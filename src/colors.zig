const clay = @import("zclay");

pub const background: clay.Color = hexToRgb("#181a1b");
pub const button: clay.Color = hexToRgb("#596064");
pub const text: clay.Color = hexToRgb("#e8e6e3");
pub const border: clay.Color = hexToRgb("#545b5e");
pub const separator: clay.Color = hexToRgb("#484d4e");
pub const bullet: clay.Color = hexToRgb("#484d4e"); // TODO: placeholder (probably)

pub fn hexToRgb(comptime hex: []const u8) clay.Color {
    if (hex.len < 6) @compileError("Your color has length less than 6...");
    const starts_with_hashtag: bool = (hex[0] == '#');
    const has_alpha: bool = (hex.len > (6 + @as(usize, @intCast(@intFromBool(starts_with_hashtag)))));

    if (hex.len != (6 + @as(usize, @intCast(@intFromBool(starts_with_hashtag)))) and hex.len != (8 + @as(usize, @intCast(@intFromBool(starts_with_hashtag))))) @compileError("Your color has incorrect length");

    const r: [2]u8 = .{hex[0 + @as(usize, @intCast(@intFromBool(starts_with_hashtag)))], hex[1 + @as(usize, @intCast(@intFromBool(starts_with_hashtag)))]};
    const g: [2]u8 = .{hex[2 + @as(usize, @intCast(@intFromBool(starts_with_hashtag)))], hex[3 + @as(usize, @intCast(@intFromBool(starts_with_hashtag)))]};
    const b: [2]u8 = .{hex[4 + @as(usize, @intCast(@intFromBool(starts_with_hashtag)))], hex[5 + @as(usize, @intCast(@intFromBool(starts_with_hashtag)))]};

    const func = struct {
        pub fn hexToU8(num: [2]u8) u8 {
            const first_digit = switch (num[0]) {
                '0' => 0, '1' => 1, '2' => 2, '3' => 3, '4' => 4, '5' => 5, '6' => 6, '7' => 7, 
                '8' => 8, '9' => 9, 'a' => 10, 'b' => 11, 'c' => 12, 'd' => 13, 'e' => 14, 'f' => 15, 
                else => @compileError("Wrong color"),
            };

            const second_digit = switch (num[1]) {
                '0' => 0, '1' => 1, '2' => 2, '3' => 3, '4' => 4, '5' => 5, '6' => 6, '7' => 7, 
                '8' => 8, '9' => 9, 'a' => 10, 'b' => 11, 'c' => 12, 'd' => 13, 'e' => 14, 'f' => 15, 
                else => @compileError("Wrong color"),
            };

            return first_digit * 16 + second_digit;
        }
    };

    return .{func.hexToU8(r), func.hexToU8(g), func.hexToU8(b), if (has_alpha) func.hexToU8(.{hex[6 + @intFromBool(starts_with_hashtag)], hex[7 + @intFromBool(starts_with_hashtag)]}) else 255};
}

