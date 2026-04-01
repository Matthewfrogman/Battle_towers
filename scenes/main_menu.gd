extends Control
const TITLE_TEXT    = "Battle Towers"
const BUTTON_HOVER  = 1.12
const TWEEN_SPEED   = 0.15
const BREATHE_SCALE = 0.04
const BREATHE_SPEED = 2.0
const BG_IMAGE      = "res://scenes/mapsforselect/mainmenuart/pathway_image.jpg"
const BUTTON_IMAGE  = "res://scenes/mapsforselect/mainmenuart/button.png"
var title_label : Label
var breathe_time := 0.0
func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if ResourceLoader.exists(BG_IMAGE):
		var bg = TextureRect.new()
		bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		bg.texture = load(BG_IMAGE)
		bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		add_child(bg)
	else:
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
	title_label.text = TITLE_TEXT
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 72)
	title_label.add_theme_color_override("font_color", Color(0.2, 0.85, 0.2))
	title_label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	title_label.add_theme_constant_override("outline_size", 30)
	vbox.add_child(title_label)
	var play_button = _make_button("PLAY")
	play_button.pressed.connect(_on_play_pressed)
	vbox.add_child(play_button)
	var exit_button = _make_button("EXIT")
	exit_button.pressed.connect(_on_exit_pressed)
	vbox.add_child(exit_button)
	for btn in [play_button, exit_button]:
		btn.mouse_entered.connect(_on_hover.bind(btn, true))
		btn.mouse_exited.connect(_on_hover.bind(btn, false))
func _make_button(label_text: String) -> Button:
	var btn = Button.new()
	btn.text = label_text
	btn.custom_minimum_size = Vector2(220, 60)
	btn.clip_contents = false
	if ResourceLoader.exists(BUTTON_IMAGE):
		var tex = load(BUTTON_IMAGE)
		var style = StyleBoxTexture.new()
		style.texture = tex
		style.texture_margin_left = 8
		style.texture_margin_right = 8
		style.texture_margin_top = 8
		style.texture_margin_bottom = 8
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)
		btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		btn.add_theme_font_size_override("font_size", 26)
		btn.add_theme_color_override("font_color", Color(0.0, 0.357, 0.137, 1.0))
		btn.add_theme_color_override("font_outline_color", Color(0, 0, 0))
		btn.add_theme_constant_override("outline_size", 30)
	else:
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.15, 0.15, 0.22)
		style.border_color = Color(0.0, 0.494, 0.201, 0.702)
		style.set_border_width_all(2)
		style.set_corner_radius_all(12)
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)
		btn.add_theme_font_size_override("font_size", 28)
		btn.add_theme_color_override("font_color", Color(0.0, 0.54, 0.222, 1.0))
		btn.add_theme_constant_override("outline_size", 30)
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
func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/map_select.tscn")
func _on_exit_pressed() -> void:
	get_tree().quit()
