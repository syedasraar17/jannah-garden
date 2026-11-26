extends CanvasLayer
## The Ishtiha ("desire") menu. Press C or Tab to open. Pick a category, pick
## what the soul desires, and it appears in front of the character with a soft
## light. Everything is free: no currency, cooldowns or random rewards.
## "Remove last" and "Clear all" tidy up what you called.

const Items = preload("res://desire_items.gd")
const P = preload("res://prims.gd")

var player   # the player node (player.gd); untyped so its own members resolve at runtime
var world: Node3D
var panel: PanelContainer
var grid: GridContainer
var note: Label
var title: Label
var category := "Fruits"
var spawned: Array = []
var _open := false


func setup(p, w: Node3D) -> void:
	player = p
	world = w
	layer = 10
	_build_ui()
	_hint()
	_refresh()
	panel.visible = false


func _hint() -> void:
	if OS.has_feature("mobile"):
		return   # phones use the on-screen buttons instead
	var l := Label.new()
	l.text = "C / Tab  Ishtiha     WASD move   Shift run   Space jump   F ride the horse   Esc mouse"
	l.position = Vector2(20, 14)
	l.add_theme_color_override("font_color", Color(1, 1, 1, 0.95))
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	l.add_theme_constant_override("shadow_offset_x", 1)
	l.add_theme_constant_override("shadow_offset_y", 1)
	add_child(l)


func _build_ui() -> void:
	panel = PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(560, 360)
	panel.position = Vector2(360, 170)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.07, 0.17, 0.12, 0.94)
	sb.border_color = Color(0.86, 0.69, 0.28)
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(18)
	sb.set_content_margin_all(18)
	panel.add_theme_stylebox_override("panel", sb)
	add_child(panel)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	panel.add_child(vb)

	title = Label.new()
	title.text = "Ishtiha  ·  whatever the souls desire"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.98, 0.9, 0.6))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(title)

	var tabs := HBoxContainer.new()
	tabs.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_child(tabs)
	for c in Items.CATEGORIES:
		var b := Button.new()
		b.text = c
		b.pressed.connect(_pick_category.bind(c))
		tabs.add_child(b)

	grid = GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	vb.add_child(grid)

	note = Label.new()
	note.text = ""
	note.autowrap_mode = TextServer.AUTOWRAP_WORD
	note.add_theme_color_override("font_color", Color(0.85, 0.9, 0.8))
	note.custom_minimum_size = Vector2(0, 44)
	vb.add_child(note)

	var foot := HBoxContainer.new()
	foot.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_child(foot)
	var undo := Button.new()
	undo.text = "Remove last"
	undo.pressed.connect(_remove_last)
	foot.add_child(undo)
	var clear := Button.new()
	clear.text = "Clear all"
	clear.pressed.connect(_clear_all)
	foot.add_child(clear)
	var close := Button.new()
	close.text = "Close"
	close.pressed.connect(toggle)
	foot.add_child(close)


func _pick_category(c: String) -> void:
	category = c
	_refresh()


func _refresh() -> void:
	for ch in grid.get_children():
		ch.queue_free()
	for id in Items.ids_in(category):
		var b := Button.new()
		b.text = Items.ITEMS[id][0]
		b.custom_minimum_size = Vector2(170, 46)
		b.pressed.connect(_spawn.bind(id))
		b.mouse_entered.connect(func(): note.text = Items.ITEMS[id][2])
		grid.add_child(b)


func toggle() -> void:
	_open = not _open
	panel.visible = _open
	player.locked = _open
	if not OS.has_feature("mobile"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if _open else Input.MOUSE_MODE_CAPTURED


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_C or event.keycode == KEY_TAB:
			toggle()
			get_viewport().set_input_as_handled()


func _spawn(id: String) -> void:
	var item := Items.make(id)
	var fwd := Vector3(0, 0, 1).rotated(Vector3.UP, player.model.rotation.y)
	var pos: Vector3 = player.global_position + fwd * 2.4
	pos.y = 0.0
	# Spread repeated spawns so items do not stack on one spot.
	pos += fwd.cross(Vector3.UP) * (float(spawned.size() % 5) - 2.0) * 0.9
	world.add_child(item)
	item.global_position = pos
	item.rotation.y = player.model.rotation.y + PI
	spawned.append(item)

	# Appear with a soft light: grow in, with a glow ring and a brief mist.
	item.scale = Vector3.ONE * 0.05
	var tw := item.create_tween()
	tw.tween_property(item, "scale", Vector3.ONE, 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_glow(pos)
	note.text = "%s appears." % Items.ITEMS[id][0]


func _glow(pos: Vector3) -> void:
	var ring := MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = 0.5
	tm.outer_radius = 0.6
	ring.mesh = tm
	ring.material_override = P.mat(Color(1.0, 0.9, 0.5, 0.8), 0.3, 0.0, 3.0, Color(1.0, 0.88, 0.45))
	world.add_child(ring)
	ring.global_position = pos + Vector3(0, 0.1, 0)
	var light := OmniLight3D.new()
	light.light_color = Color(1.0, 0.92, 0.65)
	light.light_energy = 3.0
	light.omni_range = 6.0
	world.add_child(light)
	light.global_position = pos + Vector3(0, 1.0, 0)
	var tw := ring.create_tween().set_parallel(true)
	tw.tween_property(ring, "scale", Vector3(3.5, 3.5, 3.5), 0.9)
	tw.tween_property(light, "light_energy", 0.0, 1.1)
	tw.chain().tween_callback(ring.queue_free)
	tw.tween_callback(light.queue_free)

	var sparks := CPUParticles3D.new()
	sparks.one_shot = true
	sparks.amount = 36
	sparks.lifetime = 1.2
	sparks.explosiveness = 1.0
	sparks.direction = Vector3.UP
	sparks.spread = 70.0
	sparks.initial_velocity_min = 1.0
	sparks.initial_velocity_max = 2.6
	sparks.gravity = Vector3(0, -1.0, 0)
	var sm := SphereMesh.new()
	sm.radius = 0.04
	sm.height = 0.08
	sm.radial_segments = 6
	sm.rings = 3
	sm.material = P.mat(Color(1.0, 0.9, 0.5), 0.3, 0.0, 3.0, Color(1.0, 0.88, 0.45))
	sparks.mesh = sm
	world.add_child(sparks)
	sparks.global_position = pos + Vector3(0, 0.4, 0)
	sparks.emitting = true
	get_tree().create_timer(2.0).timeout.connect(sparks.queue_free)


func _remove_last() -> void:
	if spawned.is_empty():
		return
	var it = spawned.pop_back()
	if is_instance_valid(it):
		it.queue_free()


func _clear_all() -> void:
	for it in spawned:
		if is_instance_valid(it):
			it.queue_free()
	spawned.clear()
