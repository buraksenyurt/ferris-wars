const std = @import("std");
const rl = @import("raylib");
const config = @import("config.zig").Config;
const Bot = @import("bot.zig").Bot;
const Cell = @import("formation.zig").Cell;
const Chip = @import("chip.zig").Chip;
const Player = @import("player.zig").Player;
const Formations = @import("formation.zig").FORMATION;
const AssetServer = @import("assetServer.zig").AssetServer;
const Explosion = @import("animations.zig").ExplosionAnimation;
const ChipAnimation = @import("animations.zig").ChipAnimation;
const Jumper = @import("jumper.zig").Jumper;
const JumperAnimation = @import("animations.zig").JumperAnimation;
const PlayerScore = @import("data.zig").PlayerScore;
const Data = @import("data.zig");

pub const States = enum {
    Initial,
    MenuConfigure,
    Playing,
    PlayerWin,
    PlayerLoose,
};

pub const SoundState = enum {
    On,
    Off,
};

pub const Game = struct {
    player: Player,
    bots: [config.MAX_BOT_COUNT]Bot = undefined,
    chips: [config.MAX_CHIP_COUNT]Chip = undefined,
    jumper: Jumper,
    explosions: [config.MAX_EXPLOSION_COUNT]Explosion = undefined,
    activeBotCount: usize = 0,
    totalBotCount: u32 = 0,
    state: States = .Initial,
    bestScore: PlayerScore = undefined,
    currentScore: PlayerScore = undefined,
    remainingBots: usize = 0,
    assetServer: AssetServer,
    winningSoundPlayed: bool = false,
    losingSoundPlayed: bool = false,
    music: SoundState = .On,
    soundEffects: SoundState = .On,

    pub fn init(
        assetServer: AssetServer,
    ) !@This() {
        var game = @This(){
            .player = undefined,
            .jumper = undefined,
            .bots = undefined,
            .chips = undefined,
            .bestScore = undefined,
            .explosions = undefined,
            .activeBotCount = 0,
            .state = .Initial,
            .currentScore = PlayerScore.init(0.0, 0),
            .remainingBots = 0,
            .assetServer = undefined,
        };
        game.player = Player.init(assetServer);
        game.assetServer = assetServer;

        for (game.explosions[0..]) |*e| {
            e.* = Explosion.init(assetServer);
        }

        try game.loadFormation();
        try game.loadChips();
        try game.loadJumper();

        return game;
    }

    pub fn reset(self: *@This()) !void {
        self.state = .Initial;
        self.activeBotCount = 0;
        self.totalBotCount = 0;
        self.remainingBots = 0;
        self.player.bulletCooldown = 0.0;
        self.player.totalBulletsFired = 0;
        self.losingSoundPlayed = false;
        self.winningSoundPlayed = false;
        self.currentScore = PlayerScore.init(0.0, 0);
        self.player.position = rl.Vector2{
            .x = config.SCREEN_WIDTH / 2 - config.PLAYER_WIDTH / 2,
            .y = config.AREA_HEIGHT - config.PLAYER_HEIGHT,
        };
        for (self.player.bullets[0..]) |*b| {
            b.*.isActive = false;
            b.*.position = rl.Vector2{
                .x = 0,
                .y = 0,
            };
        }
        for (self.bots[0..]) |*bot| {
            bot.*.isActive = false;
        }
        for (self.chips[0..]) |*c| {
            c.*.isActive = false;
        }
        for (self.explosions[0..]) |*e| {
            e.*.isActive = false;
        }
        _ = try self.loadFormation();
        _ = try self.loadChips();
        _ = try self.loadJumper();
    }

    fn getRandomFormation() [config.FORMATION_ROW_COUNT][config.FORMATION_COL_COUNT]Cell {
        const randIndex = @as(usize, @intCast(rl.getRandomValue(0, Formations.len - 1)));
        // std.log.info("Selected Formation Index: {d}\n", .{randIndex});
        return Formations[randIndex];
    }

    fn loadFormation(self: *@This()) !void {
        const formation = getRandomFormation();
        const formationWidth: f32 = config.FORMATION_COL_COUNT * config.BOT_WIDTH;
        const offsetX: f32 = (@as(f32, @floatFromInt(config.SCREEN_WIDTH)) - formationWidth) / 2.0;
        const offsetY: f32 = config.FORMATION_START_Y;

        var counter: usize = 0;
        for (formation, 0..) |row, rowIndex| {
            for (row, 0..) |cell, colIndex| {
                if (cell == Cell.Bot) {
                    const startX = offsetX + @as(f32, @floatFromInt((colIndex * @as(usize, config.BOT_WIDTH))));
                    const startY = offsetY + @as(f32, @floatFromInt((rowIndex * @as(usize, config.BOT_HEIGHT))));
                    const b = Bot.init(self.assetServer, startX, startY);
                    self.bots[counter] = b;
                    self.remainingBots += 1;
                    counter += 1;
                }
            }
        }
        self.activeBotCount = counter;
        self.totalBotCount = @as(u32, @intCast(counter));
    }

    fn loadChips(self: *@This()) !void {
        for (self.chips[0..], 0..) |*c, index| {
            c.*.animation = ChipAnimation.init(self.assetServer);
            c.*.size = rl.Vector2{
                .x = config.CHIP_WIDTH,
                .y = config.CHIP_HEIGHT,
            };

            var validPosition = false;
            var attempts: usize = 0;

            while (!validPosition and attempts < config.CHIP_MAX_LOCATIONS_ATTEMPTS) {
                const x = @as(f32, @floatFromInt(rl.getRandomValue(0, config.SCREEN_WIDTH - @as(i32, @intFromFloat(config.CHIP_WIDTH * 2)))));
                const y = @as(f32, @floatFromInt(rl.getRandomValue(@as(i32, @intFromFloat(config.CHIP_HEIGHT * 2)), @as(i32, config.AREA_HEIGHT / 2))));

                validPosition = true;
                for (self.chips[0..index]) |other| {
                    const dx = x - other.position.x;
                    const dy = y - other.position.y;
                    const distance = @sqrt(dx * dx + dy * dy);

                    if (distance < config.CHIP_DISTANCE) {
                        validPosition = false;
                        break;
                    }
                }

                if (validPosition) {
                    c.*.position = rl.Vector2{ .x = x, .y = y };
                }

                attempts += 1;
            }

            if (!validPosition) {
                c.*.position = rl.Vector2{
                    .x = @floatFromInt(rl.getRandomValue(0, config.SCREEN_WIDTH - @as(i32, @intFromFloat(config.CHIP_WIDTH * 2)))),
                    .y = @floatFromInt(rl.getRandomValue(@as(i32, @intFromFloat(config.CHIP_HEIGHT * 2)), @as(i32, config.AREA_HEIGHT / 2))),
                };
            }

            c.*.isActive = true;
            c.*.animation.spawn(c.position.x, c.position.y);
            c.*.maxLifetime = @floatFromInt(rl.getRandomValue(@as(i32, @intFromFloat(config.CHIP_LIFETIME_RANGE[0])), @as(i32, @intFromFloat(config.CHIP_LIFETIME_RANGE[1]))));
        }
    }

    pub fn loadJumper(self: *@This()) !void {
        self.jumper.isActive = true;
        self.jumper.position = rl.Vector2{ .x = 100, .y = 100 };
        self.jumper.size = rl.Vector2{ .x = 64, .y = 64 };
        self.jumper.direction = rl.Vector2{ .x = 1.0, .y = 1.0 };
        self.jumper.animation.isActive = true;
        self.jumper.animation = JumperAnimation.init(self.assetServer);
        self.jumper.animation.spawn(100, 100);
    }

    pub fn spawnExplosion(self: *@This(), x: f32, y: f32) void {
        for (self.explosions[0..]) |*e| {
            if (!e.isActive) {
                e.spawn(x, y);
                break;
            }
        }
    }

    pub fn calculateScore(self: *@This()) u32 {
        const baseScore: f32 = @as(f32, @floatFromInt(self.totalBotCount)) * 100.0;
        const timePenalty = self.currentScore.elapsedTime * 50.0;
        const timeBonus: f32 = @max(0.0, 1000.0 - timePenalty);
        const extraBullets = @as(f32, @floatFromInt(self.player.totalBulletsFired)) - @as(f32, @floatFromInt(self.totalBotCount));
        const accuracyPenalty = extraBullets * 10.0;
        const accuracyBonus: f32 = @max(0.0, 500.0 - accuracyPenalty);

        return @as(u32, @intFromFloat(baseScore + timeBonus + accuracyBonus));
    }

    pub fn setMusic(self: *@This()) void {
        switch (self.music) {
            .On => rl.resumeSound(self.assetServer.levelMusic),
            .Off => rl.pauseSound(self.assetServer.levelMusic),
        }
    }

    pub fn setSoundEffects(self: *@This()) void {
        switch (self.soundEffects) {
            .On => self.player.soundEffectIsActive = true,
            .Off => self.player.soundEffectIsActive = false,
        }
    }

    pub fn checkPlayerBulletsCollision(self: *@This()) void {
        for (self.player.bullets[0..]) |*bullet| {
            for (self.bots[0..self.activeBotCount]) |*bot| {
                if (bullet.isActive and bot.isActive) {
                    if (rl.checkCollisionRecs(bullet.getRectangle(), bot.getRectangle())) {
                        bullet.isActive = false;
                        bot.isActive = false;
                        self.currentScore.score += 10;
                        self.remainingBots -= 1;

                        self.spawnExplosion(
                            bot.position.x + bot.size.x / 2 - 25,
                            bot.position.y + bot.size.y / 2 - 25,
                        );
                        if (self.soundEffects == .On) rl.playSound(self.assetServer.explosionSound);
                    }
                }
            }
        }
    }

    pub fn checkBotsCollision(self: *@This()) bool {
        for (self.bots[0..]) |*bot| {
            if (bot.isActive) {
                bot.playerLastPosition = self.player.position;

                if (rl.checkCollisionRecs(self.player.getRectangle(), bot.getRectangle())) {
                    self.state = .PlayerLoose;
                    return true;
                }
            }
        }
        return false;
    }

    pub fn botsFire(self: *@This()) void {
        for (self.bots[0..]) |*bot| {
            if (bot.isActive) {
                if (bot.canShoot) {
                    var bullet = &bot.bullets[bot.bulletIndex];
                    if (!bullet.isActive) {
                        bullet.position.x = bot.position.x + (bot.size.x / 2) - (bullet.size.x / 2);
                        bullet.position.y = bot.position.y + bot.size.y;
                        bullet.direction = -1.0;
                        bullet.isActive = true;
                        bot.bulletIndex = (bot.bulletIndex + 1) % config.MAX_BULLET_COUNT;
                    }
                    bot.canShoot = false;
                }
            }
        }
    }

    pub fn checkChipCollision(self: *@This()) bool {
        for (self.chips[0..]) |*c| {
            if (c.isActive) {
                if (rl.checkCollisionRecs(self.player.getRectangle(), c.getRectangle())) {
                    self.state = .PlayerLoose;
                    return true;
                }
            }
        }
        return false;
    }

    pub fn checkBotsBulletCollision(self: *@This()) bool {
        for (self.bots[0..self.activeBotCount]) |*bot| {
            if (bot.isActive) {
                for (bot.bullets[0..]) |*bullet| {
                    if (bullet.isActive) {
                        if (rl.checkCollisionRecs(self.player.getRectangle(), bullet.getRectangle())) {
                            self.state = .PlayerLoose;
                            return true;
                        }
                    }
                }
            }
        }
        return false;
    }
};
