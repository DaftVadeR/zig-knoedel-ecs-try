const pc = @import("../components/player.zig");
const common = @import("../components/common.zig");
const app = @import("../game.zig");
const std = @import("std");

const kn = app.kn;

pub fn getArmableForPlayerClass(alloc: kn.Alloc, player_class: pc.PlayerClass) pc.Armable {
    std.debug.print("add weapsons to player2", .{});

    var weapons = std.ArrayList(pc.Weapon){};

    weapons.append(alloc.world, getEnergyWeapon()) catch {
        unreachable;
    };

    switch (player_class) {
        .default => return pc.Armable{
            .weapons = weapons,
        },
    }
}

pub fn getEnergyWeapon() pc.Weapon {
    return pc.Weapon.init("Energy Weapon", 1.0, 10, 500.0);
}
