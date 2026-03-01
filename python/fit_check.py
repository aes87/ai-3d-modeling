#!/usr/bin/env python3
"""Fit/clearance measurement — validates actual clearances against declared tolerances.

Usage: python3 fit_check.py <assembly-spec.json> [project-root]

For each fitSpec entry:
  - "clearance" type: measures minimum distance between meshes
  - "interference" type: measures intersection volume

Returns JSON on stdout:
  { "checks": [{ "name", "type", "expected", "actual", "pass" }] }
"""

import json
import sys
from pathlib import Path

import numpy as np
import trimesh


def load_and_position(part, project_root):
    """Load an STL and translate it to its assembly position."""
    stl_path = project_root / part["stlPath"]
    mesh = trimesh.load(str(stl_path), force="mesh")

    pos = part.get("position", [0, 0, 0])
    if any(p != 0 for p in pos):
        mesh.apply_translation(pos)

    return mesh


def measure_clearance(mesh_a, mesh_b):
    """Measure minimum distance between two meshes using collision manager."""
    try:
        manager = trimesh.collision.CollisionManager()
        manager.add_object("a", mesh_a)
        dist = manager.min_distance_single(mesh_b)
        return round(float(dist), 4)
    except Exception as e:
        sys.stderr.write(f"Clearance measurement failed: {e}\n")
        # Fallback: sample closest points
        try:
            closest, distances, _ = trimesh.proximity.closest_point(mesh_a, mesh_b.vertices)
            return round(float(np.min(distances)), 4)
        except Exception as e2:
            sys.stderr.write(f"Proximity fallback failed: {e2}\n")
            return None


def measure_interference(mesh_a, mesh_b):
    """Measure intersection volume between two meshes."""
    try:
        intersection = trimesh.boolean.intersection([mesh_a, mesh_b], engine="manifold")
        if intersection is not None and not intersection.is_empty:
            return round(abs(intersection.volume), 4)
        return 0.0
    except Exception as e:
        sys.stderr.write(f"Interference measurement failed: {e}\n")
        return None


def main():
    if len(sys.argv) < 2:
        print("Usage: fit_check.py <assembly-spec.json> [project-root]", file=sys.stderr)
        sys.exit(2)

    spec_path = Path(sys.argv[1])
    project_root = Path(sys.argv[2]) if len(sys.argv) > 2 else Path.cwd()

    with open(spec_path) as f:
        spec = json.load(f)

    # Build part lookup
    parts_by_name = {}
    for part in spec["parts"]:
        if "stlPath" in part:
            parts_by_name[part["name"]] = part

    checks = []
    for fit in spec.get("fitSpecs", []):
        name = fit["name"]
        fit_type = fit["type"]
        expected = fit["expected"]
        part_a_name = fit["partA"]
        part_b_name = fit["partB"]

        entry = {
            "name": name,
            "type": fit_type,
            "expected": expected,
            "partA": part_a_name,
            "partB": part_b_name,
        }

        if part_a_name not in parts_by_name or part_b_name not in parts_by_name:
            missing = [n for n in [part_a_name, part_b_name] if n not in parts_by_name]
            entry.update({"actual": None, "pass": False,
                          "error": f"Missing STL for: {', '.join(missing)}"})
            checks.append(entry)
            continue

        mesh_a = load_and_position(parts_by_name[part_a_name], project_root)
        mesh_b = load_and_position(parts_by_name[part_b_name], project_root)

        if fit_type == "clearance":
            actual = measure_clearance(mesh_a, mesh_b)
        elif fit_type == "interference":
            actual = measure_interference(mesh_a, mesh_b)
        else:
            entry.update({"actual": None, "pass": False, "error": f"Unknown type: {fit_type}"})
            checks.append(entry)
            continue

        entry["actual"] = actual

        if actual is None:
            entry["pass"] = False
            entry["error"] = "Measurement failed"
        else:
            min_val = expected.get("min", float("-inf"))
            max_val = expected.get("max", float("inf"))
            entry["pass"] = min_val <= actual <= max_val

        checks.append(entry)

    output = {"checks": checks}
    print(json.dumps(output))


if __name__ == "__main__":
    main()
