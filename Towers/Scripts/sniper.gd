extends Tower

@onready var muzzle_sprite = get_node("Cannon/muzzleflash")

#keep the projectiles, bullet speed, pierce, and bullet scene 0 or empty
func _process(_delta: float) -> void:
	super(_delta)
	if canshoot and sees_enemy:
		if enemies["first"] is Array:
			muzzle_sprite.visible = true
			enemies["first"][0].hp -= attack
			canshoot = false
			await get_tree().create_timer(0.1).timeout
			muzzle_sprite.visible = false

func upgrade(path: int):
	#based on the path given
	#store 
	pass
