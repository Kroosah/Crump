extends Node
## Schaduwbudget-bewaking (taak 006 §5) — één taak, bewust géén framework:
## geen registratie-API, geen dynamische herverdeling, geen kwaliteitsbeheer.
## Bij levelload telt hij de schaduw-werpende lichten van het level en
## degradeert hij deterministisch boven budget. In 006 zijn alle
## level-lampen statische scene-data (geen dynamische spawning), dus een
## overschrijding is per definitie een configuratiefout — de smoke-suite
## vangt die ook; dit systeem is de runtime-diagnose. Verwijder deze map en
## alleen die diagnose vervalt (D-015).

## Max schaduw-werpende level-lichten. De zaklamp valt búíten deze telling:
## haar slot is gereserveerd (totaal 4, LEVEL §5) en degradeert nooit.
const LEVEL_SHADOW_BUDGET := 3
const TOTAL_SHADOW_BUDGET := 4


func _ready() -> void:
	# Uitgesteld: eerst moet het hele level (incl. gespawnde props) staan.
	_enforce.call_deferred()


## Actieve schaduwlichten nu: level + zaklamp indien aan (F3, duck-typed
## via de groep `light_budget`).
func get_active_shadow_count() -> int:
	var count := _level_shadow_lights().size()
	var flashlight := get_tree().get_first_node_in_group("flashlight")
	if flashlight != null:
		for node in flashlight.find_children("", "Light3D", true, false):
			var light := node as Light3D
			if light.shadow_enabled and light.is_visible_in_tree():
				count += 1
	return count


func get_shadow_budget() -> int:
	return TOTAL_SHADOW_BUDGET


## Deterministische handhaving: de eerste 3 in scene-boomvolgorde behouden
## hun schaduw; elke volgende verliest alleen zijn schaduw (de lamp blijft
## áán) met één warning per gedegradeerde lamp. Boomvolgorde ligt vast in
## de scene-data, dus de uitkomst is elke run identiek.
func _enforce() -> void:
	var kept := 0
	for light in _level_shadow_lights():
		kept += 1
		if kept > LEVEL_SHADOW_BUDGET:
			light.shadow_enabled = false
			push_warning(
				"LightBudget: %d/%d level-schaduwlichten — schaduw uitgeschakeld op %s"
				% [kept, LEVEL_SHADOW_BUDGET, light.get_path()])


## Zichtbare, schaduw-werpende lichten van het level in boomvolgorde,
## zonder alles onder het zaklampsysteem (gereserveerd slot).
func _level_shadow_lights() -> Array[Light3D]:
	var result: Array[Light3D] = []
	var parent := get_parent()
	if parent == null:
		return result
	for node in parent.find_children("", "Light3D", true, false):
		var light := node as Light3D
		if not light.shadow_enabled or not light.is_visible_in_tree():
			continue
		if _belongs_to_flashlight(light):
			continue
		result.append(light)
	return result


func _belongs_to_flashlight(node: Node) -> bool:
	var current: Node = node
	while current != null:
		if current.is_in_group("flashlight"):
			return true
		current = current.get_parent()
	return false
