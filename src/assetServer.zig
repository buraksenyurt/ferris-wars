const std = @import("std");
const rl = @import("raylib");

pub const AssetServer = struct {
    assets: []Asset = undefined,
    sounds: []Asset = undefined,

    pub fn load() !@This() {
        var assets = @This(){};

        const assetCount = try findAssetsCount("png");
        assets.assets = try fillAssets(assetCount, "png", AssetType.Texture);

        const soundCount = try findAssetsCount("wav");
        assets.sounds = try fillAssets(soundCount, "wav", AssetType.Sound);

        return assets;
    }

    pub fn unload(self: @This()) void {
        for (self.assets) |asset| {
            rl.unloadTexture(asset.kind.texture);
        }
        for (self.sounds) |sound| {
            rl.unloadSound(sound.kind.sound);
        }
    }

    pub fn getTexture(self: @This(), name: []const u8) rl.Texture2D {
        for (self.assets) |asset| {
            if (std.mem.eql(u8, asset.name, name)) {
                return asset.kind.texture;
            }
        }
        return undefined;
    }

    pub fn getSound(self: @This(), name: []const u8) rl.Sound {
        for (self.sounds) |sound| {
            if (std.mem.eql(u8, sound.name, name)) {
                return sound.kind.sound;
            }
        }
        return undefined;
    }
};

fn findAssetsCount(fileType: []const u8) !usize {
    var dir = try std.fs.cwd().openDir("resources", .{ .iterate = true });
    defer dir.close();
    var counter: usize = 0;

    var iterator = dir.iterate();
    while (try iterator.next()) |entry| {
        if (std.mem.endsWith(u8, entry.name, fileType)) {
            counter += 1;
        }
    }
    std.log.info("Found {} asset files.", .{counter});
    return counter;
}

fn fillAssets(count: usize, fileType: []const u8, assetType: AssetType) ![]Asset {
    var assets: []Asset = undefined;
    var allocator = std.heap.page_allocator;
    assets = try allocator.alloc(Asset, count);

    var dir = try std.fs.cwd().openDir("resources", .{ .iterate = true });
    defer dir.close();

    var iterator = dir.iterate();
    var index: usize = 0;
    while (try iterator.next()) |entry| {
        if (std.mem.endsWith(u8, entry.name, fileType)) {
            var path_buf: [256:0]u8 = undefined;
            const path = try std.fmt.bufPrintZ(&path_buf, "resources/{s}", .{entry.name});

            const fileName = if (std.mem.lastIndexOf(u8, entry.name, ".")) |dot_index|
                entry.name[0..dot_index]
            else
                entry.name;

            const copyOfFileName = try allocator.dupe(u8, fileName);

            assets[index] = switch (assetType) {
                .Texture => Asset{
                    .id = @intCast(index),
                    .name = copyOfFileName,
                    .kind = AssetUnion{ .texture = try rl.loadTexture(path) },
                },
                .Sound => Asset{
                    .id = @intCast(index),
                    .name = copyOfFileName,
                    .kind = AssetUnion{ .sound = try rl.loadSound(path) },
                },
            };
            index += 1;
        }
    }
    return assets;
}

const AssetUnion = union(enum) {
    texture: rl.Texture2D,
    sound: rl.Sound,
};

const Asset = struct {
    id: u8,
    name: []const u8,
    kind: AssetUnion,
};

const AssetType = enum {
    Texture,
    Sound,
};
