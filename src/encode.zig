const std = @import("std");
const allocator = std.heap.page_allocator;
const utils = @import("./utils.zig");

pub fn encode(input_file_name: []const u8, output_file_name: []const u8, max_sliding_window_size: usize) !void {
    const input_file = try std.fs.cwd().openFile(input_file_name, .{ .mode = .read_only });
    defer input_file.close();

    const output_file = std.fs.cwd().createFile(output_file_name, .{ .read = true, .truncate = true }) catch unreachable;
    defer output_file.close();

    const input_text = input_file.readToEndAlloc(allocator, 1000000000) catch unreachable;

    var output_buffer = std.ArrayList(u8).init(allocator);
    defer output_buffer.deinit();

    var search_buffer = std.ArrayList(u8).initCapacity(allocator, max_sliding_window_size + 1) catch unreachable;
    defer search_buffer.deinit();

    var check_chars = std.ArrayList(u8).init(allocator);
    defer check_chars.deinit();

    var check_chars_ext = std.ArrayList(u8).init(allocator);
    defer check_chars_ext.deinit();

    var i: usize = 0;

    for (input_text) |char, char_idx| {
        if (char_idx % 10 == 0) {
            std.debug.print("\x1B[2J\x1B[H", .{});
            std.debug.print("Encoding {} / {}\n", .{ char_idx, input_text.len });
        }

        check_chars_ext.clearRetainingCapacity();
        check_chars_ext.appendSlice(check_chars.items) catch unreachable;
        check_chars_ext.append(char) catch unreachable;

        const item_index_ext = utils.findSubstring(search_buffer.items, check_chars_ext.items);

        if (item_index_ext == null or i == input_text.len - 1) {
            if (i == input_text.len - 1 and item_index_ext != null) {
                check_chars.append(char) catch unreachable;
            }

            if (check_chars.items.len > 1) {
                const item_index = utils.findSubstring(search_buffer.items, check_chars.items);
                if (item_index) |item_idx| {
                    const offset = search_buffer.items.len - item_idx;
                    const length = check_chars.items.len;
                    var token = std.fmt.allocPrint(allocator, "<{},{}>", .{ offset, length }) catch unreachable;
                    if (length > token.len) {
                        output_buffer.appendSlice(token) catch unreachable;
                    } else {
                        output_buffer.appendSlice(check_chars.items) catch unreachable;
                    }

                    search_buffer.appendSlice(check_chars.items) catch unreachable;
                }
            } else {
                // temporary solution
                if (char_idx == input_text.len - 1) {
                    check_chars.append(char) catch unreachable;
                }

                // end
                output_buffer.appendSlice(check_chars.items) catch unreachable;
                search_buffer.appendSlice(check_chars.items) catch unreachable;
            }

            check_chars.clearRetainingCapacity();
        }

        check_chars.append(char) catch unreachable;
        while (search_buffer.items.len > max_sliding_window_size) {
            _ = search_buffer.orderedRemove(0);
        }

        i += 1;
    }

    output_file.writeAll(output_buffer.items) catch unreachable;
}
