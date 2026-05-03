"""Default studio preset for hero renders.

Three-point lighting on a neutral grey sweep, neutral PLA filament BSDF.
Camera angle is selectable via args["angle"].

Override per-design by writing `id/render-preset.py` with a `setup(scene, subject, args)`.
"""

import bpy
from math import radians, cos, sin, pi


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

    # ---- World: dark ambient (silhouettes the subject against the upper background) ----
    world = bpy.data.worlds["World"]
    world.use_nodes = True
    bg = world.node_tree.nodes["Background"]
    bg.inputs["Color"].default_value = (0.04, 0.04, 0.05, 1.0)
    bg.inputs["Strength"].default_value = 0.3

    # ---- Backdrop: small dark platform — the dark world fills the rest of the frame ----
    bpy.ops.mesh.primitive_plane_add(size=4, location=(0, 0, -0.001))
    floor = bpy.context.active_object
    floor.name = "Backdrop"
    mat = bpy.data.materials.new(name="BackdropMat")
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (0.05, 0.05, 0.06, 1.0)
    bsdf.inputs["Roughness"].default_value = 0.4  # semi-glossy: picks up subject reflection, stays dark elsewhere
    floor.data.materials.append(mat)

    # ---- Subject material: PLA filament ----
    pla = bpy.data.materials.new(name="PLA")
    pla.use_nodes = True
    pbsdf = pla.node_tree.nodes["Principled BSDF"]
    pbsdf.inputs["Base Color"].default_value = (0.78, 0.78, 0.80, 1.0)
    pbsdf.inputs["Roughness"].default_value = 0.55
    # Subtle subsurface — PLA has slight translucency
    if "Subsurface Weight" in pbsdf.inputs:        # Blender 4.x
        pbsdf.inputs["Subsurface Weight"].default_value = 0.04
    elif "Subsurface" in pbsdf.inputs:             # Blender 3.x
        pbsdf.inputs["Subsurface"].default_value = 0.04
    if "Subsurface Color" in pbsdf.inputs:
        pbsdf.inputs["Subsurface Color"].default_value = (0.85, 0.85, 0.87, 1.0)
    subject.data.materials.clear()
    subject.data.materials.append(pla)
    # Auto-smooth: smooth shading on edges < 30°, flat for sharper transitions.
    if hasattr(subject.data, "use_auto_smooth"):
        subject.data.use_auto_smooth = True
        subject.data.auto_smooth_angle = radians(30)
    for poly in subject.data.polygons:
        poly.use_smooth = True

    # ---- Lighting: three-point setup, scaled for normalized subject ----
    bbox_z = subject.dimensions.z

    bpy.ops.object.light_add(type="AREA", location=(2.2, -1.6, 2.8))
    key = bpy.context.active_object
    key.name = "Key"
    key.data.energy = 150
    key.data.size = 1.5
    key.data.color = (1.0, 0.95, 0.88)
    key.rotation_euler = (radians(45), 0, radians(35))

    bpy.ops.object.light_add(type="AREA", location=(-1.8, -1.4, 1.6))
    fill = bpy.context.active_object
    fill.name = "Fill"
    fill.data.energy = 50
    fill.data.size = 2.0
    fill.data.color = (0.85, 0.92, 1.0)
    fill.rotation_euler = (radians(60), 0, radians(-30))

    # Rim is significantly brighter than fill — it carves a bright edge on the
    # back-top of the subject, separating it from the dark backdrop.
    bpy.ops.object.light_add(type="AREA", location=(0, 1.4, 2.0))
    rim = bpy.context.active_object
    rim.name = "Rim"
    rim.data.energy = 200
    rim.data.size = 0.8
    rim.data.color = (1.0, 1.0, 1.0)
    rim.rotation_euler = (radians(-50), 0, 0)

    # ---- Camera: angle-driven ----
    bpy.ops.object.camera_add(location=cam_loc)
    cam = bpy.context.active_object
    cam.name = "HeroCam"
    cam.data.lens = 50  # standard
    cam.data.sensor_width = 36

    target = bpy.data.objects.new("CamTarget", None)
    target.location = (0, 0, bbox_z * target_z_factor)
    bpy.context.collection.objects.link(target)
    constraint = cam.constraints.new(type="TRACK_TO")
    constraint.target = target
    constraint.track_axis = "TRACK_NEGATIVE_Z"
    constraint.up_axis = "UP_Y"
    scene.camera = cam
