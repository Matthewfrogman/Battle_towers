extends Control

@export var appear_sound: AudioStream
@export var appear_sound_volume: float = 0.0
@export var click_sound: AudioStream
@export var click_sound_volume: float = 0.0
const MAIN_MENU = "res://scenes/main_menu.tscn"
const BG_IMAGE  = "res://scenes/mapsforselect/mainmenuart/pathway_image.jpg"

var _breathe_time := 0.0
var _title_label: Label

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
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

	for child in get_tree().root.get_children():
		if child == self:
			continue
		if child is Enemy or child is Tower:
			child.queue_free()

	var canvas := CanvasLayer.new()
	canvas.layer = 200
	add_child(canvas)

	var root_ctrl := Control.new()
	root_ctrl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(root_ctrl)

	# Background
	if ResourceLoader.exists(BG_IMAGE) or ResourceLoader.exists(BG_IMAGE + ".import"):
		var bg := TextureRect.new()
		bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		bg.texture = load(BG_IMAGE)
		bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		bg.modulate = Color(0.4, 0.4, 0.4)
		root_ctrl.add_child(bg)
	else:
		var bg := ColorRect.new()
		bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		bg.color = Color(0.0, 0.0, 0.0)
		root_ctrl.add_child(bg)

	# Dark overlay
	var overlay := ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.0, 0.0, 0.0, 0.50)
	root_ctrl.add_child(overlay)

	# Center column
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_ctrl.add_child(center)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 20)
	center.add_child(vbox)

	# Glass panel behind content
	var glass := PanelContainer.new()
	var glass_style := StyleBoxFlat.new()
	glass_style.bg_color = Color(0.0, 0.0, 0.0, 0.9)
	glass_style.border_color = Color(0.4, 0.4, 0.4, 0.6)
	glass_style.set_border_width_all(1)
	glass_style.set_corner_radius_all(18)
	glass_style.set_content_margin_all(48)
	glass.add_theme_stylebox_override("panel", glass_style)
	vbox.add_child(glass)

	var inner := VBoxContainer.new()
	inner.alignment = BoxContainer.ALIGNMENT_CENTER
	inner.add_theme_constant_override("separation", 18)
	glass.add_child(inner)

	# Title
	_title_label = Label.new()
	_title_label.text = "DEFEAT"
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 96)
	_title_label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
	_title_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
	_title_label.add_theme_constant_override("outline_size", 8)
	inner.add_child(_title_label)

	# Subtitle
	var sub := Label.new()
	sub.text = "Your base has fallen."
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 26)
	sub.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	sub.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	sub.add_theme_constant_override("outline_size", 3)
	inner.add_child(sub)

	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0, 10)
	inner.add_child(gap)

	# Button row
	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 18)
	inner.add_child(btn_row)

	var retry_btn := _make_button("RETRY")
	retry_btn.pressed.connect(_on_retry)
	btn_row.add_child(retry_btn)

	var menu_btn := _make_button("MAIN MENU")
	menu_btn.pressed.connect(_on_menu)
	btn_row.add_child(menu_btn)

	var quit_btn := _make_button("QUIT")
	quit_btn.pressed.connect(_on_quit)
	btn_row.add_child(quit_btn)

	for btn in [retry_btn, menu_btn, quit_btn]:
		btn.mouse_entered.connect(_on_hover.bind(btn, true))
		btn.mouse_exited.connect(_on_hover.bind(btn, false))

	# Fade-in
	_title_label.modulate.a = 0.0
	var t := create_tween()
	t.tween_property(_title_label, "modulate:a", 1.0, 0.9).set_trans(Tween.TRANS_SINE)

func _make_button(lbl: String) -> Button:
	var btn := Button.new()
	btn.text = lbl
	btn.custom_minimum_size = Vector2(190, 54)

	var s := StyleBoxFlat.new()
	s.bg_color		= Color(0.1, 0.1, 0.1)
	s.border_color	= Color(0.6, 0.6, 0.6)
	s.set_border_width_all(2)
	s.set_corner_radius_all(10)
	s.set_content_margin_all(8)
	btn.add_theme_stylebox_override("normal", s)

	var sh := s.duplicate() as StyleBoxFlat
	sh.bg_color	 = Color(0.2, 0.2, 0.2)
	sh.border_color = Color(0.8, 0.8, 0.8)
	btn.add_theme_stylebox_override("hover", sh)

	var sp := s.duplicate() as StyleBoxFlat
	sp.bg_color = Color(0.05, 0.05, 0.05)
	btn.add_theme_stylebox_override("pressed", sp)
	btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

	btn.add_theme_font_size_override("font_size", 22)
	btn.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	btn.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	btn.add_theme_constant_override("outline_size", 2)
	return btn

func _on_hover(btn: Button, hov: bool) -> void:
	var t := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_property(btn, "scale", Vector2(1.08 if hov else 1.0, 1.08 if hov else 1.0), 0.12)
	btn.pivot_offset = btn.size / 2.0

func _process(delta: float) -> void:
	_breathe_time += delta * 1.8
	var s := 1.0 + sin(_breathe_time) * 0.025
	_title_label.scale = Vector2(s, s)
	_title_label.pivot_offset = _title_label.size / 2.0

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

func _on_retry() -> void:
	_play_click_sound()
	Engine.time_scale = 1.0
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu() -> void:
	_play_click_sound()
	Engine.time_scale = 1.0
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU)

func _on_quit() -> void:
	_play_click_sound()
	Engine.time_scale = 1.0
	get_tree().quit()
