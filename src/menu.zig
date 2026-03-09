// menu.zig — Menu plugin.
// Draws a centered PLAY button. Clicking it transitions to gameplay.

const rl = @import("rl");
const game = @import("game.zig");
const kn = game.kn;

/// Called by main.zig via app.addPlugin(). Registers our systems.
pub fn plugin(app: *kn.App) !void {
    // Only runs while we're in the menu state.
    try app.addSystemEx(game.Schedule.draw, &drawMenu, kn.InState(game.AppState.menu));
}

/// Draw the menu screen with a centered PLAY button.
fn drawMenu(state: kn.ResMut(kn.State(game.AppState))) !void {
    const sw = game.sim_width;
    const sh = game.sim_height;

    // Button dimensions.
    const bw: i32 = 100;
    const bh: i32 = 30;

    // Center the button on screen.
    const bx = @divTrunc(sw - bw, 2);
    const by = @divTrunc(sh - bh, 2);

    // Mouse position is in window pixels, so divide by zoom
    // to get the position in our simulated coordinate space.
    const mouse = rl.getMousePosition();
    const mx: i32 = @intFromFloat(mouse.x / game.ZOOM);
    const my: i32 = @intFromFloat(mouse.y / game.ZOOM);

    const hover = (mx >= bx) and (mx <= bx + bw) and (my >= by) and (my <= by + bh);
    const color = if (hover) rl.Color.dark_gray else rl.Color.gray;

    // Draw the button.
    rl.drawRectangle(bx, by, bw, bh, color);

    // Center the "PLAY" label inside the button.
    const font_size: i32 = 12;
    const text_w = rl.measureText("PLAY", font_size);
    const tx = bx + @divTrunc(bw - text_w, 2);
    const ty = by + @divTrunc(bh - font_size, 2);

    rl.drawText("PLAY", tx, ty, font_size, rl.Color.ray_white);

    // Handle click.
    if (hover and rl.isMouseButtonPressed(.left)) {
        state.inner.set(.gameplay);
    }
}
