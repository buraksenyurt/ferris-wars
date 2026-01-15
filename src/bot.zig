const rl = @import("raylib");
const config = @import("config.zig").Config;
const std = @import("std");
const BotBullet = @import("botBullet.zig").BotBullet;
const AssetServer = @import("assetServer.zig").AssetServer;

pub const Bot = struct {
    position: rl.Vector2,
    initialX: f32,
    size: rl.Vector2,
    asset: rl.Texture2D,
    isActive: bool = false,
    shootTimer: f32 = 0.0,
    shootCooldown: f32 = 2.0,
    canShoot: bool = false,
    bulletIndex: usize = 0,
    bullets: [config.MAX_BULLET_COUNT]BotBullet = undefined,
    playerLastPosition: rl.Vector2 = .{ .x = 0, .y = 0 },

    pub fn init(assetServer: AssetServer, startX: f32, startY: f32) @This() {
        // std.log.info("Creating Bot at position ({d}, {d})\n", .{ startX, startY });
        const botId: usize = @intCast(rl.getRandomValue(0, assetServer.bots.len - 1));
        var bot: @This() =
            .{
                .position = rl.Vector2{
                    .x = startX,
                    .y = startY,
                },
                .initialX = startX,
                .size = rl.Vector2{
                    .x = config.BOT_WIDTH,
                    .y = config.BOT_HEIGHT,
                },
                .asset = assetServer.bots[botId],
                .isActive = true,
            };
        bot.shootCooldown = @floatFromInt(rl.getRandomValue(3, 8));
        bot.shootTimer = bot.shootCooldown;

        for (bot.bullets[0..]) |*b| {
            b.* = BotBullet.init(assetServer);
        }
        return bot;
    }

    pub fn update(self: *@This(), deltaTime: f32) void {
        if (!self.isActive) return;

        self.position.y += config.BOT_VERTICAL_SPEED * deltaTime;
        self.position.x = self.initialX + (std.math.sin(self.position.y * 0.05) * config.BOT_HORIZONTAL_SPEED);

        if (self.position.x < 0) {
            self.position.x = 0;
        } else if (self.position.x > @as(f32, config.SCREEN_WIDTH) - self.size.x) {
            self.position.x = @as(f32, config.SCREEN_WIDTH) - self.size.x;
        }

        if (self.position.y > @as(f32, config.AREA_HEIGHT - self.size.y)) {
            self.position.y = -self.size.y;
        }

        if (self.shootTimer > 0.0) {
            self.shootTimer -= deltaTime;
        } else {
            self.canShoot = true;
            self.shootTimer = self.shootCooldown;
        }
    }

    pub fn draw(self: @This()) void {
        if (!self.isActive) return;
        rl.drawTexture(
            self.asset,
            @intFromFloat(self.position.x),
            @intFromFloat(self.position.y),
            rl.Color.white,
        );
    }

    pub fn getRectangle(self: *const Bot) rl.Rectangle {
        return rl.Rectangle{
            .x = self.position.x,
            .y = self.position.y,
            .width = self.size.x,
            .height = self.size.y,
        };
    }
};
