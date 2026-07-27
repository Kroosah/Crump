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

	return failures


static func _check(condition: bool, description: String, failures: int) -> int:
	if condition:
		Log.info("TEST OK   · %s" % description)
		return failures
	Log.error("TEST FOUT · %s" % description)
	return failures + 1
