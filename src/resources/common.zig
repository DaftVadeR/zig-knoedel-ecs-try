const rl = @import("rl");

// Manages the persisted input vector for the player input
// reused across the game, for spawning and other things
pub const Input = struct {
    input_normalised: rl.Vector2,
};
