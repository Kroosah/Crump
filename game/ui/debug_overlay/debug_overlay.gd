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
		"actieve geluiden: —",  # haak: vult in taak 005
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
