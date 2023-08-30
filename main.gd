extends Node2D

@export_group("Terrains")
@export var flat_terrain: PackedScene
@export var a: PackedScene
@export var b: PackedScene
@export var c: PackedScene
@export var d: PackedScene
@export var e: PackedScene
@export var f: PackedScene
@export var g: PackedScene

@onready var terrains := [flat_terrain, a, b, c, d, e, f, g]
@onready var connection_point: Marker2D = $ConnectionPoint
@onready var player: CharacterBody2D = %Player
@onready var camera: Camera2D = %Camera
@onready var start_menu: CenterContainer = %StartMenu
@onready var start_button: Button = %StartButton
@onready var quit_button: Button = %QuitButton
@onready var info_hud = %InfoHUD
@onready var int_time_label: Label = %IntTimeLabel
@onready var float_time_label: Label = %FloatTimeLabel
@onready var game_over_menu: CenterContainer = %GameOverMenu
@onready var result_label: Label = %ResultLabel
@onready var continue_button: Button = %ContinueButton
@onready var start_game_sound = $StartGameSound

var elapsed_time:= 0.
var run_time:= 0.

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color8(115, 205, 216, 255))
	Events.game_over.connect(game_over)
	Events.game_reset.connect(game_reset)
	game_reset()


func _process(_delta: float) -> void:
	run_time = (Time.get_ticks_msec() - elapsed_time) / 1000
	int_time_label.text = str(int(run_time))
	float_time_label.text = str("%0.2f" % (run_time - int(run_time))).lstrip("0")
	
	while (
		abs(camera.global_position.x - connection_point.position.x) < 
		ProjectSettings.get_setting("display/window/size/viewport_width")
	):
		set_terrain()


func set_terrain(index: int = randi_range(1, len(terrains) - 1)) -> void:
	var temp = terrains[index].instantiate()
	temp.position = connection_point.position
	connection_point.position += temp.get_node("ConnectionPoint").position
	get_node("Terrain").add_child(temp)


func _on_start_button_pressed() -> void:
	start_menu.hide()
	info_hud.show()
	start_game_sound.play()
	elapsed_time = Time.get_ticks_msec()
	player.auto_run = true


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_continue_button_pressed() -> void:
	game_reset()


func game_over() -> void:
	info_hud.hide()
	result_label.text = "Time: " + int_time_label.text + float_time_label.text
	get_tree().paused = true
	game_over_menu.show()
	await get_tree().create_timer(0.5).timeout
	continue_button.grab_focus()


func game_reset() -> void:
	get_tree().paused = false
	game_over_menu.hide()
	player.initialize()
	camera.initialize()
	connection_point.position = Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"), 
		0
		)
	for i in get_node("Terrain").get_children(): i.queue_free()
	start_menu.show()
	start_button.grab_focus()
