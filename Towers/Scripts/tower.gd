class_name Tower extends Area2D

@onready var timer = get_node("Cooldown Timer")
@onready var range_scene = get_node("Range")
@onready var cannon_scene = get_node("Cannon")
@onready var marker_scene = get_node("Cannon/Marker2D")

# VVV things that'll change between towers VVV
#the radius of where it can shoot
@export var sees_camo: bool = false
#time between attacks
@export var cooldown: float = 5.0
#angle in radians between bullets
@export var bullet_spread: float = 0.1
@export var attack_range: int
@export var attack: int = 5
@export var bullet_speed: int = 100
#the amount of enemies the bullet can pass through before it expires
@export var pierce: int = 1
#num of bullets. this number should ALWAYS be odd so it looks good.
@export var projectiles: int = 1
#a reference to the bullet/projectile it instantiates
@export var bullet_scene: PackedScene

var selected: bool = false
var canshoot: bool = false
var sees_enemy: bool
var mpos: Vector2
#the position of the enemy its looking at V
var lookingat: Vector2
#either hover or placed. If its hovering itll follow the mouse, otherwise itll shoot
var mode: String = "hover"
var target: String = "first"
var angle: float = 0
#will contain the enemies with the four+ target attacks
var enemies = {"first": 0, "closest": 0, "last": 0, "strongest": 0}

func _ready() -> void:
	timer.wait_time = cooldown
	mode = "hover"
	global_position = get_global_mouse_position()
	range_scene.scale = Vector2(attack_range, attack_range)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if mode == "hover": mode = "placed"
				else:
					#if the mouse is close enough, set selected to true
					var madj = mpos[0] - global_position.x
					var mopp = mpos[1] - global_position.y
					var mhyp = (madj**2 + mopp**2)**0.5
					if mhyp <= 50: selected = !selected

func _process(_delta: float) -> void:
	mpos = get_global_mouse_position()

	if mode == "placed":
		cannon_scene.look_at(lookingat)
		angle = cannon_scene.rotation

		for enemy in range_scene.get_overlapping_bodies():
			if enemy is Enemy: pass
			else: break
			
			var adj = global_position.x - enemy.global_position.x
			var opp = global_position.y - enemy.global_position.y
			#angle = atan2(-opp, -adj)
			#whichever hyp is lowest, thats the closest enemy
			var hyp = (adj**2 + opp**2)**0.5
			
			if target == "first" and enemies["first"] is Array and is_instance_valid(enemies["first"][0]):
				lookingat = enemies["first"][0].global_position
			
			
			if enemies["first"] is int: 
				enemies["first"] = [enemy, hyp]
			elif (is_instance_valid(enemies["first"][0]) and 
			enemies["first"][0] is Enemy and 
			enemy.progress > enemies["first"][0].progress):
				enemies["first"] = [enemy, hyp]
			elif not is_instance_valid(enemies["first"][0]):
				enemies["first"] = [enemy, hyp]
		
		if len(range_scene.get_overlapping_bodies()) > 0: 
			sees_enemy = true
			timer.paused = false
		else: 
			sees_enemy = false
			if timer.time_left <= 0.1:
				#pauses so the cooldown doesnt get to low
				timer.paused = true
		
		if canshoot and sees_enemy: shoot(bullet_speed, "angled", projectiles)
	else:
		position = get_global_mouse_position()

func shoot(speed: int, angle_mode: String, bnum: int):
	#shoot controls the direction and amount of each bullet
	if angle_mode == "straight":
		#doesn't do anything with multiple projectiles rn
		bulletShoot(Vector2(speed*cos(angle), speed*sin(angle)))
		
	if angle_mode == "angled":
		bulletShoot(Vector2(speed*cos(angle), speed*sin(angle)))
		var aIncrement = 0
		for i in bnum-1:
			#error for integer division
			if i > (bnum-1)/2.0-1:
				aIncrement = -bullet_spread*(i+1-((bnum-1)/2.0))
			else:
				aIncrement = bullet_spread*(i+1)
			bulletShoot(Vector2(speed*cos(angle+aIncrement), speed*sin(angle+aIncrement)))

func bulletShoot(move: Vector2):
	#instantiated bullets and gives them the correct stats
	var bullet = bullet_scene.instantiate()
	add_child(bullet)
	bullet.global_position = marker_scene.global_position
	bullet.damage = attack
	bullet.move = move
	bullet.pierce = pierce
	bullet.sees_camo = sees_camo
	canshoot = false

func _timer_timeout() -> void:
	canshoot = true

func upgrade(path: int):
	#overwritten by extended classes
	pass
