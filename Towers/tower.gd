class_name Tower extends Area2D

@onready var timer = get_node("Cooldown Timer")
@onready var range_scene = get_node("Range")
@onready var cannon_scene = get_node("Cannon")
@onready var marker_scene = get_node("Cannon/Marker2D")
#a reference to the bullet/projectile it instantiates
#var bullet_scene: PackedScene = preload("res://Towers/Bullets/bullet.tscn")

# VVV things that'll change between towers VVV
#the radius of where it can shoot
@export var range: int
@export var cooldown: float = 5.0
@export var attack: int = 5
#num of bullets. this number should ALWAYS be odd so it looks good.
@export var projectiles: int = 5
@export var bullet_speed: int = 100
@export var sees_camo: bool = false
@export var bullet_scene: PackedScene

var sees_enemy: bool
#the position of the enemy its looking at V
var lookingat: Vector2
var canshoot = false
#either hover or placed. If its hovering itll follow the mouse, otherwise itll shoot
var mode = "hover"
var angle: float = 0
#all the enemies in the range V
var enemies = []

func _ready() -> void:
	timer.wait_time = cooldown
	mode = "hover"
	global_position = get_global_mouse_position()
	range_scene.scale = Vector2(range, range)
	
func _process(delta: float) -> void:
	#if there is an enemy in range, and cooldown is less/equal to 0, shoot
	if mode == "hover":
		global_position = get_global_mouse_position()
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			mode = "placed"
			
	if mode == "placed":
		#get the difference between x and y coords with the closest enemy
		#gives us an angle in radians!!
		for enemy in range_scene.get_overlapping_bodies():
			var adj = global_position.x - enemy.global_position.x
			var opp = global_position.y - enemy.global_position.y
			var hyp = (adj**2 + opp**2)**0.5
			angle = atan2(-opp, -adj)
			lookingat = enemy.global_position
		
		if len(range_scene.get_overlapping_bodies()) > 0: 
			sees_enemy = true
			#timer.start()
		else: sees_enemy = false
		
		if canshoot and sees_enemy: shoot(delta, bullet_speed, angle, "angled", projectiles)


#PLANS FOR THIS:
#shoot controls the direction and amount of each bullet, and also the angles
#whereas bulletShoot actually instantiates the bullets and stuff
func shoot(delta: float, speed: int, angle: float, angle_mode: String, bnum: int):
	if angle_mode == "straight":
		#doesn't do anything with multiple projectiles rn
		bulletShoot(Vector2(speed*cos(angle), speed*sin(angle)), position)
		
	if angle_mode == "angled":
		bulletShoot(Vector2(speed*cos(angle), speed*sin(angle)), position)
		var aIncrement = 0
		for i in bnum-1:
			#error for integer division
			if i > (bnum-1)/2-1:
				aIncrement = -0.1*(i+1-((bnum-1)/2))
			else:
				aIncrement = 0.1*(i+1)
			bulletShoot(Vector2(speed*cos(angle+aIncrement), speed*sin(angle+aIncrement)), position)

func bulletShoot(move: Vector2, pos: Vector2):
	var bullet = bullet_scene.instantiate()
	add_child(bullet)
	bullet.global_position = marker_scene.global_position
	bullet.damage = attack
	bullet.move = move
	canshoot = false
	
func _timer_timeout() -> void:
	canshoot = true
