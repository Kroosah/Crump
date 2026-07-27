extends RefCounted
## Smoke-test-suite van CRUMP (D-013: eigen minimale runner, geen plugin).
## Draait binnen het echte spel: `godot --headless --path . -- --smoke-test`
## De bootstrap roept run() aan en sluit af met exitcode 0 (groen) of 1.
## Elke test logt zijn resultaat; falen is nooit stil.


static func run(bootstrap: Node) -> int:
	var failures := 0
	var tree := bootstrap.get_tree()

	# 1. Autoloads aanwezig
	for autoload_name in ["EventBus", "GameState", "AudioDirector",
			"SettingsManager", "SaveManager"]:
		failures = _check(tree.root.get_node_or_null(autoload_name) != null,
			"autoload %s aanwezig" % autoload_name, failures)

	# 2. EventBus-contract: signalen bestaan met het juiste aantal argumenten
	var expected_signals := {
		"noise_made": 2, "chapter_started": 1, "player_spotted": 1,
		"item_used": 1, "interact_prompt_changed": 1,
	}
	for signal_name in expected_signals:
		var ok := EventBus.has_signal(signal_name)
		if ok:
			for info in EventBus.get_signal_list():
				if info["name"] == signal_name:
					ok = info["args"].size() == expected_signals[signal_name]
					break
		failures = _check(ok, "EventBus.%s bestaat met %d argument(en)"
			% [signal_name, expected_signals[signal_name]], failures)

	# 3. Audiobussen + volume-round-trip
	failures = _check(AudioDirector.has_expected_buses(),
		"alle audiobussen aanwezig", failures)
	AudioDirector.set_bus_volume_linear(&"SFX", 0.5)
	failures = _check(
		absf(AudioDirector.get_bus_volume_linear(&"SFX") - 0.5) < 0.01,
		"busvolume zetten/lezen (SFX 0.5)", failures)
	AudioDirector.set_bus_volume_linear(&"SFX",
		SettingsManager.audio_volumes.get(&"SFX", 1.0))

	# 4. Settings-round-trip via schijf
	var original_sensitivity: float = SettingsManager.mouse_sensitivity
	SettingsManager.mouse_sensitivity = 1.7
	failures = _check(SettingsManager.save_settings(),
		"settings opslaan", failures)
	var config := ConfigFile.new()
	var loaded_ok := config.load(SettingsManager.SETTINGS_PATH) == OK
	failures = _check(loaded_ok
		and absf(float(config.get_value("input", "mouse_sensitivity", 0.0)) - 1.7) < 0.001,
		"settings-round-trip via settings.cfg", failures)
	SettingsManager.mouse_sensitivity = original_sensitivity
	SettingsManager.save_settings()

	# 5. GameState + SaveManager round-trip (slot 99 = testslot)
	GameState.reset()
	GameState.start_chapter(1)
	GameState.set_flag(&"smoke_test", true)
	GameState.mark_document_read(&"test_document")
	failures = _check(SaveManager.save_game(99), "save schrijven", failures)
	GameState.reset()
	failures = _check(SaveManager.load_game(99), "save laden", failures)
	failures = _check(
		GameState.chapter == 1
		and GameState.get_flag(&"smoke_test")
		and &"test_document" in GameState.documents_read,
		"save-round-trip behoudt staat", failures)
	SaveManager.delete_save(99)
	GameState.reset()

	# 6. Log schrijft naar schijf
	failures = _check(FileAccess.file_exists(Log.get_current_log_path()),
		"logbestand bestaat (%s)" % Log.get_current_log_path(), failures)

	# 7. Dev room is geladen
	failures = _check(bootstrap.get_current_level_name() == "DevRoom",
		"developer room geladen", failures)

	# 8. Input-map compleet
	for action in ["move_forward", "move_back", "move_left", "move_right",
			"sneak", "run", "crouch", "interact", "flashlight", "pause",
			"debug_overlay"]:
		failures = _check(InputMap.has_action(action),
			"input-actie '%s' bestaat" % action, failures)

	# 9. Physics-layers benoemd
	failures = _check(
		str(ProjectSettings.get_setting("layer_names/3d_physics/layer_1", "")) == "world"
		and str(ProjectSettings.get_setting("layer_names/3d_physics/layer_4", "")) == "interactable",
		"physics-layers dragen de afgesproken namen", failures)

	# 10. Zichtbaarheid van de dev room (KI-001: geen camera = egaal grijs beeld)
	failures = _check_dev_room_visible(tree, failures)

	return failures


## Controleert dat de developer room daadwerkelijk iets op het scherm zet.
## Headless kunnen we niet kíjken, dus toetsen we de voorwaarden die samen
## bepalen of er beeld is: een actieve camera, vrij zicht, licht en materialen.
static func _check_dev_room_visible(tree: SceneTree, failures: int) -> int:
	var level: Node = tree.root.find_child("DevRoom", true, false)
	failures = _check(level != null, "dev room in de scèneboom gevonden", failures)
	if level == null:
		return failures

	# Camera: precies één, en die is ook echt de actieve camera van de viewport.
	var all_cameras := tree.root.find_children("", "Camera3D", true, false)
	failures = _check(all_cameras.size() == 1,
		"exact één Camera3D in de hele scèneboom (gevonden: %d)"
		% all_cameras.size(), failures)
	var active := tree.root.get_camera_3d()
	failures = _check(active != null, "viewport heeft een actieve Camera3D",
		failures)
	if active == null:
		return failures
	failures = _check(active.is_inside_tree() and level.is_ancestor_of(active),
		"de actieve camera hoort bij de dev room", failures)

	# Clipping: near klein genoeg om vlak vóór de camera nog te tonen, far ruim
	# genoeg voor de achterwand op ~19 m.
	failures = _check(active.near > 0.0 and active.near <= 0.1,
		"camera-near bruikbaar (%.3f)" % active.near, failures)
	failures = _check(active.far >= 50.0,
		"camera-far reikt tot voorbij de ruimte (%.1f)" % active.far, failures)

	# Positie: binnen de kamer, boven de vloer, en niet ín geometrie.
	var cam_pos := active.global_position
	failures = _check(
		absf(cam_pos.x) < 9.7 and absf(cam_pos.z) < 9.7 and cam_pos.y > 0.2,
		"camera staat binnen de kamer en boven de vloer (%s)"
		% str(cam_pos.round()), failures)

	var meshes := level.find_children("", "MeshInstance3D", true, false)
	var inside_geometry := ""
	var visible_in_front := 0
	var albedos := {}
	for node in meshes:
		var mesh_instance := node as MeshInstance3D
		var box: AABB = mesh_instance.global_transform * mesh_instance.get_aabb()
		if box.has_point(cam_pos):
			inside_geometry = str(mesh_instance.get_path())
		var to_object := box.get_center() - cam_pos
		if mesh_instance.is_visible_in_tree() and (-active.global_basis.z).dot(
				to_object.normalized()) > 0.0:
			visible_in_front += 1
		var material := mesh_instance.get_surface_override_material(0)
		if material is StandardMaterial3D:
			albedos[material.albedo_color] = true
	failures = _check(inside_geometry.is_empty(),
		"camera staat niet in geometrie (%s)"
		% ("vrij" if inside_geometry.is_empty() else inside_geometry), failures)
	failures = _check(visible_in_front >= 5,
		"camera kijkt naar de testobjecten (%d in beeldrichting)"
		% visible_in_front, failures)
	failures = _check(albedos.size() >= 5,
		"testobjecten hebben contrasterende materialen (%d kleuren)"
		% albedos.size(), failures)
	failures = _check(meshes.size() >= 10,
		"dev room bevat vloer, muren en meerdere objecten (%d meshes)"
		% meshes.size(), failures)

	# Kijkrichting: de camera moet het midden van de ruimte in beeld hebben.
	var to_center := (Vector3(0.0, 1.0, 0.0) - cam_pos).normalized()
	failures = _check((-active.global_basis.z).dot(to_center) > 0.9,
		"camera is op het midden van de ruimte gericht", failures)

	# Licht: minstens twee bronnen die daadwerkelijk energie geven.
	var lit := 0
	for node in level.find_children("", "Light3D", true, false):
		var light := node as Light3D
		if light.is_visible_in_tree() and light.light_energy > 0.0:
			lit += 1
	failures = _check(lit >= 2,
		"tijdelijke verlichting is aan (%d actieve lichten)" % lit, failures)

	# Environment: geen egaal grijs, en ambient als vangnet als licht wegvalt.
	var world_env: WorldEnvironment = level.find_child("WorldEnvironment",
		true, false)
	failures = _check(world_env != null and world_env.environment != null,
		"dev room heeft een WorldEnvironment met environment", failures)
	if world_env == null or world_env.environment == null:
		return failures
	var env := world_env.environment
	failures = _check(env.background_mode == Environment.BG_COLOR,
		"achtergrond staat op een expliciete kleur", failures)
	var clear_color: Color = ProjectSettings.get_setting(
		"rendering/environment/defaults/default_clear_color", Color(0.3, 0.3, 0.3))
	# Zou de achtergrond op het default-grijs lijken, dan is een echt kapot
	# beeld niet meer te onderscheiden van een werkende render.
	var color_gap := (
		absf(env.background_color.r - clear_color.r)
		+ absf(env.background_color.g - clear_color.g)
		+ absf(env.background_color.b - clear_color.b))
	failures = _check(color_gap > 0.15,
		"achtergrondkleur wijkt af van de default clear color (%.2f)"
		% color_gap, failures)
	failures = _check(
		env.ambient_light_source == Environment.AMBIENT_SOURCE_COLOR
		and env.ambient_light_energy > 0.0,
		"ambient licht staat aan (%.2f)" % env.ambient_light_energy, failures)

	return failures


static func _check(condition: bool, description: String, failures: int) -> int:
	if condition:
		Log.info("TEST OK   · %s" % description)
		return failures
	Log.error("TEST FOUT · %s" % description)
	return failures + 1
