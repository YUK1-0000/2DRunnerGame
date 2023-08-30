extends Camera2D

@onready var player := %Player
@onready var spawn_position := global_position

const SPEED := 150.

var velocity := Vector2.ZERO


func _ready() -> void:
	set_limit(SIDE_TOP, 0)
	set_limit(SIDE_LEFT, 0)
	set_limit(SIDE_BOTTOM, ProjectSettings.get_setting("display/window/size/viewport_height") / 2)


func initialize() -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO


func _process(delta: float) -> void:
	if player.auto_run:
		velocity.x = SPEED + get_parent().run_time * 2
		global_position.x += velocity.x * delta
