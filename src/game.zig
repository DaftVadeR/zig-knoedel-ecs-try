const rl = @import("rl");
const ecs = @import("zflecs");

const ZOOM = 2;

pub const screen_width: i32 = 1280;
pub const screen_height: i32 = 720;
pub const simulated_width: i32 = screen_width / ZOOM;
pub const simulated_height: i32 = screen_height / ZOOM;

pub const Game = struct {
    world: *ecs.world_t,
    camera: rl.Camera2D,
    draw_phase: ecs.entity_t,
    state: AppState,
    modules: [state_count]StateModule,

    pub const AppState = enum(u8) {
        none,
        menu,
        gameplay,
    };

    const state_count = @typeInfo(AppState).@"enum".fields.len;

    const StateFn = *const fn (*Game) void;

    const StateModule = struct {
        init_fn: ?StateFn = null,
        enter_fn: ?StateFn = null,
        exit_fn: ?StateFn = null,
        initialized: bool = false,
    };

    pub fn init() Game {
        rl.setConfigFlags(.{
            .vsync_hint = true,
            .msaa_4x_hint = false,
        });

        rl.initWindow(screen_width, screen_height, "daftshapes");
        rl.setTargetFPS(60);
        rl.setWindowState(.{ .borderless_windowed_mode = false, .fullscreen_mode = false });

        const world = ecs.init();
        const draw_phase = ecs.entity_init(world, &.{ .name = "DrawPhase" });
        ecs.add_id(world, draw_phase, ecs.Phase);
        ecs.add_id(world, draw_phase, ecs.make_pair(ecs.DependsOn, ecs.OnStore));

        const camera2d = rl.Camera2D{
            .target = .{ .x = 0, .y = 0 },
            .offset = .{ .x = 0, .y = 0 },
            .rotation = 0,
            .zoom = ZOOM,
        };

        return .{
            .world = world,
            .camera = camera2d,
            .draw_phase = draw_phase,
            .state = .none,
            .modules = [_]StateModule{.{}} ** state_count,
        };
    }

    pub fn addModule(self: *Game, state: AppState, comptime module: type) void {
        self.modules[stateIndex(state)] = .{
            .init_fn = module.init,
            .enter_fn = module.onEnter,
            .exit_fn = module.onExit,
            .initialized = false,
        };
    }

    pub fn setState(self: *Game, next_state: AppState) void {
        if (self.state == next_state) return;

        if (self.state != .none) {
            const prev_module = &self.modules[stateIndex(self.state)];
            if (prev_module.exit_fn) |exit_fn| exit_fn(self);
        }

        self.state = next_state;

        const next_module = &self.modules[stateIndex(next_state)];
        if (!next_module.initialized) {
            if (next_module.init_fn) |init_fn| init_fn(self);
            next_module.initialized = true;
        }

        if (next_module.enter_fn) |enter_fn| enter_fn(self);
    }

    pub fn deinit(self: *Game) void {
        if (self.state != .none) {
            const current = &self.modules[stateIndex(self.state)];
            if (current.exit_fn) |exit_fn| exit_fn(self);
        }
        _ = ecs.fini(self.world);
        rl.closeWindow();
    }

    pub fn run(self: *Game) void {
        while (!rl.windowShouldClose()) {
            rl.beginDrawing();
            rl.clearBackground(rl.Color.ray_white);

            self.camera.begin();
            _ = ecs.progress(self.world, rl.getFrameTime());
            rl.drawFPS(10, 10);
            self.camera.end();

            rl.endDrawing();
        }
    }

    fn stateIndex(state: AppState) usize {
        return @intFromEnum(state);
    }
};
