// main.zig — Entry point. Sets up the window, ECS, and game loop.

const std = @import("std");
const rl = @import("rl");
const game = @import("game.zig");

const kn = game.kn;

const loading = @import("loading.zig");
const menu = @import("menu.zig");
const gameplay = @import("gameplay.zig");

pub fn main() !void {
    // --- Raylib window setup ---
    rl.setConfigFlags(.{ .vsync_hint = true });

    rl.initWindow(game.sim_width, game.sim_height, "daftshapes");

    // rl.toggleFullscreen();

    defer rl.closeWindow();
    rl.setTargetFPS(60);

    // The camera applies a 2x zoom so we can work in a smaller
    // coordinate space (sim_width x sim_height) while the actual
    // window is larger. All draw calls use simulated coordinates.
    const camera = rl.Camera2D{
        .target = .{ .x = 0, .y = 0 },
        .offset = .{ .x = 0, .y = 0 },
        .rotation = 0,
        .zoom = game.ZOOM,
    };

    // --- ECS setup ---
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var app = try kn.App.init(allocator);

    defer app.deinit();

    // State plugin: tracks AppState and auto-cleans scoped entities on transition.
    try app.addPlugin(kn.StatePlugin(game.AppState.loading, game.Schedule.cleanup));

    // Game plugins — each file registers its own systems.
    try app.addPlugin(loading);
    try app.addPlugin(menu);
    try app.addPlugin(gameplay);

    // --- Game loop ---
    while (!rl.windowShouldClose()) {
        app.run(game.Schedule.update, true);

        rl.beginDrawing();

        rl.clearBackground(rl.Color.ray_white);
        camera.begin();

        app.run(game.Schedule.draw, true);

        rl.drawFPS(10, 10);

        camera.end();

        rl.endDrawing();

        app.run(game.Schedule.cleanup, true);

        // Reset the frame arena and advance the world tick.
        app.update();
    }
}
