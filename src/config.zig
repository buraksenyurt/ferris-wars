const rl = @import("raylib");

pub const Config = struct {
    // Game
    pub const SCREEN_WIDTH: i32 = 500;
    pub const SCREEN_HEIGHT: i32 = 800;
    pub const AREA_HEIGHT: i32 = 750;
    pub const FPS: i32 = 60;
    pub const TITLE_FONT_SIZE: i32 = 30;
    pub const HUD_FONT_SIZE: i32 = 20;
    pub const CONFIGURATION_FONT_SIZE: i32 = 28;

    // Player
    pub const PLAYER_SPEED: f32 = 250.0;
    pub const PLAYER_WIDTH: f32 = 96.0;
    pub const PLAYER_HEIGHT: f32 = 67.0;

    // Player Bullets
    pub const MAX_BULLET_COUNT: usize = 5;
    pub const BULLET_SPEED: f32 = 300.0;

    // Bots
    pub const BOT_WIDTH: f32 = 64.0;
    pub const BOT_HEIGHT: f32 = 64.0;
    pub const BOT_VERTICAL_SPEED: f32 = 60.0;
    pub const BOT_HORIZONTAL_SPEED: f32 = 40.0;
    pub const MAX_BOT_COUNT: usize = 20;
    pub const BOT_BULLET_SPEED: f32 = 150.0;
    pub const BOT_POINT_VALUE: f32 = 9.80;

    // Bot Formation
    pub const FORMATION_ROW_COUNT: usize = 4;
    pub const FORMATION_COL_COUNT: usize = 5;
    pub const FORMATION_START_Y: f32 = -300.0;

    // Colors
    pub const BACKGROUND_COLOR = rl.Color{ .r = 190, .g = 136, .b = 113, .a = 100 };
    pub const HUD_BACKGROUND_COLOR = rl.Color{ .r = 56, .g = 0, .b = 0, .a = 255 };
    pub const HUD_FONT_COLOR = rl.Color{ .r = 255, .g = 186, .b = 0, .a = 255 };
    pub const WIN_BACKGROUND_COLOR = rl.Color{ .r = 0, .g = 104, .b = 0, .a = 255 };
    pub const LOOSE_BACKGROUND_COLOR = rl.Color{ .r = 107, .g = 0, .b = 0, .a = 255 };

    pub const BULLET_WIDTH: f32 = 15.0;
    pub const BULLET_HEIGHT: f32 = 32.0;
    pub const BULLET_COOLDOWN: f32 = 0.3;

    // Chips
    pub const MAX_CHIP_COUNT: usize = 8;
    pub const CHIP_WIDTH: f32 = 36.0;
    pub const CHIP_HEIGHT: f32 = 36.0;
    pub const CHIP_LIFETIME_RANGE: [2]f32 = .{ 10.0, 25.0 };
    pub const CHIP_DISTANCE: f32 = 80.0;
    pub const CHIP_MAX_LOCATIONS_ATTEMPTS: usize = 50;

    // Explosions
    pub const MAX_EXPLOSION_COUNT: usize = 10;
};
