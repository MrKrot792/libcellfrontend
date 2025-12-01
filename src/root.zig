const std = @import("std");
const rlz = @import("raylib");
const clay = @import("zclay");
const rc = @import("raylib_clay_renderer.zig");

const ui = @import("UI.zig");
const cells = @import("renderer.zig");

const fps = @import("fps.zig");

pub fn init(name: [:0]const u8, size: [2]i32, allocator: std.mem.Allocator) !void {
    try cells.init(name, size);
    try ui.init(allocator);
}

pub fn loop(allocator: std.mem.Allocator) !void {
    var fps_info: fps.FpsInfo = .zero;

    var timer = try fps.Timer.start();

    while (!rlz.windowShouldClose()) {
        fps.frameStart(&timer);
        const title_nnt: []u8 = try std.fmt.allocPrint(allocator, "FPS: {d}", .{rlz.getFPS()});
        const title: [:0]u8 = try allocator.dupeZ(u8, title_nnt);
        rlz.setWindowTitle(title);

        rlz.beginDrawing();
            rlz.clearBackground(.init(42, 42, 42, 255));

            // Drawing the UI
            try ui.draw(allocator);
            try cells.draw(ui.getCellsDimensions(), fps_info.delta);
        rlz.endDrawing();

        // TODO: change this to an arena
        allocator.free(title);
        allocator.free(title_nnt);
        fps_info = fps.frameEnd(&timer);
    }
}

pub fn deinit(allocator: std.mem.Allocator) void {
    cells.deinit();
    ui.deinit(allocator);
}
