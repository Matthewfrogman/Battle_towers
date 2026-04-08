class_name Tower extends Area2D

@warning_ignore("integer_division")

@onready var timer = get_node("Cooldown Timer")
@onready var range_scene = get_node("Range")
@onready var cannon_scene = get_node("Cannon")
@onready var marker_scene = get_node("Cannon/Marker2D")

# VVV things that'll change between towers VVV
#the radius of where it can shoot
@export var sees_camo: bool = false
@export var cooldown: float = 5.0
@export var bullet_spread: float = 0.1
@export var attack_range: int
@export var attack: int = 5
@export var bullet_speed: int = 100
@export var pierce: int = 3
#num of bullets. this number should ALWAYS be odd so it looks good.
@export var projectiles: int = 5
#a reference to the bullet/projectile it instantiates
@export var bullet_scene: PackedScene

var canshoot = false
var sees_enemy: bool
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
	
func _process(_delta: float) -> void:
	if mode == "hover":
		global_position = get_global_mouse_position()
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			mode = "placed"
			
	if mode == "placed":
		#cannon_scene.rotation = angle
		#an extra option if needed, in position
		cannon_scene.look_at(lookingat)
		
		#see which enemy is first, closest, last, etc
		#checks all the enemies 
		#make a loop of all the enemies, and choose the one that matches
		#the thing its currently looking for
		
		#two loops? one that looks at all the enemies, and gathers their position and health
		#and then adds them to a seperate loop, and then that loop will find the one with the
		#highest of one stat
		
		#have a temp value of zero, and check if the health/position is higher than itself
		#or the previous one
		
		
		for enemy in range_scene.get_overlapping_bodies():
			if enemy is Enemy: pass
			else: break
			
			var adj = global_position.x - enemy.global_position.x
			var opp = global_position.y - enemy.global_position.y
			angle = atan2(-opp, -adj)
			#whichever hyp is lowest, thats the closest enemy
			var hyp = (adj**2 + opp**2)**0.5
			
			#current issue is that whenever the enemy is added
			#you cant compare them anymore, and i need this so it can start for the first time
			#change it so that it only works when there are enemoes...
			
			
			#really long solution but I got it
			#print(enemies["first"])
			if enemies["first"] is int: 
				enemies["first"] = [enemy, hyp]
			elif enemies["first"][0] is Enemy and enemy.progress > enemies["first"][0].progress:
				enemies["first"] = [enemy, hyp]
			else:
				enemies["first"] = 0
			
			if target == "first" and enemies["first"] is Enemy:
				lookingat = enemies["first"][0].global_position
				
		
		if len(range_scene.get_overlapping_bodies()) > 0: 
			sees_enemy = true
			timer.paused = false

		else: 
			sees_enemy = false
			if timer.time_left <= 0.1:
				#pauses so the cooldown doesnt get to low, and 
				timer.paused = true
				
		
		if canshoot and sees_enemy: shoot(bullet_speed, "angled", projectiles)


#PLANS FOR THIS:
#shoot controls the direction and amount of each bullet, and also the angles
<<<<<<< Updated upstream
#whereas bulletShoot actually instantiates the bullets and stuff
func shoot(delta: float, speed: int, angle: float, angle_mode: String, bnum: int):
=======
#whereas bulletShoot actually instantiates the bullets
func shoot(speed: int, angle_mode: String, bnum: int):
>>>>>>> Stashed changes
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
	var bullet = bullet_scene.instantiate()
	add_child(bullet)
	bullet.global_position = marker_scene.global_position
	bullet.damage = attack
	bullet.move = move
	bullet.pierce = pierce
	canshoot = false
	
func _timer_timeout() -> void:
	canshoot = true
