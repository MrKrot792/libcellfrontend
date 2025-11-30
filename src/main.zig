const std = @import("std");
const libcellfrontend = @import("libcellfrontend");

pub fn main() !void {
    var debug_allocator: std.heap.DebugAllocator(.{}) = .init;
    defer {
        switch (debug_allocator.deinit()) {
            .leak => std.log.debug("You leaked memory dum dum", .{}),
            .ok => std.log.debug("No memory leaks. For now...", .{}),
        }
    }

    const allocator = debug_allocator.allocator();

    try libcellfrontend.init("cool window", .{800, 500}, allocator);
    try libcellfrontend.loop(allocator);
    libcellfrontend.deinit(allocator);
}
