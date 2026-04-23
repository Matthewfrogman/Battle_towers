extends TileMap

@export var player_hp = 100
var deathscene: PackedScene = preload("res://game_over.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if player_hp <= 0 and not get_tree().paused:
		game_over()

func game_over():
	get_tree().paused = true
	var death_screen = deathscene.instantiate()
	add_child(death_screen)
