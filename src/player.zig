const rl = @import("rl");
const game = @import("game.zig");
const components = @import("components/common.zig");
const player_components = @import("components/player.zig");
const player_input = @import("player_input.zig");
const player_movement = @import("player_movement.zig");
const player_weapons = @import("player_weapons.zig");
const player_shape = @import("player_shape.zig");

const kn = game.kn;

pub fn plugin(app: *kn.App) !void {
    try app.addSystemEx(game.Schedule.update, &spawn, kn.OnEnter(game.AppState.gameplay));
    try app.addSystemEx(game.Schedule.update, &despawn, kn.OnExit(game.AppState.gameplay));

    try app.addPlugin(player_input);
    try app.addPlugin(player_shape);
    try app.addPlugin(player_movement);
    try app.addPlugin(player_weapons);

    try app.addSystemEx(game.Schedule.update, &update, kn.InState(game.AppState.gameplay));
    try app.addSystemEx(game.Schedule.draw, &draw, kn.InState(game.AppState.gameplay));
}

fn spawn(cmd: kn.App.Commands) !void {
    _ = try cmd.spawn(.{
        player_components.Player{
            .class = .default,
        },
        components.Transform{
            .facing = 1, //facing right
            .size = .{ .x = 32, .y = 32 },
            .rotation = 0,
            .scale = rl.Vector2.one(),
            .position = .{
                .x = game.sim_width / 2,
                .y = game.sim_height / 2,
            },
        },
        kn.StateScoped(game.AppState){ .state = .gameplay },

        // Auto-despawn when leaving .gameplay:
    });
}

fn despawn(
    query: kn.Query(.{player_components.Player}),
    cmd: kn.App.Commands,
) !void {
    var it = query.iterQ(struct { entity: kn.Entity });

    while (it.next()) |en| {
        try cmd.despawn(en.entity);
    }
}

/// Draw the gameplay screen with centered text and handle Escape.
fn update() !void {}

/// Draw the gameplay screen with centered text and handle Escape.
fn draw() !void {
    // const text = "player loaded!";
    // const font_size: i32 = 20;
    //
    // // Center the text on the simulated screen.
    // const text_w = rl.measureText(text, font_size);
    //
    // const x = @divTrunc(game.sim_width - text_w, 1);
    // const y = @divTrunc(game.sim_height - font_size, 1);
    //
    // rl.drawText(text, x, y, font_size, rl.Color.dark_gray);
}
