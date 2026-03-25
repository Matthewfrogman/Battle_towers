class_name Tower extends Area2D

@onready var timer = get_node("Cooldown Timer")

#the radius of where it can shoot
@export var range: int
#the time it takes to shoot
@export var cooldown: float = 5.0

var canshoot = false
#whether or not its attacking or being place
var mode
#a reference to the bullet/projectile it instantiates
var bullet_scene: PackedScene = preload("res://Towers/Bullets/bullet.tscn")


func _ready() -> void:
	timer.wait_time = cooldown

func _process(delta: float) -> void:
	#if there is an enemy in range, and cooldown is less/equal to 0, shoot
	if canshoot == true:
		shoot(10)

func shoot(speed):
	#ideas for parameters: amount, angle, bullet speed
	#shoot a bullet in a direction
	print("shot!")
	var bullet = bullet_scene.instantiate()
	add_child(bullet)
	bullet.hspeed = 5.0*speed
	bullet.vspeed = 5.0*speed
	canshoot = false


func _timer_timeout() -> void:
	canshoot = true
