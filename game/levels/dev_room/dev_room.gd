extends Node3D
## Developer room (taak 006, keuze G): de nachtstaat is de gecommitte
## standaard — bijna zwart, schaarse TL-ankers, diepte-fog. Het werklicht
## is een expliciete editor-/debugoptie voor geometrie- en
## systeeminspectie: debug, geen gameplay, en nooit aan in een commit
## (de suite bewaakt dat).

## true = de oude heldere testverlichting (inspectie); false = nachtstaat.
@export var werklicht := false

## De TL-prop wordt als data geplaatst (patroon dev_props, ARCHITECTURE
## §4a.6) en nooit hard in de scène verwezen: verwijder je de prop-map,
## dan blijft dit level parsebaar en draait de rest door (D-015).
const LIGHT_TL_SCENE := "res://game/props/light_tl/light_tl.tscn"

## Nachtstaat: 2 stabiele ankers (mét schaduw — level-budget is 3, §5),
## 1 bewust flikkerende buis in de noordoosthoek, rest defect. Weinig
## werkend licht is het punt (keuze E); state 1 = DEFECT, 2 = FLIKKEREND.
const NIGHT_TLS: Array[Dictionary] = [
	{"name": "TlStabielWest", "position": Vector3(-5.0, 2.85, -5.0),
		"settings": {"cast_shadow": true}},
	{"name": "TlStabielOost", "position": Vector3(4.0, 2.85, 3.0),
		"settings": {"cast_shadow": true}},
	{"name": "TlFlikkerNoordoost", "position": Vector3(7.0, 2.85, -7.0),
		"settings": {"state": 2, "flicker_seed": 7}},
	{"name": "TlDefectA", "position": Vector3(-7.0, 2.85, 4.0),
		"settings": {"state": 1}},
	{"name": "TlDefectB", "position": Vector3(0.0, 2.85, 0.0),
		"settings": {"state": 1}},
	{"name": "TlDefectC", "position": Vector3(0.0, 2.85, -7.0),
		"settings": {"state": 1}},
	{"name": "TlDefectD", "position": Vector3(6.0, 2.85, -2.0),
		"settings": {"state": 1}},
	{"name": "TlDefectE", "position": Vector3(-2.0, 2.85, 7.0),
		"settings": {"state": 1}},
]

@onready var _werklicht_rig: Node3D = %Werklicht
@onready var _night_lights: Node3D = %NightLights


func _ready() -> void:
	_werklicht_rig.visible = werklicht
	_night_lights.visible = not werklicht
	_place_night_lights()
	if werklicht:
		Log.warn("DevRoom: werklicht AAN — alleen voor inspectie, nooit committen")


func _place_night_lights() -> void:
	if not ResourceLoader.exists(LIGHT_TL_SCENE):
		Log.info("DevRoom: TL-prop afwezig — nachtstaat zonder armaturen (D-015)")
		return
	var packed: PackedScene = load(LIGHT_TL_SCENE)
	for tl in NIGHT_TLS:
		var node: Node3D = packed.instantiate()
		node.name = tl["name"]
		for key in tl.get("settings", {}):
			node.set(key, tl["settings"][key])
		_night_lights.add_child(node)
		node.position = tl["position"]
	Log.info("DevRoom: %d TL-armaturen geplaatst" % NIGHT_TLS.size())
