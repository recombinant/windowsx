const std = @import("std");

pub fn build(b: *std.Build) void {
    b.addModule("windowsx", .{
        .root_source_file = b.path("windowsx.zig"),
    }).addImport(
        "zigwin32",
        b.dependency("zigwin32", .{}).module("zigwin32"),
    );
}
