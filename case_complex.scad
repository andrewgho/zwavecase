include <rpi4.scad>

pcb_length = 56;
pcb_width = 85;
pcb_thickness = 1.40;
pcb_corner_radius = 3;

case_thickness = 1;
case_thickness2 = case_thickness * 2;
case_empty_height = 2.5;  // height between case bottom's top and PCB's bottom

case_length = pcb_length + case_thickness2;
case_width = pcb_width + case_thickness2;
case_corner_radius = pcb_corner_radius + case_thickness;
case_lip_height = 6.5 + case_thickness;

e = 0.1;
e2 = e * 2;
$fn = 90;

module rounded_flat_corners(length, width, height, radius) {
  module corner() {
    cylinder(r = radius, h = height);
  }
  union() {
    translate([radius, radius]) corner();
    translate([radius, width - radius]) corner();
    translate([length - radius, width - radius]) corner();
    translate([length - radius, radius]) corner();
  }
}

module rounded_spherical_corners(length, width, radius) {
  module corner() {
    sphere(r = radius);
  }
  union() {
    translate([radius, radius, radius]) corner();
    translate([radius, width - radius, radius]) corner();
    translate([length - radius, width - radius, radius]) corner();
    translate([length - radius, radius, radius]) corner();
  }
}

module rounded_flat_cube(length, width, height, radius) {
  hull() rounded_flat_corners(length, width, height, radius);
}

module bathtub_bulk(length, width, height, radius) {
  difference() {
    hull() {
      rounded_spherical_corners(length, width, radius);
      translate([0, 0, radius]) {
        rounded_flat_cube(length, width, max(radius, height - radius), radius);
      }
    }
    translate([-e, -e, height]) {
      cube([length + e2, width + e2, max(0, (2 * radius) - height) + e]);
    }
  }
}

module bathtub(length, width, height, radius, thickness) {
  t2 = thickness * 2;
  r2 = radius - thickness;
  difference() {
    bathtub_bulk(length, width, height, radius);
    #translate([thickness, thickness, thickness]) {
      bathtub_bulk(length - t2, width - t2, (height - thickness) + e, r2);
    }
  }
}

module case() {
  bathtub(case_length, case_width, case_lip_height,
          case_corner_radius, case_thickness);
}

difference() {
  case();
  translate([case_thickness, case_thickness, case_thickness + case_empty_height]) {
    board_raspberrypi_4_model_b();
  }
}
