const rl = @import("raylib");
const config = @import("config.zig").Config;
const std = @import("std");
const Bullet = @import("bullet.zig").Bullet;
const AssetServer = @import("assetServer.zig").AssetServer;

pub const Player = struct {
    position: rl.Vector2,
    size: rl.Vector2,
    bullets: [config.MAX_BULLET_COUNT]Bullet = undefined,
    bulletCooldown: f32 = 0.0,
    totalBulletsFired: u32 = 0,
    assetServer: AssetServer,
    soundEffectIsActive: bool = false,

    pub fn init(assetServer: AssetServer) @This() {
        var p: Player =
            .{
                .position = rl.Vector2{
                    .x = config.SCREEN_WIDTH / 2 - config.PLAYER_WIDTH / 2,
                    .y = config.AREA_HEIGHT - config.PLAYER_HEIGHT,
                },
                .size = rl.Vector2{
                    .x = config.PLAYER_WIDTH,
                    .y = config.PLAYER_HEIGHT,
                },
                .assetServer = assetServer,
            };
        for (p.bullets[0..]) |*b| {
            b.* = Bullet.init(assetServer);
        }

        return p;
    }

    pub fn update(self: *@This(), deltaTime: f32) void {
        const movement = config.PLAYER_SPEED * deltaTime;

        if (rl.isKeyDown(rl.KeyboardKey.right)) {
            self.position.x += movement;
            if (self.position.x > @as(f32, @floatFromInt(config.SCREEN_WIDTH)) - self.size.x) {
                self.position.x = @as(f32, @floatFromInt(config.SCREEN_WIDTH)) - self.size.x;
            }
        }
        if (rl.isKeyDown(rl.KeyboardKey.left)) {
            self.position.x -= movement;
            if (self.position.x < 0) {
                self.position.x = 0;
            }
        }
        if (rl.isKeyDown(rl.KeyboardKey.up)) {
            self.position.y -= movement;
            if (self.position.y < 0) {
                self.position.y = 0;
            }
        }
        if (rl.isKeyDown(rl.KeyboardKey.down)) {
            self.position.y += movement;
            if (self.position.y > @as(f32, @floatFromInt(config.AREA_HEIGHT)) - self.size.y) {
                self.position.y = @as(f32, @floatFromInt(config.AREA_HEIGHT)) - self.size.y;
            }
        }

        if (rl.isKeyPressed(rl.KeyboardKey.space)) {
            for (self.bullets[0..]) |*b| {
                if (!b.isActive and self.bulletCooldown <= 0) {
                    b.position.x = self.position.x + (self.size.x / 2) - (b.size.x / 2);
                    b.position.y = self.position.y;
                    b.isActive = true;
                    self.bulletCooldown = config.BULLET_COOLDOWN;
                    self.totalBulletsFired += 1;

                    if (!rl.isSoundPlaying(self.assetServer.shootingSound) and self.soundEffectIsActive) {
                        rl.playSound(self.assetServer.shootingSound);
                    }

                    break;
                }
            }
        }
        if (self.bulletCooldown > 0) {
            self.bulletCooldown -= deltaTime;
        }
    }

    pub fn draw(self: *@This()) void {
        const x = @max(
            @min(self.position.x, @as(f32, @floatFromInt(std.math.maxInt(i32)))),
            @as(f32, @floatFromInt(std.math.minInt(i32))),
        );
        const y = @max(
            @min(self.position.y, @as(f32, @floatFromInt(std.math.maxInt(i32)))),
            @as(f32, @floatFromInt(std.math.minInt(i32))),
        );

        rl.drawTexture(
            self.assetServer.player,
            @intFromFloat(x),
            @intFromFloat(y),
            rl.Color.white,
        );

        for (self.bullets[0..]) |*b| {
            b.update(rl.getFrameTime());
            b.draw();
        }
    }

    pub fn getRectangle(self: *const Player) rl.Rectangle {
        return rl.Rectangle{
            .x = self.position.x,
            .y = self.position.y,
            .width = self.size.x,
            .height = self.size.y,
        };
    }
};
