extends Node3D
## Het clubgebouw van VV Drechtstreek (VS-fase C): de eerste echte
## locatie van CRUMP — het clubhuis onder de hoofdtribune, 's nachts, in
## de regenlucht van Sportpark Oostpolder. Greybox: eenvoudige volumes,
## realistische architectuur (LEVEL §6: menselijke maat; §2: leesbaar in
## het donker). Plattegrond volgt tasks/008 §2/§3.
##
## De greybox is bewust DATA (tabellen hieronder, patroon dev_props):
## elke maat is één getal wijzigen — snel itereren op GD-feedback over
## schaal en zichtlijnen. De art-pass (fase G) vervangt deze volumes
## door echte scènes; deuren en TL-armaturen zijn nu al de echte props,
## geplaatst met bestaanscheck (D-015: prop-map weg = level draait door).
##
## Assenstelsel: x+ = oost, z+ = zuid (het veld ligt ten noorden).
## Alle vloeren liggen op y = 0 (geen drempels); wanden zijn 0,2 m dik
## en lopen tot y = 2,9 onder het dak; plafonds per ruimte op hun eigen
## realistische hoogte (kantine 2,7 · hal 2,6 · kleedkamers 2,5 · gang/
## toiletten 2,4 · douches/onderhoud 2,3).

## true = heldere inspectiestand; false (default) = nachtstaat.
@export var werklicht := false

const LIGHT_TL_SCENE := "res://game/props/light_tl/light_tl.tscn"
const DOOR_SCENE := "res://game/props/door_wooden/door_wooden.tscn"

## Grijstinten met nét genoeg hint om functie te lezen — geen textures.
const MATERIALS := {
	&"wand": Color(0.62, 0.62, 0.64),
	&"plafond": Color(0.72, 0.72, 0.74),
	&"beton": Color(0.42, 0.43, 0.45),
	&"beton_donker": Color(0.34, 0.35, 0.37),
	&"vloer_kleed": Color(0.45, 0.42, 0.40),
	&"tegel": Color(0.36, 0.40, 0.46),
	&"verharding": Color(0.38, 0.39, 0.41),
	&"gras": Color(0.22, 0.28, 0.22),
	&"hout": Color(0.45, 0.36, 0.28),
	&"hout_donker": Color(0.33, 0.26, 0.20),
	&"metaal": Color(0.30, 0.32, 0.35),
	&"wit": Color(0.78, 0.79, 0.80),
	&"keramiek": Color(0.75, 0.76, 0.78),
	&"dak": Color(0.30, 0.30, 0.32),
	&"tribune": Color(0.36, 0.37, 0.40),
	&"accent_rood": Color(0.55, 0.16, 0.14),
	&"spiegel": Color(0.25, 0.28, 0.30),
	&"gaas": Color(0.25, 0.27, 0.30, 0.35),
	&"glas": Color(0.55, 0.65, 0.75, 0.22),
}

## Gebouwschil: gevels met deur-/raamopeningen (segmenten + lateien).
## Elke solid: pos (center), size, mat; "nc": true = geen collision.
const SCHIL: Array[Dictionary] = [
	# Zuidgevel (z 7,0..7,2): hoofdentree + hal-raam.
	{"pos": Vector3(-7.855, 1.45, 7.1), "size": Vector3(14.69, 2.9, 0.2), "mat": &"wand"},
	{"pos": Vector3(0.0, 2.51, 7.1), "size": Vector3(1.02, 0.78, 0.2), "mat": &"wand"},
	{"pos": Vector3(0.755, 1.45, 7.1), "size": Vector3(0.49, 2.9, 0.2), "mat": &"wand"},
	{"pos": Vector3(1.45, 0.45, 7.1), "size": Vector3(0.9, 0.9, 0.2), "mat": &"wand"},
	{"pos": Vector3(1.45, 2.55, 7.1), "size": Vector3(0.9, 0.7, 0.2), "mat": &"wand"},
	{"pos": Vector3(7.15, 1.45, 7.1), "size": Vector3(10.5, 2.9, 0.2), "mat": &"wand"},
	{"pos": Vector3(1.45, 1.55, 7.1), "size": Vector3(0.9, 1.3, 0.05), "mat": &"glas"},
	# Noordgevel (z -4,7..-4,5): drie kantineramen op het veld + twee
	# kiepraampjes van de douches.
	{"pos": Vector3(-12.5, 1.45, -4.6), "size": Vector3(5.4, 2.9, 0.2), "mat": &"wand"},
	{"pos": Vector3(-6.5, 1.45, -4.6), "size": Vector3(3.8, 2.9, 0.2), "mat": &"wand"},
	{"pos": Vector3(0.1, 1.45, -4.6), "size": Vector3(6.6, 2.9, 0.2), "mat": &"wand"},
	{"pos": Vector3(-3.9, 0.9, -4.6), "size": Vector3(1.4, 1.8, 0.2), "mat": &"wand"},
	{"pos": Vector3(-3.9, 2.6, -4.6), "size": Vector3(1.4, 0.6, 0.2), "mat": &"wand"},
	{"pos": Vector3(-3.9, 2.05, -4.6), "size": Vector3(1.4, 0.5, 0.05), "mat": &"glas"},
	{"pos": Vector3(-9.1, 0.9, -4.6), "size": Vector3(1.4, 1.8, 0.2), "mat": &"wand"},
	{"pos": Vector3(-9.1, 2.6, -4.6), "size": Vector3(1.4, 0.6, 0.2), "mat": &"wand"},
	{"pos": Vector3(-9.1, 2.05, -4.6), "size": Vector3(1.4, 0.5, 0.05), "mat": &"glas"},
	{"pos": Vector3(5.9, 1.45, -4.6), "size": Vector3(1.0, 2.9, 0.2), "mat": &"wand"},
	{"pos": Vector3(8.9, 1.45, -4.6), "size": Vector3(1.0, 2.9, 0.2), "mat": &"wand"},
	{"pos": Vector3(11.9, 1.45, -4.6), "size": Vector3(1.0, 2.9, 0.2), "mat": &"wand"},
	{"pos": Vector3(4.4, 0.45, -4.6), "size": Vector3(2.0, 0.9, 0.2), "mat": &"wand"},
	{"pos": Vector3(4.4, 2.6, -4.6), "size": Vector3(2.0, 0.6, 0.2), "mat": &"wand"},
	{"pos": Vector3(4.4, 1.6, -4.6), "size": Vector3(2.0, 1.4, 0.05), "mat": &"glas"},
	{"pos": Vector3(7.4, 0.45, -4.6), "size": Vector3(2.0, 0.9, 0.2), "mat": &"wand"},
	{"pos": Vector3(7.4, 2.6, -4.6), "size": Vector3(2.0, 0.6, 0.2), "mat": &"wand"},
	{"pos": Vector3(7.4, 1.6, -4.6), "size": Vector3(2.0, 1.4, 0.05), "mat": &"glas"},
	{"pos": Vector3(10.4, 0.45, -4.6), "size": Vector3(2.0, 0.9, 0.2), "mat": &"wand"},
	{"pos": Vector3(10.4, 2.6, -4.6), "size": Vector3(2.0, 0.6, 0.2), "mat": &"wand"},
	{"pos": Vector3(10.4, 1.6, -4.6), "size": Vector3(2.0, 1.4, 0.05), "mat": &"glas"},
	# Westgevel (x -15,2..-15,0): nooddeur uit de gang.
	{"pos": Vector3(-15.1, 1.45, -0.45), "size": Vector3(0.2, 2.9, 8.5), "mat": &"wand"},
	{"pos": Vector3(-15.1, 2.51, 4.31), "size": Vector3(0.2, 0.78, 1.02), "mat": &"wand"},
	{"pos": Vector3(-15.1, 1.45, 6.01), "size": Vector3(0.2, 2.9, 2.38), "mat": &"wand"},
	# Oostgevel (x 12,2..12,4): terrasdeur (op slot).
	{"pos": Vector3(12.3, 1.45, -4.1), "size": Vector3(0.2, 2.9, 1.2), "mat": &"wand"},
	{"pos": Vector3(12.3, 2.51, -2.99), "size": Vector3(0.2, 0.78, 1.02), "mat": &"wand"},
	{"pos": Vector3(12.3, 1.45, 2.36), "size": Vector3(0.2, 2.9, 9.68), "mat": &"wand"},
]

## Vloeren (top op y = 0) en plafonds per ruimte.
const VLOEREN: Array[Dictionary] = [
	{"pos": Vector3(0.0, -0.1, 4.65), "size": Vector3(4.4, 0.2, 5.1), "mat": &"beton"},
	{"pos": Vector3(7.2, -0.1, -0.5), "size": Vector3(10.4, 0.2, 8.4), "mat": &"beton"},
	{"pos": Vector3(4.1, -0.1, 5.35), "size": Vector3(4.2, 0.2, 3.7), "mat": &"beton"},
	{"pos": Vector3(10.4, -0.1, 5.35), "size": Vector3(4.0, 0.2, 3.7), "mat": &"beton"},
	{"pos": Vector3(-8.6, -0.1, 4.3), "size": Vector3(13.2, 0.2, 2.2), "mat": &"beton"},
	{"pos": Vector3(-4.7, -0.1, 0.95), "size": Vector3(5.0, 0.2, 4.9), "mat": &"vloer_kleed"},
	{"pos": Vector3(-9.3, -0.1, 0.95), "size": Vector3(4.6, 0.2, 4.9), "mat": &"vloer_kleed"},
	{"pos": Vector3(-3.8, -0.1, -3.0), "size": Vector3(3.2, 0.2, 3.4), "mat": &"tegel"},
	{"pos": Vector3(-9.0, -0.1, -3.0), "size": Vector3(3.2, 0.2, 3.4), "mat": &"tegel"},
	{"pos": Vector3(-5.1, -0.1, 6.2), "size": Vector3(3.4, 0.2, 2.0), "mat": &"tegel"},
	{"pos": Vector3(-13.2, -0.1, 1.15), "size": Vector3(3.6, 0.2, 4.5), "mat": &"beton_donker"},
	{"pos": Vector3(-8.0, -0.1, 5.8), "size": Vector3(1.6, 0.2, 1.0), "mat": &"beton"},
]

const PLAFONDS: Array[Dictionary] = [
	{"pos": Vector3(0.0, 2.675, 4.65), "size": Vector3(4.4, 0.15, 5.1), "mat": &"plafond"},
	{"pos": Vector3(7.2, 2.775, -0.5), "size": Vector3(10.4, 0.15, 8.4), "mat": &"plafond"},
	{"pos": Vector3(4.1, 2.475, 5.35), "size": Vector3(4.2, 0.15, 3.7), "mat": &"plafond"},
	{"pos": Vector3(10.4, 2.475, 5.35), "size": Vector3(4.0, 0.15, 3.7), "mat": &"plafond"},
	{"pos": Vector3(-8.6, 2.475, 4.3), "size": Vector3(13.2, 0.15, 2.2), "mat": &"plafond"},
	{"pos": Vector3(-4.7, 2.575, 0.95), "size": Vector3(5.0, 0.15, 4.9), "mat": &"plafond"},
	{"pos": Vector3(-9.3, 2.575, 0.95), "size": Vector3(4.6, 0.15, 4.9), "mat": &"plafond"},
	{"pos": Vector3(-3.8, 2.375, -3.0), "size": Vector3(3.2, 0.15, 3.4), "mat": &"plafond"},
	{"pos": Vector3(-9.0, 2.375, -3.0), "size": Vector3(3.2, 0.15, 3.4), "mat": &"plafond"},
	{"pos": Vector3(-5.1, 2.475, 6.2), "size": Vector3(3.4, 0.15, 2.0), "mat": &"plafond"},
	{"pos": Vector3(-13.2, 2.375, 1.15), "size": Vector3(3.6, 0.15, 4.5), "mat": &"plafond"},
	# Dak + tribune-silhouet erboven (het gebouw zit ónder de tribune).
	{"pos": Vector3(-1.4, 3.0, 1.25), "size": Vector3(28.0, 0.2, 12.3), "mat": &"dak"},
	{"pos": Vector3(-1.4, 3.55, 5.0), "size": Vector3(28.0, 0.9, 4.8), "mat": &"tribune"},
	{"pos": Vector3(-1.4, 4.45, 5.8), "size": Vector3(28.0, 0.9, 3.2), "mat": &"tribune"},
	{"pos": Vector3(-1.4, 5.35, 6.6), "size": Vector3(28.0, 0.9, 1.6), "mat": &"tribune"},
]

## Buitenwereld: voorplein, pad langs het veld, hekwerk, veld en mast.
const BUITEN: Array[Dictionary] = [
	# Verharding en gras (alles top y = 0, geen drempels).
	{"pos": Vector3(-5.8, -0.1, 10.6), "size": Vector3(23.6, 0.2, 6.8), "mat": &"verharding"},
	{"pos": Vector3(-16.4, -0.1, 1.25), "size": Vector3(2.4, 0.2, 11.9), "mat": &"verharding"},
	{"pos": Vector3(-2.55, -0.1, -5.8), "size": Vector3(30.1, 0.2, 2.2), "mat": &"verharding"},
	{"pos": Vector3(-2.5, -0.1, -25.95), "size": Vector3(55.0, 0.2, 38.1), "mat": &"gras"},
	{"pos": Vector3(9.2, -0.1, 10.6), "size": Vector3(6.4, 0.2, 6.8), "mat": &"gras"},
	# Entree: luifel op twee staanders + lampfitting.
	{"pos": Vector3(0.0, 2.53, 7.85), "size": Vector3(3.2, 0.15, 1.3), "mat": &"dak"},
	{"pos": Vector3(-1.45, 1.225, 8.42), "size": Vector3(0.12, 2.45, 0.12), "mat": &"metaal"},
	{"pos": Vector3(1.45, 1.225, 8.42), "size": Vector3(0.12, 2.45, 0.12), "mat": &"metaal"},
	{"pos": Vector3(0.0, 2.32, 7.14), "size": Vector3(0.3, 0.12, 0.12), "mat": &"metaal", "nc": true},
	# Fietsenrek op het voorplein.
	{"pos": Vector3(4.5, 0.4, 12.28), "size": Vector3(2.2, 0.8, 0.14), "mat": &"metaal"},
	{"pos": Vector3(4.5, 0.4, 12.62), "size": Vector3(2.2, 0.8, 0.14), "mat": &"metaal"},
	# Hekwerk (gaas-suggestie): zuid met poort + ketting, oost, west.
	{"pos": Vector3(-9.4, 0.95, 13.95), "size": Vector3(16.4, 1.7, 0.1), "mat": &"gaas"},
	{"pos": Vector3(3.6, 0.95, 13.95), "size": Vector3(4.8, 1.7, 0.1), "mat": &"gaas"},
	{"pos": Vector3(0.0, 0.95, 13.95), "size": Vector3(2.4, 1.7, 0.1), "mat": &"gaas"},
	{"pos": Vector3(0.0, 1.15, 13.94), "size": Vector3(1.0, 0.12, 0.24), "mat": &"metaal", "nc": true},
	{"pos": Vector3(-17.6, 1.0, 13.95), "size": Vector3(0.1, 2.0, 0.1), "mat": &"metaal"},
	{"pos": Vector3(-9.4, 1.0, 13.95), "size": Vector3(0.1, 2.0, 0.1), "mat": &"metaal"},
	{"pos": Vector3(-1.2, 1.0, 13.95), "size": Vector3(0.1, 2.0, 0.1), "mat": &"metaal"},
	{"pos": Vector3(1.2, 1.0, 13.95), "size": Vector3(0.1, 2.0, 0.1), "mat": &"metaal"},
	{"pos": Vector3(6.0, 1.0, 13.95), "size": Vector3(0.1, 2.0, 0.1), "mat": &"metaal"},
	{"pos": Vector3(5.95, 0.95, 10.65), "size": Vector3(0.1, 1.7, 6.5), "mat": &"gaas"},
	{"pos": Vector3(5.95, 1.0, 7.5), "size": Vector3(0.1, 2.0, 0.1), "mat": &"metaal"},
	{"pos": Vector3(-17.65, 0.95, 3.5), "size": Vector3(0.1, 1.7, 20.8), "mat": &"gaas"},
	{"pos": Vector3(-17.65, 1.0, -6.8), "size": Vector3(0.1, 2.0, 0.1), "mat": &"metaal"},
	{"pos": Vector3(-17.65, 1.0, 3.5), "size": Vector3(0.1, 2.0, 0.1), "mat": &"metaal"},
	{"pos": Vector3(12.45, 0.95, -5.8), "size": Vector3(0.1, 1.7, 2.2), "mat": &"gaas"},
	# Boarding langs het veld (lage witte reclameborden-band).
	{"pos": Vector3(-2.55, 0.5, -6.95), "size": Vector3(30.1, 1.0, 0.1), "mat": &"wit"},
	# Lichtmast 3 (paal + arm + kop; de spot hangt eraan in de scène).
	{"pos": Vector3(-16.6, 5.5, -6.3), "size": Vector3(0.25, 11.0, 0.25), "mat": &"metaal"},
	{"pos": Vector3(-16.6, 10.6, -6.9), "size": Vector3(0.2, 0.2, 1.4), "mat": &"metaal"},
	{"pos": Vector3(-16.6, 10.5, -7.6), "size": Vector3(0.5, 0.3, 0.6), "mat": &"metaal"},
	# Eén doel op het veld — verdwijnt half in de fog: silhouet, geen decor.
	{"pos": Vector3(-3.66, 1.22, -24.0), "size": Vector3(0.1, 2.44, 0.1), "mat": &"wit"},
	{"pos": Vector3(3.66, 1.22, -24.0), "size": Vector3(0.1, 2.44, 0.1), "mat": &"wit"},
	{"pos": Vector3(0.0, 2.49, -24.0), "size": Vector3(7.42, 0.1, 0.1), "mat": &"wit"},
]

## Binnenwanden — gevuld in bouwblok 2.
const INTERIEUR: Array[Dictionary] = []

## Meubel- en herkenningsvolumes — gevuld in bouwblok 2.
const MEUBELS: Array[Dictionary] = []

## Deuren (echte props, bestaanscheck) — gevuld in bouwblok 3.
const DEUREN: Array[Dictionary] = []

## TL-armaturen (echte props, bestaanscheck) — gevuld in bouwblok 3.
const NIGHT_TLS: Array[Dictionary] = []

var _materials := {}
var _unit_mesh: BoxMesh

@onready var _greybox: Node3D = $Greybox
@onready var _werklicht_rig: Node3D = %Werklicht
@onready var _night_lights: Node3D = %NightLights


func _ready() -> void:
	_unit_mesh = BoxMesh.new()
	for table in [SCHIL, VLOEREN, PLAFONDS, BUITEN, INTERIEUR, MEUBELS]:
		for solid in table:
			_build_solid(solid)
	_place_doors()
	_place_night_tls()
	_werklicht_rig.visible = werklicht
	_night_lights.visible = not werklicht
	if werklicht:
		Log.warn("Clubgebouw: werklicht AAN — alleen voor inspectie, nooit committen")
	_activate_ambience()
	Log.info("Clubgebouw: greybox opgebouwd (%d volumes)" % _greybox.get_child_count())


## Eén volume = StaticBody + geschaalde unit-mesh + eigen BoxShape
## (nooit een geschaalde collider). "nc" = decoratief, geen collision.
func _build_solid(solid: Dictionary) -> void:
	var size: Vector3 = solid["size"]
	var body := StaticBody3D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	var mesh := MeshInstance3D.new()
	mesh.mesh = _unit_mesh
	mesh.scale = size
	mesh.material_override = _material(solid["mat"])
	body.add_child(mesh)
	if not solid.get("nc", false):
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = size
		shape.shape = box
		body.add_child(shape)
	_greybox.add_child(body)
	body.position = solid["pos"]


func _material(key: StringName) -> StandardMaterial3D:
	if not _materials.has(key):
		var material := StandardMaterial3D.new()
		var color: Color = MATERIALS[key]
		material.albedo_color = color
		material.roughness = 0.9
		if color.a < 1.0:
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_materials[key] = material
	return _materials[key]


## Deuren zijn de echte interactie-props, als data geplaatst met
## bestaanscheck (D-015). De root van de prop is de scharnierzijde; het
## paneel loopt lokaal +x (1,0 m breed).
func _place_doors() -> void:
	if not ResourceLoader.exists(DOOR_SCENE):
		Log.info("Clubgebouw: deur-prop afwezig — openingen blijven open (D-015)")
		return
	var packed: PackedScene = load(DOOR_SCENE)
	for door in DEUREN:
		var node: Node3D = packed.instantiate()
		node.name = door["name"]
		for key in door.get("settings", {}):
			node.set(key, door["settings"][key])
		add_child(node)
		node.position = door["pos"]
		node.rotation_degrees.y = door.get("rot", 0.0)
	if not DEUREN.is_empty():
		Log.info("Clubgebouw: %d deuren geplaatst" % DEUREN.size())


## TL-armaturen: zelfde patroon als de dev room (state 1 = DEFECT,
## 2 = FLIKKEREND); weinig werkend licht is het punt (kader 006).
func _place_night_tls() -> void:
	if not ResourceLoader.exists(LIGHT_TL_SCENE):
		Log.info("Clubgebouw: TL-prop afwezig — nachtstaat zonder armaturen (D-015)")
		return
	var packed: PackedScene = load(LIGHT_TL_SCENE)
	for tl in NIGHT_TLS:
		var node: Node3D = packed.instantiate()
		node.name = tl["name"]
		for key in tl.get("settings", {}):
			node.set(key, tl["settings"][key])
		_night_lights.add_child(node)
		node.position = tl["pos"]
	if not NIGHT_TLS.is_empty():
		Log.info("Clubgebouw: %d TL-armaturen geplaatst" % NIGHT_TLS.size())


## Het stilte-nulpunt van het gebouw (005): koeling/tl-zoem. Null-veilig
## en duck-typed — zonder audiosysteem gebeurt er niets (D-015).
func _activate_ambience() -> void:
	var audio := get_tree().get_first_node_in_group("audio_system")
	if audio == null or not audio.has_method("set_ambience_layer"):
		return
	audio.set_ambience_layer(&"amb_hum_koeling", true, 1.5)
