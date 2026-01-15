const rl = @import("raylib");

pub const Button = struct {
    Location: rl.Vector2,
    Size: rl.Vector2,
    id: u8,

    pub fn init(id: u8, location: rl.Vector2, size: rl.Vector2) @This() {
        return Button{
            .id = id,
            .Location = location,
            .Size = size,
        };
    }

    pub fn isClicked(self: @This()) bool {
        const mousePosition = rl.getMousePosition();
        return mousePosition.x >= self.Location.x and
            mousePosition.x <= (self.Location.x + self.Size.x) and
            mousePosition.y >= self.Location.y and
            mousePosition.y <= (self.Location.y + self.Size.y) and
            rl.isMouseButtonPressed(rl.MouseButton.left);
    }
};
