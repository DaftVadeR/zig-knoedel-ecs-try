const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // --- Dependencies ---

    const raylib_dep = b.dependency("raylib_zig", .{
        .target = target,
        .optimize = optimize,
    });

    const knoedel_dep = b.dependency("knoedel", .{});

    // Knoedel ships only src/ in its package (no build.zig),
    // so we create the module from its root source file directly.
    const knoedel_mod = b.addModule("knoedel", .{
        .root_source_file = knoedel_dep.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    // --- Executable ---

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe_mod.addImport("rl", raylib_dep.module("raylib"));
    exe_mod.addImport("knoedel", knoedel_mod);

    const exe = b.addExecutable(.{
        .name = "daftshapes",
        .root_module = exe_mod,
    });

    b.installArtifact(exe);

    // --- Run step ---

    const run_step = b.step("run", "Run the app");
    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // --- Tests ---

    const exe_tests = b.addTest(.{
        .root_module = exe.root_module,
    });

    const run_exe_tests = b.addRunArtifact(exe_tests);
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_exe_tests.step);
}
