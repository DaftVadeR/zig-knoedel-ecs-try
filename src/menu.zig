const rl = @import("rl");
const ecs = @import("zflecs");
const game = @import("game.zig");

var game_ref: ?*game.Game = null;

fn menuInputSystem(_: *ecs.iter_t) callconv(.c) void {
    const g = game_ref orelse return;
    if (g.state != .menu) return;

    if (rl.isKeyPressed(.enter) or rl.isKeyPressed(.space)) {
        g.setState(.gameplay);
    }
}

fn menuDrawSystem(_: *ecs.iter_t) callconv(.c) void {
    const g = game_ref orelse return;
    if (g.state != .menu) return;

    rl.drawRectangle(0, 0, game.screen_width, game.screen_height, rl.Color{ .r = 255, .g = 255, .b = 255, .a = 220 });
    rl.drawText("DAFTSHAPES", 490, 260, 48, rl.Color.black);
    rl.drawText("Press Enter or Space to start", 430, 330, 24, rl.Color.dark_gray);
}

fn addRawSystem(world: *ecs.world_t, name: [*:0]const u8, phase: ecs.entity_t, callback: ecs.iter_action_t) void {
    var desc = ecs.system_desc_t{};
    desc.callback = callback;
    _ = ecs.SYSTEM(world, name, phase, &desc);
}

pub const MenuModule = struct {
    pub fn init(g: *game.Game) void {
        game_ref = g;

        var desc = ecs.component_desc_t{ .entity = 0, .type = .{ .size = 0, .alignment = 0 } };
        _ = ecs.module_init(g.world, "MenuModule", &desc);

        addRawSystem(g.world, "MenuInput", ecs.PreUpdate, menuInputSystem);
        addRawSystem(g.world, "MenuDraw", g.draw_phase, menuDrawSystem);
    }

    pub fn onEnter(_: *game.Game) void {}

    pub fn onExit(_: *game.Game) void {}
};
