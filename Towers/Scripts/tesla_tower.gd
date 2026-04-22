extends Tower

# Tesla tower — behavior handled by base Tower/basic_tower logic.
# This script only adds upgrade data and overrides upgrade().

func get_upgrade_data() -> Array:
	return [
		[
			{"name": "Capacitor Boost",  "cost": 700,  "desc": "Increases arc damage."},
			{"name": "Overcharge",       "cost": 1300, "desc": "Significantly more damage per arc."}
		],
		[
			{"name": "Rapid Discharge",  "cost": 650,  "desc": "Reduces the interval between arcs."},
			{"name": "Chain Reaction",   "cost": 1200, "desc": "Further reduces cooldown."}
		],
		[
			{"name": "Extended Range",   "cost": 600,  "desc": "Increases the tower's attack range."},
			{"name": "Surge Field",      "cost": 1100, "desc": "Greatly extends the arc range."}
		],
	]

func upgrade(upg_path: int):
	if path[upg_path-1] == 2:
		return null
	path[upg_path-1] += 1
	if upg_path == 1:
		if path[upg_path-1] == 1:
			attack += 10
		elif path[upg_path-1] == 2:
			attack += 20
	elif upg_path == 2:
		if path[upg_path-1] == 1:
			cooldown -= 0.5
		elif path[upg_path-1] == 2:
			cooldown -= 0.75
	elif upg_path == 3:
		if path[upg_path-1] == 1:
			attack_range += 2
		elif path[upg_path-1] == 2:
			attack_range += 3
	return "its real"
