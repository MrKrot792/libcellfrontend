const std = @import("std");

const vector = struct {
    x: u32, y: u32,
};

/// An actual image, but every pixel is `template`.
pub fn image(comptime template: type, size_in: vector) type {
    return struct {
        const T: type = template;
        const size: vector = size_in;

        data: []T,

        /// Important: always call `deinit` or you'll get a memory leak.
        pub fn init(allocator: std.mem.Allocator, clear: T) !@This() {
            const result: @This() = .{ .data = try allocator.alloc(T, size.x * size.y) };
            @memset(result.data, clear);
            return result;
        }
        
        pub fn deinit(this: @This(), allocator: std.mem.Allocator) void {
            allocator.free(this.data);
        }

        pub fn set(this: @This(), cell_position: vector, state: T) void {
            this.data[cell_position.x + cell_position.y * size.x] = state;
        }

        pub fn get(this: @This(), cell_position: vector) T {
            return this.data[cell_position.x + cell_position.y * size.x];
        }

        /// The user must create the file.
        ///
        /// TODO: add compression
        pub fn save(this: @This(), file: std.fs.File) !void {
            var buffer: [2048]u8 = undefined;
            var writer_ni = file.writer(&buffer);
            const writer = &writer_ni.interface;

            try writer.writeAll(@ptrCast(this.data));
            try writer.flush();
        }
    };
}
