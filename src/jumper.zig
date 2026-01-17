const rl = @import("raylib");
const JumperAnimation = @import("animations.zig").JumperAnimation;
const config = @import("config.zig").Config;
const std = @import("std");

pub const Jumper = struct {
    position: rl.Vector2,
    size: rl.Vector2,
    animation: JumperAnimation,
    isActive: bool = false,
    direction: rl.Vector2,
    strength: i32,

    pub fn update(self: *@This(), deltaTime: f32) void {
        if (!self.isActive) return;
        self.animation.position = self.position;
        self.animation.update(deltaTime);
    }

    pub fn move(self: *@This(), deltaX: f32, deltaY: f32) void {
        if (!self.isActive) return;
        const currentX = self.position.x + self.size.x + deltaX;
        if (self.direction.x > 0) {
            if (currentX > @as(f32, @floatFromInt(config.SCREEN_WIDTH))) {
                self.direction.x = -1.0;
            }
        } else {
            if (self.position.x - deltaX < 0) {
                self.direction.x = 1.0;
            }
        }
        const currentY = self.position.y + self.size.y + deltaY;
        if (self.direction.y > 0) {
            if (currentY > @as(f32, @floatFromInt(config.AREA_HEIGHT))) {
                self.direction.y = -1.0;
            }
        } else {
            if (self.position.y - deltaY < 0) {
                self.direction.y = 1.0;
            }
        }

        self.position.x += deltaX * self.direction.x;
        self.position.y += deltaY * self.direction.y;
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
