const rl = @import("rl");
const game = @import("game.zig");
const resources = @import("resources/common.zig");
const components = @import("components/common.zig");
const player_components = @import("components/player.zig");
const enemy_components = @import("components/enemy.zig");

const kn = game.kn;

pub fn plugin(app: *kn.App) !void {
    try app.addSystemEx(game.Schedule.update, &updateMovement, kn.InState(game.AppState.gameplay));
    try app.addSystemEx(game.Schedule.draw, &draw, kn.InState(game.AppState.gameplay));
}

// fn spawn(
//     cmd: kn.App.Commands,
//     query: kn.Query(.{
//         enemy_components.Spawner,
//     }),
// ) !void {
//     if (query.count() > 0) {
//         return; // already spawned
//     }
//
//     _ = try cmd.spawn(.{
//         enemy_components.Spawner{
//             .level = 1,
//             .enemies_spawned = .empty,
//             .time_on_level = 0,
//         },
//
//         kn.StateScoped(game.AppState){ .state = .gameplay },
//
//         // Auto-despawn when leaving .gameplay:
//     });
// }

// fn despawn(
//     alloc: kn.Alloc,
//     query: kn.Query(.{kn.Mut(enemy_components.Spawner)}),
//     cmd: kn.App.Commands,
// ) !void {
//     var it = query.iterQ(struct { spawner: *enemy_components.Spawner, entity: kn.Entity });
//
//     while (it.next()) |*en| {
//         en.spawner.enemies_spawned.deinit(alloc.world);
//
//         try cmd.despawn(en.entity);
//     }
// }

fn updateMovement(
    // input_res: kn.Res(resources.Input),
    enemy_query: kn.Query(.{ enemy_components.Enemy, kn.Mut(components.Transform), enemy_components.Movable }),
    player_query: kn.Query(.{ player_components.Player, kn.Mut(components.Transform) }),
) !void {
    _ = enemy_query;
    _ = player_query;

    // std.debug.print("running update movement\n", .{});

    // const frameTime = rl.getFrameTime();

    // var t = player_query.iterQ(struct {
    //     player: *const player_components.Player,
    //     transform: *components.Transform,
    // });

    // // -------------------------------------- //

    // while (t.next()) |en| {
    //     const normalised = input_res.inner.input_normalised;

    //     // move player based on speed
    //     // std.debug.print("old position: {any}\n", .{en.transform.*.position});

    //     if (normalised.x != 0 or normalised.y != 0) {
    //         en.transform.*.position.x += en.movable.speed.x * frameTime * normalised.x;
    //         en.transform.*.position.y += en.movable.speed.y * frameTime * normalised.y;

    //         // std.debug.print("new position: {any}\n", .{en.transform.*.position});

    //         // Only update rotation when there's actual input
    //         en.transform.*.rotation = std.math.atan2(normalised.y, normalised.x);

    //         // facing, for rendering facing direction of sprite or shape
    //         if (normalised.x < 0) {
    //             en.transform.*.facing = -1;
    //         } else if (normalised.x > 0) {
    //             en.transform.*.facing = 1;
    //         }
    //     }
    // }
}
// TODO: update enemy positions and directions based on player position
fn update() !void {}

fn draw() !void {}
