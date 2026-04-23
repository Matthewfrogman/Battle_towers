extends Tower

func get_upgrade_data() -> Array:
	return [
		[
			{"name": "Extended Pulse",   "cost": 500,  "desc": "Increases attack range."},
			{"name": "Wide Broadcast",   "cost": 900,  "desc": "Greatly increases attack range."},
			{"name": "Orbital Cannon",   "cost": 9000, "desc": "Extreme range increase and gains pierce."}
		],
		[
			{"name": "Overclock",        "cost": 600,  "desc": "Fires significantly faster."},
			{"name": "Hyperdrive",       "cost": 1100, "desc": "Pushes fire rate to its limit."},
			{"name": "Blinding Speed",   "cost": 10000, "desc": "Fires at an absolutely insane rate."}
		],
		[
			{"name": "Reflex Circuit",   "cost": 450,  "desc": "Increases damage output."},
			{"name": "Unstoppable",      "cost": 850,  "desc": "Significantly more damage per shot."},
			{"name": "Annihilator",      "cost": 8500, "desc": "Triples damage output and adds pierce."}
		],
	]

func upgrade(upg_path: int):
	if path[upg_path-1] == 3:
		return null
	path[upg_path-1] += 1
	if upg_path == 1:
		if path[upg_path-1] == 1:
			attack_range += 2
		elif path[upg_path-1] == 2:
			attack_range += 3
		elif path[upg_path-1] == 3:
			attack_range += 8
			pierce += 2
	elif upg_path == 2:
		if path[upg_path-1] == 1:
			cooldown -= 0.05
		elif path[upg_path-1] == 2:
			cooldown -= 0.05
		elif path[upg_path-1] == 3:
			cooldown -= 0.08
	elif upg_path == 3:
		if path[upg_path-1] == 1:
			attack += 5
		elif path[upg_path-1] == 2:
			attack += 10
		elif path[upg_path-1] == 3:
			attack += attack * 2
			pierce += 1
	return "its real"
