const std = @import("std");
const rl = @import("raylib");
const config = @import("config.zig").Config;
const Player = @import("player.zig").Player;
const Game = @import("game.zig").Game;
const AssetServer = @import("assetServer.zig").AssetServer;
const TextBlock = @import("textBlock.zig").TextBlock;
const TextAlignment = @import("textBlock.zig").TextAlignment;
const Designer = @import("designer.zig");
const PlayerScore = @import("data.zig").PlayerScore;
const Data = @import("data.zig");

pub fn main() !void {
    rl.setRandomSeed(@intCast(std.time.timestamp()));

    rl.initWindow(config.SCREEN_WIDTH, config.SCREEN_HEIGHT, "Ferris Wars Game in Zig with Raylib");
    defer rl.closeWindow();

    rl.initAudioDevice();
    defer rl.closeAudioDevice();

    rl.setTargetFPS(config.FPS);

    const assetServer = try AssetServer.load();

    var game = try Game.init(
        assetServer,
    );
    game.bestScore = try Data.loadPlayerScore();

    defer assetServer.unload();

    gameLoop: while (!rl.windowShouldClose()) {
        const deltaTime = rl.getFrameTime();

        rl.beginDrawing();
        defer rl.endDrawing();

        if (!rl.isSoundPlaying(assetServer.levelMusic) and game.music == .On) {
            rl.playSound(assetServer.levelMusic);
        }

        rl.clearBackground(config.BACKGROUND_COLOR);

        switch (game.state) {
            .Initial => {
                rl.drawTexture(
                    assetServer.cover,
                    0,
                    0,
                    rl.Color.white,
                );

                rl.drawRectangle(
                    0,
                    config.AREA_HEIGHT,
                    config.SCREEN_WIDTH,
                    config.SCREEN_HEIGHT - config.AREA_HEIGHT,
                    config.HUD_BACKGROUND_COLOR,
                );
                Designer.miniCreditText.draw(TextAlignment.Left, .{});

                if (rl.isKeyPressed(rl.KeyboardKey.enter) or Designer.StartGameButton.isClicked()) {
                    game.state = .Playing;
                }

                if (Designer.ConfigureButton.isClicked()) {
                    game.state = .MenuConfigure;
                }
            },
            .MenuConfigure => {
                rl.clearBackground(config.BACKGROUND_COLOR);
                Designer.configureView.draw(TextAlignment.Center, .{});

                if (rl.isKeyPressed(rl.KeyboardKey.m)) {
                    switch (game.music) {
                        .On => game.music = .Off,
                        .Off => game.music = .On,
                    }
                    game.setMusic();
                }

                if (rl.isKeyPressed(rl.KeyboardKey.b)) {
                    switch (game.soundEffects) {
                        .On => game.soundEffects = .Off,
                        .Off => game.soundEffects = .On,
                    }
                    game.setSoundEffects();
                }

                if (rl.isKeyPressed(rl.KeyboardKey.backspace)) {
                    game.state = .Initial;
                }
            },
            .Playing => {
                rl.clearBackground(config.BACKGROUND_COLOR);
                rl.drawTexture(
                    assetServer.background,
                    0,
                    0,
                    rl.Color.white,
                );
                rl.drawRectangle(
                    0,
                    config.AREA_HEIGHT,
                    config.SCREEN_WIDTH,
                    config.SCREEN_HEIGHT - config.AREA_HEIGHT,
                    config.HUD_BACKGROUND_COLOR,
                );
                Designer.hudText.draw(
                    .Left,
                    .{
                        game.totalBotCount,
                        game.remainingBots,
                        game.currentScore.score,
                        game.player.totalBulletsFired,
                        @as(i32, @intFromFloat(game.currentScore.elapsedTime)),
                    },
                );
                if (game.remainingBots == 0 and !game.jumper.isActive) {
                    game.state = .PlayerWin;
                    continue :gameLoop;
                }

                game.player.update(deltaTime);
                game.player.draw();

                game.botsFire();
                game.checkPlayerHitsBot();
                game.checkPlayerHitsJumper();

                if (game.checkBotCollisionWithPlayer()) continue :gameLoop;
                if (game.checkChipCollisionWithPlayer()) continue :gameLoop;
                if (game.checkBotsBulletHitPlayerCollision()) continue :gameLoop;
                if (game.checkJumperCollisionWithPlayer()) continue :gameLoop;

                for (game.bots[0..game.activeBotCount]) |*bot| {
                    bot.update(deltaTime);
                }
                for (game.bots[0..game.activeBotCount]) |*bot| {
                    bot.draw();
                    for (bot.bullets[0..]) |*b| {
                        b.update(deltaTime);
                        b.draw();
                    }
                }
                for (game.chips[0..]) |*c| {
                    c.update(deltaTime);
                    c.draw();
                }

                for (game.explosions[0..]) |*e| {
                    e.update(deltaTime);
                    e.draw();
                }

                game.jumper.update(deltaTime);
                game.jumper.move(60 * deltaTime, 30 * deltaTime);
                game.jumper.draw();
                game.currentScore.elapsedTime += deltaTime;
            },
            .PlayerWin => {
                rl.clearBackground(config.WIN_BACKGROUND_COLOR);
                Designer.playerWinText.draw(TextAlignment.Center, .{ game.calculateScore(), game.bestScore.score });
                if (!rl.isSoundPlaying(assetServer.winningSound) and !game.winningSoundPlayed) {
                    rl.playSound(assetServer.winningSound);
                    game.winningSoundPlayed = true;
                }
                if (rl.isSoundPlaying(assetServer.levelMusic)) {
                    rl.stopSound(assetServer.levelMusic);
                }
                if (rl.isKeyPressed(rl.KeyboardKey.r)) {
                    try game.reset();
                    continue :gameLoop;
                }
                const playerScore = PlayerScore.init(game.currentScore.elapsedTime, game.calculateScore());
                Data.updateBestScore(&game.bestScore, playerScore);
                try Data.savePlayerScore(game.bestScore);
            },
            .PlayerLoose => {
                rl.clearBackground(config.LOOSE_BACKGROUND_COLOR);
                Designer.gameOverText.draw(TextAlignment.Center, .{});
                if (!rl.isSoundPlaying(assetServer.losingSound) and !game.losingSoundPlayed) {
                    rl.playSound(assetServer.losingSound);
                    game.losingSoundPlayed = true;
                }
                if (rl.isSoundPlaying(assetServer.levelMusic)) {
                    rl.stopSound(assetServer.levelMusic);
                }
                if (rl.isKeyPressed(rl.KeyboardKey.r)) {
                    try game.reset();
                    continue :gameLoop;
                }
            },
        }
    }
}
