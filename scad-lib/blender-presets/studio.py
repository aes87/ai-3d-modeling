"""Default studio preset for hero renders.

Catalog-style lighting: light grey sweep, soft 2-light setup (key + fill, no
rim), Filmic tone mapping, slight-telephoto camera. Optimized to match the
ptouch-cradle assembly-hero look — clean product-photo feel, not CAD-render.

Subject material is a subtly warm neutral PLA. Override per-design by writing
`id/render-preset.py` with a `setup(scene, subject, args)`.
"""

import bpy
from math import radians


# Camera positions (relative to a normalized subject sitting on z=0, max dim = 1.0).
# Each is (location, target_z_factor) — target_z_factor multiplies subject.dimensions.z
# to set the look-at height (0.0 = bottom, 1.0 = top).
ANGLE_PRESETS = {
    "iso":                ((1.6, -1.6, 1.6),     0.5),
    "front":              ((0.0, -2.6, 0.5),     0.5),
    "back":               ((0.0,  2.6, 0.5),     0.5),
    "right":              ((2.6,  0.0, 0.5),     0.5),
    "left":               ((-2.6, 0.0, 0.5),     0.5),
    "top":                ((0.0,  0.0, 3.0),     0.5),
    "front-threequarter": ((1.6, -2.0, 1.0),     0.5),
    "rear-threequarter":  ((1.6,  2.0, 1.0),     0.5),
    "top-threequarter":   ((1.4, -1.8, 1.7),     0.5),
    "back-top-threequarter": ((-1.4, 1.8, 1.7),  0.5),  # 180° flip about Z of top-threequarter
    "threequarter":       ((1.6, -2.0, 1.0),     0.5),  # alias for front-threequarter
}


def setup(scene, subject, args):
    """Configure lighting, materials, camera, and world for a hero render.

    Args:
        scene: bpy.context.scene
        subject: imported STL object (centered, on z=0, normalized to max-dim=1.0)
        args: dict from harness — relevant keys: angle, quality, samples, resolution
    """
    angle = (args.get("angle") or "threequarter").lower()
    if angle not in ANGLE_PRESETS:
        print(f"[studio] unknown angle '{angle}', falling back to 'threequarter'. "
              f"Available: {sorted(ANGLE_PRESETS.keys())}")
        angle = "threequarter"

    cam_loc, target_z_factor = ANGLE_PRESETS[angle]

    # ---- World: bright neutral ambient (catalog-cyc feel) ----
    world = bpy.data.worlds["World"]
    world.use_nodes = True
    bg = world.node_tree.nodes["Background"]
    bg.inputs["Color"].default_value = (0.95, 0.95, 0.96, 1.0)
    bg.inputs["Strength"].default_value = 0.5

    # ---- Backdrop: large light-grey sweep ----
    bpy.ops.mesh.primitive_plane_add(size=12, location=(0, 0, -0.001))
    floor = bpy.context.active_object
    floor.name = "Backdrop"
    mat = bpy.data.materials.new(name="BackdropMat")
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (0.82, 0.82, 0.83, 1.0)
    bsdf.inputs["Roughness"].default_value = 0.85
    floor.data.materials.append(mat)

    # ---- Subject material: warm beige PLA ----
    # Mid-tone warm beige — saturated enough to read against the light grey
    # backdrop without going flat. Single-part hero renders need the part to
    # contrast the cyc, so we go a notch darker than the cradle's tray (0.74).
    # Roughness 0.65 + subtle subsurface mimics real matte PLA filament.
    pla = bpy.data.materials.new(name="PLA")
    pla.use_nodes = True
    pbsdf = pla.node_tree.nodes["Principled BSDF"]
    pbsdf.inputs["Base Color"].default_value = (0.68, 0.58, 0.42, 1.0)
    pbsdf.inputs["Roughness"].default_value = 0.65
    if "Subsurface Weight" in pbsdf.inputs:        # Blender 4.x
        pbsdf.inputs["Subsurface Weight"].default_value = 0.03
    elif "Subsurface" in pbsdf.inputs:             # Blender 3.x
        pbsdf.inputs["Subsurface"].default_value = 0.03
    if "Subsurface Color" in pbsdf.inputs:
        pbsdf.inputs["Subsurface Color"].default_value = (0.78, 0.68, 0.52, 1.0)
    subject.data.materials.clear()
    subject.data.materials.append(pla)

    # ---- Mesh cleanup: limited dissolve + auto-smooth (NO subsurf) ----
    # STLs are triangle soup. Limited dissolve collapses coplanar triangle pairs
    # into ngons (eliminates faint creases on flat faces under glancing light).
    # Auto-smooth at 30° preserves sharp edges (corners, fillet boundaries) and
    # smooths shallow-angle facet noise on curved surfaces.
    #
    # NOT using subdivision-surface modifier: Catmull-Clark would round every
    # corner, including the orthogonal walls and edges that should stay crisp.
    # Limited dissolve alone is enough to remove triangulation creases without
    # destroying the geometry.
    bpy.context.view_layer.objects.active = subject
    bpy.ops.object.select_all(action="DESELECT")
    subject.select_set(True)
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.mesh.dissolve_limited(angle_limit=radians(5))
    bpy.ops.object.mode_set(mode="OBJECT")
    bpy.ops.object.shade_smooth()
    if hasattr(bpy.ops.object, "shade_auto_smooth"):
        bpy.ops.object.shade_auto_smooth(angle=radians(30))
    elif hasattr(subject.data, "use_auto_smooth"):
        subject.data.use_auto_smooth = True
        subject.data.auto_smooth_angle = radians(30)

    # ---- Lighting: soft 2-light setup ----
    # Bright world handles ambient. Two large soft area lights add gentle
    # directional shaping. No rim — the light backdrop separates the subject
    # naturally.
    bpy.ops.object.light_add(type="AREA", location=(2.2, -1.6, 2.4))
    key = bpy.context.active_object
    key.name = "Key"
    key.data.energy = 60
    key.data.size = 3.5
    key.data.color = (1.0, 0.98, 0.95)
    key.rotation_euler = (radians(50), 0, radians(35))

    bpy.ops.object.light_add(type="AREA", location=(-1.8, -1.2, 1.8))
    fill = bpy.context.active_object
    fill.name = "Fill"
    fill.data.energy = 40
    fill.data.size = 4.5
    fill.data.color = (0.97, 0.98, 1.0)
    fill.rotation_euler = (radians(60), 0, radians(-30))

    # ---- Camera: slight telephoto, angle-driven ----
    bpy.ops.object.camera_add(location=cam_loc)
    cam = bpy.context.active_object
    cam.name = "HeroCam"
    cam.data.lens = 70  # slight telephoto — flatters the form, less perspective distortion
    cam.data.sensor_width = 36

    bbox_z = subject.dimensions.z
    target = bpy.data.objects.new("CamTarget", None)
    target.location = (0, 0, bbox_z * target_z_factor)
    bpy.context.collection.objects.link(target)
    constraint = cam.constraints.new(type="TRACK_TO")
    constraint.target = target
    constraint.track_axis = "TRACK_NEGATIVE_Z"
    constraint.up_axis = "UP_Y"
    scene.camera = cam
