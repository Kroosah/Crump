extends Node3D
## Testprops van de developer room (taak 003). Plaatst de interactie-props
## uitsluitend als hun scènes bestaan: verdwijnt het interactiesysteem
## (contract + props, D-015), dan blijft de kale testruimte gewoon werken.
## Dit is bewust dev-room-gereedschap — echte hoofdstukken instantiëren hun
## props zelf in de level-scène (ARCHITECTURE §4a.6).

## Plaatsing en per-instantie-instellingen als data. `settings` wordt met
## set() op de instantie gezet — de spawner kent dus geen enkel proptype.
const TEST_PROPS: Array[Dictionary] = [
	{
		"path": "res://game/props/door_wooden/door_wooden.tscn",
		"name": "TestDoor",
		"position": Vector3(-4.0, 0.0, -4.0),
	},
	{
		"path": "res://game/props/door_wooden/door_wooden.tscn",
		"name": "TestDoorLocked",
		"position": Vector3(-6.5, 0.0, -4.0),
		"settings": {"locked": true},
	},
	{
		"path": "res://game/props/drawer_cabinet/drawer_cabinet.tscn",
		"name": "TestDrawer",
		"position": Vector3(2.0, 0.0, -4.0),
		"settings": {"item_id": &"sleutel_test"},
	},
	{
		"path": "res://game/props/pickup_item/pickup_item.tscn",
		"name": "TestPickup",
		"position": Vector3(3.0, 1.09, -2.0),
		"settings": {"item_id": &"sleutel_test", "prompt": "Pak sleutel op"},
	},
	{
		"path": "res://game/props/note_readable/note_readable.tscn",
		"name": "TestNote",
		"position": Vector3(0.0, 1.7, -9.73),
		"settings": {
			"document_id": &"briefje_dev_room",
			"prompt": "Lees briefje",
			"document_text": "Testbriefje uit de developer room.\nAls je dit leest, werkt het interactiesysteem.",
		},
	},
]


func _ready() -> void:
	var placed := 0
	for prop in TEST_PROPS:
		if not ResourceLoader.exists(prop["path"]):
			continue
		var packed: PackedScene = load(prop["path"])
		if packed == null:
			continue
		var node: Node3D = packed.instantiate()
		node.name = prop["name"]
		for key in prop.get("settings", {}):
			node.set(key, prop["settings"][key])
		add_child(node)
		node.position = prop["position"]
		placed += 1
	if placed == 0:
		Log.info("DevRoom: geen testprops geplaatst (interactiesysteem afwezig)")
	else:
		Log.info("DevRoom: %d testprops geplaatst" % placed)
