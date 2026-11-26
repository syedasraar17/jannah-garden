
		extends Node3D
## Entry point: shows the character choice, builds the world, then runs the
## small animation driver for rides, flowing water and the cloth.

const Core = preload("res://world_core.gd")
const Pavilion = preload("res://world_pavilion.gd")
const Nature = preload("res://world_nature.gd")
const Places = preload("res://world_places.gd")
const Park = preload("res://world_park.gd")
const CharacterBuilder = preload("res://character_builder.gd")
const PlayerScript = preload("res://player.gd")
const IshtihaScript = preload("res://ishtiha.gd")
const TouchScript = preload("res://touch_controls.gd")
const CompanionScript = preload("res://companion.gd")
const P = preload("res://prims.gd")

## The hoor NPCs are OFF until a qualified scholar has reviewed whether and how
## they may be shown. Set to true to place a few modest, covered companions.
const SHOW_HOOR := false

var world: Node3D
var player   # CharacterBody3D with player.gd attached
var _time := 0.0
var _select_layer: CanvasLayer


func _ready() -> void:
	_show_select()


func _show_select() -> void:
	_select_layer = CanvasLayer.new()
	add_child(_select_layer)
	var bg := ColorRect.new()
	bg.color = Color(0.06, 0.16, 0.11, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_select_layer.add_child(bg)
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	box.position = Vector2(-175, -100)
	box.add_theme_constant_override("separation", 18)
	_select_layer.add_child(box)
	var t := Label.new()
	t.text = "Bismillah"
	t.add_theme_font_size_override("font_size", 40)
	t.add_theme_color_override("font_color", Color(0.98, 0.9, 0.6))
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(t)
	var sub := Label.new()
	sub.text = "A peaceful garden inspired by the descriptions of Jannah.\nChoose your character."
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_color_override("font_color", Color(0.9, 0.95, 0.88))
	box.add_child(sub)
	for k in ["man", "wife"]:
		var b := Button.new()
		b.text = "Man" if k == "man" else "Woman"
		b.custom_minimum_size = Vector2(240, 54)
		b.pressed.connect(_start.bind(k))
		box.add_child(b)


func _start(kind: String) -> void:
	_select_layer.queue_free()
	world = Node3D.new()
	world.name = "World"
	add_child(world)
	Core.build(world)
	Pavilion.build(world)
	Nature.build(world)
	Places.build(world)
	Park.build(world)
	if SHOW_HOOR:
		_place_hoor()

	player = CharacterBody3D.new()
	player.set_script(PlayerScript)
	player.position = Core.SPAWN
	add_child(player)
	player.setup(kind)
	player.yaw = 0.0

	# The other character walks after you.
	var buddy := CharacterBody3D.new()
	buddy.set_script(CompanionScript)
	buddy.position = Core.SPAWN + Vector3(-2.5, 0, 3.0)
	add_child(buddy)
	buddy.setup("wife" if kind == "man" else "man", player)

	var ui = CanvasLayer.new()
	ui.set_script(IshtihaScript)
	add_child(ui)
	ui.setup(player, world)

	if OS.has_feature("mobile"):
		_optimize_for_mobile()
		var tc = CanvasLayer.new()
		tc.set_script(TouchScript)
		add_child(tc)
		tc.setup(player, ui)


## Phones draw far fewer objects: small things beyond 130 m are not drawn.
func _optimize_for_mobile() -> void:
	for n in world.find_children("*", "MeshInstance3D", true, false):
		var mi := n as MeshInstance3D
		if mi.mesh == null:
			continue
		if mi.mesh.get_aabb().size.length() * mi.scale.length() < 40.0:
			mi.visibility_range_end = 130.0
			mi.visibility_range_end_margin = 8.0


func _place_hoor() -> void:
	for pos in [Vector3(30, 0, -6), Vector3(18, 0, -22)]:
		var h := CharacterBuilder.build("hoor")
		h.position = pos
		h.rotation.y = PI * 0.8
		world.add_child(h)


func _process(delta: float) -> void:
	_time += delta
	for m in P.flow_mats:
		var s: float = m.get_meta("flow_speed", -0.1)
		m.uv1_offset.y += s * delta

	for n in get_tree().get_nodes_in_group("anim"):
		var kind: String = n.get_meta("kind")
		var sp: float = n.get_meta("speed")
		var amt: float = n.get_meta("amount")
		var ph: float = n.get_meta("phase")
		var rot: Vector3 = n.get_meta("base_rot")
		match kind:
			"spin":
				n.rotation.y += sp * delta
			"spinz":
				n.rotation.z += sp * delta
			"swing":
				n.rotation.x = rot.x + sin(_time * sp + ph) * amt
			"seesaw":
				n.rotation.z = rot.z + sin(_time * sp + ph) * amt
			"flap":
				n.rotation.z = rot.z + sin(_time * sp + ph) * amt

	# Ferris wheel cabins hang upright whatever the wheel angle.
	for c in get_tree().get_nodes_in_group("upright"):
		var parent := c.get_parent() as Node3D
		if parent:
			c.rotation.z = -parent.rotation.z
