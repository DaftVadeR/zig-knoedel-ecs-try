const game = @import("game.zig");
// const gameplay = @import("gameplay.zig");
const menu = @import("menu.zig");

pub fn main() void {
    var g = game.Game.init();

    g.addModule(.menu, menu.MenuModule);
    // g.addModule(.gameplay, gameplay.GameplayModule);
    g.setState(.menu);

    g.run();

    g.deinit();
}
