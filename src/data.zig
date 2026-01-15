const std = @import("std");

pub const PlayerScore = struct {
    elapsedTime: f32,
    score: u64,

    pub fn init(elapsedTime: f32, score: u64) @This() {
        return .{
            .elapsedTime = elapsedTime,
            .score = score,
        };
    }

    pub fn compare(self: @This(), other: @This()) i32 {
        if (self.score > other.score) return -1;
        if (self.score < other.score) return 1;
        return 0;
    }
};

pub fn loadPlayerScore() !PlayerScore {
    const fileContent = std.fs.cwd().readFileAlloc(std.heap.page_allocator, "scores.dat", 1024 * 1024) catch |err| {
        if (err == error.FileNotFound) return PlayerScore.init(0.0, 0);
        return err;
    };
    defer std.heap.page_allocator.free(fileContent);

    const lineString = std.mem.trim(u8, fileContent, &std.ascii.whitespace);
    if (lineString.len == 0) return PlayerScore.init(0.0, 0);

    var fields = std.mem.splitScalar(u8, lineString, ',');
    const elapsedTimeField = fields.next();
    const scoreField = fields.next();

    if (elapsedTimeField) |t_str| {
        if (scoreField) |s_str| {
            const timeStr = std.mem.trim(u8, t_str, &std.ascii.whitespace);
            const time = std.fmt.parseFloat(f32, timeStr) catch return PlayerScore.init(0.0, 0);
            const score = std.fmt.parseInt(u64, std.mem.trim(u8, s_str, &std.ascii.whitespace), 10) catch return PlayerScore.init(0.0, 0);

            return PlayerScore.init(time, score);
        }
    }

    return PlayerScore.init(0.0, 0);
}

pub fn savePlayerScore(bestScore: PlayerScore) !void {
    if (bestScore.score == 0) return;

    var file = try std.fs.cwd().createFile(
        "scores.dat",
        .{ .truncate = true },
    );
    defer file.close();

    const line = try std.fmt.allocPrint(std.heap.page_allocator, "{d:.2},{}\n", .{ bestScore.elapsedTime, bestScore.score });
    defer std.heap.page_allocator.free(line);

    try file.writeAll(line);
}

pub fn updateBestScore(bestScore: *PlayerScore, newScore: PlayerScore) void {
    if (bestScore.score == 0 or newScore.score > bestScore.score) {
        bestScore.* = newScore;
    }
}
