extends Tower

func get_upgrade_data() -> Array:
	return [
		[
			{"name": "Twin Barrel",      "cost": 550,  "desc": "Fires two additional projectiles at once."},
			{"name": "Quad Barrel",      "cost": 1000, "desc": "Fires two more projectiles on top of that."},
			{"name": "Gatling Rounds",   "cost": 9500, "desc": "Fires six additional projectiles simultaneously."}
		],
		[
			{"name": "Lubricated",       "cost": 500,  "desc": "Cooldown is reduced significantly."},
			{"name": "Overdrive",        "cost": 950,  "desc": "Pushes the mechanism past its limits."},
			{"name": "Ludicrous Speed",  "cost": 10000, "desc": "Absurdly fast cooldown reduction."}
		],
		[
			{"name": "Thermal Lens",     "cost": 600,  "desc": "Range is increased for maximum efficiency."},
			{"name": "Full Spectrum",    "cost": 1100, "desc": "Greatly increases range."},
			{"name": "Phantom Field",    "cost": 8000, "desc": "Massively increases range and deals double damage to camo enemies."}
		],
	]

func upgrade(upg_path: int):
	if path[upg_path-1] == 3:
		return null
	path[upg_path-1] += 1
	if upg_path == 1:
		if path[upg_path-1] == 1:
			projectiles += 2
		elif path[upg_path-1] == 2:
			projectiles += 2
		elif path[upg_path-1] == 3:
			projectiles += 6
	elif upg_path == 2:
		if path[upg_path-1] == 1:
			cooldown -= 1.0
		elif path[upg_path-1] == 2:
			cooldown -= 1.0
		elif path[upg_path-1] == 3:
			cooldown -= 1.5
	elif upg_path == 3:
		if path[upg_path-1] == 1:
			attack_range += 1
		elif path[upg_path-1] == 2:
			attack_range += 3
		elif path[upg_path-1] == 3:
			attack_range += 4
			sees_camo = true
	return "its real"
