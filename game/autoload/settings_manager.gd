extends Node
## SettingsManager — gebruikersinstellingen, bewust LOS van GameState:
## instellingen bestaan onafhankelijk van een actieve spelsessie (D-011).
## Laadt bij opstarten user://settings.cfg, past alles direct toe, en biedt
## de onderlaag waar het opties-menu (later) op aansluit.
##
## Grafische presets: DEVELOPMENT_LOW is het dev-default voor de zwakkere
## ontwikkel-pc; de uiteindelijke game moet op HIGH/ULTRA draaien. Het
## release-default wordt in fase 6 bepaald (TECH_DEBT TD-002).

const SETTINGS_PATH := "user://settings.cfg"

enum GraphicsPreset { DEVELOPMENT_LOW, LOW, MEDIUM, HIGH, ULTRA }

## Per preset: [3d-renderschaal, msaa_3d, schaduw-atlasgrootte]
const PRESET_VALUES := {
	GraphicsPreset.DEVELOPMENT_LOW: [0.75, Viewport.MSAA_DISABLED, 1024],
	GraphicsPreset.LOW:             [0.85, Viewport.MSAA_DISABLED, 2048],
	GraphicsPreset.MEDIUM:          [1.00, Viewport.MSAA_2X, 2048],
	GraphicsPreset.HIGH:            [1.00, Viewport.MSAA_2X, 4096],
	GraphicsPreset.ULTRA:           [1.00, Viewport.MSAA_4X, 4096],
}

## Busvolumes (lineair 0-1), sleutel = busnaam uit AudioDirector.BUSES.
var audio_volumes: Dictionary = {}

## Muisgevoeligheid-vermenigvuldiger (speler leest dit uit, taak 002).
var mouse_sensitivity := 1.0

## Head-bob uitschakelbaar (motion sickness, HORROR_GUIDELINES §8).
var head_bob_enabled := true

## Helderheid (toegepast op de omgeving zodra taak 006 dat oplevert).
var brightness := 1.0

var graphics_preset := GraphicsPreset.DEVELOPMENT_LOW


func _ready() -> void:
	load_settings()
	apply_all()
	Log.info("SettingsManager: geladen (preset %s)"
		% GraphicsPreset.keys()[graphics_preset])


## Zet alle waarden terug naar de standaard (zonder op te slaan).
func reset_to_defaults() -> void:
	audio_volumes = {}
	for bus in AudioDirector.BUSES:
		audio_volumes[bus] = 1.0
	mouse_sensitivity = 1.0
	head_bob_enabled = true
	brightness = 1.0
	graphics_preset = GraphicsPreset.DEVELOPMENT_LOW


func load_settings() -> void:
	reset_to_defaults()
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		Log.info("SettingsManager: geen settings.cfg gevonden, standaarden actief")
		return
	for bus in AudioDirector.BUSES:
		audio_volumes[bus] = clampf(
			float(config.get_value("audio", String(bus), 1.0)), 0.0, 1.0)
	mouse_sensitivity = clampf(
		float(config.get_value("input", "mouse_sensitivity", 1.0)), 0.1, 5.0)
	head_bob_enabled = bool(config.get_value("comfort", "head_bob", true))
	brightness = clampf(
		float(config.get_value("video", "brightness", 1.0)), 0.5, 2.0)
	graphics_preset = clampi(
		int(config.get_value("video", "graphics_preset",
			GraphicsPreset.DEVELOPMENT_LOW)),
		0, GraphicsPreset.size() - 1) as GraphicsPreset


func save_settings() -> bool:
	var config := ConfigFile.new()
	for bus in audio_volumes:
		config.set_value("audio", String(bus), audio_volumes[bus])
	config.set_value("input", "mouse_sensitivity", mouse_sensitivity)
	config.set_value("comfort", "head_bob", head_bob_enabled)
	config.set_value("video", "brightness", brightness)
	config.set_value("video", "graphics_preset", int(graphics_preset))
	var err := config.save(SETTINGS_PATH)
	if err != OK:
		Log.error("SettingsManager: opslaan mislukt (fout %d)" % err)
		return false
	return true


## Past alle instellingen toe op de draaiende systemen.
func apply_all() -> void:
	_apply_audio()
	_apply_graphics()


func set_bus_volume(bus: StringName, volume: float) -> void:
	audio_volumes[bus] = clampf(volume, 0.0, 1.0)
	AudioDirector.set_bus_volume_linear(bus, audio_volumes[bus])


func set_graphics_preset(preset: GraphicsPreset) -> void:
	graphics_preset = preset
	_apply_graphics()
	Log.info("SettingsManager: preset gewijzigd naar %s"
		% GraphicsPreset.keys()[preset])


func _apply_audio() -> void:
	for bus in audio_volumes:
		AudioDirector.set_bus_volume_linear(bus, audio_volumes[bus])


func _apply_graphics() -> void:
	var values: Array = PRESET_VALUES[graphics_preset]
	var viewport := get_viewport()
	if viewport == null:
		return
	viewport.scaling_3d_scale = values[0]
	viewport.msaa_3d = values[1]
	viewport.positional_shadow_atlas_size = values[2]
	RenderingServer.directional_shadow_atlas_set_size(values[2], true)
