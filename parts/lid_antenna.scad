// lid_antenna.scad - weatherproof antenna bulkheads through the case lid.
//
// The connectors themselves keep the water out: use SMA (or BNC/N) bulkhead
// jacks that come with an O-ring, fitted with the O-ring on the OUTSIDE of
// the lid, plus a dust cap on each when not in use. These printed parts
// make the install clean and strong:
//   "template" - drill guide. Tape it to the outside of the lid, drill
//                a 2 mm pilot through each hole, then step up to 6.5 mm (SMA).
//   "backer"   - inside stiffener plate, bonded to the lid with epoxy or VHB.
//                The bulkhead nuts clamp the thin lid wall between the O-ring
//                and this plate, and its D-flat holes stop the jacks spinning
//                when you screw an antenna on.
// Where: the lid's side wall opposite the hinge. With the lid open that
// edge points up, so antennas stand vertical, which suits VHF/UHF, and the
// wall is clear of the display. Centre the holes ~12 mm above the lid floor,
// just above the lid_plate. Inside, RG316 pigtails run along the lid with a
// slack loop across the hinge to the SDR in the base.
//
// Print flat. PETG or ASA for the backer if the case lives in a hot car.

include <bugout.scad>

PART  = "backer";

N     = 3;        // number of connectors
SPACE = 25;       // centre spacing (enough for fingers and SMA wrenches)
HOLE_D = 6.5;     // SMA 1/4-36 bulkhead. BNC: 9.7, N-type: 16
FLAT   = 5.9;     // across the D-flat. BNC: 8.9
BACKER_T = 3;
MARGIN = 10;
BACKER_H = 16;    // fits the lid side wall above the 4 mm lid_plate

W = (N - 1) * SPACE + 2 * MARGIN;
D = BACKER_H;

module dhole(d, f, h) {
    linear_extrude(h) intersection() {
        circle(d = d);
        square([f, d + 1], center = true);
    }
}

module template() {
    difference() {
        rplate(W, D, 1.6, 3);
        for (i = [0 : N - 1]) translate([MARGIN + i * SPACE, D / 2, -0.01]) {
            cylinder(d = 2, h = 2);
        }
        // notches to line up on a pencil line
        for (i = [0 : N - 1]) translate([MARGIN + i * SPACE, 0, -0.01]) {
            translate([-0.4, -0.01, 0]) cube([0.8, 3, 2]);
            translate([-0.4, D - 3 + 0.01, 0]) cube([0.8, 3, 2]);
        }
    }
}

module backer() {
    difference() {
        rplate(W, D, BACKER_T, 3);
        for (i = [0 : N - 1]) translate([MARGIN + i * SPACE, D / 2, -0.01]) {
            // D-flat through hole keys the jack body
            dhole(HOLE_D, FLAT, BACKER_T + 0.02);
        }
    }
}

if (PART == "template") template();
if (PART == "backer") backer();
