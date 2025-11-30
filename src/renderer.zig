const std = @import("std");
const rlz = @import("raylib");
const rc = @import("raylib_clay_renderer.zig");

pub fn init(name: [:0]const u8, size: [2]i32) !void {
    rlz.setConfigFlags(.{ .window_resizable = true });
    rlz.setTraceLogLevel(.warning);
    rlz.initWindow(size[0], size[1], name);

    //rc.raylib_fonts[0] = try rlz.loadFontFromMemory(".ttf", @embedFile("../assets/fonts/Menlo-Regular.ttf"), 20, null);
    rc.raylib_fonts[0] = try rlz.loadFontEx("assets/fonts/HackNerdFontMono-Regular.ttf", 32, null); // this is probably UI? i'm not sure tho
    rlz.setTextureFilter(rc.raylib_fonts[0].?.texture, .bilinear);
}

pub fn draw() void {
    // nothing for now lol
}

pub fn deinit() void {
    rlz.closeWindow();
}
