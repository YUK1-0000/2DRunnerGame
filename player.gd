class_name Player

extends CharacterBody2D

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var coyote_jump_timer: Timer = $CoyoteJumpTimer
@onready var jump_sound = $JumpSound
@onready var air_jump_sound = $AirJumpSound
@onready var camera: Camera2D = get_parent().get_node("Camera")
@onready var spawn_position := global_position

const GRAVITY_SCALE:= 1.
const ACCELERATION:= 6000.
const JUMP_VELOCITY:= -300.

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var auto_run := false
var air_jumped: bool
var was_on_floor: bool
var just_left_ledge: bool


func initialize() -> void:
	velocity = Vector2.ZERO
	global_position = spawn_position
	auto_run = false


func _physics_process(delta: float) -> void:
	if is_on_floor(): air_jumped = false
	was_on_floor = is_on_floor()
	
	apply_gravity(delta)
	handle_jump()
	handle_acceleration(delta)
	
	move_and_slide()
	update_animations()
	
	just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge: coyote_jump_timer.start()


func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * GRAVITY_SCALE * delta


func handle_jump() -> void:
	if not auto_run: return
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or coyote_jump_timer.time_left:
			velocity.y = JUMP_VELOCITY
			jump_sound.play()
			coyote_jump_timer.stop()
		elif not is_on_floor() and not air_jumped:
			velocity.y = JUMP_VELOCITY * 0.8
			air_jump_sound.play()
			air_jumped = true
	if Input.is_action_just_released("jump"):
		if not is_on_floor():
			velocity.y = maxf(velocity.y, JUMP_VELOCITY / 4)


func handle_acceleration(_delta: float) -> void:
	if not auto_run: return
	velocity.x = (
		camera.velocity.x
		+ max(
			0, 
			(camera.global_position.x - global_position.x)
			- (camera.spawn_position.x - spawn_position.x)
		) 
		* 3
	)


func update_animations() -> void:
	if velocity.x:
		animation.flip_h = (velocity.x > 0)
		animation.play("run")
	else:
		animation.play("idle")
	if not is_on_floor():
		if velocity.y < 0:
			animation.play("jump")
		else:
			animation.play("fall")


func _on_death_zone_detector_area_entered(_area: Area2D) -> void:
	Events.game_over.emit()
