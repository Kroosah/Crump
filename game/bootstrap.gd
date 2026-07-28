extends Node
## Bootstrap — startpunt en lifecycle-eigenaar van CRUMP.
## Verifieert autoloads, laadt het actieve level onder %SceneHost en bezit
## de nette afsluiting. Ontworpen zodat later een hoofdmenu tussen opstarten
## en spel geschoven kan worden zonder verbouwing (taakdossier 001, blok C).

## Het level dat de bootstrap tijdens ontwikkeling laadt (de developer room).
const DEV_ROOM_SCENE := "res://game/levels/dev_room/dev_room.tscn"

## De spelerscène. Bewust een pad + bestaanscheck, geen preload: verwijder je
## game/actors/player/, dan draait de rest gewoon door (D-015/D-018).
const PLAYER_SCENE := "res://game/actors/player/player.tscn"

## Het interactiesysteem, zelfde patroon: bestaat de scène niet, dan speelt
## het spel zonder interactie verder (D-015).
const INTERACTOR_SCENE := "res://game/systems/interaction/interactor.tscn"

## Het inventory-systeem (taak 004), zelfde patroon. Eénmalig gespawnd als
## kind van de SceneHost: overleeft levelwissels en pauzeert mee (KI-003).
const INVENTORY_SCENE := "res://game/systems/inventory/inventory.tscn"

## Overlay bestaat alleen in debugbuilds (zie _add_debug_tools).
const DEBUG_OVERLAY_SCENE := "res://game/ui/debug_overlay/debug_overlay.tscn"

## Tijdelijke debug-prompt: toont de interactieprompt tot de echte HUD er is
## (TD-006). Alleen debugbuilds; bestaanscheck zodat de map weg kan (D-015).
const DEBUG_PROMPT_SCENE := "res://game/ui/debug_prompt/debug_prompt.tscn"

## Autoloads die aanwezig moeten zijn vóór het spel verder mag.
const REQUIRED_AUTOLOADS: Array[String] = [
	"EventBus", "GameState", "AudioDirector", "SettingsManager", "SaveManager",
]

var _current_level: Node = null

@onready var _scene_host: Node = %SceneHost


func _ready() -> void:
	# Bootstrap blijft actief tijdens pauze: hij bedient pauze/afsluiten zelf.
	process_mode = Node.PROCESS_MODE_ALWAYS
	# ALWAYS erft door naar kinderen — zonder expliciet PAUSABLE op de
	# SceneHost zou de hele spelwereld tijdens de pauze gewoon doordraaien
	# en leek Esc niets te doen (KI-003). De debug overlay blijft bewust
	# wél ALWAYS: die moet ook tijdens een pauze bruikbaar zijn.
	_scene_host.process_mode = Node.PROCESS_MODE_PAUSABLE
	# Afsluiten loopt via shutdown() zodat er één nette uitgang bestaat.
	get_tree().auto_accept_quit = false
	Log.info("CRUMP %s gestart · Godot %s · debug=%s" % [
		str(ProjectSettings.get_setting("application/config/version", "?")),
		Engine.get_version_info().string,
		str(OS.is_debug_build()),
	])
	_verify_autoloads()
	_add_debug_tools()
	_spawn_inventory()
	_load_level(DEV_ROOM_SCENE)
	if "--smoke-test" in OS.get_cmdline_user_args():
		_run_smoke_test.call_deferred()


## Naam van het geladen level (gebruikt door de debug overlay).
func get_current_level_name() -> String:
	return _current_level.name if _current_level != null else "geen"


## Debug-gereedschap alleen in debugbuilds: in een release bestaat het niet.
func _add_debug_tools() -> void:
	if not OS.is_debug_build():
		return
	var overlay: Node = load(DEBUG_OVERLAY_SCENE).instantiate()
	add_child(overlay)
	if ResourceLoader.exists(DEBUG_PROMPT_SCENE):
		var prompt: Node = load(DEBUG_PROMPT_SCENE).instantiate()
		add_child(prompt)


## Laadt een level onder de SceneHost; ruimt het vorige level op.
func _load_level(scene_path: String) -> void:
	if not ResourceLoader.exists(scene_path):
		Log.error("Bootstrap: scène bestaat niet: %s" % scene_path)
		return
	if _current_level != null:
		_current_level.queue_free()
		_current_level = null
	var packed: PackedScene = load(scene_path)
	_current_level = packed.instantiate()
	_scene_host.add_child(_current_level)
	Log.info("Bootstrap: level geladen: %s" % scene_path)
	_spawn_player()
	_spawn_interactor()


## Zet de speler op het PlayerSpawn-punt van het geladen level (D-018).
## Ontbreekt de spelerscène of het spawnpunt, dan draait het level zonder
## speler verder — de testcamera van de dev room springt dan bij (D-016).
func _spawn_player() -> void:
	if not ResourceLoader.exists(PLAYER_SCENE):
		Log.info("Bootstrap: geen spelerscène — level draait zonder speler")
		return
	var marker: Node3D = _current_level.find_child("PlayerSpawn", true, false)
	if marker == null:
		Log.info("Bootstrap: level heeft geen PlayerSpawn — geen speler geplaatst")
		return
	var player: Node3D = load(PLAYER_SCENE).instantiate()
	# Kind van het level: bij een level-wissel ruimt queue_free hem mee op.
	_current_level.add_child(player)
	player.global_transform = marker.global_transform
	Log.info("Bootstrap: speler geplaatst op %s"
		% str(marker.global_position.round()))


## Voegt het interactiesysteem toe aan het geladen level (taak 003). Kind
## van het level: pauzeert mee (KI-003) en wordt bij een levelwissel mee
## opgeruimd. De interactor gebruikt de actieve camera — hij werkt dus ook
## zonder speler en heeft geen enkele kennis van het level.
## Spawnt de inventory éénmalig (taak 004): in _ready, niet per level, en
## alleen als er nog geen bestaat — maximaal één autoritatieve inventory
## (dossier 004 §2). Kind van de SceneHost: levelwissels raken hem niet.
func _spawn_inventory() -> void:
	if not ResourceLoader.exists(INVENTORY_SCENE):
		Log.info("Bootstrap: geen inventory-systeem — spel draait zonder inventory")
		return
	if not get_tree().get_nodes_in_group("inventory").is_empty():
		push_warning("Bootstrap: er is al een inventory — tweede spawn overgeslagen")
		return
	var inventory: Node = load(INVENTORY_SCENE).instantiate()
	_scene_host.add_child(inventory)
	Log.info("Bootstrap: inventory actief")


func _spawn_interactor() -> void:
	if not ResourceLoader.exists(INTERACTOR_SCENE):
		Log.info("Bootstrap: geen interactiesysteem — level draait zonder interactie")
		return
	var interactor: Node = load(INTERACTOR_SCENE).instantiate()
	_current_level.add_child(interactor)
	Log.info("Bootstrap: interactor actief")


func _verify_autoloads() -> void:
	for autoload_name in REQUIRED_AUTOLOADS:
		if get_node_or_null("/root/" + autoload_name) == null:
			Log.error("Bootstrap: verplichte autoload '%s' ontbreekt" % autoload_name)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_toggle_pause()


func _toggle_pause() -> void:
	var tree := get_tree()
	tree.paused = not tree.paused
	Log.info("Bootstrap: pauze %s" % ("aan" if tree.paused else "uit"))


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		shutdown()


## Draait de smoke-suite en sluit af met de uitslag als exitcode (CI-bruikbaar).
func _run_smoke_test() -> void:
	# Instantie i.p.v. statische aanroep: de suite awaits physics-frames
	# voor de bewegings- en voetstaptests van de speler (taak 002).
	var suite: RefCounted = load("res://tests/smoke_test.gd").new()
	var failures: int = await suite.run(self)
	if failures == 0:
		Log.info("Smoke-test: alle controles groen")
	else:
		Log.error("Smoke-test: %d controle(s) gefaald" % failures)
	shutdown(0 if failures == 0 else 1)


## De enige nette uitgang van het spel.
func shutdown(exit_code: int = 0) -> void:
	Log.info("CRUMP sluit af (code %d)" % exit_code)
	get_tree().quit(exit_code)
