const std = @import("std");
const rlz = @import("raylib");
const rc = @import("raylib_clay_renderer.zig");
const clay = @import("zclay");

var image: rlz.Image = undefined;
var texture: rlz.Texture = undefined;
var renderTexture: rlz.RenderTexture2D = undefined;

const speed:      f32 = 200;
const zoom_speed: f32 = 1;

const wheel_zoom_speed: f32 = 100;


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

    if (rlz.isKeyDown(.w)) camera.target.y += speed / camera.zoom * delta;
    if (rlz.isKeyDown(.a)) camera.target.x -= speed / camera.zoom * delta;
    if (rlz.isKeyDown(.s)) camera.target.y -= speed / camera.zoom * delta;
    if (rlz.isKeyDown(.d)) camera.target.x += speed / camera.zoom * delta;

    if (rlz.isKeyDown(.j)) camera.zoom += zoom_speed * camera.zoom * delta;
    if (rlz.isKeyDown(.k)) camera.zoom -= zoom_speed * camera.zoom * delta;

    if (inTheBox(rlz.getMousePosition(), where) and rlz.isMouseButtonDown(.left)) {
        const mouse_delta = rlz.getMouseDelta();
        camera.target = camera.target.add(rlz.Vector2{
            .x = -mouse_delta.x / camera.zoom, 
            .y = mouse_delta.y / camera.zoom,
        });
    }

    const mouse_wheel_move = rlz.getMouseWheelMove();
    camera.zoom += mouse_wheel_move * delta * wheel_zoom_speed;
    camera.zoom = clamp(f32, camera.zoom, 0.1, 70);

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

fn inTheBox(pos: rlz.Vector2, box: clay.BoundingBox) bool {
    return (pos.x > box.x)               and 
           (pos.x < (box.width + box.x)) and
           (pos.y > box.y)               and 
           (pos.y < (box.height + box.y));
}

fn clamp(comptime T: anytype, num: T, min: T, max: T) T {
         if (num < min) { return min; }
    else if (num > max) { return max; }
    else return num;
}
