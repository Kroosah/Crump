extends Node
## SaveManager — schrijven/lezen van GameState naar user:// (ARCHITECTURE §6).
## Taak 001: minimale maar werkende basis (JSON + versienummer). Checkpoints
## en save-bij-verlaten volgen bij het levelwerk; migraties zodra het formaat
## voor het eerst wijzigt.

## Versie van het save-formaat; verhogen bij elke formaatwijziging + migratie.
const SAVE_VERSION := 1
const SAVE_DIR := "user://saves"


func _save_path(slot: int) -> String:
    return "%s/slot_%d.json" % [SAVE_DIR, slot]


func has_save(slot: int) -> bool:
    return FileAccess.file_exists(_save_path(slot))


## Slaat de huidige GameState op. Geeft true bij succes.
func save_game(slot: int) -> bool:
    DirAccess.make_dir_recursive_absolute(SAVE_DIR)
    var payload := {
        "save_version": SAVE_VERSION,
        "state": GameState.to_dict(),
    }
    var file := FileAccess.open(_save_path(slot), FileAccess.WRITE)
    if file == null:
        push_error("SaveManager: kan niet schrijven naar %s (fout %d)"
            % [_save_path(slot), FileAccess.get_open_error()])
        return false
    file.store_string(JSON.stringify(payload, "  "))
    file.close()
    return true


## Laadt een save in GameState. Geeft true bij succes; behandelt elk bestand
## als mogelijk corrupt (CODING_STANDARDS §7).
func load_game(slot: int) -> bool:
    if not has_save(slot):
        push_warning("SaveManager: geen save in slot %d" % slot)
        return false
    var file := FileAccess.open(_save_path(slot), FileAccess.READ)
    if file == null:
        push_error("SaveManager: kan %s niet openen" % _save_path(slot))
        return false
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    file.close()
    if parsed == null or not parsed is Dictionary or "state" not in parsed:
        push_error("SaveManager: save in slot %d is onleesbaar" % slot)
        return false
    var version := int(parsed.get("save_version", 0))
    if version != SAVE_VERSION:
        # Eerste migratiefunctie komt bij de eerste formaatwijziging.
        push_error("SaveManager: onbekende save-versie %d (verwacht %d)"
            % [version, SAVE_VERSION])
        return false
    GameState.from_dict(parsed["state"])
    return true


func delete_save(slot: int) -> void:
    if has_save(slot):
        DirAccess.remove_absolute(_save_path(slot))
