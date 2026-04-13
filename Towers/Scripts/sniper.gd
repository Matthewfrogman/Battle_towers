extends Tower

#keep the projectiles, bullet speed, pierce, and bullet scene 0 or empty
func _process(_delta: float) -> void:
	super(_delta)
	if canshoot and sees_enemy:
		if enemies["first"] is Array:
			enemies["first"][0].hp -= attack
			canshoot = false
