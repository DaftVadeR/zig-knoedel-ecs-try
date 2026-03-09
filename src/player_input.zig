// this file just updates component values based on the input state. The rest of the application reads
// this and acts on it as expected.

const rl = @import("rl");
const game = @import("game.zig");
const resources = @import("./resources/common.zig");
const components = @import("./components/common.zig");

const kn = game.kn;

fn getDefaultInputState() resources.Input {
    return resources.Input{
        .input_normalised = rl.Vector2.zero(),
    };
}

/// Called by main.zig via app.addPlugin(). Registers our systems.
pub fn plugin(app: *kn.App) !void {
    try app.addResource(getDefaultInputState());

    // just in case the resource has already been added, reset to be safe.
    // try app.addSystemEx(game.Schedule.load, &resetResources, kn.OnEnter(game.AppState.gameplay));
    // try app.addSystemEx(game.Schedule.cleanup, &removeResources, kn.OnExit(game.AppState.gameplay));
    try app.addSystemEx(game.Schedule.update, &update, kn.InState(game.AppState.gameplay));

    // try app.addSystemEx(game.Schedule.draw, &draw, kn.InState(game.AppState.gameplay));
}

// fn resetResources(res: kn.ResMut(resources.Input)) !void {
//     res.inner.* = getDefaultInputState(); // reset to defaults
// }

// fn removeResources(cmd: *kn.App.Commands) !void {
//     try cmd.removeResources(resources.Input);
// }

/// Draw the gameplay screen with centered text and handle Escape.
fn update(
    inputState: kn.ResMut(resources.Input),
    // player: kn.Query(components.Player),
) !void {
    var inputDir = rl.Vector2.zero();

    if (rl.isKeyDown(.up) or rl.isKeyDown(.w)) inputDir.y -= 1;
    if (rl.isKeyDown(.down) or rl.isKeyDown(.s)) inputDir.y += 1;
    if (rl.isKeyDown(.left) or rl.isKeyDown(.a)) inputDir.x -= 1;
    if (rl.isKeyDown(.right) or rl.isKeyDown(.d)) inputDir.x += 1;

    // Normalize so diagonal movement is not faster than cardinal.
    inputState.inner.input_normalised = rl.Vector2.normalize(inputDir);
}

// Draw the gameplay screen with centered text and handle Escape.
// fn draw(state: kn.ResMut(kn.State(game.AppState))) !void {
//     _ = state;
// }
