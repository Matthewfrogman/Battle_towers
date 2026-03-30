class_name Tower extends Area2D
#the cooldown timer
@onready var timer = get_node("Cooldown Timer")
#the range area2D
@onready var range_scene = get_node("Range")
#a reference to the bullet/projectile it instantiates
var bullet_scene: PackedScene = preload("res://Towers/Bullets/bullet.tscn")
# VVV things that'll change between towers VVV
#the radius of where it can shoot
@export var range: int
#the time it takes to shoot
@export var cooldown: float = 5.0
@export var attack: int = 5
<<<<<<< Updated upstream
=======
#num of bullets. this number should ALWAYS be odd so it looks good.
@export var projectiles: int = 5

>>>>>>> Stashed changes
var canshoot = false
#either hover or placed. If its hovering itll follow the mouse, otherwise itll shoot
var mode = "hover"
func _ready() -> void:
	timer.wait_time = cooldown
	mode = "hover"
	position = get_global_mouse_position()
func _process(delta: float) -> void:
	#if there is an enemy in range, and cooldown is less/equal to 0, shoot
	if mode == "hover":
		position = get_global_mouse_position()
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			mode = "placed"
			print(position)
	if mode == "placed":
		#get the difference between x and y coords with the closest enemy
<<<<<<< Updated upstream
		#gives us an angle in radians!!
		var angle: float = 0.0
		if canshoot == true:
			shoot(delta, 10, angle, "straight")
=======
		#gives an angle in radians!!
		var angle: float
		if canshoot == true:
			shoot(50, angle, "angled", 5)


>>>>>>> Stashed changes
#PLANS FOR THIS:
#shoot(eventually some other name) controls the direction and amount
#of each bullet, and also the angles
#whereas shoot2(eventually some other name) actually instantiates the bullets
func shoot(speed: int, angle: float, angle_mode: String, bnum: int):
	#straight will shoot the bullets parallel, and angled wont
	
	if angle_mode == "straight":
<<<<<<< Updated upstream
		#same vector
		var adj = speed * cos(angle)
		var opp = speed * sin(angle)
		for shots in 5:
=======
		for shots in 1:
>>>>>>> Stashed changes
			print("blast")
			bulletShoot(Vector2(speed*cos(angle), speed*sin(angle)), position)
		#change the mode AGAIN based on if its even or odd
	if angle_mode == "angled":
<<<<<<< Updated upstream
		pass
func shoot2(move: Vector2, pos: Vector2):
=======
		bulletShoot(Vector2(speed*cos(angle), speed*sin(angle)), position)
		var aIncrement = 0
		for i in bnum-1:
			#error for integer division
			if i > (bnum-1)/2-1:
				aIncrement = -0.1*(i+1-((bnum-1)/2))
				print(aIncrement)
			else:
				aIncrement = 0.1*(i+1)
				print(aIncrement)
			bulletShoot(Vector2(speed*cos(angle+aIncrement), speed*sin(angle+aIncrement)), position)
			

func bulletShoot(move: Vector2, pos: Vector2):
>>>>>>> Stashed changes
	var bullet = bullet_scene.instantiate()
	add_child(bullet)
	bullet.global_position = pos
	bullet.damage = attack
	bullet.move = move
	canshoot = false
func _timer_timeout() -> void:
	canshoot = true
