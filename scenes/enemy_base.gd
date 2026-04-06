extends CharacterBody2D
class_name Enemy

@export var speed = 35
@export var hp = 100
@export var direction = 1

# sees the progress of the enemy across the track
var progress = 0

func _ready():
	pass

func _process(delta):
	progress += 1 * delta

	if direction == 1:#Right
		position.x += delta*speed
	elif direction == 2:#Up
		position.y -= delta*speed
	elif direction == 3:#Left
		position.x -= delta*speed
	elif direction == 4:#Down
		position.y += delta*speed

	if hp <= 100:
		$sprite.modulate = Color(hp / 100.0, hp / 100.0, hp / 100.0)

	if hp <= 0:
		die()

func lose_hp(dmg):
	hp -= dmg

func die():
	# Add money to UI
	var ui = get_tree().root.get_node_or_null("UI")
	if ui and ui.has_method("add_money"):
		ui.add_money(20)
	queue_free()
