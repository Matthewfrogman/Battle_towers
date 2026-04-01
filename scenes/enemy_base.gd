extends CharacterBody2D

@export var speed = 67
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
		$sprite.modulate = Color(hp/100.0,hp/100.0,hp/100.0)
	
	if hp <= 0:
		queue_free()
	
func lose_hp(dmg):
	hp -= dmg
	
