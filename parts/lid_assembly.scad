// lid_assembly.scad - preview of the lid layout (not for printing).
// Imports the rendered STLs from ../stl, so render those first.
// Shows: lid outline (grey), lid_plate, display module at the top of the
// grid, driver board tray in the cells below it, antenna backer on the wall
// opposite the hinge (hinge is along the bottom edge in this view).

include <bugout.scad>

LID_OUT_W = 243;
LID_OUT_D = 215;
LID_H     = 25;
WALL_T    = 3;     // assumed shell thickness

// lid shell, cut away so you can see in
%difference() {
    translate([-(LID_OUT_W - 231) / 2, -(LID_OUT_D - 203) / 2, -WALL_T]) rplate(LID_OUT_W, LID_OUT_D, LID_H, 14);
    translate([-(LID_OUT_W - 231) / 2 + WALL_T, -(LID_OUT_D - 203) / 2 + WALL_T, 0]) rplate(LID_OUT_W - 2 * WALL_T, LID_OUT_D - 2 * WALL_T, LID_H, 12);
}
color("SteelBlue") import("../stl/lid_plate_full.stl");
// display module: clamp + bezel (bezel flipped front-up), top rows of the grid
GX0 = 5.5; GY0 = 1.5;   // matches lid_plate defaults
translate([GX0 + 17.5, GY0 + 80, 4]) {
    color("DimGray") import("../stl/lid_display_clamp.stl");
    color("#333") translate([185, 0, 4.5 + 8.5]) rotate([0, 180, 0]) import("../stl/lid_display_bezel.stl");
}
// driver tray in the 4 x 4 cells below
color("DarkOrange") translate([GX0 + 60, GY0, 4]) import("../stl/driver_tray.stl");
// antenna backer on the inside of the far wall
color("OliveDrab") translate([115.5 - 35, 206, 4]) rotate([90, 0, 0]) import("../stl/lid_antenna_backer.stl");
