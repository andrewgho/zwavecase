// case.scad - Raspberry Pi 4 B+ case with antenna mount for RaZberry Pro 7
// Andrew Ho <andrew@zeuscat.com>

// Overall Raspberry Pi 4 B+ dimensions from:
// https://datasheets.raspberrypi.com/rpi4/raspberry-pi-4-mechanical-drawing.pdf
length = 85;                            // Overall PCB length (longest dimension)
width = 56;                             // Overall PCB width
corner_radius = 3;                      // PCB corner radius
hole_offset = 3.5;                      // Distance between PCB edge and screw hole
hole_id = 2.7;                          // Inner screw hole diameter
hole_od = 6;                            // Diameter of screw hole free area
hole_length_center_offset = 58;         // Distance between screw hole centers, along length
hole_width_center_offset = 49;          // Distance between screw hole centers, along width

// Measured dimensions of RaZberry Pro 7 Linx antenna
antenna_screw_od = 6.25;                // Outer diameter of bolt mount
antenna_bottom_shaft_od = 10;           // Outer diameter of external antenna shaft

// Our design parameters
thickness = 1;                          // Overall shell thickness
mount_post_height = thickness + 2;      // How high the mount posts rise from ground z = 0
lip_height = mount_post_height + 1;     // How high the walls surrounding the PCB from PCB z = 0
thickness2 = thickness * 2;

antenna_boom_length = 50;               // Length of extension from attachment to base plate
antenna_support_length = 20;            // How much of that boom length is supporting antenna shaft
antenna_boom_width =
  antenna_bottom_shaft_od + thickness2;

// Rendering parameters
e = 0.1;
e2 = e * 2;
$fn = 60;

// Create a rounded rectangular solid with a given corner radius
module rounded_cube(length, width, height, radius) {
  module corner() {
    cylinder(r = radius, h = height);
  }
  hull() {
    translate([radius, radius]) corner();
    translate([radius, width - radius]) corner();
    translate([length - radius, width - radius]) corner();
    translate([length - radius, radius]) corner();
  }
}

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

module antenna_base() {
  cube([antenna_boom_length, antenna_boom_width, thickness]);
  translate([antenna_boom_length - antenna_support_length, 0, thickness]) {
    difference() {
      hull() {
        cube([thickness, antenna_boom_width, e]);
        translate([0, thickness + (antenna_bottom_shaft_od / 2), antenna_bottom_shaft_od / 2]) {
          rotate(90, [0, 1, 0]) {
            cylinder(d = thickness2 + antenna_bottom_shaft_od, h = thickness);
          }
        }
      }
      translate([-e, thickness + (antenna_bottom_shaft_od / 2), antenna_bottom_shaft_od / 2]) {
        rotate(90, [0, 1, 0]) {
          cylinder(d = antenna_screw_od, h = thickness + e2);
        }
      }
    }
    difference() {
      cube([antenna_support_length, antenna_boom_width, antenna_bottom_shaft_od / 2]);
      translate([-e, thickness + (antenna_bottom_shaft_od / 2), antenna_bottom_shaft_od / 2]) {
        rotate(90, [0, 1, 0]) {
          cylinder(d = antenna_bottom_shaft_od, h = antenna_support_length + e2);
        }
      }
    }
  }
}

// Base plate
module base_plate() {
  inner_length = 0.85 * length;
  inner_width = 0.85 * width;
  inner_roadwidth = hole_od;
  inner_corner_radius = 2;
  module corner() {
    cylinder(r = corner_radius, h = thickness);
  }
  module strut() {
    hull() {
      translate([corner_radius, corner_radius]) corner();
      translate([hole_offset + hole_length_center_offset, width - hole_offset]) corner();
    }
  }
  translate([(length - inner_length) / 2, (width - inner_width) / 2]) {
    difference() {
      rounded_cube(inner_length, inner_width, thickness, inner_corner_radius);
      translate([inner_roadwidth, inner_roadwidth, -e]) {
        rounded_cube(inner_length - (2 * inner_roadwidth),
                     inner_width - (2 * inner_roadwidth),
                     thickness + e2, inner_corner_radius);
      }
    }
  }
  translate([(length - inner_length) / 2, (width - ((0.15 / 2) * width)) - antenna_boom_width]) {
    mirror([1, 0, 0]) antenna_base();
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
  lip_edge();
  mount_post_origin();
  mount_post_edge();
}

// Uncomment to include reference model
//include <rpi4.scad>
//translate([0, width, mount_post_height]) {
//  rotate(-90, [0, 0, 1]) #board_raspberrypi_4_model_b();
//}
