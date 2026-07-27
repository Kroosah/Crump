extends Node
## EventBus — het centrale doorgeefluik tussen systemen (ARCHITECTURE §4).
##
## Signalen zijn FEITEN ("er is geluid gemaakt op positie X"), geen commando's.
## Wie er iets mee doet, beslist de ontvanger; zenders kennen ontvangers niet.
## Dit bestand bevat uitsluitend signaal-declaraties — geen logica.

## Iets in de wereld maakte geluid. Luidheid is een abstracte waarde in meters
## draagafstand (fluisteren ~2.0, dichtslaande deur ~20.0). CRUMP's gehoor
## (taak 007) en het audiosysteem (taak 005) abonneren zich hierop.
signal noise_made(position: Vector3, loudness: float)

## Een hoofdstuk is gestart (na laden of overgang). GameState zendt dit.
signal chapter_started(chapter: int)

## De speler is waargenomen door de dreiging (taak 007 zendt dit).
signal player_spotted(player_position: Vector3)

## Een inventory-item is gebruikt; het effect leeft bij de ontvanger (taak 004).
signal item_used(item_id: StringName)

## De interactieprompt moet wijzigen; lege string = geen prompt (taak 003).
signal interact_prompt_changed(text: String)
