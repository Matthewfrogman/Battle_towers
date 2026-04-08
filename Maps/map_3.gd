extends TileMap

@export var player_hp = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_hp <= 0:
		game_over()

func game_over():
	print("u ded 67")
