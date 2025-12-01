const std = @import("std");
const libcellfrontend = @import("libcellfrontend");

const log = std.log.scoped(.user);

var debug_allocator: std.heap.DebugAllocator(.{}) = .init;
const builtin = @import("builtin");

pub fn main() !void {
    // just copypasting this from project to project
    const allocator, const is_debug = gpa: {
        break :gpa switch (builtin.mode) {
            .Debug, .ReleaseSafe => .{ debug_allocator.allocator(), true },
            .ReleaseFast, .ReleaseSmall => .{ std.heap.smp_allocator, false },
        };
    };

    defer if (is_debug) {
        switch (debug_allocator.deinit()) {
            .leak => log.warn("Memory was leaked!", .{}),
            .ok => log.debug("There were no memory leaks.", .{}),
        }
    };

    try libcellfrontend.init("cool window", .{800, 500}, allocator);
    try libcellfrontend.loop(allocator);
    libcellfrontend.deinit(allocator);
}
