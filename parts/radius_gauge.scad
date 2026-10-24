// radius_gauge.scad - corner radius gauges for measuring the inside of the case.
//
// Each tab has one rounded corner, labelled with its radius. Push tabs into
// the inside corner of the lid (or base) at the floor. The right one sits
// flat against both walls with no gap at the curve. If one rocks on the curve
// it's too small; if it touches the walls but gaps at the curve it's too big.
// Set LID_R (lid_plate.scad) to the best fit, or the next size down.
//
// Print flat, 0.2 mm layers. Takes about 15 minutes.

include <bugout.scad>

RADII = [4, 6, 8, 10, 12, 15, 18, 22, 26, 30];
T     = 2;
TAB   = 34;   // tab size; big enough for the largest radius

module tab(r) {
    difference() {
        linear_extrude(T) hull() {
            translate([r, r]) circle(r = r, $fn = 96);
            translate([TAB - 1, 0]) square(1);
            translate([0, TAB - 1]) square(1);
            translate([TAB - 1, TAB - 1]) square(1);
        }
        translate([TAB * 0.62, TAB * 0.62, T - 0.6]) linear_extrude(1)
            text(str("R", r), size = 6, font = "Liberation Mono:style=Bold",
                 halign = "center", valign = "center");
        // hole to keep the set on a ring
        translate([TAB - 5, TAB - 5, -0.01]) cylinder(d = 4, h = T + 0.02);
    }
}

for (i = [0 : len(RADII) - 1])
    translate([(i % 5) * (TAB + 4), floor(i / 5) * (TAB + 4), 0]) tab(RADII[i]);
