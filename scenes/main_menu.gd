extends Control

@export var appear_sound: AudioStream
@export var appear_sound_volume: float = 0.0
@export var click_sound: AudioStream
@export var click_sound_volume: float = 0.0
const TITLE_TEXT	= "Battle Towers"
const BREATHE_SCALE = 0.03
const BREATHE_SPEED = 1.8
const BG_IMAGE	  = "res://scenes/mapsforselect/mainmenuart/pathway_image.jpg"
const BUTTON_IMAGE  = "res://scenes/mapsforselect/mainmenuart/button.png"

var title_label: Label
var breathe_time := 0.0

func _ready() -> void:
	if appear_sound:
		var audio = AudioStreamPlayer.new()
		audio.stream = appear_sound
		audio.volume_db = appear_sound_volume
		audio.bus = "Master"
		audio.process_mode = Node.PROCESS_MODE_ALWAYS
		get_tree().root.call_deferred("add_child", audio)
		audio.play()
		audio.finished.connect(audio.queue_free)

	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Background
	if ResourceLoader.exists(BG_IMAGE) or ResourceLoader.exists(BG_IMAGE + ".import"):
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

	# Center the glass panel
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	# Frosted glass panel
	var glass := PanelContainer.new()
	var gs := StyleBoxFlat.new()
	gs.bg_color = Color(0.0, 0.0, 0.0, 0.9)
	gs.border_color = Color(0.0, 0.0, 0.0, 0.55)
	gs.set_border_width_all(1)
	gs.set_corner_radius_all(18)
	gs.set_content_margin_all(48)
	glass.add_theme_stylebox_override("panel", gs)
	center.add_child(glass)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 18)
	glass.add_child(vbox)

	# Title
	title_label = Label.new()
	title_label.text = TITLE_TEXT
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 82)
	title_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	title_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
	title_label.add_theme_constant_override("outline_size", 8)
	vbox.add_child(title_label)

	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0, 16)
	vbox.add_child(gap)

	# Buttons
	var play_btn := _make_button("PLAY")
	play_btn.pressed.connect(_on_play_pressed)
	vbox.add_child(play_btn)

	var exit_btn := _make_button("EXIT")
	exit_btn.pressed.connect(_on_exit_pressed)
	vbox.add_child(exit_btn)

	for btn in [play_btn, exit_btn]:
		btn.mouse_entered.connect(_on_hover.bind(btn, true))
		btn.mouse_exited.connect(_on_hover.bind(btn, false))

	# Credits pinned to the bottom of the screen
	var credits := Label.new()
	credits.text = "Logan K  ·  Kyiden C  ·  Jacob C  ·  Jacob D  ·  Matthew H"
	credits.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	credits.anchor_left   = 0.0
	credits.anchor_top	= 1.0
	credits.anchor_right  = 1.0
	credits.anchor_bottom = 1.0
	credits.offset_top	= -30
	credits.offset_bottom = -6
	credits.add_theme_font_size_override("font_size", 12)
	credits.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 0.6))
	add_child(credits)

func _make_button(label_text: String) -> Button:
	var btn := Button.new()
	btn.text = label_text
	btn.custom_minimum_size = Vector2(230, 56)
	btn.clip_contents = false

	if ResourceLoader.exists(BUTTON_IMAGE) or ResourceLoader.exists(BUTTON_IMAGE + ".import"):
		var tex := load(BUTTON_IMAGE)
		var style := StyleBoxTexture.new()
		style.texture = tex
		style.texture_margin_left   = 8
		style.texture_margin_right  = 8
		style.texture_margin_top	= 8
		style.texture_margin_bottom = 8
		btn.add_theme_stylebox_override("normal",  style)
		btn.add_theme_stylebox_override("hover",   style)
		btn.add_theme_stylebox_override("pressed", style)
		btn.add_theme_stylebox_override("focus",   StyleBoxEmpty.new())
		btn.add_theme_font_size_override("font_size", 26)
		btn.add_theme_color_override("font_color",		 Color(0.0, 0.357, 0.137, 1.0))
		btn.add_theme_color_override("font_outline_color", Color(0, 0, 0))
		btn.add_theme_constant_override("outline_size", 3)
	else:
		var s := StyleBoxFlat.new()
		s.bg_color	 = Color(0.1, 0.1, 0.1)
		s.border_color = Color(0.6, 0.6, 0.6)
		s.set_border_width_all(2)
		s.set_corner_radius_all(10)
		btn.add_theme_stylebox_override("normal", s)
		var sh := s.duplicate() as StyleBoxFlat
		sh.bg_color	 = Color(0.2, 0.2, 0.2)
		sh.border_color = Color(0.8, 0.8, 0.8)
		btn.add_theme_stylebox_override("hover", sh)
		var sp := s.duplicate() as StyleBoxFlat
		sp.bg_color = Color(0.05, 0.05, 0.05)
		btn.add_theme_stylebox_override("pressed", sp)
		btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		btn.add_theme_font_size_override("font_size", 26)
		btn.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	return btn

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

func _play_click_sound() -> void:
	if click_sound:
		var audio = AudioStreamPlayer.new()
		audio.stream = click_sound
		audio.volume_db = click_sound_volume
		audio.bus = "Master"
		audio.process_mode = Node.PROCESS_MODE_ALWAYS
		get_tree().root.add_child(audio)
		audio.play()
		audio.finished.connect(audio.queue_free)

func _on_play_pressed() -> void:
	_play_click_sound()
	get_tree().change_scene_to_file("res://scenes/map_select.tscn")

func _on_exit_pressed() -> void:
	_play_click_sound()
	get_tree().quit()
