const std = @import("std");
const im = @import("image.zig");

const log = std.log.scoped(.file_manager);

/// This is a very simple func, but honestly? it works
pub fn save(
    allocator: std.mem.Allocator, 
    project_name: []const u8, 
    frame_number: u64, 
    comptime image_type: type, 
    image: image_type
) !void {
    // TODO: let the user change data dir's name
    const app_data_dir_name = try std.fs.getAppDataDir(allocator, "libcellfrontend");
    defer allocator.free(app_data_dir_name);

    var app_data_dir = try std.fs.cwd().makeOpenPath(app_data_dir_name, .{ .access_sub_paths = true });
    defer app_data_dir.close();

    var project_dir = try app_data_dir.makeOpenPath(project_name, .{ .access_sub_paths = true });
    defer project_dir.close();

    const name = try std.fmt.allocPrint(allocator, "{d}.im", .{frame_number});
    defer allocator.free(name);
    const image_file = try project_dir.createFile(name, .{ .truncate = true });
    defer image_file.close();
    try image.save(image_file);
}

test "sum test lmao" {
    const allocator = std.testing.allocator;
    var image: im.image(u32, .vec(50, 50)) = try .init(allocator, 0);
    defer image.deinit(allocator);

    try save(allocator, "sum project name lmao", 69, @TypeOf(image), image);
}
