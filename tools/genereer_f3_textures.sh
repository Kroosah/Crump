#!/usr/bin/env bash
# Genereert het 2D-werk van de F3-artpass (bestuurskamer, hal, entree-
# buitenkant) met ImageMagick — zelfde werkwijze als tier F2
# (tools/genereer_f2_textures.sh): zelf gegenereerd, geen externe assets.
#
# Output:
#   assets/textures/decals/  — RGBA-decals (plassen, natte gevelvoet,
#       druppelsporen, onkruid, koffiekringen) + één ORM-decal voor de
#       gladheid van plassen (groen kanaal = roughness).
#   assets/textures/f3/      — vlakke texturen voor wandobjecten en
#       panelen (whiteboard, luchtfoto, oprichtingsdocument, archief-
#       etiket, kalender, prikbord, deurmat, vaan, regenstreep).
#
# Wereldregel (artplan §2.1): gebruikssporen, geen verwaarlozing; tekst
# is Nederlands en alleen leesbaar wat de speler van dichtbij bekijkt.
# Draaien vanuit de projectroot:  bash tools/genereer_f3_textures.sh
set -euo pipefail
DEC="assets/textures/decals"
F3="assets/textures/f3"
mkdir -p "$DEC" "$F3"
FONT="DejaVu-Sans"
FONTB="DejaVu-Sans-Bold"
BLAUW="#0d3f7a"

kleur_masker() { # doel kleur masker
	magick -size "$(magick identify -format '%wx%h' "$3")" "xc:$2" \
		"$3" -alpha off -compose CopyOpacity -composite "$1"
}

echo "· decals"

# 1. Plas: onregelmatige waterplas op asfalt. Albedo maakt het asfalt
#    iets donkerder; de bijbehorende ORM-decal maakt het écht glad.
magick -size 512x384 xc:black -fill white \
	-draw 'ellipse 256,192 190,110 0,360' -blur 0x30 \
	\( -size 512x384 plasma:fractal -blur 0x10 -normalize -level 30%,100% \) \
	-compose multiply -composite -level 18%,85% -blur 0x4 /tmp/f3_mask.png
kleur_masker "$DEC/plas.png" '#0c1016' /tmp/f3_mask.png

# 2. Plas-ORM: zelfde vorm; R = AO (neutraal hoog), G = roughness (bijna
#    nul → spiegelend nat), B = metallic (0).
magick /tmp/f3_mask.png -fill '#e60e00' -colorize 100 \
	/tmp/f3_mask.png -alpha off -compose CopyOpacity -composite \
	"$DEC/plas_orm.png"

# 3. Natte gevelvoet: opgetrokken vocht boven de plint — sterk onderaan,
#    onregelmatige bovenrand, koel donker.
magick -size 512x256 gradient:'#000000'-'#ffffff' \
	\( -size 512x256 plasma:fractal -blur 0x8 -normalize -level 20%,100% \) \
	-compose multiply -composite -blur 0x3 -level 0%,80% /tmp/f3_mask.png
kleur_masker "$DEC/nat_rand.png" '#171c22' /tmp/f3_mask.png

# 4. Druppelspoor: natte voetstappen/druppels net binnen de entree.
magick -size 384x384 xc:black -fill white \
	-draw 'ellipse 120,90 26,14 0,360' -draw 'ellipse 210,150 20,11 0,360' \
	-draw 'ellipse 150,230 24,13 0,360' -draw 'ellipse 260,280 16,9 0,360' \
	-draw 'ellipse 90,300 12,7 0,360'  -draw 'ellipse 300,120 10,6 0,360' \
	-blur 0x5 \
	\( -size 384x384 plasma:fractal -blur 0x3 -normalize -level 30%,100% \) \
	-compose multiply -composite -level 0%,62% /tmp/f3_mask.png
kleur_masker "$DEC/druppelspoor.png" '#23282e' /tmp/f3_mask.png

# 5. Onkruid: lage groene pollen langs randen en naden (buiten).
magick -size 512x256 xc:black -fill white \
	-draw 'ellipse 70,215 26,38 0,360'  -draw 'ellipse 160,225 18,26 0,360' \
	-draw 'ellipse 250,210 30,42 0,360' -draw 'ellipse 350,228 15,22 0,360' \
	-draw 'ellipse 440,215 24,34 0,360' \
	-blur 0x6 \
	\( -size 512x256 plasma:fractal -blur 0x2 -normalize -level 15%,100% \) \
	-compose multiply -composite -level 0%,78% /tmp/f3_mask.png
kleur_masker "$DEC/onkruid.png" '#2c3a22' /tmp/f3_mask.png

# 6. Koffiekring: twee halve ringen op bureaubladhoogte.
magick -size 256x256 xc:black -stroke white -strokewidth 4 -fill none \
	-draw 'ellipse 110,120 42,40 20,300' -draw 'ellipse 160,160 34,33 130,360' \
	-blur 0x2 -level 0%,55% /tmp/f3_mask.png
kleur_masker "$DEC/koffiekring.png" '#3a2d20' /tmp/f3_mask.png

echo "· wandobjecten en panelen"

# Whiteboard bestuurskamer: agenda half uitgewist — de vorige vergadering
# is nooit netjes afgesloten.
magick -size 1024x680 xc:'#eef0ed' \
	-font "$FONTB" -pointsize 44 -fill '#26436d' \
	-annotate +70+90 'AGENDA' \
	-font "$FONT" -pointsize 34 -fill '#31507e' \
	-annotate +70+170 '1. notulen vorige verg.' \
	-annotate +70+230 '2. kantinebezetting' \
	-annotate +70+290 '3. ALV - najaar' \
	-annotate +70+350 '4. verlichting veld 2' \
	-annotate +70+410 '5. rondvraag' \
	-font "$FONT" -pointsize 30 -fill '#4a6285' \
	-annotate +640+200 'wie sluit af?' \
	\( -size 1024x680 xc:black -fill white \
		-draw 'roundrectangle 380,300 980,600 80,80' \
		-draw 'roundrectangle 500,80 900,260 60,60' -blur 0x34 \
		-evaluate multiply 0.55 \) \
	-compose Screen -composite \
	\( -size 1024x680 plasma:fractal -colorspace Gray -blur 0x9 \
		-normalize +level 82%,100% \) -compose multiply -composite \
	"$F3/whiteboard_agenda.png"

# Verkleurde luchtfoto van Sportpark Oostpolder, jaren tachtig: velden,
# sloten en het clubgebouw — sepia, vaag, met witte fotorand.
magick -size 800x560 xc:'#5d6b4e' \
	-fill '#4c5a41' -draw 'rectangle 60,60 420,300' \
	-fill '#55654a' -draw 'rectangle 440,80 740,320' \
	-fill '#47543d' -draw 'rectangle 120,330 480,500' \
	-stroke '#c8c3b0' -strokewidth 4 -fill none \
	-draw 'rectangle 60,60 420,300' -draw 'rectangle 440,80 740,320' \
	-draw 'rectangle 120,330 480,500' \
	-stroke none -fill '#8b877a' -draw 'rectangle 500,340 640,420' \
	-fill '#3d4a56' -draw 'line 0,520 800,540' \
	-stroke '#6b7a5c' -strokewidth 8 \
	-draw 'line 0,320 800,330' -draw 'line 430,0 435,560' \
	-blur 0x3 -modulate 105,44 -fill '#b09a6e' -colorize 30 \
	-bordercolor '#e8e4d6' -border 28 -resize 800x560! \
	"$F3/luchtfoto.png"

# Oprichtingsdocument in lijst: sierrand, leesbare kop, verder
# suggestie-regels (geen lorem — gewoon geen tekst, alleen lijnen).
magick -size 560x760 xc:'#efe8d4' \
	-stroke '#8a7c5a' -strokewidth 6 -fill none \
	-draw 'rectangle 30,30 530,730' \
	-stroke '#b3a67f' -strokewidth 2 -draw 'rectangle 44,44 516,716' \
	-stroke none -font "$FONTB" -pointsize 40 -fill '#4a3f2a' -gravity north \
	-annotate +0+80 'OPRICHTINGSAKTE' \
	-font "$FONTB" -pointsize 34 -fill "$BLAUW" \
	-annotate +0+150 'v.v. DRECHTSTREEK' \
	-font "$FONT" -pointsize 26 -fill '#5a4f38' \
	-annotate +0+210 '12 maart 1957' \
	-stroke '#7a6f52' -strokewidth 2 \
	-draw 'line 90,300 470,300' -draw 'line 90,340 470,340' \
	-draw 'line 90,380 430,380' -draw 'line 90,420 470,420' \
	-draw 'line 90,460 450,460' -draw 'line 90,500 470,500' \
	-draw 'line 90,540 410,540' \
	-draw 'line 300,620 460,640' \
	-modulate 100,82 \
	"$F3/oprichting.png"

# Oude elftalfoto (jaren zeventig/tachtig): zelfde silhouet-aanpak als
# tier F2, maar in sepia met een gescheurd hoekje aan sfeer.
magick -size 720x520 xc:'#8e8570' \
	-fill '#585444' -draw 'rectangle 0,360 720,520' \
	-fill '#6e6752' \
	-draw 'ellipse 90,230 28,64 0,360'  -draw 'ellipse 175,225 28,64 0,360' \
	-draw 'ellipse 260,232 28,64 0,360' -draw 'ellipse 345,226 28,64 0,360' \
	-draw 'ellipse 430,230 28,64 0,360' -draw 'ellipse 515,228 28,64 0,360' \
	-draw 'ellipse 600,232 28,64 0,360' \
	-fill '#655e4b' \
	-draw 'ellipse 130,350 30,58 0,360' -draw 'ellipse 225,352 30,58 0,360' \
	-draw 'ellipse 320,348 30,58 0,360' -draw 'ellipse 415,352 30,58 0,360' \
	-draw 'ellipse 510,350 30,58 0,360' \
	-fill '#4e4a3c' \
	-draw 'ellipse 90,175 16,18 0,360'  -draw 'ellipse 175,170 16,18 0,360' \
	-draw 'ellipse 260,177 16,18 0,360' -draw 'ellipse 345,171 16,18 0,360' \
	-draw 'ellipse 430,175 16,18 0,360' -draw 'ellipse 515,173 16,18 0,360' \
	-draw 'ellipse 600,177 16,18 0,360' \
	-draw 'ellipse 130,296 17,19 0,360' -draw 'ellipse 225,298 17,19 0,360' \
	-draw 'ellipse 320,294 17,19 0,360' -draw 'ellipse 415,298 17,19 0,360' \
	-draw 'ellipse 510,296 17,19 0,360' \
	-blur 0x7 \
	-font "$FONT" -pointsize 28 -fill '#3e3a30' -gravity south \
	-annotate +0+18 'Eerste elftal - kampioen 1979' \
	-modulate 102,30 -fill '#a8895a' -colorize 30 \
	-bordercolor '#ded8c4' -border 22 -resize 720x520! \
	"$F3/elftalfoto_oud.png"

# Archiefdoos-etiket: wit label met handgeschreven opschrift.
magick -size 420x180 xc:'#e9e6da' \
	-stroke '#b9b4a2' -strokewidth 3 -fill none -draw 'rectangle 8,8 412,172' \
	-stroke none -font "$FONT" -pointsize 46 -fill '#2b3a55' \
	-annotate 357x357+52+96 'NOTULEN' \
	-font "$FONT" -pointsize 34 -fill '#37517a' \
	-annotate 357x357+120+148 '2019-2023' \
	"$F3/archief_etiket.png"

# Tweede etiket voor de andere dozen.
magick -size 420x180 xc:'#e7e3d5' \
	-stroke '#b9b4a2' -strokewidth 3 -fill none -draw 'rectangle 8,8 412,172' \
	-stroke none -font "$FONT" -pointsize 40 -fill '#33415c' \
	-annotate 356x356+34+92 'LEDENADMIN.' \
	-font "$FONT" -pointsize 32 -fill '#41546f' \
	-annotate 356x356+120+146 'oud' \
	"$F3/archief_etiket_2.png"

# Jaarkalender bestuurskamer: augustus, één datum omcirkeld (blauw —
# rood blijft gereserveerd, artplan §2.3).
magick -size 460x640 xc:'#f2efe6' \
	-fill "$BLAUW" -draw 'rectangle 0,0 460,110' \
	-font "$FONTB" -pointsize 52 -fill white -gravity north \
	-annotate +0+28 'AUGUSTUS' \
	-gravity none -stroke '#9aa4ae' -strokewidth 2 \
	-draw 'line 30,180 430,180' -draw 'line 30,250 430,250' \
	-draw 'line 30,320 430,320' -draw 'line 30,390 430,390' \
	-draw 'line 30,460 430,460' -draw 'line 30,530 430,530' \
	-draw 'line 90,140 90,560'  -draw 'line 147,140 147,560' \
	-draw 'line 204,140 204,560' -draw 'line 261,140 261,560' \
	-draw 'line 318,140 318,560' -draw 'line 375,140 375,560' \
	-stroke '#2b4a78' -strokewidth 4 -fill none \
	-draw 'ellipse 232,285 24,22 0,360' \
	-stroke none -font "$FONT" -pointsize 22 -fill '#57616c' \
	-annotate +36+600 'ALV: zaal reserveren!' \
	-modulate 98,86 \
	"$F3/kalender.png"

# Prikbord hal: kurk met vier opgeprikte papieren — kantinerooster,
# mededeling, wedstrijdprogramma en een geel memobriefje.
magick -size 1024x700 xc:'#a5794e' \
	\( -size 1024x700 plasma:fractal -colorspace Gray -blur 0x2 \
		-normalize +level 52%,100% \) \
	-compose multiply -composite \
	\( -size 300x380 xc:'#f4f1e8' \
		-font "$FONTB" -pointsize 30 -fill "$BLAUW" -gravity north \
		-annotate +0+20 'KANTINE-' -annotate +0+56 'ROOSTER' \
		-stroke '#8b93a0' -strokewidth 2 \
		-draw 'line 30,130 270,130' -draw 'line 30,180 270,180' \
		-draw 'line 30,230 270,230' -draw 'line 30,280 270,280' \
		-draw 'line 30,330 270,330' -rotate 2 \) \
	-geometry +60+60 -compose over -composite \
	\( -size 330x240 xc:'#f2efe4' \
		-font "$FONTB" -pointsize 26 -fill '#31404f' -gravity north \
		-annotate +0+18 'MEDEDELING' \
		-font "$FONT" -pointsize 22 -fill '#46525e' \
		-annotate +0+70 'Ballen horen in het\nballenhok, niet in\nde gang.\n\n— het bestuur' \
		-rotate -1 \) \
	-geometry +420+60 -compose over -composite \
	\( -size 330x280 xc:'#eef0f2' \
		-font "$FONTB" -pointsize 24 -fill "$BLAUW" -gravity north \
		-annotate +0+16 'PROGRAMMA' \
		-stroke '#9aa4ae' -strokewidth 2 \
		-draw 'line 24,80 306,80' -draw 'line 24,124 306,124' \
		-draw 'line 24,168 306,168' -draw 'line 24,212 306,212' \
		-rotate 1 \) \
	-geometry +420+340 -compose over -composite \
	\( -size 220x180 xc:'#efe28a' \
		-font "$FONT" -pointsize 24 -fill '#5a4f28' -gravity center \
		-annotate +0+0 'sleutel bij\nJoop ophalen' -rotate -3 \) \
	-geometry +120+480 -compose over -composite \
	-fill '#38424e' \
	-draw 'circle 210,68 210,74' -draw 'circle 585,70 585,76' \
	-draw 'circle 585,350 585,356' -draw 'circle 228,492 228,498' \
	"$F3/prikbord_hal.png"

# Deurmat entree: donkere kokosmat met clubnaam.
magick -size 720x420 xc:'#3a332a' \
	\( -size 720x420 plasma:fractal -colorspace Gray -blur 0x1 \
		-normalize +level 42%,100% \) \
	-compose multiply -composite \
	-stroke '#5b5342' -strokewidth 5 -fill none \
	-draw 'ellipse 360,210 290,140 0,360' \
	-stroke none -font "$FONTB" -pointsize 64 -fill '#8f8770' -gravity center \
	-annotate +0-20 'v.v. DRECHTSTREEK' \
	-font "$FONT" -pointsize 36 -fill '#6e6754' \
	-annotate +0+60 'welkom' \
	-modulate 100,70 \
	"$F3/deurmat_logo.png"

# Kampioensvaan (driehoek, alpha): clubblauw met witte rand.
magick -size 360x560 xc:none \
	-fill "$BLAUW" -draw 'polygon 10,10 350,10 180,545' \
	-fill none -stroke '#e8e6df' -strokewidth 8 \
	-draw 'polygon 22,22 338,22 180,525' \
	-stroke none -font "$FONTB" -pointsize 40 -fill white -gravity north \
	-annotate +0+60 'KAMPIOEN' \
	-font "$FONT" -pointsize 34 -annotate +0+120 '4e klasse' \
	-font "$FONTB" -pointsize 44 -annotate +0+180 '2019' \
	"$F3/vaan.png"

# Briefje naast het sleutelkastje.
magick -size 280x360 xc:'#f0ecdd' \
	-font "$FONT" -pointsize 34 -fill '#3c465a' -gravity center \
	-annotate +0-10 'Sleutels\nTERUG in\nhet kastje!' \
	-font "$FONT" -pointsize 20 -fill '#66707e' -gravity south \
	-annotate +0+34 'anders zoeken we weer' \
	-modulate 100,88 \
	"$F3/briefje_sleutels.png"

# Regenstreep voor de particles: smalle zachte verticale veeg.
magick -size 32x128 xc:none \
	-fill 'rgba(210,222,238,0.95)' -draw 'rectangle 14,6 18,122' \
	-blur 0x3 -channel A -evaluate multiply 0.8 +channel \
	"$F3/regendruppel.png"

rm -f /tmp/f3_mask.png
echo "F3-textures gegenereerd in $DEC en $F3."
