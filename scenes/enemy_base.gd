extends CharacterBody2D
class_name Enemy
@export var speed = 35
@export var hp = 100
@export var direction = 1
@export var dmg_to_player = 50
@export var camo: bool = false
# sees the progress of the enemy across the track
var progress: int = 0

func _ready():
	pass

func _process(delta):
	progress += 1 * delta
	if direction == 1: # Right
		position.x += delta * speed
	elif direction == 2: # Up
		position.y -= delta * speed
	elif direction == 3: # Left
		position.x -= delta * speed
	elif direction == 4: # Down
		position.y += delta * speed
	if hp <= 100:
		modulate = Color(hp / 100.0, hp / 100.0, hp / 100.0)
	if hp <= 0:
		die()

func lose_hp(dmg):
	hp -= dmg

func die():
	# Find the shop UI via group (reliable regardless of node name changes)
	var ui_nodes = get_tree().get_nodes_in_group("shop_ui")
	if ui_nodes.size() > 0:
		ui_nodes[0].add_money(20)
	queue_free()
