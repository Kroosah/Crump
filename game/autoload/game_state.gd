extends Node
## GameState — spelvoortgang: hoofdstuk, vlaggen, gelezen documenten.
## Serialiseerbaar via to_dict()/from_dict(); SaveManager schrijft/leest dit.
## Instellingen horen hier NIET (die leven in SettingsManager, los van de
## spelsessie — zie docs/DECISIONS.md D-011).

## Huidig hoofdstuk (0 = nog niet gestart; 1-4 = hoofdstukken uit STORY.md).
var chapter: int = 0

## Vrije voortgangsvlaggen: StringName -> bool (bv. &"kleedkamer_bezocht").
var flags: Dictionary = {}

## Id's van gelezen documenten (voor omgevingsvertelling en eindes).
var documents_read: Array[StringName] = []


func start_chapter(new_chapter: int) -> void:
    chapter = new_chapter
    EventBus.chapter_started.emit(chapter)


func set_flag(flag: StringName, value: bool = true) -> void:
    flags[flag] = value


func get_flag(flag: StringName) -> bool:
    return flags.get(flag, false)


func mark_document_read(doc_id: StringName) -> void:
    if doc_id not in documents_read:
        documents_read.append(doc_id)


## Volledige reset (nieuw spel).
func reset() -> void:
    chapter = 0
    flags.clear()
    documents_read.clear()


## Serialisatie-contract voor SaveManager (ARCHITECTURE §6).
func to_dict() -> Dictionary:
    return {
        "chapter": chapter,
        "flags": flags.duplicate(),
        "documents_read": documents_read.duplicate(),
    }


func from_dict(data: Dictionary) -> void:
    chapter = int(data.get("chapter", 0))
    flags = {}
    var raw_flags: Dictionary = data.get("flags", {})
    for key in raw_flags:
        flags[StringName(key)] = bool(raw_flags[key])
    documents_read.clear()
    for doc in data.get("documents_read", []):
        documents_read.append(StringName(doc))
