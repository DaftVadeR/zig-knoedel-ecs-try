const rl = @import("rl");
const std = @import("std");
const game = @import("game.zig");
const resources = @import("./resources/common.zig");
const components = @import("./components/common.zig");
const player_components = @import("./components/player.zig");

const kn = game.kn;

pub fn plugin(app: *kn.App) !void {
    // has to be every frame to find player after spawn command.
    try app.addSystemEx(game.Schedule.update, &addComponents, kn.InState(game.AppState.gameplay));

    try app.addSystemEx(game.Schedule.update, &updateMovement, kn.InState(game.AppState.gameplay));

    try app.addSystemEx(game.Schedule.draw, &draw, kn.InState(game.AppState.gameplay));
}

fn addComponents(
    query: kn.QueryFiltered(.{player_components.Player}, .{kn.WithOut(components.Movable)}),
    cmd: kn.App.Commands,
) !void {
    var it = query.iterQ(struct { entity: kn.Entity });

    // TODO: set to actual speed value based on player class
    while (it.next()) |en| {
        try cmd.insert(en.entity, .{
            components.Movable{
                .speed = rl.Vector2{ .x = 200, .y = 200 },
            },
        });
    }
}

fn updateMovement(
    input_res: kn.Res(resources.Input),
    // player: kn.Query(components.Player),
    player_query: kn.Query(.{ player_components.Player, kn.Mut(components.Transform), components.Movable }),
) !void {
    // std.debug.print("running update movement\n", .{});

    const frameTime = rl.getFrameTime();

    var t = player_query.iterQ(struct {
        player: *const player_components.Player,
        transform: *components.Transform,
        movable: *const components.Movable,
    });

    // -------------------------------------- //

    while (t.next()) |en| {
        const normalised = input_res.inner.input_normalised;

        // move player based on speed
        // std.debug.print("old position: {any}\n", .{en.transform.*.position});

        if (normalised.x != 0 or normalised.y != 0) {
            en.transform.*.position.x += en.movable.speed.x * frameTime * normalised.x;
            en.transform.*.position.y += en.movable.speed.y * frameTime * normalised.y;

            // std.debug.print("new position: {any}\n", .{en.transform.*.position});

            // Only update rotation when there's actual input
            en.transform.*.rotation = std.math.atan2(normalised.y, normalised.x);

            // facing, for rendering facing direction of sprite or shape
            if (normalised.x < 0) {
                en.transform.*.facing = -1;
            } else if (normalised.x > 0) {
                en.transform.*.facing = 1;
            }
        }
    }
}

fn draw(state: kn.ResMut(kn.State(game.AppState))) !void {
    _ = state;
}
