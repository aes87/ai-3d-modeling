#!/usr/bin/env python3
"""Interference checker — detects mesh overlaps between assembly parts.

Usage: python3 interference.py <assembly-spec.json>

Reads the assembly spec, loads/positions STL meshes, and checks each
interference pair for mesh intersection volume.

Returns JSON on stdout:
  { "checks": [{ "partA", "partB", "intersects", "volume", "maxVolume", "pass" }] }
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


def check_intersection(mesh_a, mesh_b, max_volume):
    """Check intersection between two meshes.

    Uses manifold3d boolean engine via trimesh. Falls back to collision
    detection if boolean ops fail.
    """
    result = {
        "intersects": False,
        "volume": 0.0,
        "maxVolume": max_volume,
        "pass": True,
    }

    try:
        # Try boolean intersection with manifold engine
        intersection = trimesh.boolean.intersection([mesh_a, mesh_b], engine="manifold")

        if intersection is not None and not intersection.is_empty:
            vol = abs(intersection.volume)
            result["volume"] = round(vol, 4)
            result["intersects"] = vol > 0.001  # ignore sub-micron noise
    except Exception as e:
        # Fallback: collision detection (no volume, just bool)
        sys.stderr.write(f"Boolean intersection failed ({e}), falling back to collision check\n")
        try:
            manager = trimesh.collision.CollisionManager()
            manager.add_object("a", mesh_a)
            is_collision, _names = manager.in_collision_single(mesh_b, return_names=True)
            result["intersects"] = is_collision
            result["volume"] = -1  # unknown volume
        except Exception as e2:
            sys.stderr.write(f"Collision check also failed: {e2}\n")
            result["intersects"] = None
            result["volume"] = -1
            result["pass"] = False
            result["error"] = str(e2)
            return result

    # Evaluate pass/fail
    if result["intersects"] and result["volume"] > max_volume:
        result["pass"] = False

    return result


def main():
    if len(sys.argv) < 2:
        print("Usage: interference.py <assembly-spec.json>", file=sys.stderr)
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

    # Run interference checks
    checks = []
    for check in spec.get("checks", {}).get("interference", []):
        part_a_name = check["partA"]
        part_b_name = check["partB"]
        max_vol = check.get("maxVolume", 0.0)

        entry = {
            "partA": part_a_name,
            "partB": part_b_name,
        }

        if part_a_name not in parts_by_name or part_b_name not in parts_by_name:
            missing = [n for n in [part_a_name, part_b_name] if n not in parts_by_name]
            entry.update({"intersects": None, "volume": -1, "maxVolume": max_vol,
                          "pass": False, "error": f"Missing STL for: {', '.join(missing)}"})
            checks.append(entry)
            continue

        mesh_a = load_and_position(parts_by_name[part_a_name], project_root)
        mesh_b = load_and_position(parts_by_name[part_b_name], project_root)

        result = check_intersection(mesh_a, mesh_b, max_vol)
        entry.update(result)
        checks.append(entry)

    output = {"checks": checks}
    print(json.dumps(output))


if __name__ == "__main__":
    main()
