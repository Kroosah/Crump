extends Interactable
## Ladekast: schuift open en dicht langs zijn eigen as. Kan een item-id
## dragen als data — het échte item bestaat pas met de inventory (taak 004);
## tot die tijd is de vondst een signaal + logregel.
## Bewust geen class_name (taakdossier 003).

## De la is van stand gewisseld (feit, geen commando).
signal toggled(is_open: bool)

## Bij de eerste keer openen bleek er iets in te liggen. De inventory
## (taak 004) abonneert zich hier te zijner tijd op.
signal item_found(item_id: StringName)

@export_group("Drawer")
## Hoe ver de la naar buiten schuift, in meters langs de lokale +Z-as.
@export var slide_distance := 0.35
## Luidheid (draagafstand in m) van het schuiven.
@export var loudness_toggle := 4.0
## Optionele inhoud als data; leeg = lege la.
@export var item_id: StringName = &""

@export_group("Prompts")
@export var prompt_open := "Open la"
@export var prompt_close := "Sluit la"

var _is_open := false
var _item_revealed := false


func interact(_by: Node) -> void:
	_is_open = not _is_open
	# Langs de eigen as schuiven, zodat een gedraaide kast goed werkt.
	translate_object_local(
		Vector3(0, 0, slide_distance if _is_open else -slide_distance))
	EventBus.noise_made.emit(global_position, loudness_toggle)
	toggled.emit(_is_open)
	if _is_open and not _item_revealed and item_id != &"":
		_item_revealed = true
		item_found.emit(item_id)
		Log.info("DrawerCabinet: bevat '%s' (oppakken volgt met taak 004)"
			% item_id)


func prompt_text() -> String:
	return prompt_close if _is_open else prompt_open
