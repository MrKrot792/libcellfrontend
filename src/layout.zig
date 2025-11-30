const clay = @import("zclay");
const rlz = @import("raylib");
const colors = @import("colors.zig");

pub fn imageButton(texture: *rlz.Texture, elementId: clay.ElementId) void {
    _ = texture;
    clay.UI()(clay.ElementDeclaration{
        .id = elementId,
        .layout = .{ .sizing = .{ .h = .fixed(50), .w = .fixed(50) } },
        .background_color = colors.button,
    })({
    });
}

pub fn text(string: ?[]const u8, sizing: clay.Sizing, id: clay.ElementId) void {
    clay.UI()(clay.ElementDeclaration{
        .id = id,
        .layout = .{ .sizing = sizing, .child_alignment = .center },
    })({
        clay.text(string orelse "Placeholder", .{ .color = colors.text, .alignment = .center });
    });
}

