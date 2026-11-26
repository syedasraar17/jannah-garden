extends RefCounted
## Builds the three characters from primitives, following the concept sheets:
## soft-glowing faceless head, layered silk, gold embroidery.
##   "man"  : cream silk robe, gold sash, turban, shoulder scarf, sheer cloak
##   "wife" : cream and gold gown, long sheer embroidered veil, gold crown chain
##   "hoor" : green open robe over a cream gown, cream veil, gold belt
##
## The body is a real jointed hierarchy (Hips > Torso > Head / ArmL / ArmR,
## Hips > LegL / LegR, plus RobeFront / RobeBack / Cape cloth panels) so that
## character_anim.gd can swing arms and legs and make the clothes move.
## The model faces +Z and stands with its feet on y = 0.

const P = preload("res://prims.gd")
const Anim = preload("res://character_anim.gd")

const HIP_Y := 0.92


## Cloth materials are seen from both sides.
static func _cloth(color: Color, rough: float = 0.4) -> StandardMaterial3D:
	var m := P.mat(color, rough)
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	return m


static func _pivot(parent: Node3D, node_name: String, pos: Vector3) -> Node3D:
	var n := Node3D.new()
	n.name = node_name
	n.position = pos
	parent.add_child(n)
	return n


## A cylinder hanging down from its pivot (used for thighs, arms and so on).
static func _limb(parent: Node3D, length: float, r_top: float, r_bot: float, mat: Material) -> MeshInstance3D:
	return P.cyl(parent, r_top, r_bot, length, Vector3(0, -length * 0.5, 0), mat, Vector3.ZERO, false, 12)


## A curved cloth panel hanging from y = 0 down to y = -h: part of a cone
## whose radius grows from r0 (top) to r1 (hem), spanning +-half_arc_deg
## around +Z (front) or -Z (back). The hem has soft folds.
static func _skirt(parent: Node3D, front: bool, half_arc_deg: float, r0: float, r1: float, h: float, mat: Material) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var segs := 18
	var center: float = 0.0 if front else PI
	var arc: float = deg_to_rad(half_arc_deg)
	for i in segs:
		var a0: float = center - arc + 2.0 * arc * float(i) / float(segs)
		var a1: float = center - arc + 2.0 * arc * float(i + 1) / float(segs)
		var w0: float = 1.0 + 0.035 * sin(a0 * 9.0)
		var w1: float = 1.0 + 0.035 * sin(a1 * 9.0)
		var t0 := Vector3(sin(a0) * r0, 0.0, cos(a0) * r0)
		var t1 := Vector3(sin(a1) * r0, 0.0, cos(a1) * r0)
		var b0 := Vector3(sin(a0) * r1 * w0, -h, cos(a0) * r1 * w0)
		var b1 := Vector3(sin(a1) * r1 * w1, -h, cos(a1) * r1 * w1)
		var tilt: float = (r1 - r0) / h
		var n0 := Vector3(sin(a0), tilt, cos(a0)).normalized()
		var n1 := Vector3(sin(a1), tilt, cos(a1)).normalized()
		st.set_normal(n0)
		st.add_vertex(t0)
		st.set_normal(n0)
		st.add_vertex(b0)
		st.set_normal(n1)
		st.add_vertex(t1)
		st.set_normal(n1)
		st.add_vertex(t1)
		st.set_normal(n0)
		st.add_vertex(b0)
		st.set_normal(n1)
		st.add_vertex(b1)
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.material_override = mat
	parent.add_child(mi)
	return mi


## A thin strip lying on the surface of a skirt panel (embroidery, borders).
static func _strip(panel: Node3D, front: bool, x: float, width: float, r0: float, r1: float, h: float, mat: Material) -> void:
	var mid_r: float = (r0 + r1) * 0.5
	var z: float = sqrt(maxf(0.0001, mid_r * mid_r - x * x)) + 0.008
	var ang: float = rad_to_deg(atan2(r1 - r0, h))
	var length: float = sqrt(h * h + (r1 - r0) * (r1 - r0)) * 0.99
	if front:
		P.box(panel, Vector3(width, length, 0.012), Vector3(x, -h * 0.5, z), mat, Vector3(-ang, 0, 0))
	else:
		P.box(panel, Vector3(width, length, 0.012), Vector3(x, -h * 0.5, -z), mat, Vector3(ang, 0, 0))


static func _hem(panel: Node3D, front: bool, r0: float, r1: float, h: float, mat: Material) -> void:
	var band := 0.08
	var r_mid: float = r0 + (r1 - r0) * ((h - band) / h)
	var mi := _skirt(panel, front, 100.0, r_mid, r1 * 1.01, band, mat)
	mi.position.y = -(h - band)


static func build(kind: String) -> Node3D:
	var root := Node3D.new()
	root.name = kind.capitalize()
	root.set_script(Anim)

	var is_man: bool = kind == "man"
	var is_hoor: bool = kind == "hoor"

	var silk := _cloth(Color(0.96, 0.92, 0.80), 0.35)
	var green := _cloth(Color(0.07, 0.26, 0.15), 0.5)
	var sheer := _cloth(Color(0.98, 0.95, 0.86, 0.5), 0.3)
	var gold := P.mat(Color(0.92, 0.74, 0.32), 0.3, 0.55)
	var skin := P.mat(Color(0.93, 0.78, 0.65), 0.6)
	# The glow is soft: a lit, slightly bright head, not a lamp.
	var glow := P.mat(Color(1.0, 0.95, 0.75), 0.3, 0.0, 1.1, Color(1.0, 0.92, 0.6))
	var shoe := P.mat(Color(0.95, 0.9, 0.78), 0.5) if not is_hoor else P.mat(Color(0.86, 0.69, 0.28), 0.4, 0.4)
	var outer: StandardMaterial3D = green if is_hoor else silk

	# --- Skeleton -----------------------------------------------------------
	var hips := _pivot(root, "Hips", Vector3(0, HIP_Y, 0))
	var torso := _pivot(hips, "Torso", Vector3(0, 0.02, 0))
	var head := _pivot(torso, "Head", Vector3(0, 0.64, 0))

	# Legs (mostly under the robe, but they swing it from inside).
	var leg_names := ["LegL", "LegR"]
	var shin_names := ["ShinL", "ShinR"]
	for i in 2:
		var sx: float = -1.0 if i == 0 else 1.0
		var leg := _pivot(hips, leg_names[i], Vector3(sx * 0.095, 0, 0))
		_limb(leg, 0.46, 0.085, 0.065, silk)
		var shin := _pivot(leg, shin_names[i], Vector3(0, -0.46, 0))
		_limb(shin, 0.43, 0.062, 0.05, silk)
		P.box(shin, Vector3(0.11, 0.07, 0.27), Vector3(0, -0.45, 0.06), shoe)

	# Torso.
	var shoulder_r: float = 0.2 if is_man else 0.175
	var chest := P.cyl(torso, shoulder_r, 0.15, 0.52, Vector3(0, 0.26, 0), outer, Vector3.ZERO, false, 16)
	chest.scale = Vector3(1.0, 1.0, 0.74)
	var sash := P.cyl(torso, 0.17, 0.175, 0.1, Vector3(0, 0.03, 0), gold, Vector3.ZERO, false, 16)
	sash.scale = Vector3(1.0, 1.0, 0.82)
	P.ball(torso, 0.045, Vector3(0, 0.03, 0.14), gold)
	P.cyl(torso, 0.045, 0.05, 0.12, Vector3(0, 0.59, 0), skin, Vector3.ZERO, false, 10)

	# Head: a softly glowing face, no features.
	P.ball(head, 0.105, Vector3(0, 0.1, 0), glow, Vector3(0.88, 1.15, 0.95))
	var light := OmniLight3D.new()
	light.light_color = Color(1.0, 0.93, 0.7)
	light.light_energy = 0.3
	light.omni_range = 3.0
	light.position = Vector3(0, 0.12, 0.2)
	head.add_child(light)

	# Arms with elbows and flared silk sleeves.
	var arm_names := ["ArmL", "ArmR"]
	var fore_names := ["ForeL", "ForeR"]
	for i in 2:
		var sx: float = -1.0 if i == 0 else 1.0
		var arm := _pivot(torso, arm_names[i], Vector3(sx * 0.215, 0.5, 0))
		P.ball(arm, 0.066, Vector3.ZERO, outer)
		_limb(arm, 0.3, 0.062, 0.075, outer)
		var fore := _pivot(arm, fore_names[i], Vector3(0, -0.3, 0))
		_limb(fore, 0.28, 0.078, 0.12, outer)
		P.cyl(fore, 0.123, 0.123, 0.03, Vector3(0, -0.265, 0), gold, Vector3.ZERO, false, 12)
		P.ball(fore, 0.036, Vector3(0, -0.3, 0), skin, Vector3(0.9, 1.5, 0.65))

	# --- Robe: front and back panels swing separately -------------------------
	var r0: float = 0.2 if is_man else 0.19
	var r1: float = 0.5 if is_man else 0.52
	var rb1: float = r1 if is_man else r1 + 0.1   # a small train behind the women
	var h := 0.92
	var front := _pivot(hips, "RobeFront", Vector3(0, 0.05, 0))
	var back := _pivot(hips, "RobeBack", Vector3(0, 0.05, 0))
	_skirt(front, true, 100.0, r0, r1, h, outer)
	_skirt(back, false, 100.0, r0 + 0.006, rb1, h, outer)
	_hem(front, true, r0, r1, h, gold)
	_hem(back, false, r0 + 0.006, rb1, h, gold)

	if is_man:
		for x: float in [-0.11, 0.11]:
			_strip(front, true, x, 0.05, r0, r1, h, gold)
		_strip(back, false, 0.0, 0.12, r0, rb1, h, gold)
	elif is_hoor:
		_strip(front, true, 0.0, 0.26, r0, r1, h, silk)      # cream gown showing
		for x: float in [-0.14, 0.14]:
			_strip(front, true, x, 0.03, r0, r1, h, gold)
		_strip(back, false, 0.0, 0.07, r0, rb1, h, gold)
	else:
		_strip(front, true, 0.0, 0.08, r0, r1, h, gold)
		for x: float in [-0.17, 0.17]:
			_strip(front, true, x, 0.025, r0, r1, h, gold)
		_strip(back, false, 0.0, 0.08, r0, rb1, h, gold)

	# --- Cloak or veil, hanging from the shoulders ---------------------------
	var cape := _pivot(torso, "Cape", Vector3(0, 0.5, -0.02))
	if is_man:
		_skirt(cape, false, 75.0, 0.22, 0.5, 1.45, sheer)
		for x: float in [-0.3, 0.3]:
			_strip(cape, false, x, 0.03, 0.22, 0.5, 1.45, gold)
	else:
		_skirt(cape, false, 95.0, 0.24, 0.64, 1.75, sheer)
		for x: float in [-0.38, 0.38]:
			_strip(cape, false, x, 0.025, 0.24, 0.64, 1.75, gold)

	# --- Head coverings -------------------------------------------------------
	if is_man:
		var tm := TorusMesh.new()
		tm.inner_radius = 0.1
		tm.outer_radius = 0.165
		P.put(head, tm, silk, Vector3(0, 0.15, 0))
		var tm2 := TorusMesh.new()
		tm2.inner_radius = 0.105
		tm2.outer_radius = 0.135
		P.put(head, tm2, gold, Vector3(0, 0.2, 0), Vector3(8, 0, 0))
		P.ball(head, 0.125, Vector3(0, 0.2, -0.01), silk, Vector3(1.0, 0.7, 1.0))
		# Shoulder scarf and the end hanging over the chest.
		var scarf := P.cyl(torso, 0.19, 0.27, 0.11, Vector3(0, 0.53, 0), silk, Vector3.ZERO, false, 16)
		scarf.scale = Vector3(1.0, 1.0, 0.8)
		P.box(torso, Vector3(0.13, 0.5, 0.016), Vector3(-0.1, 0.27, 0.15), silk, Vector3(-4, 0, 0))
		P.box(torso, Vector3(0.025, 0.5, 0.018), Vector3(-0.165, 0.27, 0.152), gold, Vector3(-4, 0, 0))
	else:
		P.ball(head, 0.135, Vector3(0, 0.095, -0.005), sheer, Vector3(0.96, 1.2, 1.06))
		var cowl := P.cyl(torso, 0.13, 0.28, 0.36, Vector3(0, 0.5, 0), sheer, Vector3.ZERO, false, 16)
		cowl.scale = Vector3(1.0, 1.0, 0.86)
		var crown := TorusMesh.new()
		crown.inner_radius = 0.118
		crown.outer_radius = 0.128
		P.put(head, crown, gold, Vector3(0, 0.17, 0.005))
		P.ball(head, 0.026, Vector3(0, 0.17, 0.125), gold)
		for sx: float in [-0.07, 0.07]:
			P.ball(head, 0.014, Vector3(sx, 0.16, 0.115), silk)

	return root
