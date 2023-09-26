const std = @import("std");
const allocator = std.heap.page_allocator;
const utils = @import("./utils.zig");

pub fn decode(input_file_name: []const u8, output_file_name: []const u8) !void {
    const input_file = try std.fs.cwd().openFile(input_file_name, .{ .mode = .read_only });
    defer input_file.close();

    const output_file = std.fs.cwd().createFile(output_file_name, .{ .read = true, .truncate = true }) catch unreachable;
    defer output_file.close();

    const input_text = input_file.readToEndAlloc(allocator, 1000000000) catch unreachable;

    var output_buffer = std.ArrayList(u8).init(allocator);
    defer output_buffer.deinit();

    var inside_token = false;
    var scanning_offset = true;

    var length = std.ArrayList(u8).init(allocator);
    defer length.deinit();
    var offset = std.ArrayList(u8).init(allocator);
    defer offset.deinit();

    for (input_text) |char, char_idx| {
        if (char_idx % 10 == 0) {
            std.debug.print("\x1B[2J\x1B[H", .{});
            std.debug.print("Decoding {} / {}\n", .{ char_idx, input_text.len });
        }

        if (char == '<') {
            const substring = input_text[char_idx..utils.min(char_idx + 20, input_text.len - 1)];
            if (utils.isValidToken(substring)) {
                inside_token = true;
                scanning_offset = true;
            } else {
                output_buffer.append(char) catch unreachable;
            }
        } else if (char == ',' and inside_token) {
            scanning_offset = false;
        } else if (char == '>' and inside_token) {
            if (inside_token) {
                inside_token = false;

                const length_number = std.fmt.parseInt(i32, length.items, 10) catch unreachable;
                const offset_number = std.fmt.parseInt(i32, offset.items, 10) catch unreachable;

                var i: i32 = 0;
                while (i < length_number) {
                    const idx = @intCast(i64, output_buffer.items.len) - offset_number;
                    const referenced_char = output_buffer.items[@intCast(usize, idx)];
                    output_buffer.append(referenced_char) catch unreachable;
                    i += 1;
                }

                length.clearRetainingCapacity();
                offset.clearRetainingCapacity();
            }
        } else if (inside_token) {
            if (scanning_offset) {
                offset.append(char) catch unreachable;
            } else {
                length.append(char) catch unreachable;
            }
        } else {
            output_buffer.append(char) catch unreachable;
        }
    }

    output_file.writeAll(output_buffer.items) catch unreachable;
}
