extends Interactable
## Houten deur: open/dicht, kan op slot. Draait om zijn eigen oorsprong
## (het scharnier); plaats de scène dus met de root op de scharnierkant.
## Bewust geen class_name — niemand mag dit type kennen (taakdossier 003).
##
## Geen animatie (buiten scope): de deur klapt in één physics-frame om.
## Het geluid is er wél — een deur is een gebeurtenis (HORROR_GUIDELINES §3).

## De deur is van stand gewisseld. Feit, geen commando: wie er iets mee wil
## (een tochtvlaag, een AI-trigger) abonneert zich zelf.
signal toggled(is_open: bool)

@export_group("Door")
## Op slot: de deur praat terug via de prompt maar gaat niet open.
## Ontgrendelen bestaat nog niet (sleutels komen met de inventory, taak 004).
@export var locked := false
## Openingshoek in graden rond het scharnier; negatief = andere kant op.
@export var open_angle_deg := 90.0
## Luidheid (draagafstand in m) van openen/sluiten en van rammelen op slot.
@export var loudness_toggle := 7.0
@export var loudness_locked := 4.0
## Hoorbare cue-id's (taak 005, grensvaluta B2 — de klank leeft in
## SoundResources, niet hier).
@export var cue_open: StringName = &"door_creak_open"
@export var cue_close: StringName = &"door_creak_close"
@export var cue_locked: StringName = &"door_rattle"

@export_group("Prompts")
@export var prompt_open := "Open deur"
@export var prompt_close := "Sluit deur"
@export var prompt_locked := "Op slot"

var _is_open := false


func interact(_by: Node) -> void:
	# Elke actie zendt twee gescheiden feiten (kader 005 §1): gameplay-gehoor
	# (noise_made) en hoorbare audio (audio_cue) — onafhankelijk afstelbaar.
	if locked:
		# Weigeren is hoorbaar: een korte ruk aan een deur die niet meegeeft.
		EventBus.noise_made.emit(global_position, loudness_locked)
		EventBus.audio_cue.emit(cue_locked, global_position)
		return
	_is_open = not _is_open
	rotate_y(deg_to_rad(open_angle_deg if _is_open else -open_angle_deg))
	EventBus.noise_made.emit(global_position, loudness_toggle)
	EventBus.audio_cue.emit(cue_open if _is_open else cue_close,
		global_position)
	toggled.emit(_is_open)


func prompt_text() -> String:
	if locked:
		return prompt_locked
	return prompt_close if _is_open else prompt_open
