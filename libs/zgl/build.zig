const std = @import("std");

pub fn build(_: *std.build.Builder) void {}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}

pub const pkg = std.build.Pkg{
    .name = "zgl",
    .source = .{ .path = thisDir() ++ "/src/zgl.zig" },
};

pub fn link(exe: *std.build.LibExeObjStep) void {
    exe.addIncludePath(thisDir() ++ "/windows/libs/include");
    exe.linkSystemLibraryName("c");

    const src_dir = thisDir() ++ "/windows/libs/src/";

    exe.addCSourceFiles(&.{src_dir ++ "gl.c",},&.{""});
}