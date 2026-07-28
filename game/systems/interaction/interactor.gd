extends Node
## De interactor (taak 003): raycast vanaf de actieve camera, detecteert
## uitsluitend het Interactable-contract en publiceert de prompt op de
## EventBus.
##
## Dit script kent bewust NIETS anders: geen speler (het gebruikt de actieve
## viewport-camera, wie dat ook is), geen proptypes (harde eis GD 2026-07-28
## — nooit `is Door`-achtige checks), geen UI. De prompttekst komt letterlijk
## en ongewijzigd uit prompt_text() van het aangekeken object.

@export_group("Interaction")
## Maximale interactie-afstand in meters vanaf de camera. Bewust kort:
## interactie hoort intiem te zijn — je moet ergens naartoe durven lopen.
@export var max_distance := 2.5
## De ray raakt wereldgeometrie én interactables: de eerste hit telt, dus
## een muur of dichte kast blokkeert wat erachter ligt.
@export_flags_3d_physics var ray_mask := 9

var _target: Interactable = null
var _last_prompt := ""


func _physics_process(_delta: float) -> void:
	_update_target()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and _has_valid_target() \
			and _target.can_interact():
		_target.interact(self)


func _update_target() -> void:
	var camera := get_viewport().get_camera_3d()
	var new_target: Interactable = null
	if camera != null:
		var from := camera.global_position
		var to := from - camera.global_basis.z * max_distance
		var query := PhysicsRayQueryParameters3D.create(from, to, ray_mask)
		var hit := camera.get_world_3d().direct_space_state.intersect_ray(query)
		# De enige typecheck die bestaat: het contract zelf. Raakt de ray
		# eerst wereldgeometrie, dan is er geen doelwit — occlusie gratis.
		var collider: Object = hit.get("collider")
		if collider is Interactable and collider.can_interact():
			new_target = collider
	_target = new_target

	# Elke frame de tekst opnieuw opvragen: een object mag zijn prompt
	# wijzigen zonder dat het doelwit wisselt (deur open → "Sluit deur").
	# Emitten alleen bij verandering, zodat de bus stil blijft.
	var prompt := _target.prompt_text() if _has_valid_target() else ""
	if prompt != _last_prompt:
		_last_prompt = prompt
		EventBus.interact_prompt_changed.emit(prompt)


func _has_valid_target() -> bool:
	# Een doelwit kan zichzelf opruimen (oppakbaar object); nooit een
	# vrijgegeven node aanspreken.
	return _target != null and is_instance_valid(_target)
