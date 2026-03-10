const std = @import("std");
const rl = @import("rl");
const enemy_components = @import("../components/enemy.zig");
const components = @import("../components/common.zig");
const kn = @import("../game.zig").kn;

const EnemySpawn = struct {
    enemy_components.Enemy,
    enemy_components.MeleeDamageable,
    components.Transform,
};

pub fn spawnEnemyForLevel(
    cmd: kn.Commands,
    position: rl.Vector2,
    enemy_type: enemy_components.EnemyType,
) !void {
    _ = try cmd.spawn(.{
        enemy_components.Enemy{
            .enemy_type = enemy_type,
        },
        enemy_components.MeleeDamageable{
            .damage = 10,
        },
        components.Transform{
            .position = position,
            .facing = 0,
            .rotation = 0,
            .scale = rl.Vector2{ .x = 0, .y = 0 },
            .size = rl.Vector2{ .x = 100, .y = 100 },
        },
    });

    return;
}
