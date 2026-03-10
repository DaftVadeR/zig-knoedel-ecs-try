const rl = @import("rl");
const game = @import("game.zig");
const std = @import("std");

const resources = @import("./resources/common.zig");
const components = @import("./components/common.zig");
const player_components = @import("./components/player.zig");
const player_content = @import("./player_content/weapons.zig");
const pcw = @import("./player_content/weapons.zig");

const kn = game.kn;

pub fn plugin(app: *kn.App) !void {
    // deinit alloc'ed weapons - will happen automatically now
    // try app.addSystemEx(game.Schedule.cleanup, &deinit, kn.OnExit(game.AppState.gameplay));

    // runs once
    try app.addSystemEx(game.Schedule.update, &addComponents, kn.InState(game.AppState.gameplay));

    // update weapon firing and projectile movement
    try app.addSystemEx(game.Schedule.update, &updateWeapons, kn.InState(game.AppState.gameplay));
    try app.addSystemEx(game.Schedule.update, &updateProjectiles, kn.InState(game.AppState.gameplay));

    try app.addSystemEx(game.Schedule.draw, &draw, kn.InState(game.AppState.gameplay));
}

fn addComponents(
    player_query: kn.Query(.{
        player_components.Player,
    }),
    query: kn.Query(
        .{
            player_components.Weapon,
        },
    ),
    cmd: kn.App.Commands,
) !void {
    if (query.count() > 0) {
        return;
    }

    var player_it = player_query.iterQ(struct { player: *const player_components.Player, entity: kn.Entity });

    while (player_it.next()) |player_en| {
        _ = player_en; // use for weapon somehow later?

        std.debug.print("add weapons to player\n", .{});

        _ = try cmd.spawn(.{
            player_content.getEnergyWeapon(),
            kn.StateScoped(game.AppState){ .state = .gameplay },
        });
    }
}

fn updateWeapons(
    cmd: kn.Commands,
    player_query: kn.QueryFiltered(.{components.Transform}, .{kn.With(player_components.Player)}),
    weapons_query: kn.Query(.{
        kn.Mut(player_components.Weapon),
    }),
) !void {
    var it = weapons_query.iterQ(
        struct {
            weapon: *player_components.Weapon,
        },
    );

    var player_it = player_query.iterQ(
        struct {
            transform: *const components.Transform,
        },
    );

    // only ever one player so should be fine
    while (player_it.next()) |player_en| {
        while (it.next()) |weapon_en| {
            if (weapon_en.weapon.isProjectileReady()) {
                _ = try cmd.spawn(.{
                    weapon_en.weapon.getProjectile(player_en.transform),
                    kn.StateScoped(game.AppState){ .state = .gameplay },
                });
            }
        }
    }
}

fn updateProjectiles(
    cmd: kn.Commands,
    projectiles: kn.Query(.{
        kn.Mut(player_components.Projectile),
    }),
) !void {
    var it = projectiles.iterQ(
        struct {
            projectile: *player_components.Projectile,
            entity: kn.Entity,
        },
    );

    while (it.next()) |en| {
        const distance = en.projectile.position.distance(en.projectile.origin);

        if (distance > en.projectile.range) {
            try cmd.despawn(en.entity);
        }

        // update existing projectiles positions
        if (en.projectile.speed > 0) {
            updateProjectile(en.projectile);
        }
    }
}

fn updateProjectile(
    pj: *player_components.Projectile,
) void {
    const distance = pj.speed * rl.getFrameTime();

    pj.position.x += @cos(pj.rotation) * distance;
    pj.position.y += @sin(pj.rotation) * distance;

    // only update position?
}

fn draw(
    weapons_query: kn.Query(.{player_components.Projectile}),
) !void {
    var it = weapons_query.iterQ(
        struct {
            projectile: *const player_components.Projectile,
        },
    );

    while (it.next()) |en| {
        rl.drawCircleV(en.projectile.position, 10, .orange);
    }
}
