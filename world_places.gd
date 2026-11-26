extends RefCounted
## Mansions (gold and silver bricks, pearl domes, enterable) and the hollow
## pearl tent described in hadith.

const P = preload("res://prims.gd")
const Core = preload("res://world_core.gd")


static func build(root: Node3D) -> void:
	for i in Core.MANSIONS.size():
		_mansion(root, Core.MANSIONS[i], i)
	_tent(root)


static func _mansion(root: Node3D, pos: Vector3, idx: int) -> void:
	var node := Node3D.new()
	node.name = "Mansion%d" % (idx + 1)
	node.position = pos
	node.rotation.y = deg_to_rad(15.0 * (idx - 1))
	root.add_child(node)

	var wall := P.mat(Color(0.98, 0.95, 0.88), 0.3)
	var gold := P.mat(Color(0.86, 0.69, 0.28), 0.25, 0.85)
	var silver := P.mat(Color(0.85, 0.87, 0.9), 0.2, 0.9)
	var pearl := P.mat(Color(0.97, 0.96, 0.94), 0.12, 0.1, 0.15, Color(1.0, 0.97, 0.9))
	var teal := P.mat(Color(0.2, 0.65, 0.62), 0.3, 0.3)
	var rug := P.mat(Color(0.1, 0.4, 0.22), 0.6)
	var glass := P.mat(Color(0.7, 0.9, 1.0, 0.4), 0.05)

	# Base terrace with stairs.
	P.box(node, Vector3(26, 0.6, 22), Vector3(0, 0.3, 0), wall, Vector3.ZERO, true)
	P.box(node, Vector3(8, 0.2, 2.4), Vector3(0, 0.1, 11.8), wall, Vector3.ZERO, true)
	P.box(node, Vector3(8, 0.45, 1.2), Vector3(0, 0.32, 11.1), wall, Vector3.ZERO, true)

	# Main hall, left open at the front (south, +Z) as a door.
	var hall_h := 8.0
	P.box(node, Vector3(0.6, hall_h, 14), Vector3(-9.5, 0.6 + hall_h * 0.5, 0), wall, Vector3.ZERO, true)
	P.box(node, Vector3(0.6, hall_h, 14), Vector3(9.5, 0.6 + hall_h * 0.5, 0), wall, Vector3.ZERO, true)
	P.box(node, Vector3(19.6, hall_h, 0.6), Vector3(0, 0.6 + hall_h * 0.5, -7.0), wall, Vector3.ZERO, true)
	P.box(node, Vector3(5.6, hall_h, 0.6), Vector3(-7.0, 0.6 + hall_h * 0.5, 7.0), wall, Vector3.ZERO, true)
	P.box(node, Vector3(5.6, hall_h, 0.6), Vector3(7.0, 0.6 + hall_h * 0.5, 7.0), wall, Vector3.ZERO, true)
	P.box(node, Vector3(8.4, 2.6, 0.6), Vector3(0, 0.6 + hall_h - 1.3, 7.0), wall, Vector3.ZERO, true)
	P.box(node, Vector3(19.6, 0.6, 14.6), Vector3(0, 0.6 + hall_h + 0.3, 0), wall, Vector3.ZERO, true)
	# Gold and silver courses on the walls.
	for k in 4:
		var y := 1.6 + k * 1.8
		var m: Material = gold if k % 2 == 0 else silver
		P.box(node, Vector3(0.7, 0.14, 14.1), Vector3(-9.5, y, 0), m)
		P.box(node, Vector3(0.7, 0.14, 14.1), Vector3(9.5, y, 0), m)
		P.box(node, Vector3(19.7, 0.14, 0.7), Vector3(0, y, -7.0), m)
	# Windows.
	for wz in [-3.5, 3.5]:
		P.box(node, Vector3(0.7, 2.6, 1.6), Vector3(-9.5, 4.2, wz), glass)
		P.box(node, Vector3(0.7, 2.6, 1.6), Vector3(9.5, 4.2, wz), glass)

	# Central pearl dome on a drum, plus four corner domes.
	P.cyl(node, 5.6, 5.8, 1.8, Vector3(0, 0.6 + hall_h + 1.5, 0), wall)
	P.dome(node, 5.6, Vector3(0, 0.6 + hall_h + 2.4, 0), pearl)
	P.cyl(node, 0.1, 0.1, 2.6, Vector3(0, 0.6 + hall_h + 8.0, 0), gold)
	P.ball(node, 0.35, Vector3(0, 0.6 + hall_h + 9.3, 0), gold)
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			var tp := Vector3(sx * 12.0, 0, sz * 9.0)
			P.cyl(node, 1.5, 1.6, 10.5, tp + Vector3(0, 5.8, 0), wall, Vector3.ZERO, true)
			P.cyl(node, 1.65, 1.65, 0.3, tp + Vector3(0, 8.0, 0), gold)
			P.dome(node, 1.9, tp + Vector3(0, 11.0, 0), teal)
			P.ball(node, 0.2, tp + Vector3(0, 13.1, 0), gold)

	# Inside: carpet, couches, a hanging light.
	P.box(node, Vector3(8.0, 0.05, 11.0), Vector3(0, 0.63, 0), rug)
	P.box(node, Vector3(7.4, 0.06, 10.4), Vector3(0, 0.64, 0), gold)
	P.box(node, Vector3(7.0, 0.07, 10.0), Vector3(0, 0.65, 0), rug)
	for sx in [-1.0, 1.0]:
		var c := Node3D.new()
		c.position = Vector3(sx * 7.0, 0.6, -3.0)
		node.add_child(c)
		P.box(c, Vector3(1.6, 0.5, 5.0), Vector3(0, 0.25, 0), gold, Vector3.ZERO, true)
		P.box(c, Vector3(1.4, 0.25, 4.8), Vector3(0, 0.62, 0), P.mat(Color(0.96, 0.9, 0.75), 0.4))
		P.box(c, Vector3(0.2, 0.9, 4.8), Vector3(sx * 0.7, 1.0, 0), rug)
	var lamp := OmniLight3D.new()
	lamp.position = Vector3(0, 6.2, 0)
	lamp.light_color = Color(1.0, 0.93, 0.78)
	lamp.light_energy = 1.2
	lamp.omni_range = 18.0
	node.add_child(lamp)
	P.cyl(node, 0.05, 0.05, 1.6, Vector3(0, 7.4, 0), gold)
	P.ball(node, 0.5, Vector3(0, 6.5, 0), pearl)

	# Garden terraces in front of the mansion with fountain.
	P.cyl(node, 2.2, 2.4, 0.6, Vector3(0, 0.3, 16.0), wall, Vector3.ZERO, true)
	P.cyl(node, 1.9, 1.9, 0.12, Vector3(0, 0.62, 16.0), P.mat(Color(0.4, 0.75, 0.95, 0.75), 0.05, 0.2))


# Tent of one hollow pearl: a hadith describes a large tent of hollow pearl.
static func _tent(root: Node3D) -> void:
	var node := Node3D.new()
	node.name = "PearlTent"
	node.position = Core.TENT
	root.add_child(node)
	var pearl := P.mat(Color(0.97, 0.96, 0.94, 0.78), 0.1, 0.15, 0.2, Color(1.0, 0.97, 0.9))
	var gold := P.mat(Color(0.86, 0.69, 0.28), 0.25, 0.85)
	var rug := P.mat(Color(0.1, 0.4, 0.22), 0.6)
	P.cyl(node, 7.0, 7.2, 0.4, Vector3(0, 0.2, 0), P.mat(Color(0.96, 0.95, 0.9), 0.3), Vector3.ZERO, true, 40)
	var shell := P.dome(node, 6.2, Vector3(0, 0.4, 0), pearl)
	shell.scale = Vector3(1.0, 1.1, 1.0)
	# A gap in the shell so you can walk in: floor ring only, no walls to block.
	P.cyl(node, 5.0, 5.0, 0.06, Vector3(0, 0.45, 0), rug, Vector3.ZERO, false, 40)
	P.cyl(node, 5.2, 5.2, 0.05, Vector3(0, 0.44, 0), gold, Vector3.ZERO, false, 40)
	P.ball(node, 0.3, Vector3(0, 7.5, 0), gold)
	var l := OmniLight3D.new()
	l.position = Vector3(0, 3.0, 0)
	l.light_color = Color(1.0, 0.95, 0.85)
	l.light_energy = 0.9
	l.omni_range = 10.0
	node.add_child(l)
