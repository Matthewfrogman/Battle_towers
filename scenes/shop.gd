extends CanvasLayer

var money = 650
var tower_scenes = {
	"Basic":  "res://Towers/basic_tower.tscn",
	"Sniper": "res://Towers/sniper.tscn",
	"Camo":   "res://Towers/camo_tower.tscn",
	"Speed":  "res://Towers/speed_tower.tscn",
	"Tesla":  "res://Towers/tesla.tscn"
}
var tower_costs = {
	"Basic":  200,
	"Sniper": 800,
	"Camo":   1000,
	"Speed":  250,
	"Tesla":  1250
}

var fast_forward   = false
var shop_collapsed = false
var ff_button: Button
var toggle_btn: Button
var shop_panel: Panel
var money_label: Label
var upgrade_panel = null

const SHOP_W = 160

func _ready() -> void:
	add_to_group("shop_ui")
	_build_ui()
	_spawn_upgrade_panel()

func _build_ui() -> void:
	# Money label — always visible, top-left, just plain text with a shadow
	money_label = Label.new()
	money_label.text = "Money: $%d" % money
	money_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	money_label.offset_left   = 6
	money_label.offset_top    = 5
	money_label.offset_right  = 220
	money_label.offset_bottom = 26
	money_label.add_theme_font_size_override("font_size", 14)
	money_label.add_theme_color_override("font_color", Color.WHITE)
	money_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	money_label.add_theme_constant_override("shadow_offset_x", 1)
	money_label.add_theme_constant_override("shadow_offset_y", 1)
	add_child(money_label)

	# Shop panel — plain dark rectangle
	shop_panel = Panel.new()
	shop_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	shop_panel.offset_left   = 0
	shop_panel.offset_top    = 28
	shop_panel.offset_right  = SHOP_W
	shop_panel.offset_bottom = 28 + 5 * 52 + 50
	var bg = StyleBoxFlat.new()
	bg.bg_color = Color(0.15, 0.15, 0.15, 0.9)
	bg.border_width_right  = 1
	bg.border_width_bottom = 1
	bg.border_color = Color(0.35, 0.35, 0.35, 1)
	bg.set_content_margin_all(6)
	shop_panel.add_theme_stylebox_override("panel", bg)
	add_child(shop_panel)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left   = 6
	vbox.offset_top    = 6
	vbox.offset_right  = -6
	vbox.offset_bottom = -6
	vbox.add_theme_constant_override("separation", 4)
	shop_panel.add_child(vbox)

	for tower_name in tower_scenes.keys():
		var cost = tower_costs[tower_name]
		var btn = Button.new()
		btn.text = "%s - $%d" % [tower_name, cost]
		btn.custom_minimum_size = Vector2(0, 44)
		btn.add_theme_font_size_override("font_size", 13)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(_on_tower_button_pressed.bind(tower_name))
		vbox.add_child(btn)

	var sep = HSeparator.new()
	vbox.add_child(sep)

	ff_button = Button.new()
	ff_button.text = "Speed: Normal"
	ff_button.custom_minimum_size = Vector2(0, 32)
	ff_button.add_theme_font_size_override("font_size", 12)
	ff_button.pressed.connect(_on_ff_pressed)
	vbox.add_child(ff_button)

	# Collapse toggle button
	toggle_btn = Button.new()
	toggle_btn.text = "<"
	toggle_btn.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	toggle_btn.offset_left   = SHOP_W
	toggle_btn.offset_top    = 34
	toggle_btn.offset_right  = SHOP_W + 16
	toggle_btn.offset_bottom = 56
	toggle_btn.add_theme_font_size_override("font_size", 10)
	toggle_btn.pressed.connect(_on_toggle_pressed)
	add_child(toggle_btn)

func _on_toggle_pressed() -> void:
	shop_collapsed = !shop_collapsed
	shop_panel.visible = !shop_collapsed
	toggle_btn.text = ">" if shop_collapsed else "<"

func _on_ff_pressed() -> void:
	fast_forward = !fast_forward
	Engine.time_scale = 2.0 if fast_forward else 1.0
	ff_button.text = "Speed: Fast" if fast_forward else "Speed: Normal"

func _on_tower_button_pressed(tower_name: String) -> void:
	var cost = tower_costs[tower_name]
	if money < cost:
		return
	var tower_path = tower_scenes[tower_name]
	if not ResourceLoader.exists(tower_path):
		push_warning("Tower scene not found: " + tower_path)
		return
	money -= cost
	update_money_label()
	var tower_scene = load(tower_path)
	var tower = tower_scene.instantiate()
	tower.add_to_group("towers")
	get_tree().root.add_child(tower)
	tower.global_position = tower.get_global_mouse_position()
	if upgrade_panel:
		upgrade_panel.register_tower(tower)

func update_money_label() -> void:
	if money_label:
		money_label.text = "Money: $%d" % money

func add_money(amount: int) -> void:
	money += amount
	update_money_label()

func spend_money(amount: int) -> void:
	money -= amount
	update_money_label()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("test_4"):
		add_money(5000)

func _spawn_upgrade_panel() -> void:
	var script = load("res://scenes/upgrade_panel.gd")
	upgrade_panel = script.new()
	upgrade_panel.name = "UpgradePanel"
	add_child(upgrade_panel)
