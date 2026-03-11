const rl = @import("rl");
const game = @import("../game.zig");

// Manages the persisted input vector for the player input
// reused across the game, for spawning and other things
pub const Input = struct {
    input_normalised: rl.Vector2,
};

/// Global camera resource. Systems update the target to follow
/// the player; the main draw loop reads it for begin()/end().
pub const Camera = struct {
    inner: rl.Camera2D,

    /// Returns the visible screen rectangle in world coordinates.
    pub fn visibleRect(self: *const Camera) rl.Rectangle {
        const half_w = self.inner.offset.x / self.inner.zoom;
        const half_h = self.inner.offset.y / self.inner.zoom;

        return .{
            .x = self.inner.target.x - half_w,
            .y = self.inner.target.y - half_h,
            .width = half_w * 2,
            .height = half_h * 2,
        };
    }

    pub fn default() Camera {
        const half_w = @as(f32, @floatFromInt(game.sim_width)) / 2.0;
        const half_h = @as(f32, @floatFromInt(game.sim_height)) / 2.0;
        return .{
            .inner = .{
                .target = .{ .x = half_w, .y = half_h },
                .offset = .{ .x = half_w, .y = half_h },
                .rotation = 0,
                .zoom = game.ZOOM,
            },
        };
    }
};
