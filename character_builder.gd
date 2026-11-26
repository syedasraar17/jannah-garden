extends RefCounted
## Builds the three character models from primitives, following the concept
## sheets: radiant faceless head, layered silk, gold embroidery.
## kind: "man", "wife" (cream and gold) or "hoor" (green and gold, covered).

const P = preload("res://prims.gd")


static func build(kind: String) -> Node3D:
	var root := Node3D.new()
	root.name = kind.capitalize()

	var silk := P.mat(Color(0.97, 0.93, 0.82), 0.35)
	var gold := P.mat(Color(0.86, 0.69, 0.28), 0.25, 0.85)
	var green := P.mat(Color(0.06, 0.24, 0.13), 0.45)
	var sheer := P.mat(Color(0.98, 0.95, 0.86, 0.5), 0.3)
	var skin := P.mat(Color(0.93, 0.78, 0.65), 0.6)
	var glow := P.mat(Color(1.0, 0.94, 0.68), 0.2, 0.0, 3.5, Color(1.0, 0.9, 0.55))
	var outer: StandardMaterial3D = green if kind == "hoor" else silk

	# Long flowing robe, torso and sash.
	P.cyl(root, 0.26, 0.64, 1.25, Vector3(0, 0.62, 0), outer)
	P.cyl(root, 0.24, 0.27, 0.58, Vector3(0, 1.48, 0), outer)
	P.cyl(root, 0.29, 0.29, 0.1, Vector3(0, 1.22, 0), gold)
	P.ball(root, 0.06, Vector3(0, 1.22, 0.29), gold)

	# Cream inner panel for the green design, gold borders for all.
	if kind == "hoor":
		P.box(root, Vector3(0.3, 1.15, 0.02), Vector3(0, 0.62, 0.47), silk)
	P.box(root, Vector3(0.04, 1.1, 0.02), Vector3(-0.17, 0.6, 0.46), gold)
	P.box(root, Vector3(0.04, 1.1, 0.02), Vector3(0.17, 0.6, 0.46), gold)

	# Wide sleeves and hands.
	P.cyl(root, 0.09, 0.16, 0.75, Vector3(0.37, 1.3, 0), outer, Vector3(0, 0, 8))
	P.cyl(root, 0.09, 0.16, 0.75, Vector3(-0.37, 1.3, 0), outer, Vector3(0, 0, -8))
	P.ball(root, 0.06, Vector3(0.43, 0.9, 0.0), skin)
	P.ball(root, 0.06, Vector3(-0.43, 0.9, 0.0), skin)

	# Radiant head (no face), with a soft light.
	P.ball(root, 0.19, Vector3(0, 1.92, 0), glow)
	var light := OmniLight3D.new()
	light.light_color = Color(1.0, 0.92, 0.65)
	light.light_energy = 0.7
	light.omni_range = 3.5
	light.position = Vector3(0, 1.95, 0.15)
	root.add_child(light)

	if kind == "man":
		# Turban, shoulder scarf and a flowing back cloak.
		var tm := TorusMesh.new()
		tm.inner_radius = 0.16
		tm.outer_radius = 0.28
		P.put(root, tm, silk, Vector3(0, 2.02, 0))
		P.ball(root, 0.2, Vector3(0, 2.1, 0), silk, Vector3(1.0, 0.7, 1.0))
		P.box(root, Vector3(0.66, 0.2, 0.5), Vector3(0, 1.7, 0), silk)
		var cloak := P.box(root, Vector3(0.85, 1.5, 0.04), Vector3(0, 0.95, -0.34), sheer)
		P.animate(cloak, "swing", 1.4, 0.05, 0.0)
		P.box(root, Vector3(0.04, 1.5, 0.05), Vector3(-0.42, 0.95, -0.34), gold)
		P.box(root, Vector3(0.04, 1.5, 0.05), Vector3(0.42, 0.95, -0.34), gold)
	else:
		# Covered head, long sheer veil, small gold crown chain.
		P.ball(root, 0.255, Vector3(0, 1.93, -0.01), sheer, Vector3(1.0, 1.15, 1.0))
		P.ball(root, 0.22, Vector3(0, 1.62, 0.0), sheer, Vector3(1.3, 0.8, 1.1))
		var veil := P.box(root, Vector3(0.9, 1.75, 0.04), Vector3(0, 1.0, -0.34), sheer)
		P.animate(veil, "swing", 1.3, 0.06, 1.0)
		var crown := TorusMesh.new()
		crown.inner_radius = 0.2
		crown.outer_radius = 0.23
		P.put(root, crown, gold, Vector3(0, 2.1, 0))
		P.ball(root, 0.035, Vector3(0, 2.1, 0.22), gold)
		P.box(root, Vector3(0.04, 1.75, 0.05), Vector3(-0.44, 1.0, -0.34), gold)
		P.box(root, Vector3(0.04, 1.75, 0.05), Vector3(0.44, 1.0, -0.34), gold)

	return root
