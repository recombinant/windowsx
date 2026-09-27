const std = @import("std");

pub fn build(b: *std.Build) void {
    b.addModule("windowsx", .{
        .root_source_file = b.path("windowsx.zig"),
    }).addImport(
        "win32",
        b.dependency("win32", .{}).module("win32"),
    );
}
