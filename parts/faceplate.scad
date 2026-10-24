// faceplate.scad - swappable connector faceplates and the uprights that
// hold them.
//
// A faceplate is N grid cells wide and H tall (40 or 60 mm), with M3 holes
// on the 20 mm grid along its top and bottom edges. It bolts to a pair of
// faceplate_post uprights, or to the front of any bracket with grid holes.
// Print blanks, then design or drill cutouts as parts arrive.
//
// PART selects what to render: "plate", "post", or "demo".
// Print plates flat; print posts lying on their side (as rendered).

include <bugout.scad>

PART  = "plate";
CELLS = 4;          // width in grid cells (4 = 80 mm)
H     = 40;         // height: 40 or 60
T     = 3;          // plate thickness
EDGE  = 6;          // mounting holes sit this far from top and bottom edges

// Cutouts: [kind, x, y, a, b] with x, y from the plate's bottom-left corner.
//   ["round", x, y, d]           round hole
//   ["dflat", x, y, d, flat]     D-hole for anti-rotation (SMA, switches)
//   ["rect",  x, y, w, h]        rectangular, rounded corners
// Common sizes (check your parts' datasheets):
//   SMA bulkhead 1/4-36:      ["dflat", x, y, 6.5, 5.9]
//   BNC bulkhead:             ["dflat", x, y, 9.7, 8.9]
//   USB-C panel socket:       ["rect", x, y, 9.6, 3.8] + two ["round", ., ., 2.4]
//   5.5/2.1 DC panel jack:    ["round", x, y, 8.2]  (some need 11.2)
//   12 mm aviation (GX12):    ["dflat", x, y, 12.2, 11.2]
//   6 mm toggle switch:       ["round", x, y, 6.4]
//   3.5 mm panel jack:        ["round", x, y, 6.2]
CUTOUTS = [
    ["dflat", 15, 20, 6.5, 5.9],     // SMA: SDR antenna in
    ["rect",  35, 20, 9.6, 3.8],     // USB-C charge in
    ["round", 35 - 9, 20, 2.4],
    ["round", 35 + 9, 20, 2.4],
    ["round", 60, 20, 8.2],          // DC jack
];
LABEL = "";         // optional raised text along the top edge

module cutout(c) {
    translate([c[1], c[2], -0.01]) linear_extrude(T + 0.02)
    if (c[0] == "round") circle(d = c[3]);
    else if (c[0] == "dflat") intersection() {
        circle(d = c[3]);
        square([c[4], c[3] + 1], center = true);
    }
    else if (c[0] == "rect") offset(r = 0.8) square([c[3] - 1.6, c[4] - 1.6], center = true);
}

module faceplate() {
    W = CELLS * PITCH - 0.6;   // small gap so neighbours don't bind
    difference() {
        rplate(W, H, T, 2);
        for (i = [0 : CELLS - 1], y = [EDGE, H - EDGE])
            translate([PITCH / 2 + i * PITCH - 0.3, y, 0]) m3_hole(T);
        for (c = CUTOUTS) cutout(c);
    }
    if (LABEL != "")
        translate([W / 2, H - EDGE - 6, T]) linear_extrude(0.6)
            text(LABEL, size = 4, halign = "center", valign = "center");
}

// Upright: an L-bracket whose foot bolts to the floor grid and whose face
// takes faceplate screws (into M3 nuts trapped in the back).
module faceplate_post(h = H) {
    FOOT = 2;            // foot depth in cells
    difference() {
        union() {
            grid_foot(1, FOOT, 5);
            translate([0, -6, 0]) cube([PITCH, 6, h + 2]);
            // gusset
            translate([PITCH / 2 - 2, 0, 0]) rotate([90, 0, 90])
                linear_extrude(4) polygon([[0, 5], [0, h * 0.6], [FOOT * PITCH * 0.8, 5]]);
        }
        for (y = [EDGE, h - EDGE]) {
            translate([PITCH / 2, 1, y + 2]) rotate([90, 0, 0]) cylinder(d = M3_CLEAR, h = 8);
            translate([PITCH / 2, -1.5, y + 2]) rotate([90, 30, 0]) nut_trap(2.8);
            // nut slot from above so nuts drop in
            translate([PITCH / 2 - M3_NUT_AF / 2, -4.3, y + 2]) cube([M3_NUT_AF, 2.8, h]);
        }
    }
}

if (PART == "plate") faceplate();
if (PART == "post") rotate([0, -90, 0]) faceplate_post();
if (PART == "demo") {
    faceplate_post();
    translate([(CELLS - 1) * PITCH, 0, 0]) faceplate_post();
    translate([0.3, -6, 2]) rotate([90, 0, 0]) faceplate();
}
