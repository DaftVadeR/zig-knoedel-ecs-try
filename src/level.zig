const rl = @import("rl");
const game = @import("game.zig");
const components = @import("components/common.zig");

const kn = game.kn;

pub fn plugin(_: *kn.App) !void {
    // try app.addSystemEx(game.Schedule.update, &spawn, kn.OnEnter(game.AppState.gameplay));
    // try app.addSystemEx(game.Schedule.update, &despawn, kn.OnExit(game.AppState.gameplay));
    //
    // try app.addPlugin(plugin);
    //
    // try app.addSystemEx(game.Schedule.update, &update, kn.InState(game.AppState.gameplay));
    // try app.addSystemEx(game.Schedule.draw, &draw, kn.InState(game.AppState.gameplay));
}

fn spawn(
    // cmd: kn.App.Commands,
) !void {}

fn despawn(
    // query: kn.Query(.{player_components.Player}),
    // cmd: kn.App.Commands,
) !void {}

fn update() !void {}

fn draw() !void {}
