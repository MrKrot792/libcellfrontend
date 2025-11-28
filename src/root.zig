const std = @import("std");
const rlz = @import("raylib");
const rlzg = @import("raygui");

var size: [2]i32 = .{0, 0};

pub fn init(name: [:0]const u8, size_: [2]i32) void {
    size = size_;
    rlz.initWindow(size[0], size[1], name);
}

pub fn loop() void {
    while (!rlz.windowShouldClose()) {
        rlz.clearBackground(.ray_white);
        rlz.beginDrawing();
        rlz.drawText("Hello, world!", 0, 0, 30, .black);
        rlz.endDrawing();
    }
}

pub fn deinit() void {
    rlz.closeWindow();
}
