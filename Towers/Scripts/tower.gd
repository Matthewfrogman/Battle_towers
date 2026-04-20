class_name Tower extends Area2D

@onready var timer = get_node("Cooldown Timer")
@onready var range_scene = get_node("Range")
@onready var cannon_scene = get_node("Cannon")
@onready var marker_scene = get_node("Cannon/Marker2D")
var nobuildscene: PackedScene = preload("res://Towers/no_build_zone.tscn")

# Attributes
@export var sees_camo: bool = false
@export var cooldown: float = 1.0
@export var bullet_spread: float = 0.1
@export var attack_range: float = 2.0
@export var attack: int = 5
@export var bullet_speed: int = 400
@export var pierce: int = 1
@export var projectiles: int = 1
@export var bullet_scene: PackedScene

# Upgrade Data
var path: Array = [0, 0, 0]
const _MAX_TIERS: int = 5
const _MAX_MAJOR: int = 2

var upgrade_names = [
	["Quick Loader", "Twin Barrels", "Rapid Fire", "Overclocked", "Bullet Storm"],
	["Long Sight", "High Ground", "Signal Flare", "Advanced Radar", "Global Coverage"],
	["Heavy Slugs", "Pointy Tips", "Depleted Uranium", "Armor Piercing", "Behemoth"]
]

var upgrade_costs = [
	[200, 450, 1200, 3500, 12000],
	[150, 300, 900, 2500, 9000],
	[250, 400, 1100, 3200, 15000]
]

var selected: bool = false
var canshoot: bool = true
var sees_enemy: bool = false
var mpos: Vector2
var lookingat: Vector2 = Vector2.ZERO
var mode: String = "hover"
var target: String = "first"
var angle: float = 0
var _panel: CanvasLayer = null

# Optimization variables
var target_refresh_rate: float = 0.1
var target_timer: float = 0.0
var current_best_target: Node2D = null

# Target shop node based on your screenshot
var shop_node = null

func _ready() -> void:
	shop_node = get_tree().root.find_child("ShopUI", true, false)
	
	timer.wait_time = cooldown
	timer.one_shot = true
	if not timer.timeout.is_connected(_timer_timeout):
		timer.timeout.connect(_timer_timeout)
		
	range_scene.scale = Vector2(attack_range, attack_range)
	if has_node("Range/range_ring"):
		$Range/range_ring.scale = Vector2(1,1) * (attack_range * 0.06)

func can_place(pos):
	var space = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collide_with_areas = true
	var result = space.intersect_point(query)
	for r in result:
		if r.collider.is_in_group("no_build") and r.collider.get_parent() != self:
			return false
	return true

func can_upgrade(p: int) -> bool:
	var idx = p - 1
	if path[idx] >= _MAX_TIERS: return false
	if shop_node:
		if shop_node.money < upgrade_costs[idx][path[idx]]: 
			return false 
	var major_count = 0
	for i in range(3):
		if i != idx and path[i] >= 2:
			major_count += 1
	if path[idx] >= 2 and major_count >= _MAX_MAJOR:
		return false
	return true

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		mpos = get_global_mouse_position()
		
		if mode == "hover":
			if can_place(mpos):
				mode = "placed"
				modulate = Color(1,1,1,1)
				# LAG FIX: Check if nbz already exists before instantiating
				if get_node_or_null("NoBuildZone") == null:
					var nbz = nobuildscene.instantiate()
					nbz.name = "NoBuildZone"
					add_child(nbz)
			return

		var dist = global_position.distance_to(mpos)
		if dist <= 50:
			selected = !selected
			if selected: _build_panel()
			else: _hide_panel()
		else:
			var vp_width = get_viewport().get_visible_rect().size.x
			if selected and mpos.x < (vp_width - 210):
				_hide_panel()

func _process(delta: float) -> void:
	if mode == "hover":
		global_position = get_global_mouse_position()
		modulate = Color(1,1,1,1) if can_place(global_position) else Color(1,0.5,0.5,1)
		return

	if has_node("Range/range_ring"):
		$Range/range_ring.visible = selected
	
	# LAG FIX: Don't search for targets every frame. Search every 0.1s.
	target_timer += delta
	if target_timer >= target_refresh_rate:
		target_timer = 0.0
		_find_target()

	if is_instance_valid(current_best_target):
		lookingat = current_best_target.global_position
		cannon_scene.look_at(lookingat)
		angle = cannon_scene.rotation
		sees_enemy = true
		if canshoot:
			shoot(bullet_speed, "angled", projectiles)
	else:
		sees_enemy = false

func _find_target():
	var targets = range_scene.get_overlapping_bodies()
	var best_target = null
	var highest_prog = -1.0
	
	for t in targets:
		if not is_instance_valid(t): continue
		
		var prog = t.get("progress")
		if prog == null: prog = t.get("progress_ratio")
		
		if prog != null:
			if !t.get("camo") or (t.get("camo") and sees_camo):
				if prog > highest_prog:
					highest_prog = prog
					best_target = t
	
	current_best_target = best_target

func shoot(speed: int, _angle_mode: String, bnum: int):
	canshoot = false
	timer.start(cooldown)
	bulletShoot(Vector2.from_angle(angle) * speed)
	if bnum > 1:
		var side_count = (bnum - 1) / 2
		for i in range(1, side_count + 1):
			bulletShoot(Vector2.from_angle(angle + (bullet_spread * i)) * speed)
			bulletShoot(Vector2.from_angle(angle - (bullet_spread * i)) * speed)

func bulletShoot(velocity: Vector2):
	if bullet_scene == null: return
	var b = bullet_scene.instantiate()
	get_tree().current_scene.add_child(b) 
	b.global_position = marker_scene.global_position
	if "damage" in b: b.damage = attack
	if "move" in b: b.move = velocity
	if "velocity" in b: b.velocity = velocity
	if "pierce" in b: b.pierce = pierce
	if "sees_camo" in b: b.sees_camo = sees_camo

func _timer_timeout() -> void:
	canshoot = true

func _build_panel() -> void:
	if _panel: _panel.queue_free()
	_panel = CanvasLayer.new()
	_panel.layer = 10
	add_child(_panel)
	var vp_size = get_viewport().get_visible_rect().size
	var bg = ColorRect.new()
	bg.color = Color(0.12, 0.12, 0.12, 0.95)
	bg.size = Vector2(210, vp_size.y)
	bg.position = Vector2(vp_size.x - 210, 0)
	_panel.add_child(bg)
	for i in range(3):
		var y_off = 60 + (i * 130)
		var btn = Button.new()
		btn.name = "Btn%d" % i
		btn.size = Vector2(190, 60)
		btn.position = bg.position + Vector2(10, y_off)
		btn.pressed.connect(func(): _do_upgrade(i + 1))
		_panel.add_child(btn)
		for j in range(_MAX_TIERS):
			var pip = ColorRect.new()
			pip.name = "Pip%d_%d" % [i, j]
			pip.size = Vector2(30, 6)
			pip.position = bg.position + Vector2(10 + (j * 38), y_off + 75)
			_panel.add_child(pip)
	_refresh_panel()

func _refresh_panel() -> void:
	if !_panel: return
	var colors = [Color(0.2, 0.6, 1.0), Color(0.4, 0.8, 0.2), Color(1.0, 0.4, 0.2)]
	for i in range(3):
		var tier = path[i]
		var btn = _panel.get_node_or_null("Btn%d" % i)
		if not btn: continue
		if tier < _MAX_TIERS:
			var cost = upgrade_costs[i][tier]
			var upg_name = upgrade_names[i][tier]
			btn.text = "%s\nCost: $%d" % [upg_name, cost]
			btn.disabled = not can_upgrade(i + 1)
		else:
			btn.text = "MAXED"
			btn.disabled = true
		for j in range(_MAX_TIERS):
			var pip = _panel.get_node_or_null("Pip%d_%d" % [i, j])
			if pip:
				pip.color = colors[i] if j < tier else Color(0.2, 0.2, 0.2)

func _do_upgrade(p: int):
	var idx = p - 1
	if not can_upgrade(p): return
	if shop_node:
		shop_node.money -= upgrade_costs[idx][path[idx]]
	path[idx] += 1
	apply_upgrade_effects(p, path[idx])
	_refresh_panel()

func apply_upgrade_effects(p_idx, tier):
	match p_idx:
		1:
			if tier == 1: cooldown *= 0.8
			if tier == 2: projectiles += 2
			if tier == 3: cooldown *= 0.7
			if tier == 4: projectiles += 2
			if tier == 5: cooldown *= 0.4
		2:
			if tier == 1: attack_range += 0.5
			if tier == 2: attack_range += 0.5
			if tier == 3: sees_camo = true
			if tier == 4: attack_range += 1.0
			if tier == 5: pierce += 15
		3:
			if tier == 1: attack += 2
			if tier == 2: pierce += 2
			if tier == 3: attack += 5
			if tier == 4: attack += 10
			if tier == 5: attack += 30
	range_scene.scale = Vector2(attack_range, attack_range)
	if has_node("Range/range_ring"):
		$Range/range_ring.scale = Vector2(1,1) * (attack_range * 0.06)

func _hide_panel() -> void:
	if _panel:
		_panel.queue_free()
		_panel = null
	selected = false
