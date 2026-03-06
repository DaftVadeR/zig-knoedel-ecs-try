const std = @import("std");
// const rlz = @import("raylib_zig");
// const zflecs = @import("zflecs");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const mod = b.addModule("daftshapes", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
    });

    const raylib_dep = b.dependency("raylib_zig", .{
        .target = target,
        .optimize = optimize,
    });

    const flecs_dep = b.dependency("zflecs", .{
        .target = target,
        .optimize = optimize,
    });

    const raylib = raylib_dep.module("raylib");
    // const raylib_artifact = raylib_dep.artifact("raylib");

    // const zflecs_artifact = raylib_dep.artifact("zflecs");
    const zflecsmod = flecs_dep.module("root");

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,

        .imports = &.{
            .{ .name = "daftshapes", .module = mod },
        },
    });

    exe_mod.addImport("rl", raylib);
    exe_mod.addImport("zflecs", zflecsmod);

    const run_step = b.step("run", "Run the app");

    const exe = b.addExecutable(.{ .name = "daftshapes", .root_module = exe_mod });

    exe.linkLibrary(flecs_dep.artifact("flecs"));

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const mod_tests = b.addTest(.{
        .root_module = mod,
    });

    const run_mod_tests = b.addRunArtifact(mod_tests);

    const exe_tests = b.addTest(.{
        .root_module = exe.root_module,
    });

    const run_exe_tests = b.addRunArtifact(exe_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);
    test_step.dependOn(&run_exe_tests.step);
}
