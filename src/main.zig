const std = @import("std");
const libcellfrontend = @import("libcellfrontend");

pub fn main() !void {
    libcellfrontend.init("cool window", .{800, 500});
    libcellfrontend.loop();
    libcellfrontend.deinit();
}
