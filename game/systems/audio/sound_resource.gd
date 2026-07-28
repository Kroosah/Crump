class_name SoundResource
extends Resource
## Definitie van één hoorbaar geluid (taak 005, dossier §3). Data, geen
## gedrag (CODING_STANDARDS §5). Het `id` is de grensvaluta: bronnen noemen
## alleen dit StringName in `audio_cue`; alle akoestische eigenschappen
## (bus, volume, pitch, afstand) leven híér — nooit in props (keuze B2).
##
## Kader §8: elk geluid dient een benoemd doel (sfeer/informatie/spanning);
## de doelentabel staat in tasks/005_audio.md. Samples bevatten geen
## ingebakken ruimte-galm (dossier §12: zone-neutraal).

## Identiteit: verplicht, uniek en stabiel; de suite dwingt dat af over de
## sounds-map (zelfde discipline als items, dossier 004 §4).
@export var id: StringName = &""

## 1..n varianten; afspelen kiest willekeurig — dezelfde deur klinkt nooit
## twee keer identiek (P7: herhaling doodt onbehagen).
@export var streams: Array[AudioStream] = []

## Doelbus; moet bestaan in AudioDirector.BUSES.
@export var bus: StringName = &"SFX"

## Basisvolume in dB.
@export var volume_db := 0.0

## ± willekeurige pitchvariatie per afspeling (0 = uit).
@export var pitch_spread := 0.0

## 3D-draagafstand van het hóórbare geluid. Tuning-richtlijn: zelfde orde
## als de noise_made-luidheid van dezelfde actie (HORROR §3); bewust
## afwijken is een ontwerpkeuze (P7), geen bug.
@export var max_distance := 15.0

## Positioneel (3D op de event-positie) of niet (ambience/muziek/2D).
## Niet-positionele cues spelen nooit op een willekeurige 3D-plek
## (kwaliteitseis GD, 2026-07-28).
@export var positional := true
