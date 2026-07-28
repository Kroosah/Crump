extends Node3D
## Het zaklampsysteem (taak 006): een verwijderbaar, camera-volgend systeem
## met betrouwbare bediening — de zaklamp hapert nooit willekeurig
## (HORROR §7; falen zou ooit een ontworpen gebeurtenis zijn, geen ruis).
##
## Alleen dít component bezit de aan/uit-state. Een geslaagde toggle zendt
## drie gescheiden feiten (dossier 006 keuze C): flashlight_toggled
## (toestand, voor CRUMP's zicht in 009), audio_cue (de hoorbare klik) en
## noise_made (de klik als gameplaygeluid). Zonder aantoonbaar bezit faalt
## alles gesloten: geen state, geen licht, geen enkele emissie (keuze D).
##
## Kent geen enkel ander gameplay-systeem: bezit is een duck-typed projectie
## van de inventory via de groep, en de posities komen van de actieve camera
## (licht) en de groep `player` (geluid) — nooit andersom (§3a).

## Het item-id dat bezit aantoont; het ItemResource bestaat sinds taak 004.
const FLASHLIGHT_ITEM_ID := &"zaklamp"

@export_group("Beam")
## Realistische bundel (dossier 006 keuze B): warm, ~35 graden, ~12 m.
@export var beam_angle_deg := 35.0
@export var beam_range_m := 12.0
@export var beam_energy := 4.0
@export var beam_color := Color(1.0, 0.93, 0.82)
## Zachte bundelrand; hoger = snellere afval naar de rand.
@export var spot_attenuation := 1.2

@export_group("Follow")
## Volgsnelheid richting de actieve camera (per seconde): de kleine
## na-ijling geeft het handheld-gevoel van een echte lamp (keuze A).
@export var follow_speed := 14.0

@export_group("Cost")
## De hoorbare klik (doel: informatie, kader 005 §8).
@export var click_cue: StringName = &"flashlight_click"
## Draagafstand van de klik in meters op noise_made — fluister-orde
## (HORROR §3): de prijs is leerbaar, niet verlammend.
@export var click_loudness := 2.0

@export_group("Debug")
## Omzeilt de bezit-gate voor geïsoleerde lichttests, ALLEEN werkzaam in
## debugbuilds. Standaard uit en nooit aan in gecommitte scènes — de dev
## room gebruikt de echte pickup-flow (dossier 006 keuze D).
@export var debug_bezit_bypass := false

var _is_on := false
var _has_flashlight := false

@onready var _spot: SpotLight3D = %Spot


func _ready() -> void:
	_spot.spot_angle = beam_angle_deg
	_spot.spot_range = beam_range_m
	_spot.light_energy = beam_energy
	_spot.light_color = beam_color
	_spot.spot_attenuation = spot_attenuation
	_spot.visible = false
	# Initiële bezitssynchronisatie: de bootstrapvolgorde garandeert dat de
	# inventory (SceneHost-kind, gespawnd vóór het level) al bestaat — dit
	# is de ene expliciete leesstap; daarna is alles eventgedreven.
	_has_flashlight = _possession_from_inventory()
	EventBus.item_added.connect(_on_item_event)
	EventBus.item_removed.connect(_on_item_event)
	_snap_to_camera()
	Log.info("Flashlight: actief (bezit %s)" % ("ja" if _has_flashlight else "nee"))


func _exit_tree() -> void:
	# Symmetrisch met _ready: een levelwissel laat nooit een tweede,
	# zwevende connectie achter (dossier 006 keuze D).
	if EventBus.item_added.is_connected(_on_item_event):
		EventBus.item_added.disconnect(_on_item_event)
	if EventBus.item_removed.is_connected(_on_item_event):
		EventBus.item_removed.disconnect(_on_item_event)


func _process(delta: float) -> void:
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return
	# Na-ijlend volgen: exponentieel richting de cameratransform. De lamp
	# hoort bij het kijken (D-020) — welke camera dat is, boeit hem niet.
	var weight := clampf(follow_speed * delta, 0.0, 1.0)
	global_position = global_position.lerp(camera.global_position, weight)
	global_basis = Basis(Quaternion(global_basis).slerp(
		Quaternion(camera.global_basis), weight))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("flashlight"):
		_try_toggle()


## Leesvensters voor de F3-overlay (duck-typed via de groep `flashlight`).
func has_flashlight() -> bool:
	return _has_flashlight


func is_light_on() -> bool:
	return _is_on


func _try_toggle() -> void:
	# Volgorde is het contract (dossier 006 keuze C): eerst geldigheid en
	# bezit — gesloten falen betekent nul gevolgen op álle kanalen — dan
	# de echte statewijziging, dan exact één emissie per kanaal.
	if not _has_flashlight and not _bypass_active():
		return
	_set_light(not _is_on)
	EventBus.flashlight_toggled.emit(_is_on)
	# De klik-kanalen gebruiken de semantische spelerpositie (body-origin,
	# zelfde bron als voetstappen): camerahoogte en headbob mogen de latere
	# AI-waarneming nooit vervormen (§3a). Geen speler = geen subject dat
	# klikt — dan zwijgen alleen deze twee kanalen.
	var player := get_tree().get_first_node_in_group("player")
	if player is Node3D:
		EventBus.audio_cue.emit(click_cue, player.global_position)
		EventBus.noise_made.emit(player.global_position, click_loudness)


func _bypass_active() -> bool:
	return debug_bezit_bypass and OS.is_debug_build()


func _set_light(is_on: bool) -> void:
	_is_on = is_on
	_spot.visible = is_on


func _on_item_event(item: Resource) -> void:
	# Beide busfeiten (item_added/item_removed) komen hier samen. Niet
	# blind de vlag zetten maar herleiden uit de bron: twee zaklampitems
	# zijn één bevoegdheid, en één exemplaar verwijderen trekt niets in
	# zolang er nog een tweede is (dossier 006 keuze D).
	if item == null or item.get("id") != FLASHLIGHT_ITEM_ID:
		return
	_has_flashlight = _possession_from_inventory()
	if _is_on and not _has_flashlight and not _bypass_active():
		# Laatste exemplaar weg terwijl de lamp aan is: direct en
		# betrouwbaar uit. Het toestandfeit volgt de werkelijkheid, maar
		# de klik-kanalen zwijgen — dit is geen spelershandeling.
		_set_light(false)
		EventBus.flashlight_toggled.emit(false)


func _possession_from_inventory() -> bool:
	# Gesloten falen (dossier 006 keuze D): geen inventory-systeem of geen
	# item = geen bezit. Een ontbrekend systeem levert nooit gratis bezit.
	var inventory := get_tree().get_first_node_in_group("inventory")
	if inventory == null or not inventory.has_method("has_item"):
		return false
	return inventory.has_item(FLASHLIGHT_ITEM_ID)


func _snap_to_camera() -> void:
	var camera := get_viewport().get_camera_3d()
	if camera != null:
		global_transform = camera.global_transform
