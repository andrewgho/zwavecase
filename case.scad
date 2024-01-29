include <rpi4.scad>

// https://datasheets.raspberrypi.com/rpi4/raspberry-pi-4-mechanical-drawing.pdf

length = 85;
width = 56;
corner_radius = 3;

hole_offset = 3.5;
hole_id = 2.7;
hole_od = 6;
hole_length_center_offset = 58;
hole_width_center_offset = 49;

mount_post_height = 2;
lip_height = 3;
thickness = 1;

antenna_screw_od = 6.25;
antenna_bottom_shaft_od = 10;

e = 0.1;
e2 = e * 2;
$fn = 60;

module mount_post_origin() {
  difference() {
    hull() {
      translate([corner_radius, corner_radius]) {
        cylinder(r = corner_radius, h = mount_post_height);
      }
      translate([hole_offset, hole_offset]) {
        cylinder(d = hole_od, h = mount_post_height);
      }
    }
    translate([hole_offset, hole_offset, -e]) {
      cylinder(d = hole_id, h = mount_post_height + e2);
    }
  }
}

module mount_post_edge() {
  difference() {
    hull() {
      translate([hole_offset + hole_length_center_offset, hole_offset]) {
        cylinder(d = hole_od, h = mount_post_height);
      }
      translate([(hole_offset + hole_length_center_offset) - corner_radius, 0]) {
        cube([corner_radius * 2, e, mount_post_height]);
      }
    }
    translate([hole_offset + hole_length_center_offset, hole_offset, -e]) {
      cylinder(d = hole_id, h = mount_post_height + e2);
    }
  }
}

// Base plate
module base_plate() {
  module corner() {
    cylinder(r = corner_radius, h = thickness);
  }
  module strut() {
    hull() {
      translate([corner_radius, corner_radius]) corner();
      translate([hole_offset + hole_length_center_offset, width - hole_offset]) corner();
    }
  }
  strut();
  translate([0, width, 0]) mirror([0, 1, 0]) strut();
}

// Corner lip
module lip_origin() {
  difference() {
    hull() {
      translate([corner_radius, -thickness, 0]) {
        cube([corner_radius + thickness, thickness, thickness + lip_height]);
      }
      translate([corner_radius, corner_radius, 0]) {
        cylinder(r = corner_radius + thickness, h = thickness + lip_height);
      }
      translate([-thickness, corner_radius, 0]) {
        cube([thickness, corner_radius + thickness, thickness + lip_height]);
      }
    }
    translate([0, 0, thickness]) {
      hull() {
        translate([corner_radius, 0]) {
          cube([corner_radius + thickness + e, (corner_radius * 2) + e, lip_height + e]);
        }
        translate([corner_radius, corner_radius]) {
          cylinder(r = corner_radius, h = lip_height + e);
        }
        translate([0, corner_radius]) {
          cube([(corner_radius * 2) + e, corner_radius + thickness + e,
                lip_height + e]);
        }
      }
    }
  }
}

module lip_edge() {
  translate([(hole_offset + hole_length_center_offset) - corner_radius, -thickness]) {
    cube([corner_radius * 2, thickness, thickness + lip_height]);
  }
}

base_plate();
lip_origin();
lip_edge();
mount_post_origin();
mount_post_edge();
translate([0, (hole_offset * 2) + hole_width_center_offset]) mirror([0, 1, 0]) {
  lip_origin();
  mount_post_origin();
  mount_post_edge();
}

// Reference model
translate([0, width, 5]) rotate(-90, [0, 0, 1]) board_raspberrypi_4_model_b();
