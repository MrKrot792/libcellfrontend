const std = @import("std");
const rlz = @import("raylib");
const rc = @import("raylib_clay_renderer.zig");
const clay = @import("zclay");

var image: rlz.Image = undefined;
var texture: rlz.Texture = undefined;

pub fn init(name: [:0]const u8, size: [2]i32) !void {
    rlz.setConfigFlags(.{ .window_resizable = true });
    rlz.setTraceLogLevel(.warning);
    rlz.initWindow(size[0], size[1], name);

    //rc.raylib_fonts[0] = try rlz.loadFontFromMemory(".ttf", @embedFile("../assets/fonts/Menlo-Regular.ttf"), 20, null);
    rc.raylib_fonts[0] = try rlz.loadFontEx("assets/fonts/HackNerdFontMono-Regular.ttf", 32, null); // this is probably UI? i'm not sure tho
    rlz.setTextureFilter(rc.raylib_fonts[0].?.texture, .bilinear);

    image = .genGradientLinear(10, 10, 0, .red, .blue);
    texture = try image.toTexture();
}

pub fn draw(where: clay.BoundingBox) !void {
    rlz.updateTexture(texture, image.data);
    if (rlz.isWindowResized()) {
        image = .genGradientLinear(@intFromFloat(where.width), @intFromFloat(where.height), 0, .red, .blue);
        texture = try .fromImage(image);
    }

    texture.draw(@intFromFloat(where.x), @intFromFloat(where.y), .white);
}

pub fn deinit() void {
    rlz.closeWindow();
}
