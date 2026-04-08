extends Node2D

# --- Enemy scene paths (easy to change) ---
const PATH_BASIC   = "res://scenes/enemy_base.tscn"
const PATH_SPEEDER = "res://enemies/speeder_body.tscn"
const PATH_TANK    = "res://enemies/tank_enemy.tscn"
<<<<<<< HEAD
=======
const PATH_CAMO    = "res://enemies/camo_enemy.tscn"

# --- Placeholder enemies ---
const PATH_HEAVY   = "res://enemies/heavy_enemy.tscn"   # placeholder
const PATH_BOSS    = "res://enemies/boss_enemy.tscn"    # placeholder
const PATH_FLYER   = "res://enemies/flyer_enemy.tscn"   # placeholder
>>>>>>> 6e507bd20e927fc484a670d551e60c8415afd52b

# --- Spawner node path (easy to change) ---
const SPAWNER_PATH = "res://EnemySpawner/enemy_spawner.tscn"

# --- Time between individual enemy spawns in seconds ---
var spawn_interval: float = 0.4

# --- Button appearance (easy to change) ---
var button_size    := Vector2(64, 64)
<<<<<<< HEAD
var button_color   := Color(0.18, 0.72, 0.22)   # green fill
var outline_normal := Color(0.05, 0.05, 0.05)    # black outline  (single-wave mode)
var outline_auto   := Color(1.0,  0.85, 0.0)     # yellow outline (auto mode)
var outline_width  : float = 5.0
var corner_radius  : float = 10.0

# --- Bottom-corner button margin from screen edges (easy to change) ---
var button_margin  : int = 16

# --- Current wave (0-indexed internally) ---
=======
var button_color   := Color(0.18, 0.72, 0.22)
var outline_normal := Color(0.05, 0.05, 0.05)
var outline_auto   := Color(1.0,  0.85, 0.0)
var outline_width  : float = 5.0
var corner_radius  : float = 10.0

# --- Bottom-corner button margin ---
var button_margin  : int = 16

# --- Current wave ---
>>>>>>> 6e507bd20e927fc484a670d551e60c8415afd52b
var current_wave: int = 0

var _scenes      := {}
var _spawner     : Node2D
var _spawn_queue : Array = []
var _spawn_timer : float = 0.0
var _spawning    : bool  = false
var _auto_mode   : bool  = false

var _btn         : Button
var _canvas      : CanvasLayer
var _style_normal: StyleBoxFlat
var _style_hover : StyleBoxFlat
var _style_press : StyleBoxFlat

<<<<<<< HEAD
# clicks counted during the current wave; resets when a new wave begins
var _wave_click_count: int = 0

#  Setup

=======
var _wave_click_count: int = 0

# Setup
>>>>>>> 6e507bd20e927fc484a670d551e60c8415afd52b
func _ready() -> void:
	_try_load_scenes()
	_spawner = get_node_or_null(SPAWNER_PATH)
	_build_button()
	get_tree().get_root().size_changed.connect(_reposition_button)

func _try_load_scenes() -> void:
<<<<<<< HEAD
	var paths := {"basic": PATH_BASIC, "speeder": PATH_SPEEDER, "tank": PATH_TANK}
=======
	var paths := {
		"basic": PATH_BASIC,
		"speeder": PATH_SPEEDER,
		"tank": PATH_TANK,
		"camo": PATH_CAMO,
		"heavy": PATH_HEAVY,
		"boss": PATH_BOSS,
		"flyer": PATH_FLYER
	}

>>>>>>> 6e507bd20e927fc484a670d551e60c8415afd52b
	for key in paths:
		if ResourceLoader.exists(paths[key]):
			_scenes[key] = load(paths[key])
		else:
			_scenes[key] = null
			print("Wave Manager: could not find scene for '", key, "' at ", paths[key])

func _build_button() -> void:
	_btn = Button.new()
	_btn.custom_minimum_size = button_size
<<<<<<< HEAD
	_btn.size                = button_size
	_btn.text                = ">"
=======
	_btn.size = button_size
	_btn.text = ">"
>>>>>>> 6e507bd20e927fc484a670d551e60c8415afd52b

	_style_normal = _make_style(outline_normal)
	_style_hover  = _make_style(outline_normal,  0.12)
	_style_press  = _make_style(outline_normal, -0.10)

	_btn.add_theme_stylebox_override("normal",  _style_normal)
	_btn.add_theme_stylebox_override("hover",   _style_hover)
	_btn.add_theme_stylebox_override("pressed", _style_press)
	_btn.add_theme_stylebox_override("focus",   _make_style(outline_normal))
	_btn.add_theme_color_override("font_color", Color.WHITE)
	_btn.add_theme_font_size_override("font_size", 28)

	_btn.pressed.connect(_on_button_pressed)

<<<<<<< HEAD
	# CanvasLayer keeps the button drawn on top of the game world
=======
>>>>>>> 6e507bd20e927fc484a670d551e60c8415afd52b
	_canvas = CanvasLayer.new()
	_canvas.layer = 10
	add_child(_canvas)
	_canvas.add_child(_btn)

	_reposition_button()

func _make_style(outline_col: Color, brightness_offset: float = 0.0) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color     = button_color.lightened(brightness_offset)
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

<<<<<<< HEAD
#  Click handling

func _on_button_pressed() -> void:
	_wave_click_count += 1

	# If already in auto mode → turn it OFF
=======
# Click handling
func _on_button_pressed() -> void:
	_wave_click_count += 1

>>>>>>> 6e507bd20e927fc484a670d551e60c8415afd52b
	if _auto_mode:
		_auto_mode = false
		_set_outline(outline_normal)
		_wave_click_count = 0
		return

<<<<<<< HEAD
	# If not in auto mode → check if we should turn it ON
=======
>>>>>>> 6e507bd20e927fc484a670d551e60c8415afd52b
	if _wave_click_count >= 2:
		_auto_mode = true
		_set_outline(outline_auto)

	if not _spawning:
		_launch_current_wave()

func _process(delta: float) -> void:
	_handle_spawning(delta)

func _set_outline(col: Color) -> void:
	_style_normal.border_color = col
	_style_hover.border_color  = col
	_style_press.border_color  = col

<<<<<<< HEAD
#  Wave data

=======
# Waves (updated with new enemies)
>>>>>>> 6e507bd20e927fc484a670d551e60c8415afd52b
const WAVES: Array = [
	[["basic", 20]],
	[["basic", 35]],
	[["basic", 30], ["speeder", 5]],
	[["basic", 35], ["speeder", 15]],
	[["basic", 10], ["speeder", 25]],
	[["basic", 15], ["speeder", 15], ["tank", 10]],
	[["basic", 20], ["speeder", 20], ["tank", 15]],
	[["basic", 15], ["speeder", 25], ["tank", 20]],
	[["tank", 30]],
<<<<<<< HEAD
	[["basic", 25], ["speeder", 45], ["tank", 5]],
]

#  Spawning

=======
	[["basic", 25], ["speeder", 30], ["tank", 5], ["camo", 10]],
	[["camo", 20], ["speeder", 15]],
	[["heavy", 10], ["basic", 20]],
	[["flyer", 15], ["speeder", 20]],
	[["boss", 3], ["tank", 15]]
]

# Spawning
>>>>>>> 6e507bd20e927fc484a670d551e60c8415afd52b
func _launch_current_wave() -> void:
	start_wave(current_wave)

func start_wave(wave_index: int) -> void:
	if wave_index < 0 or wave_index >= WAVES.size():
		push_error("Wave Manager: invalid wave index " + str(wave_index))
		return

	_spawn_queue.clear()
	for group in WAVES[wave_index]:
		var type : String = group[0]
		var count: int    = group[1]
		for i in count:
			_spawn_queue.append(type)

	_spawn_timer = 0.0
<<<<<<< HEAD
	_spawning    = true
=======
	_spawning = true
>>>>>>> 6e507bd20e927fc484a670d551e60c8415afd52b

func _handle_spawning(delta: float) -> void:
	if not _spawning:
		return

	_spawn_timer -= delta
	if _spawn_timer > 0.0:
		return

	if _spawn_queue.is_empty():
		_spawning = false
		_on_wave_finished()
		return

	_spawn_next()
<<<<<<< HEAD
	_spawn_timer = spawn_interval  # time between spawns

func _on_wave_finished() -> void:
	current_wave      += 1
	_wave_click_count  = 0  # reset click counter for the next wave

	if current_wave >= WAVES.size():
		current_wave = 0
		_auto_mode   = false
=======
	_spawn_timer = spawn_interval

func _on_wave_finished() -> void:
	current_wave += 1
	_wave_click_count = 0

	if current_wave >= WAVES.size():
		current_wave = 0
		_auto_mode = false
>>>>>>> 6e507bd20e927fc484a670d551e60c8415afd52b
		_set_outline(outline_normal)
		return

	if _auto_mode:
		_launch_current_wave()

func _spawn_next() -> void:
	var type: String = _spawn_queue.pop_front()

	if _scenes[type] != null:
		var instance = _scenes[type].instantiate()
		if _spawner != null:
			_spawner.add_child(instance)
			instance.global_position = _spawner.global_position
		else:
			add_child(instance)
	else:
		print("Wave Manager: spawning ", type, " (scene not found, placeholder)")
