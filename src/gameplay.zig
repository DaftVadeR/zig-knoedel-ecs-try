// gameplay.zig — Gameplay plugin.
// Shows "game mode!" text centered on screen.
// Press Escape to return to the menu.

const rl = @import("rl");
const game = @import("game.zig");
const player = @import("player.zig");
// const enemy = @import("enemy.zig");
const resources = @import("./resources/common.zig");
const kn = game.kn;

/// Called by main.zig via app.addPlugin(). Registers our systems.
pub fn plugin(app: *kn.App) !void {
    // Only runs while we're in the gameplay state.

    try app.addPlugin(player);
    // try app.addPlugin(enemy);

    // move this above line above if there is something more important to do before the player is added.
    try app.addSystemEx(game.Schedule.update, &updateGameplay, kn.InState(game.AppState.gameplay));
    try app.addSystemEx(game.Schedule.draw, &drawGameplay, kn.InState(game.AppState.gameplay));

    // only add plugins here or after the player plugin has been initialised.
    // Otherwise there'll be a race condition due to it not being added as a resource yet.
}

fn updateGameplay(state: kn.ResMut(kn.State(game.AppState))) !void {
    // Escape returns to the menu.
    if (rl.isKeyPressed(.escape)) {
        state.inner.set(.menu);
    }
}

/// Draw the gameplay screen with centered text and handle Escape.
fn drawGameplay(state: kn.ResMut(kn.State(game.AppState))) !void {
    _ = state;

    // const text = "game mode!";
    // const font_size: i32 = 20;

    // // Center the text on the simulated screen.
    // const text_w = rl.measureText(text, font_size);

    // const x = @divTrunc(game.sim_width - text_w, 2);
    // const y = @divTrunc(game.sim_height - font_size, 2);

    // rl.drawText(text, x, y, font_size, rl.Color.dark_gray);
}
