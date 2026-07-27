extends Node
## AudioDirector — het enige systeem dat rechtstreeks met audiobussen praat
## (ARCHITECTURE §4). In taak 001 alleen busbeheer (nodig voor instellingen);
## ambience-lagen, geluid-als-event en muziek-cues volgen in taak 005.

## Busnamen zoals gedefinieerd in game/audio_bus_layout.tres.
const BUSES: Array[StringName] = [&"Master", &"SFX", &"Ambience", &"Music", &"Voice"]


## Zet het volume van een bus (0.0-1.0 lineair; intern omgezet naar dB).
func set_bus_volume_linear(bus: StringName, volume: float) -> void:
    var index := AudioServer.get_bus_index(bus)
    if index < 0:
        push_error("AudioDirector: onbekende bus '%s'" % bus)
        return
    AudioServer.set_bus_volume_db(index, linear_to_db(clampf(volume, 0.0, 1.0)))


## Lees het volume van een bus als lineaire waarde (0.0-1.0).
func get_bus_volume_linear(bus: StringName) -> float:
    var index := AudioServer.get_bus_index(bus)
    if index < 0:
        push_error("AudioDirector: onbekende bus '%s'" % bus)
        return 0.0
    return db_to_linear(AudioServer.get_bus_volume_db(index))


## Controleert of alle verwachte bussen bestaan (gebruikt door de smoke-test).
func has_expected_buses() -> bool:
    for bus in BUSES:
        if AudioServer.get_bus_index(bus) < 0:
            return false
    return true

# Ambience/muziek-API bewust nog niet aanwezig: wordt in taak 005 ontworpen
# vanuit de behoeften van HORROR_GUIDELINES §3 (geen loze stubs vooraf).
