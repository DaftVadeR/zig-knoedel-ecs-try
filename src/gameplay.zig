const rl = @import("rl");
const ecs = @import("zflecs");
const game = @import("game.zig");
const comp = @import("components.zig");
const player = @import("player.zig");
const enemy = @import("enemy.zig");

var game_ref: ?*game.Game = null;

fn gameplayInputSystem(_: *ecs.iter_t) callconv(.c) void {
    const g = game_ref orelse return;
    if (g.state != .gameplay) return;

    if (rl.isKeyPressed(.escape)) {
        g.setState(.menu);
    }
}

fn addRawSystem(world: *ecs.world_t, name: [*:0]const u8, phase: ecs.entity_t, callback: ecs.iter_action_t) void {
    var desc = ecs.system_desc_t{};
    desc.callback = callback;
    _ = ecs.SYSTEM(world, name, phase, &desc);
}

pub const GameplayModule = struct {
    pub fn init(g: *game.Game) void {
        game_ref = g;

        var desc = ecs.component_desc_t{ .entity = 0, .type = .{ .size = 0, .alignment = 0 } };
        _ = ecs.module_init(g.world, "GameplayModule", &desc);

        ecs.COMPONENT(g.world, comp.Position);
        ecs.COMPONENT(g.world, comp.Velocity);
        ecs.COMPONENT(g.world, comp.Speed);
        ecs.COMPONENT(g.world, comp.Circle);
        ecs.COMPONENT(g.world, comp.Rect);

        addRawSystem(g.world, "GameplayInput", ecs.PreUpdate, gameplayInputSystem);

        player.PlayerModule.init(g);
        enemy.EnemyModule.init(g);
    }

    pub fn onEnter(g: *game.Game) void {
        player.PlayerModule.onEnter(g);
        enemy.EnemyModule.onEnter(g);
    }

    pub fn onExit(g: *game.Game) void {
        player.PlayerModule.onExit(g);
        enemy.EnemyModule.onExit(g);
    }
};
