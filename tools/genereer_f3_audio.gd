extends SceneTree
## F3 audio-micropass: vervangt de twee deur-placeholders door een
## gelaagd, geloofwaardig deurgeluid en genereert de regen-buitenloop.
##
## De GD-brief (F3 §14): het oude één-laags creak-geluid blijft onder de
## kwaliteitslat. Een echte deur is een keten van gebeurtenissen —
## klink, schoot, blad-beweging, lichte scharnierkraak, en de zachte
## resonantie van het kozijn. Geen horror-creak: een normale deur die in
## een stil gebouw echt klinkt is enger.
##
## De bestanden vervangen de placeholders 1-op-1 (zelfde namen), dus de
## SoundResources en de deur-prop blijven onaangeraakt — precies het
## vervangingscontract van taak 005. De oorspronkelijke generator
## (genereer_placeholder_audio.gd) blijft het startpunt voor al het
## andere; wie hem opnieuw draait, draait daarna dit script.
##
## Deterministisch (vaste seed): elke run is byte-gelijk.
## Draaien:  godot --headless --path . -s tools/genereer_f3_audio.gd

const MIX_RATE := 44100
const SFX_DIR := "res://assets/audio/sfx"
const AMB_DIR := "res://assets/audio/ambience"

var _rng := RandomNumberGenerator.new()


func _init() -> void:
	_rng.seed = 20260803
	_write_wav(SFX_DIR + "/sfx_door_creak_open_01.wav", _deur_open())
	_write_wav(SFX_DIR + "/sfx_door_creak_close_01.wav", _deur_dicht())
	_write_wav(AMB_DIR + "/amb_regen_buiten_01.wav", _regen_loop(4.0))
	print("F3-audio gegenereerd (deterministisch, seed 20260803).")
	quit(0)


## Deur open: klink omlaag (twee metalige tikjes) → schoot vrij →
## blad-beweging (lage, bredere ruis-sweep) met een zachte
## scharnierkraak erdoorheen → lichte kozijnresonantie als staart.
func _deur_open() -> PackedFloat32Array:
	var samples := PackedFloat32Array()
	samples.append_array(_klink_tik(1650.0, 0.55))
	samples.append_array(_stilte(0.045))
	samples.append_array(_klink_tik(1150.0, 0.42))
	samples.append_array(_stilte(0.03))
	samples.append_array(_schoot(0.38))
	samples.append_array(_stilte(0.02))
	var beweging := _blad_beweging(0.52, 0.30, 480.0, 260.0)
	_meng(beweging, _scharnier(0.42, 130.0, 96.0, 0.10),
		int(0.06 * MIX_RATE))
	samples.append_array(beweging)
	samples.append_array(_resonantie(0.28, 82.0, 0.12))
	return samples


## Deur dicht: blad-beweging (korter, iets sneller) → zachte plok van
## blad-in-kozijn → klink valt terug → korte resonantie.
func _deur_dicht() -> PackedFloat32Array:
	var samples := PackedFloat32Array()
	var beweging := _blad_beweging(0.34, 0.26, 300.0, 520.0)
	_meng(beweging, _scharnier(0.26, 90.0, 118.0, 0.08),
		int(0.04 * MIX_RATE))
	samples.append_array(beweging)
	samples.append_array(_plok(0.10, 150.0, 0.42))
	samples.append_array(_stilte(0.05))
	samples.append_array(_klink_tik(1400.0, 0.40))
	samples.append_array(_resonantie(0.22, 74.0, 0.10))
	return samples


## Regen-buitenloop: dichte gefilterde ruis (het brede geruis op asfalt
## en dak) met losse, iets heldere druppeltikken erdoorheen. De staart
## kruist equal-power terug in de kop, dus de loop is naadloos.
func _regen_loop(duration: float) -> PackedFloat32Array:
	var count := int(duration * MIX_RATE)
	var extra := int(0.35 * MIX_RATE)
	var ruw := PackedFloat32Array()
	ruw.resize(count + extra)
	var laag := 0.0
	var band := 0.0
	for i in ruw.size():
		var noise := _rng.randf_range(-1.0, 1.0)
		# Twee lopende gemiddelden: het verschil geeft een zachte
		# banddoorlaat rond het sisgebied van regen.
		laag += (noise - laag) / 26.0
		band += (noise - band) / 7.0
		ruw[i] = (band - laag) * 0.85
	# Losse druppels: korte heldere tikjes, willekeurig verspreid.
	for druppel in 46:
		var start := _rng.randi_range(0, ruw.size() - 400)
		var hz := _rng.randf_range(1400.0, 3200.0)
		var sterkte := _rng.randf_range(0.05, 0.16)
		for i in 320:
			var envelope := exp(-9.0 * float(i) / 320.0)
			ruw[start + i] += sin(TAU * hz * float(i) / MIX_RATE) \
				* sterkte * envelope
	# Equal-power crossfade van staart naar kop → naadloze herstart.
	var samples := PackedFloat32Array()
	samples.resize(count)
	for i in count:
		samples[i] = ruw[i] * 0.42
	for i in extra:
		var t := float(i) / float(extra)
		samples[i] = (ruw[count + i] * cos(t * PI * 0.5)
			+ ruw[i] * sin(t * PI * 0.5)) * 0.42
	return samples


## Kort metalig klink-tikje: heldere ping met snelle demping en een
## vleugje ruis van het mechaniek.
func _klink_tik(hz: float, sterkte: float) -> PackedFloat32Array:
	var count := int(0.045 * MIX_RATE)
	var samples := PackedFloat32Array()
	samples.resize(count)
	for i in count:
		var t := float(i) / float(count)
		var envelope := exp(-14.0 * t)
		samples[i] = (sin(TAU * hz * float(i) / MIX_RATE) * 0.55
			+ sin(TAU * hz * 2.7 * float(i) / MIX_RATE) * 0.20
			+ _rng.randf_range(-0.18, 0.18)) * sterkte * envelope
	return samples


## De schoot die uit de sluitplaat vrijkomt: dof veerklikje.
func _schoot(sterkte: float) -> PackedFloat32Array:
	var count := int(0.06 * MIX_RATE)
	var samples := PackedFloat32Array()
	samples.resize(count)
	var lopend := 0.0
	for i in count:
		var t := float(i) / float(count)
		var envelope := exp(-10.0 * t)
		var noise := _rng.randf_range(-1.0, 1.0)
		lopend += (noise - lopend) / 9.0
		samples[i] = (lopend * 0.9
			+ sin(TAU * 560.0 * float(i) / MIX_RATE) * 0.25) \
			* sterkte * envelope
	return samples


## Blad-beweging: brede lage ruis die aanzwelt en wegvalt — de
## verplaatste lucht en het schuiven over de scharnieren.
func _blad_beweging(duration: float, sterkte: float,
		from_cut: float, to_cut: float) -> PackedFloat32Array:
	var count := int(duration * MIX_RATE)
	var samples := PackedFloat32Array()
	samples.resize(count)
	var lopend := 0.0
	for i in count:
		var t := float(i) / float(count)
		var cutoff := lerpf(from_cut, to_cut, t)
		var window := maxf(2.0, MIX_RATE / cutoff)
		var noise := _rng.randf_range(-1.0, 1.0)
		lopend += (noise - lopend) / window
		var envelope := sin(minf(t * 1.25, 1.0) * PI)
		samples[i] = lopend * sterkte * envelope * 3.2
	return samples


## Zachte scharnierkraak: lage zaagtand met wobbel — hoorbaar, niet
## theatraal (geen horror-creak op iedere deur).
func _scharnier(duration: float, from_hz: float, to_hz: float,
		sterkte: float) -> PackedFloat32Array:
	var count := int(duration * MIX_RATE)
	var samples := PackedFloat32Array()
	samples.resize(count)
	var phase := 0.0
	for i in count:
		var t := float(i) / float(count)
		var hz := lerpf(from_hz, to_hz, t)
		phase = fmod(phase + hz / MIX_RATE, 1.0)
		var saw := 2.0 * phase - 1.0
		var wobble := 0.55 + 0.45 * sin(TAU * 5.0 * t + 1.3)
		var envelope := sin(minf(t * 1.4, 1.0) * PI)
		samples[i] = (saw * 0.8 + _rng.randf_range(-0.15, 0.15)) \
			* sterkte * wobble * envelope
	return samples


## Plok van het blad in het kozijn: lage korte klap.
func _plok(duration: float, hz: float, sterkte: float) -> PackedFloat32Array:
	var count := int(duration * MIX_RATE)
	var samples := PackedFloat32Array()
	samples.resize(count)
	var lopend := 0.0
	for i in count:
		var t := float(i) / float(count)
		var envelope := exp(-11.0 * t)
		var noise := _rng.randf_range(-1.0, 1.0)
		lopend += (noise - lopend) / 30.0
		samples[i] = (sin(TAU * hz * float(i) / MIX_RATE) * 0.7
			+ lopend * 1.6) * sterkte * envelope
	return samples


## Lichte kozijn-/roomresonantie: gedempte lage sinus met boventoon.
func _resonantie(duration: float, hz: float, sterkte: float) -> PackedFloat32Array:
	var count := int(duration * MIX_RATE)
	var samples := PackedFloat32Array()
	samples.resize(count)
	for i in count:
		var t := float(i) / float(count)
		var envelope := exp(-6.5 * t)
		samples[i] = (sin(TAU * hz * float(i) / MIX_RATE) * 0.8
			+ sin(TAU * hz * 2.01 * float(i) / MIX_RATE) * 0.25) \
			* sterkte * envelope
	return samples


func _stilte(duration: float) -> PackedFloat32Array:
	var samples := PackedFloat32Array()
	samples.resize(int(duration * MIX_RATE))
	return samples


## Mengt `laag` vanaf `offset` in `basis` (in-place, met clip-marge).
func _meng(basis: PackedFloat32Array, laag: PackedFloat32Array,
		offset: int) -> void:
	for i in laag.size():
		var doel := offset + i
		if doel >= basis.size():
			break
		basis[doel] = clampf(basis[doel] + laag[i], -1.0, 1.0)


func _write_wav(res_path: String, samples: PackedFloat32Array) -> void:
	var data := PackedByteArray()
	data.resize(samples.size() * 2)
	for i in samples.size():
		var value := int(clampf(samples[i], -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, value)
	var file := FileAccess.open(ProjectSettings.globalize_path(res_path),
		FileAccess.WRITE)
	file.store_buffer("RIFF".to_ascii_buffer())
	file.store_32(36 + data.size())
	file.store_buffer("WAVE".to_ascii_buffer())
	file.store_buffer("fmt ".to_ascii_buffer())
	file.store_32(16)
	file.store_16(1)
	file.store_16(1)
	file.store_32(MIX_RATE)
	file.store_32(MIX_RATE * 2)
	file.store_16(2)
	file.store_16(16)
	file.store_buffer("data".to_ascii_buffer())
	file.store_32(data.size())
	file.store_buffer(data)
	file.close()
	print("  → %s (%.2f s)" % [res_path, samples.size() / float(MIX_RATE)])
