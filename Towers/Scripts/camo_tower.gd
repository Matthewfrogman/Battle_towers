extends Tower

func get_upgrade_data() -> Array:
	return [
		[
			{"name": "Twin Barrel",      "cost": 550,  "desc": "Fires two additional projectiles at once."},
			{"name": "Quad Barrel",      "cost": 1000, "desc": "Fires two more projectiles on top of that."}
		],
		[
			{"name": "Lubricated",       "cost": 500,  "desc": "Cooldown is reduced significantly."},
			{"name": "Overdrive",        "cost": 950,  "desc": "Pushes the mechanism past its limits."}
		],
		[
			{"name": "Thermal Lens",     "cost": 600,  "desc": "Allows targeting of camo enemies."},
			{"name": "Full Spectrum",    "cost": 1100, "desc": "Greatly increases range as well."}
		],
	]

func upgrade(upg_path: int):
	if path[upg_path-1] == 2:
		return null
	path[upg_path-1] += 1
	if upg_path == 1:
		if path[upg_path-1] == 1:
			projectiles += 2
		elif path[upg_path-1] == 2:
			projectiles += 2
	elif upg_path == 2:
		if path[upg_path-1] == 1:
			cooldown -= 1.0
		elif path[upg_path-1] == 2:
			cooldown -= 1.0
	elif upg_path == 3:
		if path[upg_path-1] == 1:
			sees_camo = true
		elif path[upg_path-1] == 2:
			attack_range += 3
	return "its real"
