extends Node
## Bootstrap — startpunt en lifecycle-eigenaar van CRUMP.
## Verifieert autoloads, laadt het actieve level onder %SceneHost en bezit
## de nette afsluiting. Ontworpen zodat later een hoofdmenu tussen opstarten
## en spel geschoven kan worden zonder verbouwing (taakdossier 001, blok C).

## Het level dat de bootstrap tijdens ontwikkeling laadt (de developer room).
const DEV_ROOM_SCENE := "res://game/levels/dev_room/dev_room.tscn"

## Autoloads die aanwezig moeten zijn vóór het spel verder mag.
const REQUIRED_AUTOLOADS: Array[String] = [
	"EventBus", "GameState", "AudioDirector", "SaveManager",
]

var _current_level: Node = null

@onready var _scene_host: Node = %SceneHost


func _ready() -> void:
	# Bootstrap blijft actief tijdens pauze: hij bedient pauze/afsluiten zelf.
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Afsluiten loopt via shutdown() zodat er één nette uitgang bestaat.
	get_tree().auto_accept_quit = false
	Log.info("CRUMP %s gestart · Godot %s · debug=%s" % [
		str(ProjectSettings.get_setting("application/config/version", "?")),
		Engine.get_version_info().string,
		str(OS.is_debug_build()),
	])
	_verify_autoloads()
	_load_level(DEV_ROOM_SCENE)


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


## De enige nette uitgang van het spel.
func shutdown(exit_code: int = 0) -> void:
	Log.info("CRUMP sluit af (code %d)" % exit_code)
	get_tree().quit(exit_code)
