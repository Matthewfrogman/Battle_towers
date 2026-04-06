extends CharacterBody2D
@export var speed = 35
@export var hp = 100
@export var direction = 1

func _ready():
	pass
	
func _process(delta):
	if direction == 1:
		position.x += delta*speed
	elif direction == 2:
		position.y -= delta*speed
	elif direction == 3:
		position.x -= delta*speed
	elif direction == 4:
		position.y += delta*speed
	
	if hp <= 100:
		$sprite.modulate = Color(hp/100.0, hp/100.0, hp/100.0)
	
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
