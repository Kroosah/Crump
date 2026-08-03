extends Node3D
## Het clubgebouw van VV Drechtstreek (VS-fase C): de eerste echte
## locatie van CRUMP — het clubhuis onder de hoofdtribune, 's nachts, in
## de regenlucht van Sportpark Oostpolder. Greybox: eenvoudige volumes,
## realistische architectuur (LEVEL §6: menselijke maat; §2: leesbaar in
## het donker). Plattegrond volgt tasks/008 §2/§3.
##
## De greybox is bewust DATA (tabellen hieronder, patroon dev_props):
## elke maat is één getal wijzigen — snel itereren op GD-feedback over
## schaal en zichtlijnen. De art-pass (fase G) vervangt deze volumes
## door echte scènes; deuren en TL-armaturen zijn nu al de echte props,
## geplaatst met bestaanscheck (D-015: prop-map weg = level draait door).
##
## Assenstelsel: x+ = oost, z+ = zuid (het veld ligt ten noorden).
## Alle vloeren liggen op y = 0 (geen drempels); wanden zijn 0,2 m dik
## en lopen tot y = 2,9 onder het dak; plafonds per ruimte op hun eigen
## realistische hoogte (kantine 2,7 · hal 2,6 · kleedkamers 2,5 · gang/
## toiletten 2,4 · douches/onderhoud 2,3).

## true = heldere inspectiestand; false (default) = nachtstaat.
@export var werklicht := false

const LIGHT_TL_SCENE := "res://game/props/light_tl/light_tl.tscn"
const DOOR_SCENE := "res://game/props/door_wooden/door_wooden.tscn"
## De F2-detaillaag (kleedkamer 3 + gang). Aanwezig = de echte props;
## afwezig = de F1-greybox draait ongewijzigd door (D-015).
const F2_DETAIL_SCENE := "res://game/levels/clubgebouw/f2_detail/f2_detail.tscn"
## De F3-detaillaag (bestuurskamer, hal, entree-buitenkant) — zelfde
## contract: map weg = het level draait door in de F2.1-staat.
const F3_DETAIL_SCENE := "res://game/levels/clubgebouw/f3_detail/f3_detail.tscn"

## Het hart van de plattegrond; bepaalt welke kant van een gevel "binnen"
## is. De schil is een convexe doos, dus dit ene punt volstaat.
const GEBOUW_MIDDEN := Vector3(-1.4, 1.45, 1.25)
## Dikte van een automatisch afwerkingspaneel (§_build_liner) en hoever
## het vóór het wandvlak uitsteekt.
const LINER_DIKTE := 0.02
const LINER_UITSTEEK := 0.002

## Materialen. Twee vormen (fase G, tier F1):
## - Color: vlakke greybox-kleur (niet-focusruimtes blijven zo);
## - Dictionary: PBR-materiaal uit assets/textures/ (CC0, D-031) met
##   "tex" (setnaam), "tint" (albedo-vermenigvuldiging), "scale"
##   (wereld-triplanair: herhaling per meter), "rough" (factor) en sinds
##   tier F2 "normal" (sterkte normal map) en "metallic".
## Focus-materialen dragen het voorvoegsel f_ (artplan §4).
##
## Tier F2 heeft de schaal van de focusmaterialen geijkt op echte maten
## (tegel 15 cm, baksteen 21 cm): tier F1 gebruikte te grove herhalingen,
## waardoor elke ruimte groter oogde dan hij is. Verder is de blauwzweem
## uit wanden en plafonds gehaald — nachtlicht is al koel genoeg.
const MATERIALS := {
	# — Focusgebied (artplan §4, tier F1, geijkt in F2) —
	&"f_zeil_hal": {"tex": "beton", "tint": Color(0.60, 0.61, 0.64), "scale": 0.3, "rough": 0.65},
	&"f_zeil_gang": {"tex": "granito", "tint": Color(0.34, 0.36, 0.34), "scale": 1.1, "rough": 0.74, "normal": 0.5},
	&"f_stucwerk": {"tex": "stucwerk", "tint": Color(0.90, 0.89, 0.85), "scale": 0.8},
	&"f_metselwerk_wit": {"tex": "metselwerk_wit", "tint": Color(0.76, 0.74, 0.67), "scale": 1.3, "normal": 0.8},
	&"f_systeemplafond": {"tex": "systeemplafond", "tint": Color(0.95, 0.95, 0.95), "scale": 0.55},
	&"f_betonplafond": {"tex": "plafondverf", "tint": Color(0.70, 0.70, 0.68), "scale": 0.4, "rough": 0.95, "normal": 0.1},
	&"f_coating": {"tex": "coating_glad", "tint": Color(0.40, 0.43, 0.45), "scale": 0.5, "rough": 0.74, "normal": 0.8},
	&"f_tegel_wand": {"tex": "tegel_klein_wit", "tint": Color(0.76, 0.75, 0.71), "scale": 0.62, "rough": 0.58, "normal": 0.8},
	&"f_tegel_vloer": {"tex": "tegel_vloer_grijs", "tint": Color(0.68, 0.71, 0.73), "scale": 1.6, "rough": 0.5},
	&"f_tapijt": {"tex": "tapijt", "tint": Color(0.40, 0.44, 0.52), "scale": 2.4, "rough": 0.95},
	&"f_gevel": {"tex": "gevel", "tint": Color(0.92, 0.90, 0.88), "scale": 0.4},
	&"f_asfalt_nat": {"tex": "asfalt", "tint": Color(0.55, 0.60, 0.68), "scale": 0.28, "rough": 0.38},
	&"f_lambrisering": {"tex": "planken", "tint": Color(0.80, 0.72, 0.62), "scale": 0.7},
	&"f_metaal": {"tex": "metaal", "scale": 0.5, "rough": 0.6},
	&"f_kozijn_blauw": {"tint": Color(0.06, 0.17, 0.32), "rough": 0.62},
	&"f_kozijn_staal": {"tint": Color(0.42, 0.44, 0.47), "rough": 0.45},
	&"f_kozijn_wit": {"tint": Color(0.80, 0.80, 0.78), "rough": 0.4},
	# — Greybox (niet-focus, ongewijzigd) —
	&"wand": Color(0.62, 0.62, 0.64),
	&"plafond": Color(0.72, 0.72, 0.74),
	&"beton": Color(0.42, 0.43, 0.45),
	&"beton_donker": Color(0.34, 0.35, 0.37),
	&"vloer_kleed": Color(0.45, 0.42, 0.40),
	&"tegel": Color(0.36, 0.40, 0.46),
	&"verharding": Color(0.38, 0.39, 0.41),
	&"gras": Color(0.22, 0.28, 0.22),
	&"hout": Color(0.45, 0.36, 0.28),
	&"hout_donker": Color(0.33, 0.26, 0.20),
	&"metaal": Color(0.30, 0.32, 0.35),
	&"wit": Color(0.78, 0.79, 0.80),
	&"keramiek": Color(0.75, 0.76, 0.78),
	&"dak": Color(0.30, 0.30, 0.32),
	&"tribune": Color(0.36, 0.37, 0.40),
	&"accent_rood": Color(0.55, 0.16, 0.14),
	&"spiegel": Color(0.25, 0.28, 0.30),
	&"gaas": Color(0.25, 0.27, 0.30, 0.35),
	&"glas": Color(0.55, 0.65, 0.75, 0.22),
}

## Gebouwschil: gevels met deur-/raamopeningen (segmenten + lateien).
## Elke solid: pos (center), size, mat; "nc": true = geen collision.
##
## Sinds de integriteitspass draagt élke gevel hetzelfde metselwerk — de
## noord- en oostgevel stonden nog in greyboxgrijs, wat van buiten las
## als een half afgebouwd gebouw. De binnenzijde volgt uit "binnen":
## één wandblok kan immers maar één materiaal hebben, en het
## buitenmetselwerk hoort niet in de kantine of de toiletten te staan.
const SCHIL: Array[Dictionary] = [
	# Zuidgevel (z 7,0..7,2): hoofdentree + hal-raam.
	{"pos": Vector3(-7.855, 1.45, 7.1), "size": Vector3(14.69, 2.9, 0.2), "mat": &"f_gevel", "binnen": &"f_stucwerk"},
	{"pos": Vector3(0.0, 2.51, 7.1), "size": Vector3(1.02, 0.78, 0.2), "mat": &"f_gevel", "binnen": &"f_stucwerk"},
	{"pos": Vector3(0.755, 1.45, 7.1), "size": Vector3(0.49, 2.9, 0.2), "mat": &"f_gevel", "binnen": &"f_stucwerk"},
	{"pos": Vector3(1.45, 0.45, 7.1), "size": Vector3(0.9, 0.9, 0.2), "mat": &"f_gevel", "binnen": &"f_stucwerk"},
	{"pos": Vector3(1.45, 2.55, 7.1), "size": Vector3(0.9, 0.7, 0.2), "mat": &"f_gevel", "binnen": &"f_stucwerk"},
	# Bestuurskamerraam (tier F3): het artplan gaf de kamer al een
	# vensterbank (§5.8), dus de gevel krijgt het bijbehorende raam —
	# zelfde maat en opbouw als de kantineramen, kozijn uit de glastabel.
	{"pos": Vector3(2.65, 1.45, 7.1), "size": Vector3(1.5, 2.9, 0.2), "mat": &"f_gevel", "binnen": &"f_stucwerk"},
	{"pos": Vector3(8.6, 1.45, 7.1), "size": Vector3(7.6, 2.9, 0.2), "mat": &"f_gevel", "binnen": &"f_stucwerk"},
	{"pos": Vector3(4.1, 0.45, 7.1), "size": Vector3(1.4, 0.9, 0.2), "mat": &"f_gevel", "binnen": &"f_stucwerk"},
	{"pos": Vector3(4.1, 2.6, 7.1), "size": Vector3(1.4, 0.6, 0.2), "mat": &"f_gevel", "binnen": &"f_stucwerk"},
	{"pos": Vector3(4.1, 1.6, 7.1), "size": Vector3(1.4, 1.4, 0.05), "mat": &"glas", "kozijn": &"f_kozijn_wit"},
	{"pos": Vector3(1.45, 1.55, 7.1), "size": Vector3(0.9, 1.3, 0.05), "mat": &"glas", "kozijn": &"f_kozijn_wit"},
	# Noordgevel (z -4,7..-4,5): drie kantineramen op het veld + twee
	# kiepraampjes van de douches.
	{"pos": Vector3(-12.5, 1.45, -4.6), "size": Vector3(5.4, 2.9, 0.2), "mat": &"f_gevel", "binnen": &"wand"},
	{"pos": Vector3(-6.5, 1.45, -4.6), "size": Vector3(3.8, 2.9, 0.2), "mat": &"f_gevel", "binnen": &"wand"},
	{"pos": Vector3(0.1, 1.45, -4.6), "size": Vector3(6.6, 2.9, 0.2), "mat": &"f_gevel", "binnen": &"wand"},
	{"pos": Vector3(-3.9, 0.9, -4.6), "size": Vector3(1.4, 1.8, 0.2), "mat": &"f_gevel", "binnen": &"wand"},
	{"pos": Vector3(-3.9, 2.6, -4.6), "size": Vector3(1.4, 0.6, 0.2), "mat": &"f_gevel", "binnen": &"wand"},
	{"pos": Vector3(-3.9, 2.05, -4.6), "size": Vector3(1.4, 0.5, 0.05), "mat": &"glas", "kozijn": &"f_kozijn_wit"},
	{"pos": Vector3(-9.1, 0.9, -4.6), "size": Vector3(1.4, 1.8, 0.2), "mat": &"f_gevel", "binnen": &"wand"},
	{"pos": Vector3(-9.1, 2.6, -4.6), "size": Vector3(1.4, 0.6, 0.2), "mat": &"f_gevel", "binnen": &"wand"},
	{"pos": Vector3(-9.1, 2.05, -4.6), "size": Vector3(1.4, 0.5, 0.05), "mat": &"glas", "kozijn": &"f_kozijn_wit"},
	{"pos": Vector3(5.9, 1.45, -4.6), "size": Vector3(1.0, 2.9, 0.2), "mat": &"f_gevel", "binnen": &"wand"},
	{"pos": Vector3(8.9, 1.45, -4.6), "size": Vector3(1.0, 2.9, 0.2), "mat": &"f_gevel", "binnen": &"wand"},
	{"pos": Vector3(11.9, 1.45, -4.6), "size": Vector3(1.0, 2.9, 0.2), "mat": &"f_gevel", "binnen": &"wand"},
	{"pos": Vector3(4.4, 0.45, -4.6), "size": Vector3(2.0, 0.9, 0.2), "mat": &"f_gevel", "binnen": &"wand"},
	{"pos": Vector3(4.4, 2.6, -4.6), "size": Vector3(2.0, 0.6, 0.2), "mat": &"f_gevel", "binnen": &"wand"},
	{"pos": Vector3(4.4, 1.6, -4.6), "size": Vector3(2.0, 1.4, 0.05), "mat": &"glas", "kozijn": &"f_kozijn_wit"},
	{"pos": Vector3(7.4, 0.45, -4.6), "size": Vector3(2.0, 0.9, 0.2), "mat": &"f_gevel", "binnen": &"wand"},
	{"pos": Vector3(7.4, 2.6, -4.6), "size": Vector3(2.0, 0.6, 0.2), "mat": &"f_gevel", "binnen": &"wand"},
	{"pos": Vector3(7.4, 1.6, -4.6), "size": Vector3(2.0, 1.4, 0.05), "mat": &"glas", "kozijn": &"f_kozijn_wit"},
	{"pos": Vector3(10.4, 0.45, -4.6), "size": Vector3(2.0, 0.9, 0.2), "mat": &"f_gevel", "binnen": &"wand"},
	{"pos": Vector3(10.4, 2.6, -4.6), "size": Vector3(2.0, 0.6, 0.2), "mat": &"f_gevel", "binnen": &"wand"},
	{"pos": Vector3(10.4, 1.6, -4.6), "size": Vector3(2.0, 1.4, 0.05), "mat": &"glas", "kozijn": &"f_kozijn_wit"},
	# Westgevel (x -15,2..-15,0): nooddeur uit de gang.
	{"pos": Vector3(-15.1, 1.45, -0.45), "size": Vector3(0.2, 2.9, 8.5), "mat": &"f_gevel", "binnen": &"f_metselwerk_wit"},
	{"pos": Vector3(-15.1, 2.51, 4.31), "size": Vector3(0.2, 0.78, 1.02), "mat": &"f_gevel", "binnen": &"f_metselwerk_wit"},
	{"pos": Vector3(-15.1, 1.45, 6.01), "size": Vector3(0.2, 2.9, 2.38), "mat": &"f_gevel", "binnen": &"f_metselwerk_wit"},
	# Oostgevel (x 12,2..12,4): terrasdeur (op slot).
	{"pos": Vector3(12.3, 1.45, -4.1), "size": Vector3(0.2, 2.9, 1.2), "mat": &"f_gevel", "binnen": &"wand"},
	{"pos": Vector3(12.3, 2.51, -2.99), "size": Vector3(0.2, 0.78, 1.02), "mat": &"f_gevel", "binnen": &"wand"},
	{"pos": Vector3(12.3, 1.45, 2.36), "size": Vector3(0.2, 2.9, 9.68), "mat": &"f_gevel", "binnen": &"wand"},
]

## Vloeren (top op y = 0) en plafonds per ruimte.
const VLOEREN: Array[Dictionary] = [
	{"pos": Vector3(0.0, -0.1, 4.6), "size": Vector3(4.4, 0.2, 5.0), "mat": &"f_zeil_hal"},
	{"pos": Vector3(7.15, -0.1, -0.45), "size": Vector3(10.3, 0.2, 8.3), "mat": &"beton"},
	{"pos": Vector3(4.1, -0.1, 5.3), "size": Vector3(4.2, 0.2, 3.6), "mat": &"f_tapijt"},
	{"pos": Vector3(10.35, -0.1, 5.3), "size": Vector3(3.9, 0.2, 3.6), "mat": &"beton"},
	{"pos": Vector3(-8.55, -0.1, 4.3), "size": Vector3(13.1, 0.2, 2.2), "mat": &"f_zeil_gang"},
	{"pos": Vector3(-4.7, -0.1, 0.95), "size": Vector3(5.0, 0.2, 4.9), "mat": &"f_coating"},
	{"pos": Vector3(-9.3, -0.1, 0.95), "size": Vector3(4.6, 0.2, 4.9), "mat": &"f_coating"},
	{"pos": Vector3(-3.8, -0.1, -2.95), "size": Vector3(3.2, 0.2, 3.3), "mat": &"f_tegel_vloer"},
	{"pos": Vector3(-9.0, -0.1, -2.95), "size": Vector3(3.2, 0.2, 3.3), "mat": &"f_tegel_vloer"},
	{"pos": Vector3(-5.1, -0.1, 6.15), "size": Vector3(3.4, 0.2, 1.9), "mat": &"tegel"},
	{"pos": Vector3(-13.2, -0.1, 1.15), "size": Vector3(3.6, 0.2, 4.5), "mat": &"beton_donker"},
	{"pos": Vector3(-8.0, -0.1, 5.8), "size": Vector3(1.6, 0.2, 1.0), "mat": &"beton"},
]

const PLAFONDS: Array[Dictionary] = [
	{"pos": Vector3(0.0, 2.675, 4.6), "size": Vector3(4.4, 0.15, 5.0), "mat": &"f_systeemplafond"},
	{"pos": Vector3(7.15, 2.775, -0.45), "size": Vector3(10.3, 0.15, 8.3), "mat": &"plafond"},
	{"pos": Vector3(4.1, 2.475, 5.3), "size": Vector3(4.2, 0.15, 3.6), "mat": &"f_systeemplafond"},
	{"pos": Vector3(10.35, 2.475, 5.3), "size": Vector3(3.9, 0.15, 3.6), "mat": &"plafond"},
	{"pos": Vector3(-8.55, 2.475, 4.3), "size": Vector3(13.1, 0.15, 2.2), "mat": &"f_betonplafond"},
	{"pos": Vector3(-4.7, 2.575, 0.95), "size": Vector3(5.0, 0.15, 4.9), "mat": &"f_betonplafond"},
	{"pos": Vector3(-9.3, 2.575, 0.95), "size": Vector3(4.6, 0.15, 4.9), "mat": &"f_betonplafond"},
	{"pos": Vector3(-3.8, 2.375, -2.95), "size": Vector3(3.2, 0.15, 3.3), "mat": &"f_betonplafond"},
	{"pos": Vector3(-9.0, 2.375, -2.95), "size": Vector3(3.2, 0.15, 3.3), "mat": &"f_betonplafond"},
	{"pos": Vector3(-5.1, 2.475, 6.15), "size": Vector3(3.4, 0.15, 1.9), "mat": &"plafond"},
	{"pos": Vector3(-13.2, 2.375, 1.15), "size": Vector3(3.6, 0.15, 4.5), "mat": &"plafond"},
	# Dak + tribune-silhouet erboven (het gebouw zit ónder de tribune).
	{"pos": Vector3(-1.4, 3.0, 1.25), "size": Vector3(28.0, 0.2, 12.3), "mat": &"dak"},
	{"pos": Vector3(-1.4, 3.55, 5.0), "size": Vector3(28.0, 0.9, 4.8), "mat": &"tribune"},
	{"pos": Vector3(-1.4, 4.45, 5.8), "size": Vector3(28.0, 0.9, 3.2), "mat": &"tribune"},
	{"pos": Vector3(-1.4, 5.35, 6.6), "size": Vector3(28.0, 0.9, 1.6), "mat": &"tribune"},
]

## Buitenwereld: voorplein, pad langs het veld, hekwerk, veld en mast.
const BUITEN: Array[Dictionary] = [
	# Verharding en gras (alles top y = 0, geen drempels).
	{"pos": Vector3(-5.8, -0.1, 10.6), "size": Vector3(23.6, 0.2, 6.8), "mat": &"f_asfalt_nat"},
	{"pos": Vector3(-16.4, -0.1, 1.25), "size": Vector3(2.4, 0.2, 11.9), "mat": &"verharding"},
	{"pos": Vector3(-2.55, -0.1, -5.8), "size": Vector3(30.1, 0.2, 2.2), "mat": &"verharding"},
	{"pos": Vector3(-2.5, -0.1, -25.95), "size": Vector3(55.0, 0.2, 38.1), "mat": &"gras"},
	{"pos": Vector3(9.2, -0.1, 10.6), "size": Vector3(6.4, 0.2, 6.8), "mat": &"gras"},
	# Entree: luifel op twee staanders + lampfitting.
	{"pos": Vector3(0.0, 2.53, 7.85), "size": Vector3(3.2, 0.15, 1.3), "mat": &"dak"},
	{"pos": Vector3(-1.45, 1.229, 8.42), "size": Vector3(0.12, 2.458, 0.12), "mat": &"metaal"},
	{"pos": Vector3(1.45, 1.229, 8.42), "size": Vector3(0.12, 2.458, 0.12), "mat": &"metaal"},
	{"pos": Vector3(0.0, 2.32, 7.14), "size": Vector3(0.3, 0.12, 0.12), "mat": &"metaal", "nc": true},
	# Fietsenrek op het voorplein (tier F3 vervangt de twee vlakken door
	# een echt beugelrek).
	{"pos": Vector3(4.5, 0.4, 12.28), "size": Vector3(2.2, 0.8, 0.14), "mat": &"metaal", "f3": true},
	{"pos": Vector3(4.5, 0.4, 12.62), "size": Vector3(2.2, 0.8, 0.14), "mat": &"metaal", "f3": true},
	# Hekwerk (gaas-suggestie): zuid met poort + ketting, oost, west.
	{"pos": Vector3(-9.4, 0.95, 13.95), "size": Vector3(16.4, 1.7, 0.1), "mat": &"gaas"},
	{"pos": Vector3(3.6, 0.95, 13.95), "size": Vector3(4.8, 1.7, 0.1), "mat": &"gaas"},
	{"pos": Vector3(0.0, 0.95, 13.95), "size": Vector3(2.4, 1.7, 0.1), "mat": &"gaas"},
	{"pos": Vector3(0.0, 1.15, 13.94), "size": Vector3(1.0, 0.12, 0.24), "mat": &"metaal", "nc": true},
	{"pos": Vector3(-17.6, 1.0, 13.95), "size": Vector3(0.12, 2.0, 0.14), "mat": &"metaal"},
	{"pos": Vector3(-9.4, 1.0, 13.95), "size": Vector3(0.12, 2.0, 0.14), "mat": &"metaal"},
	{"pos": Vector3(-1.2, 1.0, 13.95), "size": Vector3(0.12, 2.0, 0.14), "mat": &"metaal"},
	{"pos": Vector3(1.2, 1.0, 13.95), "size": Vector3(0.12, 2.0, 0.14), "mat": &"metaal"},
	{"pos": Vector3(6.0, 1.0, 13.95), "size": Vector3(0.12, 2.0, 0.14), "mat": &"metaal"},
	{"pos": Vector3(5.95, 0.95, 10.65), "size": Vector3(0.1, 1.7, 6.5), "mat": &"gaas"},
	{"pos": Vector3(5.95, 1.0, 7.5), "size": Vector3(0.14, 2.0, 0.12), "mat": &"metaal"},
	{"pos": Vector3(-17.65, 0.95, 3.5), "size": Vector3(0.1, 1.7, 20.8), "mat": &"gaas"},
	{"pos": Vector3(-17.65, 1.0, -6.8), "size": Vector3(0.14, 2.0, 0.12), "mat": &"metaal"},
	{"pos": Vector3(-17.65, 1.0, 3.5), "size": Vector3(0.14, 2.0, 0.12), "mat": &"metaal"},
	{"pos": Vector3(12.45, 0.95, -5.8), "size": Vector3(0.1, 1.7, 2.2), "mat": &"gaas"},
	# Boarding langs het veld (lage witte reclameborden-band).
	{"pos": Vector3(-2.55, 0.5, -6.95), "size": Vector3(30.1, 1.0, 0.1), "mat": &"wit"},
	# Lichtmast 3 (paal + arm + kop; de spot hangt eraan in de scène).
	{"pos": Vector3(-16.6, 5.5, -6.3), "size": Vector3(0.25, 11.0, 0.25), "mat": &"metaal"},
	{"pos": Vector3(-16.6, 10.6, -6.9), "size": Vector3(0.2, 0.2, 1.4), "mat": &"metaal"},
	{"pos": Vector3(-16.6, 10.5, -7.6), "size": Vector3(0.5, 0.3, 0.6), "mat": &"metaal"},
	# Eén doel op het veld — verdwijnt half in de fog: silhouet, geen decor.
	{"pos": Vector3(-3.66, 1.22, -24.0), "size": Vector3(0.1, 2.44, 0.1), "mat": &"wit"},
	{"pos": Vector3(3.66, 1.22, -24.0), "size": Vector3(0.1, 2.44, 0.1), "mat": &"wit"},
	{"pos": Vector3(0.0, 2.49, -24.0), "size": Vector3(7.42, 0.1, 0.1), "mat": &"wit"},
]

## Binnenwanden (0,2 m dik, tot y 2,9) met deuropeningen + lateien.
const INTERIEUR: Array[Dictionary] = [
	# Hal-oost (x 2,0..2,2): doorgang kantine + deur bestuurskamer.
	{"pos": Vector3(2.1, 1.45, 4.27), "size": Vector3(0.2, 2.9, 1.9), "mat": &"f_stucwerk"},
	{"pos": Vector3(2.1, 1.45, 6.62), "size": Vector3(0.2, 2.9, 0.76), "mat": &"f_stucwerk"},
	{"pos": Vector3(2.1, 2.51, 2.81), "size": Vector3(0.2, 0.78, 1.02), "mat": &"f_stucwerk"},
	{"pos": Vector3(2.1, 2.51, 5.73), "size": Vector3(0.2, 0.78, 1.02), "mat": &"f_stucwerk"},
	# Hal-west: deur naar de kleedkamergang.
	{"pos": Vector3(-2.1, 1.45, 3.05), "size": Vector3(0.2, 2.9, 1.5), "mat": &"f_stucwerk", "buiten": &"f_metselwerk_wit"},
	{"pos": Vector3(-2.1, 1.45, 5.91), "size": Vector3(0.2, 2.9, 2.18), "mat": &"f_stucwerk", "buiten": &"f_metselwerk_wit"},
	{"pos": Vector3(-2.1, 2.51, 4.31), "size": Vector3(0.2, 0.78, 1.02), "mat": &"f_stucwerk", "buiten": &"f_metselwerk_wit"},
	# Hal-noord (dicht).
	{"pos": Vector3(0.0, 1.45, 2.2), "size": Vector3(4.4, 2.9, 0.2), "mat": &"f_stucwerk"},
	# Kantine-zuid: keukendeur + doorgeefluik boven de bar.
	{"pos": Vector3(5.5, 1.45, 3.6), "size": Vector3(6.6, 2.9, 0.2), "mat": &"wand"},
	{"pos": Vector3(9.91, 1.45, 3.6), "size": Vector3(0.18, 2.9, 0.2), "mat": &"wand"},
	{"pos": Vector3(11.85, 1.45, 3.6), "size": Vector3(0.7, 2.9, 0.2), "mat": &"wand"},
	{"pos": Vector3(9.31, 2.51, 3.6), "size": Vector3(1.02, 0.78, 0.2), "mat": &"wand"},
	{"pos": Vector3(10.75, 0.525, 3.6), "size": Vector3(1.5, 1.05, 0.2), "mat": &"wand"},
	{"pos": Vector3(10.75, 2.425, 3.6), "size": Vector3(1.5, 0.95, 0.2), "mat": &"wand"},
	# Bestuurskamer- en keukenwanden.
	{"pos": Vector3(6.1, 1.45, 5.35), "size": Vector3(0.2, 2.9, 3.3), "mat": &"f_stucwerk"},
	{"pos": Vector3(8.5, 1.45, 5.35), "size": Vector3(0.2, 2.9, 3.3), "mat": &"wand"},
	# Gang-noord: deuren kleedkamer 3, kleedkamer 4 en onderhoudsruimte.
	{"pos": Vector3(-14.21, 1.45, 3.3), "size": Vector3(1.58, 2.9, 0.2), "mat": &"f_metselwerk_wit"},
	{"pos": Vector3(-11.11, 1.45, 3.3), "size": Vector3(2.58, 2.9, 0.2), "mat": &"f_metselwerk_wit"},
	{"pos": Vector3(-6.61, 1.45, 3.3), "size": Vector3(4.38, 2.9, 0.2), "mat": &"f_metselwerk_wit"},
	{"pos": Vector3(-2.8, 1.45, 3.3), "size": Vector3(1.2, 2.9, 0.2), "mat": &"f_metselwerk_wit"},
	{"pos": Vector3(-12.91, 2.51, 3.3), "size": Vector3(1.02, 0.78, 0.2), "mat": &"f_metselwerk_wit"},
	{"pos": Vector3(-9.31, 2.51, 3.3), "size": Vector3(1.02, 0.78, 0.2), "mat": &"f_metselwerk_wit"},
	{"pos": Vector3(-3.91, 2.51, 3.3), "size": Vector3(1.02, 0.78, 0.2), "mat": &"f_metselwerk_wit"},
	# Gang-zuid: toilettendeur + open schoonmaaknis.
	{"pos": Vector3(-11.8, 1.45, 5.3), "size": Vector3(6.4, 2.9, 0.2), "mat": &"f_metselwerk_wit"},
	{"pos": Vector3(-6.5, 1.45, 5.3), "size": Vector3(1.8, 2.9, 0.2), "mat": &"f_metselwerk_wit"},
	{"pos": Vector3(-3.39, 1.45, 5.3), "size": Vector3(2.38, 2.9, 0.2), "mat": &"f_metselwerk_wit"},
	{"pos": Vector3(-5.09, 2.51, 5.3), "size": Vector3(1.02, 0.78, 0.2), "mat": &"f_metselwerk_wit"},
	{"pos": Vector3(-8.0, 2.55, 5.3), "size": Vector3(1.2, 0.7, 0.2), "mat": &"f_metselwerk_wit"},
	# Kleedkamerblok: oostwand, tussenwand, leidingkoker tussen de douches.
	{"pos": Vector3(-2.3, 1.45, -0.65), "size": Vector3(0.2, 2.9, 7.7), "mat": &"f_metselwerk_wit"},
	{"pos": Vector3(-7.1, 1.45, 0.95), "size": Vector3(0.2, 2.9, 4.5), "mat": &"f_metselwerk_wit"},
	{"pos": Vector3(-6.4, 1.45, -3.0), "size": Vector3(2.4, 2.9, 3.0), "mat": &"f_metselwerk_wit"},
	# Kleedkamer 3 → douche 3 (open doorgang, geen deur).
	{"pos": Vector3(-5.75, 1.45, -1.4), "size": Vector3(2.5, 2.9, 0.2), "mat": &"f_metselwerk_wit"},
	{"pos": Vector3(-2.95, 1.45, -1.4), "size": Vector3(1.1, 2.9, 0.2), "mat": &"f_metselwerk_wit"},
	{"pos": Vector3(-4.0, 2.475, -1.4), "size": Vector3(1.0, 0.85, 0.2), "mat": &"f_metselwerk_wit"},
	# Kleedkamer 4 → douche 4.
	{"pos": Vector3(-10.45, 1.45, -1.4), "size": Vector3(1.9, 2.9, 0.2), "mat": &"f_metselwerk_wit"},
	{"pos": Vector3(-7.85, 1.45, -1.4), "size": Vector3(1.3, 2.9, 0.2), "mat": &"f_metselwerk_wit"},
	{"pos": Vector3(-9.0, 2.475, -1.4), "size": Vector3(1.0, 0.85, 0.2), "mat": &"f_metselwerk_wit"},
	{"pos": Vector3(-10.5, 1.45, -3.0), "size": Vector3(0.2, 2.9, 3.0), "mat": &"f_metselwerk_wit"},
	# Onderhoudsruimte (west van kleedkamer 4).
	{"pos": Vector3(-11.5, 1.45, 0.95), "size": Vector3(0.2, 2.9, 4.5), "mat": &"f_metselwerk_wit"},
	{"pos": Vector3(-13.2, 1.45, -1.0), "size": Vector3(3.6, 2.9, 0.2), "mat": &"wand"},
	# Toiletten + schoonmaaknis (zuid van de gang).
	{"pos": Vector3(-6.7, 1.45, 6.2), "size": Vector3(0.2, 2.9, 1.6), "mat": &"wand"},
	{"pos": Vector3(-3.5, 1.45, 6.2), "size": Vector3(0.2, 2.9, 1.6), "mat": &"wand"},
	{"pos": Vector3(-8.7, 1.45, 5.8), "size": Vector3(0.2, 2.9, 0.8), "mat": &"wand"},
	{"pos": Vector3(-7.3, 1.45, 5.8), "size": Vector3(0.2, 2.9, 0.8), "mat": &"wand"},
	{"pos": Vector3(-8.0, 1.45, 6.3), "size": Vector3(1.6, 2.9, 0.2), "mat": &"wand"},
	{"pos": Vector3(-8.0, 2.25, 5.8), "size": Vector3(1.6, 0.1, 0.8), "mat": &"plafond"},
	{"pos": Vector3(-5.17, 1.05, 6.5), "size": Vector3(0.06, 2.1, 1.0), "mat": &"wand"},
]

## Meubel- en herkenningsvolumes: de greybox vertelt de functie.
const MEUBELS: Array[Dictionary] = [
	# Hal: prikbord + kapstokrail met haken (tier F3 vervangt ze door de
	# echte props — zelfde koppeling als de F2-vlag).
	{"pos": Vector3(-1.3, 1.6, 6.972), "size": Vector3(1.2, 0.8, 0.06), "mat": &"hout", "nc": true, "f3": true},
	{"pos": Vector3(0.0, 1.69, 2.348), "size": Vector3(3.2, 0.08, 0.1), "mat": &"hout", "f3": true},
	{"pos": Vector3(-1.2, 1.6, 2.41), "size": Vector3(0.04, 0.12, 0.08), "mat": &"metaal", "nc": true, "f3": true},
	{"pos": Vector3(-0.6, 1.6, 2.41), "size": Vector3(0.04, 0.12, 0.08), "mat": &"metaal", "nc": true, "f3": true},
	{"pos": Vector3(0.0, 1.6, 2.41), "size": Vector3(0.04, 0.12, 0.08), "mat": &"metaal", "nc": true, "f3": true},
	{"pos": Vector3(0.6, 1.6, 2.41), "size": Vector3(0.04, 0.12, 0.08), "mat": &"metaal", "nc": true, "f3": true},
	{"pos": Vector3(1.2, 1.6, 2.41), "size": Vector3(0.04, 0.12, 0.08), "mat": &"metaal", "nc": true, "f3": true},
	# Kantine: bar met blad en doorgeefopening erachter, achterwerkblad,
	# meterkast, tv, trofeeënkast, twee pilaren, tafels/stoelen, krukken.
	{"pos": Vector3(10.6, 0.55, 2.9), "size": Vector3(2.4, 1.1, 0.6), "mat": &"hout"},
	{"pos": Vector3(10.6, 1.13, 2.9), "size": Vector3(2.6, 0.06, 0.8), "mat": &"hout_donker"},
	{"pos": Vector3(10.6, 0.45, 3.4), "size": Vector3(2.4, 0.9, 0.2), "mat": &"hout"},
	{"pos": Vector3(8.28, 1.1, 3.42), "size": Vector3(0.56, 2.0, 0.16), "mat": &"metaal"},
	{"pos": Vector3(12.13, 2.0, -3.8), "size": Vector3(0.14, 0.6, 0.8), "mat": &"metaal", "nc": true},
	{"pos": Vector3(2.4, 1.1, -0.6), "size": Vector3(0.4, 2.2, 2.0), "mat": &"hout"},
	{"pos": Vector3(5.4, 1.35, -0.5), "size": Vector3(0.25, 2.7, 0.25), "mat": &"wand"},
	{"pos": Vector3(8.6, 1.35, -0.5), "size": Vector3(0.25, 2.7, 0.25), "mat": &"wand"},
	{"pos": Vector3(4.2, 0.375, -2.6), "size": Vector3(0.8, 0.75, 0.8), "mat": &"hout"},
	{"pos": Vector3(6.8, 0.375, -1.0), "size": Vector3(0.8, 0.75, 0.8), "mat": &"hout"},
	{"pos": Vector3(4.6, 0.375, 0.9), "size": Vector3(0.8, 0.75, 0.8), "mat": &"hout"},
	{"pos": Vector3(9.0, 0.375, -3.0), "size": Vector3(0.8, 0.75, 0.8), "mat": &"hout"},
	{"pos": Vector3(6.2, 0.375, 2.0), "size": Vector3(0.8, 0.75, 0.8), "mat": &"hout"},
	{"pos": Vector3(3.4, 0.225, -2.6), "size": Vector3(0.42, 0.45, 0.42), "mat": &"hout_donker"},
	{"pos": Vector3(4.9, 0.225, -3.3), "size": Vector3(0.42, 0.45, 0.42), "mat": &"hout_donker"},
	{"pos": Vector3(6.1, 0.225, -1.7), "size": Vector3(0.42, 0.45, 0.42), "mat": &"hout_donker"},
	{"pos": Vector3(7.5, 0.225, -0.6), "size": Vector3(0.42, 0.45, 0.42), "mat": &"hout_donker"},
	{"pos": Vector3(3.9, 0.225, 0.9), "size": Vector3(0.42, 0.45, 0.42), "mat": &"hout_donker"},
	{"pos": Vector3(5.3, 0.225, 1.5), "size": Vector3(0.42, 0.45, 0.42), "mat": &"hout_donker"},
	{"pos": Vector3(8.3, 0.225, -3.6), "size": Vector3(0.42, 0.45, 0.42), "mat": &"hout_donker"},
	{"pos": Vector3(6.9, 0.225, 2.4), "size": Vector3(0.42, 0.45, 0.42), "mat": &"hout_donker"},
	{"pos": Vector3(9.8, 0.325, 2.2), "size": Vector3(0.35, 0.65, 0.35), "mat": &"hout_donker"},
	{"pos": Vector3(10.6, 0.325, 2.2), "size": Vector3(0.35, 0.65, 0.35), "mat": &"hout_donker"},
	{"pos": Vector3(11.4, 0.325, 2.2), "size": Vector3(0.35, 0.65, 0.35), "mat": &"hout_donker"},
	# Kleedkamer 3: banken, kapstokrails, lockers.
	{"pos": Vector3(-6.77, 0.24, 0.95), "size": Vector3(0.34, 0.48, 3.9), "mat": &"hout", "f2": true},
	{"pos": Vector3(-2.63, 0.24, 0.45), "size": Vector3(0.34, 0.48, 2.9), "mat": &"hout", "f2": true},
	{"pos": Vector3(-6.88, 1.68, 0.95), "size": Vector3(0.1, 0.08, 3.9), "mat": &"hout", "nc": true, "f2": true},
	{"pos": Vector3(-2.52, 1.68, 0.45), "size": Vector3(0.1, 0.08, 2.9), "mat": &"hout", "nc": true, "f2": true},
	{"pos": Vector3(-2.78, 0.9, 2.6), "size": Vector3(0.6, 1.8, 1.0), "mat": &"metaal", "f2": true},
	# Douche 3: douchekoppen (hoog) + afvoerputten.
	{"pos": Vector3(-4.8, 1.9, -4.42), "size": Vector3(0.08, 0.08, 0.12), "mat": &"metaal", "nc": true},
	{"pos": Vector3(-4.0, 1.9, -4.42), "size": Vector3(0.08, 0.08, 0.12), "mat": &"metaal", "nc": true},
	{"pos": Vector3(-3.2, 1.9, -4.42), "size": Vector3(0.08, 0.08, 0.12), "mat": &"metaal", "nc": true},
	{"pos": Vector3(-4.8, 0.005, -3.9), "size": Vector3(0.25, 0.012, 0.25), "mat": &"beton_donker", "nc": true},
	{"pos": Vector3(-4.0, 0.005, -3.9), "size": Vector3(0.25, 0.012, 0.25), "mat": &"beton_donker", "nc": true},
	{"pos": Vector3(-3.2, 0.005, -3.9), "size": Vector3(0.25, 0.012, 0.25), "mat": &"beton_donker", "nc": true},
	{"pos": Vector3(-3.8, 0.005, -2.5), "size": Vector3(0.25, 0.012, 0.25), "mat": &"beton_donker", "nc": true},
	# Kleedkamer 4: banken + rails (bewust geen lockers — variatie).
	{"pos": Vector3(-11.17, 0.24, 0.95), "size": Vector3(0.34, 0.48, 3.9), "mat": &"hout"},
	{"pos": Vector3(-7.43, 0.24, 0.45), "size": Vector3(0.34, 0.48, 2.9), "mat": &"hout"},
	{"pos": Vector3(-11.28, 1.68, 0.95), "size": Vector3(0.1, 0.08, 3.9), "mat": &"hout", "nc": true},
	{"pos": Vector3(-7.32, 1.68, 0.45), "size": Vector3(0.1, 0.08, 2.9), "mat": &"hout", "nc": true},
	# Douche 4.
	{"pos": Vector3(-9.9, 1.9, -4.42), "size": Vector3(0.08, 0.08, 0.12), "mat": &"metaal", "nc": true},
	{"pos": Vector3(-9.1, 1.9, -4.42), "size": Vector3(0.08, 0.08, 0.12), "mat": &"metaal", "nc": true},
	{"pos": Vector3(-8.3, 1.9, -4.42), "size": Vector3(0.08, 0.08, 0.12), "mat": &"metaal", "nc": true},
	{"pos": Vector3(-9.9, 0.005, -3.9), "size": Vector3(0.25, 0.012, 0.25), "mat": &"beton_donker", "nc": true},
	{"pos": Vector3(-9.1, 0.005, -3.9), "size": Vector3(0.25, 0.012, 0.25), "mat": &"beton_donker", "nc": true},
	{"pos": Vector3(-8.3, 0.005, -3.9), "size": Vector3(0.25, 0.012, 0.25), "mat": &"beton_donker", "nc": true},
	{"pos": Vector3(-9.0, 0.005, -2.5), "size": Vector3(0.25, 0.012, 0.25), "mat": &"beton_donker", "nc": true},
	# Toiletten: twee hokjes, wasbak met spiegel, urinoir.
	{"pos": Vector3(-5.9, 0.25, 6.75), "size": Vector3(0.4, 0.5, 0.45), "mat": &"keramiek"},
	{"pos": Vector3(-4.45, 0.25, 6.75), "size": Vector3(0.4, 0.5, 0.45), "mat": &"keramiek"},
	{"pos": Vector3(-3.85, 0.87, 5.8), "size": Vector3(0.44, 0.1, 0.7), "mat": &"keramiek"},
	{"pos": Vector3(-3.62, 1.55, 5.8), "size": Vector3(0.04, 0.7, 0.7), "mat": &"spiegel", "nc": true},
	{"pos": Vector3(-6.5, 0.75, 5.75), "size": Vector3(0.3, 0.6, 0.35), "mat": &"keramiek"},
	# Onderhoudsruimte: stellingrek, kast, cv-ketel, kratten, emmer.
	{"pos": Vector3(-14.7, 0.5, 1.5), "size": Vector3(0.5, 0.06, 2.8), "mat": &"metaal"},
	{"pos": Vector3(-14.7, 1.1, 1.5), "size": Vector3(0.5, 0.06, 2.8), "mat": &"metaal"},
	{"pos": Vector3(-14.7, 1.7, 1.5), "size": Vector3(0.5, 0.06, 2.8), "mat": &"metaal"},
	{"pos": Vector3(-14.7, 0.95, 0.13), "size": Vector3(0.5, 1.9, 0.06), "mat": &"metaal"},
	{"pos": Vector3(-14.7, 0.95, 2.87), "size": Vector3(0.5, 1.9, 0.06), "mat": &"metaal"},
	{"pos": Vector3(-12.0, 0.9, 2.7), "size": Vector3(0.8, 1.8, 0.9), "mat": &"metaal"},
	{"pos": Vector3(-12.0, 1.45, -0.62), "size": Vector3(0.6, 1.1, 0.45), "mat": &"wit"},
	{"pos": Vector3(-13.4, 0.16, 0.3), "size": Vector3(0.5, 0.32, 0.35), "mat": &"hout_donker"},
	{"pos": Vector3(-13.0, 0.16, 2.9), "size": Vector3(0.5, 0.32, 0.35), "mat": &"hout_donker"},
	{"pos": Vector3(-11.8, 0.15, 1.6), "size": Vector3(0.28, 0.3, 0.28), "mat": &"metaal"},
	# Schoonmaaknis: plank, emmer, bezem. En een brandblusser in de gang.
	{"pos": Vector3(-8.0, 1.5, 5.8), "size": Vector3(1.3, 0.05, 0.7), "mat": &"hout"},
	{"pos": Vector3(-8.3, 0.15, 5.75), "size": Vector3(0.28, 0.3, 0.28), "mat": &"metaal"},
	{"pos": Vector3(-7.6, 0.65, 5.6), "size": Vector3(0.04, 1.3, 0.04), "mat": &"hout", "nc": true},
	{"pos": Vector3(-6.1, 1.0, 5.34), "size": Vector3(0.16, 0.45, 0.14), "mat": &"accent_rood", "nc": true, "f2": true},
]

## Deuren: begintoestanden volgen tasks/008 §3, met één bewuste
## fase-C-afwijking: de onderhoudsruimte is nu NIET op slot (het slot
## hoort bij de sleutelflow van fase D) zodat de GD elke ruimte kan
## beoordelen. Bestuurskamer, keuken en terras zijn wél op slot: dat
## zijn wereldgrenzen, geen route.
const DEUREN: Array[Dictionary] = [
	{"name": "DeurHoofdentree", "pos": Vector3(-0.51, 0.0, 7.1),
		"settings": {"prompt_open": "Open buitendeur", "prompt_close": "Sluit buitendeur",
			"panel_tint": Color(0.72, 0.75, 0.78)}, "kozijn": &"f_kozijn_staal"},
	{"name": "DeurHalKantine", "pos": Vector3(2.1, 0.0, 3.32), "rot": 90.0, "kozijn": &"f_kozijn_blauw"},
	{"name": "DeurBestuurskamer", "pos": Vector3(2.1, 0.0, 6.24), "rot": 90.0,
		"settings": {"locked": true, "prompt_locked": "Op slot — Bestuurskamer"}, "kozijn": &"f_kozijn_blauw"},
	{"name": "DeurHalGang", "pos": Vector3(-2.1, 0.0, 4.82), "rot": 90.0, "kozijn": &"f_kozijn_blauw"},
	{"name": "DeurKeuken", "pos": Vector3(8.8, 0.0, 3.6),
		"settings": {"locked": true, "prompt_locked": "Op slot — Keuken"}},
	{"name": "DeurTerras", "pos": Vector3(12.3, 0.0, -2.48), "rot": 90.0,
		"settings": {"locked": true, "prompt_locked": "Op slot — Terras"}},
	{"name": "DeurKleedkamer3", "pos": Vector3(-4.42, 0.0, 3.3),
		"settings": {"panel_tint": Color(0.62, 0.58, 0.54)}, "kozijn": &"f_kozijn_blauw"},
	{"name": "DeurKleedkamer4", "pos": Vector3(-9.82, 0.0, 3.3),
		"settings": {"panel_tint": Color(0.62, 0.58, 0.54)}, "kozijn": &"f_kozijn_blauw"},
	{"name": "DeurOnderhoudsruimte", "pos": Vector3(-13.42, 0.0, 3.3),
		"settings": {"panel_tint": Color(0.55, 0.52, 0.49)}, "kozijn": &"f_kozijn_blauw"},
	{"name": "DeurToiletten", "pos": Vector3(-5.62, 0.0, 5.3),
		"settings": {"panel_tint": Color(0.62, 0.58, 0.54)}, "kozijn": &"f_kozijn_blauw"},
	{"name": "Nooddeur", "pos": Vector3(-15.1, 0.0, 4.82), "rot": 90.0,
		"settings": {"prompt_open": "Duw nooddeur open", "prompt_close": "Trek nooddeur dicht",
			"panel_tint": Color(0.46, 0.48, 0.51)}, "kozijn": &"f_kozijn_staal"},
]

## TL-armaturen: weinig werkend licht is het punt (kader 006). Stabiel:
## hal, kantine-bar, gang-oost (schaduwslot 2) en kleedkamer 3
## (schaduwslot 3); de flikkerbuis hangt halverwege de gang (tasks/008
## §4), gang-west is sinds F2 defect, de rest ook. Schaduwbudget:
## gang-oost + kleedkamer 3 + lichtmast = 3, zaklampslot blijft vrij
## (D-026). F2.1 verplaatste het derde slot van de kantinebar (buiten de
## demo-zone, nog greybox) naar kleedkamer 3: daar moeten bankpoten,
## kast en losse spullen echte contactschaduw krijgen.
const NIGHT_TLS: Array[Dictionary] = [
	{"name": "TlHal", "pos": Vector3(0.0, 2.52, 4.6)},
	{"name": "TlKantineBar", "pos": Vector3(10.6, 2.62, 2.4)},
	{"name": "TlKantineMidden", "pos": Vector3(7.2, 2.62, -0.5),
		"settings": {"state": 1}},
	{"name": "TlKantineWest", "pos": Vector3(4.0, 2.62, -2.5),
		"settings": {"state": 1}},
	{"name": "TlGangOost", "pos": Vector3(-3.8, 2.32, 4.3),
		"settings": {"cast_shadow": true}},
	{"name": "TlGangFlikker", "pos": Vector3(-7.2, 2.32, 4.3),
		"settings": {"state": 2, "flicker_seed": 11, "scorched": true}},
	{"name": "TlGangDefect", "pos": Vector3(-10.6, 2.32, 4.3),
		"settings": {"state": 1}},
	{"name": "TlGangWest", "pos": Vector3(-13.8, 2.32, 4.3),
		"settings": {"state": 1}},
	# Tier F3: de bestuurskamer heeft één werkende TL, bewust uit het
	# midden (west) — de oostwand met de historie leeft in de schaduw.
	# Geen schaduwslot (D-026 zit vol: gang + kleedkamer 3 + mast);
	# contrast komt uit korte range en hoge attenuatie, grounding uit
	# decals (de F2.1-techniek).
	{"name": "TlBestuurskamer", "pos": Vector3(3.2, 2.32, 5.6),
		"settings": {"light_energy_on": 0.85, "light_range": 2.45,
			"light_attenuation": 2.7}},
	{"name": "TlKleedkamer3", "pos": Vector3(-4.7, 2.42, 1.0),
		"settings": {"light_energy_on": 1.2, "light_range": 3.9,
			"light_attenuation": 2.1, "cast_shadow": true}},
	{"name": "TlDouche3", "pos": Vector3(-3.8, 2.22, -3.0),
		"settings": {"state": 1}},
	{"name": "TlKleedkamer4", "pos": Vector3(-9.3, 2.42, 1.0),
		"settings": {"state": 1}},
	{"name": "TlDouche4", "pos": Vector3(-9.0, 2.22, -3.0),
		"settings": {"state": 1}},
	{"name": "TlToiletten", "pos": Vector3(-5.1, 2.32, 6.2),
		"settings": {"state": 1}},
	{"name": "TlOnderhoud", "pos": Vector3(-13.2, 2.22, 1.2),
		"settings": {"state": 1}},
]

## Afwerkingslaag (fase G, tier F1) — puur visueel, altijd zonder
## collision. De kozijnen stonden hier ooit met de hand in; die worden
## sinds de integriteitspass uit de deurtabel afgeleid (§_build_kozijn),
## want handmatige stijlen en een deurblad lopen gegarandeerd uit elkaar.
## Verder: dunne panelen dáár waar één wandvolume twee gezichten
## nodig heeft (tegels in de douche, stucwerk op de gevel-binnenkant),
## tegelbanden halfhoog in de kleedkamers, clubblauwe kozijnen rond de
## focusdeuren, lambrisering en de kabelgoot. Architectuur onaangetast.
const AFWERKING: Array[Dictionary] = [
	# Hal: stucwerk op de binnenkant van de zuidgevel (rond deur + raam).
	# Bestuurskamer: stucwerk op gevel- en scheidingswand-binnenkanten.
	{"pos": Vector3(5.985, 1.2, 5.35), "size": Vector3(0.03, 2.4, 3.3), "mat": &"f_stucwerk", "nc": true},
	{"pos": Vector3(4.1, 1.2, 3.715), "size": Vector3(3.8, 2.4, 0.03), "mat": &"f_stucwerk", "nc": true},
	# Gang: geschilderd metselwerk op de westgevel-binnenkant (nooddeur).
	# Kleedkamer 3: tegelband halfhoog (1,4 m) rondom.
	{"pos": Vector3(-2.415, 0.7, 0.95), "size": Vector3(0.03, 1.4, 4.5), "mat": &"f_tegel_wand", "nc": true},
	{"pos": Vector3(-6.985, 0.7, 0.95), "size": Vector3(0.03, 1.4, 4.5), "mat": &"f_tegel_wand", "nc": true},
	{"pos": Vector3(-5.71, 0.7, 3.185), "size": Vector3(2.58, 1.4, 0.03), "mat": &"f_tegel_wand", "nc": true},
	{"pos": Vector3(-2.9, 0.7, 3.185), "size": Vector3(1.0, 1.4, 0.03), "mat": &"f_tegel_wand", "nc": true},
	{"pos": Vector3(-5.75, 0.7, -1.285), "size": Vector3(2.5, 1.4, 0.03), "mat": &"f_tegel_wand", "nc": true},
	{"pos": Vector3(-2.95, 0.7, -1.285), "size": Vector3(1.1, 1.4, 0.03), "mat": &"f_tegel_wand", "nc": true},
	# Kleedkamer 4: idem.
	{"pos": Vector3(-7.215, 0.7, 0.95), "size": Vector3(0.03, 1.4, 4.5), "mat": &"f_tegel_wand", "nc": true},
	{"pos": Vector3(-11.385, 0.7, 0.95), "size": Vector3(0.03, 1.4, 4.5), "mat": &"f_tegel_wand", "nc": true},
	{"pos": Vector3(-10.61, 0.7, 3.185), "size": Vector3(1.58, 1.4, 0.03), "mat": &"f_tegel_wand", "nc": true},
	{"pos": Vector3(-8.0, 0.7, 3.185), "size": Vector3(1.6, 1.4, 0.03), "mat": &"f_tegel_wand", "nc": true},
	{"pos": Vector3(-10.45, 0.7, -1.285), "size": Vector3(1.9, 1.4, 0.03), "mat": &"f_tegel_wand", "nc": true},
	{"pos": Vector3(-7.85, 0.7, -1.285), "size": Vector3(1.3, 1.4, 0.03), "mat": &"f_tegel_wand", "nc": true},
	# Douche 3: volledig betegeld (vier zijden, rond kiepraam en doorgang).
	{"pos": Vector3(-4.9, 1.15, -4.485), "size": Vector3(0.6, 2.3, 0.03), "mat": &"f_tegel_wand", "nc": true},
	{"pos": Vector3(-2.8, 1.15, -4.485), "size": Vector3(0.8, 2.3, 0.03), "mat": &"f_tegel_wand", "nc": true},
	{"pos": Vector3(-3.9, 0.9, -4.485), "size": Vector3(1.4, 1.8, 0.03), "mat": &"f_tegel_wand", "nc": true},
	{"pos": Vector3(-4.85, 1.15, -1.515), "size": Vector3(0.7, 2.3, 0.03), "mat": &"f_tegel_wand", "nc": true},
	{"pos": Vector3(-2.95, 1.15, -1.515), "size": Vector3(1.1, 2.3, 0.03), "mat": &"f_tegel_wand", "nc": true},
	{"pos": Vector3(-4.0, 2.175, -1.515), "size": Vector3(1.0, 0.25, 0.03), "mat": &"f_tegel_wand", "nc": true},
	{"pos": Vector3(-2.415, 1.15, -3.0), "size": Vector3(0.03, 2.3, 3.0), "mat": &"f_tegel_wand", "nc": true},
	{"pos": Vector3(-5.185, 1.15, -3.0), "size": Vector3(0.03, 2.3, 3.0), "mat": &"f_tegel_wand", "nc": true},
	# Douche 4: idem.
	{"pos": Vector3(-10.1, 1.15, -4.485), "size": Vector3(0.6, 2.3, 0.03), "mat": &"f_tegel_wand", "nc": true},
	{"pos": Vector3(-8.0, 1.15, -4.485), "size": Vector3(0.8, 2.3, 0.03), "mat": &"f_tegel_wand", "nc": true},
	{"pos": Vector3(-9.1, 0.9, -4.485), "size": Vector3(1.4, 1.8, 0.03), "mat": &"f_tegel_wand", "nc": true},
	{"pos": Vector3(-9.95, 1.15, -1.515), "size": Vector3(0.9, 2.3, 0.03), "mat": &"f_tegel_wand", "nc": true},
	{"pos": Vector3(-8.05, 1.15, -1.515), "size": Vector3(0.9, 2.3, 0.03), "mat": &"f_tegel_wand", "nc": true},
	{"pos": Vector3(-9.0, 2.175, -1.515), "size": Vector3(1.0, 0.25, 0.03), "mat": &"f_tegel_wand", "nc": true},
	{"pos": Vector3(-7.615, 1.15, -3.0), "size": Vector3(0.03, 2.3, 3.0), "mat": &"f_tegel_wand", "nc": true},
	{"pos": Vector3(-10.385, 1.15, -3.0), "size": Vector3(0.03, 2.3, 3.0), "mat": &"f_tegel_wand", "nc": true},
	# Hal: houten lambrisering achter de kapstok; gang: kabelgoot.
	{"pos": Vector3(0.0, 0.6, 2.315), "size": Vector3(3.8, 1.0, 0.03), "mat": &"f_lambrisering", "nc": true},
	{"pos": Vector3(-8.6, 2.3, 5.08), "size": Vector3(12.6, 0.08, 0.1), "mat": &"f_metaal", "nc": true},

]

## Bewegwijzering (fase G, tier F1): gegenereerde tekstborden
## (tools/genereer_bordjes.sh), wit op clubblauw (D-031). "emissie" > 0
## maakt het bord zelf lichtgevend (alleen NOODUITGANG — puur emissief,
## geen Light3D: het schaduwbudget blijft onaangeraakt).
const BORDJES: Array[Dictionary] = [
	# Tier F3: het naambord verhuisde van de geveldagkant naar het
	# boeiboord — op de oude plek verdween het achter de dakrand; op de
	# rand zelf is het de klassieke plek en vangt het het aanstraallicht.
	{"tex": "naambord", "pos": Vector3(0.0, 2.95, 7.452), "size": Vector2(2.6, 0.46), "rot": 0.0},
	{"tex": "kleedkamers", "pos": Vector3(-1.972, 2.3, 4.31), "size": Vector2(0.95, 0.19), "rot": 90.0},
	{"tex": "kantine", "pos": Vector3(1.972, 2.3, 2.81), "size": Vector2(0.85, 0.19), "rot": -90.0},
	{"tex": "bestuur", "pos": Vector3(1.972, 2.3, 5.73), "size": Vector2(0.65, 0.17), "rot": -90.0},
	{"tex": "kleedkamer3", "pos": Vector3(-2.9, 1.8, 3.428), "size": Vector2(0.55, 0.16), "rot": 0.0},
	{"tex": "kleedkamer4", "pos": Vector3(-8.42, 1.8, 3.428), "size": Vector2(0.55, 0.16), "rot": 0.0},
	{"tex": "toiletten", "pos": Vector3(-4.17, 1.8, 5.172), "size": Vector2(0.55, 0.16), "rot": 180.0},
	{"tex": "onderhoud", "pos": Vector3(-11.9, 1.8, 3.428), "size": Vector2(0.7, 0.13), "rot": 0.0},
	{"tex": "nooduitgang", "pos": Vector3(-14.972, 2.3, 4.31), "size": Vector2(0.75, 0.17), "rot": 90.0, "emissie": 1.0},
	{"tex": "gevonden_voorwerpen", "pos": Vector3(-12.15, 1.42, 3.425), "size": Vector2(0.21, 0.3), "rot": 0.0},
]

var _materials := {}
var _unit_mesh: BoxMesh

@onready var _greybox: Node3D = $Greybox
@onready var _werklicht_rig: Node3D = %Werklicht
@onready var _night_lights: Node3D = %NightLights


func _ready() -> void:
	_unit_mesh = BoxMesh.new()
	var f2_aanwezig := ResourceLoader.exists(F2_DETAIL_SCENE)
	var f3_aanwezig := ResourceLoader.exists(F3_DETAIL_SCENE)
	for table in [SCHIL, VLOEREN, PLAFONDS, BUITEN, INTERIEUR, MEUBELS, AFWERKING]:
		for solid in table:
			if f2_aanwezig and solid.get("f2", false):
				continue
			if f3_aanwezig and solid.get("f3", false):
				continue
			_build_solid(solid)
	for bord in BORDJES:
		_build_bord(bord)
	_place_doors()
	_place_night_tls()
	_place_f2_detail(f2_aanwezig)
	_place_f3_detail(f3_aanwezig)
	_werklicht_rig.visible = werklicht
	_night_lights.visible = not werklicht
	if werklicht:
		Log.warn("Clubgebouw: werklicht AAN — alleen voor inspectie, nooit committen")
	_activate_ambience()
	Log.info("Clubgebouw: greybox opgebouwd (%d volumes)" % _greybox.get_child_count())


## Maten van het deurblad (game/props/door_wooden): hier hangt het hele
## kozijn aan, dus ze staan één keer op deze plek en nergens anders.
const DEUR_BREEDTE := 1.0
const DEUR_HOOGTE := 2.1
## Zichtbare stijlbreedte, diepte over de muur heen, en de overlap
## waarmee het kozijn het blad raakt (nooit exact aanliggend: dan zie je
## bij de kleinste afrondingsfout een kier).
const KOZIJN_BREEDTE := 0.07
const KOZIJN_DIEPTE := 0.26
const KOZIJN_OVERLAP := 0.004
## Raamkozijnen: zichtbare stijlbreedte en de diepte waarmee ze de
## dagkant van de muuropening afdekken (muur 0,20 m + 1 cm speling).
const RAAM_BREEDTE := 0.06
const RAAM_DIEPTE := 0.21


## Eén volume = StaticBody + geschaalde unit-mesh + eigen BoxShape
## (nooit een geschaalde collider). "nc" = decoratief, geen collision.
##
## "binnen"/"buiten" plakken automatisch een afwerkingspaneel op één van
## beide zijden van een wand. Dat is de oplossing voor een fout die het
## hele gebouw doortrok: een muur is één blok met één materiaal, dus het
## buitenmetselwerk stond óók in de toiletten en de onderhoudsruimte.
## Handmatige liners liepen daarbij steeds achter op de tabellen; deze
## afgeleide panelen kunnen per definitie niet meer mislopen.
func _build_solid(solid: Dictionary) -> void:
	var size: Vector3 = solid["size"]
	if solid.has("kozijn"):
		_build_raamkozijn(solid)
	if solid.has("binnen"):
		_build_liner(solid, solid["binnen"], true)
	if solid.has("buiten"):
		_build_liner(solid, solid["buiten"], false)
	var body := StaticBody3D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	var mesh := MeshInstance3D.new()
	mesh.mesh = _unit_mesh
	mesh.scale = size
	mesh.material_override = _material(solid["mat"])
	body.add_child(mesh)
	if not solid.get("nc", false):
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = size
		shape.shape = box
		body.add_child(shape)
	_greybox.add_child(body)
	body.position = solid["pos"]


## Afwerkingspaneel tegen één zijde van een wand. De dunne as van de
## wand is vanzelf de as waarop het paneel ligt; "naar binnen" is de kant
## die naar het midden van het gebouw wijst (de schil is convex, dus dat
## klopt altijd).
## Raamkozijn rond een glaspaneel: vier stijlen die de dagkant van de
## opening afdekken. Zonder kozijn kijkt de speler van binnenuit tegen
## het buitenmetselwerk van de gevel aan — precies de fout die de
## integriteitspass door het hele gebouw aantrof.
func _build_raamkozijn(solid: Dictionary) -> void:
	var size: Vector3 = solid["size"]
	var pos: Vector3 = solid["pos"]
	var mat: StringName = solid["kozijn"]
	var as_dik: int = size.min_axis_index()
	var assen := [0, 1, 2]
	assen.erase(as_dik)
	var u: int = assen[0]
	var v: int = assen[1]
	var diepte := RAAM_DIEPTE
	for kant in [-1.0, 1.0]:
		var stijl := Vector3.ZERO
		stijl[as_dik] = diepte
		stijl[u] = RAAM_BREEDTE
		stijl[v] = size[v] + 2.0 * RAAM_BREEDTE
		var plek := pos
		plek[u] += kant * (size[u] * 0.5 + RAAM_BREEDTE * 0.5
			- KOZIJN_OVERLAP)
		_build_solid({"pos": plek, "size": stijl, "mat": mat, "nc": true})
		var dorpel := Vector3.ZERO
		dorpel[as_dik] = diepte
		dorpel[u] = size[u] + 2.0 * KOZIJN_OVERLAP
		dorpel[v] = RAAM_BREEDTE
		var plek2 := pos
		plek2[v] += kant * (size[v] * 0.5 + RAAM_BREEDTE * 0.5
			- KOZIJN_OVERLAP)
		_build_solid({"pos": plek2, "size": dorpel, "mat": mat, "nc": true})


func _build_liner(solid: Dictionary, mat: StringName, naar_binnen: bool) -> void:
	var size: Vector3 = solid["size"]
	var pos: Vector3 = solid["pos"]
	var as_i: int = size.min_axis_index()
	var richting := signf(GEBOUW_MIDDEN[as_i] - pos[as_i])
	if richting == 0.0:
		richting = 1.0
	if not naar_binnen:
		richting = -richting
	var paneel_size := size
	paneel_size[as_i] = LINER_DIKTE
	var paneel_pos := pos
	# Het paneel steekt 2 mm vóór de wand uit — precies zoals stucwerk of
	# een tegellaag dat doet. Gelijk met het wandvlak zou twee vlakken op
	# exact dezelfde diepte leggen, en dat flikkert gegarandeerd.
	paneel_pos[as_i] += richting * (size[as_i] * 0.5 - LINER_DIKTE * 0.5
		+ LINER_UITSTEEK)
	_build_solid({"pos": paneel_pos, "size": paneel_size, "mat": mat,
		"nc": true})


func _material(key: StringName) -> StandardMaterial3D:
	if _materials.has(key):
		return _materials[key]
	var material := StandardMaterial3D.new()
	var spec: Variant = MATERIALS[key]
	if spec is Color:
		material.albedo_color = spec
		material.roughness = 0.9
		if spec.a < 1.0:
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	else:
		var tint: Color = spec.get("tint", Color.WHITE)
		material.albedo_color = tint
		material.roughness = spec.get("rough", 1.0)
		if spec.has("tex"):
			# Wereld-triplanair: de greybox-volumes zijn geschaalde
			# unit-boxen, dus alleen wereldruimte geeft een gelijkmatige
			# textuurdichtheid over elke maat (TD-007 blijft geldig).
			var tex: String = spec["tex"]
			var base := "res://assets/textures/%s/%s" % [tex, tex]
			material.albedo_texture = load(base + "_color.jpg")
			material.normal_enabled = true
			material.normal_texture = load(base + "_normal.jpg")
			material.roughness_texture = load(base + "_rough.jpg")
			material.uv1_triplanar = true
			material.uv1_world_triplanar = true
			material.normal_scale = spec.get("normal", 1.0)
			var texture_scale: float = spec.get("scale", 0.5)
			material.uv1_scale = Vector3(texture_scale, texture_scale, texture_scale)
		material.metallic = spec.get("metallic", 0.0)
		if tint.a < 1.0:
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_materials[key] = material
	return _materials[key]


## Eén bord = QuadMesh zonder collision met zijn eigen tekst-texture
## (een quad heeft één vlak met volledige UV — een box versnippert de
## tekst over zijn atlas). "rot" draait het vlak naar de kijkrichting;
## NOODUITGANG gloeit emissief (geen Light3D, budget onaangetast).
func _build_bord(bord: Dictionary) -> void:
	var mesh := MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = bord["size"]
	mesh.mesh = quad
	var material := StandardMaterial3D.new()
	var texture: Texture2D = load(
		"res://assets/textures/bordjes/%s.png" % bord["tex"])
	material.albedo_texture = texture
	material.roughness = 0.35
	var emissie: float = bord.get("emissie", 0.0)
	if emissie > 0.0:
		material.emission_enabled = true
		material.emission_texture = texture
		material.emission_energy_multiplier = emissie
	mesh.material_override = material
	_greybox.add_child(mesh)
	mesh.position = bord["pos"]
	mesh.rotation_degrees.y = bord.get("rot", 0.0)


## Deuren zijn de echte interactie-props, als data geplaatst met
## bestaanscheck (D-015). De root van de prop is de scharnierzijde; het
## paneel loopt lokaal +x (1,0 m breed).
func _place_doors() -> void:
	if not ResourceLoader.exists(DOOR_SCENE):
		Log.info("Clubgebouw: deur-prop afwezig — openingen blijven open (D-015)")
		return
	var packed: PackedScene = load(DOOR_SCENE)
	for door in DEUREN:
		var node: Node3D = packed.instantiate()
		node.name = door["name"]
		for key in door.get("settings", {}):
			node.set(key, door["settings"][key])
		add_child(node)
		node.position = door["pos"]
		node.rotation_degrees.y = door.get("rot", 0.0)
		if door.has("kozijn"):
			_build_kozijn(door)
	if not DEUREN.is_empty():
		Log.info("Clubgebouw: %d deuren geplaatst" % DEUREN.size())


## Kozijn rond een deur, gerekend vanaf het scharnier en de bladmaat —
## niet met de hand ingetikt. Dat maakt een kier tussen stijl en blad
## onmogelijk: het kozijn overlapt het blad altijd met KOZIJN_OVERLAP,
## ook als een deur ooit verschuift. Zonder collision: de doorgang blijft
## exact zo breed als de architectuur hem heeft goedgekeurd.
func _build_kozijn(door: Dictionary) -> void:
	var mat: StringName = door["kozijn"]
	var hoek: float = deg_to_rad(door.get("rot", 0.0))
	var basis := Basis(Vector3.UP, hoek)
	var wortel: Vector3 = door["pos"]
	var stijl := Vector3(KOZIJN_BREEDTE, DEUR_HOOGTE + KOZIJN_BREEDTE,
		KOZIJN_DIEPTE)
	# De latei loopt tússen de stijlen door, niet eroverheen: overlappende
	# stijl- en lateivlakken van hetzelfde materiaal liggen op precies
	# dezelfde diepte en flikkeren dan in elke hoek.
	var latei := Vector3(DEUR_BREEDTE + 2.0 * KOZIJN_OVERLAP,
		KOZIJN_BREEDTE, KOZIJN_DIEPTE)
	var halve := KOZIJN_BREEDTE * 0.5
	var delen := [
		[Vector3(-halve + KOZIJN_OVERLAP, stijl.y * 0.5, 0.0), stijl],
		[Vector3(DEUR_BREEDTE + halve - KOZIJN_OVERLAP, stijl.y * 0.5, 0.0),
			stijl],
		[Vector3(DEUR_BREEDTE * 0.5,
			DEUR_HOOGTE + halve - KOZIJN_OVERLAP, 0.0), latei],
	]
	for deel in delen:
		var lokaal: Vector3 = deel[0]
		var maat: Vector3 = deel[1]
		_build_solid({
			"pos": wortel + basis * lokaal,
			# De maat draait mee met het kozijn; abs() omdat een gedraaide
			# as anders een negatieve (en dus omgeklapte) schaal geeft.
			"size": (basis * maat).abs(),
			"mat": mat, "nc": true,
		})


## TL-armaturen: zelfde patroon als de dev room (state 1 = DEFECT,
## 2 = FLIKKEREND); weinig werkend licht is het punt (kader 006).
func _place_night_tls() -> void:
	if not ResourceLoader.exists(LIGHT_TL_SCENE):
		Log.info("Clubgebouw: TL-prop afwezig — nachtstaat zonder armaturen (D-015)")
		return
	var packed: PackedScene = load(LIGHT_TL_SCENE)
	for tl in NIGHT_TLS:
		var node: Node3D = packed.instantiate()
		node.name = tl["name"]
		for key in tl.get("settings", {}):
			node.set(key, tl["settings"][key])
		_night_lights.add_child(node)
		node.position = tl["pos"]
	if not NIGHT_TLS.is_empty():
		Log.info("Clubgebouw: %d TL-armaturen geplaatst" % NIGHT_TLS.size())


## De F2-detaillaag (tier F2): kleedkamer 3 en de gang van greybox naar
## bewoonde ruimte. Ontbreekt de map, dan bouwt het level de vervangen
## F1-volumes gewoon zelf — geen enkele afhankelijkheid de andere kant op
## (D-015; de vlag "f2" in de tabellen hierboven is de enige koppeling).
func _place_f2_detail(aanwezig: bool) -> void:
	if not aanwezig:
		Log.info("Clubgebouw: F2-detaillaag afwezig — tier F1-staat (D-015)")
		return
	var packed: PackedScene = load(F2_DETAIL_SCENE)
	add_child(packed.instantiate())


## De F3-detaillaag (tier F3): bestuurskamer, hal en entree-buitenkant.
## Zelfde contract als F2 (D-015): de vlag "f3" in de tabellen is de
## enige koppeling; zonder de map bouwt het level de F1-volumes zelf.
func _place_f3_detail(aanwezig: bool) -> void:
	if not aanwezig:
		Log.info("Clubgebouw: F3-detaillaag afwezig — tier F2.1-staat (D-015)")
		return
	var packed: PackedScene = load(F3_DETAIL_SCENE)
	add_child(packed.instantiate())


## Het stilte-nulpunt van het gebouw (005): koeling/tl-zoem. Null-veilig
## en duck-typed — zonder audiosysteem gebeurt er niets (D-015).
func _activate_ambience() -> void:
	var audio := get_tree().get_first_node_in_group("audio_system")
	if audio == null or not audio.has_method("set_ambience_layer"):
		return
	audio.set_ambience_layer(&"amb_hum_koeling", true, 1.5)
