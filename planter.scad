// Parametric 10cm Cubic Planter
// A minimalist planter with drainage holes and matching saucer

include <BOSL2/std.scad>

/* [Main Dimensions] */
// Outer width/depth of the planter (mm)
size = 100;
// Outer height of the planter (mm)
height = 80;
// Wall thickness (mm)
wall_thickness = 8;
// Base thickness (mm)
base_thickness = 6;

/* [Squircle Shape] */
// Squircle squareness (0=circle, 1=square, 0.5-0.7 typical)
squareness = 0.65;

/* [Drainage] */
// Diameter of drainage holes (mm)
drainage_hole_diameter = 8;
// Inset ratio from corners for drainage holes (0-0.5)
drainage_hole_inset_ratio = 0.2;

// Calculated drainage inset
drainage_hole_inset = size * drainage_hole_inset_ratio;

/* [Edge Treatments] */
// Exterior base chamfer size (mm)
chamfer_size = 1;
// Interior wall draft angle (degrees)
draft_angle = 1;

/* [Saucer] */
// Include matching drip saucer
include_saucer = true;
// Diameter of rubber feet holes (3/8 inch)
feet_hole_diameter = 25.4 * 3 / 8;
// Inset distance from corners for feet holes (mm)
feet_hole_inset = 12;
// Clearance between planter foot and saucer (mm)
saucer_clearance = 1;
// Saucer lip height (mm)
saucer_lip_height = 8;
// Saucer base thickness (mm)
saucer_base_thickness = 4;
// Saucer wall thickness (mm)
saucer_wall_thickness = 4;
// Vertical gap between saucer lip top and planter shoulder (mm)
lip_gap = 2;

/* [Display] */
// Show planter seated in saucer
planter_seated = false;
// Spacing between planter and saucer when not seated (mm)
assembly_spacing = 20;

// Calculated values
inner_size = size - 2 * wall_thickness;
inner_depth = height - base_thickness;

// Foot dimensions - the narrower base that slots into saucer
foot_inset = saucer_wall_thickness + saucer_clearance;
foot_size = size - 2 * foot_inset;
foot_height = saucer_lip_height + lip_gap;

// Saucer dimensions - outer matches planter, inner fits the foot
saucer_outer_size = size;
saucer_inner_size = foot_size + 2 * saucer_clearance;
saucer_height = saucer_base_thickness + saucer_lip_height;

// Resolution for smooth curves
$fn = 128;

// Small offset to avoid coplanar faces in preview
eps = 0.01;

// Module: Squircle shape for extrusion
module squircle_shape(s, sq = squareness) {
  squircle([s, s], squareness=sq, $fn=$fn);
}

// Module: Squircle prism (extruded squircle)
module squircle_prism(s, h, sq = squareness) {
  linear_extrude(height=h)
    squircle_shape(s, sq);
}

// Module: Drainage holes positioned at corners
module drainage_holes() {
  hole_pos = drainage_hole_inset;
  positions = [
    [hole_pos, hole_pos],
    [hole_pos, size - hole_pos],
    [size - hole_pos, hole_pos],
    [size - hole_pos, size - hole_pos],
  ];

  for (pos = positions) {
    translate([pos[0], pos[1], -eps])
      cylinder(h=base_thickness + 2 * eps, d=drainage_hole_diameter);
  }
}

// Module: Chamfered shoulder transition
module shoulder_transition() {
  translate([size / 2, size / 2, foot_height])
    hull() {
      // Bottom: foot size
      linear_extrude(height=eps)
        squircle_shape(foot_size);
      // Top: full size
      translate([0, 0, foot_inset])
        linear_extrude(height=eps)
          squircle_shape(size);
    }
}

// Module: Main planter body with stepped foot and squircle profile
module planter_body() {
  inner_lip_chamfer = 1; // Chamfer on inner lip top edge
  draft_expansion = tan(draft_angle) * inner_depth;
  top_inner_size = inner_size + 2 * draft_expansion;

  difference() {
    union() {
      // Foot base chamfer (tapers up from smaller to full foot size)
      translate([size / 2, size / 2, 0])
        hull() {
          linear_extrude(height=eps)
            squircle_shape(foot_size - 2 * chamfer_size);
          translate([0, 0, chamfer_size])
            linear_extrude(height=eps)
              squircle_shape(foot_size);
        }

      // Narrower foot section (slots into saucer)
      translate([size / 2, size / 2, chamfer_size])
        squircle_prism(foot_size, foot_height - chamfer_size);

      // Chamfered shoulder transition
      shoulder_transition();

      // Main body section (full width, above saucer)
      translate([size / 2, size / 2, foot_height + foot_inset])
        squircle_prism(size, height - foot_height - foot_inset);
    }

    // Inner cavity with slight draft angle
    translate([size / 2, size / 2, base_thickness - eps]) {
      hull() {
        // Bottom of cavity
        linear_extrude(height=eps)
          squircle_shape(inner_size);
        // Top of cavity (slightly larger due to draft)
        translate([0, 0, inner_depth + eps])
          linear_extrude(height=eps)
            squircle_shape(top_inner_size);
      }
    }

    // Chamfer on inner lip top edge
    translate([size / 2, size / 2, height - inner_lip_chamfer])
      hull() {
        translate([0, 0, inner_lip_chamfer])
          linear_extrude(height=eps)
            squircle_shape(top_inner_size + 2 * inner_lip_chamfer + eps);
        linear_extrude(height=eps)
          squircle_shape(top_inner_size);
      }

    // Drainage holes
    drainage_holes();
  }
}

// Module: Drip saucer with squircle profile
module saucer() {
  inner_lip_chamfer = 1; // Chamfer on inner lip top edge

  difference() {
    union() {
      // Base chamfer (tapers up from smaller to full size)
      translate([size / 2, size / 2, 0])
        hull() {
          linear_extrude(height=eps)
            squircle_shape(saucer_outer_size - 2 * chamfer_size);
          translate([0, 0, chamfer_size])
            linear_extrude(height=eps)
              squircle_shape(saucer_outer_size);
        }

      // Main saucer body
      translate([size / 2, size / 2, chamfer_size])
        squircle_prism(saucer_outer_size, saucer_height - chamfer_size);
    }

    // Inner recess for planter foot
    translate([size / 2, size / 2, saucer_base_thickness - eps])
      squircle_prism(saucer_inner_size, saucer_lip_height + 2 * eps);

    // Chamfer on inner lip top edge
    translate([size / 2, size / 2, saucer_height - inner_lip_chamfer])
      hull() {
        translate([0, 0, inner_lip_chamfer])
          linear_extrude(height=eps)
            squircle_shape(saucer_inner_size + 2 * inner_lip_chamfer + eps);
        linear_extrude(height=eps)
          squircle_shape(saucer_inner_size);
      }

    // Rubber feet holes in corners
    feet_pos = feet_hole_inset + feet_hole_diameter / 2;
    feet_positions = [
      [feet_pos, feet_pos],
      [feet_pos, size - feet_pos],
      [size - feet_pos, feet_pos],
      [size - feet_pos, size - feet_pos],
    ];
    feet_hole_depth = 2;
    for (pos = feet_positions) {
      translate([pos[0], pos[1], -eps])
        cylinder(h=feet_hole_depth + eps, d=feet_hole_diameter);
    }
  }
}

// Module: Complete assembly view
module assembly() {
  // Saucer at origin
  if (include_saucer) {
    color("SandyBrown", 0.8)
      saucer();
  }

  // Planter positioned in/above saucer
  planter_z =
    include_saucer ?
      (planter_seated ? saucer_base_thickness : saucer_height + assembly_spacing)
    : 0;

  translate([0, 0, planter_z])
    color("Sienna", 0.9)
      planter_body();
}

// Render the assembly
assembly();

// Uncomment below for individual part export:
// planter_body();
// saucer();
