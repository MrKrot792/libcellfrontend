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

pub fn text(string: ?[]const u8, sizing: clay.Sizing, id: clay.ElementId, aligment: clay.ChildAlignment) void {
    textColor(string, sizing, id, aligment, colors.text);
}

pub fn textColor(string: ?[]const u8, sizing: clay.Sizing, id: clay.ElementId, aligment: clay.ChildAlignment, color: clay.Color) void {
    clay.UI()(clay.ElementDeclaration{
        .id = id,
        .layout = .{ .sizing = sizing, .child_alignment = aligment },
    })({
        clay.text(string orelse "Placeholder", .{ .color = color, .alignment = .center });
    });
}

pub fn bulletText(string: ?[]const u8, sizing: clay.Sizing, id: clay.ElementId, aligment: clay.ChildAlignment) void {
    clay.UI()(clay.ElementDeclaration{
        .id = id,
        .layout = .{ .child_alignment = aligment, .sizing = sizing },
    })({
        clay.UI()(clay.ElementDeclaration{
            .id = .localID("TextWithBullet"),
            .layout = .{ .direction = .left_to_right, .child_gap = 8 },
        })({
            textColor("-", .fit, .localID("Bullet"), .center, colors.bullet);
            textColor(string, .grow, .localID("Text"), .center, colors.text);
        });
    });
}

pub fn separator(id: clay.ElementId) void {
    clay.UI()(clay.ElementDeclaration{
        .id = id,
        .layout = .{
            .sizing = .{ .h = .fit, .w = .grow },
        },
        .border = .{ .width = .outside(1), .color = colors.separator },
    })({});
}
