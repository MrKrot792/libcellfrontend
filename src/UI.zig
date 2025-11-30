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

pub fn draw(allocator: std.mem.Allocator) !void {
    clay.setPointerState(.{ 
        .x = @floatFromInt(rlz.getMouseX()),
        .y = @floatFromInt(rlz.getMouseY()),
    }, rlz.isMouseButtonDown(.left));

    if (rlz.isKeyPressed(.d)) {
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
            .layout = .{ .sizing = .{ .h = .grow, .w = .percent(0.8) }},
            .background_color = colors.background,
            .border = .{ .width = .outside(2), .color = colors.border },
        })({
            layout.text("If you're seeing this, something's wrong.", .grow, .ID("CellsText"));
        });

        // The "cell select" menu
        clay.UI()(clay.ElementDeclaration{
            .id = .ID("Menu"),
            .layout = .{ 
                .sizing = .grow,
                .direction = .top_to_bottom,
                .child_alignment = .{ .x = .center, .y = .top },
                .child_gap = 4,
                .padding = .all(16),
            },
            .background_color = colors.background,
            .border = .{ .width = .outside(2), .color = colors.border },
        })({
            // The time menu
            clay.UI()(clay.ElementDeclaration{
                .id = .ID("TimeControl"),
                .layout = .{
                    .sizing = .{
                        .w = .grow,
                        .h = .fit,
                    },
                    .child_gap = 8,
                    .child_alignment = .center,
                    .padding = .all(8),
                },
                .border = .{ .color = colors.border, .width = .outside(2) },
                .corner_radius = .all(4),
            })({

            });
        });
    });
    const commands = clay.endLayout();

    try rc.clayRaylibRender(commands, allocator);
}
