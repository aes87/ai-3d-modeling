#!/usr/bin/env python3
"""Geometry analyzer — mesh-based printability analysis using trimesh.

Usage: python3 geometry_analyze.py <stl-path> [--layer-height 0.2] [--output report.json]

Slices the mesh at every layer height and computes:
  - Per-layer cross-section area and perimeter
  - Overhang angles (per-triangle face normal vs build direction)
  - Unsupported horizontal spans (bridges)
  - Minimum wall thickness per layer
  - Transition detection (significant cross-section changes)

Returns JSON on stdout (or to --output file):
  { "layers": [...], "overhangs": [...], "bridges": [...], "thinWalls": [...], "transitions": [...], "summary": {...} }
"""

import argparse
import json
import sys
from pathlib import Path

import numpy as np
import trimesh


# --- Printer defaults (Bambu X1C / PLA) ---
DEFAULT_LAYER_HEIGHT = 0.2   # mm
MAX_OVERHANG_ANGLE = 45.0    # degrees from vertical
MAX_BRIDGE_SPAN = 10.0       # mm
MIN_WALL_THICKNESS = 1.2     # mm
MIN_FLOOR_CEIL = 0.8         # mm


def load_mesh(stl_path):
    """Load and validate an STL mesh."""
    mesh = trimesh.load(str(stl_path), force="mesh")
    if mesh.is_empty:
        raise ValueError(f"Empty mesh: {stl_path}")
    return mesh


def analyze_overhangs(mesh):
    """Compute per-face overhang angles relative to the build direction (Z-up).

    Returns faces where the overhang exceeds MAX_OVERHANG_ANGLE.
    Overhang angle = angle between face normal and the -Z axis (gravity),
    measured as the angle from vertical.
    """
    # Face normals point outward. For a downward-facing surface,
    # the normal has a negative Z component.
    normals = mesh.face_normals
    z_component = normals[:, 2]

    # Only consider downward-facing surfaces (normal Z < 0)
    downward_mask = z_component < -1e-6

    # Angle from vertical (Z-up): angle between normal and -Z axis
    # cos(theta) = dot(normal, [0,0,-1]) = -z_component
    # We want the angle from the build plate (horizontal), not from vertical:
    #   overhang_angle = 90 - arccos(-z_component)
    # Or equivalently: overhang_angle_from_vertical = arccos(abs(z_component))
    # The printability limit is MAX_OVERHANG_ANGLE from horizontal,
    # which means (90 - MAX_OVERHANG_ANGLE) from vertical.

    overhang_faces = []
    if np.any(downward_mask):
        downward_indices = np.where(downward_mask)[0]
        # Angle from horizontal for downward faces
        # normal points down, so angle_from_horizontal = arcsin(abs(z_component))
        # Wait — let's think clearly:
        # If the face is perfectly horizontal (facing straight down), z = -1, overhang = 90°
        # If the face is at 45° from horizontal, z = -sin(45°) ≈ -0.707, overhang = 45°
        # If the face is vertical, z = 0, overhang = 0°
        # So: overhang_from_horizontal = arcsin(abs(z_component))
        angles_from_horizontal = np.degrees(np.arcsin(np.clip(
            np.abs(z_component[downward_mask]), 0, 1
        )))

        over_limit = angles_from_horizontal > MAX_OVERHANG_ANGLE
        if np.any(over_limit):
            flagged_indices = downward_indices[over_limit]
            flagged_angles = angles_from_horizontal[over_limit]

            for idx, angle in zip(flagged_indices, flagged_angles):
                centroid = mesh.triangles_center[idx]
                area = mesh.area_faces[idx]
                overhang_faces.append({
                    "face_index": int(idx),
                    "angle_from_horizontal": round(float(angle), 1),
                    "centroid": [round(float(c), 2) for c in centroid],
                    "area_mm2": round(float(area), 3),
                })

    return overhang_faces


def slice_mesh(mesh, layer_height):
    """Slice mesh at every layer height, returning cross-section data per layer."""
    bounds = mesh.bounds  # [[min_x, min_y, min_z], [max_x, max_y, max_z]]
    z_min = bounds[0][2]
    z_max = bounds[1][2]

    # Slice heights: from first layer midpoint to top
    z_values = np.arange(z_min + layer_height / 2, z_max, layer_height)

    layers = []
    prev_area = 0.0
    prev_bounds = None

    for i, z in enumerate(z_values):
        section = mesh.section(
            plane_origin=[0, 0, z],
            plane_normal=[0, 0, 1]
        )

        layer_data = {
            "layer_num": i,
            "z_mm": round(float(z), 3),
            "area_mm2": 0.0,
            "perimeter_mm": 0.0,
            "bounds": None,
            "num_contours": 0,
        }

        if section is not None:
            try:
                # Project to 2D for area/perimeter calculation
                flat, _transform = section.to_planar()
                layer_data["area_mm2"] = round(float(flat.area), 3)
                layer_data["perimeter_mm"] = round(float(flat.length), 3)
                layer_data["num_contours"] = len(flat.entities) if hasattr(flat, 'entities') else 0

                # 2D bounding box
                if len(flat.vertices) > 0:
                    flat_bounds = flat.bounds  # [[min_x, min_y], [max_x, max_y]]
                    layer_data["bounds"] = {
                        "min_x": round(float(flat_bounds[0][0]), 3),
                        "min_y": round(float(flat_bounds[0][1]), 3),
                        "max_x": round(float(flat_bounds[1][0]), 3),
                        "max_y": round(float(flat_bounds[1][1]), 3),
                        "width_x": round(float(flat_bounds[1][0] - flat_bounds[0][0]), 3),
                        "width_y": round(float(flat_bounds[1][1] - flat_bounds[0][1]), 3),
                    }
            except Exception as e:
                sys.stderr.write(f"Layer {i} (z={z:.2f}): section processing failed: {e}\n")

        layers.append(layer_data)
        prev_area = layer_data["area_mm2"]
        prev_bounds = layer_data.get("bounds")

    return layers


def detect_transitions(layers, threshold_pct=10.0):
    """Detect layers where cross-section area changes significantly.

    A transition is flagged when the area changes by more than threshold_pct
    relative to the previous layer.
    """
    transitions = []
    for i in range(1, len(layers)):
        prev_area = layers[i - 1]["area_mm2"]
        curr_area = layers[i]["area_mm2"]

        if prev_area < 0.01 and curr_area < 0.01:
            continue  # both empty

        if prev_area < 0.01:
            # Material appears (first layer of a new feature)
            transitions.append({
                "layer_num": i,
                "z_mm": layers[i]["z_mm"],
                "type": "material_start",
                "prev_area": prev_area,
                "curr_area": curr_area,
                "change_pct": 100.0,
            })
            continue

        change_pct = abs(curr_area - prev_area) / prev_area * 100
        if change_pct > threshold_pct:
            transitions.append({
                "layer_num": i,
                "z_mm": layers[i]["z_mm"],
                "type": "expansion" if curr_area > prev_area else "contraction",
                "prev_area": round(prev_area, 3),
                "curr_area": round(curr_area, 3),
                "change_pct": round(change_pct, 1),
            })

    return transitions


def estimate_wall_thickness(mesh, layer_height, sample_layers=None):
    """Estimate minimum wall thickness per sampled layer using ray casting.

    For each layer, cast rays inward from the cross-section boundary
    to find the nearest opposing wall.
    """
    bounds = mesh.bounds
    z_min = bounds[0][2]
    z_max = bounds[1][2]
    z_values = np.arange(z_min + layer_height / 2, z_max, layer_height)

    if sample_layers is not None:
        # Only check specific layers (e.g., transition layers)
        z_values = [z_values[i] for i in sample_layers if i < len(z_values)]

    thin_walls = []

    for z in z_values:
        section = mesh.section(
            plane_origin=[0, 0, z],
            plane_normal=[0, 0, 1]
        )
        if section is None:
            continue

        try:
            flat, transform = section.to_planar()
            if len(flat.vertices) < 3:
                continue

            # Sample points along the boundary and cast rays inward
            # Use the polygon's boundary to get evenly spaced sample points
            paths = flat.polygons_full
            for polygon in paths:
                boundary = polygon.exterior
                coords = np.array(boundary.coords[:-1])  # drop closing duplicate

                if len(coords) < 4:
                    continue

                # Sample every ~1mm along boundary
                perimeter = boundary.length
                n_samples = max(int(perimeter / 1.0), 10)
                sample_distances = np.linspace(0, perimeter, n_samples, endpoint=False)

                for d in sample_distances:
                    pt = boundary.interpolate(d)
                    pt_coords = np.array([pt.x, pt.y])

                    # Compute inward normal at this point
                    # Get neighboring points for tangent estimation
                    d_next = (d + 0.5) % perimeter
                    d_prev = (d - 0.5) % perimeter
                    pt_next = boundary.interpolate(d_next)
                    pt_prev = boundary.interpolate(d_prev)

                    tangent = np.array([pt_next.x - pt_prev.x, pt_next.y - pt_prev.y])
                    tangent_len = np.linalg.norm(tangent)
                    if tangent_len < 1e-10:
                        continue
                    tangent /= tangent_len

                    # Inward normal (rotate tangent 90° clockwise for exterior)
                    inward = np.array([tangent[1], -tangent[0]])

                    # Check if inward actually points into the polygon
                    test_pt = pt_coords + inward * 0.01
                    from shapely.geometry import Point
                    if not polygon.contains(Point(test_pt)):
                        inward = -inward  # flip

                    # Cast ray inward to find opposing wall
                    # Find intersection with polygon boundary
                    from shapely.geometry import LineString
                    ray_end = pt_coords + inward * 200  # 200mm max ray
                    ray = LineString([pt_coords + inward * 0.05, ray_end])
                    intersection = ray.intersection(boundary)

                    if intersection.is_empty:
                        continue

                    # Minimum distance to the intersection
                    if intersection.geom_type == 'Point':
                        dist = np.linalg.norm(
                            np.array([intersection.x, intersection.y]) - pt_coords
                        )
                    elif intersection.geom_type == 'MultiPoint':
                        dists = [
                            np.linalg.norm(np.array([p.x, p.y]) - pt_coords)
                            for p in intersection.geoms
                        ]
                        dist = min(dists)
                    else:
                        # LineString or other — use distance
                        dist = pt_coords[0]  # fallback
                        continue

                    if dist < MIN_WALL_THICKNESS:
                        layer_num = int(round((z - bounds[0][2]) / layer_height))
                        thin_walls.append({
                            "layer_num": layer_num,
                            "z_mm": round(float(z), 3),
                            "thickness_mm": round(float(dist), 3),
                            "location": [round(float(pt_coords[0]), 2),
                                         round(float(pt_coords[1]), 2)],
                            "min_required": MIN_WALL_THICKNESS,
                        })
                        break  # one flag per layer is enough

        except Exception as e:
            sys.stderr.write(f"Wall thickness at z={z:.2f}: {e}\n")
            continue

    return thin_walls


def detect_bridges(layers, layer_height):
    """Detect potential bridge spans by comparing consecutive layer bounds.

    A bridge occurs when a layer has material in a region that the layer
    below does not — specifically, when the XY extent of the current layer
    exceeds the previous layer's extent.
    """
    bridges = []

    for i in range(1, len(layers)):
        curr = layers[i]
        prev = layers[i - 1]

        if curr["bounds"] is None or prev["bounds"] is None:
            continue
        if curr["area_mm2"] < 0.01:
            continue

        cb = curr["bounds"]
        pb = prev["bounds"]

        # Check each direction for unsupported extension
        spans = []
        if cb["min_x"] < pb["min_x"] - 0.1:
            spans.append(("−X", round(pb["min_x"] - cb["min_x"], 3)))
        if cb["max_x"] > pb["max_x"] + 0.1:
            spans.append(("+X", round(cb["max_x"] - pb["max_x"], 3)))
        if cb["min_y"] < pb["min_y"] - 0.1:
            spans.append(("−Y", round(pb["min_y"] - cb["min_y"], 3)))
        if cb["max_y"] > pb["max_y"] + 0.1:
            spans.append(("+Y", round(cb["max_y"] - pb["max_y"], 3)))

        for direction, span_mm in spans:
            if span_mm > MAX_BRIDGE_SPAN:
                bridges.append({
                    "layer_num": i,
                    "z_mm": curr["z_mm"],
                    "direction": direction,
                    "span_mm": span_mm,
                    "max_allowed": MAX_BRIDGE_SPAN,
                    "pass": False,
                })
            elif span_mm > layer_height:
                # Potential bridge (>1 layer height of unsupported span)
                bridges.append({
                    "layer_num": i,
                    "z_mm": curr["z_mm"],
                    "direction": direction,
                    "span_mm": span_mm,
                    "max_allowed": MAX_BRIDGE_SPAN,
                    "pass": True,
                })

    return bridges


def build_summary(mesh, layers, overhangs, bridges, thin_walls, transitions):
    """Build a summary of all findings."""
    bounds = mesh.bounds
    bbox = {
        "x": round(float(bounds[1][0] - bounds[0][0]), 3),
        "y": round(float(bounds[1][1] - bounds[0][1]), 3),
        "z": round(float(bounds[1][2] - bounds[0][2]), 3),
    }

    overhang_fail_count = len(overhangs)
    bridge_fail_count = sum(1 for b in bridges if not b["pass"])
    thin_wall_count = len(thin_walls)

    total_issues = overhang_fail_count + bridge_fail_count + thin_wall_count
    overall_pass = total_issues == 0

    # Aggregate overhang data
    overhang_summary = {}
    if overhangs:
        angles = [o["angle_from_horizontal"] for o in overhangs]
        total_area = sum(o["area_mm2"] for o in overhangs)
        overhang_summary = {
            "count": len(overhangs),
            "max_angle": round(max(angles), 1),
            "min_angle": round(min(angles), 1),
            "total_area_mm2": round(total_area, 3),
            "total_mesh_area_mm2": round(float(mesh.area), 3),
            "pct_of_surface": round(total_area / float(mesh.area) * 100, 1),
        }

    return {
        "bbox": bbox,
        "volume_mm3": round(float(abs(mesh.volume)), 3),
        "surface_area_mm2": round(float(mesh.area), 3),
        "is_watertight": bool(mesh.is_watertight),
        "num_layers": len(layers),
        "num_transitions": len(transitions),
        "overhangs": overhang_summary,
        "bridge_fails": bridge_fail_count,
        "bridge_warnings": sum(1 for b in bridges if b["pass"]),
        "thin_walls": thin_wall_count,
        "overall_pass": overall_pass,
        "total_issues": total_issues,
    }


def main():
    parser = argparse.ArgumentParser(description="Mesh geometry analyzer for FDM printability")
    parser.add_argument("stl_path", help="Path to STL file")
    parser.add_argument("--layer-height", type=float, default=DEFAULT_LAYER_HEIGHT,
                        help=f"Layer height in mm (default: {DEFAULT_LAYER_HEIGHT})")
    parser.add_argument("--output", "-o", help="Output JSON file (default: stdout)")
    parser.add_argument("--skip-walls", action="store_true",
                        help="Skip wall thickness analysis (faster)")
    parser.add_argument("--wall-sample-rate", type=int, default=10,
                        help="Check wall thickness every N layers (default: 10)")
    args = parser.parse_args()

    stl_path = Path(args.stl_path)
    if not stl_path.exists():
        print(f"Error: STL file not found: {stl_path}", file=sys.stderr)
        sys.exit(1)

    sys.stderr.write(f"Loading mesh: {stl_path}\n")
    mesh = load_mesh(stl_path)
    sys.stderr.write(f"  Faces: {len(mesh.faces)}, Vertices: {len(mesh.vertices)}\n")
    sys.stderr.write(f"  Bounds: {mesh.bounds[0]} → {mesh.bounds[1]}\n")

    # Step 1: Overhang analysis (per-face, fast)
    sys.stderr.write("Analyzing overhangs...\n")
    overhangs = analyze_overhangs(mesh)
    sys.stderr.write(f"  {len(overhangs)} faces exceed {MAX_OVERHANG_ANGLE}° overhang\n")

    # Step 2: Layer-by-layer slicing
    sys.stderr.write(f"Slicing at {args.layer_height}mm layers...\n")
    layers = slice_mesh(mesh, args.layer_height)
    sys.stderr.write(f"  {len(layers)} layers\n")

    # Step 3: Transition detection
    sys.stderr.write("Detecting transitions...\n")
    transitions = detect_transitions(layers)
    sys.stderr.write(f"  {len(transitions)} significant transitions\n")

    # Step 4: Bridge detection
    sys.stderr.write("Detecting bridges...\n")
    bridges = detect_bridges(layers, args.layer_height)
    bridge_fails = sum(1 for b in bridges if not b["pass"])
    sys.stderr.write(f"  {len(bridges)} potential bridges, {bridge_fails} exceed {MAX_BRIDGE_SPAN}mm\n")

    # Step 5: Wall thickness (optional, slower)
    thin_walls = []
    if not args.skip_walls:
        sys.stderr.write("Analyzing wall thickness...\n")
        # Sample at transition layers + every Nth layer
        transition_layers = [t["layer_num"] for t in transitions]
        regular_samples = list(range(0, len(layers), args.wall_sample_rate))
        sample_layers = sorted(set(transition_layers + regular_samples))
        thin_walls = estimate_wall_thickness(mesh, args.layer_height, sample_layers)
        sys.stderr.write(f"  {len(thin_walls)} layers below {MIN_WALL_THICKNESS}mm wall\n")

    # Build report
    summary = build_summary(mesh, layers, overhangs, bridges, thin_walls, transitions)

    report = {
        "stl_path": str(stl_path),
        "layer_height_mm": args.layer_height,
        "printer_limits": {
            "max_overhang_angle": MAX_OVERHANG_ANGLE,
            "max_bridge_span_mm": MAX_BRIDGE_SPAN,
            "min_wall_thickness_mm": MIN_WALL_THICKNESS,
            "min_floor_ceil_mm": MIN_FLOOR_CEIL,
        },
        "summary": summary,
        "overhangs": overhangs[:50],  # cap at 50 worst faces
        "bridges": bridges,
        "thin_walls": thin_walls,
        "transitions": transitions,
        "layers": layers,
    }

    output_json = json.dumps(report, indent=2)

    if args.output:
        Path(args.output).write_text(output_json)
        sys.stderr.write(f"Report written to {args.output}\n")
    else:
        print(output_json)

    # Exit code reflects pass/fail
    sys.exit(0 if summary["overall_pass"] else 1)


if __name__ == "__main__":
    main()
