class_name Tower extends Area2D

@onready var timer = get_node("Cooldown Timer")
@onready var range_scene = get_node("Range")
@onready var cannon_scene = get_node("Cannon")
@onready var marker_scene = get_node("Cannon/Marker2D")

@export var display_name: String = ""
@export var sees_camo: bool = false
@export var cooldown: float = 5.0
@export var bullet_spread: float = 0.1
@export var attack_range: int
@export var attack: int = 5
@export var bullet_speed: int = 200
@export var pierce: int = 0
@export var projectiles: int = 1
@export var bullet_scene: PackedScene
@export var sniper: bool = false

var total_cost: int = 0
var path: Array = [0, 0, 0]

signal tower_selected(tower)
signal tower_deselected

var selected: bool = false
var canshoot: bool = false
var sees_enemy: bool
var mpos: Vector2
var lookingat: Vector2
var mode: String = "hover"
var target: String = "first"
var angle: float = 0
var enemies = {"first": 0, "closest": 0, "last": 0, "strongest": 0}

func can_place(pos):
	var space = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collide_with_areas = true
	var result = space.intersect_point(query)
	for r in result:
		if r.collider.is_in_group("no_build"):
			return false
	return true

func _ready() -> void:
	lookingat = Vector2(100000, 0)
	timer.wait_time = cooldown
	mode = "hover"
	global_position = get_global_mouse_position()
	range_scene.scale = Vector2(attack_range, attack_range)
	_update_range_ring()

func _spawn_no_build_zone() -> void:
	var zone = Area2D.new()
	zone.add_to_group("no_build")
	zone.collision_layer = 1
	zone.collision_mask = 0
	var cshape = CollisionShape2D.new()
	var shape = RectangleShape2D.new()

	# Find the base sprite (named "Base", "camo_base", "speed_base", etc.)
	# and use its actual visual size: texture_size * abs(scale)
	var base_size := Vector2(52, 52)
	for child in get_children():
		if child is Sprite2D and "base" in child.name.to_lower():
			if child.texture:
				var tex = child.texture.get_size()
				base_size = tex * Vector2(abs(child.scale.x), abs(child.scale.y))
				break

	shape.size = base_size
	cshape.shape = shape
	zone.add_child(cshape)
	add_child(zone)

# Scales the range ring texture to exactly match the collision shape's world-space radius.
func _update_range_ring() -> void:
	var col_shape = $Range/CollisionShape2D.shape
	if col_shape is CircleShape2D:
		var tex_size = $Range/range_ring.texture.get_size()
		# Effective world radius = shape.radius * range_scene.scale.x
		var world_radius = col_shape.radius * range_scene.scale.x
		# Scale the ring so its visual edge matches world_radius.
		var ring_scale = (world_radius * 2.0) / tex_size.x
		# ring_ring is a child of Range which already has range_scene.scale applied,
		# so divide out the parent scale to get the correct local scale.
		var local_scale = ring_scale / range_scene.scale.x
		$Range/range_ring.scale = Vector2(local_scale, local_scale)
	else:
		$Range/range_ring.scale = Vector2(0.1, 0.1)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if mode == "hover":
					if can_place(get_global_mouse_position()):
						mode = "placed"
						modulate = Color(1,1,1,1)
						_spawn_no_build_zone()
					else:
						modulate = Color(1,0.5,0.5,1)
				else:
					var madj = mpos[0] - global_position.x
					var mopp = mpos[1] - global_position.y
					var mhyp = (madj**2 + mopp**2)**0.5
					var was_selected = selected
					if mhyp <= 50:
						selected = !selected
					else:
						selected = false
					if selected and not was_selected:
						tower_selected.emit(self)
					elif not selected and was_selected:
						tower_deselected.emit()

func _process(_delta: float) -> void:
	mpos = get_global_mouse_position()

	if mode == "placed":
		cannon_scene.look_at(lookingat)
		angle = cannon_scene.rotation
		$Range/range_ring.visible = selected
		
		var enemy_list = []
		# Reset target every frame so a tower with nothing in range can't
		# carry over a stale reference and keep shooting.
		enemies["first"] = 0
		
		var col_radius = 32.0
		var col_shape = $Range/CollisionShape2D.shape
		if col_shape is CircleShape2D:
			col_radius = col_shape.radius
		var max_dist = col_radius * range_scene.scale.x
		
		enemy_list.clear()
		for enemy in range_scene.get_overlapping_bodies():
			if not enemy is Enemy: continue
			if not is_instance_valid(enemy): continue
			
			var hyp = global_position.distance_to(enemy.global_position)
			if hyp > max_dist:
				continue
			
			enemy_list.append(enemy)
			
			# Pick the enemy furthest along the track (highest progress)
			if not enemy.camo or sees_camo:
				if enemies["first"] is int:
					enemies["first"] = [enemy, hyp]
				elif enemy.progress > enemies["first"][0].progress:
					enemies["first"] = [enemy, hyp]
		
		if enemies["first"] is Array and is_instance_valid(enemies["first"][0]):
			sees_enemy = true
			if timer.is_stopped():
				timer.start(max(0.05, cooldown))
			lookingat = enemies["first"][0].global_position
		else:
			enemies["first"] = 0
			sees_enemy = false
			timer.stop()

		if canshoot and sees_enemy:
			if sniper:
				hitscan()
			else:
				shoot(bullet_speed, "angled", projectiles)
		
	else:
		position = get_global_mouse_position()
		if can_place(position):
			modulate = Color(1,1,1,1)
		else:
			modulate = Color(1,0.5,0.5,1)

func shoot(speed: int, angle_mode: String, bnum: int):
	if angle_mode == "straight":
		bulletShoot(Vector2(speed*cos(angle), speed*sin(angle)))
	if angle_mode == "angled":
		if not bnum == 0: bulletShoot(Vector2(speed*cos(angle), speed*sin(angle)))
		var aIncrement = 0
		for i in bnum-1:
			if i > (bnum-1)/2.0-1:
				aIncrement = -bullet_spread*(i+1-((bnum-1)/2.0))
			else:
				aIncrement = bullet_spread*(i+1)
			bulletShoot(Vector2(speed*cos(angle+aIncrement), speed*sin(angle+aIncrement)))

func bulletShoot(move: Vector2):
	if bullet_scene == null:
		push_error("bullet_scene is not assigned on tower: " + name + ". Assign it in the Inspector.")
		return
	var bullet = bullet_scene.instantiate()
	add_child(bullet)
	bullet.global_position = marker_scene.global_position
	bullet.damage = attack
	bullet.move = move
	bullet.pierce = pierce
	bullet.sees_camo = sees_camo
	canshoot = false
	timer.wait_time = max(0.05, cooldown)

func hitscan():
	var targets: Array = []
	var col_radius = 32.0
	var col_shape = $Range/CollisionShape2D.shape
	if col_shape is CircleShape2D:
		col_radius = col_shape.radius
	var max_dist = col_radius * range_scene.scale.x
	
	for body in range_scene.get_overlapping_bodies():
		if body is Enemy:
			if body.global_position.distance_to(global_position) > max_dist:
				continue
			if body.camo and not sees_camo:
				continue
			targets.append(body)
	targets.sort_custom(func(a, b): return a.progress > b.progress)
	var hits = 0
	for enemy in targets:
		if hits >= pierce:
			break
		if is_instance_valid(enemy):
			enemy.lose_hp(attack)
			upg_attack(enemy)
			hits += 1
	canshoot = false
	timer.wait_time = max(0.05, cooldown)

func _timer_timeout() -> void:
	canshoot = true

func get_upgrade_data() -> Array:
	return [
		[
			{"name": "Upgrade 1-1", "cost": 500, "desc": "Improves the tower."},
			{"name": "Upgrade 1-2", "cost": 900, "desc": "Further improvement."},
			{"name": "Upgrade 1-3", "cost": 8000, "desc": "Mastery level."}
		],
		[
			{"name": "Upgrade 2-1", "cost": 500, "desc": "Improves the tower."},
			{"name": "Upgrade 2-2", "cost": 900, "desc": "Further improvement."},
			{"name": "Upgrade 2-3", "cost": 8000, "desc": "Mastery level."}
		],
		[
			{"name": "Upgrade 3-1", "cost": 500, "desc": "Improves the tower."},
			{"name": "Upgrade 3-2", "cost": 900, "desc": "Further improvement."},
			{"name": "Upgrade 3-3", "cost": 8000, "desc": "Mastery level."}
		]
	]

func try_upgrade(path_idx: int) -> bool:
	var data = get_upgrade_data()
	var tier = path[path_idx]
	if tier >= 3:
		return false
	# For tier 2 (the third slot), check no other path is at tier 3 already
	if tier == 2:
		for t in path:
			if t >= 3:
				return false
	var cost = data[path_idx][tier]["cost"]
	var shop_nodes = get_tree().get_nodes_in_group("shop_ui")
	if shop_nodes.is_empty():
		return false
	var shop = shop_nodes[0]
	if shop.money < cost:
		return false
	shop.spend_money(cost)
	total_cost += cost
	upgrade(path_idx + 1)
	refresh_range_ring()
	return true

func refresh_range_ring() -> void:
	range_scene.scale = Vector2(attack_range, attack_range)
	_update_range_ring()

func upgrade(upg_path: int):
	pass

func upg_attack(_enemy: Enemy):
	pass
