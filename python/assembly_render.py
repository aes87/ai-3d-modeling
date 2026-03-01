#!/usr/bin/env python3
"""Assembly visualization — renders multi-part scenes with PyVista.

Usage: python3 assembly_render.py <assembly-spec.json> [project-root] [output-dir]

Renders assembly views: isometric, exploded (parts spread on Z), cross-section (clip at Y=0).
Reference parts are rendered with 30% opacity.

Returns JSON on stdout:
  { "views": [{ "name", "path" }] }
"""

import json
import sys
from pathlib import Path

import pyvista as pv
import trimesh


# Part colors (distinct, colorblind-friendly)
PART_COLORS = [
    "#2196F3",  # blue
    "#4CAF50",  # green
    "#FF9800",  # orange
    "#9C27B0",  # purple
    "#F44336",  # red
    "#00BCD4",  # cyan
]

REFERENCE_COLOR = "#9E9E9E"  # gray for reference parts
REFERENCE_OPACITY = 0.3
PART_OPACITY = 0.85
BACKGROUND = "#1e1e1e"


def load_mesh(part, project_root):
    """Load mesh via trimesh, position it, return as PyVista PolyData."""
    stl_path = project_root / part["stlPath"]
    mesh = trimesh.load(str(stl_path), force="mesh")

    pos = part.get("position", [0, 0, 0])
    if any(p != 0 for p in pos):
        mesh.apply_translation(pos)

    # Convert trimesh → PyVista
    faces = mesh.faces
    n_faces = len(faces)
    pv_faces = []
    for face in faces:
        pv_faces.extend([3, face[0], face[1], face[2]])

    return pv.PolyData(mesh.vertices, pv_faces)


def render_view(plotter, filepath, camera_position=None):
    """Render current plotter to file."""
    if camera_position:
        plotter.camera_position = camera_position
    else:
        plotter.reset_camera()
        plotter.view_isometric()

    plotter.screenshot(str(filepath))


def main():
    if len(sys.argv) < 2:
        print("Usage: assembly_render.py <assembly-spec.json> [project-root] [output-dir]",
              file=sys.stderr)
        sys.exit(2)

    spec_path = Path(sys.argv[1])
    project_root = Path(sys.argv[2]) if len(sys.argv) > 2 else Path.cwd()
    output_dir = Path(sys.argv[3]) if len(sys.argv) > 3 else project_root / "assemblies" / "output"
    output_dir.mkdir(parents=True, exist_ok=True)

    with open(spec_path) as f:
        spec = json.load(f)

    name = spec["name"]

    # Start Xvfb for headless rendering
    pv.start_xvfb()

    # Load all meshes
    meshes = []
    for i, part in enumerate(spec["parts"]):
        if "stlPath" not in part:
            continue
        try:
            mesh = load_mesh(part, project_root)
            is_ref = part.get("reference", False)
            color = REFERENCE_COLOR if is_ref else PART_COLORS[i % len(PART_COLORS)]
            opacity = REFERENCE_OPACITY if is_ref else PART_OPACITY
            meshes.append({
                "mesh": mesh,
                "name": part["name"],
                "color": color,
                "opacity": opacity,
                "is_ref": is_ref,
                "position": part.get("position", [0, 0, 0]),
            })
        except Exception as e:
            sys.stderr.write(f"Failed to load {part['name']}: {e}\n")

    if not meshes:
        print(json.dumps({"views": [], "error": "No meshes loaded"}))
        sys.exit(1)

    views = []

    # --- View 1: Isometric assembly ---
    p = pv.Plotter(off_screen=True, window_size=[1200, 900])
    p.set_background(BACKGROUND)
    for m in meshes:
        p.add_mesh(m["mesh"], color=m["color"], opacity=m["opacity"],
                   label=m["name"], smooth_shading=True)
    p.add_legend(bcolor=(0.12, 0.12, 0.12, 0.8))

    iso_path = output_dir / f"{name}-assembly-iso.png"
    p.view_isometric()
    p.reset_camera()
    p.screenshot(str(iso_path))
    p.close()
    views.append({"name": "assembly-iso", "path": str(iso_path)})

    # --- View 2: Exploded (parts spread along Z) ---
    p = pv.Plotter(off_screen=True, window_size=[1200, 900])
    p.set_background(BACKGROUND)

    # Calculate Z spread: space parts 40mm apart beyond their natural positions
    z_spread = 40.0
    for i, m in enumerate(meshes):
        mesh_copy = m["mesh"].copy()
        mesh_copy.translate([0, 0, i * z_spread], inplace=True)
        p.add_mesh(mesh_copy, color=m["color"], opacity=m["opacity"],
                   label=m["name"], smooth_shading=True)
    p.add_legend(bcolor=(0.12, 0.12, 0.12, 0.8))

    exploded_path = output_dir / f"{name}-assembly-exploded.png"
    p.view_isometric()
    p.reset_camera()
    p.screenshot(str(exploded_path))
    p.close()
    views.append({"name": "assembly-exploded", "path": str(exploded_path)})

    # --- View 3: Cross-section (clip at Y=0) ---
    p = pv.Plotter(off_screen=True, window_size=[1200, 900])
    p.set_background(BACKGROUND)

    for m in meshes:
        try:
            clipped = m["mesh"].clip(normal="y", origin=(0, 0, 0))
            if clipped.n_points > 0:
                p.add_mesh(clipped, color=m["color"], opacity=m["opacity"],
                           label=m["name"], smooth_shading=True)
        except Exception:
            # If clipping fails, show full mesh
            p.add_mesh(m["mesh"], color=m["color"], opacity=m["opacity"],
                       label=m["name"], smooth_shading=True)
    p.add_legend(bcolor=(0.12, 0.12, 0.12, 0.8))

    section_path = output_dir / f"{name}-assembly-section.png"
    p.view_xz()
    p.reset_camera()
    p.screenshot(str(section_path))
    p.close()
    views.append({"name": "assembly-section", "path": str(section_path)})

    output = {"views": views}
    print(json.dumps(output))


if __name__ == "__main__":
    main()
