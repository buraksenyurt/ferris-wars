const rl = @import("raylib");
const config = @import("config.zig").Config;
const AssetServer = @import("assetServer.zig").AssetServer;

pub const BotBullet = struct {
    position: rl.Vector2,
    size: rl.Vector2,
    asset: rl.Texture2D,
    isActive: bool = false,
    cooldown: f32 = 0.0,
    direction: f32 = -1.0,

    pub fn init(assetServer: AssetServer) @This() {
        return .{
            .position = rl.Vector2{
                .x = 0,
                .y = 0,
            },
            .size = rl.Vector2{
                .x = config.BULLET_WIDTH,
                .y = config.BULLET_HEIGHT,
            },
            .isActive = false,
            .asset = assetServer.get("botBullet"),
        };
    }

    pub fn update(self: *@This(), deltaTime: f32) void {
        if (!self.isActive) return;
        self.position.y -= config.BOT_BULLET_SPEED * deltaTime * self.direction;
        if (self.position.y + self.size.y < 0 or self.position.y > @as(f32, config.AREA_HEIGHT)) {
            self.isActive = false;
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

    pub fn getRectangle(self: *const @This()) rl.Rectangle {
        return rl.Rectangle{
            .x = self.position.x,
            .y = self.position.y,
            .width = self.size.x,
            .height = self.size.y,
        };
    }
};
