extends Node3D
## F2-detaillaag van het clubgebouw (fase G, tier F2): de laag die
## kleedkamer 3 en de gang van greybox naar "echt gebruikte ruimte" tilt.
##
## Bewust één losse eenheid onder `game/levels/clubgebouw/f2_detail/`:
## gooi de map weg en het clubgebouw draait exact als in tier F1 verder
## (D-015). Het level instantieert deze scène met een bestaanscheck en
## slaat de F1-greyboxvolumes over die hier door echte props worden
## vervangen (de `"f2": true`-vlag in clubgebouw.gd).
##
## Alles is data, net als de rest van het level (TD-007): elke lat, buis
## en vuilvlek is één regel in een tabel. De bouwer kent vijf vormen
## (box/cilinder/bol/torus/vlak), volledige rotatie, optionele collision
## en decals — genoeg om zonder externe modellen een geloofwaardige
## Nederlandse kleedkamer te kitbashen.
##
## Wat deze laag NIET doet: architectuur verplaatsen, doorgangen
## versmallen, gameplay toevoegen of het schaduwbudget aanraken (D-026).
## De enige lichtbron die hij toevoegt is de groene gloed onder het
## nooduitgangbord — puur sfeer, geen schaduw.

## Materialen. Zelfde vorm als in clubgebouw.gd: Color = vlak, Dictionary
## = PBR uit assets/textures/ (CC0, D-031). Extra sleutels t.o.v. F1:
## "metallic" en "normal" (sterkte van de normal map).
const MATERIALEN := {
	# — Hout, staal en kunststof van de inrichting —
	&"bank_lat": {"tex": "planken", "tint": Color(0.17, 0.30, 0.49), "scale": 1.6, "rough": 0.38, "normal": 0.8, "vlak_gelakt": true},
	&"bank_frame": {"tex": "metaal", "tint": Color(0.38, 0.40, 0.43), "scale": 1.2, "rough": 0.5, "metallic": 0.6},
	&"kapstok_hout": {"tex": "planken", "tint": Color(0.42, 0.36, 0.29), "scale": 1.4, "rough": 0.66},
	&"locker_blauw": {"tex": "metaal", "tint": Color(0.13, 0.27, 0.45), "scale": 0.9, "rough": 0.42, "metallic": 0.35},
	&"locker_diep": Color(0.035, 0.04, 0.05),
	&"staal": {"tex": "metaal", "tint": Color(0.52, 0.54, 0.57), "scale": 1.1, "rough": 0.35, "metallic": 0.75},
	&"staal_donker": {"tex": "metaal", "tint": Color(0.26, 0.27, 0.29), "scale": 1.0, "rough": 0.55, "metallic": 0.5},
	&"email_wit": Color(0.74, 0.74, 0.71),
	&"kunststof_wit": Color(0.78, 0.78, 0.75),
	&"kunststof_grijs": Color(0.33, 0.35, 0.37),
	&"kunststof_blauw": Color(0.20, 0.29, 0.38),
	&"kunststof_zwart": Color(0.09, 0.09, 0.10),
	&"rubber_mat": {"tex": "rubber", "tint": Color(0.42, 0.42, 0.44), "scale": 1.4, "rough": 0.95},
	&"karton": Color(0.33, 0.28, 0.21),
	&"rood_blusser": Color(0.42, 0.09, 0.08),
	&"tegel_trim": Color(0.30, 0.33, 0.38),
	&"plint": Color(0.26, 0.28, 0.31),
	&"alu": {"tex": "metaal", "tint": Color(0.60, 0.62, 0.64), "scale": 1.3, "rough": 0.3, "metallic": 0.8},
	# — Textiel en achtergelaten spullen —
	&"jack_blauw": {"tex": "tapijt", "tint": Color(0.16, 0.28, 0.46), "scale": 1.0, "rough": 0.85, "normal": 0.6},
	&"handdoek": {"tex": "tapijt", "tint": Color(0.58, 0.60, 0.60), "scale": 1.1, "rough": 0.9, "normal": 0.6},
	&"sok_wit": {"tex": "tapijt", "tint": Color(0.76, 0.75, 0.70), "scale": 1.6, "rough": 0.92, "normal": 0.5},
	&"tas_grijs": {"tex": "tapijt", "tint": Color(0.22, 0.24, 0.24), "scale": 0.9, "rough": 0.8, "normal": 0.7},
	&"scheenbeschermer": Color(0.72, 0.72, 0.70),
	&"papier": Color(0.78, 0.77, 0.72),
}

## Vaste vormen: "box" (default), "cyl", "bol", "torus".
## Sleutels: pos · size · mat · rot (graden) · col (collision, default uit)
## · verborgen (alleen collision, geen mesh — voor meubels die je uit
## losse latten opbouwt maar als één blok moet aanvoelen).
const SOLIDS: Array[Dictionary] = [
	# ══════════════ KLEEDKAMER 3 — de hero room ══════════════
	# Afwerking: tegelrand op 1,40 m en een plint langs de vloer. De
	# tegelband zelf komt uit tier F1; dit zijn de randen die hem als
	# echt tegelwerk laten lezen (schaal-ijkpunten, artplan §2.6).
	{"pos": Vector3(-4.7, 1.412, 3.175), "size": Vector3(4.6, 0.025, 0.05), "mat": &"tegel_trim"},
	{"pos": Vector3(-4.7, 1.412, -1.275), "size": Vector3(4.6, 0.025, 0.05), "mat": &"tegel_trim"},
	{"pos": Vector3(-2.425, 1.412, 0.95), "size": Vector3(0.05, 0.025, 4.5), "mat": &"tegel_trim"},
	{"pos": Vector3(-6.975, 1.412, 0.95), "size": Vector3(0.05, 0.025, 4.5), "mat": &"tegel_trim"},
	{"pos": Vector3(-4.7, 0.05, 3.17), "size": Vector3(4.6, 0.1, 0.06), "mat": &"plint"},
	{"pos": Vector3(-4.7, 0.05, -1.27), "size": Vector3(4.6, 0.1, 0.06), "mat": &"plint"},
	{"pos": Vector3(-2.43, 0.05, 0.95), "size": Vector3(0.06, 0.1, 4.5), "mat": &"plint"},
	{"pos": Vector3(-6.97, 0.05, 0.95), "size": Vector3(0.06, 0.1, 4.5), "mat": &"plint"},

	# Deurkozijn aan de kamerzijde + drempelstrip in de doorgang.
	{"pos": Vector3(-4.455, 1.065, 3.175), "size": Vector3(0.07, 2.13, 0.06), "mat": &"kunststof_wit"},
	{"pos": Vector3(-3.365, 1.065, 3.175), "size": Vector3(0.07, 2.13, 0.06), "mat": &"kunststof_wit"},
	{"pos": Vector3(-3.91, 2.16, 3.175), "size": Vector3(1.16, 0.07, 0.06), "mat": &"kunststof_wit"},
	{"pos": Vector3(-3.91, 0.006, 3.3), "size": Vector3(1.02, 0.012, 0.22), "mat": &"alu"},
	# Doorgang naar douche 3: dorpel en een aluminium hoekprofiel.
	{"pos": Vector3(-4.0, 0.008, -1.4), "size": Vector3(1.0, 0.016, 0.22), "mat": &"alu"},

	# ── Bank west (langs de tussenwand) — vier latten op drie schragen ──
	{"pos": Vector3(-6.90, 0.4325, 0.95), "size": Vector3(0.075, 0.035, 3.9), "mat": &"bank_lat"},
	{"pos": Vector3(-6.81, 0.4325, 0.95), "size": Vector3(0.075, 0.035, 3.9), "mat": &"bank_lat"},
	{"pos": Vector3(-6.72, 0.4325, 0.95), "size": Vector3(0.075, 0.035, 3.9), "mat": &"bank_lat"},
	{"pos": Vector3(-6.63, 0.4325, 0.95), "size": Vector3(0.075, 0.035, 3.9), "mat": &"bank_lat"},
	{"pos": Vector3(-6.88, 0.205, -0.75), "size": Vector3(0.045, 0.41, 0.045), "mat": &"bank_frame"},
	{"pos": Vector3(-6.66, 0.205, -0.75), "size": Vector3(0.045, 0.41, 0.045), "mat": &"bank_frame"},
	{"pos": Vector3(-6.77, 0.39, -0.75), "size": Vector3(0.30, 0.04, 0.045), "mat": &"bank_frame"},
	{"pos": Vector3(-6.88, 0.205, 0.95), "size": Vector3(0.045, 0.41, 0.045), "mat": &"bank_frame"},
	{"pos": Vector3(-6.66, 0.205, 0.95), "size": Vector3(0.045, 0.41, 0.045), "mat": &"bank_frame"},
	{"pos": Vector3(-6.77, 0.39, 0.95), "size": Vector3(0.30, 0.04, 0.045), "mat": &"bank_frame"},
	{"pos": Vector3(-6.88, 0.205, 2.65), "size": Vector3(0.045, 0.41, 0.045), "mat": &"bank_frame"},
	{"pos": Vector3(-6.66, 0.205, 2.65), "size": Vector3(0.045, 0.41, 0.045), "mat": &"bank_frame"},
	{"pos": Vector3(-6.77, 0.39, 2.65), "size": Vector3(0.30, 0.04, 0.045), "mat": &"bank_frame"},
	{"pos": Vector3(-6.77, 0.24, 0.95), "size": Vector3(0.36, 0.48, 3.9), "col": true, "verborgen": true},

	# ── Bank oost ──
	{"pos": Vector3(-2.76, 0.4325, 0.45), "size": Vector3(0.075, 0.035, 2.9), "mat": &"bank_lat"},
	{"pos": Vector3(-2.67, 0.4325, 0.45), "size": Vector3(0.075, 0.035, 2.9), "mat": &"bank_lat"},
	{"pos": Vector3(-2.58, 0.4325, 0.45), "size": Vector3(0.075, 0.035, 2.9), "mat": &"bank_lat"},
	{"pos": Vector3(-2.49, 0.4325, 0.45), "size": Vector3(0.075, 0.035, 2.9), "mat": &"bank_lat"},
	{"pos": Vector3(-2.74, 0.205, -0.70), "size": Vector3(0.045, 0.41, 0.045), "mat": &"bank_frame"},
	{"pos": Vector3(-2.52, 0.205, -0.70), "size": Vector3(0.045, 0.41, 0.045), "mat": &"bank_frame"},
	{"pos": Vector3(-2.63, 0.39, -0.70), "size": Vector3(0.30, 0.04, 0.045), "mat": &"bank_frame"},
	{"pos": Vector3(-2.74, 0.205, 0.45), "size": Vector3(0.045, 0.41, 0.045), "mat": &"bank_frame"},
	{"pos": Vector3(-2.52, 0.205, 0.45), "size": Vector3(0.045, 0.41, 0.045), "mat": &"bank_frame"},
	{"pos": Vector3(-2.63, 0.39, 0.45), "size": Vector3(0.30, 0.04, 0.045), "mat": &"bank_frame"},
	{"pos": Vector3(-2.74, 0.205, 1.60), "size": Vector3(0.045, 0.41, 0.045), "mat": &"bank_frame"},
	{"pos": Vector3(-2.52, 0.205, 1.60), "size": Vector3(0.045, 0.41, 0.045), "mat": &"bank_frame"},
	{"pos": Vector3(-2.63, 0.39, 1.60), "size": Vector3(0.30, 0.04, 0.045), "mat": &"bank_frame"},
	{"pos": Vector3(-2.63, 0.24, 0.45), "size": Vector3(0.36, 0.48, 2.9), "col": true, "verborgen": true},

	# ── Kapstokrails met dubbele haken (west: 8, oost: 6) ──
	{"pos": Vector3(-6.98, 1.68, 0.95), "size": Vector3(0.04, 0.16, 3.9), "mat": &"kapstok_hout"},
	{"pos": Vector3(-2.42, 1.68, 0.45), "size": Vector3(0.04, 0.16, 2.9), "mat": &"kapstok_hout"},
	{"pos": Vector3(-6.945, 1.66, -0.70), "size": Vector3(0.02, 0.10, 0.03), "mat": &"staal"},
	{"pos": Vector3(-6.89, 1.615, -0.70), "size": Vector3(0.11, 0.022, 0.022), "mat": &"staal"},
	{"pos": Vector3(-6.945, 1.66, -0.25), "size": Vector3(0.02, 0.10, 0.03), "mat": &"staal"},
	{"pos": Vector3(-6.89, 1.615, -0.25), "size": Vector3(0.11, 0.022, 0.022), "mat": &"staal"},
	{"pos": Vector3(-6.945, 1.66, 0.20), "size": Vector3(0.02, 0.10, 0.03), "mat": &"staal"},
	{"pos": Vector3(-6.89, 1.615, 0.20), "size": Vector3(0.11, 0.022, 0.022), "mat": &"staal"},
	{"pos": Vector3(-6.945, 1.66, 0.65), "size": Vector3(0.02, 0.10, 0.03), "mat": &"staal"},
	{"pos": Vector3(-6.89, 1.615, 0.65), "size": Vector3(0.11, 0.022, 0.022), "mat": &"staal"},
	{"pos": Vector3(-6.945, 1.66, 1.10), "size": Vector3(0.02, 0.10, 0.03), "mat": &"staal"},
	{"pos": Vector3(-6.89, 1.615, 1.10), "size": Vector3(0.11, 0.022, 0.022), "mat": &"staal"},
	{"pos": Vector3(-6.945, 1.66, 1.55), "size": Vector3(0.02, 0.10, 0.03), "mat": &"staal"},
	{"pos": Vector3(-6.89, 1.615, 1.55), "size": Vector3(0.11, 0.022, 0.022), "mat": &"staal"},
	{"pos": Vector3(-6.945, 1.66, 2.00), "size": Vector3(0.02, 0.10, 0.03), "mat": &"staal"},
	{"pos": Vector3(-6.89, 1.615, 2.00), "size": Vector3(0.11, 0.022, 0.022), "mat": &"staal"},
	{"pos": Vector3(-6.945, 1.66, 2.45), "size": Vector3(0.02, 0.10, 0.03), "mat": &"staal"},
	{"pos": Vector3(-6.89, 1.615, 2.45), "size": Vector3(0.11, 0.022, 0.022), "mat": &"staal"},
	{"pos": Vector3(-2.455, 1.66, -0.55), "size": Vector3(0.02, 0.10, 0.03), "mat": &"staal"},
	{"pos": Vector3(-2.51, 1.615, -0.55), "size": Vector3(0.11, 0.022, 0.022), "mat": &"staal"},
	{"pos": Vector3(-2.455, 1.66, -0.10), "size": Vector3(0.02, 0.10, 0.03), "mat": &"staal"},
	{"pos": Vector3(-2.51, 1.615, -0.10), "size": Vector3(0.11, 0.022, 0.022), "mat": &"staal"},
	{"pos": Vector3(-2.455, 1.66, 0.35), "size": Vector3(0.02, 0.10, 0.03), "mat": &"staal"},
	{"pos": Vector3(-2.51, 1.615, 0.35), "size": Vector3(0.11, 0.022, 0.022), "mat": &"staal"},
	{"pos": Vector3(-2.455, 1.66, 0.80), "size": Vector3(0.02, 0.10, 0.03), "mat": &"staal"},
	{"pos": Vector3(-2.51, 1.615, 0.80), "size": Vector3(0.11, 0.022, 0.022), "mat": &"staal"},
	{"pos": Vector3(-2.455, 1.66, 1.25), "size": Vector3(0.02, 0.10, 0.03), "mat": &"staal"},
	{"pos": Vector3(-2.51, 1.615, 1.25), "size": Vector3(0.11, 0.022, 0.022), "mat": &"staal"},
	{"pos": Vector3(-2.455, 1.66, 1.70), "size": Vector3(0.02, 0.10, 0.03), "mat": &"staal"},
	{"pos": Vector3(-2.51, 1.615, 1.70), "size": Vector3(0.11, 0.022, 0.022), "mat": &"staal"},

	# Het enige kledingstuk in het gebouw: een vergeten trainingsjack
	# (artplan §8) — hangt scheef, zoals iemand hem ophing.
	{"pos": Vector3(-6.855, 1.30, 1.10), "size": Vector3(0.11, 0.60, 0.34), "mat": &"jack_blauw", "rot": Vector3(0.0, 5.0, 2.0)},
	{"pos": Vector3(-6.87, 1.585, 1.10), "size": Vector3(0.09, 0.10, 0.26), "mat": &"jack_blauw", "rot": Vector3(0.0, 5.0, 0.0)},

	# ── Lockers (drie stuks; de ruimte tussen bank en zuidwand laat er
	#    geen zes toe — zie het uitvoeringsverslag) ──
	{"pos": Vector3(-2.78, 0.90, 2.60), "size": Vector3(0.58, 1.68, 0.98), "mat": &"locker_blauw", "col": true},
	{"pos": Vector3(-2.78, 0.03, 2.60), "size": Vector3(0.58, 0.06, 0.98), "mat": &"staal_donker"},
	{"pos": Vector3(-2.78, 1.755, 2.60), "size": Vector3(0.60, 0.03, 1.00), "mat": &"staal_donker"},
	{"pos": Vector3(-3.075, 0.93, 2.26), "size": Vector3(0.015, 1.60, 0.30), "mat": &"locker_blauw"},
	{"pos": Vector3(-3.075, 0.93, 2.60), "size": Vector3(0.015, 1.60, 0.30), "mat": &"locker_blauw"},
	{"pos": Vector3(-2.80, 0.93, 2.94), "size": Vector3(0.52, 1.58, 0.28), "mat": &"locker_diep"},
	{"pos": Vector3(-3.139, 0.93, 2.952), "size": Vector3(0.015, 1.60, 0.30), "mat": &"locker_blauw", "rot": Vector3(0.0, 25.0, 0.0)},
	{"pos": Vector3(-3.09, 1.00, 2.14), "size": Vector3(0.025, 0.11, 0.02), "mat": &"staal"},
	{"pos": Vector3(-3.09, 1.00, 2.48), "size": Vector3(0.025, 0.11, 0.02), "mat": &"staal"},
	{"pos": Vector3(-3.10, 0.90, 2.15), "size": Vector3(0.03, 0.05, 0.035), "mat": &"staal_donker"},
	{"pos": Vector3(-3.10, 0.90, 2.49), "size": Vector3(0.03, 0.05, 0.035), "mat": &"staal_donker"},

	# ── Radiator met leidingen en kraan (noordwand) ──
	{"pos": Vector3(-5.75, 0.42, -1.245), "size": Vector3(0.90, 0.55, 0.08), "mat": &"email_wit"},
	{"pos": Vector3(-6.10, 0.42, -1.20), "size": Vector3(0.02, 0.53, 0.02), "mat": &"email_wit"},
	{"pos": Vector3(-5.93, 0.42, -1.20), "size": Vector3(0.02, 0.53, 0.02), "mat": &"email_wit"},
	{"pos": Vector3(-5.75, 0.42, -1.20), "size": Vector3(0.02, 0.53, 0.02), "mat": &"email_wit"},
	{"pos": Vector3(-5.57, 0.42, -1.20), "size": Vector3(0.02, 0.53, 0.02), "mat": &"email_wit"},
	{"pos": Vector3(-5.40, 0.42, -1.20), "size": Vector3(0.02, 0.53, 0.02), "mat": &"email_wit"},
	{"pos": Vector3(-6.05, 0.72, -1.26), "size": Vector3(0.04, 0.10, 0.06), "mat": &"staal_donker"},
	{"pos": Vector3(-5.45, 0.72, -1.26), "size": Vector3(0.04, 0.10, 0.06), "mat": &"staal_donker"},
	{"vorm": "cyl", "pos": Vector3(-6.15, 0.08, -1.22), "size": Vector3(0.014, 0.16, 0.014), "mat": &"staal"},
	{"vorm": "cyl", "pos": Vector3(-5.35, 0.08, -1.22), "size": Vector3(0.014, 0.16, 0.014), "mat": &"staal"},
	{"vorm": "cyl", "pos": Vector3(-6.15, 0.19, -1.22), "size": Vector3(0.032, 0.07, 0.032), "mat": &"staal_donker"},

	# Verwarmingsleiding in de noordoosthoek, met beugels.
	{"vorm": "cyl", "pos": Vector3(-2.52, 1.25, -1.21), "size": Vector3(0.028, 2.5, 0.028), "mat": &"staal"},
	{"pos": Vector3(-2.50, 0.45, -1.24), "size": Vector3(0.05, 0.03, 0.05), "mat": &"staal_donker"},
	{"pos": Vector3(-2.50, 1.40, -1.24), "size": Vector3(0.05, 0.03, 0.05), "mat": &"staal_donker"},
	{"pos": Vector3(-2.50, 2.25, -1.24), "size": Vector3(0.05, 0.03, 0.05), "mat": &"staal_donker"},

	# ── Schakelaar en dubbel stopcontact naast de deur ──
	{"pos": Vector3(-4.62, 1.05, 3.183), "size": Vector3(0.085, 0.085, 0.014), "mat": &"kunststof_wit"},
	{"pos": Vector3(-4.62, 1.05, 3.172), "size": Vector3(0.055, 0.055, 0.010), "mat": &"kunststof_wit"},
	{"pos": Vector3(-4.90, 0.32, 3.183), "size": Vector3(0.150, 0.080, 0.014), "mat": &"kunststof_wit"},

	# ── Ventilatierooster boven de doucheopening ──
	{"pos": Vector3(-4.00, 2.30, -1.29), "size": Vector3(0.34, 0.24, 0.02), "mat": &"staal_donker"},
	{"pos": Vector3(-4.00, 2.375, -1.30), "size": Vector3(0.30, 0.016, 0.012), "mat": &"staal"},
	{"pos": Vector3(-4.00, 2.335, -1.30), "size": Vector3(0.30, 0.016, 0.012), "mat": &"staal"},
	{"pos": Vector3(-4.00, 2.295, -1.30), "size": Vector3(0.30, 0.016, 0.012), "mat": &"staal"},
	{"pos": Vector3(-4.00, 2.255, -1.30), "size": Vector3(0.30, 0.016, 0.012), "mat": &"staal"},
	{"pos": Vector3(-4.00, 2.215, -1.30), "size": Vector3(0.30, 0.016, 0.012), "mat": &"staal"},

	# ── Afvalbak bij de deur ──
	{"vorm": "cyl", "pos": Vector3(-3.70, 0.21, 2.98), "size": Vector3(0.17, 0.42, 0.17), "mat": &"kunststof_grijs", "col": true},
	{"vorm": "torus", "pos": Vector3(-3.70, 0.425, 2.98), "size": Vector3(0.155, 0.185, 0.155), "mat": &"kunststof_zwart"},

	# ── Tactiekbord (noordwand) met alu-lijst en stiftgoot ──
	{"pos": Vector3(-6.20, 1.90, -1.268), "size": Vector3(1.16, 0.81, 0.03), "mat": &"alu"},
	{"pos": Vector3(-6.20, 1.485, -1.26), "size": Vector3(0.50, 0.025, 0.05), "mat": &"alu"},
	{"vorm": "cyl", "pos": Vector3(-6.32, 1.508, -1.24), "size": Vector3(0.008, 0.12, 0.008), "mat": &"kunststof_zwart", "rot": Vector3(0.0, 0.0, 90.0)},

	# ── Achtergelaten spullen: schaars, en elk met een eigenaar ──
	# Vergeten sok onder de westbank.
	{"pos": Vector3(-6.55, 0.028, 1.62), "size": Vector3(0.13, 0.055, 0.09), "mat": &"sok_wit", "rot": Vector3(0.0, 34.0, 0.0)},
	{"pos": Vector3(-6.60, 0.022, 1.68), "size": Vector3(0.07, 0.04, 0.06), "mat": &"sok_wit", "rot": Vector3(0.0, 12.0, 0.0)},
	# Handdoek over de oostbank.
	{"pos": Vector3(-2.63, 0.468, 1.05), "size": Vector3(0.35, 0.028, 0.46), "mat": &"handdoek"},
	{"pos": Vector3(-2.795, 0.33, 1.05), "size": Vector3(0.03, 0.30, 0.44), "mat": &"handdoek"},
	# Twee flesjes: één omgevallen op de vloer, één op de bank.
	{"vorm": "cyl", "pos": Vector3(-5.60, 0.034, 0.60), "size": Vector3(0.034, 0.20, 0.034), "mat": &"kunststof_blauw", "rot": Vector3(90.0, 18.0, 0.0)},
	{"vorm": "cyl", "pos": Vector3(-5.60, 0.034, 0.49), "size": Vector3(0.021, 0.03, 0.021), "mat": &"kunststof_wit", "rot": Vector3(90.0, 18.0, 0.0)},
	{"vorm": "cyl", "pos": Vector3(-2.63, 0.555, -0.20), "size": Vector3(0.034, 0.21, 0.034), "mat": &"kunststof_wit"},
	# Scheenbeschermer onder de oostbank.
	{"pos": Vector3(-2.68, 0.012, -0.50), "size": Vector3(0.10, 0.02, 0.15), "mat": &"scheenbeschermer", "rot": Vector3(0.0, 18.0, 6.0)},
	# Sporttas onder de westbank — bewust een neutrale, generieke tas:
	# de vergeten sporttas uit D-028 is een fase-D-gameplayprop.
	{"pos": Vector3(-6.72, 0.14, 0.10), "size": Vector3(0.30, 0.28, 0.60), "mat": &"tas_grijs", "rot": Vector3(0.0, 6.0, 0.0)},
	{"pos": Vector3(-6.72, 0.29, 0.10), "size": Vector3(0.26, 0.06, 0.52), "mat": &"tas_grijs", "rot": Vector3(0.0, 6.0, 0.0)},
	{"pos": Vector3(-6.70, 0.325, 0.10), "size": Vector3(0.05, 0.03, 0.30), "mat": &"staal_donker", "rot": Vector3(0.0, 6.0, 0.0)},

	# ══════════════ GANG — het horrorbeeld ══════════════
	# Plinten langs beide wanden, netjes onderbroken bij elke doorgang.
	{"pos": Vector3(-14.21, 0.05, 3.39), "size": Vector3(1.58, 0.1, 0.06), "mat": &"plint"},
	{"pos": Vector3(-11.11, 0.05, 3.39), "size": Vector3(2.58, 0.1, 0.06), "mat": &"plint"},
	{"pos": Vector3(-6.61, 0.05, 3.39), "size": Vector3(4.38, 0.1, 0.06), "mat": &"plint"},
	{"pos": Vector3(-2.80, 0.05, 3.39), "size": Vector3(1.20, 0.1, 0.06), "mat": &"plint"},
	{"pos": Vector3(-11.80, 0.05, 5.21), "size": Vector3(6.40, 0.1, 0.06), "mat": &"plint"},
	{"pos": Vector3(-6.51, 0.05, 5.21), "size": Vector3(1.78, 0.1, 0.06), "mat": &"plint"},
	{"pos": Vector3(-3.40, 0.05, 5.21), "size": Vector3(2.40, 0.1, 0.06), "mat": &"plint"},

	# Leidingen onder het plafond, bewust alleen langs de noordzijde:
	# asymmetrie geeft de gang richting (brief §3).
	{"vorm": "cyl", "pos": Vector3(-8.60, 2.30, 3.62), "size": Vector3(0.026, 12.6, 0.026), "mat": &"staal", "rot": Vector3(0.0, 0.0, 90.0)},
	{"vorm": "cyl", "pos": Vector3(-8.60, 2.255, 3.70), "size": Vector3(0.018, 12.6, 0.018), "mat": &"staal_donker", "rot": Vector3(0.0, 0.0, 90.0)},
	{"pos": Vector3(-14.30, 2.33, 3.66), "size": Vector3(0.05, 0.10, 0.16), "mat": &"staal_donker"},
	{"pos": Vector3(-12.20, 2.33, 3.66), "size": Vector3(0.05, 0.10, 0.16), "mat": &"staal_donker"},
	{"pos": Vector3(-10.10, 2.33, 3.66), "size": Vector3(0.05, 0.10, 0.16), "mat": &"staal_donker"},
	{"pos": Vector3(-8.00, 2.33, 3.66), "size": Vector3(0.05, 0.10, 0.16), "mat": &"staal_donker"},
	{"pos": Vector3(-5.90, 2.33, 3.66), "size": Vector3(0.05, 0.10, 0.16), "mat": &"staal_donker"},
	{"pos": Vector3(-3.80, 2.33, 3.66), "size": Vector3(0.05, 0.10, 0.16), "mat": &"staal_donker"},

	# Deurmatten voor de kleedkamers.
	{"pos": Vector3(-3.91, 0.007, 3.80), "size": Vector3(0.90, 0.014, 0.55), "mat": &"rubber_mat"},
	{"pos": Vector3(-9.31, 0.007, 3.80), "size": Vector3(0.90, 0.014, 0.55), "mat": &"rubber_mat", "rot": Vector3(0.0, 2.0, 0.0)},

	# Lage wachtbank tussen kleedkamer 3 en 4 (artplan §5.5).
	{"pos": Vector3(-7.60, 0.43, 3.56), "size": Vector3(1.40, 0.035, 0.075), "mat": &"bank_lat"},
	{"pos": Vector3(-7.60, 0.43, 3.65), "size": Vector3(1.40, 0.035, 0.075), "mat": &"bank_lat"},
	{"pos": Vector3(-7.60, 0.43, 3.74), "size": Vector3(1.40, 0.035, 0.075), "mat": &"bank_lat"},
	{"pos": Vector3(-8.15, 0.205, 3.58), "size": Vector3(0.045, 0.41, 0.045), "mat": &"bank_frame"},
	{"pos": Vector3(-8.15, 0.205, 3.72), "size": Vector3(0.045, 0.41, 0.045), "mat": &"bank_frame"},
	{"pos": Vector3(-8.15, 0.39, 3.65), "size": Vector3(0.045, 0.04, 0.22), "mat": &"bank_frame"},
	{"pos": Vector3(-7.05, 0.205, 3.58), "size": Vector3(0.045, 0.41, 0.045), "mat": &"bank_frame"},
	{"pos": Vector3(-7.05, 0.205, 3.72), "size": Vector3(0.045, 0.41, 0.045), "mat": &"bank_frame"},
	{"pos": Vector3(-7.05, 0.39, 3.65), "size": Vector3(0.045, 0.04, 0.22), "mat": &"bank_frame"},
	{"pos": Vector3(-7.60, 0.24, 3.65), "size": Vector3(1.40, 0.48, 0.30), "col": true, "verborgen": true},

	# Twee gestapelde kantinestoelen tegen de zuidwand — de natuurlijke
	# obstructie halverwege (brief §3), net iets scheef weggezet.
	{"pos": Vector3(-10.60, 0.44, 4.92), "size": Vector3(0.42, 0.04, 0.42), "mat": &"kunststof_grijs", "rot": Vector3(0.0, -14.0, 0.0)},
	{"pos": Vector3(-10.60, 0.68, 5.10), "size": Vector3(0.42, 0.44, 0.04), "mat": &"kunststof_grijs", "rot": Vector3(-8.0, -14.0, 0.0)},
	{"pos": Vector3(-10.78, 0.21, 4.75), "size": Vector3(0.03, 0.42, 0.03), "mat": &"staal_donker", "rot": Vector3(0.0, -14.0, 0.0)},
	{"pos": Vector3(-10.42, 0.21, 4.75), "size": Vector3(0.03, 0.42, 0.03), "mat": &"staal_donker", "rot": Vector3(0.0, -14.0, 0.0)},
	{"pos": Vector3(-10.78, 0.21, 5.08), "size": Vector3(0.03, 0.42, 0.03), "mat": &"staal_donker", "rot": Vector3(0.0, -14.0, 0.0)},
	{"pos": Vector3(-10.42, 0.21, 5.08), "size": Vector3(0.03, 0.42, 0.03), "mat": &"staal_donker", "rot": Vector3(0.0, -14.0, 0.0)},
	{"pos": Vector3(-10.56, 0.53, 4.94), "size": Vector3(0.42, 0.04, 0.42), "mat": &"kunststof_grijs", "rot": Vector3(0.0, -6.0, 0.0)},
	{"pos": Vector3(-10.56, 0.77, 5.12), "size": Vector3(0.42, 0.44, 0.04), "mat": &"kunststof_grijs", "rot": Vector3(-8.0, -6.0, 0.0)},
	{"pos": Vector3(-10.58, 0.45, 4.95), "size": Vector3(0.46, 0.90, 0.46), "col": true, "verborgen": true},

	# Doos met doelnetten aan het donkere westeinde.
	{"pos": Vector3(-14.20, 0.20, 4.85), "size": Vector3(0.55, 0.40, 0.45), "mat": &"karton", "col": true, "rot": Vector3(0.0, 7.0, 0.0)},
	{"pos": Vector3(-14.20, 0.43, 4.85), "size": Vector3(0.50, 0.08, 0.40), "mat": &"staal_donker", "rot": Vector3(0.0, 7.0, 0.0)},

	# Brandblusser (vervangt het F1-volume): fles, kop, beugel.
	{"vorm": "cyl", "pos": Vector3(-6.10, 0.75, 5.28), "size": Vector3(0.075, 0.50, 0.075), "mat": &"rood_blusser"},
	{"vorm": "cyl", "pos": Vector3(-6.10, 1.03, 5.28), "size": Vector3(0.028, 0.09, 0.028), "mat": &"staal_donker"},
	{"pos": Vector3(-6.10, 1.09, 5.26), "size": Vector3(0.09, 0.03, 0.10), "mat": &"staal_donker"},
	{"pos": Vector3(-6.10, 0.86, 5.34), "size": Vector3(0.11, 0.14, 0.05), "mat": &"staal_donker"},

	# Schoonmaaknis: emmer, mop en een fles allesreiniger op de plank.
	{"vorm": "cyl", "pos": Vector3(-8.35, 0.17, 5.78), "size": Vector3(0.16, 0.34, 0.16), "mat": &"kunststof_grijs", "col": true},
	{"vorm": "torus", "pos": Vector3(-8.35, 0.34, 5.78), "size": Vector3(0.145, 0.17, 0.145), "mat": &"kunststof_zwart"},
	{"vorm": "cyl", "pos": Vector3(-7.72, 0.70, 5.92), "size": Vector3(0.018, 1.34, 0.018), "mat": &"kapstok_hout", "rot": Vector3(7.0, 0.0, 4.0)},
	{"pos": Vector3(-7.78, 0.09, 5.83), "size": Vector3(0.11, 0.17, 0.20), "mat": &"handdoek", "rot": Vector3(0.0, 8.0, 0.0)},
	{"vorm": "cyl", "pos": Vector3(-8.20, 1.63, 5.80), "size": Vector3(0.045, 0.24, 0.045), "mat": &"kunststof_blauw"},
]

## Vlakke, getextureerde panelen (QuadMesh): wandobjecten waarvan de tekst
## of foto het werk doet. "rot" = graden; een quad kijkt standaard naar +z.
const PANELEN: Array[Dictionary] = [
	# Kleedkamer 3: tactiekbord, poster en het formulier op de vloer.
	{"tex": "f2/tactiekbord", "pos": Vector3(-6.20, 1.90, -1.252), "size": Vector2(1.10, 0.75)},
	{"tex": "f2/poster_normen", "pos": Vector3(-5.20, 1.85, 3.178), "size": Vector2(0.42, 0.59), "rot": Vector3(0.0, 180.0, 1.5)},
	{"tex": "f2/formulier", "pos": Vector3(-4.15, 0.007, 2.60), "size": Vector2(0.15, 0.21), "rot": Vector3(-90.0, 0.0, 14.0)},
	# Gang: elftalfoto's door de jaren heen — twee in het licht bij de
	# toiletten, twee in het donkere westdeel (die vind je pas met de lamp).
	{"tex": "f2/elftalfoto_1", "pos": Vector3(-6.95, 1.74, 5.168), "size": Vector2(0.44, 0.32), "rot": Vector3(0.0, 180.0, 0.0)},
	{"tex": "f2/elftalfoto_2", "pos": Vector3(-6.25, 1.72, 5.168), "size": Vector2(0.44, 0.32), "rot": Vector3(0.0, 180.0, -1.2)},
	{"tex": "f2/elftalfoto_3", "pos": Vector3(-10.20, 1.75, 5.168), "size": Vector2(0.50, 0.37), "rot": Vector3(0.0, 180.0, 0.0)},
	{"tex": "f2/elftalfoto_1", "pos": Vector3(-11.40, 1.71, 5.168), "size": Vector2(0.44, 0.32), "rot": Vector3(0.0, 180.0, 1.8)},
	# Keuringskaartje naast de brandblusser.
	{"tex": "f2/keuringskaart", "pos": Vector3(-5.82, 1.32, 5.184), "size": Vector2(0.10, 0.14), "rot": Vector3(0.0, 180.0, 0.0)},
]

## Lijstjes achter de gangfoto's (aparte tabel: één regel per foto,
## zodat de fotomaat en de lijst nooit uit elkaar lopen).
const FOTO_LIJSTEN: Array[Dictionary] = [
	{"pos": Vector3(-6.95, 1.74, 5.186), "size": Vector3(0.48, 0.36, 0.014)},
	{"pos": Vector3(-6.25, 1.72, 5.186), "size": Vector3(0.48, 0.36, 0.014)},
	{"pos": Vector3(-10.20, 1.75, 5.186), "size": Vector3(0.54, 0.41, 0.014)},
	{"pos": Vector3(-11.40, 1.71, 5.186), "size": Vector3(0.48, 0.36, 0.014)},
]

## Decals: material breakup. "vlak" bepaalt de projectierichting
## ("vloer"/"plafond"/"x+"/"x-"/"z+"/"z-" = de as waarlangs de vlek het
## oppervlak in projecteert; hij staat dus altijd aan de kámerzijde), "size" is
## de projectiebox in meters, "alpha" de sterkte (0..1) en "hoek" een
## draaiing binnen het vlak. Wereldregel: gebruikssporen, geen verval —
## de sterktes blijven bewust laag (artplan §2.1).
const DECALS: Array[Dictionary] = [
	# ── Kleedkamer 3 ──
	{"tex": "looplijn", "vlak": "vloer", "pos": Vector3(-4.20, 0.02, 1.60), "size": Vector3(2.6, 0.6, 3.6), "alpha": 0.85, "hoek": 12.0},
	{"tex": "looplijn", "vlak": "vloer", "pos": Vector3(-5.60, 0.02, 0.20), "size": Vector3(2.2, 0.6, 3.0), "alpha": 0.7, "hoek": 74.0},
	{"tex": "schoenstreep", "vlak": "vloer", "pos": Vector3(-6.30, 0.02, 1.20), "size": Vector3(1.6, 0.5, 1.6), "alpha": 0.5},
	{"tex": "schoenstreep", "vlak": "vloer", "pos": Vector3(-3.10, 0.02, 0.90), "size": Vector3(1.2, 0.5, 1.6), "alpha": 0.45, "hoek": 40.0},
	{"tex": "vuil_rand", "vlak": "x+", "pos": Vector3(-2.44, 0.22, 0.90), "size": Vector3(4.4, 0.9, 0.5), "alpha": 0.9},
	{"tex": "vuil_rand", "vlak": "x-", "pos": Vector3(-6.96, 0.22, 0.90), "size": Vector3(4.4, 0.9, 0.5), "alpha": 0.85},
	{"tex": "vuil_rand", "vlak": "z+", "pos": Vector3(-5.60, 0.22, 3.16), "size": Vector3(2.6, 0.9, 0.5), "alpha": 0.6},
	{"tex": "vuil_hoek", "vlak": "vloer", "pos": Vector3(-6.85, 0.02, -1.15), "size": Vector3(1.0, 0.5, 1.0), "alpha": 0.65},
	{"tex": "vuil_hoek", "vlak": "vloer", "pos": Vector3(-2.55, 0.02, 3.05), "size": Vector3(1.0, 0.5, 1.0), "alpha": 0.55, "hoek": 180.0},
	{"tex": "vocht", "vlak": "vloer", "pos": Vector3(-4.00, 0.02, -1.05), "size": Vector3(1.5, 0.5, 0.9), "alpha": 0.6},
	{"tex": "kalk", "vlak": "z-", "pos": Vector3(-3.20, 1.10, -1.27), "size": Vector3(0.7, 2.0, 0.4), "alpha": 0.45},
	{"tex": "verfschade", "vlak": "x+", "pos": Vector3(-2.44, 1.95, -0.30), "size": Vector3(1.2, 0.8, 0.4), "alpha": 0.6},
	{"tex": "verfschade", "vlak": "z+", "pos": Vector3(-6.20, 2.05, 3.16), "size": Vector3(1.0, 0.7, 0.4), "alpha": 0.5},
	{"tex": "krassen", "vlak": "x-", "pos": Vector3(-3.11, 1.10, 2.60), "size": Vector3(0.9, 1.4, 0.35), "alpha": 0.35},
	{"tex": "veeg", "vlak": "z+", "pos": Vector3(-4.30, 1.05, 3.16), "size": Vector3(0.8, 0.6, 0.4), "alpha": 0.5},
	{"tex": "veeg", "vlak": "x-", "pos": Vector3(-6.96, 1.30, 1.10), "size": Vector3(0.9, 0.7, 0.4), "alpha": 0.4},

	# ── Gang: de looplijn is hier het belangrijkste breukvlak ──
	{"tex": "looplijn", "vlak": "vloer", "pos": Vector3(-4.50, 0.02, 4.30), "size": Vector3(5.0, 0.6, 1.7), "alpha": 0.8, "hoek": 90.0},
	{"tex": "looplijn", "vlak": "vloer", "pos": Vector3(-8.60, 0.02, 4.30), "size": Vector3(5.0, 0.6, 1.7), "alpha": 0.85, "hoek": 90.0},
	{"tex": "looplijn", "vlak": "vloer", "pos": Vector3(-12.60, 0.02, 4.30), "size": Vector3(5.0, 0.6, 1.7), "alpha": 0.75, "hoek": 90.0},
	{"tex": "vuil_rand", "vlak": "z-", "pos": Vector3(-5.00, 0.22, 3.44), "size": Vector3(5.5, 0.9, 0.5), "alpha": 0.9},
	{"tex": "vuil_rand", "vlak": "z-", "pos": Vector3(-11.00, 0.22, 3.44), "size": Vector3(5.5, 0.9, 0.5), "alpha": 0.85},
	{"tex": "vuil_rand", "vlak": "z+", "pos": Vector3(-4.00, 0.22, 5.16), "size": Vector3(4.0, 0.9, 0.5), "alpha": 0.85},
	{"tex": "vuil_rand", "vlak": "z+", "pos": Vector3(-11.50, 0.22, 5.16), "size": Vector3(6.0, 0.9, 0.5), "alpha": 0.9},
	{"tex": "schoenstreep", "vlak": "vloer", "pos": Vector3(-3.90, 0.02, 3.95), "size": Vector3(1.6, 0.5, 1.2), "alpha": 0.5},
	{"tex": "schoenstreep", "vlak": "vloer", "pos": Vector3(-9.40, 0.02, 3.95), "size": Vector3(1.6, 0.5, 1.2), "alpha": 0.4, "hoek": 25.0},
	{"tex": "vocht", "vlak": "vloer", "pos": Vector3(-7.90, 0.02, 5.05), "size": Vector3(1.6, 0.5, 1.1), "alpha": 0.5},
	{"tex": "vocht", "vlak": "z+", "pos": Vector3(-13.60, 1.30, 5.16), "size": Vector3(1.2, 1.8, 0.4), "alpha": 0.4},
	{"tex": "veeg", "vlak": "z-", "pos": Vector3(-3.55, 1.05, 3.44), "size": Vector3(0.7, 0.6, 0.4), "alpha": 0.55},
	{"tex": "veeg", "vlak": "z-", "pos": Vector3(-8.95, 1.05, 3.44), "size": Vector3(0.7, 0.6, 0.4), "alpha": 0.5},
	{"tex": "verfschade", "vlak": "z+", "pos": Vector3(-9.60, 1.60, 5.16), "size": Vector3(1.4, 1.0, 0.4), "alpha": 0.55},
	{"tex": "verfschade", "vlak": "z-", "pos": Vector3(-12.00, 1.30, 3.44), "size": Vector3(1.2, 0.9, 0.4), "alpha": 0.5},
	{"tex": "krassen", "vlak": "z-", "pos": Vector3(-6.60, 0.90, 3.44), "size": Vector3(1.6, 1.2, 0.35), "alpha": 0.3},
	{"tex": "vuil_hoek", "vlak": "vloer", "pos": Vector3(-14.80, 0.02, 3.60), "size": Vector3(1.2, 0.5, 1.2), "alpha": 0.6, "hoek": 270.0},
	{"tex": "vuil_hoek", "vlak": "vloer", "pos": Vector3(-8.00, 0.02, 5.95), "size": Vector3(1.2, 0.5, 1.2), "alpha": 0.55},
]

var _materialen := {}
var _meshes := {}
var _wortel: Node3D


func _ready() -> void:
	_wortel = Node3D.new()
	_wortel.name = "F2Detail"
	add_child(_wortel)
	for solid in SOLIDS:
		_bouw_solid(solid)
	for lijst in FOTO_LIJSTEN:
		_bouw_solid({"pos": lijst["pos"], "size": lijst["size"], "mat": &"kapstok_hout"})
	for paneel in PANELEN:
		_bouw_paneel(paneel)
	for decal in DECALS:
		_bouw_decal(decal)
	_bouw_nooduitgang_gloed()
	Log.info("F2-detaillaag: %d onderdelen" % _wortel.get_child_count())


## Eén onderdeel = StaticBody3D met geschaalde mesh en (optioneel) een
## eigen BoxShape. Decoratief is de norm: alleen "col": true krijgt
## collision, zodat de speler nergens onzichtbaar blijft haken.
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
		shape.shape = box
		body.add_child(shape)
	_wortel.add_child(body)
	body.position = solid["pos"]
	body.rotation_degrees = solid.get("rot", Vector3.ZERO)


## Meshes worden gedeeld waar dat kan: één unit-box voor alle blokken,
## en per maat één cilinder/bol/torus (identieke maten hergebruiken
## dezelfde resource — dat scheelt geheugen én statewissels).
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
		if spec.has("tex"):
			var tex: String = spec["tex"]
			var basis := "res://assets/textures/%s/%s" % [tex, tex]
			# "vlak_gelakt": alleen reliëf en glans van de textuur, geen
			# kleur — zo wordt gelakt hout écht clubblauw in plaats van
			# een blauwe zweem over bruine planken.
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


## Getextureerd vlak (poster, foto, bord). Eén quad = één vlak met
## volledige UV; een box zou de afbeelding over zijn atlas versnipperen.
func _bouw_paneel(paneel: Dictionary) -> void:
	var mesh := MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = paneel["size"]
	mesh.mesh = quad
	var material := StandardMaterial3D.new()
	material.albedo_texture = load(
		"res://assets/textures/%s.png" % paneel["tex"])
	material.roughness = 0.7
	mesh.material_override = material
	_wortel.add_child(mesh)
	mesh.position = paneel["pos"]
	mesh.rotation_degrees = paneel.get("rot", Vector3.ZERO)


## Decal = geprojecteerde vlek. Een Decal kijkt langs zijn eigen -Y, dus
## "vlak" is niets anders dan de rotatie die die as de goede kant op
## draait. De vlek pakt alles binnen zijn box mee — ook de deuren, en dat
## is precies de bedoeling: vuil stopt niet bij een objectgrens.
func _bouw_decal(spec: Dictionary) -> void:
	var decal := Decal.new()
	decal.texture_albedo = load(
		"res://assets/textures/decals/%s.png" % spec["tex"])
	decal.size = spec["size"]
	decal.modulate = Color(1.0, 1.0, 1.0, spec.get("alpha", 0.6))
	decal.albedo_mix = 1.0
	decal.upper_fade = 0.6
	decal.lower_fade = 0.35
	decal.normal_fade = 0.25
	_wortel.add_child(decal)
	decal.position = spec["pos"]
	var hoek: float = spec.get("hoek", 0.0)
	match spec.get("vlak", "vloer"):
		"plafond":
			decal.rotation_degrees = Vector3(180.0, hoek, 0.0)
		"z+":  # projecteert naar +z
			decal.rotation_degrees = Vector3(-90.0, 0.0, hoek)
		"z-":  # projecteert naar -z
			decal.rotation_degrees = Vector3(90.0, 0.0, hoek)
		"x+":  # projecteert naar +x
			decal.rotation_degrees = Vector3(0.0, 0.0, 90.0 + hoek)
		"x-":  # projecteert naar -x
			decal.rotation_degrees = Vector3(0.0, 0.0, -90.0 + hoek)
		_:
			decal.rotation_degrees = Vector3(0.0, hoek, 0.0)


## De enige lamp die deze laag toevoegt: de groene gloed van het
## nooduitgangbord aan het donkere westeinde. Zonder schaduw — het
## schaduwbudget (D-026) blijft van het level en de zaklamp.
func _bouw_nooduitgang_gloed() -> void:
	var licht := OmniLight3D.new()
	licht.name = "NooduitgangGloed"
	licht.light_color = Color(0.55, 0.88, 0.62)
	licht.light_energy = 0.22
	licht.omni_range = 3.0
	licht.omni_attenuation = 1.6
	licht.shadow_enabled = false
	_wortel.add_child(licht)
	licht.position = Vector3(-14.82, 2.25, 4.31)
