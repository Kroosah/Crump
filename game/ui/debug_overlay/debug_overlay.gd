extends CanvasLayer
## Debug overlay — F3 toggle't ontwikkelinformatie (fps, frametijd, scène).
## Wordt uitsluitend in debugbuilds geïnstantieerd (door de bootstrap); in
## release-builds bestaat deze scène niet eens in het draaiende spel.

@onready var _label: Label = %InfoLabel


func _ready() -> void:
	visible = false
	# Ook bruikbaar terwijl het spel gepauzeerd is.
	process_mode = Node.PROCESS_MODE_ALWAYS


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_overlay"):
		visible = not visible


func _process(_delta: float) -> void:
	if not visible:
		return
	_label.text = _build_info()


func _build_info() -> String:
	var fps := Engine.get_frames_per_second()
	var frame_ms := Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	var lines: Array[String] = [
		"CRUMP %s · Godot %s" % [
			str(ProjectSettings.get_setting("application/config/version", "?")),
			Engine.get_version_info().string,
		],
		"fps: %d · frametijd: %.2f ms" % [fps, frame_ms],
		"level: %s" % _current_level_name(),
		"speler: %s" % _player_position_text(),
		"inventory: %s" % _inventory_text(),
		"actieve geluiden: %s" % _audio_text(),
		"zaklamp: %s" % _flashlight_text(),
		"licht: %s" % _light_text(),
	]
	return "\n".join(lines)


func _current_level_name() -> String:
	var bootstrap := get_node_or_null("/root/Bootstrap")
	if bootstrap != null and bootstrap.has_method("get_current_level_name"):
		return bootstrap.get_current_level_name()
	return "?"


func _player_position_text() -> String:
	# Haak voor taak 002: de speler meldt zich straks in de groep "player".
	var player := get_tree().get_first_node_in_group("player")
	if player is Node3D:
		var pos: Vector3 = player.global_position
		return "(%.1f, %.1f, %.1f)" % [pos.x, pos.y, pos.z]
	return "—"


func _inventory_text() -> String:
	# Haak taak 004: null-veilig via de groep (ARCHITECTURE §4a.4), zonder
	# de inventory-klasse te noemen — de overlay overleeft elke verwijdering.
	var inventory := get_tree().get_first_node_in_group("inventory")
	if inventory == null or not inventory.has_method("get_items"):
		return "—"
	var items: Array = inventory.get_items()
	var text := "%d/%d" % [items.size(), inventory.capacity]
	if items.is_empty():
		return text
	var ids := PackedStringArray()
	for item in items:
		ids.append(String(item.id))
	return "%s · %s" % [text, ", ".join(ids)]


func _flashlight_text() -> String:
	# Haak taak 006: null-veilig via de groep, duck-typed — zelfde patroon
	# als de inventory- en audioregel; de overlay overleeft elke verwijdering.
	var flashlight := get_tree().get_first_node_in_group("flashlight")
	if flashlight == null or not flashlight.has_method("has_flashlight") \
			or not flashlight.has_method("is_light_on"):
		return "—"
	return "bezit %s · %s" % [
		"ja" if flashlight.has_flashlight() else "nee",
		"aan" if flashlight.is_light_on() else "uit"]


func _light_text() -> String:
	# Schaduwtelling via de budget-bewaking (groep), brightness rechtstreeks
	# uit het autoload (infrastructuur, mag altijd), TL-telling via de groep.
	var parts := PackedStringArray()
	var budget := get_tree().get_first_node_in_group("light_budget")
	if budget != null and budget.has_method("get_active_shadow_count"):
		parts.append("%d/%d schaduw" % [
			budget.get_active_shadow_count(), budget.get_shadow_budget()])
	parts.append("helderheid %.1f" % SettingsManager.brightness)
	var stable := 0
	var flickering := 0
	var broken := 0
	var tl_found := false
	for tl in get_tree().get_nodes_in_group("light_tl"):
		if not tl.has_method("get_tl_state"):
			continue
		tl_found = true
		match tl.get_tl_state():
			0: stable += 1
			1: broken += 1
			2: flickering += 1
	if tl_found:
		parts.append("tl: %d stabiel / %d flikkert / %d defect"
			% [stable, flickering, broken])
	return " · ".join(parts)


func _audio_text() -> String:
	# Haak taak 005: null-veilig via de groep, duck-typed — de overlay
	# overleeft elke verwijdering (zelfde patroon als de inventory-regel).
	var audio := get_tree().get_first_node_in_group("audio_system")
	if audio == null or not audio.has_method("get_active_one_shots"):
		return "—"
	var text: String = audio.get_pool_status()
	var ids: Array = audio.get_active_one_shots()
	if not ids.is_empty():
		var names := PackedStringArray()
		for id in ids:
			names.append(String(id))
		text += " · " + ", ".join(names)
	var layers: Array = audio.get_active_ambience()
	if not layers.is_empty():
		var layer_names := PackedStringArray()
		for layer in layers:
			layer_names.append(String(layer))
		text += " | amb: " + ", ".join(layer_names)
	return text
