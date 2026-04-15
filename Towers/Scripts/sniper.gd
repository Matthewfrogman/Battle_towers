extends Tower

@onready var muzzle_sprite = get_node("Cannon/muzzleflash")

#keep the projectiles, bullet speed, pierce, and bullet scene 0 or empty
func _process(_delta: float) -> void:
	super(_delta)
	if canshoot and sees_enemy:
		if enemies["first"] is Array:
			muzzle_sprite.visible = true
			enemies["first"][0].hp -= attack
			upg_attack(enemies["first"][0])
			canshoot = false
			await get_tree().create_timer(0.1).timeout
			muzzle_sprite.visible = false

func upgrade(upg_path: int):
	#based on the path given
	if path[upg_path-1] == 2:
		return null
	path[upg_path-1]+=1
	if upg_path == 1 and path[upg_path-1] == 1:
		attack += 10
	elif upg_path == 2 and path[upg_path-1] == 2:
		cooldown -= 1
	elif upg_path == 3 and path[upg_path-1] == 3:
		sees_camo = true

func upg_attack(enemy: Enemy):
	if path[0] == 2:
		enemy.hp -= roundi(enemy.max_hp/50.0)
	elif path[1] == 2:
		enemy.debuff(2, 0.1, 5)
	elif path[2] == 2:
		if enemy.camo == true:
			enemy.hp -= 10
