extends Node2D

# --- Signal added here ---
signal boss_wave_completed

const PATH_BASIC   = "res://enemies/enemy_base.tscn"
const PATH_SPEEDER = "res://enemies/speeder_body.tscn"
const PATH_TANK    = "res://enemies/tank_enemy.tscn"
const PATH_CAMO    = "res://enemies/camo_enemy.tscn"

const PATH_BOSS    = "res://enemies/Boss_1.tscn"
const PATH_BOSS2   = "res://enemies/Boss_2.tscn"
const PATH_BOSS3   = "res://enemies/Boss_3.tscn"

@export_enum("boss1", "boss2", "boss3") var selected_boss: String = "boss1"
@export var spawner_path: NodePath

var spawn_interval: float = 0.4

var button_size := Vector2(64, 64)
var button_color := Color(0.18, 0.72, 0.22)
var outline_normal := Color(0.05, 0.05, 0.05)
var outline_auto := Color(1.0, 0.85, 0.0)
var outline_width := 5.0
var corner_radius := 10.0
var button_margin := 16

@export var current_wave: int = 0
@export var wave: int = 1

var _scenes := {}
var _spawner: Node2D
var _spawner_start_pos: Vector2

var _spawn_queue: Array = []
var _spawn_timer: float = 0.0
var _spawning: bool = false
var _auto_mode: bool = false

var _btn: Button
var _canvas: CanvasLayer
var _style_normal: StyleBoxFlat
var _style_hover: StyleBoxFlat
var _style_press: StyleBoxFlat

var _wave_click_count: int = 0
var _alive_enemies: int = 0

func _ready() -> void:
	randomize()
	_try_load_scenes()

	_spawner = get_node_or_null(spawner_path)
	if _spawner:
		_spawner_start_pos = _spawner.global_position

	_build_button()
	get_tree().get_root().size_changed.connect(_reposition_button)

func _try_load_scenes() -> void:
	var paths := {
		"basic": PATH_BASIC,
		"speeder": PATH_SPEEDER,
		"tank": PATH_TANK,
		"camo": PATH_CAMO,
		"boss1": PATH_BOSS,
		"boss2": PATH_BOSS2,
		"boss3": PATH_BOSS3
	}

	for key in paths:
		if ResourceLoader.exists(paths[key]):
			_scenes[key] = load(paths[key])
		else:
			_scenes[key] = null

func _build_button() -> void:
	_btn = Button.new()
	_btn.custom_minimum_size = button_size
	_btn.size = button_size
	_btn.text = ">"

	_style_normal = _make_style(outline_normal)
	_style_hover = _make_style(outline_normal, 0.12)
	_style_press = _make_style(outline_normal, -0.10)

	_btn.add_theme_stylebox_override("normal", _style_normal)
	_btn.add_theme_stylebox_override("hover", _style_hover)
	_btn.add_theme_stylebox_override("pressed", _style_press)

	_btn.add_theme_color_override("font_color", Color.WHITE)
	_btn.add_theme_font_size_override("font_size", 28)

	_btn.pressed.connect(_on_button_pressed)

	_canvas = CanvasLayer.new()
	_canvas.layer = 10
	add_child(_canvas)
	_canvas.add_child(_btn)

	_reposition_button()

func _make_style(outline_col: Color, brightness_offset: float = 0.0) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = button_color.lightened(brightness_offset)
	s.border_color = outline_col
	s.set_border_width_all(int(outline_width))
	s.set_corner_radius_all(int(corner_radius))
	return s

func _reposition_button() -> void:
	var vp := get_tree().get_root().get_visible_rect().size
	_btn.position = Vector2(
		vp.x - button_size.x - button_margin,
		vp.y - button_size.y - button_margin
	)

func _on_button_pressed() -> void:
	_wave_click_count += 1

	if _auto_mode:
		_auto_mode = false
		_set_outline(outline_normal)
		_wave_click_count = 0
		return

	if _wave_click_count >= 2:
		_auto_mode = true
		_set_outline(outline_auto)

	if not _spawning:
		_launch_current_wave()

func _set_outline(col: Color) -> void:
	_style_normal.border_color = col
	_style_hover.border_color = col
	_style_press.border_color = col

func _process(delta: float) -> void:
	_handle_spawning(delta)

const WAVES: Array = [
	[["basic", 20]],
	[["basic", 35]],
	[["basic", 30], ["speeder", 5]],
	[["basic", 35], ["speeder", 15]],
	[["basic", 10], ["speeder", 25]],
	[["basic", 15], ["speeder", 10], ["tank", 10], ["camo", 10]],
	[["basic", 20], ["speeder", 20], ["tank", 15], ["camo", 15]],
	[["basic", 15], ["speeder", 25], ["tank", 20]],
	[["tank", 30]],
	[["basic", 25], ["speeder", 45], ["tank", 5]],

	 #wave 11
	#[["basic", 20], ["tank", 20], ["camo", 10]],
	 #wave 12
	#[["speeder", 35], ["camo", 15]],
	 #wave 13
	#[["tank", 30]],
	 #wave 14
	#[["basic", 25], ["speeder", 25], ["camo", 20]],
	 #wave 15
	#[["basic", 30], ["tank", 20]],

	# wave 16
	#[["tank", 35], ["camo", 20]],
	# wave 17
	#[["speeder", 50]],
	# wave 18
	#[["basic", 40], ["tank", 25]],
	# wave 19
	#[["camo", 40]],
	# wave 20
	#[["tank", 40], ["speeder", 40]],

	# wave 21
	#[["basic", 50]],
	# wave 22
	#[["tank", 45]],
	# wave 23
	#[["speeder", 60]],
	# wave 24
	#[["camo", 50]],
	# wave 25
	#[["basic", 40], ["tank", 40]],

	# wave 26
	#[["speeder", 70]],
	# wave 27
	#[["camo", 60]],
	# wave 28
	#[["tank", 55]],
	# wave 29
	#[["basic", 60], ["speeder", 40]],
	# wave 30
	#[["tank", 60], ["camo", 40]],

	# wave 31
	#[["speeder", 80]],
	# wave 32
	#[["camo", 70]],
	# wave 33
	#[["tank", 70]],
	# wave 34
	#[["basic", 80]],
	# wave 35
	#[["tank", 80], ["camo", 60]],

	# wave 36
	#[["speeder", 90]],
	# wave 37
	#[["camo", 80]],
	# wave 38
	#[["tank", 85]],
	# wave 39
	#[["basic", 100]],
	# wave 40
	#[["tank", 90], ["camo", 70]],

	# wave 41
	#[["speeder", 100]],
	# wave 42
	#[["camo", 100]],
	# wave 43
	#[["tank", 100]],
	# wave 44
	#[["basic", 120]],
	# wave 45
	#[["tank", 120]],

	# wave 46
	#[["speeder", 120]],
	# wave 47
	#[["camo", 120]],
	# wave 48
	#[["tank", 130]],
	# wave 49
	#[["basic", 140]],

	[["boss", 1]]
]

func _launch_current_wave() -> void:
	start_wave(current_wave)

func start_wave(wave_index: int) -> void:
	if wave_index < 0 or wave_index >= WAVES.size():
		return

	_spawn_queue.clear()

	for group in WAVES[wave_index]:
		var type: String = group[0]
		var count: int = group[1]

		if type == "boss":
			type = selected_boss

		for i in count:
			_spawn_queue.append(type)

	_spawn_timer = 0.0
	_spawning = true

func _handle_spawning(delta: float) -> void:
	if not _spawning:
		return

	_spawn_timer -= delta
	if _spawn_timer > 0:
		return

	if _spawn_queue.is_empty():
		_spawning = false
		_on_wave_finished()
		return

	_spawn_next()
	_spawn_timer = spawn_interval

func _on_wave_finished() -> void:
	# Detect if the wave just finished was a boss wave
	var is_boss_wave = false
	for group in WAVES[current_wave]:
		if group[0] == "boss":
			is_boss_wave = true
			break
			
	current_wave += 1
	wave = current_wave + 1

	if is_boss_wave:
		boss_wave_completed.emit()

	
	if current_wave >= WAVES.size():
		current_wave = 0
		wave = 1
		_auto_mode = false
		_set_outline(outline_normal)
		return

	if _auto_mode and _alive_enemies == 0:
		_launch_current_wave()

func _spawn_next() -> void:
	var type: String = _spawn_queue.pop_front()

	if _scenes[type] == null:
		return

	var y_offset := randf_range(-25.0, 25.0)
	var spawn_pos = _spawner_start_pos + Vector2(0, y_offset)

	var instance = _scenes[type].instantiate()
	get_tree().get_root().add_child(instance)
	instance.global_position = spawn_pos

	_alive_enemies += 1
	instance.tree_exited.connect(_on_enemy_died)

func _on_enemy_died() -> void:
	_alive_enemies -= 1
	if _alive_enemies < 0:
		_alive_enemies = 0

	if _auto_mode and not _spawning and _spawn_queue.is_empty() and _alive_enemies == 0:
		_launch_current_wave()

func _on_boss_wave_completed() -> void:
	get_tree().change_scene_to_file("res://Game_win.tscn")
