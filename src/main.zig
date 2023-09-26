const std = @import("std");
const allocator = std.heap.page_allocator;
const encode = @import("./encode.zig").encode;
const decode = @import("./decode.zig").decode;

pub fn main() !void {
    var args = std.process.argsWithAllocator(allocator) catch unreachable;
    defer args.deinit();

    var target_file: [:0]const u8 = undefined;
    var output_file: [:0]const u8 = undefined;
    var do_encode = false;
    var do_decode = false;
    var max_sliding_window_size: usize = 4096;

    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "--help")) {
            std.debug.print("Help", .{});
            return;
        }

        if (std.mem.eql(u8, arg, "--target") or std.mem.eql(u8, arg, "-t")) {
            target_file = args.next() orelse {
                std.debug.print("Invalid target file", .{});
                return;
            };
            continue;
        }

        if (std.mem.eql(u8, arg, "--output") or std.mem.eql(u8, arg, "-o")) {
            output_file = args.next() orelse {
                std.debug.print("Invalid target file", .{});
                return;
            };
            continue;
        }

        if (std.mem.eql(u8, arg, "--window-size") or std.mem.eql(u8, arg, "-w")) {
            const max_windows_size_string = args.next() orelse {
                std.debug.print("Invalid window size", .{});
                return;
            };
            max_sliding_window_size = std.fmt.parseInt(usize, max_windows_size_string, 10) catch unreachable;
        }

        if (std.mem.eql(u8, arg, "encode")) {
            do_encode = true;
            continue;
        }

        if (std.mem.eql(u8, arg, "decode")) {
            do_decode = true;
            continue;
        }
    }

    if (do_decode and do_encode) {
        std.debug.print("Both encode and decode provided, exiting...", .{});
        return;
    }

    if (do_encode) {
        try encode(target_file, output_file, max_sliding_window_size);
    }

    if (do_decode) {
        try decode(target_file, output_file);
    }
}
