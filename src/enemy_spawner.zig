const rl = @import("rl");
const game = @import("game.zig");
const components = @import("components/common.zig");
const enemy_components = @import("components/enemy.zig");
const player_components = @import("components/player.zig");
const enemy_content = @import("content/enemies.zig");

const kn = game.kn;

pub fn plugin(app: *kn.App) !void {
    try app.addSystemEx(game.Schedule.update, &spawn, kn.OnEnter(game.AppState.gameplay));
    // try app.addSystemEx(game.Schedule.update, &despawn, kn.OnExit(game.AppState.gameplay));

    // try app.addPlugin(enemy_components);

    try app.addSystemEx(game.Schedule.update, &update, kn.InState(game.AppState.gameplay));
    try app.addSystemEx(game.Schedule.draw, &draw, kn.InState(game.AppState.gameplay));
}

fn spawn(
    alloc: kn.Alloc,
    cmd: kn.App.Commands,
    query: kn.Query(.{
        enemy_components.Spawner,
    }),
) !void {
    if (query.count() > 0) {
        return; // already spawned
    }

    const levels = try enemy_components.getEnemyMap(alloc);

    _ = try cmd.spawn(.{
        enemy_components.Spawner{
            .level = 1,
            .time_on_level = 0,
            .time_since_wave = 0,
            .levels = levels,
        },

        kn.StateScoped(game.AppState){ .state = .gameplay },

        // Auto-despawn when leaving .gameplay:
    });
}

// fn despawn(
//     alloc: kn.Alloc,
//     query: kn.Query(.{kn.Mut(enemy_components.Spawner)}),
//     cmd: kn.App.Commands,
// ) !void {
//     var it = query.iterQ(struct { spawner: *enemy_components.Spawner, entity: kn.Entity });

//     while (it.next()) |*en| {
//         en.spawner.enemies_spawned.deinit(alloc.world);

//         try cmd.despawn(en.entity);
//     }
// }

// TODO: spawn enemies periodically
fn update(
    cmd: kn.App.Commands,
    // alloc: kn.Alloc,
    query: kn.Query(.{kn.Mut(enemy_components.Spawner)}),
    player_query: kn.Query(.{ player_components.Player, components.Transform }),
) !void {
    var it = query.iterQ(struct { spawner: *enemy_components.Spawner });

    var player_it = player_query.iterQ(struct { transform: *const components.Transform });

    while (player_it.next()) |*player_en| {
        while (it.next()) |*en| {
            const lvl = en.spawner.levels.get(en.spawner.level);

            if (lvl == null) {
                break;
            }

            en.spawner.time_on_level += rl.getFrameTime();
            en.spawner.time_since_wave += rl.getFrameTime();

            // go to next level if time exceeds 30 secs.
            if (en.spawner.time_on_level >= 30) {
                en.spawner.time_on_level = 0;
                en.spawner.level += 1;
            }

            if (en.spawner.time_since_wave >= lvl.?.wave_frequency) {
                en.spawner.time_since_wave = 0;

                // TODO: spawn enemy wave

                // spawns one enemy for now, but will spawn as many as wave scale determines.
                try enemy_content.spawnEnemyForLevel(
                    cmd,
                    player_en.transform.position,
                    lvl.?.enemy_type,
                );
            }
        }
    }
}

fn draw() !void {}
