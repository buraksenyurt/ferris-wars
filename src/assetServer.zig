const std = @import("std");
const rl = @import("raylib");

pub const AssetServer = struct {
    assets: []Asset = undefined,
    sounds: []Sound = undefined,

    pub fn load() !@This() {
        var assets = @This(){};

        const assetCount = try findAssetsCount("png");
        assets.assets = try fillAssets(assetCount);

        const soundCount = try findAssetsCount("wav");
        assets.sounds = try fillSounds(soundCount);

        return assets;
    }

    pub fn unload(self: @This()) void {
        for (self.assets) |asset| {
            rl.unloadTexture(asset.texture);
        }
        for (self.sounds) |sound| {
            rl.unloadSound(sound.sound);
        }
    }

    pub fn get(self: @This(), name: []const u8) rl.Texture2D {
        for (self.assets) |asset| {
            if (std.mem.eql(u8, asset.name, name)) {
                return asset.texture;
            }
        }
        return undefined;
    }

    pub fn getSound(self: @This(), name: []const u8) rl.Sound {
        for (self.sounds) |sound| {
            if (std.mem.eql(u8, sound.name, name)) {
                return sound.sound;
            }
        }
        return undefined;
    }
};

fn findAssetsCount(fileType: []const u8) !usize {
    var dir = try std.fs.cwd().openDir("resources/assets", .{ .iterate = true });
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

fn fillSounds(count: usize) ![]Sound {
    var sounds: []Sound = undefined;
    var allocator = std.heap.page_allocator;
    sounds = try allocator.alloc(Sound, count);

    var dir = try std.fs.cwd().openDir("resources/assets", .{ .iterate = true });
    defer dir.close();

    var iterator = dir.iterate();
    var index: usize = 0;
    while (try iterator.next()) |entry| {
        if (std.mem.endsWith(u8, entry.name, "wav")) {
            var path_buf: [256:0]u8 = undefined;
            const path = try std.fmt.bufPrintZ(&path_buf, "resources/assets/{s}", .{entry.name});

            const fileName = if (std.mem.lastIndexOf(u8, entry.name, ".")) |dot_index|
                entry.name[0..dot_index]
            else
                entry.name;

            const copyOfFileName = try allocator.dupe(u8, fileName);

            sounds[index] = Sound{
                .id = @intCast(index),
                .name = copyOfFileName,
                .sound = try rl.loadSound(path),
            };
            index += 1;
        }
    }
    return sounds;
}

const Asset = struct {
    id: u8,
    name: []const u8,
    texture: rl.Texture2D,
};

const Sound = struct {
    id: u8,
    name: []const u8,
    sound: rl.Sound,
};
