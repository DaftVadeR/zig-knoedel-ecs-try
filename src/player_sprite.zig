const rl = @import("rl");
const game = @import("game.zig");
const resources = @import("./resources/common.zig");
const components = @import("./components/common.zig");
const player_components = @import("./components/player.zig");
const std = @import("std");

const kn = game.kn;

// Spritesheet layout: 6 columns x 2 rows of 16x16 frames.
// Row 0 = idle, Row 1 = run.
const FRAME_WIDTH: f32 = 16;
const FRAME_HEIGHT: f32 = 16;
const FRAME_COUNT: u32 = 6;
const FRAME_DURATION: f32 = 0.12; // ~8 FPS animation

const ROW_IDLE: u32 = 0;
const ROW_RUN: u32 = 1;

pub fn plugin(app: *kn.App) !void {
    // Attach Sprite + SpriteController to the player once it exists
    try app.addSystemEx(game.Schedule.update, &addComponents, kn.InState(game.AppState.gameplay));

    // Tick animation and switch idle/run based on input
    try app.addSystemEx(game.Schedule.update, &update, kn.InState(game.AppState.gameplay));

    // Draw the sprite
    try app.addSystemEx(game.Schedule.draw, &draw, kn.InState(game.AppState.gameplay));

    // Unload texture on exit
    try app.addSystemEx(game.Schedule.cleanup, &cleanup, kn.OnExit(game.AppState.gameplay));
}

/// Attaches Sprite and SpriteController to any Player entity that doesn't have them yet.
fn addComponents(
    query: kn.QueryFiltered(.{player_components.Player}, .{kn.WithOut(components.Sprite)}),
    cmd: kn.App.Commands,
) !void {
    var it = query.iterQ(struct { entity: kn.Entity });

    while (it.next()) |en| {
        const texture = try rl.loadTexture("assets/images/player/knight_spritesheet.png");

        const controller = components.SpriteController{
            .frame_width = FRAME_WIDTH,
            .frame_height = FRAME_HEIGHT,
            .frame_count = FRAME_COUNT,
            .frame_duration = FRAME_DURATION,
            .current_row = ROW_IDLE,
        };

        try cmd.insert(en.entity, .{
            components.Sprite{
                .texture = texture,
                .src = controller.sourceRect(),
            },
            controller,
        });
    }
}

/// Advance animation timer and switch between idle/run based on input.
fn update(
    input_res: kn.Res(resources.Input),
    query: kn.Query(.{
        player_components.Player,
        kn.Mut(components.Sprite),
        kn.Mut(components.SpriteController),
    }),
) !void {
    const dt = rl.getFrameTime();
    const input = input_res.inner.input_normalised;
    const is_moving = input.x != 0 or input.y != 0;

    var it = query.iterQ(struct {
        sprite: *components.Sprite,
        controller: *components.SpriteController,
    });

    while (it.next()) |en| {
        // Switch animation row based on movement
        const target_row: u32 = if (is_moving) ROW_RUN else ROW_IDLE;

        if (en.controller.current_row != target_row) {
            en.controller.current_row = target_row;
            en.controller.current_frame = 0;
            en.controller.frame_timer = 0;
        }

        // Advance animation
        _ = en.controller.tick(dt);

        // Update the sprite source rect to the current frame
        en.sprite.src = en.controller.sourceRect();
    }
}

/// Draw the player sprite, flipped horizontally based on Transform.facing.
fn draw(
    query: kn.Query(.{
        player_components.Player,
        components.Transform,
        components.Sprite,
    }),
) !void {
    var it = query.iterQ(struct {
        transform: *const components.Transform,
        sprite: *const components.Sprite,
    });

    while (it.next()) |en| {
        const pos = en.transform.position;
        const size = en.transform.size;

        // Source rect — flip width sign for horizontal flip based on facing.
        // Raylib flips the texture when source width is negative.
        const src = rl.Rectangle{
            .x = en.sprite.src.x,
            .y = en.sprite.src.y,
            .width = en.sprite.src.width * en.transform.facing,
            .height = en.sprite.src.height,
        };

        // Destination rect — centered on the entity position.
        const dest = rl.Rectangle{
            .x = pos.x,
            .y = pos.y,
            .width = size.x,
            .height = size.y,
        };

        // Origin at center of the destination rect for center-origin drawing.
        const origin = rl.Vector2{
            .x = size.x / 2.0,
            .y = size.y / 2.0,
        };

        rl.drawTexturePro(
            en.sprite.texture,
            src,
            dest,
            origin,
            0, // no rotation — facing is handled by source width flip
            rl.Color.white,
        );
    }
}

/// Unload textures when leaving gameplay state.
fn cleanup(
    query: kn.Query(.{ player_components.Player, kn.Mut(components.Sprite) }),
) !void {
    var it = query.iterQ(struct { sprite: *components.Sprite });

    while (it.next()) |en| {
        rl.unloadTexture(en.sprite.texture);
    }
}
