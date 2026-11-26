extends RefCounted
## Fruit trees with endless shade, flower beds, the waterfall sitting nook
## (rock on three sides), and the winged horse.

const P = preload("res://prims.gd")
const Core = preload("res://world_core.gd")


static func build(root: Node3D) -> void:
	_trees(root)
	_flowers(root)
	_nook(root)
	_horse(root)


# Fruits named in the Quran: grapes, pomegranates, dates, figs, plus others.
static func _trees(root: Node3D) -> void:
	var trunk := P.mat(Color(0.4, 0.28, 0.18), 0.9)
	var leaf_cols := [Color(0.2, 0.55, 0.25), Color(0.25, 0.6, 0.28), Color(0.17, 0.5, 0.24)]
	var fruit_cols := [Color(0.85, 0.1, 0.15), Color(0.55, 0.15, 0.55), Color(0.98, 0.78, 0.15), Color(0.95, 0.5, 0.15), Color(0.6, 0.4, 0.2)]
	var rng := RandomNumberGenerator.new()
	rng.seed = 21
	var fruit_mesh := SphereMesh.new()
	fruit_mesh.radius = 0.16
	fruit_mesh.height = 0.32
	fruit_mesh.radial_segments = 8
	fruit_mesh.rings = 4
	var fx: Array = []
	var fc: Array = []
	var placed := 0
	var tries := 0
	while placed < 90 and tries < 2000:
		tries += 1
		var x := rng.randf_range(-Core.MAP_HALF_X + 6.0, Core.MAP_HALF_X - 6.0)
		var z := rng.randf_range(Core.Z_NORTH + 14.0, Core.Z_SOUTH - 4.0)
		if not Core.is_clear(x, z, 2.0):
			continue
		placed += 1
		var h := rng.randf_range(3.2, 5.0)
		var tree := Node3D.new()
		tree.position = Vector3(x, 0, z)
		root.add_child(tree)
		P.cyl(tree, 0.2, 0.32, h, Vector3(0, h * 0.5, 0), trunk, Vector3.ZERO, true, 10)
		var lm := P.mat(leaf_cols[rng.randi() % leaf_cols.size()], 0.85)
		var cr := rng.randf_range(2.2, 3.2)
		P.ball(tree, cr, Vector3(0, h + cr * 0.45, 0), lm, Vector3(1.0, 0.75, 1.0))
		P.ball(tree, cr * 0.7, Vector3(cr * 0.6, h + cr * 0.2, 0.3), lm, Vector3(1.0, 0.75, 1.0))
		P.ball(tree, cr * 0.7, Vector3(-cr * 0.55, h + cr * 0.15, -0.3), lm, Vector3(1.0, 0.75, 1.0))
		var fcol: Color = fruit_cols[rng.randi() % fruit_cols.size()]
		for k in 14:
			var a := rng.randf() * TAU
			var rr := rng.randf_range(cr * 0.5, cr * 0.95)
			var fy := h + rng.randf_range(-0.2, cr * 0.7)
			fx.append(Transform3D(Basis(), Vector3(x + cos(a) * rr, fy, z + sin(a) * rr)))
			fc.append(fcol)
	P.scatter(root, fruit_mesh, P.vertex_mat(0.4), fx, fc)


static func _flowers(root: Node3D) -> void:
	var palette := [
		Color(0.95, 0.35, 0.5), Color(0.99, 0.99, 0.95), Color(0.99, 0.85, 0.2),
		Color(0.7, 0.45, 0.9), Color(0.95, 0.5, 0.2), Color(0.35, 0.6, 0.95),
	]
	var mesh := SphereMesh.new()
	mesh.radius = 0.12
	mesh.height = 0.2
	mesh.radial_segments = 6
	mesh.rings = 3
	var rng := RandomNumberGenerator.new()
	rng.seed = 33
	var xf: Array = []
	var cols: Array = []
	var n := 0
	var tries := 0
	while n < 1500 and tries < 6000:
		tries += 1
		# Flowers cluster in beds so they read as gardens, not noise.
		var cx := rng.randf_range(-85.0, 85.0)
		var cz := rng.randf_range(Core.Z_NORTH + 10.0, Core.Z_SOUTH - 5.0)
		var col: Color = P.rng_color(rng, palette)
		for k in 14:
			var x := cx + rng.randf_range(-2.5, 2.5)
			var z := cz + rng.randf_range(-2.5, 2.5)
			if not Core.is_clear(x, z, -2.0):
				continue
			xf.append(Transform3D(Basis(), Vector3(x, rng.randf_range(0.25, 0.5), z)))
			cols.append(col)
			n += 1
	P.scatter(root, mesh, P.vertex_mat(0.6), xf, cols)

	# Thin green stems below the blooms.
	var stem := CylinderMesh.new()
	stem.top_radius = 0.015
	stem.bottom_radius = 0.02
	stem.height = 0.4
	stem.radial_segments = 4
	stem.rings = 1
	var sx: Array = []
	var sc: Array = []
	for t in xf:
		sx.append(Transform3D(Basis(), Vector3(t.origin.x, 0.2, t.origin.z)))
		sc.append(Color(0.25, 0.55, 0.25))
	P.scatter(root, stem, P.vertex_mat(0.9), sx, sc)


# --- The sitting nook: a small waterfall with rock on three sides ----------

static func _nook(root: Node3D) -> void:
	var node := Node3D.new()
	node.name = "WaterfallNook"
	node.position = Core.NOOK
	root.add_child(node)
	var rock := P.mat(Color(0.5, 0.44, 0.38), 0.95)
	var rock2 := P.mat(Color(0.6, 0.54, 0.46), 0.95)
	var rng := RandomNumberGenerator.new()
	rng.seed = 9

	# Back wall and two side walls: rock on three sides, open to the south.
	P.box(node, Vector3(12, 7, 2.5), Vector3(0, 3.5, -5.0), rock, Vector3.ZERO, true)
	P.box(node, Vector3(2.5, 6, 10), Vector3(-6.0, 3.0, 0.0), rock, Vector3.ZERO, true)
	P.box(node, Vector3(2.5, 6, 10), Vector3(6.0, 3.0, 0.0), rock, Vector3.ZERO, true)
	for k in 16:
		var a := rng.randf_range(-6.5, 6.5)
		var layer := rng.randi() % 3
		var pos := Vector3(a, rng.randf_range(0.5, 6.5), -3.8)
		if layer == 1:
			pos = Vector3(-4.8, rng.randf_range(0.5, 5.5), rng.randf_range(-4.0, 3.5))
		elif layer == 2:
			pos = Vector3(4.8, rng.randf_range(0.5, 5.5), rng.randf_range(-4.0, 3.5))
		P.ball(node, rng.randf_range(0.8, 1.7), pos, rock2, Vector3(1.0, 0.8, 1.0))

	# Small waterfall pouring down the back wall into a pool.
	var wf := P.mat(Color(0.75, 0.92, 1.0, 0.7), 0.1, 0.2, 0.3, Color(0.7, 0.9, 1.0))
	P.box(node, Vector3(2.2, 6.0, 0.25), Vector3(0, 3.1, -3.7), wf)
	P.cyl(node, 3.0, 3.0, 0.1, Vector3(0, 0.12, -2.0), P.mat(Color(0.4, 0.75, 0.95, 0.75), 0.05, 0.2), Vector3.ZERO, false, 32)
	var mist := CPUParticles3D.new()
	mist.position = Vector3(0, 0.6, -3.2)
	mist.amount = 30
	mist.lifetime = 2.5
	mist.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	mist.emission_sphere_radius = 1.4
	mist.gravity = Vector3(0, 0.5, 0)
	var mm := SphereMesh.new()
	mm.radius = 0.5
	mm.height = 1.0
	mm.radial_segments = 8
	mm.rings = 4
	mm.material = P.mat(Color(1, 1, 1, 0.12), 1.0)
	mist.mesh = mm
	node.add_child(mist)

	# Where you sit: a carpet, cushions and a low couch facing the fall.
	var silk := P.mat(Color(0.96, 0.9, 0.75), 0.4)
	var green := P.mat(Color(0.1, 0.4, 0.22), 0.5)
	var gold := P.mat(Color(0.86, 0.69, 0.28), 0.25, 0.85)
	P.box(node, Vector3(6.0, 0.06, 4.0), Vector3(0, 0.05, 1.8), green)
	P.box(node, Vector3(5.6, 0.07, 0.25), Vector3(0, 0.06, 3.6), gold)
	P.box(node, Vector3(3.6, 0.5, 1.2), Vector3(0, 0.3, 1.4), gold, Vector3.ZERO, true)
	P.box(node, Vector3(3.4, 0.25, 1.05), Vector3(0, 0.68, 1.4), silk)
	P.box(node, Vector3(3.4, 0.8, 0.2), Vector3(0, 1.0, 0.85), green)
	for sx in [-1.2, 0.0, 1.2]:
		P.ball(node, 0.28, Vector3(sx, 0.95, 1.4), silk if sx != 0.0 else green, Vector3(1.4, 0.7, 1.0))

	var l := OmniLight3D.new()
	l.position = Vector3(0, 3.0, 0.5)
	l.light_color = Color(0.9, 0.95, 1.0)
	l.light_energy = 0.6
	l.omni_range = 12.0
	node.add_child(l)


# --- The winged horse (the creator's own addition, not from the sources) ----

static func _horse(root: Node3D) -> void:
	var horse := Node3D.new()
	horse.name = "WingedHorse"
	horse.position = Core.HORSE
	horse.add_to_group("horse")
	root.add_child(horse)

	var coat := P.mat(Color(0.98, 0.97, 0.94), 0.45)
	var gold := P.mat(Color(0.86, 0.69, 0.28), 0.25, 0.85)
	var wing := P.mat(Color(1.0, 0.99, 0.95, 0.92), 0.4, 0.0, 0.25, Color(1.0, 0.95, 0.8))
	var body := Node3D.new()
	horse.add_child(body)
	body.position.y = 0.0

	P.cyl(body, 0.42, 0.45, 1.5, Vector3(0, 1.35, 0), coat, Vector3(90, 0, 0))
	P.ball(body, 0.46, Vector3(0, 1.38, 0.78), coat)
	P.ball(body, 0.46, Vector3(0, 1.4, -0.75), coat)
	P.cyl(body, 0.17, 0.3, 0.9, Vector3(0, 1.95, 0.95), coat, Vector3(-28, 0, 0))
	P.ball(body, 0.26, Vector3(0, 2.38, 1.2), coat, Vector3(0.9, 0.9, 1.35))
	P.box(body, Vector3(0.05, 0.9, 0.14), Vector3(0, 2.05, 0.75), gold, Vector3(-28, 0, 0))
	for sx in [-0.2, 0.2]:
		P.cyl(body, 0.06, 0.04, 0.3, Vector3(sx, 2.62, 1.12), coat)
		P.cyl(body, 0.12, 0.08, 0.95, Vector3(sx, 0.52, 0.62), coat)
		P.cyl(body, 0.12, 0.08, 0.95, Vector3(sx, 0.52, -0.62), coat)
		P.box(body, Vector3(0.18, 0.08, 0.18), Vector3(sx, 0.04, 0.62), gold)
		P.box(body, Vector3(0.18, 0.08, 0.18), Vector3(sx, 0.04, -0.62), gold)
	P.cyl(body, 0.14, 0.03, 0.9, Vector3(0, 1.1, -1.4), coat, Vector3(-35, 0, 0))
	# Saddle.
	P.box(body, Vector3(0.7, 0.12, 0.8), Vector3(0, 1.82, 0.05), P.mat(Color(0.1, 0.4, 0.22), 0.5))
	P.box(body, Vector3(0.72, 0.04, 0.82), Vector3(0, 1.78, 0.05), gold)

	# Two layered, flapping wings.
	for side in [-1.0, 1.0]:
		var w := Node3D.new()
		w.position = Vector3(side * 0.4, 1.75, 0.1)
		body.add_child(w)
		for k in 4:
			var feather_len := 1.9 - k * 0.2
			var f := P.box(w, Vector3(feather_len, 0.04, 0.5), Vector3(side * feather_len * 0.5, 0.0, -k * 0.3 + 0.2), wing, Vector3(0, side * (-10.0 - k * 6.0), 0))
			f.name = "Feather%d" % k
		P.animate(w, "flap", 3.0, 0.45 * side, 0.0 if side < 0 else 0.0)
