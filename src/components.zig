const rl = @import("rl");

// ── Shared components ──────────────────────────────────────────────────
// These are used by multiple entity types (player, enemy, etc.)

/// World-space position.
pub const Position = struct {
    x: f32,
    y: f32,
};

/// Per-frame velocity (pixels per second).
pub const Velocity = struct {
    x: f32,
    y: f32,
};

/// Movement speed scalar (pixels per second).
pub const Speed = struct {
    value: f32,
};

// ── Shape components ───────────────────────────────────────────────────
// An entity picks ONE shape variant.

pub const Circle = struct {
    radius: f32,
    color: rl.Color,
};

pub const Rect = struct {
    width: f32,
    height: f32,
    color: rl.Color,
};
