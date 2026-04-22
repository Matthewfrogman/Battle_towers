extends Tower

func get_upgrade_data() -> Array:
	return [
		[
			{"name": "Extended Pulse",   "cost": 500,  "desc": "Increases attack range."},
			{"name": "Wide Broadcast",   "cost": 900,  "desc": "Greatly increases attack range."}
		],
		[
			{"name": "Overclock",        "cost": 600,  "desc": "Fires significantly faster."},
			{"name": "Hyperdrive",       "cost": 1100, "desc": "Pushes fire rate to its limit."}
		],
		[
			{"name": "Reflex Circuit",   "cost": 450,  "desc": "Increases damage output."},
			{"name": "Unstoppable",      "cost": 850,  "desc": "Significantly more damage per shot."}
		],
	]

func upgrade(upg_path: int):
	if path[upg_path-1] == 2:
		return null
	path[upg_path-1] += 1
	if upg_path == 1:
		if path[upg_path-1] == 1:
			attack_range += 2
		elif path[upg_path-1] == 2:
			attack_range += 3
	elif upg_path == 2:
		if path[upg_path-1] == 1:
			cooldown -= 0.15
		elif path[upg_path-1] == 2:
			cooldown -= 0.2
	elif upg_path == 3:
		if path[upg_path-1] == 1:
			attack += 5
		elif path[upg_path-1] == 2:
			attack += 10
	return
