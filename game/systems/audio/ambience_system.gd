extends Node
## Ambience-lagen (taak 005, keuze F): benoemde loops die per laag met een
## fade aan en uit gaan. De standaardtoestand van élke laag is UIT —
## stilte is een geldige, volledig ondersteunde toestand (P2); een level
## zet expliciet zijn nulpunt aan (dossier §5; nooit automatisch bij
## bootstrap). Het wegvallen van een laag is daarmee een gebeurtenis, geen
## bug — ambience is een spanningsinstrument, geen behang.

## dB-vloer waarnaar uitgefade wordt vóór de stop.
const SILENT_DB := -60.0

## layer_id → {player: AudioStreamPlayer, basis_db: float, tween: Tween}
var _layers: Dictionary = {}


## Zet een laag aan of uit met een fade. `sound` komt uit de centrale
## resolver (façade); onbekend id = null = luid loggen, niets doen.
func set_layer(sound: Resource, layer_id: StringName, active: bool,
		fade_s: float) -> void:
	if active and sound == null:
		push_warning("Ambience: onbekende laag '%s'" % layer_id)
		return
	if active:
		_start_layer(sound, layer_id, fade_s)
	else:
		_stop_layer(layer_id, fade_s)


func get_active_layers() -> Array[StringName]:
	var active: Array[StringName] = []
	for layer_id in _layers:
		active.append(layer_id)
	return active


func _start_layer(sound: Resource, layer_id: StringName, fade_s: float) -> void:
	if _layers.has(layer_id):
		return
	var player := AudioStreamPlayer.new()
	player.name = "Laag_%s" % layer_id
	player.stream = sound.streams[0]
	player.bus = sound.bus
	player.volume_db = SILENT_DB
	add_child(player)
	# Naadloze loop: de placeholder eindigt op de cyclusgrens; bij finished
	# gewoon opnieuw starten (WAV-loopvlaggen zijn import-metadata en dit
	# blijft ook correct voor toekomstige niet-loopende streams).
	player.finished.connect(player.play)
	player.play()
	var tween := create_tween()
	tween.tween_property(player, "volume_db", sound.volume_db, fade_s)
	_layers[layer_id] = {"player": player, "tween": tween}
	Log.info("Ambience: laag '%s' aan (fade %.1f s)" % [layer_id, fade_s])


func _stop_layer(layer_id: StringName, fade_s: float) -> void:
	if not _layers.has(layer_id):
		return
	var player: AudioStreamPlayer = _layers[layer_id]["player"]
	var old_tween: Tween = _layers[layer_id]["tween"]
	if old_tween != null and old_tween.is_valid():
		old_tween.kill()
	_layers.erase(layer_id)
	var tween := create_tween()
	tween.tween_property(player, "volume_db", SILENT_DB, fade_s)
	tween.tween_callback(player.queue_free)
	Log.info("Ambience: laag '%s' uit (fade %.1f s)" % [layer_id, fade_s])
