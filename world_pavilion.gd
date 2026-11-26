extends RefCounted
## The flower-roof pavilion: a marble platform, FIVE pillars (four at the
## corners plus a taller middle one), and a large canopy roof of many kinds of
## flowers, with petals drifting down. It stands at one place, not over the map.

const P = preload("res://prims.gd")
const Core = preload("res://world_core.gd")

const HALF := 8.0            # corner pillars sit at +-HALF
const PILLAR_H := 7.5
const MIDDLE_H := 10.0
const ROOF_Y := 8.0
const ROOF_FLAT := 0.22      # dome height as a fraction of its radius (low canopy)


static func build(root: Node3D) -> void:
	var node := Node3D.new()
	node.name = "FlowerPavilion"
	node.position = Core.PAVILION
	root.add_child(node)

	var marble := P.mat(Color(0.96, 0.95, 0.9), 0.3)
	var gold := P.mat(Color(0.86, 0.69, 0.28), 0.25, 0.85)
	var rng := RandomNumberGenerator.new()
	rng.seed = 77

	# Stepped marble platform with a gold inlay.
	P.cyl(node, 12.0, 12.6, 0.4, Vector3(0, 0.2, 0), marble, Vector3.ZERO, true, 48)
	P.cyl(node, 10.6, 11.0, 0.3, Vector3(0, 0.55, 0), marble, Vector3.ZERO, true, 48)
	P.cyl(node, 7.0, 7.0, 0.05, Vector3(0, 0.72, 0), gold, Vector3.ZERO, false, 48)
	P.cyl(node, 6.6, 6.6, 0.06, Vector3(0, 0.73, 0), marble, Vector3.ZERO, false, 48)

	# Five pillars: four corners and a taller one in the middle.
	var spots := [Vector3(-HALF, 0, -HALF), Vector3(HALF, 0, -HALF), Vector3(-HALF, 0, HALF), Vector3(HALF, 0, HALF)]
	for s in spots:
		_pillar(node, s, PILLAR_H, 0.6, marble, gold)
	_pillar(node, Vector3.ZERO, MIDDLE_H, 0.85, marble, gold)

	# Beams from the middle pillar out to each corner, holding up the roof.
	for s in spots:
		var from := Vector3(0, MIDDLE_H - 0.6, 0)
		var to := Vector3(s.x, PILLAR_H - 0.1, s.z)
		_beam(node, from, to, gold)
	# Ring beam joining the four corner pillars.
	_ring(node, spots, gold)

	_roof(node, rng)
	_petals(node)
	_seating(node)
	_lamp(node)


static func _pillar(parent: Node3D, pos: Vector3, h: float, r: float, marble: Material, gold: Material) -> void:
	P.cyl(parent, r * 1.5, r * 1.6, 0.45, Vector3(pos.x, 0.95, pos.z), marble)
	P.cyl(parent, r * 0.88, r, h, Vector3(pos.x, 0.7 + h * 0.5, pos.z), marble, Vector3.ZERO, true)
	for k in 3:
		P.cyl(parent, r * 1.02, r * 1.02, 0.1, Vector3(pos.x, 1.6 + k * (h - 1.8) * 0.5, pos.z), gold)
	P.cyl(parent, r * 1.5, r * 0.9, 0.5, Vector3(pos.x, 0.7 + h, pos.z), gold)


static func _beam(parent: Node3D, a: Vector3, b: Vector3, mat: Material) -> void:
	var mid := (a + b) * 0.5
	var d := b - a
	var m := P.box(parent, Vector3(0.3, 0.3, d.length()), mid, mat)
	m.transform = Transform3D(Basis.looking_at(d.normalized(), Vector3.UP), mid)


static func _ring(parent: Node3D, spots: Array, mat: Material) -> void:
	var y := PILLAR_H + 0.7
	var pairs := [[0, 1], [1, 3], [3, 2], [2, 0]]
	for p in pairs:
		var a: Vector3 = spots[p[0]]
		var b: Vector3 = spots[p[1]]
		var mid := (a + b) * 0.5
		var along_x := absf(a.z - b.z) < 0.1
		var size := Vector3(absf(a.x - b.x) + 0.6, 0.3, 0.3) if along_x else Vector3(0.3, 0.3, absf(a.z - b.z) + 0.6)
		P.box(parent, size, Vector3(mid.x, y, mid.z), mat)


# --- The canopy: a shallow dome whose surface is covered in flowers ---------

static func _roof(parent: Node3D, rng: RandomNumberGenerator) -> void:
	var leaf := P.mat(Color(0.2, 0.5, 0.25), 0.8)
	leaf.cull_mode = BaseMaterial3D.CULL_DISABLED   # visible from underneath too
	# Leafy base so no sky shows through the flowers.
	var base := P.dome(parent, 14.0, Vector3(0, ROOF_Y, 0), leaf)
	base.scale = Vector3(1.0, ROOF_FLAT, 1.0)
	# Short gold struts carry the canopy from each corner pillar.
	var strut := P.mat(Color(0.86, 0.69, 0.28), 0.25, 0.85)
	for sx in [-HALF, HALF]:
		for sz in [-HALF, HALF]:
			P.cyl(parent, 0.22, 0.3, 1.9, Vector3(sx, 0.7 + PILLAR_H + 1.0, sz), strut)
	P.cyl(parent, 0.4, 0.5, 0.5, Vector3(0, 0.7 + MIDDLE_H + 0.1, 0), strut)

	var palette := [
		Color(0.95, 0.35, 0.5), Color(0.98, 0.7, 0.8), Color(0.99, 0.99, 0.95),
		Color(0.99, 0.85, 0.2), Color(0.7, 0.45, 0.9), Color(0.95, 0.5, 0.2),
		Color(0.35, 0.6, 0.95), Color(0.85, 0.15, 0.25), Color(0.6, 0.85, 0.55),
	]
	var bloom := SphereMesh.new()
	bloom.radius = 0.38
	bloom.height = 0.5
	bloom.radial_segments = 8
	bloom.rings = 4
	var xf: Array = []
	var cols: Array = []
	var n := 0
	while n < 1800:
		var az := rng.randf() * TAU
		var el := acos(rng.randf())            # 0 = straight up
		if el > 1.5:
			continue
		var dir := Vector3(sin(el) * cos(az), cos(el) * ROOF_FLAT, sin(el) * sin(az))
		var s := rng.randf_range(0.7, 1.5)
		var col: Color = P.rng_color(rng, palette)
		# One bloom on top and one underneath, so the roof is full of flowers
		# whether you look at it from outside or stand beneath it.
		for r in [14.25, 13.7]:
			var p: Vector3 = Vector3(0, ROOF_Y, 0) + dir * r
			xf.append(Transform3D(Basis.from_scale(Vector3(s, s * 0.7, s)), p))
			cols.append(col)
		n += 1
	P.scatter(parent, bloom, P.vertex_mat(0.6), xf, cols)

	# Hanging garlands at the roof rim and long hanging blossoms over the seats.
	var strand := SphereMesh.new()
	strand.radius = 0.22
	strand.height = 0.44
	strand.radial_segments = 6
	strand.rings = 3
	xf = []
	cols = []
	for k in 36:
		var ang := k * TAU / 36.0
		var rim := Vector3(cos(ang) * 13.2, ROOF_Y - 0.4, sin(ang) * 13.2)
		var strand_len := rng.randi_range(3, 6)
		for j in strand_len:
			xf.append(Transform3D(Basis(), rim + Vector3(0, -j * 0.55, 0)))
			cols.append(P.rng_color(rng, palette))
	P.scatter(parent, strand, P.vertex_mat(0.6), xf, cols)


static func _petals(parent: Node3D) -> void:
	var p := CPUParticles3D.new()
	p.position = Vector3(0, ROOF_Y - 0.5, 0)
	p.amount = 140
	p.lifetime = 8.0
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	p.emission_sphere_radius = 9.0
	p.gravity = Vector3(0, -0.5, 0)
	p.initial_velocity_min = 0.1
	p.initial_velocity_max = 0.5
	p.spread = 180.0
	p.angular_velocity_min = -90.0
	p.angular_velocity_max = 90.0
	var q := QuadMesh.new()
	q.size = Vector2(0.18, 0.18)
	var m := P.mat(Color(1.0, 0.8, 0.88), 0.7, 0.0, 0.6, Color(1.0, 0.75, 0.85))
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	m.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	q.material = m
	p.mesh = q
	parent.add_child(p)


static func _seating(parent: Node3D) -> void:
	var silk := P.mat(Color(0.96, 0.9, 0.75), 0.4)
	var green := P.mat(Color(0.1, 0.4, 0.22), 0.5)
	var gold := P.mat(Color(0.86, 0.69, 0.28), 0.25, 0.85)
	# Raised couches in a ring around the middle pillar.
	for k in 4:
		var ang := k * TAU / 4.0 + PI / 4.0
		var c := Node3D.new()
		c.position = Vector3(cos(ang) * 4.2, 0.75, sin(ang) * 4.2)
		c.rotation.y = -ang + PI / 2.0
		parent.add_child(c)
		P.box(c, Vector3(3.0, 0.5, 1.2), Vector3(0, 0.25, 0), gold, Vector3.ZERO, true)
		P.box(c, Vector3(2.8, 0.25, 1.05), Vector3(0, 0.62, 0), silk)
		P.box(c, Vector3(2.8, 0.7, 0.2), Vector3(0, 0.95, -0.5), green)
		P.ball(c, 0.28, Vector3(-0.9, 0.9, 0.1), green, Vector3(1.4, 0.7, 1.0))
		P.ball(c, 0.28, Vector3(0.9, 0.9, 0.1), silk, Vector3(1.4, 0.7, 1.0))


static func _lamp(parent: Node3D) -> void:
	var l := OmniLight3D.new()
	l.position = Vector3(0, 5.5, 0)
	l.light_color = Color(1.0, 0.92, 0.75)
	l.light_energy = 1.3
	l.omni_range = 24.0
	parent.add_child(l)
