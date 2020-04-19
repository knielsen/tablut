// The size of one square.
D = 21;
// Board size in tiles.
N = 9;
// Width of edge around the board.
board_edge_width = 5;
// Width of edge between tiles.
tile_edge_width = 1.5;
board_thick = 6;
tile_depress = 1.2;
relief = tile_depress + 0.45;
hatch_dist = 2.22;
hatch2_dist = 1.5*hatch_dist;
hatch_width = .2*hatch_dist;
// Piece size.
piece_dia = .78*D;
piece_height = 4;
piece_rounding_r = 0.9;
rounded_pieces = true;
for_printing = true;

$fa=5; $fs=0.2;

board_len = N*D + 2*board_edge_width - tile_edge_width;


module crown2d() {
  scale(v=.8*[1,1,1]) {
    union() {
      translate([0, .4*D])
        circle(r=.1*D);
      translate([-.4*D, .15*D])
        circle(r=.1*D);
      translate([.4*D, .15*D])
        circle(r=.1*D);
      polygon(points=[[0, .38*D], [.2*D, -.2*D], [.4*D, .15*D],
                      [.35*D, -.45*D], [-.35*D, -.45*D],
                      [-.4*D, .15*D], [-.2*D, -.2*D]]);
    }
  }
}

module hatchmarks(dist, width) {
  count = ceil(sqrt(2)*(D-tile_edge_width) / dist);
  render(convexity=20) {
    intersection() {
      cube([D-tile_edge_width, D-tile_edge_width, 4*relief], center=true);
      rotate([0, 0, 45]) {
        for (i=[-(count-1)/2:(count-1)/2]) {
          for (j=[-(count-1)/2:(count-1)/2]) {
            translate([dist*i, dist*j, 0]) {
              cube([dist-width, dist-width, 2*relief], center=true);
            }
          }
        }
      }
    }
  }
}

module base_board() {
  difference() {
    translate([0, 0, -.5*board_thick])
      cube([board_len, board_len, board_thick], center=true);

    for (i=[-(N-1)/2:(N-1)/2]) {
      for (j=[-(N-1)/2:(N-1)/2]) {
        translate([i*D, j*D, 0]) {
          cube([D-tile_edge_width, D-tile_edge_width, 2*tile_depress], center=true);
          if ((i==0 && (j>=-2 && j<=2)) ||
              (j==0 && (i>=-2 && i<=2))) {
            hatchmarks(dist=hatch2_dist, width=hatch_width);
          }
          if (((i==-4 || i==4) && (j>=-1 && j<=1)) ||
              ((i==-3 || i==3) && j==0) ||
              ((j==-4 || j==4) && (i>=-1 && i<=1)) ||
              ((j==-3 || j==3) && i==0)) {
            hatchmarks(dist=hatch_dist, width=hatch_width);
          }
        }
      }
    }
  }
  translate([0, 0, -relief]) {
    linear_extrude(height=2*(relief-tile_depress), center=true, convexity=10) {
      crown2d();
    }
  }
}


module piece() {
  N_a = ($fa >= 45 ? 2 : ceil(90/$fa));
  N_s = ceil(.5*PI*piece_rounding_r / $fs);
  N = max(2, min(N_a, N_s));
  translate([0, 0, -tile_depress]) {
    if (rounded_pieces) {
      for (i = [0 : N-1]) {
        angle1 = i/N*90;
        x1 = piece_rounding_r*sin(angle1);
        z1 = piece_rounding_r*cos(angle1);
        angle2 = (i+1)/N*90;
        x2 = piece_rounding_r*sin(angle2);
        z2 = piece_rounding_r*cos(angle2);
        translate([0, 0, piece_rounding_r - z1]) {
          cylinder(r1=.5*piece_dia-piece_rounding_r+x1,
                   r2=.5*piece_dia-piece_rounding_r+x2,
                   h=z1-z2, center=false);
        }
        translate([0, 0, piece_height-(piece_rounding_r - z2)]) {
          cylinder(r1=.5*piece_dia-piece_rounding_r+x2,
                   r2=.5*piece_dia-piece_rounding_r+x1,
                   h=z1-z2, center=false);
        }
      }
      translate([0, 0, piece_rounding_r]) {
        cylinder(d=piece_dia, h=piece_height-2*piece_rounding_r, center=false);
      }
    } else {
      cylinder(d=piece_dia, h=piece_height, center=false);
    }
  }
}


module king_piece() {
  difference() {
    piece();
    translate([0, 0, -tile_depress+piece_height-0.01]) {
      linear_extrude(height=2*(relief-tile_depress), center=true, convexity=10) {
        scale(v=0.7*[1,1,1]) crown2d();
      }
    }
  }
}


module demo() {
  base_board();

  translate([0, D, 0])
    king_piece();
  translate([D, 0, 0])
    piece();
  translate([2*D, -3*D, 0])
    piece();
  translate([-1*D, 2*D, 0])
    piece();
}


module to_print() {
  base_board();
  translate([.6*board_len, -D, 0])
    piece();
  translate([.6*board_len, D, 0])
    king_piece();
}

if (for_printing) {
  to_print();
} else {
  demo();
}
//hatchmarks();
//crown();
//piece();
