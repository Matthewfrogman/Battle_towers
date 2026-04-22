extends Tower

func get_upgrade_data() -> Array:
	return [
		[
			{"name": "Reinforced Tips",  "cost": 650,  "desc": "Bullets pierce through one additional enemy."},
			{"name": "Armor Piercing",   "cost": 1250, "desc": "Bullets pierce one more enemy on top of that."}
		],
		[
			{"name": "Scatter Shot",     "cost": 750,  "desc": "Fires two extra projectiles per volley."},
			{"name": "Volley Fire",      "cost": 1500, "desc": "Fires two more projectiles, saturating the area."}
		],
		[
			{"name": "Oiled Mechanism",  "cost": 500,  "desc": "Reduces attack cooldown slightly."},
			{"name": "Hair Trigger",     "cost": 950,  "desc": "Further reduces cooldown."}
		],
	]

func upgrade(upg_path: int):
	if path[upg_path-1] == 2:
		return null
	path[upg_path-1] += 1
	if upg_path == 1:
		if path[upg_path-1] == 1:
			pierce += 1
		if path[upg_path-1] == 2:
			pierce += 1
	elif upg_path == 2:
		if path[upg_path-1] == 1:
			projectiles += 2
		if path[upg_path-1] == 2:
			projectiles += 2
	elif upg_path == 3:
		if path[upg_path-1] == 1:
			cooldown -= 0.2
		if path[upg_path-1] == 2:
			cooldown -= 0.3
	return "its real"
