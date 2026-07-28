class_name DocumentResource
extends Resource
## Inhoud van één leesbaar document (taak 007). Data, geen gedrag
## (CODING_STANDARDS §5); runtime read-only — niemand muteert de velden
## (zelfde regime als ItemResource/SoundResource). "Kort en scanbaar"
## (LEVEL §8) is een redactionele regel voor de schrijvers, bewust géén
## code-limiet.

## Identiteit: verplicht en uniek; de suite dwingt dit af over de
## documents-map (zelfde discipline als items en sounds).
@export var id: StringName = &""

## Optionele kop boven de tekst; leeg = geen titelregel in de lezer.
@export var title := ""

## De volledige tekst, letterlijk getoond; opmaak is aan de UI.
@export_multiline var text := ""
