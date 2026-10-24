// board_tray.scad - raised tray for a single board computer or driver board.
//
// Defaults are for the Orange Pi 4 Pro (89 x 56 mm). Its mounting-hole
// spacing is not published, so the hole values below are the Raspberry Pi
// B-series pattern as a starting point. MEASURE YOUR BOARD and set
// HOLE_DX / HOLE_DY / HOLE_X0 / HOLE_Y0 before printing.
//
// The underside has a grid foot with slots, so the tray bolts to the base
// tiles and slides up to one grid pitch for cable clearance. Set
// GRID_FOOT = false for a flat back you stick down with VHB (lid use).
//
// Print flat, standoffs up. No supports.

include <bugout.scad>

BOARD_W  = 89;      // board size along X
BOARD_D  = 56;      // along Y
HOLE_X0  = 3.5;     // first hole, from board corner
HOLE_Y0  = 3.5;
HOLE_DX  = 58;      // hole spacing along X  (VERIFY)
HOLE_DY  = 49;      // hole spacing along Y  (VERIFY)
HOLE_D   = 2.2;     // pilot for M2.5 self-tapping (2.9 for M3)
STANDOFF_H = 8;     // clearance under the board
STANDOFF_D = 6.5;
MARGIN   = 4;       // tray border around the board
PLATE_T  = 3;
GRID_FOOT = true;
VENT     = true;    // slotted plate for airflow under the SoC

TW = BOARD_W + 2 * MARGIN;
TD = BOARD_D + 2 * MARGIN;
NX = ceil(TW / PITCH);
NY = ceil(TD / PITCH);
SY = [MARGIN + HOLE_Y0, MARGIN + HOLE_Y0 + HOLE_DY];   // standoff rows

module tray() {
    difference() {
        union() {
            rplate(GRID_FOOT ? NX * PITCH : TW, GRID_FOOT ? NY * PITCH : TD, PLATE_T);
            // standoffs
            for (x = [0, HOLE_DX], y = [0, HOLE_DY])
                translate([MARGIN + HOLE_X0 + x, MARGIN + HOLE_Y0 + y, 0])
                    cylinder(d = STANDOFF_D, h = PLATE_T + STANDOFF_H);
            // low lip on the two short edges to locate the board
            for (x = [MARGIN - 2.4, MARGIN + BOARD_W + 0.4])
                translate([x, MARGIN + 10, 0]) cube([2, BOARD_D - 20, PLATE_T + 2]);
        }
        for (x = [0, HOLE_DX], y = [0, HOLE_DY])
            translate([MARGIN + HOLE_X0 + x, MARGIN + HOLE_Y0 + y, PLATE_T])
                cylinder(d = HOLE_D, h = STANDOFF_H + 1);
        // grid slots, skipping any row that would run into a standoff
        if (GRID_FOOT)
            for (j = [0 : NY - 1])
                let (y = PITCH / 2 + j * PITCH)
                if (min([for (sy = SY) abs(sy - y)]) > STANDOFF_D / 2 + M3_HEAD_D / 2)
                    translate([PITCH / 2, y, 0]) m3_slot((NX - 1) * PITCH, PLATE_T);
        if (VENT)
            for (i = [0 : 5])
                translate([MARGIN + 18 + i * 9, MARGIN + 14, -0.01])
                    rplate(4, BOARD_D - 28, PLATE_T + 0.02, 2);
    }
}

tray();
