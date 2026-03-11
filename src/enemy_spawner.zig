const std = @import("std");
const rl = @import("rl");
const game = @import("game.zig");
const components = @import("components/common.zig");
const enemy_components = @import("components/enemy.zig");
const player_components = @import("components/player.zig");
const enemy_content = @import("content/enemies.zig");
const resources = @import("resources/common.zig");

const kn = game.kn;

pub fn plugin(app: *kn.App) !void {
    try app.addSystemEx(game.Schedule.update, &spawn, kn.OnEnter(game.AppState.gameplay));

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
            .level = 0,
            .time_on_level = 0,
            .time_since_wave = 0,
            .levels = levels,
        },

        kn.StateScoped(game.AppState){ .state = .gameplay },
    });
}

fn update(
    cmd: kn.App.Commands,
    cam: kn.Res(resources.Camera),
    query: kn.Query(.{kn.Mut(enemy_components.Spawner)}),
    player_query: kn.Query(.{ player_components.Player, components.Transform }),
) !void {
    var it = query.iterQ(struct { spawner: *enemy_components.Spawner });

    // We need the player query to confirm the player exists, but
    // spawn positions are now derived from the camera.
    if (player_query.count() == 0) return;

    while (it.next()) |*en| {
        var lvl = en.spawner.levels.get(en.spawner.level);
        var spawnEnemies = false;

        // if just started, use lvl 1.
        if (en.spawner.level == 0) {
            lvl = en.spawner.levels.get(1);
            spawnEnemies = true;
        } else if (lvl == null) {
            break;
        }

        en.spawner.time_on_level += rl.getFrameTime();
        en.spawner.time_since_wave += rl.getFrameTime();

        // go to next level if time exceeds 30 secs or level is 0 (first time)
        if (en.spawner.time_on_level >= 30 or spawnEnemies) {
            en.spawner.level += 1;
            en.spawner.time_on_level = 0;
        }

        if (en.spawner.time_since_wave >= lvl.?.wave_frequency or spawnEnemies) {
            en.spawner.time_since_wave = 0;

            const num_to_spawn = lvl.?.wave_scale * 5;

            // spawns enemies just outside the visible screen bounds
            for (0..@as(usize, @intFromFloat(num_to_spawn))) |_| {
                const enemy_size = enemy_content.getEnemySizeForType(lvl.?.enemy_type);
                const spawn_pos = getOffscreenSpawnPosition(cam.inner, enemy_size);

                try enemy_content.spawnEnemyForLevel(
                    cmd,
                    spawn_pos,
                    lvl.?.enemy_type,
                );
            }
        }
    }
}

fn draw() !void {}

/// Returns a random position just outside the visible screen bounds,
/// derived from the Camera resource. The entity_size is used to push
/// the spawn point far enough that the entire entity is fully off-screen.
fn getOffscreenSpawnPosition(cam: *const resources.Camera, entity_size: rl.Vector2) rl.Vector2 {
    const visible = cam.visibleRect();

    const screen_left = visible.x;
    const screen_top = visible.y;
    const screen_right = visible.x + visible.width;
    const screen_bottom = visible.y + visible.height;

    // Push the entity center far enough that its full extent is off-screen.
    const margin_x: f32 = entity_size.x / 2.0 + 30.0;
    const margin_y: f32 = entity_size.y / 2.0 + 30.0;

    const edge = rl.getRandomValue(0, 3);

    // Random positions along each axis (spanning the full screen + margins)
    const rand_x = @as(f32, @floatFromInt(rl.getRandomValue(
        @as(i32, @intFromFloat(screen_left - margin_x)),
        @as(i32, @intFromFloat(screen_right + margin_x)),
    )));
    const rand_y = @as(f32, @floatFromInt(rl.getRandomValue(
        @as(i32, @intFromFloat(screen_top - margin_y)),
        @as(i32, @intFromFloat(screen_bottom + margin_y)),
    )));

    return switch (edge) {
        0 => .{ .x = rand_x, .y = screen_top - margin_y }, // above screen
        1 => .{ .x = rand_x, .y = screen_bottom + margin_y }, // below screen
        2 => .{ .x = screen_left - margin_x, .y = rand_y }, // left of screen
        3 => .{ .x = screen_right + margin_x, .y = rand_y }, // right of screen
        else => unreachable,
    };
}
