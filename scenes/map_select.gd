extends Control
#change placeholder maps (refer to discord for tutorial)
const MAPS = ["Map 1", "Map 2", "Map 3"]
const MAP_IMAGES = [
	"res://scenes/mapsforselect/plains.png",
	"res://scenes/mapsforselect/volcano.png",
	"res://scenes/mapsforselect/chaos.png"
]
const BUTTON_HOVER  = 1.12
const TWEEN_SPEED   = 0.15
const BREATHE_SCALE = 0.04
const BREATHE_SPEED = 2.0

var current_index := 0
var title_label : Label
var map_image : TextureRect
var breathe_time := 0.0

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var bg = ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.07, 0.07, 0.10)
	add_child(bg)

	var center = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 32)
	center.add_child(vbox)

	title_label = Label.new()
	title_label.text = "Map Select"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 72)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.4))
	vbox.add_child(title_label)

	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 24)
	vbox.add_child(hbox)

	var left_btn = _make_arrow_button("<")
	left_btn.pressed.connect(_on_left)
	hbox.add_child(left_btn)

	var frame = PanelContainer.new()
	frame.custom_minimum_size = Vector2(260, 160)
	var frame_style = StyleBoxFlat.new()
	frame_style.bg_color = Color(0.12, 0.12, 0.18)
	frame_style.border_color = Color(1.0, 0.92, 0.4, 0.5)
	frame_style.set_border_width_all(2)
	frame_style.set_corner_radius_all(12)
	frame.add_theme_stylebox_override("panel", frame_style)
	hbox.add_child(frame)

	map_image = TextureRect.new()
	map_image.custom_minimum_size = Vector2(260, 160)
	map_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	map_image.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	map_image.texture = load(MAP_IMAGES[current_index])
	frame.add_child(map_image)

	var right_btn = _make_arrow_button(">")
	right_btn.pressed.connect(_on_right)
	hbox.add_child(right_btn)

	var play_btn = _make_button("PLAY")
	play_btn.pressed.connect(_on_play)
	vbox.add_child(play_btn)

	var back_btn = _make_button("BACK")
	back_btn.pressed.connect(_on_back)
	vbox.add_child(back_btn)

	for btn in [play_btn, back_btn]:
		btn.mouse_entered.connect(_on_hover.bind(btn, true))
		btn.mouse_exited.connect(_on_hover.bind(btn, false))

	for btn in [left_btn, right_btn]:
		btn.mouse_entered.connect(_on_hover.bind(btn, true))
		btn.mouse_exited.connect(_on_hover.bind(btn, false))


func _make_button(label_text: String) -> Button:
	var btn = Button.new()
	btn.text = label_text
	btn.custom_minimum_size = Vector2(220, 60)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.22)
	style.border_color = Color(1.0, 0.92, 0.4, 0.7)
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("pressed", style)
	btn.add_theme_font_size_override("font_size", 28)
	btn.add_theme_color_override("font_color", Color(1.0, 0.92, 0.4))
	return btn


func _make_arrow_button(label_text: String) -> Button:
	var btn = Button.new()
	btn.text = label_text
	btn.custom_minimum_size = Vector2(60, 60)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.22)
	style.border_color = Color(1.0, 0.92, 0.4, 0.7)
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("pressed", style)
	btn.add_theme_font_size_override("font_size", 32)
	btn.add_theme_color_override("font_color", Color(1.0, 0.92, 0.4))
	return btn


func _on_hover(btn: Button, hovering: bool) -> void:
	var target = BUTTON_HOVER if hovering else 1.0
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(btn, "scale", Vector2(target, target), TWEEN_SPEED)
	btn.pivot_offset = btn.size / 2.0


func _process(delta: float) -> void:
	breathe_time += delta * BREATHE_SPEED
	var s = 1.0 + sin(breathe_time) * BREATHE_SCALE
	title_label.scale = Vector2(s, s)
	title_label.pivot_offset = title_label.size / 2.0


func _on_left() -> void:
	current_index = (current_index - 1 + MAPS.size()) % MAPS.size()
	map_image.texture = load(MAP_IMAGES[current_index])


func _on_right() -> void:
	current_index = (current_index + 1) % MAPS.size()
	map_image.texture = load(MAP_IMAGES[current_index])


func _on_play() -> void:
	print("Launch map: ", MAPS[current_index])


func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
