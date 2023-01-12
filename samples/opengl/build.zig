const std = @import("std");
const zglfw = @import("../../libs/zglfw/build.zig");
// const zgl = @import("../../libs/zgl/build.zig");

const Options = @import("../../build.zig").Options;

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}


pub fn build(b: *std.build.Builder, options: Options) *std.build.LibExeObjStep {
    const exe = b.addExecutable("opengl_window", thisDir() ++ "/src/opengl_window.zig");

    exe.setBuildMode(options.build_mode);
    exe.setTarget(options.target);
    // exe.addPackage(zgl.pkg);
    exe.addPackage(zglfw.pkg);
    // zgl.link(exe);
    zglfw.link(exe);
    

    return exe;

}