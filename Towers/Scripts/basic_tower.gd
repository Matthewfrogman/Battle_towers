extends Tower

func upgrade(upg_path: int):
	#for all the simple upgrades, and actually upgrades the tower
	if path[upg_path-1] == 2:
		return null
	path[upg_path-1]+=1
	if upg_path == 1:
		if path[upg_path-1] == 1:
			pierce += 1
		if path[upg_path-1] == 2:
			pierce += 2
	elif upg_path == 1:
		if path[upg_path-1] == 1:
			projectiles += 2
		if path[upg_path-1] == 2:
			projectiles += 2
	elif upg_path == 1:
		if path[upg_path-1] == 1:
			cooldown -= 0.5
		if path[upg_path-1] == 2:
			cooldown -= 0.25
	return "its real"
