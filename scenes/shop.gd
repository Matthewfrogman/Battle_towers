extends CanvasLayer

var money = 500
var tower_scenes = {
	"Basic": "res://Towers/basic_tower.tscn",
	"Sniper": "res://Towers/sniper_tower.tscn",
	"Camo": "res://Towers/camo_tower.tscn",
	"Speed": "res://Towers/ice_tower.tscn",
	"Tesla": "res://Towers/tesla.tscn"
}
var tower_costs = {
	"Basic": 200,
	"Sniper": 350,
	"Camo": 400,
	"Speed": 300,
	"Tesla": 500
}
var fast_forward = false
var ff_button = null

func _ready():
	var panel = $Panel
	
	# Money label
	var label = $Panel/MoneyLabel
	label.text = "Money: $500"
	label.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	label.offset_left = 10
	label.offset_top = 10
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	
	# Create 5 tower buttons
	var y_offset = 35
	var button_height = 50
	var button_spacing = 5
	var button_width = 150
	
	for i in range(5):
		var tower_name = tower_scenes.keys()[i]
		var cost = tower_costs[tower_name]
		
		var btn = Button.new()
		btn.text = tower_name + " - $" + str(cost)
		btn.custom_minimum_size = Vector2(button_width, button_height)
		btn.position = Vector2(10, y_offset + (i * (button_height + button_spacing)))
		btn.add_theme_font_size_override("font_size", 18)
		btn.pressed.connect(_on_tower_button_pressed.bind(tower_name))
		panel.add_child(btn)
	
	# Fast forward button at bottom
	ff_button = Button.new()
	ff_button.text = "▶▶"
	ff_button.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	ff_button.custom_minimum_size = Vector2(150, 25)
	ff_button.offset_left = 10
	ff_button.offset_bottom = -10
	ff_button.add_theme_font_size_override("font_size", 18)
	
	var ff_style = StyleBoxFlat.new()
	ff_style.bg_color = Color(0.1, 0.5, 0.1, 1)
	ff_style.set_corner_radius_all(6)
	ff_button.add_theme_stylebox_override("normal", ff_style)
	ff_button.add_theme_stylebox_override("hover", ff_style)
	ff_button.add_theme_stylebox_override("pressed", ff_style)
	ff_button.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	ff_button.pressed.connect(_on_ff_pressed)
	panel.add_child(ff_button)

func _on_ff_pressed():
	fast_forward = !fast_forward
	if fast_forward:
		Engine.time_scale = 2.0
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.2, 0.9, 0.2, 1)
		style.set_corner_radius_all(6)
		ff_button.add_theme_stylebox_override("normal", style)
		ff_button.add_theme_stylebox_override("hover", style)
		ff_button.add_theme_stylebox_override("pressed", style)
	else:
		Engine.time_scale = 1.0
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.1, 0.5, 0.1, 1)
		style.set_corner_radius_all(6)
		ff_button.add_theme_stylebox_override("normal", style)
		ff_button.add_theme_stylebox_override("hover", style)
		ff_button.add_theme_stylebox_override("pressed", style)

func _on_tower_button_pressed(tower_name):
	var cost = tower_costs[tower_name]
	if money >= cost:
		var tower_path = tower_scenes[tower_name]
		
		# Check if file exists
		if ResourceLoader.exists(tower_path):
			money -= cost
			update_money_label()
			var tower_scene = load(tower_path)
			var tower = tower_scene.instantiate()
			get_tree().root.add_child(tower)
			tower.global_position = tower.get_global_mouse_position()
		else:
			print("Tower scene not found: " + tower_path + " (placeholder)")

func update_money_label():
	$Panel/MoneyLabel.text = "Money: $" + str(money)

func add_money(amount):
	money += amount
	update_money_label()
