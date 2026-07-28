extends Node
## Het audiosysteem van CRUMP (taak 005): de enige plek waar semantische
## audio-events hoorbaar worden. Bezit de volledige
## AudioStreamPlayer-lifecycle (kader §4) via drie gescheiden
## verantwoordelijkheden als kinderen: OneShots, Ambience en Music.
##
## Dit script zelf is de façade + de centrale cue-resolver (kwaliteitseis
## GD: één registry, geen verspreide match-statements). AudioDirector
## blijft de dunne mixer; dit systeem praat nooit rechtstreeks met
## audiobussen — hij zet alleen busnamen op players.
##
## Eén autoritatieve instantie (zelfde patroon als de inventory): alleen
## de eerste node in groep `audio_system` verbindt zich met de bus.
## Verwijder deze map en het spel wordt stil maar draait (D-015).

## De canonieke vindplaats van alle SoundResources; de mapscan is de
## registry (keuze D — geen tweede administratie).
const SOUNDS_DIR := "res://game/systems/audio/sounds"

var _sounds: Dictionary = {}
var _authoritative := false

@onready var _one_shots: Node = %OneShots
@onready var _ambience: Node = %Ambience
@onready var _music: Node = %Music


func _ready() -> void:
	_load_sounds()
	if get_tree().get_nodes_in_group("audio_system")[0] != self:
		push_warning("AudioSystem: tweede instantie genegeerd — niet met de bus verbonden")
		return
	_authoritative = true
	EventBus.audio_cue.connect(_on_audio_cue)
	Log.info("AudioSystem: actief (%d geluiden geregistreerd)" % _sounds.size())


func _exit_tree() -> void:
	# Symmetrisch met _ready.
	if _authoritative:
		EventBus.audio_cue.disconnect(_on_audio_cue)
		_authoritative = false


## Centrale resolutie van id → SoundResource; null bij onbekend id.
func resolve(sound_id: StringName) -> Resource:
	return _sounds.get(sound_id)


## Ambience-façade (levels roepen dit null-veilig aan via de groep).
func set_ambience_layer(layer_id: StringName, active: bool, fade_s: float = 1.0) -> void:
	_ambience.set_layer(resolve(layer_id), layer_id, active, fade_s)


func get_active_ambience() -> Array[StringName]:
	return _ambience.get_active_layers()


## Muziek-façade (minimale API, niets triggert dit automatisch — keuze G).
func play_music_cue(cue_id: StringName, fade_s: float = 2.0) -> void:
	_music.play_cue(resolve(cue_id), cue_id, fade_s)


func stop_music_cue(fade_s: float = 2.0) -> void:
	_music.stop_cue(fade_s)


## Voor de F3-overlay (debug): nu spelende one-shots + actieve lagen.
func get_active_one_shots() -> Array[StringName]:
	return _one_shots.get_active()


func get_pool_status() -> String:
	return _one_shots.get_pool_status()


func _on_audio_cue(sound_id: StringName, position: Vector3) -> void:
	var sound: Resource = resolve(sound_id)
	if sound == null:
		# Veilig falen (kwaliteitseis 1): luid in de log, stil in de wereld,
		# en er wordt géén player geclaimd.
		push_warning("AudioSystem: onbekende cue-id '%s'" % sound_id)
		return
	_one_shots.play(sound, position)


func _load_sounds() -> void:
	for file in DirAccess.get_files_at(SOUNDS_DIR):
		if not file.ends_with(".tres"):
			continue
		var sound: Resource = load(SOUNDS_DIR + "/" + file)
		if sound == null or not sound is SoundResource \
				or sound.id == &"" or sound.streams.is_empty():
			push_warning("AudioSystem: ongeldige geluidsdefinitie: %s" % file)
			continue
		if _sounds.has(sound.id):
			# Configuratiefout (dossier §3); de suite vangt dit ook af.
			push_warning("AudioSystem: dubbele cue-id '%s' (%s genegeerd)"
				% [sound.id, file])
			continue
		_sounds[sound.id] = sound
