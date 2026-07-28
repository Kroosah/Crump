extends Interactable
## Leesbaar briefje: opent de leesweergave via een signaal; de tekst is data.
## De lees-UI bestaat nog niet (fase 2/4) — dit briefje zendt alleen het
## feit "document geopend" en registreert het lezen in GameState.
## Lezen is bewust stil: geen noise_made — stilte is het instrument
## (GAME_BIBLE §3, pijler 1). Bewust geen class_name (taakdossier 003).

@export_group("Note")
## Identiteit van het document (GameState.documents_read, STORY-verwijzing).
@export var document_id: StringName = &"note"
## De volledige tekst als data; de latere lees-UI toont dit letterlijk.
@export_multiline var document_text := ""

@export_group("Prompts")
@export var prompt := "Lees brief"


func interact(_by: Node) -> void:
	GameState.mark_document_read(document_id)
	EventBus.document_opened.emit(document_id, document_text)


func prompt_text() -> String:
	return prompt
