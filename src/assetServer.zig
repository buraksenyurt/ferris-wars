const rl = @import("raylib");

pub const AssetServer = struct {
    player: rl.Texture2D = undefined,
    bots: [3]rl.Texture2D = undefined,
    bullet: rl.Texture2D = undefined,
    botBullet: rl.Texture2D = undefined,
    cover: rl.Texture2D = undefined,
    explosionAnimation: rl.Texture2D = undefined,
    chipAnimation: rl.Texture2D = undefined,
    jumperAnimation: rl.Texture2D = undefined,
    winningSound: rl.Sound = undefined,
    losingSound: rl.Sound = undefined,
    explosionSound: rl.Sound = undefined,
    levelMusic: rl.Sound = undefined,
    shootingSound: rl.Sound = undefined,

    pub fn load() !@This() {
        var assets = @This(){};

        // Textures
        assets.player = try rl.loadTexture("resources/assets/hero.png");
        assets.bots[0] = try rl.loadTexture("resources/assets/bot_1.png");
        assets.bots[1] = try rl.loadTexture("resources/assets/bot_2.png");
        assets.bots[2] = try rl.loadTexture("resources/assets/bot_3.png");
        assets.bullet = try rl.loadTexture("resources/assets/rocket.png");
        assets.botBullet = try rl.loadTexture("resources/assets/botBullet.png");
        assets.cover = try rl.loadTexture("resources/assets/splash.png");

        // Sprite Sheets
        assets.explosionAnimation = try rl.loadTexture("resources/sheets/explosion.png");
        assets.chipAnimation = try rl.loadTexture("resources/sheets/chip.png");
        assets.jumperAnimation = try rl.loadTexture("resources/sheets/jumper.png");

        // Sounds
        assets.winningSound = try rl.loadSound("resources/audios/winning.wav");
        assets.losingSound = try rl.loadSound("resources/audios/losing.wav");
        assets.explosionSound = try rl.loadSound("resources/audios/explosion.wav");
        assets.levelMusic = try rl.loadSound("resources/audios/levelMusic.wav");
        assets.shootingSound = try rl.loadSound("resources/audios/shooting.wav");
        return assets;
    }

    pub fn unload(self: @This()) void {
        rl.unloadTexture(self.player);
        for (self.bots[0..]) |bot| {
            rl.unloadTexture(bot);
        }
        rl.unloadTexture(self.bullet);
        rl.unloadTexture(self.cover);
        rl.unloadTexture(self.botBullet);
        rl.unloadTexture(self.explosionAnimation);
        rl.unloadTexture(self.chipAnimation);
        rl.unloadTexture(self.jumperAnimation);

        rl.unloadSound(self.winningSound);
        rl.unloadSound(self.losingSound);
        rl.unloadSound(self.explosionSound);
        rl.unloadSound(self.levelMusic);
        rl.unloadSound(self.shootingSound);
    }
};
