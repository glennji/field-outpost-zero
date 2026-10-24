// bugout.scad - shared library for the Bugout SDR mounting system.
//
// Everything mounts on a 20 mm grid of M3 holes. Base tiles carry captive
// M3 nuts underneath, so any bracket with grid-spaced slots can be bolted
// anywhere on the floor with M3 x 8-12 mm screws.
//
// Include this from part files with:  include <bugout.scad>

$fn = 48;

// ---- Grid and hardware ---------------------------------------------------
PITCH      = 20;     // grid spacing, mm
M3_CLEAR   = 3.4;    // M3 clearance hole
M3_HEAD_D  = 6.2;    // M3 socket head counterbore
M3_HEAD_H  = 3.2;
M3_NUT_AF  = 5.7;    // M3 nut across flats, with print clearance
M3_NUT_H   = 2.6;
M3_INSERT  = 4.2;    // hole for M3 heat-set insert (if you prefer inserts)

// ---- Printing ------------------------------------------------------------
WALL   = 2.4;        // default wall, a multiple of a 0.4 nozzle
CHAMF  = 0.8;        // edge chamfer

// ---- Helpers -------------------------------------------------------------

// Hexagon prism for a nut trap, flats aligned with X.
module nut_trap(h = M3_NUT_H, af = M3_NUT_AF) {
    cylinder(d = af / cos(30), h = h, $fn = 6);
}

// Through hole for M3, optionally with counterbore at the top (z = h).
module m3_hole(h, counterbore = false) {
    translate([0, 0, -0.01]) cylinder(d = M3_CLEAR, h = h + 0.02);
    if (counterbore)
        translate([0, 0, h - M3_HEAD_H]) cylinder(d = M3_HEAD_D, h = M3_HEAD_H + 0.01);
}

// Slot of length len (centre to centre) along X, for M3.
module m3_slot(len, h, d = M3_CLEAR) {
    translate([0, 0, -0.01]) hull() {
        cylinder(d = d, h = h + 0.02);
        translate([len, 0, 0]) cylinder(d = d, h = h + 0.02);
    }
}

// Rounded rectangle plate, corner radius r, origin at the corner.
module rplate(w, d, h, r = 3) {
    r2 = min(r, w / 2 - 0.01, d / 2 - 0.01);
    translate([r2, r2, 0]) linear_extrude(h)
        offset(r = r2) square([w - 2 * r2, d - 2 * r2]);
}

// Grid of points, nx by ny, starting at (x0, y0).
module grid(nx, ny, x0 = 0, y0 = 0, p = PITCH) {
    for (i = [0 : nx - 1], j = [0 : ny - 1])
        translate([x0 + i * p, y0 + j * p, 0]) children();
}

// Mounting foot: a plate with M3 slots on the grid, so any part can be
// bolted down and slid up to one pitch along X. Footprint nx x ny cells.
// With counterbore = true the screw heads sit flush with the top (h >= 6),
// so a battery or dongle can sit directly on the foot.
module grid_foot(nx, ny, h = 4, counterbore = false) {
    difference() {
        rplate(nx * PITCH, ny * PITCH, h);
        for (j = [0 : ny - 1])
            translate([PITCH / 2, PITCH / 2 + j * PITCH, 0]) {
                m3_slot((nx - 1) * PITCH, h);
                if (counterbore)
                    translate([0, 0, h - M3_HEAD_H])
                        m3_slot((nx - 1) * PITCH, M3_HEAD_H, M3_HEAD_D);
            }
    }
}

// Velcro / strap slot through a wall, slot width sw, height sh.
module strap_slot(sw = 22, sh = 3, depth = 20) {
    translate([-sw / 2, -depth / 2, 0]) cube([sw, depth, sh]);
}
