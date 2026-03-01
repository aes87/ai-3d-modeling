// Bambu Lab X1 Carbon — build volume and dimension reporting

BED_X = 256;
BED_Y = 256;
BED_Z = 256;

// Assert a part fits within the build volume.
// Call with the bounding box dimensions of your part.
module assert_fits(x, y, z) {
  assert(x <= BED_X, str("Part X (", x, "mm) exceeds bed X (", BED_X, "mm)"));
  assert(y <= BED_Y, str("Part Y (", y, "mm) exceeds bed Y (", BED_Y, "mm)"));
  assert(z <= BED_Z, str("Part Z (", z, "mm) exceeds bed Z (", BED_Z, "mm)"));
}

// Echo dimensions in a parseable format for the Node.js pipeline.
// Call at the end of your .scad file with the part's bounding box.
module report_dimensions(x, y, z, label="part") {
  assert_fits(x, y, z);
  echo(str("DIMENSION:", label, ":x=", x));
  echo(str("DIMENSION:", label, ":y=", y));
  echo(str("DIMENSION:", label, ":z=", z));
}
