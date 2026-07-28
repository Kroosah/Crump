extends Node
## Het inventory-systeem (taak 004): bewaart wat de speler draagt, bewaakt
## de capaciteit en beslist accept/reject over oppakverzoeken van de bus.
##
## Kent geen enkel wereldobject: het `source`-token uit een verzoek wordt
## alleen teruggeëchood in item_pickup_resolved zodat de juiste zender zijn
## antwoord herkent — er wordt nooit iets op aangeroepen (dossier 004 §2).
## Feedback (geluid, verdwijnen) is van de props zelf (§5c); dit systeem
## beheert uitsluitend de itemlijst. ItemResources zijn read-only
## configuratiedata: hier worden alleen referenties bewaard.
##
## Eén autoritatieve inventory (§2): alleen de eerste node in de groep
## `inventory` verbindt zich met de bus. Een tweede instantie meldt zich
## luid en blijft doof — hij kan nooit meebeslissen.

@export_group("Inventory")
## "Een handvol" (GAME_BIBLE §8, dossier §4). Vol = oppakverzoek afwijzen.
@export var capacity := 6

var _items: Array[ItemResource] = []
## Waar zolang déze instantie de bus-verbinding bezit; bepaalt ook de
## symmetrische afbraak in _exit_tree.
var _authoritative := false


func _ready() -> void:
	if get_tree().get_nodes_in_group("inventory")[0] != self:
		push_warning("Inventory: tweede instantie genegeerd — niet met de bus verbonden")
		return
	_authoritative = true
	EventBus.item_pickup_requested.connect(_on_item_pickup_requested)


func _exit_tree() -> void:
	# Symmetrisch met _ready: alleen afbreken wat we zelf opbouwden.
	if _authoritative:
		EventBus.item_pickup_requested.disconnect(_on_item_pickup_requested)
		_authoritative = false


## Het enige besliskanaal voor toevoegen (dossier §4): true = opgenomen,
## false = geweigerd — en een weigering muteert helemaal niets.
## Bewust getypeerd op Resource: afwijzen van een verkeerd type is
## onderdeel van het contract.
func add_item(item: Resource) -> bool:
	if item == null:
		push_warning("Inventory: add_item(null) geweigerd")
		return false
	if item is not ItemResource:
		push_warning("Inventory: geen ItemResource geweigerd (%s)" % item.get_class())
		return false
	if item.id == &"":
		push_warning("Inventory: item met lege id geweigerd ('%s')" % item.display_name)
		return false
	if _items.size() >= capacity:
		return false
	_items.append(item)
	EventBus.item_added.emit(item)
	return true


## Verwijdert de eerste vermelding met dit id en geeft hem terug.
## Mislukking (id niet aanwezig) = null, zonder mutatie of signaal.
func remove_item(id: StringName) -> Resource:
	for i in _items.size():
		if _items[i].id == id:
			var item: ItemResource = _items[i]
			_items.remove_at(i)
			EventBus.item_removed.emit(item)
			return item
	return null


func has_item(id: StringName) -> bool:
	for item in _items:
		if item.id == id:
			return true
	return false


## Kopie van de lijst: niemand muteert de interne staat van buitenaf.
func get_items() -> Array[ItemResource]:
	return _items.duplicate()


func is_full() -> bool:
	return _items.size() >= capacity


func _on_item_pickup_requested(source: Node, item: Resource) -> void:
	EventBus.item_pickup_resolved.emit(source, add_item(item))
