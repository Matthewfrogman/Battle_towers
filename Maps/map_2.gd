extends TileMap

@export var player_hp = 100
<<<<<<< HEAD
=======
var deathscene: PackedScene = preload("res://scenes/deathscreen.tscn")
>>>>>>> 6e507bd20e927fc484a670d551e60c8415afd52b

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_hp <= 0:
		game_over()

func game_over():
<<<<<<< HEAD
	print("u ded 67")
=======
	var death_screen = deathscene.instantiate()
	add_child(death_screen)
>>>>>>> 6e507bd20e927fc484a670d551e60c8415afd52b
