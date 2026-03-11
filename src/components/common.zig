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

/// Holds a texture handle and the current source rectangle (frame) to draw.
/// Reusable for any entity with a spritesheet or static sprite.
pub const Sprite = struct {
    texture: rl.Texture2D,
    /// The region of the texture to draw (updated by SpriteController for animations).
    src: rl.Rectangle,
};

/// Controls spritesheet animation: tracks current frame, row (animation),
/// and advances the frame timer. Works alongside a Sprite component.
pub const SpriteController = struct {
    frame_width: f32,
    frame_height: f32,
    frame_count: u32,
    current_frame: u32 = 0,
    frame_timer: f32 = 0,
    frame_duration: f32, // seconds per frame
    current_row: u32 = 0, // which row of the spritesheet (e.g. 0=idle, 1=run)

    /// Advance the animation timer by dt. Returns true if the frame changed.
    pub fn tick(self: *SpriteController, dt: f32) bool {
        self.frame_timer += dt;
        if (self.frame_timer >= self.frame_duration) {
            self.frame_timer -= self.frame_duration;
            self.current_frame = (self.current_frame + 1) % self.frame_count;
            return true;
        }
        return false;
    }

    /// Returns the source rectangle for the current frame and row.
    pub fn sourceRect(self: *const SpriteController) rl.Rectangle {
        return .{
            .x = @as(f32, @floatFromInt(self.current_frame)) * self.frame_width,
            .y = @as(f32, @floatFromInt(self.current_row)) * self.frame_height,
            .width = self.frame_width,
            .height = self.frame_height,
        };
    }
};
