extends SceneTree
## Genereert de placeholder-audio van taak 005 (CLAUDE.md: geen assets
## verzinnen — placeholders worden gegenereerd en gedocumenteerd).
## Volledig deterministisch (vaste seed): elke run produceert byte-gelijke
## bestanden. Elke echte asset vervangt straks 1-op-1 een placeholder via
## de SoundResource, zonder code.
##
## Draaien (headless):
##   godot --headless --path . -s tools/genereer_placeholder_audio.gd
##
## Doelen per geluid (kader §8) staan in tasks/005_audio.md.

const MIX_RATE := 44100
const SFX_DIR := "res://assets/audio/sfx"
const AMB_DIR := "res://assets/audio/ambience"

var _rng := RandomNumberGenerator.new()


func _init() -> void:
	_rng.seed = 20260728
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SFX_DIR))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(AMB_DIR))

	# Voetstappen: korte ruis-bursts; duur/volume verschillen per gangsoort
	# zodat de speler zijn eigen prijs hoort (P3).
	for variant in [1, 2]:
		_write_wav("%s/sfx_footstep_walk_%02d.wav" % [SFX_DIR, variant],
			_noise_burst(0.12, 0.50, 900.0))
		_write_wav("%s/sfx_footstep_sneak_%02d.wav" % [SFX_DIR, variant],
			_noise_burst(0.09, 0.20, 600.0))
		_write_wav("%s/sfx_footstep_run_%02d.wav" % [SFX_DIR, variant],
			_noise_burst(0.15, 0.85, 1200.0))
		_write_wav("%s/sfx_footstep_crouch_%02d.wav" % [SFX_DIR, variant],
			_noise_burst(0.10, 0.28, 700.0))

	# Deur: lage kraak (open dalend, dicht stijgend) + slot-rammel.
	# LET OP: de twee creak-bestanden zijn sinds tier F3 vervangen door
	# het gelaagde deurgeluid uit tools/genereer_f3_audio.gd — draai dat
	# script ná dit script om de F3-versie terug te krijgen.
	_write_wav(SFX_DIR + "/sfx_door_creak_open_01.wav", _creak(0.7, 95.0, 62.0))
	_write_wav(SFX_DIR + "/sfx_door_creak_close_01.wav", _creak(0.5, 62.0, 88.0))
	_write_wav(SFX_DIR + "/sfx_door_rattle_01.wav", _rattle())

	# La: geschuurde ruis-sweep.
	_write_wav(SFX_DIR + "/sfx_drawer_slide_open_01.wav",
		_noise_burst(0.35, 0.35, 500.0))
	_write_wav(SFX_DIR + "/sfx_drawer_slide_close_01.wav",
		_noise_burst(0.30, 0.40, 450.0))

	# Oppakken: twee zachte tikjes — subtiel, geen beloningsjingle (P2/P4).
	_write_wav(SFX_DIR + "/sfx_item_pickup_01.wav", _ticks())

	# Nulpunt-ambience: koeling/tl-zoem. Gehele cycli op de loopgrens
	# (100 Hz en 50 Hz over exact 2,0 s) → naadloze herstart.
	_write_wav(AMB_DIR + "/amb_hum_koeling_01.wav", _hum(2.0))

	# Zaklamp-klik (taak 006): één droge schakelaartik — informatie, geen
	# jingle (kader 005 §8). Bewust als laatste gegenereerd: zo blijft de
	# RNG-volgorde (en dus elke eerdere placeholder) byte-gelijk.
	_write_wav(SFX_DIR + "/sfx_flashlight_click_01.wav", _click())

	print("Placeholder-audio gegenereerd (deterministisch, seed 20260728).")
	quit(0)


## Ruisburst met exponentieel afvallende envelope en een simpel
## laagdoorlaat-karakter (lopend gemiddelde ~ afsnijfrequentie).
func _noise_burst(duration: float, amplitude: float, cutoff: float) -> PackedFloat32Array:
	var count := int(duration * MIX_RATE)
	var samples := PackedFloat32Array()
	samples.resize(count)
	var window := maxi(1, int(MIX_RATE / cutoff))
	var running := 0.0
	for i in count:
		var noise := _rng.randf_range(-1.0, 1.0)
		running += (noise - running) / float(window)
		var envelope := exp(-6.0 * float(i) / float(count))
		samples[i] = running * amplitude * envelope * 4.0
	return samples


## Kraak: zaagtand die van `from_hz` naar `to_hz` glijdt, met trage
## amplitude-wobbel en wat ruis erdoorheen.
func _creak(duration: float, from_hz: float, to_hz: float) -> PackedFloat32Array:
	var count := int(duration * MIX_RATE)
	var samples := PackedFloat32Array()
	samples.resize(count)
	var phase := 0.0
	for i in count:
		var t := float(i) / float(count)
		var hz := lerpf(from_hz, to_hz, t)
		phase = fmod(phase + hz / MIX_RATE, 1.0)
		var saw := 2.0 * phase - 1.0
		var wobble := 0.6 + 0.4 * sin(TAU * 7.0 * t)
		var envelope := minf(t * 8.0, 1.0) * (1.0 - t * 0.6)
		samples[i] = (saw * 0.28 + _rng.randf_range(-0.06, 0.06)) \
			* wobble * envelope
	return samples


## Slot-rammel: drie korte metalige bursts vlak na elkaar.
func _rattle() -> PackedFloat32Array:
	var samples := PackedFloat32Array()
	for burst in 3:
		samples.append_array(_noise_burst(0.05, 0.5, 2200.0))
		var gap := PackedFloat32Array()
		gap.resize(int(0.04 * MIX_RATE))
		samples.append_array(gap)
	return samples


## Twee zachte sinustikjes (oppakken): kort, onopvallend.
func _ticks() -> PackedFloat32Array:
	var samples := PackedFloat32Array()
	for tick_hz in [880.0, 1175.0]:
		var count := int(0.05 * MIX_RATE)
		var part := PackedFloat32Array()
		part.resize(count)
		for i in count:
			var envelope := exp(-10.0 * float(i) / float(count))
			part[i] = sin(TAU * tick_hz * float(i) / MIX_RATE) * 0.3 * envelope
		samples.append_array(part)
		var gap := PackedFloat32Array()
		gap.resize(int(0.03 * MIX_RATE))
		samples.append_array(gap)
	return samples


## Zaklamp-klik: ultrakorte heldere burst + lage plok — een mechanische
## schakelaar, geen elektronische piep.
func _click() -> PackedFloat32Array:
	var samples := _noise_burst(0.03, 0.6, 3000.0)
	var count := int(0.04 * MIX_RATE)
	var thunk := PackedFloat32Array()
	thunk.resize(count)
	for i in count:
		var envelope := exp(-12.0 * float(i) / float(count))
		thunk[i] = sin(TAU * 220.0 * float(i) / MIX_RATE) * 0.35 * envelope
	samples.append_array(thunk)
	return samples


## Zoem van koeling/tl: 50+100 Hz met een zweving; gehele cycli over de
## duur zodat de loop naadloos is.
func _hum(duration: float) -> PackedFloat32Array:
	var count := int(duration * MIX_RATE)
	var samples := PackedFloat32Array()
	samples.resize(count)
	for i in count:
		var t := float(i) / MIX_RATE
		var value := 0.5 * sin(TAU * 50.0 * t) + 0.35 * sin(TAU * 100.0 * t) \
			+ 0.15 * sin(TAU * 150.0 * t)
		samples[i] = value * 0.16
	return samples


## Schrijft 16-bit mono PCM als RIFF/WAV.
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
	file.store_16(1)            # PCM
	file.store_16(1)            # mono
	file.store_32(MIX_RATE)
	file.store_32(MIX_RATE * 2) # byte rate
	file.store_16(2)            # block align
	file.store_16(16)           # bits per sample
	file.store_buffer("data".to_ascii_buffer())
	file.store_32(data.size())
	file.store_buffer(data)
	file.close()
	print("  → %s (%.2f s)" % [res_path, samples.size() / float(MIX_RATE)])
