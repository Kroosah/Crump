#!/usr/bin/env bash
# Genereert het 2D-werk van de F2-artpass met ImageMagick — zelf
# gegenereerd, geen externe assets (CLAUDE.md: placeholders/2D-werk via een
# tool in tools/, gedocumenteerd in de commit).
#
# Twee soorten output:
#   assets/textures/decals/  — RGBA-decals voor material breakup (vuil,
#       slijtage, vocht, verfschade, krassen, kalk, schoenstrepen). Kleur =
#       vlakke tint, alpha = het patroon; de sterkte regelt de scène.
#   assets/textures/f2/      — vlakke texturen voor wandobjecten
#       (tactiekbord, posters, elftalfoto's, papier, keuringskaart).
#
# Wereldregel (artplan §2.1): gebruikssporen, geen verwaarlozing. Alles
# blijft zwak — de scène draait de sterkte omhoog, nooit de bron.
# Draaien vanuit de projectroot:  bash tools/genereer_f2_textures.sh
set -euo pipefail
DEC="assets/textures/decals"
F2="assets/textures/f2"
mkdir -p "$DEC" "$F2"
FONT="DejaVu-Sans"
FONTB="DejaVu-Sans-Bold"
BLAUW="#0d3f7a"

# Combineert een vlakke kleur met een alfamasker tot één RGBA-decal.
kleur_masker() { # doel kleur masker
	magick -size "$(magick identify -format '%wx%h' "$3")" "xc:$2" \
		"$3" -alpha off -compose CopyOpacity -composite "$1"
}

echo "· decals"

# 1. Vuilrand langs de vloer/wand-overgang: sterk onderaan, uitdovend
#    naar boven, met een onregelmatige bovenrand (plasma-ruis).
magick -size 512x256 gradient:'#000000'-'#ffffff' \
	\( -size 512x256 plasma:fractal -blur 0x6 -normalize -level 25%,100% \) \
	-compose multiply -composite -blur 0x2 -level 0%,88% /tmp/f2_mask.png
kleur_masker "$DEC/vuil_rand.png" '#3b3529' /tmp/f2_mask.png

# 2. Hoekvuil: driehoekig donker veld dat vanuit de hoek uitwaaiert.
magick -size 256x256 xc:black -fill white \
	-draw 'polygon 0,256 0,60 200,256' -blur 0x28 \
	\( -size 256x256 plasma:fractal -blur 0x4 -normalize -level 30%,100% \) \
	-compose multiply -composite -level 0%,80% /tmp/f2_mask.png
kleur_masker "$DEC/vuil_hoek.png" '#37312a' /tmp/f2_mask.png

# 3. Looplijn: de donkere sleet midden op de vloer waar iedereen loopt.
magick -size 512x512 xc:black -fill white \
	-draw 'roundrectangle 150,-40 362,552 90,90' -blur 0x36 \
	\( -size 512x512 plasma:fractal -blur 0x8 -normalize -level 20%,100% \) \
	-compose multiply -composite -level 0%,62% /tmp/f2_mask.png
kleur_masker "$DEC/looplijn.png" '#3a342a' /tmp/f2_mask.png

# 4. Vochtplek: zachte blotch met een iets donkerder kern (geen schimmel).
magick -size 256x256 plasma:fractal -blur 0x10 -normalize \
	-level 45%,95% \
	\( -size 256x256 radial-gradient:white-black \) \
	-compose multiply -composite -level 0%,72% /tmp/f2_mask.png
kleur_masker "$DEC/vocht.png" '#3e4444' /tmp/f2_mask.png

# 5. Verfschade: kleine afgestoten plekjes (licht) met donkere rand.
magick -size 256x256 xc:black -fill white \
	-draw 'ellipse 70,90 13,8 0,360' -draw 'ellipse 120,140 7,10 0,360' \
	-draw 'ellipse 185,70 9,6 0,360' -draw 'ellipse 150,205 6,5 0,360' \
	-draw 'ellipse 60,180 5,7 0,360' \
	-blur 0x1 \
	\( -size 256x256 plasma:fractal -blur 0x1 -normalize -level 20%,100% \) \
	-compose multiply -composite -level 0%,92% /tmp/f2_mask.png
kleur_masker "$DEC/verfschade.png" '#8e8a80' /tmp/f2_mask.png

# 6. Krassen: dunne lichte lijnen, willekeurige hoeken.
magick -size 512x512 xc:black -stroke white -strokewidth 1 \
	-draw 'line 40,60 210,88'   -draw 'line 120,300 400,268' \
	-draw 'line 300,120 470,190' -draw 'line 60,420 260,460' \
	-draw 'line 350,380 500,340' -draw 'line 200,180 240,196' \
	-blur 0x1 -level 0%,70% /tmp/f2_mask.png
kleur_masker "$DEC/krassen.png" '#b9b6ae' /tmp/f2_mask.png

# 7. Veeg-/handsporen: zachte gerichte smeer rond hand-/deurhoogte.
magick -size 256x256 xc:black -fill white \
	-draw 'ellipse 128,128 96,44 0,360' -blur 0x22 \
	\( -size 256x256 plasma:fractal -blur 0x3 -normalize -level 35%,100% \) \
	-compose multiply -composite -level 0%,42% /tmp/f2_mask.png
kleur_masker "$DEC/veeg.png" '#4a4a48' /tmp/f2_mask.png

# 8. Kalkaanslag: lichte verticale sluier voor de doucheovergang.
magick -size 256x512 xc:black -fill white \
	-draw 'rectangle 0,300 256,512' -blur 0x40 \
	\( -size 256x512 plasma:fractal -blur 0x2 -normalize -level 40%,100% \) \
	-compose multiply -composite -level 0%,66% /tmp/f2_mask.png
kleur_masker "$DEC/kalk.png" '#e7ecec' /tmp/f2_mask.png

# 9. Schoenstrepen: korte zwarte vegen van voetbalschoenen op de vloer.
magick -size 512x512 xc:black -stroke white -strokewidth 3 \
	-draw 'line 80,120 190,150'  -draw 'line 210,300 330,286' \
	-draw 'line 330,90 420,140'  -draw 'line 120,400 205,430' \
	-blur 0x3 -level 0%,58% /tmp/f2_mask.png
kleur_masker "$DEC/schoenstreep.png" '#1d1d1f' /tmp/f2_mask.png

echo "· wandobjecten"

# Tactiekbord: whiteboard met een half uitgeveegde 4-3-3 en veegsporen.
magick -size 1024x680 xc:'#eef0ee' \
	-stroke '#9fb3c8' -strokewidth 3 -fill none \
	-draw 'rectangle 60,40 964,640' -draw 'line 512,40 512,640' \
	-draw 'circle 512,340 512,430' \
	-draw 'rectangle 60,200 200,480' -draw 'rectangle 824,200 964,480' \
	-stroke none -fill '#20406e' \
	-draw 'circle 180,340 180,356' -draw 'circle 330,180 330,196' \
	-draw 'circle 330,340 330,356' -draw 'circle 330,500 330,516' \
	-draw 'circle 520,240 520,256' -draw 'circle 520,440 520,456' \
	-fill '#8a1f1f' \
	-draw 'circle 700,200 700,214' -draw 'circle 700,480 700,494' \
	-stroke '#20406e' -strokewidth 5 -fill none \
	-draw 'line 340,190 500,240' -draw 'line 340,500 510,440' \
	-font "$FONT" -pointsize 42 -stroke none -fill '#3b4a5a' \
	-annotate +700+620 'zaterdag 14.30' \
	\( -size 1024x680 xc:black -fill white \
		-draw 'roundrectangle 560,150 900,520 60,60' -blur 0x40 \
		-evaluate multiply 0.20 \) \
	-compose Screen -composite \
	"$F2/tactiekbord.png"

# Poster van de (fictieve) bond — normen en waarden, verschoten.
magick -size 640x900 xc:'#f2efe6' \
	-fill "$BLAUW" -draw 'rectangle 0,0 640,150' \
	-font "$FONTB" -pointsize 58 -fill white -gravity north \
	-annotate +0+30 'NVVB' \
	-font "$FONTB" -pointsize 46 -fill '#1b2733' -gravity north \
	-annotate +0+200 'NORMEN & WAARDEN' \
	-font "$FONT" -pointsize 34 -fill '#3a4655' -gravity north \
	-annotate +0+300 'Respect voor de\nscheidsrechter\n\nLaat de kleedkamer\nachter zoals je hem\nwilt aantreffen\n\nWie het laatst weggaat,\ndoet het licht uit' \
	-modulate 96,78 \
	"$F2/poster_normen.png"

# Elftalfoto's: geen echte gezichten — geblurde silhouetten in twee rijen,
# verschoten kleur, dun passe-partout. Drie varianten (verschillende jaren).
foto() { # doel achtergrond shirt jaartal
	magick -size 720x520 "xc:$2" \
		-fill '#2f3a2b' -draw 'rectangle 0,360 720,520' \
		-fill "$3" \
		-draw 'roundrectangle 60,250 140,380 30,30' \
		-draw 'roundrectangle 175,250 255,380 30,30' \
		-draw 'roundrectangle 290,250 370,380 30,30' \
		-draw 'roundrectangle 405,250 485,380 30,30' \
		-draw 'roundrectangle 520,250 600,380 30,30' \
		-draw 'roundrectangle 115,150 185,255 26,26' \
		-draw 'roundrectangle 240,150 310,255 26,26' \
		-draw 'roundrectangle 365,150 435,255 26,26' \
		-draw 'roundrectangle 490,150 560,255 26,26' \
		-fill '#c8ab92' \
		-draw 'circle 100,240 100,268' -draw 'circle 215,240 215,268' \
		-draw 'circle 330,240 330,268' -draw 'circle 445,240 445,268' \
		-draw 'circle 560,240 560,268' \
		-draw 'circle 150,140 150,166' -draw 'circle 275,140 275,166' \
		-draw 'circle 400,140 400,166' -draw 'circle 525,140 525,166' \
		-blur 0x7 -modulate 100,62 \
		-bordercolor '#efece2' -border 26 \
		-font "$FONT" -pointsize 26 -fill '#5a5750' -gravity south \
		-annotate +0+2 "$4" \
		-bordercolor '#4a3a2a' -border 8 \
		"$1"
}
foto "$F2/elftalfoto_1.png" '#7d8f9c' '#2a4d84' 'seizoen 1998/1999'
foto "$F2/elftalfoto_2.png" '#8b8f84' '#26497e' 'kampioen 4e klasse — 2007'
foto "$F2/elftalfoto_3.png" '#94918a' '#2b5089' 'zaterdag 1 — 2016/2017'

# Wedstrijdformulier: een A5'je dat op de vloer/bank blijft liggen.
magick -size 500x700 xc:'#f6f4ed' \
	-font "$FONTB" -pointsize 34 -fill '#222831' -gravity north \
	-annotate +0+34 'WEDSTRIJDFORMULIER' \
	-font "$FONT" -pointsize 24 -fill '#3a4049' \
	-annotate +0+96 'v.v. Drechtstreek  —  zaterdag' \
	-stroke '#b9b6ae' -strokewidth 2 \
	-draw 'line 40,150 460,150' -draw 'line 40,210 460,210' \
	-draw 'line 40,270 460,270' -draw 'line 40,330 460,330' \
	-draw 'line 40,390 460,390' -draw 'line 40,450 460,450' \
	-draw 'line 40,510 460,510' -draw 'line 40,570 460,570' \
	-stroke none -fill '#2b3550' -font "$FONT" -pointsize 22 \
	-annotate +60+186 '1.   ...........' -annotate +60+246 '2.   ...........' \
	-annotate +60+306 '3.   ...........' -annotate +60+366 '4.   ...........' \
	-modulate 98,90 \
	"$F2/formulier.png"

# Keuringskaartje van de brandblusser.
magick -size 260x360 xc:'#f7f5ee' \
	-fill '#0b7a3b' -draw 'rectangle 0,0 260,70' \
	-font "$FONTB" -pointsize 26 -fill white -gravity north \
	-annotate +0+20 'GEKEURD' \
	-font "$FONT" -pointsize 22 -fill '#2a2f36' -gravity north \
	-annotate +0+110 'brandblusser\n\nvolgende keuring:\nmaart' \
	"$F2/keuringskaart.png"

rm -f /tmp/f2_mask.png
echo "Klaar: $(ls "$DEC" | wc -l) decals in $DEC, $(ls "$F2" | wc -l) texturen in $F2"
