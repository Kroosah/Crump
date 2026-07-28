extends Interactable
## Leesbaar briefje: bezit zijn DocumentResource, valideert de data en
## zendt het feit document_opened(id, titel, tekst) — uitsluitend
## basistypen (D-021), de resource gaat nooit over de bus. De lees-UI is
## een eigen verwijderbaar systeem (taak 007): zonder lezer blijft dit
## briefje gewoon registreren en zenden. Lezen is bewust stil: geen
## noise_made — stilte is het instrument (GAME_BIBLE §3, pijler 1).
## Bewust geen class_name (taakdossier 003).

@export_group("Note")
## De inhoud als data (taak 007): id, titel en tekst leven in de
## resource; dit briefje leest hem alleen (runtime read-only).
@export var document: DocumentResource

@export_group("Prompts")
@export var prompt := "Lees brief"


func interact(_by: Node) -> void:
	# Valideren vóór alles (dossier 007 §4d): ongeldige data betekent
	# geen feit én geen GameState-mutatie — luid falen in ontwikkeling.
	if document == null:
		push_warning("ReadableNote '%s': geen DocumentResource toegewezen" % name)
		return
	if document.id == &"":
		push_warning("ReadableNote '%s': document met lege id geweigerd" % name)
		return
	if document.text.is_empty():
		push_warning("ReadableNote '%s': document met lege tekst geweigerd" % name)
		return
	GameState.mark_document_read(document.id)
	EventBus.document_opened.emit(document.id, document.title, document.text)


func prompt_text() -> String:
	return prompt
