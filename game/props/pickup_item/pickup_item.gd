extends Interactable
## Oppakbaar object: verdwijnt bij oppakken en meldt dat via een signaal.
## Zonder inventory (taak 004) is "oppakken" nog: signaal + logregel +
## weg uit de wereld. De haak ligt klaar; de opslag nog niet.
## Bewust geen class_name (taakdossier 003).

## Dit object is opgepakt. De inventory (taak 004) abonneert zich hierop.
signal picked_up(item_id: StringName)

@export_group("Pickup")
## Identiteit van het item als data; betekenis volgt met taak 004.
@export var item_id: StringName = &"item"
## Luidheid (draagafstand in m) van het oppakken — klein, maar niet niets.
@export var loudness_pickup := 2.0

@export_group("Prompts")
@export var prompt := "Pak op"


func interact(_by: Node) -> void:
	EventBus.noise_made.emit(global_position, loudness_pickup)
	picked_up.emit(item_id)
	Log.info("PickupItem: '%s' opgepakt (verdwijnt — inventory volgt in taak 004)"
		% item_id)
	queue_free()


func prompt_text() -> String:
	return prompt
