
extends RefCounted
## Layout constants plus the base world: sky, soil, three rivers falling from
## distant waterfalls, and the bridges over them.
## North is -Z. The player starts near SPAWN, looking north.

const P = preload("res://prims.gd")

const RIVER_X0 := [-58.0, -12.0, 42.0]
const RIVER_W := 6.0
const Z_NORTH := -108.0
const Z_SOUTH := 86.0
const MAP_HALF_X := 96.0

const SPAWN := Vector3(8, 0, 18)
const PAVILION := Vector3(24, 0, -14)
const MANSIONS := [Vector3(-35, 0, -45), Vector3(12, 0, -62), Vector3(76, 0, -40)]
const TENT := Vector3(-28, 0, -12)
const NOOK := Vector3(-38, 0, 24)
const PARK := Vector3(8, 0, 52)
const HORSE := Vector3(14, 0, 10)


static func river_x(i: int, z: float) -> float:
	var x0: float = RIVER_X0[i]
	return x0 + 7.0 * sin(z * 0.045 + i * 1.7)


static func near_river(x: float, z: float, margin: float = 0.0) -> bool:
	for i in 3:
		if absf(x - river_x(i, z)) < RIVER_W * 0.5 + margin:
			return true
	return false


## True when (x, z) is free of rivers and big structures (for trees, flowers).
static func is_clear(x: float, z: float, margin: float = 0.0) -> bool:
	if near_river(x, z, 4.0 + margin):
		return false
	var p := Vector3(x, 0, z)
	var spots := [[PAVILION, 12.0], [TENT, 9.0], [NOOK, 12.0], [PARK, 26.0], [SPAWN, 5.0], [HORSE, 5.0]]
	for s in spots:
		var r: float = s[1]
		if p.distance_to(s[0]) < r + margin:
			return false
	for m in MANSIONS:
		if p.distance_to(m) < 18.0 + margin:
			return false
	return true


static func build(root: Node3D) -> void:
	_environment(root)
	_ground(root)
	_rivers(root)
	_waterfalls(root)
	for i in 3:
		for z in [12.0, -30.0]:
			_bridge(root, Vector3(river_x(i, z), 0, z))
	_boundaries(root)


# --- Sky and light: soft and constant, no harsh sun, no night -----------------

static func _environment(root: Node3D) -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var psm := ProceduralSkyMaterial.new()
	psm.sky_top_color = Color(0.5, 0.74, 0.96)
	psm.sky_horizon_color = Color(0.97, 0.94, 0.86)
	psm.ground_horizon_color = Color(0.97, 0.94, 0.86)
	psm.ground_bottom_color = Color(0.92, 0.9, 0.82)
	psm.sun_angle_max = 0.0
	var sky := Sky.new()
	sky.sky_material = psm
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 1.1
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.glow_enabled = not OS.has_feature("mobile")
	env.glow_intensity = 0.35
	env.fog_enabled = true
	env.fog_light_color = Color(0.96, 0.93, 0.86)
	env.fog_density = 0.0022
	var we := WorldEnvironment.new()
	we.environment = env
	root.add_child(we)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-52, -30, 0)
	sun.light_color = Color(1.0, 0.96, 0.88)
	sun.light_energy = 1.0
	sun.shadow_enabled = not OS.has_feature("mobile")   # shadows are too heavy for most phones
	sun.directional_shadow_max_distance = 140.0
	root.add_child(sun)


# --- Soil: pale, musk-scented, with pearl and ruby pebbles -------------------

static func _ground(root: Node3D) -> void:
	var soil := P.mat(Color(0.93, 0.87, 0.75), 0.85, 0.0, 0.12, Color(1.0, 0.9, 0.7))
	var plane := PlaneMesh.new()
	plane.size = Vector2(2.0 * MAP_HALF_X + 4.0, 234.0)
	P.put(root, plane, soil, Vector3(0, 0, -11))
	var shape := BoxShape3D.new()
	shape.size = Vector3(2.0 * MAP_HALF_X + 4.0, 2.0, 234.0)
	P.add_solid(root, shape, Vector3(0, -1, -11))

	var rng := RandomNumberGenerator.new()
	rng.seed = 11

	# Soft green lawn patches so the ground is not one flat colour.
	var greens := [Color(0.45, 0.72, 0.36), Color(0.38, 0.66, 0.34), Color(0.55, 0.78, 0.42), Color(0.33, 0.6, 0.32)]
	var xf: Array = []
	var cols: Array = []
	var disc := SphereMesh.new()
	disc.radius = 1.0
	disc.height = 2.0
	disc.radial_segments = 12
	disc.rings = 4
	while xf.size() < 520:
		var x := rng.randf_range(-MAP_HALF_X + 4.0, MAP_HALF_X - 4.0)
		var z := rng.randf_range(Z_NORTH + 4.0, Z_SOUTH - 2.0)
		if near_river(x, z, 4.0):
			continue
		var s := rng.randf_range(3.0, 8.0)
		xf.append(Transform3D(Basis.from_scale(Vector3(s, 0.05, s * rng.randf_range(0.7, 1.3))), Vector3(x, 0.03, z)))
		cols.append(P.rng_color(rng, greens))
	P.scatter(root, disc, P.vertex_mat(0.9), xf, cols)

	# Pearl, ruby and gold pebbles.
	var pebbles := [Color(0.98, 0.97, 0.92), Color(0.98, 0.97, 0.92), Color(0.82, 0.1, 0.16), Color(0.9, 0.75, 0.3)]
	var pm := SphereMesh.new()
	pm.radius = 0.08
	pm.height = 0.16
	pm.radial_segments = 8
	pm.rings = 4
	xf = []
	cols = []
	while xf.size() < 700:
		var x := rng.randf_range(-MAP_HALF_X + 4.0, MAP_HALF_X - 4.0)
		var z := rng.randf_range(Z_NORTH + 4.0, Z_SOUTH - 2.0)
		if near_river(x, z, 2.0):
			continue
		xf.append(Transform3D(Basis(), Vector3(x, 0.06, z)))
		cols.append(P.rng_color(rng, pebbles))
	P.scatter(root, pm, P.vertex_mat(0.25), xf, cols)

	# Drifting golden motes: the musk fragrance.
	var motes := CPUParticles3D.new()
	motes.position = Vector3(0, 2.5, -11)
	motes.amount = 600
	motes.lifetime = 9.0
	motes.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	motes.emission_box_extents = Vector3(MAP_HALF_X, 2.5, 110.0)
	motes.gravity = Vector3(0, 0.12, 0)
	motes.initial_velocity_min = 0.1
	motes.initial_velocity_max = 0.4
	motes.direction = Vector3(1, 0.3, 0.2)
	motes.spread = 180.0
	var mm := SphereMesh.new()
	mm.radius = 0.05
	mm.height = 0.1
	mm.radial_segments = 6
	mm.rings = 3
	mm.material = P.mat(Color(1.0, 0.88, 0.5, 0.8), 0.5, 0.0, 2.0, Color(1.0, 0.85, 0.4))
	motes.mesh = mm
	root.add_child(motes)


# --- Rivers: water, milk and honey --------------------------------------------

static func _flow_mat(color: Color, speed: float, rough: float, uv_scale_y: float = 1.0) -> StandardMaterial3D:
	var m := P.mat(Color(color.r * 1.8, color.g * 1.8, color.b * 1.8, color.a), rough, 0.2)
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	var noise := FastNoiseLite.new()
	noise.frequency = 0.03
	var tex := NoiseTexture2D.new()
	tex.noise = noise
	tex.seamless = true
	tex.width = 256
	tex.height = 256
	m.albedo_texture = tex
	m.uv1_scale = Vector3(1, uv_scale_y, 1)
	m.set_meta("flow_speed", speed)
	P.flow_mats.append(m)
	return m


static func _river_mesh(i: int, z0: float, z1: float, width: float, y: float) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var z := z0
	while z < z1:
		var zn := minf(z + 2.0, z1)
		var xa := river_x(i, z)
		var xb := river_x(i, zn)
		var h := width * 0.5
		var v0 := Vector3(xa - h, y, z)
		var v1 := Vector3(xa + h, y, z)
		var v2 := Vector3(xb - h, y, zn)
		var v3 := Vector3(xb + h, y, zn)
		var t0 := z * 0.08
		var t1 := zn * 0.08
		var tris := [
			[v0, Vector2(0, t0)], [v1, Vector2(1, t0)], [v2, Vector2(0, t1)],
			[v1, Vector2(1, t0)], [v3, Vector2(1, t1)], [v2, Vector2(0, t1)],
		]
		for t in tris:
			st.set_normal(Vector3.UP)
			st.set_uv(t[1])
			st.add_vertex(t[0])
		z = zn
	return st.commit()


static func _rivers(root: Node3D) -> void:
	var colors := [Color(0.35, 0.62, 0.85, 0.8), Color(0.97, 0.97, 0.94, 0.96), Color(0.93, 0.62, 0.12, 0.9)]
	var names := ["River of Water", "River of Milk", "River of Honey"]
	var sand := P.mat(Color(0.9, 0.8, 0.58), 0.9)
	for i in 3:
		var node := Node3D.new()
		node.name = names[i]
		root.add_child(node)
		var bank := MeshInstance3D.new()
		bank.mesh = _river_mesh(i, Z_NORTH + 1.0, Z_SOUTH, RIVER_W + 1.8, 0.08)
		bank.material_override = sand
		node.add_child(bank)
		var water := MeshInstance3D.new()
		water.mesh = _river_mesh(i, Z_NORTH + 1.0, Z_SOUTH, RIVER_W, 0.16)
		water.material_override = _flow_mat(colors[i], -0.12, 0.08)
		node.add_child(water)


# --- Waterfalls at the far north: the rivers' source -------------------------

static func _waterfalls(root: Node3D) -> void:
	var rock := P.mat(Color(0.47, 0.41, 0.35), 0.95)
	var rock2 := P.mat(Color(0.58, 0.52, 0.44), 0.95)
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	P.box(root, Vector3(2.0 * MAP_HALF_X + 4.0, 46, 10), Vector3(0, 23, Z_NORTH - 6), rock, Vector3.ZERO, true)
	for k in 14:
		var w := rng.randf_range(10.0, 26.0)
		var h := rng.randf_range(4.0, 9.0)
		P.box(root, Vector3(w, h, 3.0), Vector3(rng.randf_range(-85, 85), rng.randf_range(4, 38), Z_NORTH - 0.2), rock2, Vector3.ZERO)

	var falls := [Color(0.5, 0.75, 0.95, 0.75), Color(0.98, 0.98, 0.96, 0.92), Color(0.95, 0.68, 0.2, 0.85)]
	for i in 3:
		var xr := river_x(i, Z_NORTH)
		P.box(root, Vector3(8, 44, 0.5), Vector3(xr, 22, Z_NORTH - 0.6), _flow_mat(falls[i], -0.9, 0.1, 5.0))
		for k in 9:
			var side := 1.0 if rng.randf() < 0.5 else -1.0
			P.ball(root, rng.randf_range(1.2, 2.8), Vector3(xr + side * rng.randf_range(5.5, 11.0), 0.7, Z_NORTH + rng.randf_range(-1.0, 3.0)), rock2, Vector3(1, 0.7, 1))
		_mist(root, Vector3(xr, 1.0, Z_NORTH + 1.0))


static func _mist(root: Node3D, pos: Vector3) -> void:
	var p := CPUParticles3D.new()
	p.position = pos
	p.amount = 50
	p.lifetime = 3.0
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	p.emission_sphere_radius = 4.0
	p.gravity = Vector3(0, 0.6, 0)
	p.initial_velocity_min = 0.2
	p.initial_velocity_max = 0.8
	p.scale_amount_min = 0.8
	p.scale_amount_max = 1.6
	var sm := SphereMesh.new()
	sm.radius = 1.2
	sm.height = 2.4
	sm.radial_segments = 8
	sm.rings = 4
	sm.material = P.mat(Color(1, 1, 1, 0.12), 1.0)
	p.mesh = sm
	root.add_child(p)


# --- Bridges: marble deck with gold rails, arched over the water -------------

static func _bridge(root: Node3D, pos: Vector3) -> void:
	var marble := P.mat(Color(0.96, 0.95, 0.9), 0.3)
	var gold := P.mat(Color(0.86, 0.69, 0.28), 0.25, 0.85)
	var bridge := Node3D.new()
	bridge.position = pos
	bridge.name = "Bridge"
	root.add_child(bridge)
	var rise := 1.35
	var run := 5.0
	var ang := rad_to_deg(atan2(rise, run))
	var ramp_len := sqrt(run * run + rise * rise)
	_bridge_segment(bridge, Vector3(0, rise, 0), 0.0, 8.0, marble, gold)
	_bridge_segment(bridge, Vector3(6.5, rise * 0.5, 0), -ang, ramp_len, marble, gold)
	_bridge_segment(bridge, Vector3(-6.5, rise * 0.5, 0), ang, ramp_len, marble, gold)


static func _bridge_segment(parent: Node3D, local_pos: Vector3, rot_z_deg: float, length: float, marble: Material, gold: Material) -> void:
	var seg := Node3D.new()
	seg.position = local_pos
	seg.rotation_degrees = Vector3(0, 0, rot_z_deg)
	parent.add_child(seg)
	P.box(seg, Vector3(length, 0.3, 3.2), Vector3.ZERO, marble, Vector3.ZERO, true)
	var posts := int(length / 1.6)
	for sz in [-1.5, 1.5]:
		P.box(seg, Vector3(length, 0.12, 0.12), Vector3(0, 0.95, sz), gold)
		for k in posts + 1:
			var px := -length * 0.5 + k * (length / posts)
			P.box(seg, Vector3(0.14, 0.95, 0.14), Vector3(px, 0.5, sz), gold)
		var rail_shape := BoxShape3D.new()
		rail_shape.size = Vector3(length, 1.2, 0.1)
		P.add_solid(seg, rail_shape, Vector3(0, 0.75, sz))


static func _boundaries(root: Node3D) -> void:
	var h := 60.0
	P.invisible_wall(root, Vector3(2, h, 260), Vector3(MAP_HALF_X + 1.0, h * 0.5, -11))
	P.invisible_wall(root, Vector3(2, h, 260), Vector3(-MAP_HALF_X - 1.0, h * 0.5, -11))
	P.invisible_wall(root, Vector3(2.0 * MAP_HALF_X + 4.0, h, 2), Vector3(0, h * 0.5, Z_SOUTH + 1.0))
