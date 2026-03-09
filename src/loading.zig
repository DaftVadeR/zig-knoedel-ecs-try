// loading.zig — Loading plugin.
// Runs once when we enter the "loading" state.
// Right now there's nothing to load, so we immediately
// transition to the menu.

const game = @import("game.zig");
const kn = game.kn;

/// Called by main.zig via app.addPlugin(). Registers our systems.
pub fn plugin(app: *kn.App) !void {
    // This system fires once when we enter the loading state.
    try app.addSystemEx(game.Schedule.update, &onLoading, kn.OnEnter(game.AppState.loading));
}

/// Transition straight to the menu.
/// Later you can add asset loading here and only transition when done.
fn onLoading(state: kn.ResMut(kn.State(game.AppState))) !void {
    state.inner.set(.menu);
}
