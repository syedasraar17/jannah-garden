extends CharacterBody3D
## Third-person player. WASD move, Shift run, Space jump, mouse look.
## F near the winged horse to ride it (Space up, Ctrl down), F again to dismount.

const CharacterBuilder = preload("res://character_builder.gd")

const WALK := 6.0
const RUN := 12.0
const JUMP := 6.5
const GRAVITY := 18.0
const FLY := 18.0

var kind := "man"
var yaw := 0.0
var pitch := -0.3
var locked := false   # set true while a menu is open
var horse: Node3D = null

var model: Node3D
var arm: SpringArm3D
var cam: Camera3D
var _walk_t := 0.0

# Filled in by touch_controls.gd on phones.
var touch_move := Vector2.ZERO   # x = right, y = forward (-1..1)
var touch_look := Vector2.ZERO   # drag pixels since the last frame
var touch_jump := false
var touch_down := false
var touch_run := false


func setup(character_kind: String) -> void:
	kind = character_kind
	var shape := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.4
	cap.height = 1.9
	shape.shape = cap
	shape.position.y = 0.95
	add_child(shape)

	model = CharacterBuilder.build(kind)
	add_child(model)

	arm = SpringArm3D.new()
	arm.spring_length = 5.5
	arm.margin = 0.3
	arm.position.y = 1.7
	var sphere := SphereShape3D.new()
	sphere.radius = 0.2
	arm.shape = sphere
	arm.add_excluded_object(get_rid())   # the camera arm must not hit its own player
	add_child(arm)

	cam = Camera3D.new()
	cam.fov = 70.0
	cam.far = 600.0
	arm.add_child(cam)
	cam.make_current()
	if not OS.has_feature("mobile"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if locked:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		yaw -= event.relative.x * 0.0028
		pitch = clampf(pitch - event.relative.y * 0.0028, -1.3, 0.5)
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F:
			_toggle_horse()
		elif event.keycode == KEY_ESCAPE:
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			else:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	if not locked:
		yaw -= touch_look.x * 0.006
		pitch = clampf(pitch - touch_look.y * 0.006, -1.3, 0.5)
	touch_look = Vector2.ZERO
	arm.rotation = Vector3(pitch, yaw, 0)

	var fwd := 0.0
	var side := 0.0
	var up_down := 0.0
	if not locked:
		if Input.is_key_pressed(KEY_W): fwd += 1.0
		if Input.is_key_pressed(KEY_S): fwd -= 1.0
		if Input.is_key_pressed(KEY_D): side += 1.0
		if Input.is_key_pressed(KEY_A): side -= 1.0
		if Input.is_key_pressed(KEY_SPACE): up_down += 1.0
		if Input.is_key_pressed(KEY_CTRL): up_down -= 1.0
		fwd += touch_move.y
		side += touch_move.x
		if touch_jump: up_down += 1.0
		if touch_down: up_down -= 1.0
	var dir := Vector3(side, 0, -fwd).rotated(Vector3.UP, yaw).normalized()
	var moving := dir.length() > 0.1

	if horse:
		velocity.x = dir.x * FLY
		velocity.z = dir.z * FLY
		velocity.y = move_toward(velocity.y, up_down * FLY * 0.6, 50.0 * delta)
	else:
		var speed := RUN if ((Input.is_key_pressed(KEY_SHIFT) or touch_run) and not locked) else WALK
		velocity.x = dir.x * speed
		velocity.z = dir.z * speed
		if not is_on_floor():
			velocity.y -= GRAVITY * delta
		elif up_down > 0.0:
			velocity.y = JUMP
		else:
			velocity.y = -0.5
	move_and_slide()

	if moving:
		var target := atan2(dir.x, dir.z)
		model.rotation.y = lerp_angle(model.rotation.y, target, 10.0 * delta)

	var lift := 1.1 if horse else 0.0
	if moving and is_on_floor() and not horse:
		_walk_t += delta * 9.0
		lift += absf(sin(_walk_t)) * 0.05
	model.position.y = lerpf(model.position.y, lift, 12.0 * delta)

	if horse:
		horse.global_position = global_position
		horse.rotation.y = lerp_angle(horse.rotation.y, model.rotation.y, 8.0 * delta)


func ride() -> void:
	_toggle_horse()


func _toggle_horse() -> void:
	if horse:
		horse.global_position.y = 0.0
		horse = null
		arm.position.y = 1.7
		return
	var best: Node3D = null
	var best_d := 4.5
	for h in get_tree().get_nodes_in_group("horse"):
		var d := global_position.distance_to(h.global_position)
		if d < best_d:
			best_d = d
			best = h
	if best:
		horse = best
		arm.position.y = 2.6
		velocity.y = 2.0
