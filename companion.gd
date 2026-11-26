extends CharacterBody3D
## The other character (the wife when you chose the man, the man when you chose
## the woman). Walks after the player, keeps a polite distance, stops when close
## and never blocks the way: the two bodies ignore each other.

const CharacterBuilder = preload("res://character_builder.gd")

const WALK := 5.5
const RUN := 11.0
const GRAVITY := 18.0
const STAY_NEAR := 3.2      # stops when closer than this
const TELEPORT := 45.0      # catches up instantly when left far behind

var target   # the player (player.gd)
var model: Node3D


func setup(kind: String, player_node) -> void:
	target = player_node
	var shape := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.4
	cap.height = 1.9
	shape.shape = cap
	shape.position.y = 0.95
	add_child(shape)
	model = CharacterBuilder.build(kind)
	add_child(model)
	add_collision_exception_with(player_node)
	player_node.add_collision_exception_with(self)


func _physics_process(delta: float) -> void:
	if target == null or not is_instance_valid(target):
		return
	var to: Vector3 = target.global_position - global_position
	var flat := Vector3(to.x, 0.0, to.z)
	var dist: float = flat.length()

	if dist > TELEPORT:
		# Appear beside the player, a little behind.
		var back := Vector3(0, 0, 2.5).rotated(Vector3.UP, target.yaw)
		global_position = target.global_position + back
		velocity = Vector3.ZERO
		return

	var want := Vector3.ZERO
	if dist > STAY_NEAR:
		var speed: float = RUN if dist > 9.0 else WALK
		want = flat.normalized() * speed
	velocity.x = lerpf(velocity.x, want.x, minf(1.0, 8.0 * delta))
	velocity.z = lerpf(velocity.z, want.z, minf(1.0, 8.0 * delta))
	if is_on_floor():
		velocity.y = -0.5
	else:
		velocity.y -= GRAVITY * delta
	move_and_slide()

	var horiz := Vector2(velocity.x, velocity.z)
	var face := flat if horiz.length() < 0.3 else Vector3(velocity.x, 0, velocity.z)
	if face.length() > 0.2:
		model.rotation.y = lerp_angle(model.rotation.y, atan2(face.x, face.z), 8.0 * delta)
	model.call("update_motion", horiz.length(), delta, false)
