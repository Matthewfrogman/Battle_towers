extends Tower

@onready var muzzle_sprite = get_node("Cannon/muzzleflash")

func get_upgrade_data() -> Array:
	return [
		[
			{"name": "Hollow Point",     "cost": 600,  "desc": "Rounds deal significantly more damage."},
			{"name": "Explosive Round",  "cost": 1200, "desc": "Each shot also deals bonus percent HP damage."},
			{"name": "Death Mark",       "cost": 11000, "desc": "Enemies below 25% HP are instantly killed (non-boss)."}
		],
		[
			{"name": "Steady Hands",     "cost": 500,  "desc": "Reduces time between shots."},
			{"name": "Semi-Auto",        "cost": 1100, "desc": "Greatly reduces cooldown."},
			{"name": "Lightning Reflex", "cost": 9000, "desc": "Fires at an extreme rate and gains extra pierce."}
		],
		[
			{"name": "Infrared Scope",   "cost": 700,  "desc": "Detects and targets camo enemies."},
			{"name": "Camo Shred",       "cost": 1300, "desc": "Deals bonus damage to camo enemies."},
			{"name": "Shadow Hunter",    "cost": 8000, "desc": "Deals massive bonus damage to camo enemies and reveals them."}
		],
	]

func _process(_delta: float) -> void:
	super(_delta)
	if canshoot and sees_enemy:
		var target = enemies["first"]
		if target is Array and is_instance_valid(target[0]) and (
				not target[0].camo or sees_camo):
			muzzle_sprite.visible = true
			target[0].lose_hp(attack)
			upg_attack(target[0])
			canshoot = false
			await get_tree().create_timer(0.1).timeout
			if is_instance_valid(muzzle_sprite):
				muzzle_sprite.visible = false

func upgrade(upg_path: int):
	if path[upg_path-1] == 3:
		return null
	path[upg_path-1] += 1
	if upg_path == 1:
		if path[upg_path-1] == 1:
			attack += 25
		elif path[upg_path-1] == 2:
			attack += 50
		elif path[upg_path-1] == 3:
			pass  # applied in upg_attack
	elif upg_path == 2:
		if path[upg_path-1] == 1:
			cooldown -= 1.0
		elif path[upg_path-1] == 2:
			cooldown -= 1.5
		elif path[upg_path-1] == 3:
			cooldown -= 1.0
			pierce += 3
	elif upg_path == 3:
		if path[upg_path-1] == 1:
			sees_camo = true
		elif path[upg_path-1] == 2:
			pass  # applied in upg_attack
		elif path[upg_path-1] == 3:
			pass  # applied in upg_attack
	return "its real"

func upg_attack(enemy: Enemy):
	# Path 1 tier 2: 2% max HP per shot (not on bosses)
	if path[0] >= 2:
		if not enemy.boss:
			enemy.hp -= roundi(enemy.max_hp / 50.0)
	# Path 1 tier 3: Instantly kill non-boss enemies below 25% HP
	if path[0] == 3:
		if not enemy.boss and enemy.hp < enemy.max_hp * 0.25:
			enemy.hp = 0
	# Path 2 tier 2: fire debuff
	if path[1] >= 2:
		enemy.debuff("fire", 2, 0.1, 5, false)
	# Path 3 tier 2: bonus camo damage
	if path[2] >= 2:
		if enemy.camo:
			enemy.hp -= 10
	# Path 3 tier 3: heavy camo damage and reveal
	if path[2] == 3:
		if enemy.camo:
			enemy.hp -= 40
			enemy.camo = false
