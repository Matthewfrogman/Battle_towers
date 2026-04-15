extends Node2D

const PATH_BASIC   = "res://scenes/enemy_base.tscn"
const PATH_SPEEDER = "res://enemies/speeder_body.tscn"
const PATH_TANK    = "res://enemies/tank_enemy.tscn"
const PATH_CAMO    = "res://enemies/camo_enemy.tscn"

const PATH_BOSS    = "res://enemies/Boss_1.tscn"
const PATH_BOSS2   = "res://enemies/Boss_2.tscn"
const PATH_BOSS3   = "res://enemies/Boss_3.tscn"

@export_enum("boss1", "boss2", "boss3") var selected_boss: String = "boss1"

@export var spawner_path: NodePath

var spawn_interval: float = 0.4

var current_wave: int = 0
var wave: int = 1

var _scenes := {}
var _spawner: Node2D
var _spawner_start_pos: Vector2

var _spawn_queue: Array = []
var _spawn_timer: float = 0.0
var _spawning: bool = false
var _auto_mode: bool = false

func _ready() -> void:
	randomize()
	_try_load_scenes()
	_spawner = get_node_or_null(spawner_path)
	if _spawner:
		_spawner_start_pos = _spawner.global_position

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

const WAVES: Array = [
	[["basic", 20]],
	[["basic", 30]],
	[["basic", 25], ["speeder", 10]],
	[["basic", 30], ["speeder", 15]],
	[["basic", 20], ["speeder", 25]],
	[["basic", 15], ["tank", 10]],
	[["basic", 20], ["tank", 15]],
	[["speeder", 40]],
	[["tank", 25]],
	[["basic", 30], ["speeder", 30]],

	[["basic", 20], ["tank", 20], ["camo", 10]],
	[["speeder", 35], ["camo", 15]],
	[["tank", 30]],
	[["basic", 25], ["speeder", 25], ["camo", 20]],
	[["basic", 30], ["tank", 20]],

	[["tank", 35], ["camo", 20]],
	[["speeder", 50]],
	[["basic", 40], ["tank", 25]],
	[["camo", 40]],
	[["tank", 40], ["speeder", 40]],

	[["basic", 50]],
	[["tank", 45]],
	[["speeder", 60]],
	[["camo", 50]],
	[["basic", 40], ["tank", 40]],

	[["speeder", 70]],
	[["camo", 60]],
	[["tank", 55]],
	[["basic", 60], ["speeder", 40]],
	[["tank", 60], ["camo", 40]],

	[["speeder", 80]],
	[["camo", 70]],
	[["tank", 70]],
	[["basic", 80]],
	[["tank", 80], ["camo", 60]],

	[["speeder", 90]],
	[["camo", 80]],
	[["tank", 85]],
	[["basic", 100]],
	[["tank", 90], ["camo", 70]],

	[["speeder", 100]],
	[["camo", 100]],
	[["tank", 100]],
	[["basic", 120]],
	[["tank", 120]],

	[["speeder", 120]],
	[["camo", 120]],
	[["tank", 130]],
	[["basic", 140]],

	[["boss", 1]]
]

func _process(delta: float) -> void:
	_handle_spawning(delta)

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
	current_wave += 1
	wave = current_wave + 1

	if current_wave >= WAVES.size():
		current_wave = 0
		wave = 1

func _spawn_next() -> void:
	var type: String = _spawn_queue.pop_front()

	if _scenes[type] == null:
		return

	var y_offset := randf_range(-25.0, 25.0)
	var spawn_pos = _spawner_start_pos + Vector2(0, y_offset)

	var instance = _scenes[type].instantiate()
	get_tree().get_root().add_child(instance)
	instance.global_position = spawn_pos
