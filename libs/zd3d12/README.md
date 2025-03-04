# zd3d12 - helper library for working with DirectX 12

## Features

* Basic DirectX 12 context management (descriptor heaps, memory heaps, swapchain, CPU and GPU sync, etc.)
* Basic DirectX 12 resource management (handle-based resources and pipelines)
* Basic resource barriers management with simple state-tracking
* Transient and persistent descriptor allocation
* Fast image loading using WIC (Windows Imaging Component)
* Helpers for uploading data to the GPU
* Fast mipmap generator running on the GPU
* Interop with Direct2D and DirectWrite for high-quality vector graphics and text rendering (optional)

Example programs: https://github.com/michal-z/zig-gamedev/tree/main/samples/intro

## Getting started

Copy `zd3d12`, `zwin32` and `ztracy` folders to a `libs` subdirectory of the root of your project.

Then in your `build.zig` add:

```zig
const std = @import("std");
const zwin32 = @import("libs/zwin32/build.zig");
const ztracy = @import("libs/ztracy/build.zig");
const zd3d12 = @import("libs/zd3d12/build.zig");

pub fn build(b: *std.build.Builder) void {
    ...
    const enable_dx_debug = b.option(
        bool,
        "enable-dx-debug",
        "Enable debug layer for D3D12, D2D1, and DXGI",
    ) orelse false;
    const enable_dx_gpu_debug = b.option(
        bool,
        "enable-dx-gpu-debug",
        "Enable GPU-based validation for D3D12",
    ) orelse false;
    const ztracy_enable = b.option(bool, "ztracy_enable", "Enable Tracy profiler") orelse false;

    const exe_options = b.addOptions();
    exe.addOptions("build_options", exe_options);

    exe_options.addOption(bool, "enable_dx_debug", enable_dx_debug);
    exe_options.addOption(bool, "enable_dx_gpu_debug", enable_dx_gpu_debug);
    exe_options.addOption(bool, "enable_d2d", false);
    exe_options.addOption(bool, "ztracy_enable", ztracy_enable);

    const options_pkg = exe_options.getPackage("build_options");
    const ztracy_pkg = ztracy.getPkg(&.{options_pkg});
    const zd3d12_pkg = zd3d12.getPkg(&.{ ztracy_pkg, zwin32.pkg, options_pkg });

    exe.addPackage(ztracy_pkg);
    exe.addPackage(zd3d12_pkg);
    exe.addPackage(zwin32.pkg);

    ztracy.link(tracy, ztracy_enable, .{});
    zd3d12.link(exe);
}
```

Now in your code you may import and use zd3d12:

```zig
const zd3d12 = @import("zd3d12");

// We need to export below symbols for DirectX 12 Agility SDK.
pub export const D3D12SDKVersion: u32 = 608;
pub export const D3D12SDKPath: [*:0]const u8 = ".\\d3d12\\";

pub fn main() !void {
    ...
    var gctx = zd3d12.GraphicsContext.init(allocator, window);
    defer gctx.deinit(allocator);

    while (...) {
        gctx.beginFrame();

        const back_buffer = gctx.getBackBuffer();
        gctx.addTransitionBarrier(back_buffer.resource_handle, .{ .RENDER_TARGET = true });
        gctx.flushResourceBarriers();

        gctx.cmdlist.OMSetRenderTargets(
            1,
            &[_]d3d12.CPU_DESCRIPTOR_HANDLE{back_buffer.descriptor_handle},
            w32.TRUE,
            null,
        );
        gctx.cmdlist.ClearRenderTargetView(back_buffer.descriptor_handle, &.{ 0.2, 0.4, 0.8, 1.0 }, 0, null);

        gctx.addTransitionBarrier(back_buffer.resource_handle, d3d12.RESOURCE_STATES.PRESENT);
        gctx.flushResourceBarriers();

        gctx.endFrame();
    }
}
```
