const std = @import("std");
const rlz = @import("raylib");
const rc = @import("raylib_clay_renderer.zig");
const clay = @import("zclay");

var image: rlz.Image = undefined;
var texture: rlz.Texture = undefined;
var renderTexture: rlz.RenderTexture2D = undefined;

var camera: rlz.Camera2D = .{ 
    .offset = .{ .x = 0, .y = 0 }, // not .zero because it's not comptime
    .rotation = 0, 
    .target = .{ .x = 0, .y = 0 }, 
    .zoom = 1 
};


pub fn init(name: [:0]const u8, size: [2]i32) !void {
    rlz.setConfigFlags(.{ .window_resizable = true });
    rlz.setTraceLogLevel(.warning);
    rlz.initWindow(size[0], size[1], name);

    //rc.raylib_fonts[0] = try rlz.loadFontFromMemory(".ttf", @embedFile("../assets/fonts/Menlo-Regular.ttf"), 20, null);
    rc.raylib_fonts[0] = try rlz.loadFontEx("assets/fonts/HackNerdFontMono-Regular.ttf", 32, null); // this is probably UI? i'm not sure tho
    rlz.setTextureFilter(rc.raylib_fonts[0].?.texture, .bilinear);

    image = .genCellular(500, 500, 50);
    texture = try image.toTexture();
    renderTexture = try .init(1, 1);
}

pub fn draw(where: clay.BoundingBox, delta: f32) !void {
    rlz.updateTexture(texture, image.data);

    if (rlz.isWindowResized()) {
        renderTexture = try .init(@intFromFloat(where.width), @intFromFloat(where.height));
        camera.offset = .init(where.width / 2.0, where.height / 2.0);
    }

    const speed:      f32 = 200;
    const zoom_speed: f32 = 1;

    if (rlz.isKeyDown(.w)) camera.target.y += speed / camera.zoom * delta;
    if (rlz.isKeyDown(.a)) camera.target.x -= speed / camera.zoom * delta;
    if (rlz.isKeyDown(.s)) camera.target.y -= speed / camera.zoom * delta;
    if (rlz.isKeyDown(.d)) camera.target.x += speed / camera.zoom * delta;

    if (rlz.isKeyDown(.j)) camera.zoom += zoom_speed * camera.zoom * delta;
    if (rlz.isKeyDown(.k)) camera.zoom -= zoom_speed * camera.zoom * delta;

    renderTexture.begin();
    camera.begin();
    rlz.clearBackground(.black);
    texture.draw(0, 0, .white);
    camera.end();
    renderTexture.end();

    renderTexture.texture.draw(@intFromFloat(where.x), @intFromFloat(where.y), .white);
}

pub fn deinit() void {
    rlz.closeWindow();
}
