extends Tower

# Tesla tower — applies a slow debuff on every hit.
# Upgrades: path 1 = damage, path 2 = cooldown, path 3 = range.

const SLOW_DURATION_BASE: float = 1.5
var slow_duration: float = SLOW_DURATION_BASE

func get_upgrade_data() -> Array:
	return [
		[
			{"name": "Capacitor Boost",  "cost": 700,  "desc": "Increases arc damage."},
			{"name": "Overcharge",       "cost": 1300, "desc": "Significantly more damage per arc."},
			{"name": "Storm Surge",      "cost": 10000, "desc": "Massively increases damage and chains arc to 3 nearby enemies."}
		],
		[
			{"name": "Rapid Discharge",  "cost": 650,  "desc": "Reduces the interval between arcs."},
			{"name": "Chain Reaction",   "cost": 1200, "desc": "Further reduces cooldown."},
			{"name": "Rapid Pulse",      "cost": 9000, "desc": "Extreme cooldown and arc hits 2 enemies at once."}
		],
		[
			{"name": "Extended Range",   "cost": 600,  "desc": "Increases the tower's attack range."},
			{"name": "Surge Field",      "cost": 1100, "desc": "Greatly extends the arc range."},
			{"name": "Total Paralysis",  "cost": 8000, "desc": "Massively increases range and slow duration. Slows bosses."}
		],
	]

func upgrade(upg_path: int):
	if path[upg_path-1] == 3:
		return null
	path[upg_path-1] += 1
	if upg_path == 1:
		if path[upg_path-1] == 1:
			attack += 10
		elif path[upg_path-1] == 2:
			attack += 20
		elif path[upg_path-1] == 3:
			attack += 50
			pierce += 2  # chain to extra targets
	elif upg_path == 2:
		if path[upg_path-1] == 1:
			cooldown -= 0.5
		elif path[upg_path-1] == 2:
			cooldown -= 0.75
		elif path[upg_path-1] == 3:
			cooldown -= 0.5
			pierce += 1
	elif upg_path == 3:
		if path[upg_path-1] == 1:
			attack_range += 2
			slow_duration += 0.75
		elif path[upg_path-1] == 2:
			attack_range += 3
			slow_duration += 1.0
		elif path[upg_path-1] == 3:
			attack_range += 4
			slow_duration += 3.0
	return "its real"

func upg_attack(enemy: Enemy) -> void:
	if is_instance_valid(enemy):
		# Path 3 tier 3: Total Paralysis also works on bosses
		if enemy.has_method("slow") and (not enemy.boss or path[2] == 3):
			enemy.slow(slow_duration)
		_draw_lightning(enemy)

func _draw_lightning(enemy: Enemy) -> void:
	if not is_instance_valid(enemy):
		return
	var line = Line2D.new()
	line.default_color = Color(0.2, 0.6, 1.0, 1.0) # Blue
	line.width = 4.0
	# Draw from roughly the top of the tesla coil to the enemy
	line.points = [Vector2(0, -60), enemy.global_position - global_position]
	add_child(line)
	var tween = create_tween()
	tween.tween_property(line, "modulate:a", 0.0, 0.15)
	tween.tween_callback(line.queue_free)
