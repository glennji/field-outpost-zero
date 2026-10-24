// lid_display.scad - holds a bare LCD panel in the case lid.
//
// The panel faces out of the lid, toward you when the lid is open.
// Two parts:
//   "bezel"  - front frame. The panel drops into a pocket from behind and the
//              lip overlaps the panel's black border, so only the active area
//              shows. Debossed FO:Z badge on the bottom border (LABEL).
//   "clamp"  - back plate with heat-set inserts. M3 x 12 screws through the
//              bezel front sandwich the panel on a foam pad. Its slotted ears bolt to the lid_plate grid, so
//              the screen lifts out as one module with four screws.
// The HDMI driver board goes BESIDE the panel on its own board_tray (see
// README), not behind it: the lid is only ~22 mm deep inside.
//
// Defaults are a typical 7" 1024x600 panel. MEASURE YOUR PANEL.
// Print both parts flat, as rendered. The bezel needs no supports.

include <bugout.scad>

PART = "bezel";

PANEL_W = 165;     // panel outline (X)
PANEL_H = 100;     // panel outline (Y)
PANEL_T = 5.0;     // panel thickness including backlight
VIEW_W  = 155;     // active area (X)
VIEW_H  = 87;      // active area (Y)
VIEW_DX = 0;       // active-area offset from panel centre (FPC side is often offset)
VIEW_DY = 0;
FPC_W   = 40;      // ribbon cable exit: width ...
FPC_EDGE = "bottom";  // ... and which edge it leaves from: "bottom" "top" "left" "right"

FRAME  = 10;       // frame border beyond the panel
FRONT_T = 2;       // lip thickness in front of the panel
FOAM   = 1.5;      // foam pad behind the panel
CLAMP_T = 4.5;     // deep enough for M3 heat-set inserts

EAR_SPAN = ceil((PANEL_W + 2 * FRAME + 8) / PITCH) * PITCH;  // ear hole spacing, a grid multiple
LABEL   = "FO:Z";  // debossed on the bezel front, "" for none
LID_DEPTH_IN = 22; // usable depth inside the lid (25 mm outside minus floor)
PLATE_T = 4;       // lid_plate thickness

// Optional: driver board on the back of the clamp. Only if the lid is deep
// enough (the echo below checks). Off by default. (MEASURE YOURS)
DRIVER_ON_CLAMP = false;
DRV_W = 65;
DRV_H = 55;
DRV_HOLES = [[3.5, 3.5], [61.5, 3.5], [3.5, 51.5], [61.5, 51.5]];

OW = PANEL_W + 2 * FRAME;
OH = PANEL_H + 2 * FRAME;
BEZEL_T = FRONT_T + PANEL_T + FOAM;
SCREWS = concat([[FRAME / 2, FRAME / 2], [OW - FRAME / 2, FRAME / 2],
          [FRAME / 2, OH - FRAME / 2], [OW - FRAME / 2, OH - FRAME / 2]], [
          for (dx = [-1, 1], y = [FRAME / 2, OH - FRAME / 2])
              [OW / 2 + dx * (FPC_W / 2 + 10), y]]);   // clear of the ribbon notch

module fpc_notch(depth) {
    if (FPC_EDGE == "bottom") translate([OW / 2 - FPC_W / 2, FRAME - 4, 0]) cube([FPC_W, 5, depth]);
    if (FPC_EDGE == "top")    translate([OW / 2 - FPC_W / 2, OH - FRAME - 1, 0]) cube([FPC_W, 5, depth]);
    if (FPC_EDGE == "left")   translate([FRAME - 4, OH / 2 - FPC_W / 2, 0]) cube([5, FPC_W, depth]);
    if (FPC_EDGE == "right")  translate([OW - FRAME - 1, OH / 2 - FPC_W / 2, 0]) cube([5, FPC_W, depth]);
}

// Front face down on the bed (z = 0 is the viewing side).
module bezel() {
    difference() {
        rplate(OW, OH, BEZEL_T, 4);
        // viewing window, chamfered so the lip doesn't shadow the edges
        translate([OW / 2 + VIEW_DX, OH / 2 + VIEW_DY, -0.01])
            hull() {
                linear_extrude(0.01) square([VIEW_W + 2 * FRONT_T, VIEW_H + 2 * FRONT_T], center = true);
                translate([0, 0, FRONT_T]) linear_extrude(0.02) square([VIEW_W, VIEW_H], center = true);
            }
        // panel pocket from the back, 0.4 mm clearance
        translate([FRAME - 0.4, FRAME - 0.4, FRONT_T]) cube([PANEL_W + 0.8, PANEL_H + 0.8, BEZEL_T]);
        translate([0, 0, FRONT_T]) fpc_notch(BEZEL_T);
        // module screws go in from the front (serviceable with the lid open),
        // counterbored, into heat-set inserts in the clamp
        for (s = SCREWS) translate([s[0], s[1], 0]) {
            m3_hole(BEZEL_T);
            translate([0, 0, -0.01]) cylinder(d = M3_HEAD_D, h = M3_HEAD_H);
        }
        // badge, mirrored because the front face prints on the bed
        if (LABEL != "")
            translate([OW / 4, FRAME / 2, -0.01]) mirror([1, 0, 0]) linear_extrude(0.6)
                text(LABEL, size = 5.5, font = "Liberation Mono:style=Bold",
                     halign = "center", valign = "center");
    }
}

// Clamp, lid side down. z = 0 sits on the lid_plate.
module clamp() {
    difference() {
        union() {
            translate([OW / 2 - EAR_SPAN / 2 - 7, 0, 0]) rplate(EAR_SPAN + 14, OH, CLAMP_T, 4);
            if (DRIVER_ON_CLAMP)
                translate([OW / 2 - DRV_W / 2, OH / 2 - DRV_H / 2, 0])
                    for (h = DRV_HOLES) translate([h[0], h[1], 0]) cylinder(d = 6, h = CLAMP_T + 6);
        }
        // heat-set inserts for the bezel screws, pressed in from the top
        for (s = SCREWS) translate([s[0], s[1], -0.01]) cylinder(d = M3_INSERT, h = CLAMP_T + 0.02);
        if (DRIVER_ON_CLAMP)
            translate([OW / 2 - DRV_W / 2, OH / 2 - DRV_H / 2, 0])
                for (h = DRV_HOLES) translate([h[0], h[1], 1]) cylinder(d = 2.2, h = CLAMP_T + 6);
        // ear holes, spaced a whole number of grid cells apart
        for (j = [0 : floor(OH / PITCH) - 1], dx = [-1, 1])
            translate([OW / 2 + dx * EAR_SPAN / 2, PITCH / 2 + j * PITCH, 0])
                m3_hole(CLAMP_T);
        // lightening / airflow windows behind the panel
        WIN = (OW - 2 * FRAME - 24) / 2;
        for (x = [FRAME + 8, OW / 2 + 4])
            translate([x, FRAME + 8, -0.01])
                rplate(WIN, OH - 2 * FRAME - 16, CLAMP_T + 0.02, 4);
        // ribbon cable pass-through
        translate([0, 0, -0.01]) fpc_notch(CLAMP_T + 0.02);
    }
}

STACK = PLATE_T + CLAMP_T + BEZEL_T;
echo(str("Display stack above lid floor: ", STACK, " mm of ", LID_DEPTH_IN, " mm",
         STACK > LID_DEPTH_IN - 3 ? "  ** TOO DEEP: lid may not close **" : "  OK"));

if (PART == "bezel") bezel();
if (PART == "clamp") clamp();
