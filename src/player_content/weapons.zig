const pc = @import("../components/player.zig");
const common = @import("../components/common.zig");
const app = @import("../game.zig");
const std = @import("std");

const kn = app.kn;

pub fn getEnergyWeapon() pc.Weapon {
    return pc.Weapon.init("Energy Weapon", 1.0, 10, 500.0);
}
