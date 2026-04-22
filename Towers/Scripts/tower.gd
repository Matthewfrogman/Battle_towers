class_name Tower extends Area2D

@onready var timer = get_node("Cooldown Timer")
@onready var range_scene = get_node("Range")
@onready var cannon_scene = get_node("Cannon")
@onready var marker_scene = get_node("Cannon/Marker2D")
var nobuildscene: PackedScene = preload("res://Towers/no_build_zone.tscn")

@export var sees_camo: bool = false
@export var cooldown: float = 5.0
@export var bullet_spread: float = 0.1
@export var attack_range: int
@export var attack: int = 5
@export var bullet_speed: int = 100
@export var pierce: int = 1
@export var projectiles: int = 1
@export var bullet_scene: PackedScene
@export var sniper: bool = false

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
var path: Array = [0, 0, 0]
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
	var tex_size = $Range/range_ring.texture.get_size()
	var col_shape = $Range/CollisionShape2D.shape
	if col_shape is CircleShape2D:
		var target_diam = col_shape.radius * 2.0
		$Range/range_ring.scale = Vector2(target_diam / tex_size.x, target_diam / tex_size.y)
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
						var nobuildzone = nobuildscene.instantiate()
						add_child(nobuildzone)
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
		
		enemy_list.clear()
		for enemy in range_scene.get_overlapping_bodies():
			if not enemy is Enemy: continue
			#create a list, that resets before this loop is run, that will add
			#every single enemy thats currently in the loop
			#at the very beginning of the loop, if the first enemy isnt in the list
			#it is removed
			
			var adj = global_position.x - enemy.global_position.x
			var opp = global_position.y - enemy.global_position.y
			var hyp = (adj**2 + opp**2)**0.5
			
			enemy_list.append(enemy)
			
			print(enemy_list)
			if target == "first" and enemies["first"] is Array and is_instance_valid(enemies["first"][0]):
				if not enemy_list.has(enemies["first"][0]):
					
					enemies["first"] = 0
				else:
					lookingat = enemies["first"][0].global_position
			
			#replaces the initial value with the first enemy that shows up, as long as it can see it
			if enemies["first"] is int:
				if not enemy.camo or enemy.camo and sees_camo:
					enemies["first"] = [enemy, hyp]
			
			#if the enemy is valid(not dead), and its an enemy, and the progress is greater than the one 
			#thats current in the first place, and either its not camo, or it is camo and the tower can see it
			elif is_instance_valid(enemies["first"][0]) and (enemies["first"][0] is Enemy and
			enemy.progress > enemies["first"][0].progress and 
 			not enemies["first"][0].camo or enemies["first"][0].camo and sees_camo):
				#replace its spot
				enemies["first"] = [enemy, hyp]
				
			elif not is_instance_valid(enemies["first"][0]):
				enemies["first"] = [enemy, hyp]
		
		#print(enemies["first"])
		if enemies["first"] is Array:
			sees_enemy = true
			timer.paused = false
		else:
			sees_enemy = false
			if timer.time_left <= 0.1:
				timer.paused = true

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
	timer.wait_time = cooldown

func hitscan():
	var targets: Array = []
	for body in range_scene.get_overlapping_bodies():
		if body is Enemy:
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
	timer.wait_time = cooldown

func _timer_timeout() -> void:
	canshoot = true

func get_upgrade_data() -> Array:
	return [
		[{"name": "Upgrade 1-1", "cost": 500, "desc": "Improves the tower."},
		 {"name": "Upgrade 1-2", "cost": 900, "desc": "Further improvement."}],
		[{"name": "Upgrade 2-1", "cost": 500, "desc": "Improves the tower."},
		 {"name": "Upgrade 2-2", "cost": 900, "desc": "Further improvement."}],
		[{"name": "Upgrade 3-1", "cost": 500, "desc": "Improves the tower."},
		 {"name": "Upgrade 3-2", "cost": 900, "desc": "Further improvement."}],
	]

func try_upgrade(path_idx: int) -> bool:
	var data = get_upgrade_data()
	var tier = path[path_idx]
	if tier >= 2:
		return false
	var cost = data[path_idx][tier]["cost"]
	var shop_nodes = get_tree().get_nodes_in_group("shop_ui")
	if shop_nodes.is_empty():
		return false
	var shop = shop_nodes[0]
	if shop.money < cost:
		return false
	shop.spend_money(cost)
	upgrade(path_idx + 1)
	refresh_range_ring()
	return true

func refresh_range_ring() -> void:
	range_scene.scale = Vector2(attack_range, attack_range)

func upgrade(upg_path: int):
	print(upg_path)

func upg_attack(_enemy: Enemy):
	pass
