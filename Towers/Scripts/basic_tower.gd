extends Tower

func get_upgrade_data() -> Array:
	return [
		[
			{"name": "Reinforced Tips",  "cost": 650,  "desc": "Bullets pierce through one additional enemy."},
			{"name": "Armor Piercing",   "cost": 1250, "desc": "Bullets pierce one more enemy on top of that."},
			{"name": "Uranium Core",     "cost": 9000, "desc": "Bullets pierce through three more enemies."}
		],
		[
			{"name": "Scatter Shot",     "cost": 750,  "desc": "Fires an extra projectile per volley."},
			{"name": "Volley Fire",      "cost": 1500, "desc": "Fires one more projectile, saturating the area."},
			{"name": "Bullet Hell",      "cost": 10000, "desc": "Fires four extra projectiles."}
		],
		[
			{"name": "Oiled Mechanism",  "cost": 500,  "desc": "Reduces attack cooldown slightly."},
			{"name": "Hair Trigger",     "cost": 950,  "desc": "Further reduces cooldown."},
			{"name": "Minigun Barrel",   "cost": 8500, "desc": "Massively increases fire rate."}
		],
	]


func upgrade(upg_path: int):
	if path[upg_path-1] == 3:
		return null
	path[upg_path-1] += 1
	if upg_path == 1:
		if path[upg_path-1] == 1:
			pierce += 1
		elif path[upg_path-1] == 2:
			pierce += 1
		elif path[upg_path-1] == 3:
			pierce += 3
	elif upg_path == 2:
		if path[upg_path-1] == 1:
			projectiles += 1
		elif path[upg_path-1] == 2:
			projectiles += 1
		elif path[upg_path-1] == 3:
			projectiles += 4
	elif upg_path == 3:
		if path[upg_path-1] == 1:
			cooldown -= 0.05
		elif path[upg_path-1] == 2:
			cooldown -= 0.05
		elif path[upg_path-1] == 3:
			cooldown -= 0.2
	return "its real"
