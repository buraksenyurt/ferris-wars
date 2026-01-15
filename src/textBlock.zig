const rl = @import("raylib");

pub const TextAlignment = enum {
    Left,
    Center,
    Right,
};

pub const TextBlock = struct {
    text: [:0]const u8,
    position: rl.Vector2,
    fontSize: i32,
    color: rl.Color,

    pub fn draw(self: @This(), alignment: TextAlignment, args: anytype) void {
        var pos = self.position;
        const textToDraw = rl.textFormat(self.text, args);
        const textWidth = rl.measureText(textToDraw, self.fontSize);

        switch (alignment) {
            .Left => {},
            .Center => {
                pos.x -= @as(f32, @floatFromInt(textWidth)) / 2.0;
            },
            .Right => {
                pos.x -= @as(f32, @floatFromInt(textWidth));
            },
        }

        rl.drawText(
            textToDraw,
            @intFromFloat(pos.x),
            @intFromFloat(pos.y),
            self.fontSize,
            self.color,
        );
    }
};
