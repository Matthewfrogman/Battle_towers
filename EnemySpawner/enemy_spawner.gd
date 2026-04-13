extends Node2D

# --- Enemy scene paths (easy to change) ---
const PATH_BASIC   = "res://scenes/enemy_base.tscn"
const PATH_SPEEDER = "res://enemies/speeder_body.tscn"
const PATH_TANK    = "res://enemies/tank_enemy.tscn"
const PATH_CAMO    = "res://enemies/camo_enemy.tscn"
# --- Placeholder enemies ---
const PATH_BOSS    = "res://enemies/boss_enemy.tscn"
const PATH_FLYER   = "res://enemies/flyer_enemy.tscn"

# --- Spawner NODE path (NOT res://) ---
@export var spawner_path: NodePath

# --- Time between individual enemy spawns ---
var spawn_interval: float = 0.4

# --- Button appearance ---
var button_size    := Vector2(64, 64)
var button_color   := Color(0.18, 0.72, 0.22)   # green fill
var outline_normal := Color(0.05, 0.05, 0.05)    # black outline  (single-wave mode)
var outline_auto   := Color(1.0,  0.85, 0.0)     # yellow outline (auto mode)
var outline_width  : float = 5.0
var corner_radius  : float = 10.0

# --- Bottom-corner button margin from screen edges (easy to change) ---
var button_margin  : int = 16

# --- Current wave (0-indexed internally) ---
var current_wave: int = 0

var _scenes      := {}
var _spawner     : Node2D
var _spawner_start_pos: Vector2

var _spawn_queue : Array = []
var _spawn_timer : float = 0.0
var _spawning    : bool  = false
var _auto_mode   : bool  = false

var _btn         : Button
var _canvas      : CanvasLayer
var _style_normal: StyleBoxFlat
var _style_hover : StyleBoxFlat
var _style_press : StyleBoxFlat

# clicks counted during the current wave; resets when a new wave begins
var _wave_click_count: int = 0

#  Setup

func _ready() -> void:
	randomize()

	_try_load_scenes()

	_spawner = get_node_or_null(spawner_path)
	if _spawner == null:
		push_error("Spawner not found! Assign it in the inspector.")
	else:
		_spawner_start_pos = _spawner.global_position

	_build_button()
	get_tree().get_root().size_changed.connect(_reposition_button)

func _try_load_scenes() -> void:
	var paths := {
		"basic": PATH_BASIC,
		"speeder": PATH_SPEEDER,
		"tank": PATH_TANK,
		"camo": PATH_CAMO,
		"boss": PATH_BOSS,
		"flyer": PATH_FLYER
	}

	for key in paths:
		if ResourceLoader.exists(paths[key]):
			_scenes[key] = load(paths[key])
		else:
			_scenes[key] = null
			print("Wave Manager: could not find scene for '", key, "' at ", paths[key])

func _build_button() -> void:
	_btn = Button.new()
	_btn.custom_minimum_size = button_size
	_btn.size                = button_size
	_btn.text                = ">"

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

	# CanvasLayer keeps the button drawn on top of the game world
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

#  Click handling

func _on_button_pressed() -> void:
	_wave_click_count += 1

	# If already in auto mode → turn it OFF
	if _auto_mode:
		_auto_mode = false
		_set_outline(outline_normal)
		_wave_click_count = 0
		return

	# If not in auto mode → check if we should turn it ON
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

# Waves
#  Wave data

const WAVES: Array = [
	[["basic", 20]],
	[["basic", 35]],
	[["basic", 30], ["speeder", 5]],
	[["basic", 35], ["speeder", 15]],
	[["basic", 10], ["speeder", 25]],
	[["basic", 15], ["speeder", 10], ["tank", 10],["camo", 10]],
	[["basic", 20], ["speeder", 20], ["tank", 15],["camo", 15]],
	[["basic", 15], ["speeder", 25], ["tank", 20]],
	[["tank", 30]],
	[["basic", 25], ["speeder", 45], ["tank", 5]],
]

#  Spawning

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
	_spawning    = true

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
	_spawn_timer = spawn_interval  # time between spawns

func _on_wave_finished() -> void:
	current_wave      += 1
	_wave_click_count  = 0  # reset click counter for the next wave

	if current_wave >= WAVES.size():
		current_wave = 0
		_auto_mode   = false
		_set_outline(outline_normal)
		return

	if _auto_mode:
		_launch_current_wave()

func _spawn_next() -> void:
	var type: String = _spawn_queue.pop_front()

	if _scenes[type] == null:
		print("Missing scene for ", type)
		return

	# Move spawner randomly on Y based on ORIGINAL position
	var y_offset := randf_range(-25.0, 25.0)
	var spawn_pos = _spawner_start_pos + Vector2(0, y_offset)

	var instance = _scenes[type].instantiate()

	# Add to the scene root or an enemies container, not the spawner
	get_tree().get_root().add_child(instance)
	instance.global_position = spawn_pos
