const rl = @import("rl");
const std = @import("std");
const kn = @import("../game.zig").kn;

// for now, enemy levels are 1 minute.
pub fn getEnemyMap(alloc: kn.Alloc) !std.AutoHashMap(i32, EnemyLevel) {
    var map: std.AutoHashMap(i32, EnemyLevel) = .init(alloc.world);

    try map.put(1, .{
        .enemy_type = .Goblin,
        .wave_scale = 1, // size relative to a standard wave
        .wave_frequency = 10.0, // every 15 seconds
    });

    try map.put(2, .{
        .enemy_type = .Goblin,
        .wave_scale = 2, // size relative to a standard wave
        .wave_frequency = 10.0, // every 15 seconds
    });

    try map.put(3, .{
        .enemy_type = .GoblinShadow,
        .wave_scale = 3, // size relative to a standard wave
        .wave_frequency = 8.0, // every 15 seconds
    });

    try map.put(4, .{
        .enemy_type = .GoblinShadow,
        .wave_scale = 4, // size relative to a standard wave
        .wave_frequency = 7.0, // every 15 seconds
    });

    return map;
}

pub const Spawner = struct {
    level: i32,
    time_on_level: f32,
    time_since_wave: f32,
    levels: std.AutoHashMap(i32, EnemyLevel),

    // TODO: pass through data structure representing enemy makeup for each level
};

pub const EnemyLevel = struct {
    enemy_type: EnemyType,
    wave_scale: f32,
    wave_frequency: f32, // number of seconds between waves
};

pub const EnemyType = enum {
    Goblin,
    GoblinShadow,
};

pub const Enemy = struct {
    enemy_type: EnemyType,
};

// happens on colliding - same tick rate for now
pub const MeleeDamageable = struct {
    damage: f32,
};

pub const Movable = struct {
    // cached destination
    //
    // sets destination so position is updated based on this
    // every time it has to readjust its target.
    // this could be every frame, or every couple frames, or every second or two.
    destination: rl.Vector2 = rl.Vector2{ .x = 0, .y = 0 },
    speed: rl.Vector2,
};
