const rl = @import("rl");
const std = @import("std");

pub const Player = struct {};

pub const Transform = struct {
    position: rl.Vector2,
    rotation: f32,
    scale: rl.Vector2,
    size: rl.Vector2,
    facing: f32, // for sprite direction, 1 right, -1 left, default to last direction moved otherwise
};

pub const Movable = struct {
    speed: rl.Vector2,
};

pub const AiMovable = struct {
    destination: rl.Vector2,
};

pub const Weapon = struct {
    name: []const u8,
    damage: i32,
    range: f32,
};

pub const Armable = struct {
    weapons: std.ArrayList(Weapon),
};
