extends CharacterBody2D
class_name Enemy

@onready var debuff_texture = get_node("Debuff")

@export var speed = 35
@export var max_hp: int
@export var hp = 100
@export var direction = 1
@export var dmg_to_player = 1
@export var camo: bool = false
@export var boss: bool = false
@export var death_sound: AudioStream
@export var death_sound_volume: float = 0.0
# progress tracks how long the enemy has been alive — higher = further along the track
var progress: float = 0.0
# checks to see if the enemy is debuffed or not before applying one
var debuffed: bool = false
var slowed: bool = false
var _base_speed: int = 0

func _ready():
	if max_hp == 0:
		max_hp = hp
	_base_speed = speed

func _process(delta):
	if debuffed:
		debuff_texture.visible = true
	else:
		debuff_texture.visible = false
	
	progress += 1 * delta
	if direction == 1: # Right
		position.x += delta * speed
	elif direction == 2: # Up
		position.y -= delta * speed
	elif direction == 3: # Left
		position.x -= delta * speed
	elif direction == 4: # Down
		position.y += delta * speed
	if hp < max_hp:
		var ratio = clampf(float(hp) / float(max_hp), 0.0, 1.0)
		if slowed:
			modulate = Color(ratio * 0.5, ratio * 0.7, ratio * 1.0)
		else:
			modulate = Color(ratio, ratio, ratio)

func lose_hp(dmg):
	hp -= dmg
	if hp <= 0:
		die()

func die():
	# Find the shop UI via group (reliable regardless of node name changes)
	var ui_nodes = get_tree().get_nodes_in_group("shop_ui")
	if ui_nodes.size() > 0:
		ui_nodes[0].add_money(20)
	if death_sound:
		var audio = AudioStreamPlayer.new()
		audio.stream = death_sound
		audio.volume_db = death_sound_volume
		audio.bus = "Master"
		get_tree().root.add_child(audio)
		audio.play()
		audio.finished.connect(audio.queue_free)
	queue_free()

func slow(duration: float) -> void:
	# Slows enemy to half speed with blue tint. No effect on bosses.
	if boss or slowed:
		return
	slowed = true
	speed = int(_base_speed / 2.0)
	var t = get_tree().create_timer(duration)
	t.timeout.connect(func():
		slowed = false
		speed = _base_speed
	)

func _exit_tree() -> void:
	pass

func debuff(debuff_type: String, debuff_dmg: int, interval: float, intervals: int, camo_remove: bool):
	#creates a debuff on the enemy if it doesnt have one already
	if debuffed == true:
		return null
	debuffed = true
	if camo_remove:
		camo = false
	for i in intervals:
		await get_tree().create_timer(interval).timeout
		if not is_instance_valid(self):
			return
		hp -= debuff_dmg
		if hp <= 0:
			die()
			return
	debuffed = false
