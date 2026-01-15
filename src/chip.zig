const rl = @import("raylib");
const config = @import("config.zig").Config;
const std = @import("std");
const ChipAnimation = @import("animations.zig").ChipAnimation;
const AssetServer = @import("assetServer.zig").AssetServer;

pub const Chip = struct {
    position: rl.Vector2,
    size: rl.Vector2,
    animation: ChipAnimation,
    isActive: bool = false,
    currentLifetime: f32 = 0.0,
    maxLifetime: f32 = 0.0,
    wakeUpTime: f32 = 0.0,

    pub fn update(self: *@This(), deltaTime: f32) void {
        if (!self.isActive) return;
        self.currentLifetime += deltaTime;
        if (self.currentLifetime >= self.maxLifetime) {
            self.isActive = false;
            self.animation.isActive = false;
            return;
        }
        if (self.animation.isActive) self.animation.update(deltaTime);
    }

    pub fn draw(self: @This()) void {
        if (!self.isActive) return;
        self.animation.draw();
    }

    pub fn getRectangle(self: *const @This()) rl.Rectangle {
        return rl.Rectangle{
            .x = self.position.x,
            .y = self.position.y,
            .width = self.size.x,
            .height = self.size.y,
        };
    }
};
