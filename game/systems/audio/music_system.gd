extends Node
## Muziek-cues (taak 005, keuze G): de minimale API en niets meer. Geen
## spanningsmodel, geen automatische triggers, geen gameplaymuzieklogica —
## muziek is schaars en verdiend (GAME_BIBLE §4, HORROR §3), en het
## rust/spanning-model is bewust uitgesteld tot er een afnemer is (009+,
## eigen ontwerpbeslissing). In 005 roept uitsluitend de smoke-suite dit
## aan; er bestaat géén muziekcontent.

var _player: AudioStreamPlayer = null
var _current_cue: StringName = &""


## Start een cue met fade-in; een lopende cue wordt eerst vervangen.
func play_cue(sound: Resource, cue_id: StringName, fade_s: float) -> void:
	if sound == null:
		push_warning("Music: onbekende cue '%s'" % cue_id)
		return
	stop_cue(0.0)
	_player = AudioStreamPlayer.new()
	_player.name = "MuziekCue"
	_player.stream = sound.streams[0]
	_player.bus = sound.bus
	_player.volume_db = -60.0
	add_child(_player)
	_player.play()
	create_tween().tween_property(_player, "volume_db", sound.volume_db, fade_s)
	_current_cue = cue_id
	Log.info("Music: cue '%s' gestart" % cue_id)


## Stopt de lopende cue met fade-uit; geen cue = stilte blijft stilte.
func stop_cue(fade_s: float) -> void:
	if _player == null:
		return
	var player := _player
	_player = null
	_current_cue = &""
	if fade_s <= 0.0:
		player.queue_free()
		return
	var tween := create_tween()
	tween.tween_property(player, "volume_db", -60.0, fade_s)
	tween.tween_callback(player.queue_free)


func get_current_cue() -> StringName:
	return _current_cue
