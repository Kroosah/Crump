#!/usr/bin/env bash
# Genereert de bewegwijzering-textures van het clubgebouw (VS-fase G,
# tier F1) met ImageMagick — zelf gegenereerd werk, geen externe assets
# (CLAUDE.md: placeholders/2D-werk via een tool in tools/, gedocumenteerd).
# Stijl: wit op clubblauw (D-031), DejaVu Sans Bold; nooduitgang wit op
# groen; het gevonden-voorwerpen-briefje donker op wit.
# Draaien vanuit de projectroot:  bash tools/genereer_bordjes.sh
set -euo pipefail
UIT="assets/textures/bordjes"
mkdir -p "$UIT"
BLAUW="#0d3f7a"   # clubblauw VV Drechtstreek (richting RAL 5010)
GROEN="#0b7a3b"
FONT="DejaVu-Sans-Bold"

bord() { # naam breedte hoogte tekst achtergrond puntgrootte
	convert -size "$2x$3" "xc:$5" -font "$FONT" -pointsize "$6" \
		-fill white -gravity center -annotate 0 "$4" \
		-bordercolor "$5" -border 6 "$UIT/$1.png"
}

bord naambord      1400 240 "v.v. DRECHTSTREEK\nSPORTPARK OOSTPOLDER" "$BLAUW" 72
bord kleedkamers   900 190 "KLEEDKAMERS  →" "$BLAUW" 96
bord kantine       800 190 "KANTINE" "$BLAUW" 96
bord bestuur       640 170 "BESTUUR" "$BLAUW" 88
bord kleedkamer3   760 210 "KLEEDKAMER 3" "$BLAUW" 88
bord kleedkamer4   760 210 "KLEEDKAMER 4" "$BLAUW" 88
bord toiletten     760 210 "TOILETTEN" "$BLAUW" 88
bord onderhoud     980 170 "ONDERHOUD\nverboden voor onbevoegden" "$BLAUW" 56
bord nooduitgang   760 180 "NOODUITGANG" "$GROEN" 82

# Gevonden-voorwerpen-mededeling: een geprint A5'je, geen kunststof bord.
convert -size 640x460 xc:white -font "$FONT" -pointsize 44 -fill "#222831" \
	-gravity center -annotate 0 "SPULLEN LATEN LIGGEN?\n\nGevonden voorwerpen\ngaan naar de\nONDERHOUDSRUIMTE\n\n— de beheerder" \
	-bordercolor white -border 14 "$UIT/gevonden_voorwerpen.png"

echo "Bordjes gegenereerd in $UIT/"
