extends Tower

@onready var muzzle_sprite = get_node("Cannon/muzzleflash")

func get_upgrade_data() -> Array:
	return [
		[
			{"name": "Hollow Point",     "cost": 600,  "desc": "Rounds deal significantly more damage."},
			{"name": "Explosive Round",  "cost": 1200, "desc": "Each shot also deals bonus percent HP damage."}
		],
		[
			{"name": "Steady Hands",     "cost": 500,  "desc": "Reduces time between shots."},
			{"name": "Semi-Auto",        "cost": 1100, "desc": "Greatly reduces cooldown."}
		],
		[
			{"name": "Infrared Scope",   "cost": 700,  "desc": "Detects and targets camo enemies."},
			{"name": "Camo Shred",       "cost": 1300, "desc": "Deals bonus damage to camo enemies."}
		],
	]

func _process(_delta: float) -> void:
	super(_delta)
	if canshoot and sees_enemy:
		if enemies["first"] is Array and (
			not enemies["first"][0].camo or enemies["first"][0].camo and sees_camo):
			muzzle_sprite.visible = true
			enemies["first"][0].hp -= attack
			upg_attack(enemies["first"][0])
			canshoot = false
			await get_tree().create_timer(0.1).timeout
			muzzle_sprite.visible = false

func upgrade(upg_path: int):
	if path[upg_path-1] == 2:
		return null
	path[upg_path-1] += 1
	if upg_path == 1:
		if path[upg_path-1] == 1:
			attack += 25
		if path[upg_path-1] == 2:
			attack += 50
	elif upg_path == 2:
		if path[upg_path-1] == 1:
			cooldown -= 1.0
		if path[upg_path-1] == 2:
			cooldown -= 1.5
	elif upg_path == 3:
		if path[upg_path-1] == 1:
			sees_camo = true
		if path[upg_path-1] == 2:
			pass  # applied in upg_attack
	return "its real"

func upg_attack(enemy: Enemy):
	if path[0] == 2:
		enemy.hp -= roundi(enemy.max_hp / 50.0)
	if path[1] == 2:
		enemy.debuff("fire", 2, 0.1, 5, false)
	if path[2] == 2:
		if enemy.camo:
			enemy.hp -= 10
