extends CanvasLayer

var current_tower: Tower = null
var panel: Panel
var name_label: Label
var path_sections: Array = []
var flash_tween: Tween

func _ready() -> void:
	_build_panel()
	hide()
	_connect_existing_towers()

func _build_panel() -> void:
	panel = Panel.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	panel.offset_left   = -260
	panel.offset_top    = 10
	panel.offset_right  = -10
	panel.offset_bottom = 360

	var bg = StyleBoxFlat.new()
	bg.bg_color = Color(0.15, 0.15, 0.15, 0.9)
	bg.border_width_left = 1
	bg.border_width_right = 1
	bg.border_width_top = 1
	bg.border_width_bottom = 1
	bg.border_color = Color(0.35, 0.35, 0.35, 1)
	bg.set_content_margin_all(8)
	panel.add_theme_stylebox_override("panel", bg)
	add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 8
	vbox.offset_top = 8
	vbox.offset_right = -8
	vbox.offset_bottom = -8
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	name_label = Label.new()
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(name_label)
	
	var sep = HSeparator.new()
	vbox.add_child(sep)

	path_sections.clear()
	for p in 3:
		var section = _build_path_section(vbox, p)
		path_sections.append(section)

func _build_path_section(parent: VBoxContainer, path_idx: int) -> Dictionary:
	var path_vbox = VBoxContainer.new()
	path_vbox.add_theme_constant_override("separation", 2)
	parent.add_child(path_vbox)

	var path_label = Label.new()
	path_label.text = "Path %d" % (path_idx + 1)
	path_label.add_theme_font_size_override("font_size", 12)
	path_vbox.add_child(path_label)

	var btns: Array = []
	for tier in 2:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 36)
		btn.text = "..."
		btn.add_theme_font_size_override("font_size", 11)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.clip_text = true
		btn.pressed.connect(_on_upgrade_pressed.bind(path_idx, tier, btn))
		path_vbox.add_child(btn)
		btns.append(btn)

	return {"label": path_label, "btns": btns}

func _connect_existing_towers() -> void:
	for node in get_tree().get_nodes_in_group("towers"):
		_connect_tower(node)

func _connect_tower(tower: Tower) -> void:
	if not tower.tower_selected.is_connected(_on_tower_selected):
		tower.tower_selected.connect(_on_tower_selected)
	if not tower.tower_deselected.is_connected(_on_tower_deselected):
		tower.tower_deselected.connect(_on_tower_deselected)

func register_tower(tower: Tower) -> void:
	_connect_tower(tower)

func _on_tower_selected(tower: Tower) -> void:
	current_tower = tower
	_refresh()
	show()

func _on_tower_deselected() -> void:
	current_tower = null
	hide()

func _refresh() -> void:
	if current_tower == null:
		return
	name_label.text = current_tower.name.replace("_", " ").to_upper()
	var data = current_tower.get_upgrade_data()

	for p in 3:
		var tier_bought = current_tower.path[p]
		var section = path_sections[p]
		var path_data = data[p]

		for t in 2:
			var btn: Button = section["btns"][t]
			var upgrade_info = path_data[t]
			var cost_str = "$%d" % upgrade_info["cost"]

			if t < tier_bought:
				btn.text = "[Done] %s" % upgrade_info["name"]
				btn.disabled = true
			elif t == tier_bought:
				btn.text = "%s - %s" % [upgrade_info["name"], cost_str]
				btn.disabled = false
			else:
				btn.text = "[Locked] %s - %s" % [upgrade_info["name"], cost_str]
				btn.disabled = true

func _on_upgrade_pressed(path_idx: int, tier: int, btn: Button) -> void:
	if current_tower == null:
		return
	if tier != current_tower.path[path_idx]:
		return
	var success = current_tower.try_upgrade(path_idx)
	if success:
		_refresh()
	else:
		_flash_insufficient(btn)

func _flash_insufficient(btn: Button) -> void:
	if flash_tween and flash_tween.is_running():
		flash_tween.kill()
	var orig_col = Color.WHITE
	btn.add_theme_color_override("font_color", Color.RED)
	flash_tween = create_tween()
	flash_tween.tween_interval(0.35)
	flash_tween.tween_callback(func(): btn.add_theme_color_override("font_color", orig_col))
