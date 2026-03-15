#!/usr/bin/env python3
"""Slicer-based analysis — uses PrusaSlicer CLI for ground-truth printability data.

Usage: python3 slicer_analyze.py <stl-path> [--profile <ini-path>] [--output report.json]

PrusaSlicer is the upstream engine used by OrcaSlicer and BambuStudio.
This script invokes it in headless CLI mode to:
  1. Slice the STL and export G-code
  2. Parse G-code for layer-by-layer data (support, bridges, retracts)
  3. Optionally export per-layer SVG cross-sections

Returns JSON on stdout (or to --output file):
  { "slicer": {...}, "layers": [...], "supports": {...}, "summary": {...} }
"""

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path


# Bambu X1C / PLA defaults
DEFAULT_PROFILE = {
    "layer_height": 0.2,
    "first_layer_height": 0.2,
    "nozzle_diameter": 0.4,
    "filament_diameter": 1.75,
    "temperature": 220,
    "bed_temperature": 60,
    "perimeters": 3,
    "fill_density": "15%",
    "support_material": 1,
    "support_material_auto": 1,
    "support_material_threshold": 45,
    "dont_support_bridges": 1,
    "bed_shape": "0x0,256x0,256x256,0x256",
    "max_print_height": 256,
}


def find_slicer():
    """Find a PrusaSlicer-compatible CLI binary."""
    candidates = [
        "prusa-slicer",
        "prusaslicer",
        "PrusaSlicer",
        "slic3r",
        "orca-slicer",
        "OrcaSlicer",
        "bambu-studio",
    ]
    for name in candidates:
        path = shutil.which(name)
        if path:
            return path

    # Check common install locations
    common_paths = [
        "/usr/bin/prusa-slicer",
        "/usr/local/bin/prusa-slicer",
        "/opt/PrusaSlicer/prusa-slicer",
        "/usr/bin/slic3r",
    ]
    for p in common_paths:
        if os.path.isfile(p) and os.access(p, os.X_OK):
            return p

    return None


def get_slicer_version(slicer_path):
    """Get slicer version string."""
    try:
        result = subprocess.run(
            [slicer_path, "--version"],
            capture_output=True, text=True, timeout=10
        )
        version = (result.stdout.strip() or result.stderr.strip()).split("\n")[0]
        return version
    except Exception:
        return "unknown"


def write_profile_ini(profile_dict, output_path):
    """Write a slicer profile as INI file."""
    lines = ["# Auto-generated profile for printability analysis"]
    for key, value in profile_dict.items():
        lines.append(f"{key} = {value}")
    Path(output_path).write_text("\n".join(lines))


def slice_to_gcode(slicer_path, stl_path, profile_path=None, output_dir=None):
    """Slice STL to G-code using PrusaSlicer CLI.

    Returns (gcode_path, stderr_output).
    """
    if output_dir is None:
        output_dir = tempfile.mkdtemp(prefix="slicer_")

    gcode_path = os.path.join(output_dir, Path(stl_path).stem + ".gcode")

    cmd = [slicer_path, "--export-gcode", "--output", gcode_path]

    if profile_path:
        cmd.extend(["--load", profile_path])

    cmd.append(str(stl_path))

    sys.stderr.write(f"Slicing: {' '.join(cmd)}\n")

    result = subprocess.run(
        cmd,
        capture_output=True, text=True, timeout=300
    )

    if result.returncode != 0:
        raise RuntimeError(
            f"Slicer failed (exit {result.returncode}):\n{result.stderr}"
        )

    return gcode_path, result.stderr


def slice_to_svg(slicer_path, stl_path, profile_path=None, output_dir=None):
    """Export per-layer SVG cross-sections.

    Returns (svg_dir, stderr_output).
    """
    if output_dir is None:
        output_dir = tempfile.mkdtemp(prefix="slicer_svg_")

    # PrusaSlicer exports SVGs to a directory named after the model
    cmd = [slicer_path, "--export-svg", "--output", output_dir]

    if profile_path:
        cmd.extend(["--load", profile_path])

    cmd.append(str(stl_path))

    sys.stderr.write(f"Exporting SVG layers: {' '.join(cmd)}\n")

    result = subprocess.run(
        cmd,
        capture_output=True, text=True, timeout=300
    )

    return output_dir, result.stderr


def parse_gcode(gcode_path):
    """Parse G-code for layer-by-layer analysis.

    Extracts:
      - Layer boundaries (Z moves)
      - Extrusion types (perimeter, infill, support, bridge)
      - Support material presence
      - Bridge moves
      - Total print time estimate
    """
    layers = []
    current_layer = None
    current_z = 0.0
    has_support = False
    bridge_count = 0
    total_extrusion = 0.0
    layer_num = -1

    # PrusaSlicer G-code comment patterns
    type_pattern = re.compile(r"^;TYPE:(.+)")
    layer_pattern = re.compile(r"^;LAYER_CHANGE")
    z_pattern = re.compile(r"^;Z:(\d+\.?\d*)")
    height_pattern = re.compile(r"^;HEIGHT:(\d+\.?\d*)")

    with open(gcode_path) as f:
        for line in f:
            line = line.rstrip()

            # Layer change marker
            m = layer_pattern.match(line)
            if m:
                if current_layer is not None:
                    layers.append(current_layer)
                layer_num += 1
                current_layer = {
                    "layer_num": layer_num,
                    "z_mm": current_z,
                    "height_mm": 0.0,
                    "types": set(),
                    "has_support": False,
                    "has_bridge": False,
                    "extrusion_mm": 0.0,
                }
                continue

            # Z height
            m = z_pattern.match(line)
            if m:
                current_z = float(m.group(1))
                if current_layer:
                    current_layer["z_mm"] = current_z
                continue

            # Layer height
            m = height_pattern.match(line)
            if m and current_layer:
                current_layer["height_mm"] = float(m.group(1))
                continue

            # Extrusion type
            m = type_pattern.match(line)
            if m and current_layer:
                extrusion_type = m.group(1).strip()
                current_layer["types"].add(extrusion_type)
                if "support" in extrusion_type.lower():
                    current_layer["has_support"] = True
                    has_support = True
                if "bridge" in extrusion_type.lower():
                    current_layer["has_bridge"] = True
                    bridge_count += 1
                continue

            # Track extrusion amount (E parameter in G1 moves)
            if line.startswith("G1") and "E" in line:
                e_match = re.search(r"E(\d+\.?\d*)", line)
                if e_match and current_layer:
                    current_layer["extrusion_mm"] += float(e_match.group(1))
                    total_extrusion += float(e_match.group(1))

    # Don't forget the last layer
    if current_layer is not None:
        layers.append(current_layer)

    # Convert sets to lists for JSON serialization
    for layer in layers:
        layer["types"] = sorted(list(layer["types"]))
        layer["extrusion_mm"] = round(layer["extrusion_mm"], 3)

    return {
        "layers": layers,
        "total_layers": len(layers),
        "has_support": has_support,
        "bridge_layer_count": bridge_count,
        "total_extrusion_mm": round(total_extrusion, 3),
    }


def build_report(stl_path, slicer_path, slicer_version, gcode_data, profile):
    """Build the final analysis report."""
    support_layers = [l for l in gcode_data["layers"] if l["has_support"]]
    bridge_layers = [l for l in gcode_data["layers"] if l["has_bridge"]]

    summary = {
        "total_layers": gcode_data["total_layers"],
        "needs_support": gcode_data["has_support"],
        "support_layer_count": len(support_layers),
        "bridge_layer_count": len(bridge_layers),
        "total_extrusion_mm": gcode_data["total_extrusion_mm"],
    }

    if support_layers:
        summary["support_z_range"] = {
            "min": support_layers[0]["z_mm"],
            "max": support_layers[-1]["z_mm"],
        }

    if bridge_layers:
        summary["bridge_z_values"] = [l["z_mm"] for l in bridge_layers]

    return {
        "stl_path": str(stl_path),
        "slicer": {
            "path": slicer_path,
            "version": slicer_version,
            "engine": "PrusaSlicer/Slic3r",
        },
        "profile": profile,
        "summary": summary,
        "layers": gcode_data["layers"],
    }


def main():
    parser = argparse.ArgumentParser(
        description="Slicer-based printability analysis using PrusaSlicer CLI"
    )
    parser.add_argument("stl_path", help="Path to STL file")
    parser.add_argument("--profile", help="Path to slicer profile INI file")
    parser.add_argument("--output", "-o", help="Output JSON file (default: stdout)")
    parser.add_argument("--export-svg", action="store_true",
                        help="Also export per-layer SVG files")
    parser.add_argument("--svg-dir", help="Directory for SVG output")
    parser.add_argument("--keep-gcode", action="store_true",
                        help="Keep generated G-code file")
    parser.add_argument("--gcode-dir", help="Directory for G-code output")
    args = parser.parse_args()

    stl_path = Path(args.stl_path)
    if not stl_path.exists():
        print(f"Error: STL file not found: {stl_path}", file=sys.stderr)
        sys.exit(1)

    # Find slicer
    slicer_path = find_slicer()
    if not slicer_path:
        print(json.dumps({
            "error": "No PrusaSlicer-compatible CLI found",
            "hint": "Install with: sudo apt-get install prusa-slicer",
            "searched": [
                "prusa-slicer", "prusaslicer", "PrusaSlicer",
                "slic3r", "orca-slicer", "OrcaSlicer",
            ],
        }))
        sys.exit(2)

    slicer_version = get_slicer_version(slicer_path)
    sys.stderr.write(f"Using slicer: {slicer_path} ({slicer_version})\n")

    # Profile
    profile_path = args.profile
    profile_used = {}
    if not profile_path:
        # Write default profile
        tmp_profile = tempfile.NamedTemporaryFile(
            suffix=".ini", prefix="profile_", delete=False, mode="w"
        )
        write_profile_ini(DEFAULT_PROFILE, tmp_profile.name)
        profile_path = tmp_profile.name
        profile_used = DEFAULT_PROFILE
        sys.stderr.write(f"Using default Bambu X1C/PLA profile\n")
    else:
        profile_used = {"file": profile_path}

    # Slice to G-code
    try:
        gcode_path, slicer_stderr = slice_to_gcode(
            slicer_path, stl_path, profile_path,
            output_dir=args.gcode_dir
        )
    except RuntimeError as e:
        print(json.dumps({"error": str(e)}))
        sys.exit(1)

    sys.stderr.write(f"G-code generated: {gcode_path}\n")

    # Parse G-code
    sys.stderr.write("Parsing G-code...\n")
    gcode_data = parse_gcode(gcode_path)
    sys.stderr.write(
        f"  {gcode_data['total_layers']} layers, "
        f"support: {gcode_data['has_support']}, "
        f"bridges: {gcode_data['bridge_layer_count']}\n"
    )

    # Optional SVG export
    if args.export_svg:
        svg_dir = args.svg_dir or tempfile.mkdtemp(prefix="slicer_svg_")
        try:
            slice_to_svg(slicer_path, stl_path, profile_path, svg_dir)
            sys.stderr.write(f"SVG layers exported to: {svg_dir}\n")
        except Exception as e:
            sys.stderr.write(f"SVG export failed (non-fatal): {e}\n")

    # Cleanup
    if not args.keep_gcode and not args.gcode_dir:
        os.unlink(gcode_path)

    # Build report
    report = build_report(stl_path, slicer_path, slicer_version, gcode_data, profile_used)
    output_json = json.dumps(report, indent=2)

    if args.output:
        Path(args.output).write_text(output_json)
        sys.stderr.write(f"Report written to {args.output}\n")
    else:
        print(output_json)

    # Exit code: 0 = no support needed, 1 = support needed
    sys.exit(0 if not gcode_data["has_support"] else 1)


if __name__ == "__main__":
    main()
