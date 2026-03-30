extends CanvasLayer
var money = 500
var tower_scene = preload("res://Towers/tower.tscn")
var fast_forward = false
var ff_button = null

func _ready():
	var panel = $Panel

	var label = $Panel/MoneyLabel
	label.text = "Money: $500"
	label.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	label.offset_left = 10
	label.offset_top = 10
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(0, 0, 0, 1))

	var btn = $Panel/BuyTowerBtn
	btn.text = "Tower - $200"
	btn.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	btn.offset_left = 10
	btn.offset_top = 35
	btn.offset_right = 170
	btn.offset_bottom = 75
	btn.add_theme_font_size_override("font_size", 13)

	ff_button = Button.new()
	ff_button.text = "▶▶"
	ff_button.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	ff_button.offset_left = 10
	ff_button.offset_top = 85
	ff_button.offset_right = 170
	ff_button.offset_bottom = 125
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

func _on_buy_tower_btn_pressed():
	if money >= 200:
		money -= 200
		update_money_label()
		var tower = tower_scene.instantiate()
		get_tree().current_scene.add_child(tower)
		tower.global_position = tower.get_global_mouse_position()

func update_money_label():
	$Panel/MoneyLabel.text = "Money: $" + str(money)

func add_money(amount):
	money += amount
	update_money_label()
