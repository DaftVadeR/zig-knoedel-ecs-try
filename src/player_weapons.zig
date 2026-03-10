const rl = @import("rl");
const game = @import("game.zig");
const std = @import("std");

const resources = @import("./resources/common.zig");
const components = @import("./components/common.zig");
const player_components = @import("./components/player.zig");
const pcw = @import("./player_content/weapons.zig");

const kn = game.kn;

pub fn plugin(app: *kn.App) !void {
    // deinit alloc'ed weapons
    try app.addSystemEx(game.Schedule.cleanup, &deinit, kn.OnExit(game.AppState.gameplay));

    try app.addSystemEx(game.Schedule.update, &addComponents, kn.InState(game.AppState.gameplay));

    // try app.addSystemEx(game.Schedule.draw, &draw, kn.InState(game.AppState.gameplay));
    try app.addSystemEx(game.Schedule.update, &update, kn.InState(game.AppState.gameplay));
}
fn addComponents(
    alloc: kn.Alloc,
    query: kn.QueryFiltered(.{
        player_components.Player,
    }, .{
        kn.WithOut(player_components.Armable),
    }),
    cmd: kn.App.Commands,
) !void {
    var it = query.iterQ(struct { player: *const player_components.Player, entity: kn.Entity });

    while (it.next()) |en| {
        std.debug.print("add weapons to player\n", .{});

        const armable = pcw.getArmableForPlayerClass(alloc, en.player.class);

        try cmd.insert(en.entity, .{armable});
    }
}

fn deinit(alloc: kn.Alloc, query: kn.Query(.{ player_components.Player, kn.Mut(player_components.Armable) })) !void {
    var it = query.iterQ(struct { armable: *player_components.Armable });

    while (it.next()) |en| {
        // first projectiles.
        for (en.armable.weapons.items) |*wpn| {
            wpn.projectiles.deinit(alloc.world);
        }

        en.armable.weapons.deinit(alloc.world);
    }
}

fn update(
    alloc: kn.Alloc,
    weapons: kn.Query(.{
        player_components.Player,
        kn.Mut(player_components.Armable),
        components.Transform,
    }),
) !void {
    var it = weapons.iterQ(
        struct {
            armable: *player_components.Armable,
            player: *const player_components.Player,
            transform: *const components.Transform,
        },
    );

    while (it.next()) |en| {
        for (en.armable.weapons.items) |*wpn| {
            // delete old projectiles
            var i: usize = wpn.projectiles.items.len;

            // performant way to remove projectiles without allocation
            while (i > 0) {
                i -= 1;

                const pj = wpn.projectiles.items[i];
                const distance = pj.position.distance(pj.origin);

                if (distance > pj.range) {
                    _ = wpn.projectiles.swapRemove(i);
                }
            }

            // fire new projectiles
            wpn.fireProjectileIfReady(
                alloc,
                en.transform,
            ); // should have everything it needs from the player transform
            //

            // update existing projectiles positions
            for (wpn.projectiles.items) |*pj| {
                if (pj.speed > 0) {
                    updateProjectile(pj);
                }
            }
        }
    }
}

fn updateProjectile(pj: *player_components.Projectile) void {
    const distance = pj.speed * rl.getFrameTime();

    pj.position.x += @cos(pj.rotation) * distance;
    pj.position.y += @sin(pj.rotation) * distance;

    // only update position?
}

fn draw(
    weapons_query: kn.Query(.{kn.Mut(player_components.Armable)}),
) !void {
    var it = weapons_query.iterQ(
        struct {
            armable: *player_components.Armable,
        },
    );

    while (it.next()) |en| {
        for (en.armable.weapons.items) |*wpn| {
            for (wpn.projectiles) |pj| {
                rl.drawCircleV(pj.position, 10, .orange);
            }
        }
    }
}
