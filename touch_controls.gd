extends CanvasLayer
## On-screen controls for phones. Left half of the screen: a floating joystick
## (touch anywhere and drag). Right side: drag to look. Plus buttons.
## Only created on mobile (see main.gd). Talks to player.gd through its
## touch_* variables, and to the Ishtiha menu through toggle().

const R := 110.0

var player
var ishtiha
var _move_id := -1
var _look_id := -1
var _origin := Vector2.ZERO
var _base: Panel
var _knob: Panel
var _buttons: Array = []


func setup(p, ui) -> void:
	player = p
	ishtiha = ui
	layer = 9
	_base = _circle(R * 2.0, Color(1, 1, 1, 0.18))
	_knob = _circle(R * 0.9, Color(1, 1, 1, 0.45))
	_base.visible = false
	_knob.visible = false

	var jump := _btn("Jump", Vector2(1090, 500), Vector2(140, 140))
	jump.button_down.connect(func(): player.touch_jump = true)
	jump.button_up.connect(func(): player.touch_jump = false)

	var down := _btn("Down", Vector2(1090, 380), Vector2(110, 90))
	down.button_down.connect(func(): player.touch_down = true)
	down.button_up.connect(func(): player.touch_down = false)

	var run := _btn("Run", Vector2(940, 540), Vector2(120, 100))
	run.toggle_mode = true
	run.toggled.connect(func(on): player.touch_run = on)

	var horse := _btn("Horse", Vector2(940, 420), Vector2(120, 100))
	horse.pressed.connect(func(): player.ride())

	var desire := _btn("Ishtiha", Vector2(20, 14), Vector2(150, 64))
	desire.pressed.connect(func(): ishtiha.toggle())


func _circle(size: float, color: Color) -> Panel:
	var p := Panel.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.set_corner_radius_all(int(size / 2.0))
	p.add_theme_stylebox_override("panel", sb)
	p.size = Vector2(size, size)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(p)
	return p


func _btn(text: String, pos: Vector2, sz: Vector2) -> Button:
	var b := Button.new()
	b.text = text
	b.position = pos
	b.size = sz
	b.add_theme_font_size_override("font_size", 24)
	b.focus_mode = Control.FOCUS_NONE
	b.modulate = Color(1, 1, 1, 0.8)
	add_child(b)
	_buttons.append(b)
	return b


func _over_button(pos: Vector2) -> bool:
	for b in _buttons:
		if b.get_global_rect().has_point(pos):
			return true
	return false


func _stop_move() -> void:
	_move_id = -1
	player.touch_move = Vector2.ZERO
	_base.visible = false
	_knob.visible = false


func _input(event: InputEvent) -> void:
	if player == null:
		return
	if player.locked:
		# A menu is open: let it have the touches.
		_look_id = -1
		_stop_move()
		return
	var half: float = get_viewport().get_visible_rect().size.x * 0.45
	if event is InputEventScreenTouch:
		if event.pressed:
			if _over_button(event.position):
				return
			if event.position.x < half:
				if _move_id == -1:
					_move_id = event.index
					_origin = event.position
					_base.position = _origin - _base.size * 0.5
					_knob.position = _origin - _knob.size * 0.5
					_base.visible = true
					_knob.visible = true
			elif _look_id == -1:
				_look_id = event.index
		else:
			if event.index == _move_id:
				_stop_move()
			elif event.index == _look_id:
				_look_id = -1
	elif event is InputEventScreenDrag:
		if event.index == _move_id:
			var d: Vector2 = event.position - _origin
			if d.length() > R:
				d = d.normalized() * R
			_knob.position = _origin + d - _knob.size * 0.5
			var v := d / R
			player.touch_move = Vector2(v.x, -v.y)
		elif event.index == _look_id:
			player.touch_look += event.relative
