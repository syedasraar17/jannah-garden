extends RefCounted
## A gentle fun park: swings, slides, merry-go-round, seesaws, Ferris wheel,
## sandbox, climbing frame, spring riders, monkey bars. No scores, no timers.
## Everything animated is tagged through P.animate and driven in main.gd.

const P = preload("res://prims.gd")
const Core = preload("res://world_core.gd")

static func build(root: Node3D) -> void:
	var park := Node3D.new()
	park.name = "FunPark"
	park.position = Core.PARK
	root.add_child(park)
	var rng := RandomNumberGenerator.new()
	rng.seed = 4

	# Soft green ground and a gold-bordered path ring.
	P.cyl(park, 24.0, 24.0, 0.12, Vector3(0, 0.06, 0), P.mat(Color(0.5, 0.78, 0.4), 0.95), Vector3.ZERO, false, 48)
	P.cyl(park, 8.0, 8.0, 0.14, Vector3(0, 0.07, 0), P.mat(Color(0.96, 0.92, 0.82), 0.9), Vector3.ZERO, false, 48)

	_ferris_wheel(park, Vector3(0, 0, -15))
	_merry_go_round(park, Vector3(0, 0, 0))
	_swings(park, Vector3(-16, 0, -4))
	_slide(park, Vector3(15, 0, -3), 0.0)
	_slide(park, Vector3(15, 0, 6), 180.0)
	_seesaw(park, Vector3(-14, 0, 9), 0.0)
	_seesaw(park, Vector3(-14, 0, 13), 0.0)
	_sandbox(park, Vector3(14, 0, 15))
	_climbing_frame(park, Vector3(-3, 0, 17))
	_spring_riders(park, Vector3(7, 0, 17))
	_monkey_bars(park, Vector3(-18, 0, 4))
	_benches(park)

	var l := OmniLight3D.new()
	l.position = Vector3(0, 9, 0)
	l.light_energy = 0.5
	l.omni_range = 28.0
	park.add_child(l)


static func _c(i: int) -> Material:
	var cols := [Color(0.95, 0.35, 0.4), Color(0.98, 0.8, 0.2), Color(0.3, 0.65, 0.95), Color(0.45, 0.8, 0.4), Color(0.8, 0.5, 0.9)]
	return P.mat(cols[i % cols.size()], 0.5)


static func _ferris_wheel(park: Node3D, pos: Vector3) -> void:
	var node := Node3D.new()
	node.position = pos
	park.add_child(node)
	var gold := P.mat(Color(0.86, 0.69, 0.28), 0.25, 0.85)
	var white := P.mat(Color(0.96, 0.95, 0.9), 0.3)
	var R := 7.5
	var hub_y := 9.0
	# A-frame supports.
	for sz in [-1.2, 1.2]:
		P.cyl(node, 0.22, 0.22, hub_y + 1.5, Vector3(-3.0, hub_y * 0.5, sz), white, Vector3(0, 0, -20), true, 10)
		P.cyl(node, 0.22, 0.22, hub_y + 1.5, Vector3(3.0, hub_y * 0.5, sz), white, Vector3(0, 0, 20), true, 10)
	P.cyl(node, 0.3, 0.3, 3.0, Vector3(0, hub_y, 0), gold, Vector3(90, 0, 0))
	var wheel := Node3D.new()
	wheel.position = Vector3(0, hub_y, 0)
	node.add_child(wheel)
	P.animate(wheel, "spinz", 0.12, 0.0, 0.0)
	for sz in [-0.9, 0.9]:
		var tm := TorusMesh.new()
		tm.inner_radius = R - 0.08
		tm.outer_radius = R + 0.08
		tm.rings = 48
		tm.ring_segments = 8
		P.put(wheel, tm, gold, Vector3(0, 0, sz), Vector3(90, 0, 0))
	for k in 8:
		var a := k * 180.0 / 8.0
		P.box(wheel, Vector3(R * 2.0, 0.1, 0.1), Vector3(0, 0, 0.9), white, Vector3(0, 0, a))
		P.box(wheel, Vector3(R * 2.0, 0.1, 0.1), Vector3(0, 0, -0.9), white, Vector3(0, 0, a))
	for k in 10:
		var a := k * TAU / 10.0
		var cabin_pivot := Node3D.new()
		cabin_pivot.position = Vector3(cos(a) * R, sin(a) * R, 0)
		wheel.add_child(cabin_pivot)
		# Counter-spin keeps cabins upright (handled in main.gd by "upright").
		cabin_pivot.add_to_group("upright")
		P.box(cabin_pivot, Vector3(1.6, 1.2, 1.6), Vector3(0, -1.1, 0), _c(k))
		P.box(cabin_pivot, Vector3(1.9, 0.14, 1.9), Vector3(0, -0.45, 0), gold)
		P.box(cabin_pivot, Vector3(0.06, 0.8, 0.06), Vector3(0, -0.1, 0), gold)


static func _merry_go_round(park: Node3D, pos: Vector3) -> void:
	var base := Node3D.new()
	base.position = pos
	park.add_child(base)
	var gold := P.mat(Color(0.86, 0.69, 0.28), 0.25, 0.85)
	P.cyl(base, 0.25, 0.3, 2.8, Vector3(0, 1.4, 0), gold)
	var top := Node3D.new()
	top.position = Vector3(0, 0.35, 0)
	base.add_child(top)
	P.animate(top, "spin", 0.5, 0.0, 0.0)
	P.cyl(top, 3.0, 3.0, 0.3, Vector3(0, 0, 0), P.mat(Color(0.96, 0.92, 0.82), 0.5), Vector3.ZERO, true, 32)
	P.cyl(top, 3.3, 0.1, 1.4, Vector3(0, 3.1, 0), P.mat(Color(0.95, 0.4, 0.45), 0.5))
	for k in 6:
		var a := k * TAU / 6.0
		P.cyl(top, 0.06, 0.06, 2.8, Vector3(cos(a) * 2.5, 1.5, sin(a) * 2.5), gold)
		var seat := Node3D.new()
		seat.position = Vector3(cos(a) * 2.0, 0.55, sin(a) * 2.0)
		seat.rotation.y = -a
		top.add_child(seat)
		P.box(seat, Vector3(0.7, 0.14, 0.7), Vector3(0, 0, 0), _c(k))
		P.box(seat, Vector3(0.1, 0.6, 0.7), Vector3(-0.3, 0.3, 0), _c(k))


static func _swings(park: Node3D, pos: Vector3) -> void:
	var node := Node3D.new()
	node.position = pos
	park.add_child(node)
	var frame := P.mat(Color(0.3, 0.65, 0.95), 0.4)
	var gold := P.mat(Color(0.86, 0.69, 0.28), 0.25, 0.85)
	P.box(node, Vector3(0.25, 4.2, 0.25), Vector3(-3.6, 2.1, -1.2), frame, Vector3(0, 0, 0))
	P.box(node, Vector3(0.25, 4.2, 0.25), Vector3(3.6, 2.1, -1.2), frame, Vector3(0, 0, 0))
	P.box(node, Vector3(0.25, 4.2, 0.25), Vector3(-3.6, 2.1, 1.2), frame)
	P.box(node, Vector3(0.25, 4.2, 0.25), Vector3(3.6, 2.1, 1.2), frame)
	P.box(node, Vector3(7.6, 0.3, 0.3), Vector3(0, 4.2, 0), gold)
	for k in 3:
		var pivot := Node3D.new()
		pivot.position = Vector3(-2.2 + k * 2.2, 4.1, 0)
		node.add_child(pivot)
		P.animate(pivot, "swing", 1.8, 0.5, k * 0.9)
		P.box(pivot, Vector3(0.04, 3.2, 0.04), Vector3(-0.3, -1.6, 0), gold)
		P.box(pivot, Vector3(0.04, 3.2, 0.04), Vector3(0.3, -1.6, 0), gold)
		P.box(pivot, Vector3(0.8, 0.12, 0.35), Vector3(0, -3.2, 0), _c(k + 1))


static func _slide(park: Node3D, pos: Vector3, rot_y: float) -> void:
	var node := Node3D.new()
	node.position = pos
	node.rotation_degrees.y = rot_y
	park.add_child(node)
	var frame := P.mat(Color(0.98, 0.8, 0.2), 0.4)
	var chute := P.mat(Color(0.9, 0.92, 0.96), 0.15, 0.6)
	P.box(node, Vector3(2.0, 0.2, 2.0), Vector3(0, 3.0, 0), frame, Vector3.ZERO, true)
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			P.box(node, Vector3(0.18, 3.0, 0.18), Vector3(sx * 0.9, 1.5, sz * 0.9), frame)
	# Ladder.
	for k in 6:
		P.box(node, Vector3(1.2, 0.08, 0.1), Vector3(0, 0.4 + k * 0.5, -1.2 - k * 0.0), frame)
	P.box(node, Vector3(0.1, 3.0, 0.1), Vector3(-0.6, 1.5, -1.2), frame)
	P.box(node, Vector3(0.1, 3.0, 0.1), Vector3(0.6, 1.5, -1.2), frame)
	# Chute and low side rails.
	P.box(node, Vector3(1.4, 0.1, 5.0), Vector3(0, 1.5, 3.3), chute, Vector3(-30, 0, 0))
	P.box(node, Vector3(0.1, 0.4, 5.0), Vector3(-0.7, 1.7, 3.3), frame, Vector3(-30, 0, 0))
	P.box(node, Vector3(0.1, 0.4, 5.0), Vector3(0.7, 1.7, 3.3), frame, Vector3(-30, 0, 0))


static func _seesaw(park: Node3D, pos: Vector3, rot_y: float) -> void:
	var node := Node3D.new()
	node.position = pos
	node.rotation_degrees.y = rot_y
	park.add_child(node)
	var gold := P.mat(Color(0.86, 0.69, 0.28), 0.25, 0.85)
	P.box(node, Vector3(0.3, 0.9, 0.6), Vector3(0, 0.45, 0), gold)
	var board := Node3D.new()
	board.position = Vector3(0, 0.9, 0)
	node.add_child(board)
	P.animate(board, "seesaw", 1.3, 0.28, 0.0)
	P.box(board, Vector3(5.0, 0.12, 0.5), Vector3.ZERO, _c(0))
	for sx in [-2.2, 2.2]:
		P.box(board, Vector3(0.1, 0.5, 0.3), Vector3(sx, 0.3, 0), gold)


static func _sandbox(park: Node3D, pos: Vector3) -> void:
	var node := Node3D.new()
	node.position = pos
	park.add_child(node)
	var wood := P.mat(Color(0.55, 0.38, 0.22), 0.9)
	P.box(node, Vector3(5, 0.1, 5), Vector3(0, 0.1, 0), P.mat(Color(0.95, 0.85, 0.6), 0.95))
	for k in 4:
		var a := k * 90.0
		var off := Vector3(0, 0.2, 2.5).rotated(Vector3.UP, deg_to_rad(a))
		P.box(node, Vector3(5.2, 0.4, 0.2), off, wood, Vector3(0, a, 0))
	P.ball(node, 0.5, Vector3(-1.0, 0.25, 0.5), P.mat(Color(0.93, 0.82, 0.55), 0.95), Vector3(1.0, 0.8, 1.0))
	P.cyl(node, 0.2, 0.15, 0.3, Vector3(1.0, 0.25, -0.5), _c(2))


static func _climbing_frame(park: Node3D, pos: Vector3) -> void:
	var node := Node3D.new()
	node.position = pos
	park.add_child(node)
	var frame := P.mat(Color(0.45, 0.8, 0.4), 0.4)
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			P.box(node, Vector3(0.14, 3.4, 0.14), Vector3(sx * 1.6, 1.7, sz * 1.6), frame)
	for level in 5:
		var y := 0.5 + level * 0.7
		for sz in [-1.6, 1.6]:
			P.box(node, Vector3(3.3, 0.08, 0.08), Vector3(0, y, sz), frame)
		for sx in [-1.6, 1.6]:
			P.box(node, Vector3(0.08, 0.08, 3.3), Vector3(sx, y, 0), frame)
	P.box(node, Vector3(3.3, 0.1, 3.3), Vector3(0, 3.4, 0), P.mat(Color(0.98, 0.8, 0.2), 0.5), Vector3.ZERO, true)


static func _spring_riders(park: Node3D, pos: Vector3) -> void:
	var node := Node3D.new()
	node.position = pos
	park.add_child(node)
	for k in 3:
		var pivot := Node3D.new()
		pivot.position = Vector3(k * 1.8, 0.1, 0)
		node.add_child(pivot)
		P.animate(pivot, "swing", 2.0, 0.22, k * 1.3)
		P.cyl(pivot, 0.08, 0.12, 0.8, Vector3(0, 0.4, 0), P.mat(Color(0.7, 0.7, 0.75), 0.2, 0.8))
		P.ball(pivot, 0.5, Vector3(0, 1.0, 0), _c(k + 2), Vector3(0.8, 0.9, 1.3))
		P.ball(pivot, 0.28, Vector3(0, 1.45, 0.6), _c(k + 2))


static func _monkey_bars(park: Node3D, pos: Vector3) -> void:
	var node := Node3D.new()
	node.position = pos
	park.add_child(node)
	var frame := P.mat(Color(0.8, 0.5, 0.9), 0.4)
	var gold := P.mat(Color(0.86, 0.69, 0.28), 0.25, 0.85)
	for sx in [-3.0, 3.0]:
		P.box(node, Vector3(0.16, 2.8, 0.16), Vector3(sx, 1.4, -0.8), frame)
		P.box(node, Vector3(0.16, 2.8, 0.16), Vector3(sx, 1.4, 0.8), frame)
	for k in 8:
		P.cyl(node, 0.05, 0.05, 1.6, Vector3(-2.6 + k * 0.75, 2.7, 0), gold, Vector3(90, 0, 0))


static func _benches(park: Node3D) -> void:
	var wood := P.mat(Color(0.55, 0.38, 0.22), 0.9)
	var gold := P.mat(Color(0.86, 0.69, 0.28), 0.25, 0.85)
	for k in 6:
		var a := k * TAU / 6.0 + 0.3
		var bench := Node3D.new()
		bench.position = Vector3(cos(a) * 21.0, 0, sin(a) * 21.0)
		bench.rotation.y = -a - PI / 2.0
		park.add_child(bench)
		P.box(bench, Vector3(2.2, 0.12, 0.6), Vector3(0, 0.5, 0), wood, Vector3.ZERO, true)
		P.box(bench, Vector3(2.2, 0.6, 0.1), Vector3(0, 0.85, 0.3), wood)
		P.box(bench, Vector3(0.1, 0.5, 0.5), Vector3(-1.0, 0.25, 0), gold)
		P.box(bench, Vector3(0.1, 0.5, 0.5), Vector3(1.0, 0.25, 0), gold)
