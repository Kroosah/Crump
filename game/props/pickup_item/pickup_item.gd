extends Interactable
## Oppakbaar object (taak 003, flow herzien in 004): dient een oppakverzoek
## in op de EventBus en verdwijnt uitsluitend na een geldige
## accepted-response binnen zijn eigen synchrone verzoekvenster
## (dossier 004 §5a/5b). Zonder inventory blijft hij gewoon liggen en is
## hij direct opnieuw interacteerbaar — nette degradatie (D-015).
##
## Bewust geen class_name (taakdossier 003), en het item-veld is bewust
## het basistype Resource: dit script mag de inventory-feature niet kennen
## (D-021) — de inventory valideert zelf streng. De ItemResource is
## read-only configuratiedata; hier wordt alleen uit gelezen.

## Dit object is opgepakt (bevestigd door de inventory). Prop-eigen feit
## voor tests en levellogica; systemen luisteren op de bus (item_added).
signal picked_up(item_id: StringName)

@export_group("Pickup")
## De itemdefinitie: sleep hier een ItemResource-.tres in.
@export var item: Resource
## Luidheid (draagafstand in m) van het oppakken — klinkt pas ná acceptatie
## (§5c: het geluid hoort bij het lukken, niet bij het proberen).
@export var loudness_pickup := 2.0

@export_group("Prompts")
@export var prompt := "Pak op"

## Alleen waar bínnen het synchrone emit-venster van het eigen verzoek
## (§5a): buiten dat venster bestaat er per definitie geen open verzoek.
var _awaiting := false
## Permanent waar na acceptatie; blokkeert elke verdere verwerking (§5b).
var _picked := false


func _ready() -> void:
	super()
	EventBus.item_pickup_resolved.connect(_on_pickup_resolved)


func _exit_tree() -> void:
	# Symmetrisch met _ready (kwaliteitseis GD, 2026-07-28).
	EventBus.item_pickup_resolved.disconnect(_on_pickup_resolved)


func can_interact() -> bool:
	return not _picked


func interact(_by: Node) -> void:
	if _picked:
		return
	_awaiting = true
	EventBus.item_pickup_requested.emit(self, item)
	# Signalen zijn synchroon: als hier niemand gereageerd heeft, komt er
	# nooit meer een antwoord. Venster dicht — het object blijft in zijn
	# normale, direct opnieuw interacteerbare toestand (§5a).
	_awaiting = false


func prompt_text() -> String:
	return prompt


func _on_pickup_resolved(source: Node, accepted: bool) -> void:
	# Invarianten §5b: het antwoord gaat exact over mij, ik verwerk op dít
	# moment zelf een verzoek, en het is nog niet afgehandeld. De eerste
	# passende response sluit het venster; al het andere ketst hier af.
	if source != self or not _awaiting:
		return
	_awaiting = false
	if not accepted:
		return
	_picked = true
	# Eigen wereldfeedback, pas ná bevestiging (§5c): geluid, feit, weg.
	EventBus.noise_made.emit(global_position, loudness_pickup)
	var item_id := StringName(item.get(&"id")) if item != null else &""
	picked_up.emit(item_id)
	Log.info("PickupItem: '%s' opgenomen in de inventory" % item_id)
	queue_free()
