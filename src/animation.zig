const rl = @import("raylib");
const config = @import("config.zig").Config;
const AssetServer = @import("assetServer.zig").AssetServer;

pub const Animation = struct {
    position: rl.Vector2,
    isActive: bool,
    frames: []const rl.Rectangle,
    frameOrder: []const usize,
    currentFrame: usize,
    frameTimer: f32,
    frameDuration: f32,
    spriteSheet: rl.Texture2D,

    pub fn init(
        assetServer: AssetServer,
        frameDuration: f32,
        spriteName: []const u8,
        frames: []const rl.Rectangle,
        frameOrder: []const usize,
    ) @This() {
        return .{
            .position = rl.Vector2{ .x = 0, .y = 0 },
            .isActive = false,
            .currentFrame = 0,
            .frameTimer = 0.0,
            .frameDuration = frameDuration,
            .spriteSheet = assetServer.getTexture(spriteName),
            .frames = frames,
            .frameOrder = frameOrder,
        };
    }

    pub fn spawn(self: *@This(), x: f32, y: f32) void {
        self.position = rl.Vector2{ .x = x, .y = y };
        self.isActive = true;
        self.currentFrame = 0;
        self.frameTimer = 0.0;
    }

    pub fn update(self: *@This(), deltaTime: f32, oneTime: bool) void {
        if (!self.isActive) return;

        self.frameTimer += deltaTime;
        if (self.frameTimer >= self.frameDuration) {
            self.frameTimer = 0.0;
            self.currentFrame += 1;

            if (self.currentFrame >= self.frameOrder.len) {
                if (oneTime) {
                    self.isActive = false;
                } else {
                    self.currentFrame = 0;
                }
            }
        }
    }

    pub fn draw(self: @This()) void {
        if (!self.isActive) return;

        const frameIndex = self.frameOrder[self.currentFrame];
        const sourceRect = self.frames[frameIndex];

        const scale: f32 = 0.8;
        const destRect = rl.Rectangle{
            .x = self.position.x,
            .y = self.position.y,
            .width = sourceRect.width * scale,
            .height = sourceRect.height * scale,
        };

        rl.drawTexturePro(
            self.spriteSheet,
            sourceRect,
            destRect,
            rl.Vector2{ .x = 0, .y = 0 },
            0.0,
            rl.Color.white,
        );
    }
};
