const rl = @import("rl");
const game = @import("game.zig");
const resources = @import("./resources/common.zig");
const components = @import("./components/common.zig");
const std = @import("std");

const kn = game.kn;

/// Called by main.zig via app.addPlugin(). Registers our systems.
pub fn plugin(app: *kn.App) !void {
    try app.addSystemEx(game.Schedule.load, &addComponents, kn.OnEnter(game.AppState.gameplay));

    try app.addSystemEx(game.Schedule.update, &update, kn.InState(game.AppState.gameplay));

    try app.addSystemEx(game.Schedule.draw, &draw, kn.InState(game.AppState.gameplay));
}

fn addComponents(query: kn.Query(.{components.Player}), cmd: kn.App.Commands) !void {
    var it = query.iterQ(struct { entity: kn.Entity });

    // TODO: add correct weapon init for player type.
    while (it.next()) |en| {
        try cmd.insert(en.entity, .{
            components.Armable{
                .weapons = .empty,
            },
        });
    }
}

/// Draw the gameplay screen with centered text and handle Escape.
fn update(
    // state: kn.ResMut(kn.State(game.AppState)),
    player: kn.Query(.{components.Player}),
) !void {
    _ = player;
}

/// Draw the gameplay screen with centered text and handle Escape.
fn draw(state: kn.ResMut(kn.State(game.AppState))) !void {
    _ = state;
}
