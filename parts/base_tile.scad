// base_tile.scad - floor tile with a 20 mm grid of captive M3 nuts.
//
// Print several and dovetail them together to cover the case floor, then
// stick the assembled floor down with VHB tape (no holes in the case, so
// it stays waterproof). The tape also keeps the nuts from dropping out.
//
// Print flat, top face up, 0.2 mm layers, 4 walls, 30% infill. No supports:
// the nut traps open on the underside.

include <bugout.scad>

NX       = 5;       // cells along X (5 x 20 = 100 mm)
NY       = 5;       // cells along Y
T        = 5;       // tile thickness
TRIM_X   = 0;       // >0 trims the tile to this width, to fit the case edge
TRIM_Y   = 0;       // >0 trims the tile to this depth
JOIN_X   = true;    // dovetail tabs on +X edge, sockets on -X edge
JOIN_Y   = true;    // same along Y
USE_INSERTS = false;  // true: heat-set insert holes instead of nut traps

DT_W = 8;           // dovetail neck width
DT_L = 5;           // dovetail length
FIT  = 0.25;        // clearance for the socket

module dovetail(extra = 0) {
    linear_extrude(T + 0.02)
        polygon([[0, -DT_W / 2 - extra], [DT_L + extra, -DT_W / 2 - 2 - extra],
                 [DT_L + extra, DT_W / 2 + 2 + extra], [0, DT_W / 2 + extra]]);
}

module tile() {
    W = NX * PITCH;
    D = NY * PITCH;
    difference() {
        union() {
            cube([W, D, T]);
            // tabs on +X and +Y, one per two cells, between grid holes
            if (JOIN_X) for (j = [1 : 2 : NY - 1])
                translate([W, j * PITCH, 0]) dovetail();
            if (JOIN_Y) for (i = [1 : 2 : NX - 1])
                translate([i * PITCH, D, 0]) rotate(90) dovetail();
        }
        // matching sockets on -X and -Y
        if (JOIN_X) for (j = [1 : 2 : NY - 1])
            translate([0, j * PITCH, -0.01]) dovetail(FIT);
        if (JOIN_Y) for (i = [1 : 2 : NX - 1])
            translate([i * PITCH, 0, -0.01]) rotate(90) dovetail(FIT);

        grid(NX, NY, PITCH / 2, PITCH / 2) {
            if (USE_INSERTS) {
                translate([0, 0, -0.01]) cylinder(d = M3_INSERT, h = T + 0.02);
            } else {
                m3_hole(T);
                translate([0, 0, -0.01]) nut_trap();
            }
        }
        // grip grooves on top so shims and feet don't skate
        for (i = [1 : NX - 1])
            translate([i * PITCH - 0.4, -1, T - 0.4]) cube([0.8, D + 2, 1]);
        for (j = [1 : NY - 1])
            translate([-1, j * PITCH - 0.4, T - 0.4]) cube([W + 2, 0.8, 1]);
    }
}

if (TRIM_X > 0 || TRIM_Y > 0)
    intersection() {
        tile();
        translate([-DT_L - 1, -DT_L - 1, -1])
            cube([(TRIM_X > 0 ? TRIM_X : 1000) + DT_L + 1,
                  (TRIM_Y > 0 ? TRIM_Y : 1000) + DT_L + 1, T + 2]);
    }
else
    tile();
