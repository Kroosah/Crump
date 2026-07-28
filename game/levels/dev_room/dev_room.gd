extends Node3D
## Developer room (taak 006, keuze G): de nachtstaat is de gecommitte
## standaard — bijna zwart, schaarse TL-ankers, diepte-fog. Het werklicht
## is een expliciete editor-/debugoptie voor geometrie- en
## systeeminspectie: debug, geen gameplay, en nooit aan in een commit
## (de suite bewaakt dat).

## true = de oude heldere testverlichting (inspectie); false = nachtstaat.
@export var werklicht := false

@onready var _werklicht_rig: Node3D = %Werklicht
@onready var _night_lights: Node3D = %NightLights


func _ready() -> void:
	_werklicht_rig.visible = werklicht
	_night_lights.visible = not werklicht
	if werklicht:
		Log.warn("DevRoom: werklicht AAN — alleen voor inspectie, nooit committen")
