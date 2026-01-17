const std = @import("std");
const rl = @import("raylib");

pub const AssetServer = struct {
    assets: []Asset = undefined,
    winningSound: rl.Sound = undefined,
    losingSound: rl.Sound = undefined,
    explosionSound: rl.Sound = undefined,
    levelMusic: rl.Sound = undefined,
    shootingSound: rl.Sound = undefined,

    pub fn load() !@This() {
        var assets = @This(){};

        const assetCount = try findAssetsCount();
        assets.assets = try fillAssets(assetCount);

        // Sounds
        assets.winningSound = try rl.loadSound("resources/audios/winning.wav");
        assets.losingSound = try rl.loadSound("resources/audios/losing.wav");
        assets.explosionSound = try rl.loadSound("resources/audios/explosion.wav");
        assets.levelMusic = try rl.loadSound("resources/audios/levelMusic.wav");
        assets.shootingSound = try rl.loadSound("resources/audios/shooting.wav");
        return assets;
    }

    pub fn unload(self: @This()) void {
        rl.unloadSound(self.winningSound);
        rl.unloadSound(self.losingSound);
        rl.unloadSound(self.explosionSound);
        rl.unloadSound(self.levelMusic);
        rl.unloadSound(self.shootingSound);
    }

    pub fn get(self: @This(), name: []const u8) rl.Texture2D {
        for (self.assets) |asset| {
            if (std.mem.eql(u8, asset.name, name)) {
                return asset.texture;
            }
        }
        return undefined;
    }
};

fn findAssetsCount() !usize {
    var dir = try std.fs.cwd().openDir("resources/assets", .{ .iterate = true });
    defer dir.close();
    var counter: usize = 0;

    var iterator = dir.iterate();
    while (try iterator.next()) |entry| {
        if (std.mem.endsWith(u8, entry.name, "png")) {
            counter += 1;
        }
    }
    std.log.info("Found {} asset files.", .{counter});
    return counter;
}

fn fillAssets(count: usize) ![]Asset {
    var assets: []Asset = undefined;
    var allocator = std.heap.page_allocator;
    assets = try allocator.alloc(Asset, count);

    var dir = try std.fs.cwd().openDir("resources/assets", .{ .iterate = true });
    defer dir.close();

    var iterator = dir.iterate();
    var index: usize = 0;
    while (try iterator.next()) |entry| {
        if (std.mem.endsWith(u8, entry.name, "png")) {
            var path_buf: [256:0]u8 = undefined;
            const path = try std.fmt.bufPrintZ(&path_buf, "resources/assets/{s}", .{entry.name});

            const fileName = if (std.mem.lastIndexOf(u8, entry.name, ".")) |dot_index|
                entry.name[0..dot_index]
            else
                entry.name;

            const copyOfFileName = try allocator.dupe(u8, fileName);

            assets[index] = Asset{
                .id = @intCast(index),
                .name = copyOfFileName,
                .texture = try rl.loadTexture(path),
            };
            index += 1;
        }
    }
    // std.log.warn("{any}", .{assets});
    return assets;
}

const Asset = struct {
    id: u8,
    name: []const u8,
    texture: rl.Texture2D,
};
