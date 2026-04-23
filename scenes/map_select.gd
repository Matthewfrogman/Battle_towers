extends Control

const MAPS = ["Map 1", "Map 2", "Map 3"]
const MAP_SUBTITLES = ["The Plains", "The Volcano", "The Cyber Grid"]
const MAP_IMAGES = [
	"res://scenes/mapsforselect/plains.png",
	"res://scenes/mapsforselect/volcano.png",
	"res://scenes/mapsforselect/cyber.png"
]
const MAP_SCENES = [
	"res://Maps/Map_1.tscn",
	"res://Maps/Map_2.tscn",
	"res://Maps/Map_3.tscn"
]
const BG_IMAGE     = "res://scenes/mapsforselect/mainmenuart/pathway_image.jpg"
const BUTTON_IMAGE = "res://scenes/mapsforselect/mainmenuart/button.png"
const BREATHE_SCALE = 0.03
const BREATHE_SPEED = 1.8

var current_index := 0
var title_label:  Label
var map_image:    TextureRect
var map_name_lbl: Label
var map_sub_lbl:  Label
var index_lbl:    Label
var breathe_time  := 0.0

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Background
	if ResourceLoader.exists(BG_IMAGE):
		var bg := TextureRect.new()
		bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		bg.texture = load(BG_IMAGE)
		bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		add_child(bg)
	else:
		var bg := ColorRect.new()
		bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		bg.color = Color(0.06, 0.08, 0.06)
		add_child(bg)

	# Dark overlay
	var overlay := ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.0, 0.0, 0.0, 0.58)
	add_child(overlay)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	# Glass panel
	var glass := PanelContainer.new()
	var gs := StyleBoxFlat.new()
	gs.bg_color = Color(0.0, 0.0, 0.0, 0.9)
	gs.border_color = Color(0.4, 0.4, 0.4, 0.6)
	gs.set_border_width_all(1)
	gs.set_corner_radius_all(18)
	gs.set_content_margin_all(40)
	glass.add_theme_stylebox_override("panel", gs)
	center.add_child(glass)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 16)
	glass.add_child(vbox)

	# Title
	title_label = Label.new()
	title_label.text = "Select Map"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 72)
	title_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	title_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
	title_label.add_theme_constant_override("outline_size", 7)
	vbox.add_child(title_label)

	# Map name label
	map_name_lbl = Label.new()
	map_name_lbl.text = MAPS[current_index]
	map_name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	map_name_lbl.add_theme_font_size_override("font_size", 28)
	map_name_lbl.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95))
	map_name_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	map_name_lbl.add_theme_constant_override("outline_size", 3)
	vbox.add_child(map_name_lbl)

	# Map subtitle (flavour name)
	map_sub_lbl = Label.new()
	map_sub_lbl.text = MAP_SUBTITLES[current_index]
	map_sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	map_sub_lbl.add_theme_font_size_override("font_size", 15)
	map_sub_lbl.add_theme_color_override("font_color", Color(0.65, 0.65, 0.65))
	vbox.add_child(map_sub_lbl)

	# Arrow row + map image
	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 18)
	vbox.add_child(hbox)

	var left_btn := _make_arrow("<")
	left_btn.pressed.connect(_on_left)
	hbox.add_child(left_btn)

	# Map image frame
	var frame := PanelContainer.new()
	frame.custom_minimum_size = Vector2(280, 175)
	var frame_style := StyleBoxFlat.new()
	frame_style.bg_color = Color(0.1, 0.1, 0.1)
	frame_style.border_color = Color(0.5, 0.5, 0.5)
	frame_style.set_border_width_all(2)
	frame_style.set_corner_radius_all(10)
	frame.add_theme_stylebox_override("panel", frame_style)
	hbox.add_child(frame)

	map_image = TextureRect.new()
	map_image.custom_minimum_size = Vector2(280, 175)
	map_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	map_image.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	if ResourceLoader.exists(MAP_IMAGES[current_index]):
		map_image.texture = load(MAP_IMAGES[current_index])
	frame.add_child(map_image)

	var right_btn := _make_arrow(">")
	right_btn.pressed.connect(_on_right)
	hbox.add_child(right_btn)

	# Index indicator  "1 / 3"
	index_lbl = Label.new()
	index_lbl.text = "%d / %d" % [current_index + 1, MAPS.size()]
	index_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	index_lbl.add_theme_font_size_override("font_size", 14)
	index_lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	vbox.add_child(index_lbl)

	# Play / Back buttons
	var play_btn := _make_button("PLAY")
	play_btn.pressed.connect(_on_play)
	vbox.add_child(play_btn)

	var back_btn := _make_button("BACK")
	back_btn.pressed.connect(_on_back)
	vbox.add_child(back_btn)

	for btn in [play_btn, back_btn, left_btn, right_btn]:
		btn.mouse_entered.connect(_on_hover.bind(btn, true))
		btn.mouse_exited.connect(_on_hover.bind(btn, false))

func _make_button(label_text: String) -> Button:
	var btn := Button.new()
	btn.text = label_text
	btn.custom_minimum_size = Vector2(220, 54)
	if ResourceLoader.exists(BUTTON_IMAGE):
		var tex := load(BUTTON_IMAGE)
		var style := StyleBoxTexture.new()
		style.texture = tex
		style.texture_margin_left   = 8
		style.texture_margin_right  = 8
		style.texture_margin_top    = 8
		style.texture_margin_bottom = 8
		btn.add_theme_stylebox_override("normal",  style)
		btn.add_theme_stylebox_override("hover",   style)
		btn.add_theme_stylebox_override("pressed", style)
		btn.add_theme_stylebox_override("focus",   StyleBoxEmpty.new())
		btn.add_theme_font_size_override("font_size", 26)
		btn.add_theme_color_override("font_color",         Color(0.0, 0.415, 0.121, 1.0))
		btn.add_theme_color_override("font_outline_color", Color(0, 0, 0))
		btn.add_theme_constant_override("outline_size", 3)
	else:
		var s := StyleBoxFlat.new()
		s.bg_color     = Color(0.1, 0.1, 0.1)
		s.border_color = Color(0.6, 0.6, 0.6)
		s.set_border_width_all(2)
		s.set_corner_radius_all(10)
		btn.add_theme_stylebox_override("normal", s)
		var sh := s.duplicate() as StyleBoxFlat
		sh.bg_color     = Color(0.2, 0.2, 0.2)
		sh.border_color = Color(0.8, 0.8, 0.8)
		btn.add_theme_stylebox_override("hover", sh)
		var sp := s.duplicate() as StyleBoxFlat
		sp.bg_color = Color(0.05, 0.05, 0.05)
		btn.add_theme_stylebox_override("pressed", sp)
		btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		btn.add_theme_font_size_override("font_size", 26)
		btn.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	return btn

func _make_arrow(label_text: String) -> Button:
	var btn := Button.new()
	btn.text = label_text
	btn.custom_minimum_size = Vector2(52, 52)
	if ResourceLoader.exists(BUTTON_IMAGE):
		var tex := load(BUTTON_IMAGE)
		var style := StyleBoxTexture.new()
		style.texture = tex
		style.texture_margin_left   = 8
		style.texture_margin_right  = 8
		style.texture_margin_top    = 8
		style.texture_margin_bottom = 8
		btn.add_theme_stylebox_override("normal",  style)
		btn.add_theme_stylebox_override("hover",   style)
		btn.add_theme_stylebox_override("pressed", style)
		btn.add_theme_stylebox_override("focus",   StyleBoxEmpty.new())
		btn.add_theme_font_size_override("font_size", 28)
		btn.add_theme_color_override("font_color",         Color(0.0, 0.391, 0.004, 1.0))
		btn.add_theme_color_override("font_outline_color", Color(0, 0, 0))
		btn.add_theme_constant_override("outline_size", 3)
	else:
		var s := StyleBoxFlat.new()
		s.bg_color     = Color(0.1, 0.1, 0.1)
		s.border_color = Color(0.6, 0.6, 0.6)
		s.set_border_width_all(2)
		s.set_corner_radius_all(10)
		btn.add_theme_stylebox_override("normal", s)
		var sh := s.duplicate() as StyleBoxFlat
		sh.bg_color = Color(0.2, 0.2, 0.2)
		btn.add_theme_stylebox_override("hover", sh)
		var sp := s.duplicate() as StyleBoxFlat
		sp.bg_color = Color(0.05, 0.05, 0.05)
		btn.add_theme_stylebox_override("pressed", sp)
		btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		btn.add_theme_font_size_override("font_size", 28)
		btn.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	return btn

func _update_map_display() -> void:
	if ResourceLoader.exists(MAP_IMAGES[current_index]):
		map_image.texture = load(MAP_IMAGES[current_index])
	map_name_lbl.text = MAPS[current_index]
	map_sub_lbl.text  = MAP_SUBTITLES[current_index]
	index_lbl.text    = "%d / %d" % [current_index + 1, MAPS.size()]

func _on_hover(btn: Button, hovering: bool) -> void:
	var target_scale := 1.10 if hovering else 1.0
	var target_mod   := Color(1.3, 1.3, 1.3) if hovering else Color.WHITE
	var tween := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	tween.tween_property(btn, "scale", Vector2(target_scale, target_scale), 0.13)
	tween.tween_property(btn, "self_modulate", target_mod, 0.13)
	btn.pivot_offset = btn.size / 2.0

func _process(delta: float) -> void:
	breathe_time += delta * BREATHE_SPEED
	var s := 1.0 + sin(breathe_time) * BREATHE_SCALE
	title_label.scale = Vector2(s, s)
	title_label.pivot_offset = title_label.size / 2.0

func _on_left() -> void:
	current_index = (current_index - 1 + MAPS.size()) % MAPS.size()
	_update_map_display()

func _on_right() -> void:
	current_index = (current_index + 1) % MAPS.size()
	_update_map_display()

func _on_play() -> void:
	var scene_path: String = MAP_SCENES[current_index]
	if ResourceLoader.exists(scene_path):
		get_tree().change_scene_to_file(scene_path)
	else:
		push_warning("Map scene not found: " + scene_path)

func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
