const std = @import("std");
const rlz = @import("raylib");
const clay = @import("zclay");
const rc = @import("raylib_clay_renderer.zig");

const layout = @import("layout.zig");
const colors = @import("colors.zig");

var size: [2]i32 = .{0, 0};
var memory: []u8 = undefined; 

pub fn init(name: [:0]const u8, size_: [2]i32, allocator: std.mem.Allocator) !void {
    size = size_;
    rlz.setConfigFlags(.{ .window_resizable = true });
    rlz.setTraceLogLevel(.warning);
    rlz.initWindow(size[0], size[1], name);

    //rc.raylib_fonts[0] = try rlz.loadFontFromMemory(".ttf", @embedFile("../assets/fonts/Menlo-Regular.ttf"), 20, null);
    rc.raylib_fonts[0] = try rlz.loadFontEx("assets/fonts/HackNerdFontMono-Regular.ttf", 32, null);
    rlz.setTextureFilter(rc.raylib_fonts[0].?.texture, .bilinear);

    const min_memory_size: u32 = clay.minMemorySize();
    memory = try allocator.alloc(u8, min_memory_size);
    const arena: clay.Arena = clay.createArenaWithCapacityAndMemory(memory);
    _ = clay.initialize(arena, .{ .h = @floatFromInt(rlz.getRenderHeight()), .w = @floatFromInt(rlz.getRenderWidth()) }, .{});
    clay.setMeasureTextFunction(void, {}, rc.measureText);

    std.log.debug("Clay needed {d} bytes!", .{min_memory_size});
}

pub fn loop(allocator: std.mem.Allocator) !void {
    while (!rlz.windowShouldClose()) {
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

        rlz.beginDrawing();
        rlz.clearBackground(.init(42, 42, 42, 255));
        const title_nnt: []u8 = try std.fmt.allocPrint(allocator, "FPS: {d}", .{rlz.getFPS()});
        const title: [:0]u8 = try allocator.dupeZ(u8, title_nnt);
        rlz.setWindowTitle(title);
        allocator.free(title);
        allocator.free(title_nnt);
        try rc.clayRaylibRender(commands, allocator);
        rlz.endDrawing();
    }
}

pub fn deinit(allocator: std.mem.Allocator) void {
    rlz.closeWindow();
    defer allocator.free(memory);
}
