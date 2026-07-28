extends Node
## One-shot-afspeler (taak 005, keuze E): vaste pool players, eigendom van
## het audiosysteem — een verdwijnende bronprop kapt per constructie niets
## af (kader §6). Positionele cues spelen op de exacte event-positie via
## AudioStreamPlayer3D; niet-positionele cues via een gewone
## AudioStreamPlayer — nooit op een verzonnen 3D-plek (kwaliteitseis 3).
##
## Deterministisch bij uitputting: de langstspelende wordt gestolen
## (debug-log), nooit verborgen bijgespawnd. Na afloop wordt een player
## volledig gereset en hergebruikt.

@export_group("Pool")
## Aantal 3D-players; begrensd geheugen én een bewuste bovengrens aan
## gelijktijdig lawaai (P2/P4).
@export var pool_size_3d := 12
## Aantal niet-positionele players (stingers/2D — nu alleen voor tests).
@export var pool_size_flat := 4

## Per player: start-tick van de huidige claim (0 = vrij) en de cue-id.
var _claims: Dictionary = {}
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	for i in pool_size_3d:
		_maak_player(AudioStreamPlayer3D.new(), "OneShot3D_%d" % i)
	for i in pool_size_flat:
		_maak_player(AudioStreamPlayer.new(), "OneShotFlat_%d" % i)


## Speelt één cue op precies één player (kwaliteitseis 2). `sound` is een
## gevalideerde SoundResource (de resolver van de façade garandeert dat).
func play(sound: Resource, position: Vector3) -> void:
	var player: Node = _claim_player(sound.positional)
	if player == null:
		return
	player.stream = sound.streams[_rng.randi_range(0, sound.streams.size() - 1)]
	player.volume_db = sound.volume_db
	player.pitch_scale = 1.0 + _rng.randf_range(-sound.pitch_spread,
		sound.pitch_spread)
	player.bus = sound.bus
	if player is AudioStreamPlayer3D:
		player.global_position = position
		player.max_distance = sound.max_distance
	_claims[player] = {
		"sinds": Time.get_ticks_msec(),
		"id": sound.id,
	}
	player.play()


## Stopt en reset alle players (ook bruikbaar in tests: claim/release
## zonder te wachten op `finished`, dat onder de headless dummy-driver
## niet betrouwbaar vuurt).
func stop_all() -> void:
	for player in _claims:
		_reset_player(player)


## Cue-id's van de nu spelende one-shots (F3-debug).
func get_active() -> Array[StringName]:
	var active: Array[StringName] = []
	for player in _claims:
		if _claims[player]["sinds"] > 0:
			active.append(_claims[player]["id"])
	return active


func get_pool_status() -> String:
	return "%d/%d" % [get_active().size(), pool_size_3d + pool_size_flat]


func _maak_player(player: Node, player_name: String) -> void:
	player.name = player_name
	add_child(player)
	_claims[player] = {"sinds": 0, "id": &""}
	# finished → terug naar de pool; verbonden voor de levensduur van de
	# pool zelf (de players zijn onze kinderen, geen wisselende externen).
	player.finished.connect(_reset_player.bind(player))


func _claim_player(positional: bool) -> Node:
	var wanted := "OneShot3D_" if positional else "OneShotFlat_"
	var oldest: Node = null
	var oldest_since := 0
	for player in _claims:
		if not String(player.name).begins_with(wanted):
			continue
		var since: int = _claims[player]["sinds"]
		if since == 0 and not player.playing:
			return player
		if oldest == null or since < oldest_since:
			oldest = player
			oldest_since = since
	# Pool vol: deterministisch de langstspelende stelen (keuze E).
	if oldest != null:
		Log.debug("OneShots: pool vol — steel '%s'" % _claims[oldest]["id"])
		_reset_player(oldest)
	return oldest


func _reset_player(player: Node) -> void:
	player.stop()
	player.stream = null
	player.volume_db = 0.0
	player.pitch_scale = 1.0
	_claims[player] = {"sinds": 0, "id": &""}
