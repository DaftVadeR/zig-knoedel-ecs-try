const rl = @import("rl");
const std = @import("std");

pub const Transform = struct {
    position: rl.Vector2,
    rotation: f32,
    scale: rl.Vector2,
    size: rl.Vector2,
    facing: f32, // for sprite direction, 1 right, -1 left, default to last direction moved otherwise
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
