// main.zig — Entry point. Sets up the window, ECS, and game loop.

const std = @import("std");
const rl = @import("rl");
const game = @import("game.zig");
const resources = @import("resources/common.zig");

const kn = game.kn;

const loading = @import("loading.zig");
const menu = @import("menu.zig");
const gameplay = @import("gameplay.zig");

pub fn main() !void {
    // --- Raylib window setup ---
    rl.setConfigFlags(.{ .vsync_hint = true });

    rl.initWindow(game.sim_width, game.sim_height, "daftshapes");

    rl.toggleFullscreen();

    defer rl.closeWindow();
    rl.setTargetFPS(60);

    // --- ECS setup ---
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var app = try kn.App.init(allocator);

    defer app.deinit();

    // Camera resource — centered on the player spawn point initially.
    try app.addResource(resources.Camera.default());

    // State plugin: tracks AppState and auto-cleans scoped entities on transition.
    try app.addPlugin(kn.StatePlugin(game.AppState.loading, game.Schedule.cleanup));

    // Game plugins — each file registers its own systems.
    try app.addPlugin(loading);
    try app.addPlugin(menu);
    try app.addPlugin(gameplay);

    // --- Game loop ---
    while (!rl.windowShouldClose()) {
        app.run(game.Schedule.update, true);

        // Read the camera resource for drawing.
        const cam = try app.getResource(resources.Camera);

        rl.beginDrawing();

        rl.clearBackground(rl.Color.ray_white);
        cam.inner.begin();

        app.run(game.Schedule.draw, true);

        cam.inner.end();

        // Draw FPS outside camera transform so it stays in screen-space.
        rl.drawFPS(10, 10);

        rl.endDrawing();

        app.run(game.Schedule.cleanup, true);

        // Reset the frame arena and advance the world tick.
        app.update();
    }
}
