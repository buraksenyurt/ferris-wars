const TextBlock = @import("textBlock.zig").TextBlock;
const TextAlignment = @import("textBlock.zig").TextAlignment;
const Button = @import("button.zig").Button;
const rl = @import("raylib");
const config = @import("config.zig").Config;

const HORIZONTAL_CENTER = @as(f32, config.SCREEN_WIDTH) / 2.0;
const VERTICAL_CENTER = @as(f32, config.SCREEN_HEIGHT) / 2.0;

pub const gameOverText = TextBlock{
    .text = "Game Over! Press R to Restart",
    .position = rl.Vector2{
        .x = HORIZONTAL_CENTER,
        .y = VERTICAL_CENTER - @as(f32, config.TITLE_FONT_SIZE * 2),
    },
    .fontSize = config.TITLE_FONT_SIZE,
    .color = rl.Color.white,
};

pub const playerWinText = TextBlock{
    .text = "You Win with %d points.!\nPress R to Restart\n\nBest Score: %d points.",
    .position = rl.Vector2{
        .x = HORIZONTAL_CENTER,
        .y = VERTICAL_CENTER - @as(f32, config.TITLE_FONT_SIZE * 4),
    },
    .fontSize = config.TITLE_FONT_SIZE,
    .color = rl.Color.white,
};

pub const hudText = TextBlock{
    .text = "Bots: %d/%d Hit: %d Bullets: %d Time: %d s",
    .position = rl.Vector2{
        .x = 10.0,
        .y = @as(f32, config.AREA_HEIGHT) + 10.0,
    },
    .fontSize = config.HUD_FONT_SIZE,
    .color = config.HUD_FONT_COLOR,
};

pub const miniCreditText = TextBlock{
    .text = "Developed by Burak Selim Senyurt - 2025",
    .position = rl.Vector2{
        .x = 10.0,
        .y = @as(f32, config.AREA_HEIGHT) + 10.0,
    },
    .fontSize = config.HUD_FONT_SIZE,
    .color = rl.Color.white,
};

const configurationViewText =
    \\  Configuration
    \\
    \\
    \\
    \\  Use the following keys 
    \\  to configure the game:
    \\
    \\
    \\  M - Toggle Music On/Off
    \\  B - Toggle Sound Effects 
    \\      On/Off
    \\
    \\
    \\  Press `Backspace` to return 
    \\  to the main menu.
;

pub const configureView = TextBlock{
    .text = configurationViewText,
    .position = rl.Vector2{
        .x = HORIZONTAL_CENTER,
        .y = VERTICAL_CENTER - @as(f32, config.CONFIGURATION_FONT_SIZE * 12),
    },
    .fontSize = config.CONFIGURATION_FONT_SIZE,
    .color = rl.Color.black,
};

pub const StartGameButton = Button.init(
    1,
    rl.Vector2{
        .x = 148.0,
        .y = 584.0,
    },
    rl.Vector2{ .x = 210.0, .y = 50.0 },
);

pub const ConfigureButton = Button.init(
    2,
    rl.Vector2{
        .x = 148.0,
        .y = 642.0,
    },
    rl.Vector2{ .x = 210.0, .y = 50.0 },
);
