// strap_cradle.scad - cradle for the Anker battery pack (or anything boxy).
//
// Two end walls and a side wall hold the pack, and slots take a 20-25 mm
// velcro strap over the top. Set the inner size to your pack plus ~1 mm.
// The base is a grid foot, so it bolts to the floor tiles.
//
// Print flat. No supports.

include <bugout.scad>

IN_W   = 152;   // inner length along X  (MEASURE YOUR PACK)
IN_D   = 72;    // inner width along Y
WALL_H = 18;    // wall height, about 2/3 of the pack's thickness
STRAP_W = 26;   // strap slot width
BASE_T = 6;
OPEN_END = true;  // leave the +X end open for the USB ports

OW = IN_W + 2 * WALL;
OD = IN_D + 2 * WALL;
NX = ceil(OW / PITCH);
NY = ceil(OD / PITCH);
X0 = (NX * PITCH - OW) / 2;
Y0 = (NY * PITCH - OD) / 2;

difference() {
    union() {
        grid_foot(NX, NY, BASE_T, counterbore = true);
        translate([X0, Y0, BASE_T]) difference() {
            cube([OW, OD, WALL_H]);
            translate([WALL, WALL, -1]) cube([IN_W, IN_D, WALL_H + 2]);
            if (OPEN_END)
                translate([WALL + IN_W - 1, WALL + 8, -1])
                    cube([WALL + 2, IN_D - 16, WALL_H + 2]);
            // front wall cut low so the pack lifts out
            translate([WALL + 15, -1, 6]) cube([IN_W - 30, WALL + 2, WALL_H]);
        }
    }
    // strap channels: the strap runs under the pack, out through both long
    // walls, then up and over the top
    for (x = [OW * 0.25, OW * 0.75])
        translate([X0 + x, Y0 + OD / 2, BASE_T - 1.2])
            strap_slot(STRAP_W, 3.2, OD + 2);
}
