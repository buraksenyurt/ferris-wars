const config = @import("config.zig").Config;

pub const Cell = enum(u8) {
    Empty = 0,
    Bot = 1,
};

pub const FORMATION = [_][config.FORMATION_ROW_COUNT][config.FORMATION_COL_COUNT]Cell{
    .{
        .{ .Bot, .Empty, .Empty, .Empty, .Bot },
        .{ .Bot, .Empty, .Empty, .Empty, .Bot },
        .{ .Empty, .Bot, .Empty, .Bot, .Empty },
        .{ .Empty, .Empty, .Bot, .Empty, .Empty },
    },
    .{
        .{ .Empty, .Empty, .Empty, .Empty, .Empty },
        .{ .Empty, .Bot, .Empty, .Bot, .Empty },
        .{ .Bot, .Empty, .Bot, .Empty, .Bot },
        .{ .Empty, .Bot, .Empty, .Bot, .Empty },
    },
    .{
        .{ .Empty, .Bot, .Empty, .Bot, .Empty },
        .{ .Bot, .Empty, .Bot, .Empty, .Bot },
        .{ .Empty, .Bot, .Empty, .Bot, .Empty },
        .{ .Bot, .Empty, .Bot, .Empty, .Bot },
    },
    .{
        .{ .Bot, .Empty, .Bot, .Empty, .Bot },
        .{ .Bot, .Empty, .Bot, .Empty, .Bot },
        .{ .Bot, .Empty, .Bot, .Empty, .Bot },
        .{ .Bot, .Empty, .Bot, .Empty, .Bot },
    },
    .{
        .{ .Empty, .Empty, .Bot, .Empty, .Empty },
        .{ .Empty, .Bot, .Bot, .Bot, .Empty },
        .{ .Bot, .Bot, .Bot, .Bot, .Bot },
        .{ .Empty, .Empty, .Bot, .Empty, .Empty },
    },
    .{
        .{ .Bot, .Bot, .Bot, .Bot, .Bot },
        .{ .Empty, .Bot, .Bot, .Bot, .Empty },
        .{ .Empty, .Empty, .Bot, .Empty, .Empty },
        .{ .Empty, .Empty, .Bot, .Empty, .Empty },
    },
    .{
        .{ .Empty, .Empty, .Empty, .Empty, .Empty },
        .{ .Empty, .Empty, .Bot, .Empty, .Empty },
        .{ .Empty, .Bot, .Bot, .Bot, .Empty },
        .{ .Bot, .Bot, .Bot, .Bot, .Bot },
    },
};
