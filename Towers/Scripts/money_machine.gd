extends Tower

var money_per_round: int = 100
var compound_interest: bool = false

func _ready() -> void:
	super._ready()
	add_to_group("money_machine")

func get_upgrade_data() -> Array:
	return [
		[
			{"name": "Bigger Bills",     "cost": 1000, "desc": "Increases money per round to $200."},
			{"name": "Printing Press",   "cost": 2500, "desc": "Increases money per round to $400."},
			{"name": "Gold Factory",     "cost": 8000, "desc": "Doubles income. Generates $800 per round."}
		],
		[
			{"name": "Efficient Motor",  "cost": 800,  "desc": "Gain an instant $500 bonus."},
			{"name": "Tax Evasion",      "cost": 3000, "desc": "Gain an instant $2000 bonus."},
			{"name": "Instant Jackpot",  "cost": 7000, "desc": "Gain an instant $8000 bonus."}
		],
		[
			{"name": "Interest Rates",   "cost": 1500, "desc": "Increases money per round by $200."},
			{"name": "Monopoly",         "cost": 4000, "desc": "Increases money per round by $500."},
			{"name": "Compound Interest","cost": 9000, "desc": "Income increases by $300 every wave permanently."}
		],
	]

func upgrade(upg_path: int):
	if path[upg_path-1] == 3:
		return null
	path[upg_path-1] += 1
	if upg_path == 1:
		if path[upg_path-1] == 1:
			money_per_round += 100
		elif path[upg_path-1] == 2:
			money_per_round += 200
		elif path[upg_path-1] == 3:
			money_per_round += 400  # 800 total
	elif upg_path == 2:
		var shop_nodes = get_tree().get_nodes_in_group("shop_ui")
		if not shop_nodes.is_empty():
			if path[upg_path-1] == 1:
				shop_nodes[0].add_money(500)
			elif path[upg_path-1] == 2:
				shop_nodes[0].add_money(2000)
			elif path[upg_path-1] == 3:
				shop_nodes[0].add_money(8000)
	elif upg_path == 3:
		if path[upg_path-1] == 1:
			money_per_round += 200
		elif path[upg_path-1] == 2:
			money_per_round += 500
		elif path[upg_path-1] == 3:
			# Compound Interest: mark for per-wave income growth
			compound_interest = true
	return "its real"

func gain_money() -> void:
	if mode != "placed":
		return
	if compound_interest:
		money_per_round += 300
	var shop_nodes = get_tree().get_nodes_in_group("shop_ui")
	if not shop_nodes.is_empty():
		shop_nodes[0].add_money(money_per_round)
		
	# Size up big and size back down smoothly
	var tween = create_tween()
	tween.tween_property($Base, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property($Base, "scale", Vector2(0.8, 0.8), 0.4).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

func _process(delta: float) -> void:
	mpos = get_global_mouse_position()

	if mode == "placed":
		$Range/range_ring.visible = selected
	else:
		position = get_global_mouse_position()
		if can_place(position):
			modulate = Color(1,1,1,1)
		else:
			modulate = Color(1,0.5,0.5,1)
