class_name ItemResource
extends Resource
## Datamodel voor een draagbaar item (taak 004). Data, geen gedrag
## (CODING_STANDARDS §5): effecten van items leven bij hun ontvangers.
##
## Runtime READ-ONLY configuratiedata (invariant GD, 2026-07-28): geen
## enkel systeem — inventory, pickup of anders — muteert deze velden.
## De inventory bewaart uitsluitend referenties naar geldige definities.
##
## Bewust minimaal (dossier 004 §3): usable/key_id/max_stack bestaan pas
## wanneer de taak die ze nodig heeft er is — additief, zonder breuk.

## Identiteit: verplicht, uniek en stabiel — dit wordt de save-sleutel.
## Twee .tres-definities met dezelfde id zijn een configuratiefout; de
## smoke-suite dwingt uniciteit af over de items-map (dossier §4).
@export var id: StringName = &""

## Naam voor speler-teksten (Nederlands).
@export var display_name := ""

## Eén à twee zinnen voor de latere UI; mag leeg blijven.
@export_multiline var description := ""

## Icoon voor de latere UI; placeholder mag leeg tot de UI-taak.
@export var icon: Texture2D
