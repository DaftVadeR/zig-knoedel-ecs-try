const rl = @import("rl");
const std = @import("std");
const game = @import("game.zig");
const resources = @import("./resources/common.zig");
const components = @import("./components/common.zig");

const kn = game.kn;

/// Called by main.zig via app.addPlugin(). Registers our systems.
pub fn plugin(app: *kn.App) !void {
    try app.addSystemEx(game.Schedule.load, &addComponents, kn.OnEnter(game.AppState.gameplay));

    try app.addSystemEx(game.Schedule.update, &updateMovement, kn.InState(game.AppState.gameplay));
    try app.addSystemEx(game.Schedule.draw, &draw, kn.InState(game.AppState.gameplay));
}

fn addComponents(query: kn.Query(.{components.Player}), cmd: kn.App.Commands) !void {
    var it = query.iterQ(struct { entity: kn.Entity });

    // TODO: set to actual speed value based on player class
    while (it.next()) |en| {
        try cmd.insert(en.entity, .{
            components.Movable{
                .speed = rl.Vector2.zero(),
            },
        });
    }
}

/// Draw the gameplay screen with centered text and handle Escape.
fn updateMovement(
    input_res: kn.Res(resources.Input),
    // player: kn.Query(components.Player),
    player_query: kn.Query(.{ components.Player, kn.Mut(components.Transform) }),
) !void {
    _ = player_query;
    _ = input_res;

    // const frameTime = rl.getFrameTime();
    //
    // const input = input_res.inner;
    //
    // var t = player_query.iterQ(struct {
    //     player: *const components.Player,
    //     transform: *components.Transform,
    // });

    // -------------------------------------- //

    // while (it.next()) |en| {
    //     if (input_res.inner.input_normalised.x != 0 or input_res.inner.input_normalised.y != 0) {
    //         self.player.position.x += pd.attributes.speed * frameTime * normalized.x;
    //         self.player.position.y += pd.attributes.speed * frameTime * normalized.y;
    //     }
    //     en.transform.position.x += frameTime * input.input_normalised.x;
    //     en.transform.position.y += frameTime * input.input_normalised.y;
    //
    //     en.player.rotation = std.math.atan2(input.input_normalised.y, input.input_normalised.x);
    // }
    //

    // ----- OLLLDDD DRAW CODE -----

    // // Always tick the active anim regardless of input.
    // pd.anims[pd.active_anim].update(frameTime);

    // // Switch animation based on whether the player is moving.
    // if (inputDir.x == 0 and inputDir.y == 0) {
    //     pd.active_anim = 0; // idle
    // } else {
    //     pd.active_anim = 1; // run
    // }

    // // Update facing direction based on horizontal input.
    // if (inputDir.x < 0) {
    //     self.player.transform.x = -1;
    // } else if (inputDir.x > 0) {
    //     self.player.transform.x = 1;
    // }

    // Center the text on the simulated screen.
    // const text_w = rl.measureText(text, font_size);

    // const x = @divTrunc(game.sim_width - text_w, 1);
    // const y = @divTrunc(game.sim_height - font_size, 1);

    // rl.drawText(text, x, y, font_size, rl.Color.dark_gray);
}

/// Draw the gameplay screen with centered text and handle Escape.
fn draw(state: kn.ResMut(kn.State(game.AppState))) !void {
    _ = state;
}
