const std = @import("std");
const zglfw = @import("zglfw");


const window_title = "zig-gamedev: opengl window";

extern fn gladLoadGL() u32;


pub fn main() void {

    std.log.debug("Hello!", .{});

    zglfw.init() catch {
        std.log.err("Failed to initialize GLFW library.", .{});
        return;
    };
    defer zglfw.terminate();

    zglfw.glfwWindowHint(zglfw.GLFW_CONTEXT_VERSION_MAJOR, 4);
    zglfw.glfwWindowHint(zglfw.GLFW_CONTEXT_VERSION_MINOR, 6);
    zglfw.glfwWindowHint(zglfw.GLFW_OPENGL_PROFILE, zglfw.GLFW_OPENGL_CORE_PROFILE);

    const window = zglfw.Window.create(1600, 1000, window_title, null) catch {
        std.log.err("Failed to create demo window.", .{});
        return;
    };
    defer window.destroy();

    zglfw.glfwMakeContextCurrent(window);

    // Load OpenGL functions, gladLoadGL returns the loaded version, 0 on error.
    
    const version = gladLoadGL();
    if (version == 0)
    {
        std.debug.print("Failed to initialize OpenGL context\n",.{});
    }

    while (!window.shouldClose() and window.getKey(.escape) != .press) {
        zglfw.pollEvents();
    }

}