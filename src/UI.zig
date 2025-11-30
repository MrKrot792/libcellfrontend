const std = @import("std");
const clay = @import("zclay");
const rlz = @import("raylib");
const rc = @import("raylib_clay_renderer.zig");

const layout = @import("layout.zig");
const colors = @import("colors.zig");

var memory: []u8 = undefined; 

const log = std.log.scoped(.UI);

/// Must be initialized **AFTER** the cells renderer.
pub fn init(allocator: std.mem.Allocator) !void {
    const min_memory_size: u32 = clay.minMemorySize();
    memory = try allocator.alloc(u8, min_memory_size);
    const arena: clay.Arena = clay.createArenaWithCapacityAndMemory(memory);
    _ = clay.initialize(arena, .{ .h = @floatFromInt(rlz.getRenderHeight()), .w = @floatFromInt(rlz.getRenderWidth()) }, .{});
    clay.setMeasureTextFunction(void, {}, rc.measureText);

    log.debug("Clay needed {d} bytes!", .{min_memory_size});
}

pub fn deinit(allocator: std.mem.Allocator) void {
    allocator.free(memory);
}

pub fn getCellsDimensions() clay.BoundingBox {
    const result = clay.getElementData(.ID("CellsContainer"));
    if (!result.found) log.err("Could not create a bounding box for the cells renderer!", .{});
    return result.bounding_box;
}

pub fn draw(allocator: std.mem.Allocator) !void {
    clay.setPointerState(.{ 
        .x = @floatFromInt(rlz.getMouseX()),
        .y = @floatFromInt(rlz.getMouseY()),
    }, rlz.isMouseButtonDown(.left));

    if (rlz.isKeyPressed(.h)) {
        clay.setDebugModeEnabled(!clay.isDebugModeEnabled());
    }

    if (rlz.isWindowResized()) clay.setLayoutDimensions(.{ .h = @floatFromInt(rlz.getRenderHeight()), .w = @floatFromInt(rlz.getRenderWidth()) });

    clay.beginLayout();
    clay.UI()(clay.ElementDeclaration{
        .id = .ID("Root"),
        .layout = .{
            .padding = .all(4), 
            .child_gap = 4,
            .sizing = .grow,
        },
        })({
        // Placeholder for the cells illustration
        clay.UI()(clay.ElementDeclaration{
            .id = .ID("Cells"),
            .layout = .{ .sizing = .{ .h = .grow, .w = .percent(0.8) }, .padding = .all(2)},
            .background_color = colors.background,
            .border = .{ .width = .outside(2), .color = colors.border },
        })({
            clay.UI()(clay.ElementDeclaration{
                .id = .ID("CellsContainer"),
                .layout = .{ .sizing = .grow },
                .background_color = colors.background,
            })({
                layout.text("If you're seeing this, something's wrong.", .grow, .ID("CellsText"), .center);
            });
        });

        // The "cell select" menu
        clay.UI()(clay.ElementDeclaration{
            .id = .ID("Menu"),
            .layout = .{ 
                .sizing = .grow,
                .direction = .top_to_bottom,
                .child_alignment = .{ .x = .center, .y = .top },
                .child_gap = 8,
                .padding = .all(16),
            },
            .background_color = colors.background,
            .border = .{ .width = .outside(2), .color = colors.border },
        })({
            layout.text("Information", .{ .h = .fit, .w = .grow }, .ID("Information"), .center);
            layout.separator(.ID("Separator"));
            layout.bulletText("Time control", .{ .h = .fit, .w = .grow }, .ID("TimeControl"), .{ .x = .left, .y = .center });
        });
    });
    const commands = clay.endLayout();
    try rc.clayRaylibRender(commands, allocator);
}
