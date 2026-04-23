extends CanvasLayer

var current_tower: Tower = null
var panel: Panel
var name_label: Label
var path_sections: Array = []
var flash_tween: Tween
var sell_btn: Button

var tooltip_panel: Panel
var tooltip_label: Label

func _ready() -> void:
	_build_tooltip()
	_build_panel()
	hide()
	_connect_existing_towers()

func _build_tooltip() -> void:
	tooltip_panel = Panel.new()
	tooltip_panel.visible = false
	tooltip_panel.z_index = 10

	var bg = StyleBoxFlat.new()
	bg.bg_color = Color(0.1, 0.1, 0.1, 0.95)
	bg.border_width_left   = 1
	bg.border_width_right  = 1
	bg.border_width_top    = 1
	bg.border_width_bottom = 1
	bg.border_color = Color(0.45, 0.45, 0.45, 1)
	bg.set_content_margin_all(8)
	tooltip_panel.add_theme_stylebox_override("panel", bg)
	add_child(tooltip_panel)

	tooltip_label = Label.new()
	tooltip_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tooltip_label.add_theme_font_size_override("font_size", 11)
	tooltip_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	tooltip_panel.add_child(tooltip_label)

func _build_panel() -> void:
	panel = Panel.new()
	panel.anchor_left   = 1.0
	panel.anchor_top    = 0.5
	panel.anchor_right  = 1.0
	panel.anchor_bottom = 0.5
	panel.offset_left   = -265
	panel.offset_top    = -240
	panel.offset_right  = -10
	panel.offset_bottom = 240

	var bg = StyleBoxFlat.new()
	bg.bg_color = Color(0.15, 0.15, 0.15, 0.9)
	bg.border_width_left   = 1
	bg.border_width_right  = 1
	bg.border_width_top    = 1
	bg.border_width_bottom = 1
	bg.border_color = Color(0.35, 0.35, 0.35, 1)
	bg.set_content_margin_all(8)
	panel.add_theme_stylebox_override("panel", bg)
	add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left   = 8
	vbox.offset_top    = 8
	vbox.offset_right  = -8
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

	var sep2 = HSeparator.new()
	vbox.add_child(sep2)

	sell_btn = Button.new()
	sell_btn.custom_minimum_size = Vector2(0, 36)
	sell_btn.text = "Sell"
	sell_btn.add_theme_font_size_override("font_size", 13)
	
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.6, 0.15, 0.15)
	sb.border_color = Color(0.8, 0.2, 0.2)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(6)
	sell_btn.add_theme_stylebox_override("normal", sb)

	var sb_h = sb.duplicate() as StyleBoxFlat
	sb_h.bg_color = Color(0.75, 0.2, 0.2)
	sell_btn.add_theme_stylebox_override("hover", sb_h)

	var sb_p = sb.duplicate() as StyleBoxFlat
	sb_p.bg_color = Color(0.4, 0.1, 0.1)
	sell_btn.add_theme_stylebox_override("pressed", sb_p)

	sell_btn.pressed.connect(_on_sell_pressed)
	vbox.add_child(sell_btn)

func _build_path_section(parent: VBoxContainer, path_idx: int) -> Dictionary:
	var path_vbox = VBoxContainer.new()
	path_vbox.add_theme_constant_override("separation", 2)
	parent.add_child(path_vbox)

	# Header row: label on left, pip dashes on right
	var header_hbox = HBoxContainer.new()
	header_hbox.add_theme_constant_override("separation", 4)
	path_vbox.add_child(header_hbox)

	var path_label = Label.new()
	path_label.text = "Path %d" % (path_idx + 1)
	path_label.add_theme_font_size_override("font_size", 12)
	path_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(path_label)

	# Three pip dashes
	var pips: Array = []
	for _i in 3:
		var pip = Panel.new()
		pip.custom_minimum_size = Vector2(14, 6)
		var pip_style = StyleBoxFlat.new()
		pip_style.bg_color = Color(0.3, 0.3, 0.3, 1)
		pip_style.set_corner_radius_all(2)
		pip.add_theme_stylebox_override("panel", pip_style)
		header_hbox.add_child(pip)
		pips.append(pip)

	var btns: Array = []
	for tier in 3:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 34)
		btn.text = "..."
		btn.add_theme_font_size_override("font_size", 11)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.clip_text = true
		btn.mouse_entered.connect(_on_btn_hover_enter.bind(path_idx, tier, btn))
		btn.mouse_exited.connect(_on_btn_hover_exit)
		btn.pressed.connect(_on_upgrade_pressed.bind(path_idx, tier, btn))
		path_vbox.add_child(btn)
		btns.append(btn)

	return {"label": path_label, "btns": btns, "pips": pips}

func _update_pips(section: Dictionary, tier_bought: int) -> void:
	var pips: Array = section["pips"]
	for i in pips.size():
		var pip: Panel = pips[i]
		var pip_style = StyleBoxFlat.new()
		pip_style.set_corner_radius_all(2)
		if i < tier_bought:
			pip_style.bg_color = Color(0.2, 0.75, 0.2, 1)
		else:
			pip_style.bg_color = Color(0.3, 0.3, 0.3, 1)
		pip.add_theme_stylebox_override("panel", pip_style)

func _on_btn_hover_enter(path_idx: int, tier: int, btn: Button) -> void:
	if current_tower == null:
		return
	if tier != current_tower.path[path_idx]:
		return
	var data = current_tower.get_upgrade_data()
	var upgrade_info = data[path_idx][tier]
	var desc: String = upgrade_info.get("desc", "")
	if desc == "":
		tooltip_panel.visible = false
		return

	const TOOLTIP_W = 200
	const PADDING    = 6

	tooltip_label.text = desc
	tooltip_label.custom_minimum_size = Vector2(TOOLTIP_W - PADDING * 2, 0)
	tooltip_label.size = Vector2(TOOLTIP_W - PADDING * 2, 0)

	tooltip_panel.visible = true
	tooltip_panel.size = Vector2(TOOLTIP_W, 60)
	tooltip_label.position = Vector2(PADDING, PADDING)
	tooltip_label.size = Vector2(TOOLTIP_W - PADDING * 2, 0)

	_position_tooltip_deferred.call_deferred(btn, TOOLTIP_W, PADDING)

func _position_tooltip_deferred(btn: Button, tooltip_w: int, padding: int) -> void:
	if not tooltip_panel.visible:
		return

	var label_h = tooltip_label.get_minimum_size().y
	var panel_h = label_h + padding * 2
	tooltip_panel.size = Vector2(tooltip_w, panel_h)
	tooltip_label.size = Vector2(tooltip_w - padding * 2, label_h)

	var btn_global   = btn.get_global_rect()
	var panel_global = panel.get_global_rect()

	var tx = panel_global.position.x - tooltip_w - 8
	var ty = btn_global.position.y + (btn_global.size.y / 2.0) - (panel_h / 2.0)

	var vp_h = get_viewport().get_visible_rect().size.y
	ty = clamp(ty, 4, vp_h - panel_h - 4)

	tooltip_panel.position = Vector2(tx, ty)

func _on_btn_hover_exit() -> void:
	tooltip_panel.visible = false

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
	tooltip_panel.visible = false
	hide()

func _refresh() -> void:
	if current_tower == null:
		return
	# Prefer the explicit display_name export; fall back to node name with trailing digits stripped.
	var raw: String = current_tower.display_name if current_tower.display_name != "" \
		else current_tower.name.rstrip("0123456789").replace("_", " ").strip_edges()
	name_label.text = raw.to_upper()
	var data = current_tower.get_upgrade_data()

	for p in 3:
		var tier_bought = current_tower.path[p]
		var section = path_sections[p]
		var path_data = data[p]

		_update_pips(section, tier_bought)

		var any_tier3 = current_tower.path.any(func(t): return t >= 3)

		for t in 3:
			var btn: Button = section["btns"][t]
			if t >= path_data.size():
				btn.visible = false
				continue
			var upgrade_info = path_data[t]

			if t < tier_bought:
				btn.visible = false
			elif t == tier_bought:
				btn.visible = true
				# Block tier 3 if another path already has tier 3
				if t == 2 and any_tier3 and current_tower.path[p] < 3:
					btn.disabled = true
					btn.text = "[LOCKED] %s - $%d" % [upgrade_info["name"], upgrade_info["cost"]]
				else:
					btn.disabled = false
					btn.text = "%s - $%d" % [upgrade_info["name"], upgrade_info["cost"]]
			else:
				btn.visible = false

	if current_tower and current_tower.get("total_cost") != null:
		var sell_val = int(current_tower.total_cost * 0.75)
		sell_btn.text = "Sell ($%d)" % sell_val

func _on_sell_pressed() -> void:
	if current_tower == null:
		return
	var sell_val = int(current_tower.total_cost * 0.75)
	var shop_nodes = get_tree().get_nodes_in_group("shop_ui")
	if not shop_nodes.is_empty():
		shop_nodes[0].add_money(sell_val)
	current_tower.queue_free()
	current_tower = null
	hide()

func _on_upgrade_pressed(path_idx: int, tier: int, btn: Button) -> void:
	if current_tower == null:
		return
	if tier != current_tower.path[path_idx]:
		return
	var success = current_tower.try_upgrade(path_idx)
	if success:
		tooltip_panel.visible = false
		_refresh()
	else:
		_flash_insufficient(btn)

func _flash_insufficient(btn: Button) -> void:
	if flash_tween and flash_tween.is_running():
		flash_tween.kill()
	flash_tween = create_tween()
	flash_tween.tween_property(btn, "modulate", Color(1, 0.2, 0.2, 1), 0.05)
	flash_tween.tween_property(btn, "modulate", Color.WHITE, 0.3)
