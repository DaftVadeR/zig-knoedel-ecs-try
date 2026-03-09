// game.zig — Shared types and constants used across all plugins.

const knoedel = @import("knoedel");

/// The three states our game can be in.
/// Knoedel uses this enum with its StatePlugin to drive
/// conditional systems (OnEnter, InState, etc).
pub const AppState = enum {
    loading,
    menu,
    gameplay,
};

/// Instantiate the Knoedel ECS with a simple configuration.
/// All plugins import `kn` from here so there's one source of truth.
pub const kn = knoedel.Knoedel(.{
    .thread_count = 0, // single-threaded — simple and predictable
});

/// The schedules (phases) our game loop runs through each frame.
/// main.zig calls app.run() once for each of these per frame.
pub const Schedule = enum {
    load, // rendering (all raylib draw calls happen here)
    update, // game logic (state transitions, input, etc.)
    draw, // rendering (all raylib draw calls happen here)
    cleanup, // housekeeping (knoedel cleans up scoped entities, etc.)
};

// --- Screen / camera constants ---

pub const ZOOM: f32 = 1;

/// Actual window size in pixels.
pub const window_width: i32 = 1920;
pub const window_height: i32 = 1080;

/// Simulated resolution after the camera zoom is applied.
/// All game coordinates and draw calls use these values.
pub const sim_width: i32 = @divTrunc(window_width, @as(i32, @intFromFloat(ZOOM)));
pub const sim_height: i32 = @divTrunc(window_height, @as(i32, @intFromFloat(ZOOM)));
