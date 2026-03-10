const rl = @import("rl");
const std = @import("std");
const common = @import("common.zig");
const kn = @import("../game.zig").kn;

pub const PlayerClass = enum {
    default,
};

pub const Player = struct {
    class: PlayerClass,
};

pub const Projectile = struct {
    origin: rl.Vector2,
    rotation: f32,
    position: rl.Vector2,
    speed: f32,
    damage: f32,
    range: f32,
    distance_traveled: f32,
};

pub const Weapon = struct {
    name: []const u8,
    attack_speed: f32,
    projectile_speed: f32,
    damage: f32,
    range: f32,
    // projectiles: std.ArrayList(Projectile), // active projectiles fired by this weapon

    time_since_last_fire: f32, // seconds accumulated since last fire

    pub fn init(name: []const u8, attack_speed: f32, damage: f32, range: f32) Weapon {
        return .{
            .name = name,
            .attack_speed = attack_speed,
            .projectile_speed = 300.0, // default projectile speed, can be customized per weapon
            .damage = damage,
            .range = range,
            // .projectiles = .empty,
            .time_since_last_fire = attack_speed, // ready to fire immediately
        };
    }

    pub fn tick(self: *Weapon, dt: f32) bool {
        self.time_since_last_fire += dt;

        if (self.time_since_last_fire >= self.attack_speed) {
            self.time_since_last_fire = 0;

            return true;
        }

        return false;
    }

    pub fn isProjectileReady(self: *Weapon) bool {
        return (self.tick(rl.getFrameTime()));
    }

    pub fn getProjectile(
        self: *Weapon,
        transform: *const common.Transform,
    ) Projectile {
        std.debug.print("Firing projectile from weapon: {s}\n", .{self.name});

        return Projectile{
            .origin = transform.position,
            .position = transform.position,
            .rotation = transform.rotation,
            .speed = self.projectile_speed,
            .damage = self.damage,
            .range = self.range,
            .distance_traveled = 0,
        };
    }
};
