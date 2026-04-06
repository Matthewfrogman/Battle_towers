extends Control

var shop_open := true

func _ready() -> void:
	var toggle_btn = Button.new()
	toggle_btn.text = "SHOP"
	toggle_btn.custom_minimum_size = Vector2(60, 25)
	toggle_btn.anchor_left = 0
	toggle_btn.anchor_top = 0
	toggle_btn.offset_left = 163
	toggle_btn.offset_top = 15
	add_child(toggle_btn)

	toggle_btn.pressed.connect(_toggle_shop)

func _toggle_shop() -> void:
	shop_open = !shop_open

	for child in get_children():
		if child is Button and child.text == "SHOP":
			continue
		child.visible = shop_open
