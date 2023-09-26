const std = @import("std");

pub fn findSubstring(haystack: []const u8, needle: []const u8) ?usize {
    if (haystack.len < needle.len) {
        return null;
    }

    const max_index = haystack.len - needle.len;
    var haystack_index: usize = 0;
    while (haystack_index <= max_index) {
        var match_found = true;
        var needle_index: usize = 0;
        while (needle_index < needle.len) {
            if (haystack[haystack_index + needle_index] != needle[needle_index]) {
                match_found = false;
                break;
            }
            needle_index += 1;
        }

        if (match_found) {
            return haystack_index;
        }

        haystack_index += 1;
    }

    return null;
}

pub fn isValidToken(input: []const u8) bool {
    var index: usize = 0;

    // Check if the string starts with "<"
    if (input.len == 0 or input[0] != '<') {
        return false;
    }

    // Skip the "<" character
    index += 1;

    // Check if there are one or more digits
    while (index < input.len and @intCast(u8, input[index]) >= '0' and @intCast(u8, input[index]) <= '9') {
        index += 1;
    }

    // Check if there is a ","
    if (index >= input.len or input[index] != ',') {
        return false;
    }

    // Skip the "," character
    index += 1;

    // Check if there are one or more digits
    while (index < input.len and @intCast(u8, input[index]) >= '0' and @intCast(u8, input[index]) <= '9') {
        index += 1;
    }

    // Check if the string ends with ">"
    if (index >= input.len or input[index] != '>') {
        return false;
    }

    // If we reached this point, the format is valid
    return true;
}

test "isValidToken valid input" {
    const validInput = "<123,456>";
    try std.testing.expect(isValidToken(validInput) == true);
}

test "isValidToken invalid input" {
    const invalidInput = "<12a,456>";
    try std.testing.expect(isValidToken(invalidInput) == false);
}

pub fn min(x1: usize, x2: usize) usize {
    if (x1 < x2) return x1;
    return x2;
}
