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

## Het inventory-systeem (taak 004); zelfde D-015-afspraak. Zonder deze map
## blijven pickups liggen (nette degradatie) en slaan de inventorytests over.
const INVENTORY_SCENE := "res://game/systems/inventory/inventory.tscn"

## Het audiosysteem (taak 005); zelfde D-015-afspraak. Zonder deze map
## draait het spel stil en slaan de audiotests over.
const AUDIO_SYSTEM_SCENE := "res://game/systems/audio/audio_system.tscn"

## Licht & sfeer (taak 006): drie losse verwijdereenheden met elk hun
## eigen D-015-afspraak. Zonder zaklamp geen licht; zonder budget-bewaking
## vangt alleen deze suite configfouten; zonder TL-prop is de nachtstaat
## armatuurloos maar blijft het level parsebaar.
const FLASHLIGHT_SCENE := "res://game/systems/flashlight/flashlight.tscn"
const LIGHT_BUDGET_SCENE := "res://game/systems/light_budget/light_budget.tscn"
const LIGHT_TL_SCENE := "res://game/props/light_tl/light_tl.tscn"


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
		"flashlight_toggled": 1,
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

	# 15. Inventory (taak 004) — zelfde D-015-afspraak. LET OP: enkele tests
	# hieronder toetsen bewust de luide faalpaden (add_item(null), tweede
	# inventory) — de push_warnings in de output zijn dan het bewijs, geen bug.
	if ResourceLoader.exists(INVENTORY_SCENE):
		failures = await _check_inventory(tree, failures)
	else:
		Log.info("TEST INFO · inventory-systeem ontbreekt — inventorytests overgeslagen (D-015)")

	# 16. Audio (taak 005) — zelfde D-015-afspraak; ook hier zijn de
	# warnings van de bewust geteste faalpaden (onbekende cue-id, tweede
	# systeem) het bewijs, geen bug.
	if ResourceLoader.exists(AUDIO_SYSTEM_SCENE):
		failures = await _check_audio(tree, failures)
	else:
		Log.info("TEST INFO · audiosysteem ontbreekt — audiotests overgeslagen (D-015)")

	# 17. Licht & sfeer (taak 006). Environment en brightness zijn
	# level-/settings-infrastructuur en draaien altijd; de drie
	# verwijdereenheden (zaklamp, TL-prop, budget-bewaking) hebben elk hun
	# eigen D-015-afspraak. LET OP: de budgettests forceren bewust een
	# overschrijding — de LightBudget-warnings in de output zijn het
	# bewijs, geen bug.
	failures = await _check_environment_brightness(tree, failures)
	if ResourceLoader.exists(FLASHLIGHT_SCENE):
		failures = await _check_flashlight(tree, failures)
	else:
		Log.info("TEST INFO · zaklampsysteem ontbreekt — zaklamptests overgeslagen (D-015)")
	if ResourceLoader.exists(LIGHT_TL_SCENE):
		failures = await _check_light_tl(tree, failures)
	else:
		Log.info("TEST INFO · TL-prop ontbreekt — TL-tests overgeslagen (D-015)")
	if ResourceLoader.exists(LIGHT_BUDGET_SCENE):
		failures = await _check_light_budget(tree, failures)
	else:
		Log.info("TEST INFO · budget-bewaking ontbreekt — budgettests overgeslagen (D-015)")
	if ResourceLoader.exists(FLASHLIGHT_SCENE) \
			and ResourceLoader.exists(LIGHT_BUDGET_SCENE) \
			and ResourceLoader.exists(LIGHT_TL_SCENE):
		failures = await _check_lighting_f3(tree, failures)

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

	# Licht (herijkt 006): de nachtstaat is de actieve, gecommitte staat.
	# De KI-001-dekking blijft onverkort; de drempels toetsen voortaan de
	# donkere waarheid: ≥2 actieve bronnen zijn de stabiele TL-ankers
	# (LEVEL §2.3), en géén DirectionalLight schijnt omhoog (KI-002).
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
	if ResourceLoader.exists(LIGHT_TL_SCENE):
		failures = _check(lit >= 2,
			"nachtverlichting is aan (%d actieve lichten)" % lit, failures)
	else:
		Log.info("TEST INFO · TL-prop ontbreekt — lichttelling overgeslagen (D-015)")

	# Werklicht is debug, geen gameplay: de gecommitte standaard is nacht.
	var werklicht_rig: Node3D = level.find_child("Werklicht", true, false)
	failures = _check(
		werklicht_rig != null and not werklicht_rig.visible
		and level.get("werklicht") == false,
		"nachtstaat is de actieve staat (werklicht uit)", failures)

	# Schaduwbudget (LEVEL §5, dossier 006 §5): het level ontwerpt op max 3
	# schaduw-werpende lampen; het vierde slot is voor de zaklamp
	# gereserveerd (haar spot staat uit en telt hier dus niet mee).
	var shadow_lights := 0
	for node in level.find_children("", "Light3D", true, false):
		var light := node as Light3D
		if light.shadow_enabled and light.is_visible_in_tree():
			shadow_lights += 1
	failures = _check(shadow_lights <= 3,
		"level blijft binnen het schaduwbudget (%d/3 + zaklampslot)"
		% shadow_lights, failures)

	# Nachtstaat-samenstelling (keuze E): 2 stabiele ankers, 1 bewuste
	# flikkerbuis, rest defect — duck-typed via de groep (D-021).
	if ResourceLoader.exists(LIGHT_TL_SCENE):
		var stable := 0
		var flickering := 0
		var broken := 0
		for tl in tree.get_nodes_in_group("light_tl"):
			if not tl.has_method("get_tl_state"):
				continue
			match tl.get_tl_state():
				0: stable += 1
				1: broken += 1
				2: flickering += 1
		failures = _check(stable == 2 and flickering == 1 and broken >= 1,
			"nachtstaat: 2 stabiel / 1 flikkerend / rest defect (%d/%d/%d)"
			% [stable, flickering, broken], failures)

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
	# Id vóór de interactie lezen: bij acceptatie is de node daarna weg.
	var expected_id := StringName(pickup.item.get(&"id")) \
		if pickup.item != null else &""

	await _aim(tree, player, Vector3(3.0, 0.05, -0.9), 0.0, -0.54)
	failures = _check(prompt_log[0] == expected_prompt,
		"oppakbaar object toont zijn eigen prompt ('%s')" % prompt_log[0], failures)

	var picked: Array = []
	var pick_recorder := func(item_id: StringName) -> void:
		picked.append(item_id)
	pickup.picked_up.connect(pick_recorder)
	var noises: Array = await _interact_and_listen(tree)

	if ResourceLoader.exists(INVENTORY_SCENE):
		# Flow 004: de inventory bevestigde — feedback en verdwijnen zijn
		# van de prop zelf, en gebeuren exact één keer.
		failures = _check(picked == [expected_id],
			"oppakken meldt het item via picked_up", failures)
		failures = _check(noises.size() == 1,
			"oppak-geluid klinkt precies één keer (ná bevestiging)", failures)
		await _wait_physics_frames(tree, 5)
		failures = _check(not is_instance_valid(pickup),
			"opgepakt object is uit de wereld verdwenen", failures)
		failures = _check(prompt_log[0] == "",
			"prompt verdwijnt met het opgepakte object", failures)
	else:
		# D-015-degradatie: geen inventory = geen bevestiging — het object
		# blijft liggen en is direct opnieuw interacteerbaar (dossier §5a).
		failures = _check(picked.is_empty() and noises.is_empty(),
			"zonder inventory: geen oppak-feedback", failures)
		failures = _check(is_instance_valid(pickup) and pickup.can_interact(),
			"zonder inventory: object blijft liggen en blijft interacteerbaar",
			failures)
		pickup.picked_up.disconnect(pick_recorder)
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


## Inventorytests (taak 004, dossier §7). Duck-typed: deze suite noemt
## ItemResource of de inventory-klasse nooit bij naam (les D-021).
func _check_inventory(tree: SceneTree, failures: int) -> int:
	# §7.1+7.2 — itemmodel en id-discipline over de canonieke items-map.
	const ITEMS_DIR := "res://game/systems/inventory/items"
	var seen_ids := {}
	var item_files := DirAccess.get_files_at(ITEMS_DIR)
	var items_valid := item_files.size() > 0
	for file in item_files:
		if not file.ends_with(".tres"):
			continue
		var res: Resource = load(ITEMS_DIR + "/" + file)
		if res == null or String(res.get(&"id")).is_empty() \
				or String(res.get(&"display_name")).is_empty():
			items_valid = false
			Log.error("itemdefinitie ongeldig: %s" % file)
			continue
		var res_id: StringName = res.get(&"id")
		if seen_ids.has(res_id):
			failures = _check(false,
				"item-id '%s' is uniek (botsing: %s en %s)"
				% [res_id, seen_ids[res_id], file], failures)
		seen_ids[res_id] = file
	failures = _check(items_valid,
		"alle itemdefinities laden met geldige id en naam (%d stuks)"
		% seen_ids.size(), failures)
	failures = _check(seen_ids.size() == item_files.size(),
		"alle item-id's in de items-map zijn uniek", failures)

	# §7.9 — precies één autoritatieve inventory.
	var inventories := tree.get_nodes_in_group("inventory")
	failures = _check(inventories.size() == 1,
		"exact één inventory in de groep (gevonden: %d)"
		% inventories.size(), failures)
	if inventories.is_empty():
		return failures
	var inventory = inventories[0]

	# §7.3 — unit-semantiek van add/remove/has, relatief aan de baseline
	# (de 003-e2e-test heeft al een sleutel opgenomen).
	var added: Array = []
	var removed: Array = []
	var added_recorder := func(item: Resource) -> void: added.append(item)
	var removed_recorder := func(item: Resource) -> void: removed.append(item)
	EventBus.item_added.connect(added_recorder)
	EventBus.item_removed.connect(removed_recorder)

	var baseline: int = inventory.get_items().size()
	var flashlight: Resource = load(ITEMS_DIR + "/zaklamp.tres")
	failures = _check(inventory.add_item(flashlight) == true
		and inventory.get_items().size() == baseline + 1 and added.size() == 1,
		"add_item neemt een geldig item op (met item_added)", failures)
	failures = _check(inventory.add_item(flashlight) == true
		and inventory.get_items().size() == baseline + 2,
		"dezelfde item-id mag een tweede slot innemen (geen stacking)", failures)
	failures = _check(inventory.has_item(&"zaklamp"),
		"has_item vindt het opgenomen item", failures)

	failures = _check(inventory.add_item(null) == false
		and inventory.get_items().size() == baseline + 2 and added.size() == 2,
		"add_item(null) weigert zonder mutatie of signaal", failures)
	failures = _check(inventory.add_item(Resource.new()) == false
		and inventory.get_items().size() == baseline + 2,
		"verkeerd Resource-type wordt veilig geweigerd", failures)
	var empty_id_item: Resource = (load(
		"res://game/systems/inventory/item_resource.gd") as Script).new()
	failures = _check(inventory.add_item(empty_id_item) == false
		and inventory.get_items().size() == baseline + 2,
		"item met lege id wordt veilig geweigerd", failures)

	# §7 — volle inventory weigert zonder mutatie (return false, geen signaal).
	var original_capacity: int = inventory.capacity
	inventory.capacity = inventory.get_items().size()
	failures = _check(inventory.is_full(), "is_full herkent een volle inventory",
		failures)
	failures = _check(inventory.add_item(flashlight) == false
		and inventory.get_items().size() == baseline + 2 and added.size() == 2,
		"volle inventory weigert zonder mutatie of signaal", failures)
	inventory.capacity = original_capacity

	# remove_item: succes muteert + signaleert; mislukking doet niets.
	failures = _check(inventory.remove_item(&"zaklamp") != null
		and removed.size() == 1
		and inventory.get_items().size() == baseline + 1,
		"remove_item verwijdert één vermelding (met item_removed)", failures)
	failures = _check(inventory.remove_item(&"zaklamp") != null
		and inventory.remove_item(&"zaklamp") == null
		and removed.size() == 2
		and inventory.get_items().size() == baseline,
		"remove_item zonder match muteert en signaleert niet", failures)

	EventBus.item_added.disconnect(added_recorder)
	EventBus.item_removed.disconnect(removed_recorder)

	# Functionele keten: alleen met speler, interactor en testprops.
	var player = tree.get_first_node_in_group("player")
	var props_root: Node = tree.root.find_child("TestProps", true, false)
	if player == null or props_root == null \
			or not ResourceLoader.exists(INTERACTOR_SCENE):
		Log.info("TEST INFO · geen speler/interactor — functionele inventorytests overgeslagen")
		return failures
	failures = await _check_inventory_flow(
		tree, player, props_root, inventory, failures)
	return failures


## Functionele flow-tests (dossier §7.4-7.8): reject + opnieuw interacteren,
## response-invarianten, ongeldige itemdata, tweede inventory, F3-regel.
func _check_inventory_flow(tree: SceneTree, player, props_root: Node,
		inventory, failures: int) -> int:
	var key_item: Resource = load(
		"res://game/systems/inventory/items/sleutel_kleedkamer.tres")
	var resolved: Array = []
	var resolved_recorder := func(source: Node, accepted: bool) -> void:
		resolved.append([source, accepted])
	EventBus.item_pickup_resolved.connect(resolved_recorder)

	# §7.5 — volle inventory: prop blijft en is direct opnieuw
	# interacteerbaar; na capaciteitsherstel slaagt dezelfde prop alsnog.
	var pickup = _spawn_test_pickup(props_root, key_item)
	var picked: Array = []
	var pick_recorder := func(item_id: StringName) -> void:
		picked.append(item_id)
	pickup.picked_up.connect(pick_recorder)
	var size_before: int = inventory.get_items().size()
	var original_capacity: int = inventory.capacity
	inventory.capacity = size_before

	await _aim(tree, player, Vector3(3.0, 0.05, -0.9), 0.0, -0.54)
	var noises: Array = await _interact_and_listen(tree)
	failures = _check(resolved.size() == 1 and resolved[0][1] == false,
		"volle inventory beantwoordt het verzoek met rejected", failures)
	failures = _check(is_instance_valid(pickup) and pickup.can_interact()
		and noises.is_empty() and picked.is_empty()
		and inventory.get_items().size() == size_before,
		"rejected: prop blijft, geen geluid, inventory ongewijzigd", failures)

	inventory.capacity = original_capacity
	resolved.clear()
	noises = await _interact_and_listen(tree)
	failures = _check(resolved.size() == 1 and resolved[0][1] == true
		and picked.size() == 1 and noises.size() == 1,
		"dezelfde prop is na herstel direct opnieuw interacteerbaar", failures)
	await _wait_physics_frames(tree, 5)
	failures = _check(not is_instance_valid(pickup)
		and inventory.get_items().size() == size_before + 1,
		"accepted na eerdere rejection: prop exact één keer verdwenen", failures)

	# §7.7 — response-invarianten via handmatig geïnjecteerde responses.
	var stray = _spawn_test_pickup(props_root, key_item)
	var stray_picked: Array = []
	var stray_recorder := func(item_id: StringName) -> void:
		stray_picked.append(item_id)
	stray.picked_up.connect(stray_recorder)
	EventBus.item_pickup_resolved.emit(stray, true)
	await _wait_physics_frames(tree, 3)
	failures = _check(is_instance_valid(stray) and stray_picked.is_empty(),
		"response zonder actief verzoek wordt genegeerd", failures)
	var decoy := Node.new()
	tree.root.add_child(decoy)
	EventBus.item_pickup_resolved.emit(decoy, true)
	await _wait_physics_frames(tree, 3)
	failures = _check(is_instance_valid(stray) and stray_picked.is_empty(),
		"response met andere source wordt genegeerd", failures)
	decoy.queue_free()

	# Dubbele response binnen één verzoek: een extra 'vervalste' beantwoorder
	# op de bus — de prop mag maar één keer afhandelen.
	var forger := func(source: Node, _item: Resource) -> void:
		EventBus.item_pickup_resolved.emit(source, true)
	EventBus.item_pickup_requested.connect(forger)
	var size_before_double: int = inventory.get_items().size()
	await _aim(tree, player, Vector3(3.0, 0.05, -0.9), 0.0, -0.54)
	var double_noises: Array = await _interact_and_listen(tree)
	EventBus.item_pickup_requested.disconnect(forger)
	await _wait_physics_frames(tree, 5)
	failures = _check(stray_picked.size() == 1 and double_noises.size() == 1
		and not is_instance_valid(stray)
		and inventory.get_items().size() == size_before_double + 1,
		"dubbele response: exact één afhandeling en één verwijdering", failures)

	# §7.8 — ongeldige itemdata end-to-end: afgewezen, prop blijft, geen crash.
	var invalid = _spawn_test_pickup(props_root, null)
	resolved.clear()
	await _aim(tree, player, Vector3(3.0, 0.05, -0.9), 0.0, -0.54)
	noises = await _interact_and_listen(tree)
	failures = _check(resolved.size() == 1 and resolved[0][1] == false
		and is_instance_valid(invalid) and invalid.can_interact()
		and noises.is_empty(),
		"pickup zonder geldige itemdata wordt veilig geweigerd", failures)
	invalid.queue_free()

	# §7.9 — een tweede inventory abonneert zich niet: één verzoek levert
	# exact één response op (getest met null-item: niemand muteert).
	var second: Node = load(INVENTORY_SCENE).instantiate()
	tree.root.add_child(second)
	await _wait_physics_frames(tree, 2)
	resolved.clear()
	var dummy := Node.new()
	tree.root.add_child(dummy)
	EventBus.item_pickup_requested.emit(dummy, null)
	failures = _check(resolved.size() == 1,
		"tweede inventory blijft doof: één verzoek, één response", failures)
	second.queue_free()
	dummy.queue_free()

	EventBus.item_pickup_resolved.disconnect(resolved_recorder)

	# §7.11 — F3-regel toont de bezetting via de groep.
	var overlay := tree.root.find_child("DebugOverlay", true, false)
	var info_label: Label = overlay.find_child("InfoLabel", true, false) \
		if overlay != null else null
	failures = _check(overlay != null and info_label != null,
		"debug overlay aanwezig voor de inventory-regel", failures)
	if overlay != null and info_label != null:
		_send_action_event(&"debug_overlay")
		await _wait_physics_frames(tree, 3)
		var expected := "inventory: %d/%d" % [
			inventory.get_items().size(), inventory.capacity]
		failures = _check(expected in info_label.text
			and "sleutel_kleedkamer" in info_label.text,
			"F3 toont bezetting en item-id's ('%s')" % expected, failures)
		_send_action_event(&"debug_overlay")
		await _wait_physics_frames(tree, 2)
	return failures


## Audiotests (taak 005, dossier §10). Duck-typed: deze suite noemt
## SoundResource of audio-klassen nooit bij naam (D-021).
func _check_audio(tree: SceneTree, failures: int) -> int:
	# §10.2 — datamodel en id-discipline over de sounds-map.
	const SOUNDS_DIR := "res://game/systems/audio/sounds"
	var seen_ids := {}
	var sounds_valid := true
	var sound_files := DirAccess.get_files_at(SOUNDS_DIR)
	for file in sound_files:
		if not file.ends_with(".tres"):
			continue
		var sound: Resource = load(SOUNDS_DIR + "/" + file)
		if sound == null or String(sound.get(&"id")).is_empty() \
				or (sound.get(&"streams") as Array).is_empty() \
				or not AudioDirector.BUSES.has(sound.get(&"bus")):
			sounds_valid = false
			Log.error("geluidsdefinitie ongeldig: %s" % file)
			continue
		var sound_id: StringName = sound.get(&"id")
		if seen_ids.has(sound_id):
			failures = _check(false, "cue-id '%s' is uniek (botsing: %s en %s)"
				% [sound_id, seen_ids[sound_id], file], failures)
		seen_ids[sound_id] = file
	failures = _check(sounds_valid and seen_ids.size() >= 11,
		"alle geluidsdefinities laden met geldige id/streams/bus (%d)"
		% seen_ids.size(), failures)

	# Eén autoritatief audiosysteem, door de bootstrap gespawnd.
	var systems := tree.get_nodes_in_group("audio_system")
	failures = _check(systems.size() == 1,
		"exact één audiosysteem in de groep (gevonden: %d)" % systems.size(),
		failures)
	if systems.is_empty():
		return failures
	var audio = systems[0]
	var one_shots = audio.find_child("OneShots", true, false)
	failures = _check(one_shots != null, "one-shot-pool aanwezig", failures)

	# §10.3 — onbekende cue-id: warning, geen crash, geen geclaimde player.
	one_shots.stop_all()
	EventBus.audio_cue.emit(&"bestaat_niet_xyz", Vector3.ZERO)
	failures = _check(audio.get_active_one_shots().is_empty(),
		"onbekende cue-id claimt geen player (veilig falen)", failures)

	# Scheiding van concepten (kader §1): noise_made veroorzaakt nooit
	# audio, audio_cue veroorzaakt nooit noise.
	var noises: Array = []
	var noise_recorder := func(position: Vector3, loudness: float) -> void:
		noises.append([position, loudness])
	EventBus.noise_made.connect(noise_recorder)
	EventBus.noise_made.emit(Vector3.ZERO, 5.0)
	failures = _check(audio.get_active_one_shots().is_empty(),
		"noise_made veroorzaakt géén hoorbare audio", failures)
	EventBus.audio_cue.emit(&"door_rattle", Vector3(1, 1, 1))
	var actief: Array = audio.get_active_one_shots()
	failures = _check(noises.size() == 1
		and actief.size() == 1 and actief[0] == &"door_rattle",
		"audio_cue veroorzaakt géén noise_made (kanalen onafhankelijk)",
		failures)
	EventBus.noise_made.disconnect(noise_recorder)

	# §10.3 — pool: claim/release zonder lek, deterministisch stelen.
	var player_count := audio.find_children("", "AudioStreamPlayer3D",
		true, false).size()
	for i in 20:
		EventBus.audio_cue.emit(&"door_rattle", Vector3(i, 1, 0))
	failures = _check(audio.get_active_one_shots().size() <= player_count
		and audio.find_children("", "AudioStreamPlayer3D", true, false).size()
			== player_count,
		"pool-uitputting steelt deterministisch, spawnt nooit bij", failures)
	one_shots.stop_all()
	failures = _check(audio.get_active_one_shots().is_empty(),
		"stop_all geeft de hele pool vrij (geen lek)", failures)

	# §10.4 — ambience: de dev room heeft zijn nulpunt expliciet aangezet;
	# een vers (niet-autoritatief) systeem is standaard volledig stil.
	var lagen: Array = audio.get_active_ambience()
	failures = _check(lagen.size() == 1 and lagen[0] == &"amb_hum_koeling",
		"dev room activeerde zijn nulpunt-laag expliciet", failures)
	var fresh: Node = load(AUDIO_SYSTEM_SCENE).instantiate()
	tree.root.add_child(fresh)
	await _wait_physics_frames(tree, 2)
	failures = _check(fresh.get_active_ambience().is_empty()
		and fresh.get_active_one_shots().is_empty(),
		"een vers audiosysteem is standaard stil (P2)", failures)
	# De tweede instantie is doof: één cue → alleen het autoritatieve
	# systeem claimt een player.
	EventBus.audio_cue.emit(&"door_rattle", Vector3.ZERO)
	failures = _check(audio.get_active_one_shots().size() == 1
		and fresh.get_active_one_shots().is_empty(),
		"tweede audiosysteem blijft doof voor de bus", failures)
	one_shots.stop_all()
	fresh.queue_free()

	# §10.5 — muziek-API: start/stop zonder externe triggers; veilig falen.
	var music = audio.find_child("Music", true, false)
	audio.play_music_cue(&"amb_hum_koeling", 0.0)
	failures = _check(music.get_current_cue() == &"amb_hum_koeling",
		"muziek-cue start via de API", failures)
	audio.stop_music_cue(0.0)
	failures = _check(music.get_current_cue() == &"",
		"muziek-cue stopt via de API", failures)
	audio.play_music_cue(&"bestaat_niet_xyz", 0.0)
	failures = _check(music.get_current_cue() == &"",
		"onbekende muziek-cue faalt veilig", failures)

	# Functionele keten door de echte bronnen.
	var player = tree.get_first_node_in_group("player")
	var props_root: Node = tree.root.find_child("TestProps", true, false)
	if player == null or props_root == null \
			or not ResourceLoader.exists(INTERACTOR_SCENE):
		Log.info("TEST INFO · geen speler/interactor — functionele audiotests overgeslagen")
		return failures
	failures = await _check_audio_flow(tree, player, props_root, audio,
		one_shots, failures)
	return failures


## Functionele audioketen (dossier §10.1): deur-cue, pickup-cue exact één
## keer en pas na accepted, geen cue bij rejected, one-shot overleeft de
## verdwenen bronprop, en de F3-regel toont het geheel.
func _check_audio_flow(tree: SceneTree, player, props_root: Node,
		audio, one_shots, failures: int) -> int:
	var cues: Array = []
	var cue_recorder := func(sound_id: StringName, position: Vector3) -> void:
		cues.append([sound_id, position])
	EventBus.audio_cue.connect(cue_recorder)

	# Deuractie → exact de bedoelde cue, hoorbaar op de deurpositie (§10.3).
	# Kort na de interactie meten: de headless-driver speelt streams écht
	# af, dus na de cue-duur is de player alweer netjes vrijgegeven.
	var door: Node = props_root.get_node_or_null("TestDoor")
	one_shots.stop_all()
	await _aim(tree, player, Vector3(-3.5, 0.05, -2.3), 0.0, 0.0)
	cues.clear()
	_send_action_event(&"interact")
	await _wait_physics_frames(tree, 4)
	var door_active: Array = audio.get_active_one_shots()
	var door_ok: bool = door != null and cues.size() == 1 \
		and cues[0][0] == door.cue_open \
		and door_active.size() == 1 and door_active[0] == door.cue_open
	failures = _check(door_ok,
		"deur opent met exact zijn eigen cue (%s)"
		% (cues[0][0] if cues.size() == 1 else "geen/meer"), failures)
	var positioned := false
	for p3d in audio.find_children("", "AudioStreamPlayer3D", true, false):
		if p3d.playing and p3d.global_position.distance_to(
				door.global_position) < 1.5:
			positioned = true
	failures = _check(positioned,
		"deur-cue speelt 3D op de exacte deurpositie", failures)
	await _wait_physics_frames(tree, 35)
	# Deur weer dicht (zijaanzicht, zoals in de 003-tests).
	await _aim(tree, player, Vector3(-2.8, 0.05, -4.5), PI / 2, 0.0)
	cues.clear()
	_send_action_event(&"interact")
	await _wait_physics_frames(tree, 4)
	failures = _check(cues.size() == 1 and door != null
		and cues[0][0] == door.cue_close,
		"deur sluit met exact zijn eigen cue", failures)
	await _wait_physics_frames(tree, 35)

	# Rejected pickup → géén pickup-cue (kader §7.3).
	var inventory = tree.get_first_node_in_group("inventory")
	var key_item: Resource = load(
		"res://game/systems/inventory/items/sleutel_kleedkamer.tres")
	if inventory != null:
		var pickup = _spawn_test_pickup(props_root, key_item)
		var original_capacity: int = inventory.capacity
		inventory.capacity = inventory.get_items().size()
		one_shots.stop_all()
		await _aim(tree, player, Vector3(3.0, 0.05, -0.9), 0.0, -0.54)
		cues.clear()
		await _interact_and_listen(tree)
		failures = _check(cues.is_empty()
			and audio.get_active_one_shots().is_empty(),
			"geweigerde pickup veroorzaakt geen pickup-cue", failures)

		# Accepted → exact één cue, en de one-shot overleeft de verdwenen
		# bronprop (kader §7.1/§7.2). Binnen de cue-duur meten: de prop is
		# dan al gefreed terwijl de pool-player nog speelt.
		inventory.capacity = original_capacity
		cues.clear()
		_send_action_event(&"interact")
		await _wait_physics_frames(tree, 4)
		var pickup_active: Array = audio.get_active_one_shots()
		var pickup_cue_ok: bool = cues.size() == 1 \
			and cues[0][0] == &"item_pickup" \
			and not is_instance_valid(pickup) \
			and pickup_active.size() == 1 and pickup_active[0] == &"item_pickup"
		failures = _check(pickup_cue_ok,
			"accepted pickup: exact één cue die de verdwenen prop overleeft",
			failures)
		# En na de cue-duur geeft `finished` de player vanzelf terug aan de
		# pool — release zonder lek, zonder stop_all.
		await _wait_physics_frames(tree, 30)
		failures = _check(audio.get_active_one_shots().is_empty(),
			"one-shot player komt na afloop vanzelf vrij (finished)", failures)
		inventory.remove_item(StringName(key_item.get(&"id")))
	else:
		Log.info("TEST INFO · geen inventory — pickup-audiotests overgeslagen")

	# F3-regel toont pool-status, spelende cue en ambience-laag.
	var overlay := tree.root.find_child("DebugOverlay", true, false)
	var info_label: Label = overlay.find_child("InfoLabel", true, false) \
		if overlay != null else null
	if info_label != null:
		_send_action_event(&"debug_overlay")
		await _wait_physics_frames(tree, 3)
		failures = _check("actieve geluiden: " in info_label.text
			and "amb: amb_hum_koeling" in info_label.text,
			"F3 toont actieve geluiden en ambience-laag", failures)
		_send_action_event(&"debug_overlay")
		await _wait_physics_frames(tree, 2)

	one_shots.stop_all()
	EventBus.audio_cue.disconnect(cue_recorder)
	return failures


## Environment- en brightnesstests (taak 006 §6, lost TD-003 af): filmische
## tonemap, diepte-fog, debanding, en brightness die écht aangrijpt op
## adjustment_brightness — geclampt op 0.8..1.2, ook vanaf schijf.
func _check_environment_brightness(tree: SceneTree, failures: int) -> int:
	var level: Node = tree.root.find_child("DevRoom", true, false)
	var world_env: WorldEnvironment = level.find_child("WorldEnvironment",
		true, false) if level != null else null
	if world_env == null or world_env.environment == null:
		return _check(false, "environment aanwezig voor licht-/brightnesstests",
			failures)
	var env := world_env.environment
	failures = _check(env.tonemap_mode != Environment.TONE_MAPPER_LINEAR,
		"tonemap is niet-lineair (filmisch)", failures)
	failures = _check(env.fog_enabled and env.fog_density > 0.0,
		"diepte-fog is actief (dichtheid %.3f)" % env.fog_density, failures)
	failures = _check(bool(ProjectSettings.get_setting(
			"rendering/anti_aliasing/quality/use_debanding", false)),
		"debanding staat aan (near-black zonder kleurtrappen)", failures)

	# TD-003: de instelling grijpt echt aan, met de smalle 006-range.
	failures = _check(absf(SettingsManager.brightness - 1.0) < 0.001,
		"brightness-standaard is 1.0", failures)
	failures = _check(
		env.adjustment_enabled
		and absf(env.adjustment_brightness - SettingsManager.brightness) < 0.001,
		"environment volgt de brightness-instelling (TD-003 afgelost)", failures)
	SettingsManager.set_brightness(2.0)
	failures = _check(
		absf(SettingsManager.brightness - 1.2) < 0.001
		and absf(env.adjustment_brightness - 1.2) < 0.001,
		"brightness clampt op maximum 1.2 en de environment volgt", failures)
	SettingsManager.set_brightness(0.5)
	failures = _check(
		absf(SettingsManager.brightness - 0.8) < 0.001
		and absf(env.adjustment_brightness - 0.8) < 0.001,
		"brightness clampt op minimum 0.8", failures)
	SettingsManager.set_brightness(1.0)

	# Een oude configwaarde buiten de range wordt bij het laden veilig
	# binnengetrokken (de 0.5-2.0-clamp van vóór 006 bestaat niet meer).
	var config := ConfigFile.new()
	config.load(SettingsManager.SETTINGS_PATH)
	config.set_value("video", "brightness", 2.0)
	config.save(SettingsManager.SETTINGS_PATH)
	SettingsManager.load_settings()
	failures = _check(absf(SettingsManager.brightness - 1.2) < 0.001,
		"configwaarde buiten de range wordt bij laden geclampt", failures)
	SettingsManager.set_brightness(1.0)
	SettingsManager.save_settings()
	return failures


## Zaklamptests (taak 006 §3/§3a, keuzes C+D): gesloten bezit-gate, exact
## één emissie per kanaal ná de statewijziging, positiescheiding
## (licht = camera, geluid = speler), duplicaatsemantiek via hercontrole,
## herspawn zonder dubbele verwerking, pauze en debug-bypass.
func _check_flashlight(tree: SceneTree, failures: int) -> int:
	var packed: PackedScene = load(FLASHLIGHT_SCENE)
	var standalone := packed.instantiate() if packed != null else null
	failures = _check(standalone != null,
		"zaklamp-scène instantieert los", failures)
	if standalone != null:
		failures = _check(standalone.get("debug_bezit_bypass") == false,
			"debug_bezit_bypass staat default uit", failures)
		standalone.free()

	var flashlights := tree.get_nodes_in_group("flashlight")
	failures = _check(flashlights.size() == 1,
		"exact één zaklampsysteem gespawnd (gevonden: %d)"
		% flashlights.size(), failures)
	if flashlights.is_empty():
		return failures
	var flashlight = flashlights[0]
	failures = _check(flashlight.get("debug_bezit_bypass") == false,
		"gecommitte dev room gebruikt de bypass niet (echte pickup-flow)",
		failures)

	# Recorders op alle drie de gevolgkanalen — gescheiden geteld. De
	# cue-id eenmalig lokaal vangen: de herspawn-test verderop vriest de
	# oorspronkelijke instantie, en een lambda mag daar niet meer aan.
	var toggles: Array = []
	var cues: Array = []
	var noises: Array = []
	var click_cue: StringName = flashlight.get("click_cue")
	var toggle_recorder := func(is_on: bool) -> void:
		toggles.append(is_on)
	var cue_recorder := func(sound_id: StringName, position: Vector3) -> void:
		if sound_id == click_cue:
			cues.append(position)
	var noise_recorder := func(position: Vector3, loudness: float) -> void:
		noises.append([position, loudness])
	EventBus.flashlight_toggled.connect(toggle_recorder)
	EventBus.audio_cue.connect(cue_recorder)
	EventBus.noise_made.connect(noise_recorder)

	# Zonder bezit (of zonder inventory): gesloten falen — geen state,
	# geen licht, en op géén enkel kanaal ook maar één emissie.
	failures = _check(flashlight.has_flashlight() == false,
		"zaklampbezit start op nee (niets opgeraapt)", failures)
	_send_action_event(&"flashlight")
	await _wait_physics_frames(tree, 3)
	var inventory = tree.get_first_node_in_group("inventory")
	var closed_label := "zonder inventory: gesloten falen" if inventory == null \
		else "zonder bezit: geen toggle en geen enkel gevolgkanaal"
	failures = _check(
		not flashlight.is_light_on() and toggles.is_empty()
		and cues.is_empty() and noises.is_empty(), closed_label, failures)

	# Debug-bypass: expliciet aanzetten werkt (deze suite ís een
	# debugbuild), het eerlijke bezit blijft nee, en daarna weer uit.
	flashlight.set("debug_bezit_bypass", true)
	_send_action_event(&"flashlight")
	await _wait_physics_frames(tree, 3)
	failures = _check(
		flashlight.is_light_on() and toggles == [true]
		and flashlight.has_flashlight() == false,
		"bypass (debug, expliciet aan) toggle't zonder bezit", failures)
	_send_action_event(&"flashlight")
	await _wait_physics_frames(tree, 3)
	flashlight.set("debug_bezit_bypass", false)
	failures = _check(not flashlight.is_light_on() and toggles == [true, false],
		"bypass weer uit; licht netjes uitgezet", failures)

	if inventory == null:
		Log.info("TEST INFO · geen inventory — bezitstests overgeslagen (gesloten falen gedekt)")
		EventBus.flashlight_toggled.disconnect(toggle_recorder)
		EventBus.audio_cue.disconnect(cue_recorder)
		EventBus.noise_made.disconnect(noise_recorder)
		return failures

	# Bezit via de echte inventory; daarna een geslaagde toggle: exact
	# één emissie per kanaal, pas ná de statewijziging.
	var zaklamp_item: Resource = load(
		"res://game/systems/inventory/items/zaklamp.tres")
	inventory.add_item(zaklamp_item)
	await _wait_physics_frames(tree, 2)
	failures = _check(flashlight.has_flashlight(),
		"item_added geeft bezit (eventgedreven hercontrole)", failures)
	toggles.clear()
	cues.clear()
	noises.clear()
	_send_action_event(&"flashlight")
	await _wait_physics_frames(tree, 3)
	failures = _check(
		flashlight.is_light_on() and toggles == [true]
		and cues.size() == 1 and noises.size() == 1,
		"geslaagde toggle: exact één emissie per kanaal", failures)

	# Positiescheiding (§3a): geluid op de speler-body, licht op de camera.
	var player = tree.get_first_node_in_group("player")
	var camera := tree.root.get_camera_3d()
	if player is Node3D and camera != null and noises.size() == 1:
		failures = _check(
			noises[0][0].distance_to(player.global_position) < 0.01
			and cues[0].distance_to(player.global_position) < 0.01
			and absf(noises[0][1] - flashlight.get("click_loudness")) < 0.01,
			"klik klinkt op de spelerpositie met de klik-luidheid", failures)
		await _wait_physics_frames(tree, 10)
		failures = _check(
			flashlight.global_position.distance_to(camera.global_position) < 0.3
			and flashlight.global_position.distance_to(player.global_position) > 1.0,
			"licht volgt de camera, niet de spelervoeten", failures)

	# Pauze: geen toggle (PAUSABLE) — de wereld staat ook akoestisch stil.
	toggles.clear()
	_send_action_event(&"pause")
	await _wait_physics_frames(tree, 3)
	_send_action_event(&"flashlight")
	await _wait_physics_frames(tree, 3)
	failures = _check(tree.paused and toggles.is_empty()
		and flashlight.is_light_on(),
		"tijdens pauze geen toggle", failures)
	_send_action_event(&"pause")
	await _wait_physics_frames(tree, 3)

	# Duplicaten: twee exemplaren = één bevoegdheid; één verwijderen trekt
	# niets in (hercontrole aan de bron, nooit blind false).
	inventory.add_item(zaklamp_item)
	inventory.remove_item(&"zaklamp")
	await _wait_physics_frames(tree, 2)
	failures = _check(flashlight.has_flashlight() and flashlight.is_light_on(),
		"één van twee exemplaren weg: bezit en licht blijven", failures)

	# Laatste exemplaar weg terwijl de lamp aan is: direct uit, exact één
	# flashlight_toggled(false), en de klik-kanalen zwijgen (geen actie).
	toggles.clear()
	cues.clear()
	noises.clear()
	inventory.remove_item(&"zaklamp")
	await _wait_physics_frames(tree, 2)
	failures = _check(
		not flashlight.is_light_on() and flashlight.has_flashlight() == false
		and toggles == [false] and cues.is_empty() and noises.is_empty(),
		"laatste exemplaar weg terwijl aan: direct uit, stil, één feit",
		failures)

	# Herspawn (levelwissel-simulatie): voorgevulde inventory wordt bij de
	# initiële synchronisatie gelezen, en er ontstaat geen dubbele
	# verwerking — één toggle blijft één emissie per kanaal.
	inventory.add_item(zaklamp_item)
	var level: Node = tree.root.find_child("DevRoom", true, false)
	flashlight.free()
	var fresh: Node = packed.instantiate()
	level.add_child(fresh)
	await _wait_physics_frames(tree, 2)
	failures = _check(fresh.has_flashlight(),
		"voorgevulde inventory: bezit direct bij spawn (initiële sync)",
		failures)
	toggles.clear()
	cues.clear()
	noises.clear()
	_send_action_event(&"flashlight")
	await _wait_physics_frames(tree, 3)
	failures = _check(
		fresh.is_light_on() and toggles == [true]
		and cues.size() == 1 and noises.size() == 1,
		"na herspawn: exact één verwerking per kanaal (geen dubbele connectie)",
		failures)
	_send_action_event(&"flashlight")
	await _wait_physics_frames(tree, 3)
	inventory.remove_item(&"zaklamp")
	await _wait_physics_frames(tree, 2)
	failures = _check(fresh.has_flashlight() == false,
		"herspawnde zaklamp volgt item_removed correct", failures)

	EventBus.flashlight_toggled.disconnect(toggle_recorder)
	EventBus.audio_cue.disconnect(cue_recorder)
	EventBus.noise_made.disconnect(noise_recorder)
	return failures


## TL-tests (taak 006 §4, keuze E): drie expliciete staten, seed-
## deterministisch flikkerpatroon mét rust, en flikkeren dat correct stopt.
func _check_light_tl(tree: SceneTree, failures: int) -> int:
	var packed: PackedScene = load(LIGHT_TL_SCENE)
	var tl_a: Node3D = packed.instantiate()
	var tl_b: Node3D = packed.instantiate()
	failures = _check(tl_a != null and tl_b != null,
		"TL-prop instantieert los", failures)
	for tl in [tl_a, tl_b]:
		tl.set("state", 2)
		tl.set("flicker_seed", 12345)
		tree.root.add_child(tl)
	var light_a: OmniLight3D = tl_a.find_child("Light", true, false)
	var light_b: OmniLight3D = tl_b.find_child("Light", true, false)
	var energy_on: float = tl_a.get("light_energy_on")

	# Determinisme: zelfde seed → identiek verloop, frame voor frame.
	# 4 s dekt gegarandeerd minstens één burst (rust is max 3,5 s).
	var seq_a := PackedFloat32Array()
	var seq_b := PackedFloat32Array()
	for i in 240:
		await tree.physics_frame
		seq_a.append(light_a.light_energy)
		seq_b.append(light_b.light_energy)
	failures = _check(seq_a == seq_b,
		"flikkerpatroon is seed-deterministisch (%d frames identiek)"
		% seq_a.size(), failures)
	var on_frames := 0
	var dim_frames := 0
	for value in seq_a:
		if value >= energy_on - 0.001:
			on_frames += 1
		else:
			dim_frames += 1
	failures = _check(dim_frames > 0 and on_frames > dim_frames,
		"patroon flikkert én bevat rust (aan overheerst: %d/%d frames)"
		% [on_frames, dim_frames], failures)

	# Flikkeren stopt onmiddellijk en definitief bij een staatwissel.
	tl_a.set("state", 0)
	tl_b.set("state", 1)
	var stable_ok := true
	var defect_ok := true
	for i in 90:
		await tree.physics_frame
		if absf(light_a.light_energy - energy_on) > 0.001:
			stable_ok = false
		if light_b.visible or light_b.light_energy > 0.0:
			defect_ok = false
	failures = _check(stable_ok,
		"STABIEL flikkert nooit (energie 90 frames constant)", failures)
	failures = _check(defect_ok,
		"DEFECT blijft uit en flikkert nooit", failures)
	tl_a.free()
	tl_b.free()
	return failures


## Budgettests (taak 006 §5): configfouten degraderen deterministisch op
## boomvolgorde, de zaklamp houdt haar gereserveerde slot, en de lamp
## zelf blijft aan. De LightBudget-warnings hieronder zijn het bewijs.
func _check_light_budget(tree: SceneTree, failures: int) -> int:
	var budgets := tree.get_nodes_in_group("light_budget")
	failures = _check(budgets.size() == 1,
		"exact één budget-bewaking gespawnd (gevonden: %d)" % budgets.size(),
		failures)
	if budgets.is_empty():
		return failures
	var budget = budgets[0]
	failures = _check(
		budget.get_active_shadow_count() <= budget.get_shadow_budget(),
		"actieve schaduwlichten binnen budget (%d/%d)"
		% [budget.get_active_shadow_count(), budget.get_shadow_budget()],
		failures)

	# Overschrijding forceren: drie extra schaduwlampen achteraan het
	# level. In boomvolgorde winnen de bestaande TL-ankers en de eerste
	# extra; de rest verliest alleen zijn schaduw.
	var level: Node = tree.root.find_child("DevRoom", true, false)
	var extras: Array = []
	for i in 3:
		var extra := OmniLight3D.new()
		extra.shadow_enabled = true
		level.add_child(extra)
		extras.append(extra)
	var enforcer: Node = load(LIGHT_BUDGET_SCENE).instantiate()
	level.add_child(enforcer)
	await _wait_physics_frames(tree, 3)
	failures = _check(
		extras[0].shadow_enabled and not extras[1].shadow_enabled
		and not extras[2].shadow_enabled,
		"boven budget: degradatie is deterministisch op boomvolgorde",
		failures)
	failures = _check(extras[1].visible and extras[1].light_energy > 0.0,
		"gedegradeerde lamp blijft aan (alleen de schaduw vervalt)", failures)
	var anchor: Node = level.find_child("TlStabielWest", true, false)
	var anchor_light: OmniLight3D = anchor.find_child("Light", true, false) \
		if anchor != null else null
	failures = _check(anchor_light != null and anchor_light.shadow_enabled,
		"eerste lampen in boomvolgorde behouden hun schaduw", failures)
	var flashlight = tree.get_first_node_in_group("flashlight")
	if flashlight != null:
		var spot: Light3D = flashlight.find_child("Spot", true, false)
		failures = _check(spot != null and spot.shadow_enabled,
			"zaklamp behoudt haar gereserveerde schaduwslot", failures)
	for extra in extras:
		extra.free()
	enforcer.free()
	return failures


## F3-regels van taak 006: zaklampbezit + aan/uit, schaduwtelling/budget,
## brightnesswaarde en de compacte TL-telling.
func _check_lighting_f3(tree: SceneTree, failures: int) -> int:
	var overlay := tree.root.find_child("DebugOverlay", true, false)
	var info_label: Label = overlay.find_child("InfoLabel", true, false) \
		if overlay != null else null
	if info_label == null:
		return failures
	_send_action_event(&"debug_overlay")
	await _wait_physics_frames(tree, 3)
	failures = _check(
		"zaklamp: bezit nee · uit" in info_label.text
		and "schaduw" in info_label.text
		and "helderheid 1.0" in info_label.text
		and "tl: 2 stabiel / 1 flikkert / 5 defect" in info_label.text,
		"F3 toont zaklamp-, budget-, helderheid- en TL-regel", failures)
	_send_action_event(&"debug_overlay")
	await _wait_physics_frames(tree, 2)
	return failures


## Zet een verse pickup op de vaste testplek in de dev room; instellingen
## via set() — deze suite kent geen proptypes.
func _spawn_test_pickup(props_root: Node, item: Resource) -> Node:
	var packed: PackedScene = load("res://game/props/pickup_item/pickup_item.tscn")
	var pickup: Node3D = packed.instantiate()
	pickup.set("item", item)
	pickup.set("prompt", "Pak sleutel op")
	props_root.add_child(pickup)
	pickup.position = Vector3(3.0, 1.09, -2.0)
	return pickup


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
