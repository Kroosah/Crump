extends Node3D
## F3-detaillaag van het clubgebouw (fase G, tier F3): bestuurskamer,
## hal en de buitenzijde van de entree — de drie gebieden die de
## demo-zone naar het niveau van de F2.1-hero-kleedkamer tillen.
##
## Zelfde patroon als de F2-laag: één losse verwijdereenheid onder
## `game/levels/clubgebouw/f3_detail/` (D-015) — map weg = het level
## draait door in de F2.1-staat. Alles is data; de bouwer is dezelfde
## kitbash (box/cilinder/bol/torus/vlak, decals, panelen) met twee
## uitbreidingen: emissieve materialen (apparaat-LED's — puur emissief,
## geen Light3D, budget D-026 onaangeraakt) en de regenlaag buiten
## (GPUParticles3D + drie ruimtelijke audio-emitters).
##
## Wat deze laag NIET doet: architectuur verplaatsen, doorgangen
## versmallen, gameplay toevoegen, schaduwlichten toevoegen of de
## beschermde gang aanraken. De bestuurskamer-TL zelf staat in de
## leveltabel (clubgebouw.gd, NIGHT_TLS) — armaturen zijn levelinfra.

const REGEN_TEXTURE := "res://assets/textures/f3/regendruppel.png"
const REGEN_AUDIO := "res://assets/audio/ambience/amb_regen_buiten_01.wav"

## Materialen. Color = vlak; Dictionary = PBR uit assets/textures/
## (zelfde sleutels als de F2-laag) plus "emissie"/"energie" voor de
## apparaat-LED's.
const MATERIALEN := {
	# — Hout en meubels —
	&"tafelblad": {"tex": "planken", "tint": Color(0.52, 0.42, 0.30), "scale": 1.2, "rough": 0.45, "normal": 0.7},
	&"tafel_frame": {"tex": "metaal", "tint": Color(0.30, 0.31, 0.33), "scale": 1.1, "rough": 0.55, "metallic": 0.5},
	&"hout_stoel": {"tex": "planken", "tint": Color(0.40, 0.31, 0.22), "scale": 1.5, "rough": 0.6, "normal": 0.7},
	&"hout_stoel_b": {"tex": "planken", "tint": Color(0.35, 0.26, 0.19), "scale": 1.7, "rough": 0.68, "normal": 0.7},
	&"dressoir_hout": {"tex": "planken", "tint": Color(0.33, 0.25, 0.18), "scale": 1.1, "rough": 0.58, "normal": 0.8},
	&"bureau_blad": {"tex": "planken", "tint": Color(0.48, 0.40, 0.31), "scale": 1.3, "rough": 0.5, "normal": 0.6},
	&"bureau_kast": Color(0.36, 0.32, 0.27),
	&"kapstok_hout": {"tex": "planken", "tint": Color(0.42, 0.36, 0.29), "scale": 1.4, "rough": 0.66},
	&"bank_lat": {"tex": "planken", "tint": Color(0.17, 0.30, 0.49), "scale": 1.6, "rough": 0.52, "normal": 0.9, "vlak_gelakt": true},
	&"bank_frame": {"tex": "metaal", "tint": Color(0.38, 0.40, 0.43), "scale": 1.2, "rough": 0.5, "metallic": 0.6},
	# — Staal, kunststof, kantoor —
	&"staal": {"tex": "metaal", "tint": Color(0.50, 0.52, 0.54), "scale": 1.1, "rough": 0.45, "metallic": 0.7},
	&"staal_donker": {"tex": "metaal", "tint": Color(0.26, 0.27, 0.29), "scale": 1.0, "rough": 0.55, "metallic": 0.5},
	&"alu": {"tex": "metaal", "tint": Color(0.56, 0.58, 0.59), "scale": 1.3, "rough": 0.45, "metallic": 0.7},
	&"archief_staal": {"tex": "metaal", "tint": Color(0.36, 0.40, 0.37), "scale": 0.9, "rough": 0.5, "metallic": 0.3},
	&"beige_kantoor": Color(0.62, 0.59, 0.51),
	&"beige_donker": Color(0.48, 0.45, 0.38),
	&"scherm_uit": Color(0.06, 0.07, 0.08),
	&"kunststof_wit": Color(0.78, 0.78, 0.75),
	&"kunststof_grijs": Color(0.33, 0.35, 0.37),
	&"kunststof_blauw": Color(0.20, 0.29, 0.38),
	&"kunststof_zwart": Color(0.09, 0.09, 0.10),
	&"telefoon_grijs": Color(0.55, 0.55, 0.52),
	&"email_wit": Color(0.74, 0.74, 0.71),
	&"messing": {"tex": "metaal", "tint": Color(0.62, 0.50, 0.24), "scale": 1.4, "rough": 0.35, "metallic": 0.8},
	&"glas_kan": Color(0.20, 0.24, 0.26),
	&"koffierest": Color(0.16, 0.10, 0.06),
	# — Apparaat-LED's: puur emissief, geen Light3D (D-026) —
	&"led_groen": {"tint": Color(0.10, 0.22, 0.12), "emissie": Color(0.30, 0.95, 0.40), "energie": 1.6},
	&"led_oranje": {"tint": Color(0.24, 0.15, 0.06), "emissie": Color(0.95, 0.55, 0.15), "energie": 1.4},
	# — Textiel, papier, karton —
	&"stof_blauw": {"tex": "tapijt", "tint": Color(0.15, 0.22, 0.34), "scale": 1.2, "rough": 0.9, "normal": 0.6},
	&"stof_zwart": {"tex": "tapijt", "tint": Color(0.10, 0.10, 0.11), "scale": 1.3, "rough": 0.92, "normal": 0.5},
	&"jack_blauw": {"tex": "tapijt", "tint": Color(0.16, 0.28, 0.46), "scale": 1.0, "rough": 0.85, "normal": 0.6},
	&"vlag_blauw": {"tex": "tapijt", "tint": Color(0.12, 0.24, 0.44), "scale": 1.4, "rough": 0.88, "normal": 0.5},
	&"gordijn": {"tex": "tapijt", "tint": Color(0.52, 0.50, 0.44), "scale": 1.1, "rough": 0.9, "normal": 0.7},
	&"karton": Color(0.33, 0.28, 0.21),
	&"papier": Color(0.78, 0.77, 0.72),
	&"rubber_mat": {"tex": "rubber", "tint": Color(0.42, 0.42, 0.44), "scale": 1.4, "rough": 0.95},
	# — Afwerking —
	&"plint": Color(0.26, 0.28, 0.31),
	&"plint_hout": {"tex": "planken", "tint": Color(0.45, 0.40, 0.33), "scale": 1.6, "rough": 0.6},
	&"vensterbank": Color(0.76, 0.76, 0.73),
	&"rood_haspel": Color(0.42, 0.09, 0.08),
	# — Buiten —
	&"beton_plint": {"tex": "beton", "tint": Color(0.36, 0.37, 0.39), "scale": 0.7, "rough": 0.85, "normal": 0.6},
	&"boeiboord": Color(0.13, 0.14, 0.16),
	&"zink": {"tex": "metaal", "tint": Color(0.42, 0.44, 0.47), "scale": 1.2, "rough": 0.5, "metallic": 0.6},
	&"mast_alu": {"tex": "metaal", "tint": Color(0.48, 0.50, 0.53), "scale": 1.0, "rough": 0.42, "metallic": 0.7},
	&"kliko_grijs": Color(0.24, 0.26, 0.28),
	&"kliko_groen": Color(0.16, 0.24, 0.16),
	&"luifel_plafond": Color(0.60, 0.60, 0.57),
	&"melkglas": Color(0.82, 0.80, 0.72),
	# — Hal —
	&"terracotta": Color(0.42, 0.26, 0.18),
	&"plant_groen": Color(0.18, 0.24, 0.14),
}

## Vaste vormen, zelfde sleutels als de F2-laag: pos · size · mat ·
## rot (graden) · vorm ("box"/"cyl"/"bol"/"torus") · col · verborgen.
const SOLIDS: Array[Dictionary] = [
	# ══════════════ BESTUURSKAMER — hero room #2 ══════════════
	# Interieur: x 2,2..5,97 · z 3,73..6,98 · plafond 2,4. De deur zit in
	# de westwand (z 5,24..6,24), het nieuwe raam in de zuidgevel
	# (x 3,4..4,8 — kozijn komt uit de glastabel van het level, D-038).

	# ── Afwerking: houten plinten (tapijt → houten plint), onderbroken
	#    bij de deur ──
	{"pos": Vector3(4.085, 0.05, 3.76), "size": Vector3(3.77, 0.1, 0.06), "mat": &"plint_hout"},
	{"pos": Vector3(5.94, 0.05, 5.355), "size": Vector3(0.06, 0.1, 3.25), "mat": &"plint_hout"},
	{"pos": Vector3(4.085, 0.05, 6.948), "size": Vector3(3.77, 0.1, 0.06), "mat": &"plint_hout"},
	{"pos": Vector3(2.23, 0.05, 4.485), "size": Vector3(0.06, 0.1, 1.51), "mat": &"plint_hout"},
	{"pos": Vector3(2.23, 0.05, 6.625), "size": Vector3(0.06, 0.1, 0.71), "mat": &"plint_hout"},
	# Drempelstrip in de deuropening.
	{"pos": Vector3(2.1, 0.006, 5.74), "size": Vector3(0.22, 0.012, 1.02), "mat": &"alu"},
	# Kabelgoot langs de noordwand (jaren-negentig kantoorinfra) met een
	# opbouwstopcontact bij het bureau.
	{"pos": Vector3(4.42, 0.30, 3.7525), "size": Vector3(3.10, 0.06, 0.045), "mat": &"kunststof_wit"},
	{"pos": Vector3(5.40, 0.30, 3.7875), "size": Vector3(0.15, 0.08, 0.025), "mat": &"kunststof_wit"},
	# Schakelaar naast de deur.
	{"pos": Vector3(2.234, 1.05, 6.36), "size": Vector3(0.014, 0.085, 0.085), "mat": &"kunststof_wit"},
	{"pos": Vector3(2.246, 1.05, 6.36), "size": Vector3(0.010, 0.055, 0.055), "mat": &"kunststof_wit"},
	# TL-aansluiting: doos, buis naar de westwand, twee beugels (F2.1-les:
	# een armatuur hangt nooit uit het niets).
	{"pos": Vector3(3.2, 2.365, 5.6), "size": Vector3(0.11, 0.07, 0.09), "mat": &"kunststof_wit"},
	{"vorm": "cyl", "pos": Vector3(2.7, 2.3915, 5.6), "size": Vector3(0.013, 1.0, 0.013), "mat": &"kunststof_wit", "rot": Vector3(0.0, 0.0, 90.0)},
	{"pos": Vector3(2.45, 2.3915, 5.6), "size": Vector3(0.035, 0.017, 0.03), "mat": &"kunststof_wit"},
	{"pos": Vector3(2.95, 2.3915, 5.6), "size": Vector3(0.035, 0.017, 0.03), "mat": &"kunststof_wit"},

	# ── Radiator met vensterbank onder het raam ──
	{"pos": Vector3(4.1, 0.42, 6.93), "size": Vector3(1.10, 0.55, 0.08), "mat": &"email_wit"},
	{"pos": Vector3(3.65, 0.42, 6.885), "size": Vector3(0.02, 0.53, 0.02), "mat": &"email_wit"},
	{"pos": Vector3(3.83, 0.42, 6.885), "size": Vector3(0.02, 0.53, 0.02), "mat": &"email_wit"},
	{"pos": Vector3(4.01, 0.42, 6.885), "size": Vector3(0.02, 0.53, 0.02), "mat": &"email_wit"},
	{"pos": Vector3(4.19, 0.42, 6.885), "size": Vector3(0.02, 0.53, 0.02), "mat": &"email_wit"},
	{"pos": Vector3(4.37, 0.42, 6.885), "size": Vector3(0.02, 0.53, 0.02), "mat": &"email_wit"},
	{"pos": Vector3(4.55, 0.42, 6.885), "size": Vector3(0.02, 0.53, 0.02), "mat": &"email_wit"},
	{"vorm": "cyl", "pos": Vector3(3.58, 0.72, 6.90), "size": Vector3(0.030, 0.06, 0.030), "mat": &"staal_donker"},
	{"vorm": "cyl", "pos": Vector3(3.52, 0.08, 6.928), "size": Vector3(0.014, 0.16, 0.014), "mat": &"staal"},
	{"vorm": "cyl", "pos": Vector3(4.68, 0.08, 6.928), "size": Vector3(0.014, 0.16, 0.014), "mat": &"staal"},
	{"pos": Vector3(4.1, 0.875, 6.86), "size": Vector3(1.56, 0.03, 0.24), "mat": &"vensterbank"},

	# ── Vergadertafel: één degelijk rechthoekig blad op stalen poten —
	#    zoals clubtafels echt zijn (geen designtafel; een tweede blad
	#    aanschuiven bij de ALV is precies hoe dit meubel leeft) ──
	{"pos": Vector3(3.85, 0.7225, 5.15), "size": Vector3(2.05, 0.035, 0.90), "mat": &"tafelblad"},
	{"pos": Vector3(3.85, 0.685, 5.15), "size": Vector3(1.85, 0.04, 0.72), "mat": &"bureau_kast"},
	{"vorm": "cyl", "pos": Vector3(3.00, 0.335, 4.83), "size": Vector3(0.024, 0.67, 0.024), "mat": &"tafel_frame"},
	{"vorm": "cyl", "pos": Vector3(4.70, 0.335, 4.83), "size": Vector3(0.024, 0.67, 0.024), "mat": &"tafel_frame"},
	{"vorm": "cyl", "pos": Vector3(3.00, 0.335, 5.47), "size": Vector3(0.024, 0.67, 0.024), "mat": &"tafel_frame"},
	{"vorm": "cyl", "pos": Vector3(4.70, 0.335, 5.47), "size": Vector3(0.024, 0.67, 0.024), "mat": &"tafel_frame"},
	{"pos": Vector3(3.85, 0.38, 5.15), "size": Vector3(2.05, 0.76, 0.90), "col": true, "verborgen": true},

	# ── Zes stoelen, bij elkaar geraapt door de jaren heen ──
	# 1+2: kunststof kantinestoelen (grijs), noordzijde.
	{"pos": Vector3(3.50, 0.45, 4.42), "size": Vector3(0.42, 0.04, 0.42), "mat": &"kunststof_grijs", "rot": Vector3(0.0, 186.0, 0.0)},
	{"pos": Vector3(3.52, 0.69, 4.24), "size": Vector3(0.42, 0.44, 0.04), "mat": &"kunststof_grijs", "rot": Vector3(-8.0, 186.0, 0.0)},
	{"pos": Vector3(3.32, 0.21, 4.58), "size": Vector3(0.03, 0.42, 0.03), "mat": &"staal_donker", "rot": Vector3(0.0, 186.0, 0.0)},
	{"pos": Vector3(3.68, 0.21, 4.55), "size": Vector3(0.03, 0.42, 0.03), "mat": &"staal_donker", "rot": Vector3(0.0, 186.0, 0.0)},
	{"pos": Vector3(3.34, 0.21, 4.27), "size": Vector3(0.03, 0.42, 0.03), "mat": &"staal_donker", "rot": Vector3(0.0, 186.0, 0.0)},
	{"pos": Vector3(3.70, 0.21, 4.24), "size": Vector3(0.03, 0.42, 0.03), "mat": &"staal_donker", "rot": Vector3(0.0, 186.0, 0.0)},
	{"pos": Vector3(3.51, 0.45, 4.40), "size": Vector3(0.46, 0.90, 0.46), "col": true, "verborgen": true},
	{"pos": Vector3(4.28, 0.45, 4.40), "size": Vector3(0.42, 0.04, 0.42), "mat": &"kunststof_grijs", "rot": Vector3(0.0, 176.0, 0.0)},
	{"pos": Vector3(4.26, 0.69, 4.22), "size": Vector3(0.42, 0.44, 0.04), "mat": &"kunststof_grijs", "rot": Vector3(-8.0, 176.0, 0.0)},
	{"pos": Vector3(4.10, 0.21, 4.55), "size": Vector3(0.03, 0.42, 0.03), "mat": &"staal_donker", "rot": Vector3(0.0, 176.0, 0.0)},
	{"pos": Vector3(4.46, 0.21, 4.58), "size": Vector3(0.03, 0.42, 0.03), "mat": &"staal_donker", "rot": Vector3(0.0, 176.0, 0.0)},
	{"pos": Vector3(4.08, 0.21, 4.24), "size": Vector3(0.03, 0.42, 0.03), "mat": &"staal_donker", "rot": Vector3(0.0, 176.0, 0.0)},
	{"pos": Vector3(4.44, 0.21, 4.26), "size": Vector3(0.03, 0.42, 0.03), "mat": &"staal_donker", "rot": Vector3(0.0, 176.0, 0.0)},
	{"pos": Vector3(4.27, 0.45, 4.40), "size": Vector3(0.46, 0.90, 0.46), "col": true, "verborgen": true},
	# 3+4: houten stoelen (twee tinten), zuidzijde; nummer 4 staat scheef
	# en iets van de tafel — alsof iemand net is opgestaan.
	{"pos": Vector3(3.45, 0.46, 5.92), "size": Vector3(0.40, 0.035, 0.40), "mat": &"hout_stoel", "rot": Vector3(0.0, 8.0, 0.0)},
	{"pos": Vector3(3.42, 0.44, 6.11), "size": Vector3(0.035, 0.88, 0.035), "mat": &"hout_stoel", "rot": Vector3(0.0, 8.0, 0.0)},
	{"pos": Vector3(3.79, 0.44, 6.06), "size": Vector3(0.035, 0.88, 0.035), "mat": &"hout_stoel", "rot": Vector3(0.0, 8.0, 0.0)},
	{"pos": Vector3(3.60, 0.66, 6.085), "size": Vector3(0.35, 0.06, 0.022), "mat": &"hout_stoel", "rot": Vector3(0.0, 8.0, 0.0)},
	{"pos": Vector3(3.60, 0.80, 6.085), "size": Vector3(0.35, 0.07, 0.022), "mat": &"hout_stoel", "rot": Vector3(0.0, 8.0, 0.0)},
	{"pos": Vector3(3.28, 0.23, 5.76), "size": Vector3(0.035, 0.46, 0.035), "mat": &"hout_stoel", "rot": Vector3(0.0, 8.0, 0.0)},
	{"pos": Vector3(3.65, 0.23, 5.71), "size": Vector3(0.035, 0.46, 0.035), "mat": &"hout_stoel", "rot": Vector3(0.0, 8.0, 0.0)},
	{"pos": Vector3(3.53, 0.45, 5.92), "size": Vector3(0.46, 0.90, 0.46), "col": true, "verborgen": true},
	{"pos": Vector3(4.42, 0.46, 6.14), "size": Vector3(0.40, 0.035, 0.40), "mat": &"hout_stoel_b", "rot": Vector3(0.0, 38.0, 0.0)},
	{"pos": Vector3(4.29, 0.44, 6.31), "size": Vector3(0.035, 0.88, 0.035), "mat": &"hout_stoel_b", "rot": Vector3(0.0, 38.0, 0.0)},
	{"pos": Vector3(4.58, 0.44, 6.08), "size": Vector3(0.035, 0.88, 0.035), "mat": &"hout_stoel_b", "rot": Vector3(0.0, 38.0, 0.0)},
	{"pos": Vector3(4.435, 0.66, 6.195), "size": Vector3(0.35, 0.06, 0.022), "mat": &"hout_stoel_b", "rot": Vector3(0.0, 38.0, 0.0)},
	{"pos": Vector3(4.435, 0.80, 6.195), "size": Vector3(0.35, 0.07, 0.022), "mat": &"hout_stoel_b", "rot": Vector3(0.0, 38.0, 0.0)},
	{"pos": Vector3(4.25, 0.23, 5.95), "size": Vector3(0.035, 0.46, 0.035), "mat": &"hout_stoel_b", "rot": Vector3(0.0, 38.0, 0.0)},
	{"pos": Vector3(4.54, 0.23, 5.72), "size": Vector3(0.035, 0.46, 0.035), "mat": &"hout_stoel_b", "rot": Vector3(0.0, 38.0, 0.0)},
	{"pos": Vector3(4.42, 0.45, 6.10), "size": Vector3(0.46, 0.90, 0.46), "col": true, "verborgen": true},
	# 5: kunststof stoel (blauw), westkop.
	{"pos": Vector3(2.72, 0.45, 5.15), "size": Vector3(0.42, 0.04, 0.42), "mat": &"kunststof_blauw", "rot": Vector3(0.0, 94.0, 0.0)},
	{"pos": Vector3(2.54, 0.69, 5.14), "size": Vector3(0.42, 0.44, 0.04), "mat": &"kunststof_blauw", "rot": Vector3(-8.0, 94.0, 0.0)},
	{"pos": Vector3(2.86, 0.21, 4.97), "size": Vector3(0.03, 0.42, 0.03), "mat": &"staal_donker", "rot": Vector3(0.0, 94.0, 0.0)},
	{"pos": Vector3(2.88, 0.21, 5.33), "size": Vector3(0.03, 0.42, 0.03), "mat": &"staal_donker", "rot": Vector3(0.0, 94.0, 0.0)},
	{"pos": Vector3(2.57, 0.21, 4.99), "size": Vector3(0.03, 0.42, 0.03), "mat": &"staal_donker", "rot": Vector3(0.0, 94.0, 0.0)},
	{"pos": Vector3(2.59, 0.21, 5.35), "size": Vector3(0.03, 0.42, 0.03), "mat": &"staal_donker", "rot": Vector3(0.0, 94.0, 0.0)},
	{"pos": Vector3(2.72, 0.45, 5.15), "size": Vector3(0.46, 0.90, 0.46), "col": true, "verborgen": true},
	# 6: gestoffeerde vergaderstoel, oostkop — met de opgevouwen clubvlag
	# over de leuning.
	{"pos": Vector3(5.12, 0.46, 5.15), "size": Vector3(0.44, 0.08, 0.44), "mat": &"stof_blauw", "rot": Vector3(0.0, -90.0, 0.0)},
	{"pos": Vector3(5.31, 0.80, 5.15), "size": Vector3(0.07, 0.52, 0.44), "mat": &"stof_blauw", "rot": Vector3(0.0, 0.0, -6.0)},
	{"pos": Vector3(4.97, 0.21, 4.99), "size": Vector3(0.03, 0.42, 0.03), "mat": &"staal_donker"},
	{"pos": Vector3(4.97, 0.21, 5.31), "size": Vector3(0.03, 0.42, 0.03), "mat": &"staal_donker"},
	{"pos": Vector3(5.28, 0.21, 4.99), "size": Vector3(0.03, 0.42, 0.03), "mat": &"staal_donker"},
	{"pos": Vector3(5.28, 0.21, 5.31), "size": Vector3(0.03, 0.42, 0.03), "mat": &"staal_donker"},
	{"pos": Vector3(5.13, 0.45, 5.15), "size": Vector3(0.46, 0.95, 0.46), "col": true, "verborgen": true},
	# De clubvlag, opgevouwen over de leuning van stoel 6 (artplan §5.8).
	{"pos": Vector3(5.31, 1.075, 5.15), "size": Vector3(0.16, 0.035, 0.30), "mat": &"vlag_blauw", "rot": Vector3(0.0, 0.0, -6.0)},
	{"pos": Vector3(5.38, 0.93, 5.15), "size": Vector3(0.03, 0.26, 0.26), "mat": &"vlag_blauw", "rot": Vector3(0.0, 0.0, -6.0)},
	# Het trainersjack over de leuning van de scheve houten stoel.
	{"pos": Vector3(4.435, 0.845, 6.20), "size": Vector3(0.37, 0.06, 0.30), "mat": &"jack_blauw", "rot": Vector3(0.0, 38.0, 0.0)},
	{"pos": Vector3(4.52, 0.62, 6.30), "size": Vector3(0.09, 0.42, 0.28), "mat": &"jack_blauw", "rot": Vector3(0.0, 38.0, 4.0)},

	# ── Bureau (noordoosthoek) met ladenblok, computer en bureaustoel ──
	{"pos": Vector3(5.05, 0.745, 4.16), "size": Vector3(1.35, 0.03, 0.70), "mat": &"bureau_blad"},
	{"pos": Vector3(5.51, 0.315, 4.16), "size": Vector3(0.42, 0.60, 0.60), "mat": &"bureau_kast"},
	{"pos": Vector3(5.51, 0.50, 4.4675), "size": Vector3(0.38, 0.16, 0.015), "mat": &"bureau_kast"},
	{"pos": Vector3(5.51, 0.32, 4.4675), "size": Vector3(0.38, 0.16, 0.015), "mat": &"bureau_kast"},
	{"pos": Vector3(5.51, 0.14, 4.4675), "size": Vector3(0.38, 0.16, 0.015), "mat": &"bureau_kast"},
	{"pos": Vector3(5.51, 0.52, 4.485), "size": Vector3(0.10, 0.02, 0.02), "mat": &"staal_donker"},
	{"pos": Vector3(5.51, 0.34, 4.485), "size": Vector3(0.10, 0.02, 0.02), "mat": &"staal_donker"},
	{"pos": Vector3(5.51, 0.16, 4.485), "size": Vector3(0.10, 0.02, 0.02), "mat": &"staal_donker"},
	{"pos": Vector3(4.41, 0.365, 4.16), "size": Vector3(0.03, 0.73, 0.62), "mat": &"bureau_kast"},
	{"pos": Vector3(5.04, 0.53, 3.88), "size": Vector3(1.28, 0.42, 0.02), "mat": &"bureau_kast"},
	{"pos": Vector3(5.05, 0.39, 4.16), "size": Vector3(1.35, 0.78, 0.72), "col": true, "verborgen": true},
	# Computer: beige tower onder het blad, oude monitor + toetsenbord
	# erop; de standby-LED is het zwakke apparaatlicht van deze kamer.
	{"pos": Vector3(4.62, 0.22, 3.98), "size": Vector3(0.20, 0.44, 0.46), "mat": &"beige_kantoor"},
	{"pos": Vector3(5.30, 0.94, 4.05), "size": Vector3(0.36, 0.30, 0.34), "mat": &"beige_kantoor", "rot": Vector3(0.0, -14.0, 0.0)},
	{"pos": Vector3(5.245, 0.945, 4.208), "size": Vector3(0.28, 0.22, 0.012), "mat": &"scherm_uit", "rot": Vector3(0.0, -14.0, 0.0)},
	{"pos": Vector3(5.30, 0.775, 4.05), "size": Vector3(0.22, 0.03, 0.22), "mat": &"beige_donker", "rot": Vector3(0.0, -14.0, 0.0)},
	{"pos": Vector3(5.185, 0.845, 4.225), "size": Vector3(0.012, 0.012, 0.008), "mat": &"led_oranje", "rot": Vector3(0.0, -14.0, 0.0)},
	{"pos": Vector3(5.00, 0.7725, 4.40), "size": Vector3(0.42, 0.025, 0.14), "mat": &"beige_kantoor", "rot": Vector3(0.0, 3.0, 0.0)},
	{"pos": Vector3(5.32, 0.775, 4.46), "size": Vector3(0.06, 0.03, 0.10), "mat": &"beige_donker", "rot": Vector3(0.0, -20.0, 0.0)},
	# Bureaustoel: goedkoop model, iets van het bureau weggedraaid.
	{"pos": Vector3(4.85, 0.05, 4.95), "size": Vector3(0.52, 0.03, 0.06), "mat": &"kunststof_zwart", "rot": Vector3(0.0, 25.0, 0.0)},
	{"pos": Vector3(4.85, 0.05, 4.95), "size": Vector3(0.06, 0.03, 0.52), "mat": &"kunststof_zwart", "rot": Vector3(0.0, 25.0, 0.0)},
	{"vorm": "cyl", "pos": Vector3(4.85, 0.25, 4.95), "size": Vector3(0.024, 0.38, 0.024), "mat": &"staal_donker"},
	{"pos": Vector3(4.85, 0.475, 4.95), "size": Vector3(0.45, 0.07, 0.43), "mat": &"stof_zwart", "rot": Vector3(0.0, 25.0, 0.0)},
	{"pos": Vector3(4.77, 0.78, 5.13), "size": Vector3(0.42, 0.44, 0.06), "mat": &"stof_zwart", "rot": Vector3(-8.0, 25.0, 0.0)},
	{"pos": Vector3(4.85, 0.45, 4.95), "size": Vector3(0.50, 0.92, 0.50), "col": true, "verborgen": true},

	# ── Dossierkast (staal, vier laden) in de noordwesthoek: het hoge
	#    donkere silhouet dat je vanaf de deur schuin ziet ──
	{"pos": Vector3(2.56, 0.66, 3.96), "size": Vector3(0.62, 1.32, 0.46), "mat": &"archief_staal", "col": true},
	{"pos": Vector3(2.56, 0.20, 4.195), "size": Vector3(0.56, 0.28, 0.015), "mat": &"archief_staal"},
	{"pos": Vector3(2.56, 0.52, 4.195), "size": Vector3(0.56, 0.28, 0.015), "mat": &"archief_staal"},
	{"pos": Vector3(2.56, 0.84, 4.195), "size": Vector3(0.56, 0.28, 0.015), "mat": &"archief_staal"},
	{"pos": Vector3(2.56, 1.16, 4.195), "size": Vector3(0.56, 0.28, 0.015), "mat": &"archief_staal"},
	{"pos": Vector3(2.56, 0.30, 4.208), "size": Vector3(0.12, 0.025, 0.02), "mat": &"staal"},
	{"pos": Vector3(2.56, 0.62, 4.208), "size": Vector3(0.12, 0.025, 0.02), "mat": &"staal"},
	{"pos": Vector3(2.56, 0.94, 4.208), "size": Vector3(0.12, 0.025, 0.02), "mat": &"staal"},
	{"pos": Vector3(2.56, 1.26, 4.208), "size": Vector3(0.12, 0.025, 0.02), "mat": &"staal"},
	{"pos": Vector3(2.42, 0.30, 4.205), "size": Vector3(0.08, 0.05, 0.008), "mat": &"kunststof_wit"},
	{"pos": Vector3(2.42, 0.62, 4.205), "size": Vector3(0.08, 0.05, 0.008), "mat": &"kunststof_wit"},
	{"pos": Vector3(2.42, 0.94, 4.205), "size": Vector3(0.08, 0.05, 0.008), "mat": &"kunststof_wit"},
	{"pos": Vector3(2.42, 1.26, 4.205), "size": Vector3(0.08, 0.05, 0.008), "mat": &"kunststof_wit"},
	# Rij ordners bovenop de dossierkast (aansluitend, zoals op een echte
	# plank), één leunt scheef tegen de rest.
	{"pos": Vector3(2.34, 1.475, 3.97), "size": Vector3(0.075, 0.31, 0.28), "mat": &"kunststof_blauw"},
	{"pos": Vector3(2.414, 1.475, 3.97), "size": Vector3(0.075, 0.31, 0.28), "mat": &"kunststof_zwart"},
	{"pos": Vector3(2.488, 1.475, 3.97), "size": Vector3(0.075, 0.31, 0.28), "mat": &"kunststof_blauw"},
	{"pos": Vector3(2.562, 1.475, 3.97), "size": Vector3(0.075, 0.31, 0.28), "mat": &"kunststof_grijs"},
	{"pos": Vector3(2.636, 1.475, 3.97), "size": Vector3(0.075, 0.31, 0.28), "mat": &"kunststof_zwart"},
	{"pos": Vector3(2.72, 1.478, 3.97), "size": Vector3(0.075, 0.31, 0.28), "mat": &"kunststof_blauw", "rot": Vector3(0.0, 0.0, -14.0)},

	# ── Houten ladekast aan de westwand met de printer erop (vrij van de
	#    dossierkast — de integriteitscheck ving de overlap) ──
	{"pos": Vector3(2.42, 0.46, 4.60), "size": Vector3(0.44, 0.92, 0.62), "mat": &"dressoir_hout", "col": true},
	{"pos": Vector3(2.6475, 0.50, 4.45), "size": Vector3(0.015, 0.72, 0.28), "mat": &"dressoir_hout"},
	{"pos": Vector3(2.6475, 0.50, 4.75), "size": Vector3(0.015, 0.72, 0.28), "mat": &"dressoir_hout"},
	{"vorm": "cyl", "pos": Vector3(2.662, 0.60, 4.49), "size": Vector3(0.012, 0.02, 0.012), "mat": &"staal_donker", "rot": Vector3(0.0, 0.0, 90.0)},
	{"vorm": "cyl", "pos": Vector3(2.662, 0.60, 4.71), "size": Vector3(0.012, 0.02, 0.012), "mat": &"staal_donker", "rot": Vector3(0.0, 0.0, 90.0)},
	{"pos": Vector3(2.45, 1.05, 4.60), "size": Vector3(0.42, 0.26, 0.34), "mat": &"kunststof_grijs"},
	{"pos": Vector3(2.63, 0.985, 4.60), "size": Vector3(0.26, 0.015, 0.12), "mat": &"kunststof_grijs"},
	{"pos": Vector3(2.663, 1.155, 4.48), "size": Vector3(0.010, 0.010, 0.008), "mat": &"led_groen"},

	# ── Dressoir aan de oostwand: het geheugen van de club ──
	{"pos": Vector3(5.75, 0.44, 6.15), "size": Vector3(0.44, 0.82, 1.40), "mat": &"dressoir_hout", "col": true},
	{"pos": Vector3(5.745, 0.8625, 6.15), "size": Vector3(0.47, 0.025, 1.44), "mat": &"dressoir_hout"},
	{"pos": Vector3(5.75, 0.045, 6.15), "size": Vector3(0.44, 0.09, 1.36), "mat": &"bureau_kast"},
	{"pos": Vector3(5.5225, 0.47, 5.52), "size": Vector3(0.015, 0.62, 0.325), "mat": &"dressoir_hout"},
	{"pos": Vector3(5.5225, 0.47, 5.86), "size": Vector3(0.015, 0.62, 0.325), "mat": &"dressoir_hout"},
	{"pos": Vector3(5.5225, 0.47, 6.44), "size": Vector3(0.015, 0.62, 0.325), "mat": &"dressoir_hout"},
	{"pos": Vector3(5.5225, 0.47, 6.78), "size": Vector3(0.015, 0.62, 0.325), "mat": &"dressoir_hout"},
	{"vorm": "cyl", "pos": Vector3(5.508, 0.60, 5.68), "size": Vector3(0.012, 0.02, 0.012), "mat": &"staal_donker", "rot": Vector3(0.0, 0.0, 90.0)},
	{"vorm": "cyl", "pos": Vector3(5.508, 0.60, 6.62), "size": Vector3(0.012, 0.02, 0.012), "mat": &"staal_donker", "rot": Vector3(0.0, 0.0, 90.0)},

	# ── Op het dressoir: koffiezetapparaat met opgedroogde kan,
	#    bekertjes, archiefdozen, twee bekers uit de kast ──
	{"pos": Vector3(5.76, 0.885, 6.62), "size": Vector3(0.24, 0.02, 0.26), "mat": &"kunststof_zwart"},
	{"pos": Vector3(5.90, 1.06, 6.62), "size": Vector3(0.10, 0.34, 0.22), "mat": &"kunststof_zwart"},
	{"pos": Vector3(5.80, 1.245, 6.62), "size": Vector3(0.20, 0.08, 0.24), "mat": &"kunststof_zwart"},
	{"vorm": "cyl", "pos": Vector3(5.76, 0.901, 6.62), "size": Vector3(0.070, 0.012, 0.070), "mat": &"staal_donker"},
	{"vorm": "cyl", "pos": Vector3(5.76, 0.982, 6.62), "size": Vector3(0.062, 0.15, 0.062), "mat": &"glas_kan"},
	{"pos": Vector3(5.703, 0.987, 6.62), "size": Vector3(0.014, 0.10, 0.03), "mat": &"kunststof_zwart"},
	{"vorm": "cyl", "pos": Vector3(5.68, 0.925, 6.40), "size": Vector3(0.035, 0.10, 0.035), "mat": &"kunststof_wit"},
	{"pos": Vector3(5.75, 1.01, 5.75), "size": Vector3(0.38, 0.27, 0.30), "mat": &"karton"},
	{"pos": Vector3(5.75, 1.015, 6.10), "size": Vector3(0.38, 0.27, 0.30), "mat": &"karton", "rot": Vector3(0.0, 5.0, 0.0)},
	# Wisselbeker en een kleine beker.
	{"pos": Vector3(5.80, 0.885, 5.48), "size": Vector3(0.085, 0.02, 0.085), "mat": &"bureau_kast"},
	{"vorm": "cyl", "pos": Vector3(5.80, 0.925, 5.48), "size": Vector3(0.012, 0.06, 0.012), "mat": &"messing"},
	{"vorm": "cyl", "pos": Vector3(5.80, 1.005, 5.48), "size": Vector3(0.048, 0.10, 0.048), "mat": &"messing"},
	{"vorm": "torus", "pos": Vector3(5.80, 1.055, 5.48), "size": Vector3(0.044, 0.054, 0.044), "mat": &"messing"},
	# Twee archiefdozen gestapeld op de vloer naast het dressoir.
	{"pos": Vector3(5.70, 0.135, 5.28), "size": Vector3(0.38, 0.27, 0.30), "mat": &"karton", "col": true},
	{"pos": Vector3(5.69, 0.41, 5.29), "size": Vector3(0.38, 0.27, 0.30), "mat": &"karton", "rot": Vector3(0.0, 7.0, 0.0)},

	# ── Sleutelkastje + wandtelefoon naast de deur ──
	{"pos": Vector3(2.2325, 1.45, 6.55), "size": Vector3(0.025, 0.36, 0.28), "mat": &"kunststof_grijs"},
	{"pos": Vector3(2.249, 1.45, 6.55), "size": Vector3(0.012, 0.34, 0.26), "mat": &"kunststof_grijs"},
	{"vorm": "cyl", "pos": Vector3(2.258, 1.45, 6.66), "size": Vector3(0.009, 0.012, 0.009), "mat": &"staal_donker", "rot": Vector3(0.0, 0.0, 90.0)},
	{"pos": Vector3(2.2325, 1.40, 6.15), "size": Vector3(0.045, 0.24, 0.11), "mat": &"telefoon_grijs"},
	{"pos": Vector3(2.262, 1.44, 6.15), "size": Vector3(0.035, 0.14, 0.05), "mat": &"telefoon_grijs"},
	{"vorm": "cyl", "pos": Vector3(2.245, 1.24, 6.19), "size": Vector3(0.007, 0.05, 0.007), "mat": &"kunststof_grijs", "rot": Vector3(12.0, 0.0, 8.0)},
	{"vorm": "cyl", "pos": Vector3(2.245, 1.19, 6.17), "size": Vector3(0.007, 0.05, 0.007), "mat": &"kunststof_grijs", "rot": Vector3(-10.0, 0.0, 6.0)},

	# ── Kleine spullen op tafel en bureau: de vergadering is nooit
	#    netjes opgeruimd ──
	{"vorm": "cyl", "pos": Vector3(4.18, 0.785, 5.02), "size": Vector3(0.040, 0.09, 0.040), "mat": &"kunststof_wit"},
	{"vorm": "torus", "pos": Vector3(4.225, 0.79, 5.02), "size": Vector3(0.012, 0.028, 0.012), "mat": &"kunststof_wit", "rot": Vector3(0.0, 0.0, 90.0)},
	{"vorm": "cyl", "pos": Vector3(3.45, 0.845, 5.32), "size": Vector3(0.035, 0.21, 0.035), "mat": &"kunststof_wit"},
	{"vorm": "cyl", "pos": Vector3(3.45, 0.958, 5.32), "size": Vector3(0.020, 0.025, 0.020), "mat": &"kunststof_blauw"},
	{"pos": Vector3(3.62, 0.746, 4.95), "size": Vector3(0.15, 0.008, 0.21), "mat": &"papier", "rot": Vector3(0.0, 14.0, 0.0)},
	{"vorm": "cyl", "pos": Vector3(3.76, 0.744, 4.99), "size": Vector3(0.004, 0.14, 0.004), "mat": &"kunststof_blauw", "rot": Vector3(90.0, 32.0, 0.0)},
	{"pos": Vector3(4.65, 0.775, 4.02), "size": Vector3(0.22, 0.03, 0.30), "mat": &"papier", "rot": Vector3(0.0, 6.0, 0.0)},
	{"pos": Vector3(5.30, 0.785, 3.93), "size": Vector3(0.21, 0.05, 0.28), "mat": &"papier", "rot": Vector3(0.0, -3.0, 0.0)},
	{"pos": Vector3(4.90, 0.764, 4.22), "size": Vector3(0.15, 0.008, 0.21), "mat": &"papier", "rot": Vector3(0.0, -10.0, 0.0)},
	# Papierbak onder het bureau.
	{"vorm": "cyl", "pos": Vector3(4.45, 0.14, 4.72), "size": Vector3(0.13, 0.28, 0.13), "mat": &"kunststof_grijs", "col": true, "rot": Vector3(0.0, 0.0, 1.2)},

	# ── Historie-wand: lijsten flush tegen de stucliner (x-vlak 5,97);
	#    de foto's zelf zijn panelen ──
	{"pos": Vector3(5.9635, 1.78, 6.30), "size": Vector3(0.013, 0.42, 0.56), "mat": &"kapstok_hout"},
	{"pos": Vector3(5.9635, 1.74, 5.80), "size": Vector3(0.013, 0.49, 0.37), "mat": &"kapstok_hout"},
	{"pos": Vector3(5.9635, 1.80, 6.76), "size": Vector3(0.013, 0.33, 0.44), "mat": &"kapstok_hout"},
	{"pos": Vector3(5.9635, 1.30, 5.79), "size": Vector3(0.013, 0.36, 0.48), "mat": &"kapstok_hout"},
	# Kampioensvaan aan een knop.
	{"vorm": "cyl", "pos": Vector3(5.955, 1.72, 5.42), "size": Vector3(0.010, 0.03, 0.010), "mat": &"kapstok_hout", "rot": Vector3(0.0, 0.0, 90.0)},

	# ── Whiteboard aan de noordwand + stiftgoot (tegen de stucliner) ──
	{"pos": Vector3(3.60, 1.62, 3.7425), "size": Vector3(0.94, 0.64, 0.025), "mat": &"alu"},
	{"pos": Vector3(3.60, 1.29, 3.755), "size": Vector3(0.40, 0.022, 0.05), "mat": &"alu"},
	{"vorm": "cyl", "pos": Vector3(3.50, 1.308, 3.762), "size": Vector3(0.008, 0.11, 0.008), "mat": &"kunststof_zwart", "rot": Vector3(0.0, 0.0, 90.0)},

	# ══════════════ HAL — transition space ══════════════
	# Interieur: x -2,0..2,0 · z 2,3..6,98 · plafond 2,6. Terughoudend:
	# de hal verbindt en oriënteert (brief §5), hij concurreert niet met
	# de hero rooms. Geen nieuwe lichtbronnen — de darkness hierarchy
	# richting gang blijft van de gang.

	# ── Plinten langs alle wanden, onderbroken bij de deuren ──
	{"pos": Vector3(0.0, 0.05, 2.35), "size": Vector3(3.94, 0.1, 0.06), "mat": &"plint"},
	{"pos": Vector3(-1.97, 0.05, 3.05), "size": Vector3(0.06, 0.1, 1.5), "mat": &"plint"},
	{"pos": Vector3(-1.97, 0.05, 5.9), "size": Vector3(0.06, 0.1, 2.16), "mat": &"plint"},
	{"pos": Vector3(1.97, 0.05, 4.27), "size": Vector3(0.06, 0.1, 1.9), "mat": &"plint"},
	{"pos": Vector3(1.97, 0.05, 6.625), "size": Vector3(0.06, 0.1, 0.71), "mat": &"plint"},
	{"pos": Vector3(-1.2575, 0.05, 6.95), "size": Vector3(1.49, 0.1, 0.06), "mat": &"plint"},
	{"pos": Vector3(1.245, 0.05, 6.95), "size": Vector3(1.51, 0.1, 0.06), "mat": &"plint"},

	# ── Prikbord (vervangt het F1-vlak): houten lijst om het gevulde
	#    kurkvlak — het kloppend hart van elke vereniging ──
	{"pos": Vector3(-1.3, 2.0, 6.963), "size": Vector3(1.10, 0.05, 0.03), "mat": &"kapstok_hout"},
	{"pos": Vector3(-1.3, 1.2, 6.963), "size": Vector3(1.10, 0.05, 0.03), "mat": &"kapstok_hout"},
	{"pos": Vector3(-1.875, 1.6, 6.963), "size": Vector3(0.05, 0.85, 0.03), "mat": &"kapstok_hout"},
	{"pos": Vector3(-0.725, 1.6, 6.963), "size": Vector3(0.05, 0.85, 0.03), "mat": &"kapstok_hout"},

	# ── Kapstok (vervangt het F1-vlak): rail met zeven dubbele haken,
	#    en de lage schoenenbank eronder — zelfde model als de gang ──
	{"pos": Vector3(0.0, 1.68, 2.35), "size": Vector3(3.0, 0.16, 0.04), "mat": &"kapstok_hout"},
	{"pos": Vector3(-1.35, 1.66, 2.38), "size": Vector3(0.03, 0.10, 0.02), "mat": &"staal"},
	{"pos": Vector3(-1.35, 1.615, 2.425), "size": Vector3(0.022, 0.022, 0.11), "mat": &"staal"},
	{"pos": Vector3(-0.90, 1.66, 2.38), "size": Vector3(0.03, 0.10, 0.02), "mat": &"staal"},
	{"pos": Vector3(-0.90, 1.615, 2.425), "size": Vector3(0.022, 0.022, 0.11), "mat": &"staal"},
	{"pos": Vector3(-0.45, 1.66, 2.38), "size": Vector3(0.03, 0.10, 0.02), "mat": &"staal"},
	{"pos": Vector3(-0.45, 1.615, 2.425), "size": Vector3(0.022, 0.022, 0.11), "mat": &"staal"},
	{"pos": Vector3(0.0, 1.66, 2.38), "size": Vector3(0.03, 0.10, 0.02), "mat": &"staal"},
	{"pos": Vector3(0.0, 1.615, 2.425), "size": Vector3(0.022, 0.022, 0.11), "mat": &"staal"},
	{"pos": Vector3(0.45, 1.66, 2.38), "size": Vector3(0.03, 0.10, 0.02), "mat": &"staal"},
	{"pos": Vector3(0.45, 1.615, 2.425), "size": Vector3(0.022, 0.022, 0.11), "mat": &"staal"},
	{"pos": Vector3(0.90, 1.66, 2.38), "size": Vector3(0.03, 0.10, 0.02), "mat": &"staal"},
	{"pos": Vector3(0.90, 1.615, 2.425), "size": Vector3(0.022, 0.022, 0.11), "mat": &"staal"},
	{"pos": Vector3(1.35, 1.66, 2.38), "size": Vector3(0.03, 0.10, 0.02), "mat": &"staal"},
	{"pos": Vector3(1.35, 1.615, 2.425), "size": Vector3(0.022, 0.022, 0.11), "mat": &"staal"},
	{"pos": Vector3(0.0, 0.43, 2.50), "size": Vector3(1.20, 0.035, 0.075), "mat": &"bank_lat"},
	{"pos": Vector3(0.0, 0.43, 2.59), "size": Vector3(1.20, 0.035, 0.075), "mat": &"bank_lat"},
	{"pos": Vector3(0.0, 0.43, 2.68), "size": Vector3(1.20, 0.035, 0.075), "mat": &"bank_lat"},
	{"pos": Vector3(-0.47, 0.209, 2.52), "size": Vector3(0.045, 0.418, 0.045), "mat": &"bank_frame"},
	{"pos": Vector3(-0.47, 0.209, 2.66), "size": Vector3(0.045, 0.418, 0.045), "mat": &"bank_frame"},
	{"pos": Vector3(-0.47, 0.398, 2.59), "size": Vector3(0.040, 0.04, 0.22), "mat": &"bank_frame"},
	{"pos": Vector3(0.47, 0.209, 2.52), "size": Vector3(0.045, 0.418, 0.045), "mat": &"bank_frame"},
	{"pos": Vector3(0.47, 0.209, 2.66), "size": Vector3(0.045, 0.418, 0.045), "mat": &"bank_frame"},
	{"pos": Vector3(0.47, 0.398, 2.59), "size": Vector3(0.040, 0.04, 0.22), "mat": &"bank_frame"},
	{"pos": Vector3(0.0, 0.24, 2.59), "size": Vector3(1.20, 0.48, 0.30), "col": true, "verborgen": true},

	# ── Radiator met vensterbank onder het halraam; de plant is nét te
	#    droog (artplan §6 — één verbleekt element per ruimte) ──
	{"pos": Vector3(1.45, 0.42, 6.9), "size": Vector3(0.80, 0.55, 0.08), "mat": &"email_wit"},
	{"pos": Vector3(1.13, 0.42, 6.855), "size": Vector3(0.02, 0.53, 0.02), "mat": &"email_wit"},
	{"pos": Vector3(1.29, 0.42, 6.855), "size": Vector3(0.02, 0.53, 0.02), "mat": &"email_wit"},
	{"pos": Vector3(1.45, 0.42, 6.855), "size": Vector3(0.02, 0.53, 0.02), "mat": &"email_wit"},
	{"pos": Vector3(1.61, 0.42, 6.855), "size": Vector3(0.02, 0.53, 0.02), "mat": &"email_wit"},
	{"pos": Vector3(1.77, 0.42, 6.855), "size": Vector3(0.02, 0.53, 0.02), "mat": &"email_wit"},
	{"vorm": "cyl", "pos": Vector3(1.06, 0.72, 6.90), "size": Vector3(0.030, 0.06, 0.030), "mat": &"staal_donker"},
	{"vorm": "cyl", "pos": Vector3(1.10, 0.08, 6.928), "size": Vector3(0.014, 0.16, 0.014), "mat": &"staal"},
	{"vorm": "cyl", "pos": Vector3(1.80, 0.08, 6.928), "size": Vector3(0.014, 0.16, 0.014), "mat": &"staal"},
	{"pos": Vector3(1.45, 0.875, 6.86), "size": Vector3(1.06, 0.03, 0.24), "mat": &"vensterbank"},
	{"vorm": "cyl", "pos": Vector3(1.70, 0.945, 6.88), "size": Vector3(0.055, 0.11, 0.055), "mat": &"terracotta"},
	{"pos": Vector3(1.70, 1.06, 6.88), "size": Vector3(0.02, 0.14, 0.03), "mat": &"plant_groen", "rot": Vector3(0.0, 15.0, 12.0)},
	{"pos": Vector3(1.68, 1.05, 6.87), "size": Vector3(0.03, 0.12, 0.02), "mat": &"plant_groen", "rot": Vector3(8.0, -20.0, -14.0)},
	{"pos": Vector3(1.72, 1.03, 6.89), "size": Vector3(0.02, 0.10, 0.02), "mat": &"plant_groen", "rot": Vector3(-6.0, 40.0, 20.0)},

	# ── Gordijn, half dicht (artplan §6) met rail boven het raam ──
	{"vorm": "cyl", "pos": Vector3(1.45, 2.28, 6.83), "size": Vector3(0.008, 1.10, 0.008), "mat": &"alu", "rot": Vector3(0.0, 0.0, 90.0)},
	{"pos": Vector3(1.15, 1.60, 6.86), "size": Vector3(0.42, 1.30, 0.05), "mat": &"gordijn"},
	{"pos": Vector3(0.97, 1.60, 6.845), "size": Vector3(0.13, 1.30, 0.075), "mat": &"gordijn"},

	# ── Brandslanghaspel aan de westwand bij de gangdeur (rood is hier
	#    signaal, geen accent — artplan §2.3) ──
	{"pos": Vector3(-1.985, 1.30, 5.45), "size": Vector3(0.03, 0.66, 0.66), "mat": &"kunststof_wit"},
	{"vorm": "cyl", "pos": Vector3(-1.90, 1.30, 5.45), "size": Vector3(0.27, 0.13, 0.27), "mat": &"rood_haspel", "rot": Vector3(0.0, 0.0, 90.0)},
	{"vorm": "cyl", "pos": Vector3(-1.825, 1.30, 5.45), "size": Vector3(0.055, 0.03, 0.055), "mat": &"kunststof_zwart", "rot": Vector3(0.0, 0.0, 90.0)},
	{"pos": Vector3(-1.86, 0.98, 5.60), "size": Vector3(0.06, 0.05, 0.12), "mat": &"kunststof_zwart"},

	# ── Entree-binnenzijde: deurmat (het logo is een paneel), afvalbak
	#    en paraplubak ──
	{"pos": Vector3(0.0, 0.007, 6.55), "size": Vector3(0.95, 0.014, 0.60), "mat": &"rubber_mat"},
	{"vorm": "cyl", "pos": Vector3(1.60, 0.20, 6.45), "size": Vector3(0.16, 0.40, 0.16), "mat": &"kunststof_grijs", "col": true, "rot": Vector3(0.0, 0.0, 1.5)},
	{"vorm": "torus", "pos": Vector3(1.60, 0.407, 6.45), "size": Vector3(0.146, 0.175, 0.146), "mat": &"kunststof_zwart", "rot": Vector3(0.0, 14.0, 1.5)},
	{"vorm": "cyl", "pos": Vector3(0.78, 0.25, 6.72), "size": Vector3(0.11, 0.50, 0.11), "mat": &"kunststof_grijs", "col": true},
	{"vorm": "cyl", "pos": Vector3(0.80, 0.55, 6.72), "size": Vector3(0.022, 0.72, 0.022), "mat": &"kunststof_zwart", "rot": Vector3(8.0, 0.0, 6.0)},
	{"vorm": "torus", "pos": Vector3(0.86, 0.90, 6.70), "size": Vector3(0.018, 0.032, 0.018), "mat": &"kunststof_zwart", "rot": Vector3(0.0, 0.0, 90.0)},

	# ── Klok aan de oostwand (stilstaand — niemand heeft hem gelijkgezet) ──
	{"vorm": "cyl", "pos": Vector3(1.985, 2.2, 4.27), "size": Vector3(0.14, 0.03, 0.14), "mat": &"email_wit", "rot": Vector3(0.0, 0.0, 90.0)},
	{"vorm": "torus", "pos": Vector3(1.968, 2.2, 4.27), "size": Vector3(0.128, 0.144, 0.128), "mat": &"staal_donker", "rot": Vector3(0.0, 0.0, 90.0)},
	{"pos": Vector3(1.966, 2.222, 4.282), "size": Vector3(0.005, 0.055, 0.010), "mat": &"kunststof_zwart", "rot": Vector3(28.0, 0.0, 0.0)},
	{"pos": Vector3(1.966, 2.19, 4.235), "size": Vector3(0.005, 0.075, 0.010), "mat": &"kunststof_zwart", "rot": Vector3(118.0, 0.0, 0.0)},

	# ── TL-aansluiting van de hal-TL: doos, buis naar de noordwand ──
	{"pos": Vector3(0.0, 2.565, 4.6), "size": Vector3(0.11, 0.07, 0.09), "mat": &"kunststof_wit"},
	{"vorm": "cyl", "pos": Vector3(0.0, 2.5915, 3.45), "size": Vector3(0.013, 2.3, 0.013), "mat": &"kunststof_wit", "rot": Vector3(90.0, 0.0, 0.0)},
	{"pos": Vector3(0.0, 2.5915, 2.9), "size": Vector3(0.035, 0.017, 0.03), "mat": &"kunststof_wit"},
	{"pos": Vector3(0.0, 2.5915, 4.0), "size": Vector3(0.035, 0.017, 0.03), "mat": &"kunststof_wit"},
]

## Getextureerde panelen (QuadMesh). Een quad kijkt standaard naar +z;
## rot draait hem naar de wand.
const PANELEN: Array[Dictionary] = [
	# Bestuurskamer: whiteboard, kalender, historie-wand, vaan, briefje.
	{"tex": "f3/whiteboard_agenda", "pos": Vector3(3.60, 1.62, 3.757), "size": Vector2(0.88, 0.58)},
	{"tex": "f3/kalender", "pos": Vector3(2.2255, 1.58, 4.60), "size": Vector2(0.21, 0.29), "rot": Vector3(0.0, 90.0, -1.0)},
	{"tex": "f3/luchtfoto", "pos": Vector3(5.955, 1.78, 6.30), "size": Vector2(0.52, 0.38), "rot": Vector3(0.0, -90.0, 0.0)},
	{"tex": "f3/oprichting", "pos": Vector3(5.955, 1.74, 5.80), "size": Vector2(0.33, 0.45), "rot": Vector3(0.0, -90.0, 0.0)},
	{"tex": "f3/elftalfoto_oud", "pos": Vector3(5.955, 1.80, 6.76), "size": Vector2(0.40, 0.29), "rot": Vector3(0.0, -90.0, 1.2)},
	{"tex": "f2/elftalfoto_2", "pos": Vector3(5.955, 1.30, 5.79), "size": Vector2(0.44, 0.32), "rot": Vector3(0.0, -90.0, -0.8)},
	{"tex": "f3/vaan", "pos": Vector3(5.948, 1.53, 5.42), "size": Vector2(0.20, 0.32), "rot": Vector3(0.0, -90.0, 0.0)},
	{"tex": "f3/briefje_sleutels", "pos": Vector3(2.240, 1.42, 6.86), "size": Vector2(0.10, 0.13), "rot": Vector3(0.0, 90.0, 2.0)},
	{"tex": "f3/archief_etiket", "pos": Vector3(5.558, 1.01, 5.75), "size": Vector2(0.20, 0.085), "rot": Vector3(0.0, -90.0, 0.0)},
	{"tex": "f3/archief_etiket_2", "pos": Vector3(5.508, 0.16, 5.28), "size": Vector2(0.20, 0.085), "rot": Vector3(0.0, -90.0, 0.0)},
	# Hal: het gevulde prikbord, de clubmat en het keuringskaartje van
	# de haspel.
	{"tex": "f3/prikbord_hal", "pos": Vector3(-1.3, 1.6, 6.946), "size": Vector2(1.10, 0.75), "rot": Vector3(0.0, 180.0, 0.0)},
	{"tex": "f3/deurmat_logo", "pos": Vector3(0.0, 0.0155, 6.55), "size": Vector2(0.88, 0.52), "rot": Vector3(-90.0, 0.0, 0.0)},
	{"tex": "f2/keuringskaart", "pos": Vector3(-1.985, 1.32, 5.86), "size": Vector2(0.10, 0.14), "rot": Vector3(0.0, 90.0, 0.0)},
]

## Decals: grounding en materiaalbreuk — de F2.1-lessen toegepast op de
## nieuwe gebieden. Sterktes bewust laag (gebruikssporen, geen verval).
const DECALS: Array[Dictionary] = [
	# ── Bestuurskamer · slijtage en gebruik ──
	{"tex": "looplijn", "vlak": "vloer", "pos": Vector3(2.95, 0.02, 5.45), "size": Vector3(1.6, 0.5, 1.3), "alpha": 0.5, "hoek": 24.0},
	{"tex": "looplijn", "vlak": "vloer", "pos": Vector3(3.9, 0.02, 4.55), "size": Vector3(2.2, 0.5, 1.1), "alpha": 0.4, "hoek": -32.0},
	{"tex": "vloervlek", "vlak": "vloer", "pos": Vector3(3.3, 0.018, 5.95), "size": Vector3(1.6, 0.3, 1.6), "alpha": 0.35},
	{"tex": "vloervlek", "vlak": "vloer", "pos": Vector3(5.0, 0.018, 5.4), "size": Vector3(1.4, 0.3, 1.4), "alpha": 0.3, "hoek": 140.0},
	{"tex": "koffiekring", "vlak": "vloer", "pos": Vector3(4.14, 0.744, 5.06), "size": Vector3(0.16, 0.06, 0.16), "alpha": 0.55},
	{"tex": "koffiekring", "vlak": "vloer", "pos": Vector3(5.79, 0.878, 6.48), "size": Vector3(0.13, 0.05, 0.13), "alpha": 0.5, "hoek": 80.0},
	{"tex": "veeg", "vlak": "x+", "pos": Vector3(2.21, 1.05, 5.42), "size": Vector3(0.55, 0.45, 0.4), "alpha": 0.5},
	{"tex": "veeg", "vlak": "x+", "pos": Vector3(2.21, 1.08, 6.36), "size": Vector3(0.45, 0.4, 0.4), "alpha": 0.4},
	{"tex": "verfrol", "vlak": "x+", "pos": Vector3(2.21, 1.95, 4.6), "size": Vector3(2.4, 0.4, 1.05), "alpha": 0.4},
	{"tex": "verfrol", "vlak": "x-", "pos": Vector3(5.96, 1.95, 6.1), "size": Vector3(2.6, 0.4, 1.05), "alpha": 0.45},
	{"tex": "verfrol", "vlak": "z+", "pos": Vector3(4.0, 1.95, 3.74), "size": Vector3(2.6, 0.4, 1.05), "alpha": 0.4},
	{"tex": "verfschade", "vlak": "x-", "pos": Vector3(5.96, 1.30, 5.55), "size": Vector3(0.55, 0.3, 0.5), "alpha": 0.4},
	{"tex": "vuil_hoek", "vlak": "vloer", "pos": Vector3(5.75, 0.02, 3.95), "size": Vector3(0.9, 0.5, 0.9), "alpha": 0.4, "hoek": 90.0},
	{"tex": "vuil_hoek", "vlak": "vloer", "pos": Vector3(2.45, 0.02, 6.75), "size": Vector3(0.9, 0.5, 0.9), "alpha": 0.35, "hoek": 180.0},
	{"tex": "vuil_rand", "vlak": "x+", "pos": Vector3(2.24, 0.18, 5.0), "size": Vector3(2.8, 0.7, 0.4), "alpha": 0.5},
	{"tex": "vuil_rand", "vlak": "x-", "pos": Vector3(5.93, 0.18, 6.0), "size": Vector3(2.8, 0.7, 0.4), "alpha": 0.5},
	{"tex": "vuil_rand", "vlak": "z-", "pos": Vector3(4.1, 0.18, 6.94), "size": Vector3(3.6, 0.7, 0.4), "alpha": 0.45},
	{"tex": "roet", "vlak": "plafond", "pos": Vector3(3.2, 2.395, 5.6), "size": Vector3(2.0, 0.25, 0.85), "alpha": 0.35},
	{"tex": "vocht", "vlak": "plafond", "pos": Vector3(4.9, 2.395, 6.5), "size": Vector3(0.62, 0.25, 0.62), "alpha": 0.5},

	# ── Bestuurskamer · grounding (contact met vloer en wand) ──
	{"tex": "ao_vlek", "vlak": "vloer", "pos": Vector3(3.85, 0.015, 5.15), "size": Vector3(2.0, 0.3, 1.1), "alpha": 0.4},
	{"tex": "ao_vlek", "vlak": "vloer", "pos": Vector3(3.51, 0.013, 4.40), "size": Vector3(0.44, 0.25, 0.44), "alpha": 0.5},
	{"tex": "ao_vlek", "vlak": "vloer", "pos": Vector3(4.27, 0.013, 4.40), "size": Vector3(0.44, 0.25, 0.44), "alpha": 0.5},
	{"tex": "ao_vlek", "vlak": "vloer", "pos": Vector3(3.53, 0.013, 5.92), "size": Vector3(0.44, 0.25, 0.44), "alpha": 0.5},
	{"tex": "ao_vlek", "vlak": "vloer", "pos": Vector3(4.42, 0.013, 6.10), "size": Vector3(0.44, 0.25, 0.44), "alpha": 0.5},
	{"tex": "ao_vlek", "vlak": "vloer", "pos": Vector3(2.72, 0.013, 5.15), "size": Vector3(0.44, 0.25, 0.44), "alpha": 0.5},
	{"tex": "ao_vlek", "vlak": "vloer", "pos": Vector3(5.13, 0.013, 5.15), "size": Vector3(0.46, 0.25, 0.46), "alpha": 0.5},
	{"tex": "ao_vlek", "vlak": "vloer", "pos": Vector3(5.05, 0.015, 4.16), "size": Vector3(1.4, 0.3, 0.8), "alpha": 0.45},
	{"tex": "ao_vlek", "vlak": "vloer", "pos": Vector3(4.85, 0.013, 4.95), "size": Vector3(0.55, 0.25, 0.55), "alpha": 0.5},
	{"tex": "ao_vlek", "vlak": "vloer", "pos": Vector3(5.74, 0.015, 6.15), "size": Vector3(0.55, 0.3, 1.5), "alpha": 0.5},
	{"tex": "ao_vlek", "vlak": "vloer", "pos": Vector3(2.56, 0.015, 3.96), "size": Vector3(0.7, 0.3, 0.55), "alpha": 0.5},
	{"tex": "ao_vlek", "vlak": "vloer", "pos": Vector3(2.42, 0.015, 4.60), "size": Vector3(0.52, 0.3, 0.7), "alpha": 0.5},
	{"tex": "ao_vlek", "vlak": "vloer", "pos": Vector3(5.70, 0.013, 5.28), "size": Vector3(0.5, 0.25, 0.42), "alpha": 0.5},
	{"tex": "ao_vlek", "vlak": "vloer", "pos": Vector3(4.45, 0.013, 4.72), "size": Vector3(0.36, 0.25, 0.36), "alpha": 0.55},
	{"tex": "ao_vlek", "vlak": "vloer", "pos": Vector3(4.1, 0.014, 6.75), "size": Vector3(1.2, 0.25, 0.5), "alpha": 0.35},
	{"tex": "ao_vlek", "vlak": "z-", "pos": Vector3(4.1, 0.45, 6.94), "size": Vector3(1.3, 0.35, 0.75), "alpha": 0.3},
	{"tex": "ao_vlek", "vlak": "x-", "pos": Vector3(5.95, 1.60, 6.30), "size": Vector3(1.2, 0.3, 1.0), "alpha": 0.28},
	{"tex": "ao_vlek", "vlak": "z+", "pos": Vector3(3.60, 1.60, 3.75), "size": Vector3(1.1, 0.25, 0.9), "alpha": 0.28},
	# Wand/plafond- en plintranden.
	{"tex": "ao_lijn", "vlak": "z+", "pos": Vector3(4.085, 2.24, 3.74), "size": Vector3(3.8, 0.4, 0.52), "alpha": 0.45},
	{"tex": "ao_lijn", "vlak": "z-", "pos": Vector3(4.085, 2.24, 6.95), "size": Vector3(3.8, 0.4, 0.52), "alpha": 0.45},
	{"tex": "ao_lijn", "vlak": "x+", "pos": Vector3(2.23, 2.24, 5.35), "size": Vector3(3.3, 0.4, 0.52), "alpha": 0.45},
	{"tex": "ao_lijn", "vlak": "x-", "pos": Vector3(5.95, 2.24, 5.35), "size": Vector3(3.3, 0.4, 0.52), "alpha": 0.45},
	{"tex": "ao_lijn", "vlak": "x+", "pos": Vector3(2.23, 0.14, 4.5), "size": Vector3(1.5, 0.3, 0.2), "alpha": 0.35, "hoek": 180.0},
	{"tex": "ao_lijn", "vlak": "z+", "pos": Vector3(4.0, 0.14, 3.75), "size": Vector3(3.7, 0.3, 0.2), "alpha": 0.35, "hoek": 180.0},
	# Deurkozijn hecht aan de wand.
	{"tex": "ao_lijn", "vlak": "x+", "pos": Vector3(2.21, 1.10, 5.20), "size": Vector3(0.22, 0.35, 2.1), "alpha": 0.35, "hoek": 90.0},
	{"tex": "ao_lijn", "vlak": "x+", "pos": Vector3(2.21, 1.10, 6.28), "size": Vector3(0.22, 0.35, 2.1), "alpha": 0.35, "hoek": -90.0},

	# ── Hal · looplijnen: iedereen loopt van de entree naar de gang of
	#    de kantine — de vloer weet dat ──
	{"tex": "looplijn", "vlak": "vloer", "pos": Vector3(-0.9, 0.02, 5.5), "size": Vector3(2.2, 0.6, 1.6), "alpha": 0.7, "hoek": 35.0},
	{"tex": "looplijn", "vlak": "vloer", "pos": Vector3(1.0, 0.02, 4.7), "size": Vector3(1.8, 0.5, 1.4), "alpha": 0.5, "hoek": -40.0},
	{"tex": "looplijn", "vlak": "vloer", "pos": Vector3(-1.5, 0.02, 4.4), "size": Vector3(1.4, 0.5, 1.2), "alpha": 0.6, "hoek": 80.0},
	{"tex": "slijtglans", "orm": "slijtglans_orm", "mix": 0.0, "vlak": "vloer", "pos": Vector3(-0.6, 0.02, 5.3), "size": Vector3(2.2, 0.3, 2.0), "alpha": 0.7, "hoek": 35.0},
	{"tex": "slijtglans", "orm": "slijtglans_orm", "mix": 0.0, "vlak": "vloer", "pos": Vector3(0.9, 0.02, 4.5), "size": Vector3(1.6, 0.3, 1.6), "alpha": 0.6, "hoek": -40.0},
	# Binnen is droog — op de druppelsporen bij de entree-mat na
	# (artplan §4).
	{"tex": "druppelspoor", "vlak": "vloer", "pos": Vector3(0.0, 0.018, 5.95), "size": Vector3(1.1, 0.3, 0.9), "alpha": 0.6},
	{"tex": "druppelspoor", "vlak": "vloer", "pos": Vector3(0.3, 0.018, 6.35), "size": Vector3(0.7, 0.3, 0.6), "alpha": 0.5, "hoek": 60.0},
	{"tex": "schoenstreep", "vlak": "vloer", "pos": Vector3(0.15, 0.02, 6.1), "size": Vector3(1.3, 0.5, 1.0), "alpha": 0.5},
	# Vuilranden, hoeken en handsporen.
	{"tex": "vuil_rand", "vlak": "z-", "pos": Vector3(0.0, 0.22, 2.36), "size": Vector3(3.6, 0.9, 0.5), "alpha": 0.7},
	{"tex": "vuil_rand", "vlak": "x-", "pos": Vector3(-1.94, 0.22, 5.9), "size": Vector3(2.0, 0.9, 0.5), "alpha": 0.6},
	{"tex": "vuil_rand", "vlak": "x-", "pos": Vector3(-1.94, 0.22, 3.0), "size": Vector3(1.4, 0.9, 0.5), "alpha": 0.55},
	{"tex": "vuil_rand", "vlak": "z+", "pos": Vector3(1.25, 0.22, 6.92), "size": Vector3(1.4, 0.9, 0.5), "alpha": 0.6},
	{"tex": "vuil_hoek", "vlak": "vloer", "pos": Vector3(-1.75, 0.02, 6.7), "size": Vector3(0.9, 0.5, 0.9), "alpha": 0.4, "hoek": 180.0},
	{"tex": "vuil_hoek", "vlak": "vloer", "pos": Vector3(1.75, 0.02, 2.55), "size": Vector3(0.9, 0.5, 0.9), "alpha": 0.35, "hoek": 90.0},
	{"tex": "veeg", "vlak": "x-", "pos": Vector3(-1.96, 1.05, 4.0), "size": Vector3(0.5, 0.45, 0.4), "alpha": 0.55},
	{"tex": "veeg", "vlak": "x+", "pos": Vector3(1.96, 1.05, 3.15), "size": Vector3(0.5, 0.45, 0.4), "alpha": 0.5},
	{"tex": "veeg", "vlak": "z+", "pos": Vector3(0.35, 1.05, 6.94), "size": Vector3(0.5, 0.45, 0.4), "alpha": 0.5},
	{"tex": "verfrol", "vlak": "x-", "pos": Vector3(-1.94, 1.9, 5.8), "size": Vector3(2.0, 0.4, 1.05), "alpha": 0.4},
	{"tex": "verfrol", "vlak": "x+", "pos": Vector3(1.94, 1.9, 4.3), "size": Vector3(2.4, 0.4, 1.05), "alpha": 0.45},
	# Grounding.
	{"tex": "ao_vlek", "vlak": "vloer", "pos": Vector3(0.0, 0.014, 2.59), "size": Vector3(1.3, 0.3, 0.5), "alpha": 0.5},
	{"tex": "ao_vlek", "vlak": "vloer", "pos": Vector3(1.60, 0.013, 6.45), "size": Vector3(0.42, 0.25, 0.42), "alpha": 0.55},
	{"tex": "ao_vlek", "vlak": "vloer", "pos": Vector3(0.78, 0.013, 6.72), "size": Vector3(0.32, 0.25, 0.32), "alpha": 0.5},
	{"tex": "ao_vlek", "vlak": "vloer", "pos": Vector3(0.0, 0.012, 6.55), "size": Vector3(1.1, 0.25, 0.75), "alpha": 0.35},
	{"tex": "ao_vlek", "vlak": "vloer", "pos": Vector3(1.45, 0.014, 6.75), "size": Vector3(0.95, 0.25, 0.5), "alpha": 0.35},
	{"tex": "ao_vlek", "vlak": "z+", "pos": Vector3(1.45, 0.45, 6.93), "size": Vector3(1.0, 0.35, 0.7), "alpha": 0.3},
	{"tex": "ao_vlek", "vlak": "z+", "pos": Vector3(-1.3, 1.6, 6.94), "size": Vector3(1.4, 0.25, 1.0), "alpha": 0.28},
	{"tex": "ao_vlek", "vlak": "z-", "pos": Vector3(0.0, 1.68, 2.37), "size": Vector3(3.2, 0.25, 0.5), "alpha": 0.3},
	{"tex": "ao_vlek", "vlak": "x-", "pos": Vector3(-1.95, 1.30, 5.45), "size": Vector3(0.9, 0.3, 0.9), "alpha": 0.3},
	{"tex": "ao_lijn", "vlak": "z-", "pos": Vector3(0.0, 2.46, 2.36), "size": Vector3(3.9, 0.4, 0.5), "alpha": 0.45},
	{"tex": "ao_lijn", "vlak": "z+", "pos": Vector3(0.0, 2.46, 6.92), "size": Vector3(3.9, 0.4, 0.5), "alpha": 0.45},
	{"tex": "ao_lijn", "vlak": "x-", "pos": Vector3(-1.94, 2.46, 4.6), "size": Vector3(4.6, 0.4, 0.5), "alpha": 0.45},
	{"tex": "ao_lijn", "vlak": "x+", "pos": Vector3(1.94, 2.46, 4.6), "size": Vector3(4.6, 0.4, 0.5), "alpha": 0.45},
	{"tex": "ao_lijn", "vlak": "z-", "pos": Vector3(0.0, 0.14, 2.36), "size": Vector3(3.9, 0.3, 0.2), "alpha": 0.35, "hoek": 180.0},
	{"tex": "ao_lijn", "vlak": "x-", "pos": Vector3(-1.94, 0.14, 5.9), "size": Vector3(2.1, 0.3, 0.2), "alpha": 0.35, "hoek": 180.0},
]

var _materialen := {}
var _meshes := {}
var _wortel: Node3D


func _ready() -> void:
	_wortel = Node3D.new()
	_wortel.name = "F3Detail"
	add_child(_wortel)
	for solid in SOLIDS:
		_bouw_solid(solid)
	for paneel in PANELEN:
		_bouw_paneel(paneel)
	for decal in DECALS:
		_bouw_decal(decal)
	_bouw_regen()
	_bouw_regen_audio()
	Log.info("F3-detaillaag: %d onderdelen" % _wortel.get_child_count())


## Zelfde bouwer als de F2-laag: StaticBody3D met geschaalde mesh en
## optionele BoxShape; "verborgen" = alleen collision.
func _bouw_solid(solid: Dictionary) -> void:
	var size: Vector3 = solid["size"]
	var body := StaticBody3D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	if not solid.get("verborgen", false):
		var mesh := MeshInstance3D.new()
		var vorm: String = solid.get("vorm", "box")
		mesh.mesh = _mesh_voor(vorm, size)
		if vorm == "box":
			mesh.scale = size
		mesh.material_override = _materiaal(solid["mat"])
		body.add_child(mesh)
	if solid.get("col", false):
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = size
		var vorm_naam: String = solid.get("vorm", "box")
		if vorm_naam == "cyl" or vorm_naam == "bol":
			box.size = Vector3(size.x * 2.0, size.y, size.z * 2.0)
		shape.shape = box
		body.add_child(shape)
	_wortel.add_child(body)
	body.position = solid["pos"]
	body.rotation_degrees = solid.get("rot", Vector3.ZERO)


func _mesh_voor(vorm: String, size: Vector3) -> Mesh:
	if vorm == "box":
		if not _meshes.has("box"):
			_meshes["box"] = BoxMesh.new()
		return _meshes["box"]
	var sleutel := "%s:%.4v" % [vorm, size]
	if _meshes.has(sleutel):
		return _meshes[sleutel]
	var mesh: Mesh
	match vorm:
		"cyl":
			var cyl := CylinderMesh.new()
			cyl.top_radius = size.x
			cyl.bottom_radius = size.x
			cyl.height = size.y
			cyl.radial_segments = 12
			cyl.rings = 1
			mesh = cyl
		"bol":
			var bol := SphereMesh.new()
			bol.radius = size.x
			bol.height = size.y
			bol.radial_segments = 14
			bol.rings = 7
			mesh = bol
		"torus":
			var torus := TorusMesh.new()
			torus.inner_radius = size.x
			torus.outer_radius = size.y
			torus.rings = 16
			torus.ring_segments = 8
			mesh = torus
		_:
			mesh = BoxMesh.new()
	_meshes[sleutel] = mesh
	return mesh


func _materiaal(key: StringName) -> StandardMaterial3D:
	if _materialen.has(key):
		return _materialen[key]
	var material := StandardMaterial3D.new()
	var spec: Variant = MATERIALEN[key]
	if spec is Color:
		material.albedo_color = spec
		material.roughness = 0.85
	else:
		material.albedo_color = spec.get("tint", Color.WHITE)
		material.roughness = spec.get("rough", 1.0)
		material.metallic = spec.get("metallic", 0.0)
		if spec.has("emissie"):
			material.emission_enabled = true
			material.emission = spec["emissie"]
			material.emission_energy_multiplier = spec.get("energie", 1.0)
		if spec.has("tex"):
			var tex: String = spec["tex"]
			var basis := "res://assets/textures/%s/%s" % [tex, tex]
			if not spec.get("vlak_gelakt", false):
				material.albedo_texture = load(basis + "_color.jpg")
			material.normal_enabled = true
			material.normal_texture = load(basis + "_normal.jpg")
			material.normal_scale = spec.get("normal", 1.0)
			material.roughness_texture = load(basis + "_rough.jpg")
			material.uv1_triplanar = true
			material.uv1_world_triplanar = true
			var schaal: float = spec.get("scale", 1.0)
			material.uv1_scale = Vector3(schaal, schaal, schaal)
	_materialen[key] = material
	return _materialen[key]


func _bouw_paneel(paneel: Dictionary) -> void:
	var mesh := MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = paneel["size"]
	mesh.mesh = quad
	var material := StandardMaterial3D.new()
	material.albedo_texture = load(
		"res://assets/textures/%s.png" % paneel["tex"])
	material.roughness = 0.7
	if paneel.get("alpha", false):
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	mesh.material_override = material
	_wortel.add_child(mesh)
	mesh.position = paneel["pos"]
	mesh.rotation_degrees = paneel.get("rot", Vector3.ZERO)


func _bouw_decal(spec: Dictionary) -> void:
	var decal := Decal.new()
	decal.texture_albedo = load(
		"res://assets/textures/decals/%s.png" % spec["tex"])
	if spec.has("orm"):
		decal.texture_orm = load(
			"res://assets/textures/decals/%s.png" % spec["orm"])
	decal.size = spec["size"]
	decal.modulate = Color(1.0, 1.0, 1.0, spec.get("alpha", 0.6))
	decal.albedo_mix = spec.get("mix", 1.0)
	decal.upper_fade = 0.6
	decal.lower_fade = 0.35
	decal.normal_fade = 0.25
	_wortel.add_child(decal)
	decal.position = spec["pos"]
	var hoek: float = spec.get("hoek", 0.0)
	match spec.get("vlak", "vloer"):
		"plafond":
			decal.rotation_degrees = Vector3(180.0, hoek, 0.0)
		"z+":
			decal.rotation_degrees = Vector3(-90.0, 0.0, hoek)
		"z-":
			decal.rotation_degrees = Vector3(90.0, 0.0, hoek)
		"x+":
			decal.rotation_degrees = Vector3(0.0, 0.0, 90.0 + hoek)
		"x-":
			decal.rotation_degrees = Vector3(0.0, 0.0, -90.0 + hoek)
		_:
			decal.rotation_degrees = Vector3(0.0, hoek, 0.0)


## Regen boven het voorplein: twee GPUParticles3D-volumes (dichtbij +
## verte-laag achter het hek) — wereldregen, geen camera-effect. Unlit
## en zwak: hij leest als beweging in het licht van de entreelamp, niet
## als wit confetti. Volgt in F3.4; zonder texture gebeurt er niets.
func _bouw_regen() -> void:
	if not ResourceLoader.exists(REGEN_TEXTURE):
		return
	pass  # F3.4 vult dit in.


## Ruimtelijke regen-audio: drie emitters langs de gevel. Zonder de
## gegenereerde loop (F3.5) blijft het stil — geen harde afhankelijkheid.
func _bouw_regen_audio() -> void:
	if not ResourceLoader.exists(REGEN_AUDIO):
		return
	pass  # F3.5 vult dit in.
