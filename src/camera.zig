// camera.zig — Camera plugin.
// Follows the player by updating the Camera resource target each frame.

const game = @import("game.zig");
const resources = @import("resources/common.zig");
const components = @import("components/common.zig");
const player_components = @import("components/player.zig");

const kn = game.kn;

pub fn plugin(app: *kn.App) !void {
    try app.addSystemEx(game.Schedule.update, &followPlayer, kn.InState(game.AppState.gameplay));
}

/// Set the camera target to the player's position each frame.
fn followPlayer(
    cam: kn.ResMut(resources.Camera),
    query: kn.Query(.{ player_components.Player, components.Transform }),
) !void {
    var it = query.iterQ(struct { transform: *const components.Transform });

    if (it.next()) |en| {
        cam.inner.inner.target = en.transform.position;
    }
}
