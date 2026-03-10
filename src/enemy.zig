// sets up all enemy related stuff

const rl = @import("rl");
const game = @import("game.zig");
// const components = @import("components/common.zig");
// const enemy = @import("components/enemy.zig");

const enemy_spawner = @import("enemy_spawner.zig");
const enemy_movement = @import("enemy_movement.zig");
const enemy_shape = @import("enemy_shape.zig");

const kn = game.kn;

pub fn plugin(app: *kn.App) !void {
    try app.addPlugin(enemy_spawner);
    try app.addPlugin(enemy_movement);
    try app.addPlugin(enemy_shape);

    try app.addSystemEx(game.Schedule.update, &update, kn.InState(game.AppState.gameplay));
    try app.addSystemEx(game.Schedule.draw, &draw, kn.InState(game.AppState.gameplay));
}

fn update() !void {}

fn draw() !void {}
