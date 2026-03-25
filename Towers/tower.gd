class_name Tower extends Area2D

# VVV all the different objects here VVV
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

var canshoot = false
#either hover or placed. If its hovering itll follow the mouse, otherwise itll shoot
var mode = "hover"


func _ready() -> void:
	timer.wait_time = cooldown

func _process(delta: float) -> void:
	#if there is an enemy in range, and cooldown is less/equal to 0, shoot
	if mode == "hover":
		position = get_global_mouse_position()
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			mode = "placed"
	if mode == "placed":
		#get the difference between x and y coords with the closest enemy
		#gives us an angle
		var angle: float
		if canshoot == true:
			shoot(delta, 10, angle, "straight")


#PLANS FOR THIS:
#shoot(eventually some other name) controls the direction and amount
#of each bullet, and also the angles
#whereas shoot2(eventually some other name) actually instantiates the bullets
func shoot(delta: float, speed: int, angle: float, angle_mode: String):
	#ideas for parameters: amount, angle, bullet speed
	#the ability to shoot and go in different directions, or shoot in the same direction
	if angle_mode == "straight":
		for shots in 5:
			print("blast")
			shoot2(Vector2(1*delta, 2*delta))
		#change the mode AGAIN based on if its even or odd
	
	if angle_mode == "angled":
		pass

func shoot2(move: Vector2):
	var bullet = bullet_scene.instantiate()
	add_child(bullet)
	bullet.damage = attack
	bullet.move = move
	canshoot = false


func _timer_timeout() -> void:
	canshoot = true
