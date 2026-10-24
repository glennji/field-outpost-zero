// lid_plate.scad - grid carrier plate shaped to the inside of the case lid.
//
// The same 20 mm M3 grid as the base tiles, cut to the lid's inner outline
// with its rounded corners. It sticks to the inside of the lid with VHB
// (which also keeps the captive nuts in), and the display module, driver
// board tray and antenna backers bolt to it.
//
// Lid (Glenn's case): 243 x 215 x 25 mm outside, tapering slightly toward
// the floor. Defaults below are an ESTIMATE of the inside of the lid at its
// floor (outside size, minus ~3 mm walls, minus ~1 mm taper, minus 1 mm
// clearance each side). Measure the inside at the floor and the corner
// radius (print radius_gauge.scad), then set LID_IN_W / LID_IN_D / LID_R.
//
// Most beds can't print 230 x 200 in one piece, so SPLIT cuts the plate into
// two halves that dovetail together. Print flat, no supports.

include <bugout.scad>

LID_IN_W = 231;    // inside width at the floor, minus clearance (MEASURE)
LID_IN_D = 203;    // inside depth at the floor, minus clearance (MEASURE)
LID_R    = 12;     // inside corner radius (MEASURE with radius_gauge)
T        = 4;      // plate thickness (fits the M3 nut traps)
SPLIT    = true;   // two halves for beds smaller than ~240 mm
HALF     = 0;      // with SPLIT: 0 = left half, 1 = right half, 2 = both laid out
WINDOWS  = true;   // small diamond windows between grid holes, saves filament

DT_W = 8;
DT_L = 5;
FIT  = 0.25;

// Grid is centred on the plate so both edges get equal margins.
GX0 = (LID_IN_W - floor(LID_IN_W / PITCH) * PITCH) / 2;
GY0 = (LID_IN_D - floor(LID_IN_D / PITCH) * PITCH) / 2;
NX  = floor(LID_IN_W / PITCH);
NY  = floor(LID_IN_D / PITCH);
SPLIT_X = GX0 + floor(NX / 2) * PITCH;   // split along a grid line

module outline2d() {
    translate([LID_R, LID_R]) offset(r = LID_R) square([LID_IN_W - 2 * LID_R, LID_IN_D - 2 * LID_R]);
}

module dovetail2d(extra = 0) {
    polygon([[0, -DT_W / 2 - extra], [DT_L + extra, -DT_W / 2 - 2 - extra],
             [DT_L + extra, DT_W / 2 + 2 + extra], [0, DT_W / 2 + extra]]);
}

// dovetail rows sit on odd grid lines, between holes
DT_YS = [for (j = [1 : 2 : NY - 1]) GY0 + j * PITCH];

module plate() {
    difference() {
        linear_extrude(T) outline2d();
        translate([GX0, GY0, 0]) grid(NX, NY, PITCH / 2, PITCH / 2) {
            m3_hole(T);
            translate([0, 0, -0.01]) nut_trap();
        }
        if (WINDOWS)
            for (i = [1 : NX - 1], j = [1 : NY - 1])
                // keep the split line solid so the halves join cleanly
                if (!(SPLIT && GX0 + i * PITCH == SPLIT_X))
                    translate([GX0 + i * PITCH, GY0 + j * PITCH, -0.01])
                        rotate(45) cylinder(d = 9, h = T + 0.02, $fn = 4);
    }
}

module half(side) {
    big = 1000;
    if (side == 0)
        union() {
            intersection() { plate(); translate([-1, -1, -1]) cube([SPLIT_X + 1, big, T + 2]); }
            intersection() {
                plate_solid();
                for (y = DT_YS) translate([SPLIT_X, y, 0]) linear_extrude(T) dovetail2d();
            }
        }
    else
        difference() {
            intersection() { plate(); translate([SPLIT_X, -1, -1]) cube([big, big, T + 2]); }
            for (y = DT_YS) translate([SPLIT_X, y, -0.01]) linear_extrude(T + 0.02) dovetail2d(FIT);
        }
}

module plate_solid() { linear_extrude(T) outline2d(); }

if (!SPLIT) plate();
else if (HALF == 0) half(0);
else if (HALF == 1) translate([-SPLIT_X, 0, 0]) half(1);
else { half(0); translate([15, 0, 0]) half(1); }

echo(str("Lid plate ", LID_IN_W, " x ", LID_IN_D, " mm, grid ", NX, " x ", NY,
         " cells, split at x = ", SPLIT_X));
