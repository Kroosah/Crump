extends RefCounted
## Smoke-test-suite van CRUMP (D-013: eigen minimale runner, geen plugin).
## Draait binnen het echte spel: `godot --headless --path . -- --smoke-test`
## De bootstrap roept run() aan (met await: de spelertests laten physics
## draaien) en sluit af met exitcode 0 (groen) of 1.
## Elke test logt zijn resultaat; falen is nooit stil.

## De spelerscène; bestaat hij niet (verwijderbaarheidstest D-015), dan worden
## de spelertests overgeslagen en moet de rest gewoon groen blijven.
const PLAYER_SCENE := "res://game/actors/player/player.tscn"

## Het interactiesysteem (taak 003); zelfde D-015-afspraak. De verwijdereenheid
## is contract + interactor + props sámen (props overerven het contract).
const INTERACTOR_SCENE := "res://game/systems/interaction/interactor.tscn"


func run(bootstrap: Node) -> int:
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
		"item_used": 1, "interact_prompt_changed": 1, "document_opened": 2,
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

	# 11. Bewuste projectinstellingen die tóevallig gelijk zijn aan de
	# engine-default. Godot schrijft zulke waarden niet weg in project.godot
	# (D-017), dus dit is de enige plek waar de keuze nog hard vastligt —
	# verandert een toekomstige Godot-versie zijn default, dan valt het hier om.
	var expected_settings := {
		"rendering/renderer/rendering_method": "forward_plus",
		"physics/common/physics_ticks_per_second": 60,
		"display/window/size/mode": Window.MODE_WINDOWED,
	}
	for key in expected_settings:
		var actual: Variant = ProjectSettings.get_setting(key)
		failures = _check(actual == expected_settings[key],
			"projectinstelling %s staat op %s (gevonden: %s)"
			% [key, str(expected_settings[key]), str(actual)], failures)

	# 12. Pauze-architectuur (KI-003): de bootstrap moet tijdens de pauze
	# blijven luisteren (ALWAYS), maar de spelwereld onder de SceneHost moet
	# wél echt stilstaan. ALWAYS op de bootstrap erft door naar kinderen,
	# dus PAUSABLE op de SceneHost is verplicht — anders doet Esc "niets".
	failures = _check(bootstrap.process_mode == Node.PROCESS_MODE_ALWAYS,
		"bootstrap draait door tijdens pauze (ALWAYS)", failures)
	var scene_host: Node = bootstrap.get_node_or_null("SceneHost")
	failures = _check(
		scene_host != null
		and scene_host.process_mode == Node.PROCESS_MODE_PAUSABLE,
		"spelwereld (SceneHost) pauzeert mee (PAUSABLE)", failures)

	# 13. Speler (taak 002) — alleen als de spelerscène bestaat: na het
	# weggooien van game/actors/player/ (verwijderbaarheidstest D-015) moet
	# de rest van de suite gewoon groen blijven.
	if ResourceLoader.exists(PLAYER_SCENE):
		failures = await _check_player(tree, failures)
	else:
		Log.info("TEST INFO · spelerscène ontbreekt — spelertests overgeslagen (D-015)")

	# 14. Interactiesysteem (taak 003) — zelfde D-015-afspraak als de speler:
	# ontbreekt het systeem (contract + interactor + props), dan blijft de
	# rest van de suite groen.
	if ResourceLoader.exists(INTERACTOR_SCENE):
		failures = await _check_interaction(tree, failures)
	else:
		Log.info("TEST INFO · interactiesysteem ontbreekt — interactietests overgeslagen (D-015)")

	return failures


## Controleert dat de developer room daadwerkelijk iets op het scherm zet.
## Headless kunnen we niet kíjken, dus toetsen we de voorwaarden die samen
## bepalen of er beeld is: een actieve camera, vrij zicht, licht en materialen.
func _check_dev_room_visible(tree: SceneTree, failures: int) -> int:
	var level: Node = tree.root.find_child("DevRoom", true, false)
	failures = _check(level != null, "dev room in de scèneboom gevonden", failures)
	if level == null:
		return failures

	# Camera's: de testcamera van de dev room, plus de spelerscamera als de
	# speler bestaat (taak 002). De actieve camera hoort in beide gevallen bij
	# het level (de speler wordt als kind van het level gespawnd).
	var player: Node = tree.get_first_node_in_group("player")
	var expected_cameras := 2 if player != null else 1
	var all_cameras := tree.root.find_children("", "Camera3D", true, false)
	failures = _check(all_cameras.size() == expected_cameras,
		"exact %d Camera3D('s) in de hele scèneboom (gevonden: %d)"
		% [expected_cameras, all_cameras.size()], failures)
	var active := tree.root.get_camera_3d()
	failures = _check(active != null, "viewport heeft een actieve Camera3D",
		failures)
	if active == null:
		return failures
	failures = _check(active.is_inside_tree() and level.is_ancestor_of(active),
		"de actieve camera hoort bij de dev room", failures)
	if player != null:
		# Met een speler moet díéns camera het beeld hebben — de testcamera
		# is een ontwikkelhulpmiddel en wint nooit van gameplay (D-016).
		failures = _check(player.is_ancestor_of(active),
			"de spelerscamera levert het beeld (D-016)", failures)

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
	# Drempel 0.99 (~8 graden): de oude 0.9 liet de 9-graden-transponeerfout
	# van KI-002/v0.0.8 nog door. Geldt ook voor de spelerscamera: het
	# spawnpunt kijkt de kamer in, dus een scheve start valt hier om.
	var to_center := (Vector3(0.0, 1.0, 0.0) - cam_pos).normalized()
	failures = _check((-active.global_basis.z).dot(to_center) > 0.99,
		"camera is op het midden van de ruimte gericht", failures)

	# Licht: minstens twee bronnen die daadwerkelijk energie geven, en géén
	# DirectionalLight die omhoog schijnt (KI-002: getransponeerde basis).
	var lit := 0
	for node in level.find_children("", "Light3D", true, false):
		var light := node as Light3D
		if light.is_visible_in_tree() and light.light_energy > 0.0:
			lit += 1
		if light is DirectionalLight3D:
			var light_dir := -light.global_basis.z
			failures = _check(light_dir.y < -0.2,
				"DirectionalLight '%s' schijnt omlaag (y-richting %.2f)"
				% [light.name, light_dir.y], failures)
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


## Spelertests (taak 002): losstaand laden, op de vloer landen, en echte
## input-simulatie per gangmodus — de voetstap moet als noise_made-feit met
## de juiste luidheid op de EventBus verschijnen.
func _check_player(tree: SceneTree, failures: int) -> int:
	# Losstaand instantieerbaar (CODING_STANDARDS §4.1): de scène laadt en
	# bouwt zonder level eromheen.
	var packed: PackedScene = load(PLAYER_SCENE)
	var standalone := packed.instantiate() if packed != null else null
	failures = _check(standalone is CharacterBody3D,
		"spelerscène instantieert los als CharacterBody3D", failures)
	if standalone != null:
		standalone.free()

	# De gespawnde speler (bootstrap → PlayerSpawn) staat in de groep 'player'.
	# Bewust ongetypt: het type 'Player' hier benoemen zou een harde
	# klasse-verwijzing zijn die de verwijderbaarheidstest (D-015) breekt.
	var player = tree.get_first_node_in_group("player")
	failures = _check(player != null,
		"gespawnde speler gevonden in groep 'player'", failures)
	if player == null:
		return failures

	# Physics settelen: na een halve seconde staat hij op de vloer, niet
	# erdoorheen gezakt en nog binnen de kamer.
	await _wait_physics_frames(tree, 30)
	failures = _check(player.is_on_floor(),
		"speler staat op de vloer", failures)
	failures = _check(
		player.global_position.y > -0.5 and player.global_position.y < 1.0
		and absf(player.global_position.x) < 10.0
		and absf(player.global_position.z) < 10.0,
		"speler is niet door vloer of muur gevallen (%s)"
		% str(player.global_position.round()), failures)

	# Per gangmodus: beweegt hij, en klinkt de stap met de juiste luidheid?
	# Luidheid schaalt met de modus — dat contract is de koppeling naar
	# CRUMP's gehoor (taak 007) en mag dus nooit stil kapotgaan.
	var gaits := [
		["lopen", ["move_forward"], player.loudness_walk],
		["sluipen", ["move_forward", "sneak"], player.loudness_sneak],
		["rennen", ["move_forward", "run"], player.loudness_run],
		["bukken", ["move_forward", "crouch"], player.loudness_crouch],
	]
	for gait in gaits:
		var start_pos: Vector3 = player.global_position
		var events: Array = await _move_and_listen(tree, gait[1], 120)
		var moved: bool = player.global_position.distance_to(start_pos) > 0.3
		failures = _check(moved,
			"speler verplaatst zich bij %s" % gait[0], failures)
		failures = _check(events.size() >= 1,
			"%s geeft een voetstap-event op de EventBus" % gait[0], failures)
		if events.size() >= 1:
			failures = _check(absf(events[0][1] - gait[2]) < 0.01,
				"%s klinkt met luidheid %.1f (gemeten: %.1f)"
				% [gait[0], gait[2], events[0][1]], failures)
			failures = _check(
				events[0][0].distance_to(player.global_position) < 2.0,
				"voetstap-positie ligt bij de speler", failures)

	# Bukken verlaagt de camera (alleen de ooghoogte; collider blijft, TD-004).
	var head: Node3D = player.get_node("Head")
	Input.action_press("crouch")
	await _wait_physics_frames(tree, 30)
	var crouched_ok: bool = head.position.y < player.stand_eye_height - 0.2
	Input.action_release("crouch")
	failures = _check(crouched_ok,
		"bukken verlaagt de ooghoogte (%.2f m)" % head.position.y, failures)
	await _wait_physics_frames(tree, 30)
	failures = _check(
		absf(head.position.y - player.stand_eye_height) < 0.05,
		"ooghoogte herstelt na het bukken (%.2f m)" % head.position.y, failures)

	# Pauze-round-trip (KI-003): Esc zet de wereld écht stil en hervat weer.
	failures = await _check_pause(tree, player, failures)

	return failures


## Toetst de volledige Esc-cyclus: pauzeren stopt de speler (en geeft de
## muis vrij), nogmaals Esc hervat (en vangt de muis weer). De muis-checks
## kunnen alleen met een echt scherm — headless meldt altijd VISIBLE.
func _check_pause(tree: SceneTree, player, failures: int) -> int:
	var has_display: bool = DisplayServer.get_name() != "headless"

	_send_action_event(&"pause")
	await _wait_physics_frames(tree, 5)
	failures = _check(tree.paused, "Esc pauzeert de scene-tree", failures)
	if has_display:
		failures = _check(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE,
			"muis komt vrij tijdens de pauze", failures)
	else:
		Log.info("TEST INFO · muis-checks overgeslagen (headless heeft geen muismodus)")

	# De wereld staat stil: bewegen tijdens de pauze doet niets.
	var start_pos: Vector3 = player.global_position
	Input.action_press("move_forward")
	await _wait_physics_frames(tree, 30)
	Input.action_release("move_forward")
	failures = _check(player.global_position.distance_to(start_pos) < 0.05,
		"speler staat stil tijdens de pauze", failures)

	_send_action_event(&"pause")
	await _wait_physics_frames(tree, 5)
	failures = _check(not tree.paused, "Esc hervat het spel", failures)
	if has_display:
		failures = _check(Input.mouse_mode == Input.MOUSE_MODE_CAPTURED,
			"muis wordt weer gevangen bij hervatten", failures)

	# En de wereld draait weer.
	start_pos = player.global_position
	Input.action_press("move_forward")
	await _wait_physics_frames(tree, 30)
	Input.action_release("move_forward")
	failures = _check(player.global_position.distance_to(start_pos) > 0.1,
		"speler beweegt weer na hervatten", failures)
	await _wait_physics_frames(tree, 35)
	return failures


## Interactietests (taak 003): het volledige contract door de échte keten —
## speler kijkt, prompt verschijnt op de EventBus (letterlijk prompt_text()),
## interact-toets voert de eigen interactie van het object uit, wegkijken
## wist de prompt, en niet-interactables zwijgen. Nergens een proptype: de
## tests vergelijken uitsluitend met de export-data van de props zelf.
func _check_interaction(tree: SceneTree, failures: int) -> int:
	# Interactor-scène laadt en instantieert los.
	var packed: PackedScene = load(INTERACTOR_SCENE)
	var standalone := packed.instantiate() if packed != null else null
	failures = _check(standalone != null,
		"interactor-scène instantieert los", failures)
	if standalone != null:
		standalone.free()

	# De bootstrap heeft de interactor in het level gezet.
	var interactor := tree.root.find_child("Interactor", true, false)
	failures = _check(interactor != null,
		"interactor is door de bootstrap gespawnd", failures)
	if interactor == null:
		return failures

	# Elke prop-scène instantieert los en voldoet aan het contract. Bewust
	# GEEN overslaan bij een ontbrekende prop: de verwijdereenheid is het
	# hele systeem (contract + interactor + props). Bestaat de interactor
	# wél maar een prop niet, dan is dat een halve verwijdering — een
	# kapotte toestand die hier luid hoort te falen.
	for prop_path in [
			"res://game/props/door_wooden/door_wooden.tscn",
			"res://game/props/drawer_cabinet/drawer_cabinet.tscn",
			"res://game/props/pickup_item/pickup_item.tscn",
			"res://game/props/note_readable/note_readable.tscn"]:
		var prop_scene: PackedScene = null
		if ResourceLoader.exists(prop_path):
			prop_scene = load(prop_path)
		var prop := prop_scene.instantiate() if prop_scene != null else null
		# Bewust duck-typed en níét `prop is Interactable`: een global class
		# benoemen is een parse-time-afhankelijkheid — dan parst deze suite
		# zelf niet meer zodra het interactiesysteem verwijderd is (D-015).
		var honours_contract: bool = prop != null \
			and prop.has_method("can_interact") \
			and prop.has_method("interact") \
			and prop.has_method("prompt_text")
		failures = _check(honours_contract,
			"prop voldoet los aan het Interactable-contract (%s)"
			% prop_path.get_file(), failures)
		if prop != null:
			prop.free()

	# Voor de functionele keten is de speler nodig (die richt de camera).
	var player = tree.get_first_node_in_group("player")
	var props_root: Node = tree.root.find_child("TestProps", true, false)
	if player == null or props_root == null:
		Log.info("TEST INFO · geen speler of testprops — functionele interactietests overgeslagen")
		return failures

	# Prompt-recorder: onthoudt de laatst uitgezonden prompttekst.
	var prompt_log: Array = [""]
	var prompt_recorder := func(text: String) -> void:
		prompt_log[0] = text
	EventBus.interact_prompt_changed.connect(prompt_recorder)

	failures = await _check_door(tree, player, props_root, prompt_log, failures)
	failures = await _check_locked_door(tree, player, props_root, prompt_log, failures)
	failures = await _check_drawer(tree, player, props_root, prompt_log, failures)
	failures = await _check_pickup(tree, player, props_root, prompt_log, failures)
	failures = await _check_note(tree, player, props_root, prompt_log, failures)

	# Niet-interactable: een kale wereldkist geeft geen prompt.
	await _aim(tree, player, Vector3(-4.0, 0.05, 4.8), 0.0, -0.61)
	failures = _check(prompt_log[0] == "",
		"niet-interactable object geeft geen prompt", failures)

	# Wegkijken de lege ruimte in: prompt blijft/wordt leeg.
	await _aim(tree, player, Vector3(0.8, 0.05, -8.2), PI, 0.0)
	failures = _check(prompt_log[0] == "",
		"prompt is leeg bij wegkijken", failures)

	# Debug-prompt (alleen debugbuilds, TD-006): toont letterlijk de
	# bus-tekst met de actuele interact-toets uit de InputMap ervoor.
	if ResourceLoader.exists("res://game/ui/debug_prompt/debug_prompt.tscn"):
		failures = await _check_debug_prompt(tree, player, props_root, failures)

	EventBus.interact_prompt_changed.disconnect(prompt_recorder)
	return failures


func _check_debug_prompt(tree: SceneTree, player, props_root: Node,
		failures: int) -> int:
	var prompt_node := tree.root.find_child("DebugPrompt", true, false)
	failures = _check(prompt_node != null,
		"debug-prompt is gespawnd (debugbuild)", failures)
	var door: Node = props_root.get_node_or_null("TestDoor")
	if prompt_node == null or door == null:
		return failures
	var label: Label = prompt_node.find_child("PromptLabel", true, false)

	var key_name := ""
	for event in InputMap.action_get_events("interact"):
		if event is InputEventKey:
			key_name = event.as_text_physical_keycode()
			break

	await _aim(tree, player, Vector3(-3.5, 0.05, -2.3), 0.0, 0.0)
	failures = _check(label != null
		and label.text == "[%s] %s" % [key_name, door.prompt_open],
		"debug-prompt toont '[toets] prompt' uit de InputMap ('%s')"
		% (label.text if label != null else "-"), failures)

	await _aim(tree, player, Vector3(0.8, 0.05, -8.2), PI, 0.0)
	failures = _check(label != null and label.text == "",
		"debug-prompt leegt bij wegkijken", failures)
	return failures


func _check_door(tree: SceneTree, player, props_root: Node,
		prompt_log: Array, failures: int) -> int:
	var door: Node = props_root.get_node_or_null("TestDoor")
	failures = _check(door != null, "testdeur staat in de dev room", failures)
	if door == null:
		return failures

	# Aankijken: prompt is letterlijk de eigen tekst van de deur.
	await _aim(tree, player, Vector3(-3.5, 0.05, -2.3), 0.0, 0.0)
	failures = _check(prompt_log[0] == door.prompt_open,
		"deur toont zijn eigen open-prompt ('%s')" % prompt_log[0], failures)

	# Interact: de deur voert zijn eigen interactie uit — hoorbaar.
	var noises: Array = await _interact_and_listen(tree)
	failures = _check(noises.size() == 1
		and absf(noises[0][1] - door.loudness_toggle) < 0.01,
		"deur opent hoorbaar met eigen luidheid", failures)

	# De open deur staat nu haaks; vanaf de zijkant toont hij de sluit-prompt.
	await _aim(tree, player, Vector3(-2.8, 0.05, -4.5), PI / 2, 0.0)
	failures = _check(prompt_log[0] == door.prompt_close,
		"open deur toont zijn sluit-prompt ('%s')" % prompt_log[0], failures)

	# Sluiten; het paneel draait uit deze kijklijn weg → prompt leeg.
	var close_noises: Array = await _interact_and_listen(tree)
	failures = _check(close_noises.size() == 1,
		"deur sluit hoorbaar", failures)
	failures = _check(prompt_log[0] == "",
		"prompt verdwijnt zodra het deurpaneel wegdraait", failures)

	# Terug aan de voorkant: de cyclus is rond, de deur is weer te openen.
	await _aim(tree, player, Vector3(-3.5, 0.05, -2.3), 0.0, 0.0)
	failures = _check(prompt_log[0] == door.prompt_open,
		"gesloten deur toont weer zijn open-prompt", failures)
	return failures


func _check_locked_door(tree: SceneTree, player, props_root: Node,
		prompt_log: Array, failures: int) -> int:
	var door: Node = props_root.get_node_or_null("TestDoorLocked")
	failures = _check(door != null, "op-slot-deur staat in de dev room", failures)
	if door == null:
		return failures

	await _aim(tree, player, Vector3(-6.0, 0.05, -2.3), 0.0, 0.0)
	failures = _check(prompt_log[0] == door.prompt_locked,
		"op-slot-deur meldt dat via zijn prompt ('%s')" % prompt_log[0], failures)

	# Interact weigert netjes: rammelt hoorbaar, blijft dicht, prompt blijft.
	var noises: Array = await _interact_and_listen(tree)
	failures = _check(noises.size() == 1
		and absf(noises[0][1] - door.loudness_locked) < 0.01,
		"op-slot-deur rammelt hoorbaar maar geeft niet mee", failures)
	failures = _check(prompt_log[0] == door.prompt_locked,
		"op-slot-deur blijft zijn slot-prompt tonen", failures)
	return failures


func _check_drawer(tree: SceneTree, player, props_root: Node,
		prompt_log: Array, failures: int) -> int:
	var drawer: Node = props_root.get_node_or_null("TestDrawer")
	failures = _check(drawer != null, "testla staat in de dev room", failures)
	if drawer == null:
		return failures

	await _aim(tree, player, Vector3(2.0, 0.05, -2.3), 0.0, -0.75)
	failures = _check(prompt_log[0] == drawer.prompt_open,
		"la toont zijn eigen open-prompt ('%s')" % prompt_log[0], failures)

	# Openen: hoorbaar, en de inhoud wordt eenmalig als signaal gemeld.
	var found: Array = []
	var found_recorder := func(item_id: StringName) -> void:
		found.append(item_id)
	drawer.item_found.connect(found_recorder)
	var noises: Array = await _interact_and_listen(tree)
	drawer.item_found.disconnect(found_recorder)
	failures = _check(noises.size() == 1
		and absf(noises[0][1] - drawer.loudness_toggle) < 0.01,
		"la schuift hoorbaar open", failures)
	failures = _check(found == [drawer.item_id],
		"la meldt zijn inhoud via item_found", failures)
	failures = _check(prompt_log[0] == drawer.prompt_close,
		"open la toont zijn sluit-prompt", failures)

	# Sluiten voor een schone eindstand.
	await _interact_and_listen(tree)
	failures = _check(prompt_log[0] == drawer.prompt_open,
		"gesloten la toont weer zijn open-prompt", failures)
	return failures


func _check_pickup(tree: SceneTree, player, props_root: Node,
		prompt_log: Array, failures: int) -> int:
	var pickup: Node = props_root.get_node_or_null("TestPickup")
	failures = _check(pickup != null, "oppakbaar object staat in de dev room", failures)
	if pickup == null:
		return failures
	var expected_prompt: String = pickup.prompt
	var expected_id: StringName = pickup.item_id

	await _aim(tree, player, Vector3(3.0, 0.05, -0.9), 0.0, -0.54)
	failures = _check(prompt_log[0] == expected_prompt,
		"oppakbaar object toont zijn eigen prompt ('%s')" % prompt_log[0], failures)

	var picked: Array = []
	var pick_recorder := func(item_id: StringName) -> void:
		picked.append(item_id)
	pickup.picked_up.connect(pick_recorder)
	await _interact_and_listen(tree)
	failures = _check(picked == [expected_id],
		"oppakken meldt het item via picked_up", failures)
	await _wait_physics_frames(tree, 5)
	failures = _check(not is_instance_valid(pickup),
		"opgepakt object is uit de wereld verdwenen", failures)
	failures = _check(prompt_log[0] == "",
		"prompt verdwijnt met het opgepakte object", failures)
	return failures


func _check_note(tree: SceneTree, player, props_root: Node,
		prompt_log: Array, failures: int) -> int:
	var note: Node = props_root.get_node_or_null("TestNote")
	failures = _check(note != null, "briefje hangt in de dev room", failures)
	if note == null:
		return failures

	await _aim(tree, player, Vector3(0.0, 0.05, -8.2), 0.0, 0.0)
	failures = _check(prompt_log[0] == note.prompt,
		"briefje toont zijn eigen prompt ('%s')" % prompt_log[0], failures)

	var opened: Array = []
	var doc_recorder := func(document_id: StringName, text: String) -> void:
		opened.append([document_id, text])
	EventBus.document_opened.connect(doc_recorder)
	var noises: Array = await _interact_and_listen(tree)
	EventBus.document_opened.disconnect(doc_recorder)
	failures = _check(opened.size() == 1
		and opened[0][0] == note.document_id
		and opened[0][1] == note.document_text,
		"lezen zendt document_opened met id en tekst", failures)
	failures = _check(noises.is_empty(),
		"lezen is stil (geen noise_made)", failures)
	failures = _check(note.document_id in GameState.documents_read,
		"gelezen document staat in GameState", failures)
	GameState.reset()
	return failures


## Zet de speler stil op een plek met blikrichting (yaw op het lichaam,
## pitch op het hoofd) en geeft de interactor tijd om te kijken.
func _aim(tree: SceneTree, player, position: Vector3, yaw: float,
		pitch: float) -> void:
	player.velocity = Vector3.ZERO
	player.global_position = position
	player.rotation = Vector3(0.0, yaw, 0.0)
	player.get_node("Head").rotation.x = pitch
	await _wait_physics_frames(tree, 5)


## Injecteert de interact-toets en vangt de noise_made-events die de
## interactie oplevert; wacht daarna kort zodat de prompt kon verversen.
func _interact_and_listen(tree: SceneTree) -> Array:
	var noises: Array = []
	var recorder := func(position: Vector3, loudness: float) -> void:
		noises.append([position, loudness])
	EventBus.noise_made.connect(recorder)
	_send_action_event(&"interact")
	await _wait_physics_frames(tree, 5)
	EventBus.noise_made.disconnect(recorder)
	return noises


## Injecteert een echt input-event voor een actie. Input.action_press zet
## alleen de actiestatus en genereert géén InputEvent; event-gedreven
## handlers (_unhandled_input) zouden er niets van merken.
func _send_action_event(action: StringName) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	Input.parse_input_event(event)


## Houdt input-acties ingedrukt tot de eerste voetstap (of de frame-limiet)
## en geeft de opgevangen noise_made-events terug als [positie, luidheid].
func _move_and_listen(tree: SceneTree, actions: Array, max_frames: int) -> Array:
	var events := []
	var recorder := func(position: Vector3, loudness: float) -> void:
		events.append([position, loudness])
	EventBus.noise_made.connect(recorder)
	for action in actions:
		Input.action_press(action)
	for i in max_frames:
		await tree.physics_frame
		if events.size() >= 1:
			break
	for action in actions:
		Input.action_release(action)
	EventBus.noise_made.disconnect(recorder)
	# Uitrollen tot stilstand, zodat de volgende meting schoon begint. Ruim
	# nemen: vanaf rensnelheid duurt afremmen ~20 physics-frames, en een nog
	# lopende voetstap-timer moet ook de kans krijgen zichzelf te stoppen.
	await _wait_physics_frames(tree, 35)
	return events


func _wait_physics_frames(tree: SceneTree, count: int) -> void:
	for i in count:
		await tree.physics_frame


func _check(condition: bool, description: String, failures: int) -> int:
	if condition:
		Log.info("TEST OK   · %s" % description)
		return failures
	Log.error("TEST FOUT · %s" % description)
	return failures + 1
