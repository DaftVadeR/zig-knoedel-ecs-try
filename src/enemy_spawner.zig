const std = @import("std");
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
            .level = 0,
            .time_on_level = 0,
            .time_since_wave = 0,
            .levels = levels,
        },

        kn.StateScoped(game.AppState){ .state = .gameplay },

        // Auto-despawn when leaving .gameplay:
    });
}

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

                const screenSize = rl.Vector2{
                    .x = @as(f32, @floatFromInt(rl.getScreenWidth())),
                    .y = @as(f32, @floatFromInt(rl.getScreenHeight())),
                };

                const position = player_en.transform.position;

                std.debug.print("screen size {} \n", .{screenSize});
                std.debug.print("position {}\n", .{position});

                // _ = position;
                // _ = screenSize;

                // spawns enemies just outside the screen bounds
                for (0..@as(usize, @intFromFloat(num_to_spawn))) |_| {
                    const enemy_size = enemy_content.getEnemySizeForType(lvl.?.enemy_type);
                    const spawn_pos = getOffscreenSpawnPosition(position, enemy_size);

                    std.debug.print("spawning enemy at ({d:.0}, {d:.0})\n", .{ spawn_pos.x, spawn_pos.y });

                    try enemy_content.spawnEnemyForLevel(
                        cmd,
                        spawn_pos,
                        lvl.?.enemy_type,
                    );
                }
            }
        }
    }
}

fn draw() !void {}

/// Returns a random position just outside the visible screen bounds.
/// Uses the player position to determine the visible rect:
///   the screen is centered on the player, so visible area is
///   (player.x - sim_width/2) to (player.x + sim_width/2), etc.
/// If the camera doesn't follow the player, pass the screen center
/// as the player_pos instead.
///
/// The entity_size is used to push the spawn point far enough that
/// the entire shape (including head overhang etc.) is fully off-screen.
fn getOffscreenSpawnPosition(player_pos: rl.Vector2, entity_size: rl.Vector2) rl.Vector2 {
    const sw: f32 = @floatFromInt(game.sim_width);
    const sh: f32 = @floatFromInt(game.sim_height);

    // Visible rect — camera target is (0,0) with offset (0,0),
    // so the visible area is always (0,0) to (sim_width, sim_height).
    const screen_left: f32 = 0;
    const screen_right: f32 = sw;
    const screen_top: f32 = 0;
    const screen_bottom: f32 = sh;

    // Push the entity center far enough that its full extent is off-screen.
    // Extra padding for any visual overhang (e.g. head drawn above body).
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

    _ = player_pos;

    return switch (edge) {
        0 => .{ .x = rand_x, .y = screen_top - margin_y }, // above screen
        1 => .{ .x = rand_x, .y = screen_bottom + margin_y }, // below screen
        2 => .{ .x = screen_left - margin_x, .y = rand_y }, // left of screen
        3 => .{ .x = screen_right + margin_x, .y = rand_y }, // right of screen
        else => unreachable,
    };
}
