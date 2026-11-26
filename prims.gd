extends RefCounted
## Small helpers for building the whole game from primitive shapes, so the
## prototype needs no imported assets. Replace these with real models later.

## Materials whose UV is scrolled every frame (rivers, waterfalls).
static var flow_mats: Array = []


static func mat(color: Color, rough: float = 0.6, metal: float = 0.0, emit: float = 0.0, emit_color: Color = Color.BLACK) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = rough
	m.metallic = metal
	if color.a < 1.0:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if emit > 0.0:
		m.emission_enabled = true
		m.emission = emit_color if emit_color != Color.BLACK else color
		m.emission_energy_multiplier = emit
	return m


static func put(parent: Node, mesh: Mesh, material: Material, pos: Vector3, rot_deg: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = material
	mi.position = pos
	mi.rotation_degrees = rot_deg
	parent.add_child(mi)
	return mi


static func add_solid(parent: Node3D, shape: Shape3D, pos: Vector3, rot_deg: Vector3 = Vector3.ZERO) -> StaticBody3D:
	var body := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	cs.shape = shape
	body.add_child(cs)
	body.position = pos
	body.rotation_degrees = rot_deg
	parent.add_child(body)
	return body


static func box(parent: Node3D, size: Vector3, pos: Vector3, material: Material, rot_deg: Vector3 = Vector3.ZERO, solid: bool = false) -> MeshInstance3D:
	var bm := BoxMesh.new()
	bm.size = size
	var mi := put(parent, bm, material, pos, rot_deg)
	if solid:
		var shape := BoxShape3D.new()
		shape.size = size
		add_solid(parent, shape, pos, rot_deg)
	return mi


static func cyl(parent: Node3D, r_top: float, r_bottom: float, h: float, pos: Vector3, material: Material, rot_deg: Vector3 = Vector3.ZERO, solid: bool = false, segs: int = 24) -> MeshInstance3D:
	var cm := CylinderMesh.new()
	cm.top_radius = r_top
	cm.bottom_radius = r_bottom
	cm.height = h
	cm.radial_segments = segs
	cm.rings = 1
	var mi := put(parent, cm, material, pos, rot_deg)
	if solid:
		var shape := CylinderShape3D.new()
		shape.radius = maxf(r_top, r_bottom)
		shape.height = h
		add_solid(parent, shape, pos, rot_deg)
	return mi


static func ball(parent: Node3D, radius: float, pos: Vector3, material: Material, squash: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var sm := SphereMesh.new()
	sm.radius = radius
	sm.height = radius * 2.0
	sm.radial_segments = 16
	sm.rings = 8
	var mi := put(parent, sm, material, pos)
	mi.scale = squash
	return mi


static func dome(parent: Node3D, radius: float, pos: Vector3, material: Material) -> MeshInstance3D:
	var sm := SphereMesh.new()
	sm.radius = radius
	sm.height = radius
	sm.is_hemisphere = true
	sm.radial_segments = 32
	sm.rings = 16
	return put(parent, sm, material, pos)


static func invisible_wall(parent: Node3D, size: Vector3, pos: Vector3) -> void:
	var shape := BoxShape3D.new()
	shape.size = size
	add_solid(parent, shape, pos)


## Tag a node so main.gd animates it every frame.
## kind: "spin" (rotate around Y), "swing" (rock on X), "seesaw" (rock on Z),
## "flap" (wing flap on Z), "orbit" (walk in a slow circle)
static func animate(node: Node3D, kind: String, speed: float = 1.0, amount: float = 0.0, phase: float = 0.0) -> void:
	node.add_to_group("anim")
	node.set_meta("kind", kind)
	node.set_meta("speed", speed)
	node.set_meta("amount", amount)
	node.set_meta("phase", phase)
	node.set_meta("base_pos", node.position)
	node.set_meta("base_rot", node.rotation)


static func rng_color(rng: RandomNumberGenerator, palette: Array) -> Color:
	return palette[rng.randi() % palette.size()]


## Material that takes its colour from each MultiMesh instance.
static func vertex_mat(rough: float = 0.7) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.vertex_color_use_as_albedo = true
	m.roughness = rough
	return m


## Draw many copies of one mesh in a single draw call (flowers, fruit, pebbles).
static func scatter(parent: Node3D, mesh: Mesh, material: Material, xforms: Array, colors: Array) -> MultiMeshInstance3D:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.mesh = mesh
	mm.instance_count = xforms.size()
	for k in xforms.size():
		mm.set_instance_transform(k, xforms[k])
		mm.set_instance_color(k, colors[k])
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	mmi.material_override = material
	parent.add_child(mmi)
	return mmi
