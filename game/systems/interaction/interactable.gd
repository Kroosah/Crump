class_name Interactable
extends StaticBody3D
## Het interactie-contract van CRUMP (ARCHITECTURE §5.1, taak 003).
##
## Dit is de ENIGE kennis die de interactor over de wereld heeft: een object
## is Interactable, meer niet (harde eis GD 2026-07-28). Elk object bepaalt
## zelf wat can_interact/interact/prompt_text betekenen; concrete props
## krijgen bewust géén class_name, zodat er geen type bestaat om op te
## checken. Afnemers van interactie-effecten luisteren naar signalen.
##
## Props overerven deze klasse, staan op physics-layer `interactable` en
## overriden de drie methodes hieronder.

## De physics-layer `interactable` (layer 4) als bitmasker.
const INTERACTABLE_LAYER := 8


func _ready() -> void:
	# Luid falen in ontwikkeling (CODING_STANDARDS §7): een Interactable die
	# niet op de interactable-layer staat, is onzichtbaar voor de raycast —
	# dat is altijd een vergissing.
	if collision_layer & INTERACTABLE_LAYER == 0:
		push_warning("%s: Interactable staat niet op de 'interactable'-layer"
			% name)


## Is dit object op dit moment benaderbaar voor interactie? `false` maakt het
## object volledig inert: geen prompt, geen interact. Een op-slot-deur blijft
## dus `true` — die praat terug ("Op slot"), hij negeert je niet.
func can_interact() -> bool:
	return true


## Voer de interactie uit. `_by` is de aanroepende interactor; vrijwel geen
## enkele prop heeft die nodig, maar het contract geeft de mogelijkheid.
func interact(_by: Node) -> void:
	# Een prop zonder eigen interact() is een contractfout die we nú willen
	# zien, niet stil in een playtest (CODING_STANDARDS §7).
	push_warning("%s: Interactable zonder eigen interact()-implementatie" % name)


## De handelingstekst van dit object ("Open deur", "Lees brief"). Volledig
## data-gedreven (harde eis GD): de interactor geeft deze tekst letterlijk
## door; de toets-hint komt pas in de UI-laag uit de InputMap.
func prompt_text() -> String:
	return ""
