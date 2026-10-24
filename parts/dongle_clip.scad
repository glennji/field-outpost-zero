// dongle_clip.scad - snap clip for a USB dongle such as the RTL-SDR v4.
//
// A U-channel the dongle presses into, with a cable-tie slot as backup.
// Defaults fit the RTL-SDR Blog v4 (about 64 x 26 x 13 mm, metal body);
// measure yours and add 0.4 mm to width and height.
//
// Print as rendered, foot down. No supports.

include <bugout.scad>

DW  = 26.4;   // dongle width (Y)
DH  = 13.4;   // dongle height (Z)
LEN = 40;     // clip length along the dongle (X)
LIP = 1.6;    // how far the lips overhang the top edge
BASE_T = 6;

NX = ceil(LEN / PITCH);
NY = ceil((DW + 2 * WALL) / PITCH);
OD = DW + 2 * WALL;
Y0 = (NY * PITCH - OD) / 2;

difference() {
    union() {
        grid_foot(NX, NY, BASE_T, counterbore = true);
        translate([0, Y0, BASE_T]) difference() {
            cube([LEN, OD, DH + WALL]);
            translate([-1, WALL, -1]) cube([LEN + 2, DW, DH + 1]);
            // opening at the top, narrower than the dongle: it snaps in
            translate([-1, WALL + LIP, DH - 0.01]) cube([LEN + 2, DW - 2 * LIP, WALL + 1]);
        }
    }
    // cable-tie slot across the middle
    translate([LEN / 2 - 2, -1, BASE_T + 2]) cube([4, NY * PITCH + 2, 2]);
}
