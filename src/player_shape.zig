const rl = @import("rl");
const game = @import("game.zig");
const resources = @import("./resources/common.zig");
const components = @import("./components/common.zig");
const player_components = @import("./components/player.zig");
const std = @import("std");

const kn = game.kn;

pub fn plugin(app: *kn.App) !void {
    // try app.addSystemEx(game.Schedule.load, &addComponents, kn.OnEnter(game.AppState.gameplay));

    try app.addSystemEx(game.Schedule.update, &update, kn.InState(game.AppState.gameplay));

    try app.addSystemEx(game.Schedule.draw, &draw, kn.InState(game.AppState.gameplay));
}

// fn addComponents(query: kn.Query(.{components.Player}), cmd: kn.App.Commands) !void {
//
// }

fn update(
    // state: kn.ResMut(kn.State(game.AppState)),
    player: kn.Query(.{player_components.Player}),
) !void {
    _ = player;
}

fn draw(
    // state: kn.ResMut(kn.State(game.AppState)),
    // player: kn.QueryS(components.player)
    // query: kn.Query(.{components.Player, components.Transform}),

    query: kn.Query(.{ player_components.Player, components.Transform }),
    // short_query: QueryS(struct {p: *Player, t: }),
) !void {
    var t = query.iterQ(struct {
        // player: *const components.Player,
        transform: *const components.Transform,
    });

    while (t.next()) |en| {
        // body
        rl.drawRectangleV(
            // center
            en.transform.position.subtract(en.transform.size.scale(0.5)),
            en.transform.size,
            .blue,
        );

        const head_size = 20;

        const head_vec = rl.Vector2{
            .x = head_size,
            .y = head_size,
        };

        const leg_size = 10;

        const leg_vec = rl.Vector2{
            .x = leg_size,
            .y = leg_size,
        };

        const arm_size = 10;

        const arm_vec = rl.Vector2{
            .x = arm_size,
            .y = arm_size,
        };

        // head
        rl.drawRectangleV(
            // center
            rl.Vector2{
                .x = en.transform.position.x - head_size / 2,
                .y = en.transform.position.y - en.transform.size.y / 2 - head_size,
            },
            head_vec,
            .red,
        );

        // leg left
        rl.drawRectangleV(
            // center
            rl.Vector2{
                .x = en.transform.position.x - en.transform.size.x / 2,
                .y = en.transform.position.y + en.transform.size.y / 2,
            },
            leg_vec,
            .green,
        );

        // leg right
        rl.drawRectangleV(
            // center
            rl.Vector2{
                .x = en.transform.position.x + en.transform.size.x / 2 - leg_size,
                .y = en.transform.position.y + en.transform.size.y / 2,
            },
            leg_vec,
            .green,
        );

        // arm left
        rl.drawRectangleV(
            // center
            rl.Vector2{
                .x = en.transform.position.x - en.transform.size.x / 2 - arm_size,
                .y = en.transform.position.y - en.transform.size.y / 2,
            },
            arm_vec,
            .green,
        );

        // arm right
        rl.drawRectangleV(
            // center
            rl.Vector2{
                .x = en.transform.position.x + en.transform.size.x / 2,
                .y = en.transform.position.y - en.transform.size.y / 2,
            },
            arm_vec,
            .green,
        );
    }
}
