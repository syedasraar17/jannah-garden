extends Node3D
## Drives the pose of a character built by character_builder.gd: idle breathing,
## walking and running (arms, legs, robe and veil), and a seated riding pose.
## The builder names every pivot; this script finds them once and moves them.
##
## The owner (player.gd or companion.gd) calls update_motion() every physics
## frame. Characters nobody drives (for example the hoor standing in the
## pavilion) fall back to a gentle idle on their own.

var hips: Node3D
var torso: Node3D
var head: Node3D
var arm_l: Node3D
var arm_r: Node3D
var fore_l: Node3D
var fore_r: Node3D
var leg_l: Node3D
var leg_r: Node3D
var shin_l: Node3D
var shin_r: Node3D
var cape: Node3D
var robe_front: Node3D
var robe_back: Node3D

var _t := 0.0
var _phase := 0.0
var _blend := 0.0     # 0 = standing, 1 = walking
var _speed_n := 0.0   # smoothed speed, 0 = still, 1 = full run
var _hips_y := 0.0
var _front_base := 0.0
var _back_base := 0.0
var _last_driven_ms := -1000


func _ready() -> void:
	hips = find_child("Hips", true, false) as Node3D
	torso = find_child("Torso", true, false) as Node3D
	head = find_child("Head", true, false) as Node3D
	arm_l = find_child("ArmL", true, false) as Node3D
	arm_r = find_child("ArmR", true, false) as Node3D
	fore_l = find_child("ForeL", true, false) as Node3D
	fore_r = find_child("ForeR", true, false) as Node3D
	leg_l = find_child("LegL", true, false) as Node3D
	leg_r = find_child("LegR", true, false) as Node3D
	shin_l = find_child("ShinL", true, false) as Node3D
	shin_r = find_child("ShinR", true, false) as Node3D
	cape = find_child("Cape", true, false) as Node3D
	robe_front = find_child("RobeFront", true, false) as Node3D
	robe_back = find_child("RobeBack", true, false) as Node3D
	if hips:
		_hips_y = hips.position.y
	if robe_front:
		_front_base = robe_front.rotation.x
	if robe_back:
		_back_base = robe_back.rotation.x
	_t = randf() * 10.0   # so two idle characters never breathe in step


func _process(delta: float) -> void:
	# Nobody is driving this character: just stand and breathe.
	if Time.get_ticks_msec() - _last_driven_ms > 250:
		_apply(0.0, delta, false)


## speed = horizontal speed in m/s, riding = seated pose on the winged horse.
func update_motion(speed: float, delta: float, riding: bool) -> void:
	_last_driven_ms = Time.get_ticks_msec()
	_apply(speed, delta, riding)


func _ease(node: Node3D, x: float, z: float, k: float) -> void:
	if node == null:
		return
	node.rotation.x = lerp_angle(node.rotation.x, x, k)
	node.rotation.z = lerp_angle(node.rotation.z, z, k)


func _apply(speed: float, delta: float, riding: bool) -> void:
	if hips == null:
		return
	_t += delta
	var moving := speed > 0.3 and not riding
	_speed_n = lerpf(_speed_n, clampf(speed / 12.0, 0.0, 1.0), minf(1.0, 8.0 * delta))
	_blend = move_toward(_blend, 1.0 if moving else 0.0, 6.0 * delta)
	if moving:
		_phase += delta * (5.5 + speed * 0.55)

	var k := minf(1.0, 14.0 * delta)
	var s := sin(_phase)
	var c := cos(_phase)
	var amp := (0.28 + 0.45 * _speed_n) * _blend
	var breathe := sin(_t * 1.6) * 0.012

	if riding:
		_ease(leg_l, -1.15, -0.2, k)
		_ease(leg_r, -1.15, 0.2, k)
		_ease(shin_l, 1.2, 0.0, k)
		_ease(shin_r, 1.2, 0.0, k)
		_ease(arm_l, -0.55, -0.1, k)
		_ease(arm_r, -0.55, 0.1, k)
		_ease(fore_l, -0.7, 0.0, k)
		_ease(fore_r, -0.7, 0.0, k)
	else:
		_ease(leg_l, s * amp, 0.0, k)
		_ease(leg_r, -s * amp, 0.0, k)
		# The knee folds while the leg swings forward.
		_ease(shin_l, maxf(0.0, -c) * amp * 1.2, 0.0, k)
		_ease(shin_r, maxf(0.0, c) * amp * 1.2, 0.0, k)
		_ease(arm_l, -s * amp * 0.9 + breathe, -0.07, k)
		_ease(arm_r, s * amp * 0.9 - breathe, 0.07, k)
		_ease(fore_l, -0.1 - maxf(0.0, s) * amp * 0.9, 0.0, k)
		_ease(fore_r, -0.1 - maxf(0.0, -s) * amp * 0.9, 0.0, k)

	# Body: bob with each step, sway the hips, lean into a run, breathe.
	hips.position.y = _hips_y + absf(s) * 0.045 * _blend
	hips.rotation.z = s * 0.04 * _blend
	if torso:
		torso.rotation.y = -s * 0.08 * _blend
		torso.rotation.x = 0.02 + _speed_n * 0.1 * _blend
		torso.scale = Vector3(1.0, 1.0 + breathe, 1.0 + breathe * 0.5)
	if head:
		head.rotation.x = -(0.02 + _speed_n * 0.07 * _blend)
		head.rotation.y = sin(_t * 0.6) * 0.05 * (1.0 - _blend)

	# Cloth: the veil or cloak trails back with speed; the robe panels kick out.
	if cape:
		cape.rotation.x = 0.04 + _speed_n * 0.55 + sin(_t * 2.3) * 0.035 + sin(_phase * 2.0) * 0.05 * _blend
		cape.rotation.z = sin(_t * 1.7) * 0.03 + s * 0.03 * _blend
	if robe_front:
		var kick := absf(s) * 0.28 + _speed_n * 0.12
		var target_front := _front_base - kick * _blend
		if riding:
			target_front = _front_base - 0.55
		robe_front.rotation.x = lerp_angle(robe_front.rotation.x, target_front, k)
	if robe_back:
		var lift := absf(c) * 0.2 + _speed_n * 0.15
		var target_back := _back_base + lift * _blend
		if riding:
			target_back = _back_base + 0.3
		robe_back.rotation.x = lerp_angle(robe_back.rotation.x, target_back, k)
