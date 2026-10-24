// shims.scad - spacers, wedges and wall jacks for taking up slack.
//
// PART = "spacers": flat 1 x 2 cell spacers in 1, 2, 3 and 5 mm, slotted
//                   for M3, to lift a bracket or level a tile.
// PART = "wedges":  tapered wedges to pack between the floor tiles and the
//                   case walls (moulded cases have 1-3 degree draft).
// PART = "jack":    a wall jack: bolts to the grid at the edge of the floor
//                   and an M3 screw pushes a pad against the case wall, so
//                   the floor locks in without glue or holes in the case.
// Print flat. TPU works well for the wedges and jack pads.

include <bugout.scad>

PART = "spacers";

SPACER_T = [1, 2, 3, 5];
WEDGE_L  = 40;
WEDGE_W  = 15;
WEDGE_SIZES = [[1, 4], [2, 6], [3, 8]];   // [thin end, thick end]

module spacer(t) {
    difference() {
        rplate(PITCH - 1, 2 * PITCH - 1, t, 2);
        translate([(PITCH - 1) / 2, PITCH / 2 - 0.5, 0]) rotate(90) m3_slot(PITCH, t);
    }
}

module wedge(t0, t1) {
    difference() {
        rotate([90, 0, 0]) translate([0, 0, -WEDGE_W])
            linear_extrude(WEDGE_W) polygon([[0, 0], [WEDGE_L, 0], [WEDGE_L, t1], [0, t0]]);
        // finger pull hole at the thick end
        translate([WEDGE_L - 6, WEDGE_W / 2, -0.01]) cylinder(d = 4, h = t1 + 1);
    }
}

module wall_jack() {
    H = 14;
    difference() {
        union() {
            grid_foot(1, 2, 5);
            cube([PITCH, 8, H]);
        }
        // horizontal M3 pointing at the wall (-Y), nut trapped inside
        translate([PITCH / 2, 9, H / 2 + 1.5]) rotate([90, 0, 0]) cylinder(d = M3_CLEAR, h = 10);
        translate([PITCH / 2 - M3_NUT_AF / 2, 3, H / 2 + 1.5 - M3_NUT_AF / 2 / cos(30)])
            cube([M3_NUT_AF, M3_NUT_H + 0.3, H]);
    }
}

// Pad that snaps over the jack screw tip so it doesn't mark the case.
module jack_pad() {
    difference() {
        cylinder(d = 12, h = 4);
        translate([0, 0, 1.5]) cylinder(d = 2.9, h = 3);
    }
}

if (PART == "spacers")
    for (i = [0 : len(SPACER_T) - 1])
        translate([i * (PITCH + 3), 0, 0]) spacer(SPACER_T[i]);
if (PART == "wedges")
    for (i = [0 : len(WEDGE_SIZES) - 1])
        translate([0, i * (WEDGE_W + 3), 0]) wedge(WEDGE_SIZES[i][0], WEDGE_SIZES[i][1]);
if (PART == "jack") {
    wall_jack();
    translate([PITCH + 12, 10, 0]) jack_pad();
}
