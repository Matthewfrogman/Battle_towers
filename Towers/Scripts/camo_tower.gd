extends Tower

func upgrade(upg_path: int):
	#for all the simple upgrades, and actually upgrades the tower
	if path[upg_path-1] == 2:
		return null
	path[upg_path-1]+=1
	if upg_path == 1:
		if path[upg_path-1] == 1:
			projectiles += 2
		elif path[upg_path-1] == 2:
			projectiles += 2
	elif upg_path == 2:
		if path[upg_path-1] == 1:
			cooldown -= 1
		elif path[upg_path-1] == 2:
			cooldown -= 1
	return null
