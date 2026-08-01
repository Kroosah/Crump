extends SceneTree
## Geometrie- en materiaalcontrole over het volledige clubgebouw
## (VS-fase G, integriteitspass). Puur gereedschap: het bouwt het level
## precies zoals het spel dat doet en trekt daarna élke zichtbare mesh na
## op de foutklassen die een kitbash-uit-datatabellen typisch oplevert.
##
## Waarom een tool en geen handmatige inspectie: de fouten die de GD zag
## (zwevende strips, uitstekende meshes, z-fighting) zijn stuk voor stuk
## rekenkundig te vinden, en alleen zo weet je zeker dat je de laatste
## niet mist. Wat de tool níét kan beoordelen is smaak — daar zijn de
## renders voor.
##
## Gebruik:  godot --headless --path . -s tools/controleer_geometrie.gd
## Exitcode 0 = geen bevindingen, 1 = bevindingen (zie de lijst).
##
## Toleranties (meters):
## - KIER: twee vlakken die elkaar hóren te raken maar 0,5–12 mm uit
##   elkaar staan — dat is de klassieke "zwevende strip".
## - VLAK: twee zichtbare vlakken die binnen 1,5 mm samenvallen —
##   z-fighting, ook al ziet het er in de editor rustig uit.
## - DOORSNIJDING: een decoratief object dat meer dan 8 mm in een ander
##   volume steekt (of erdoorheen komt).

const LEVEL := "res://game/levels/clubgebouw/clubgebouw.tscn"

const KIER_MIN := 0.0005
const KIER_MAX := 0.012
const VLAK_TOL := 0.0015
const DOORSNIJ_TOL := 0.008
## Onder deze overlap (fractie van de kleinste maat) zijn twee volumes
## buren die elkaar net raken, geen echt geval.
const OVERLAP_MIN := 0.25

var _meshes: Array = []
var _bevindingen: Array = []


func _init() -> void:
	var packed: PackedScene = load(LEVEL)
	if packed == null:
		push_error("Controle: levelscène niet gevonden")
		quit(1)
		return
	var level: Node = packed.instantiate()
	root.add_child.call_deferred(level)
	_run.call_deferred(level)


func _run(level: Node) -> void:
	await process_frame
	await process_frame
	_verzamel(level)
	print("Controle: %d zichtbare meshes verzameld" % _meshes.size())
	_controleer_paren()
	_controleer_losse_objecten(level)
	_controleer_materialen()
	_rapporteer()
	quit(1 if not _bevindingen.is_empty() else 0)


## Elke zichtbare mesh met zijn wereld-AABB, plus een leesbare herkomst.
func _verzamel(wortel: Node) -> void:
	for node in wortel.find_children("", "MeshInstance3D", true, false):
		var mesh := node as MeshInstance3D
		if not mesh.is_visible_in_tree() or mesh.mesh == null:
			continue
		var aabb: AABB = mesh.global_transform * mesh.get_aabb()
		# Een vlak paneel (bord, poster, foto) is bedoeld plat: dat is
		# geen maatfout. Wel geven we het een papieren dikte, anders kan
		# geen enkele buurcontrole er iets mee.
		var plat := false
		for as_i in 3:
			if aabb.size[as_i] < 0.0005:
				plat = true
				aabb.position[as_i] -= 0.0005
				aabb.size[as_i] = 0.001
		if aabb.size.x <= 0.0 or aabb.size.y <= 0.0 or aabb.size.z <= 0.0:
			_meld("MAATFOUT", _pad(mesh), "mesh heeft een nulmaat: %s"
				% str(aabb.size))
			continue
		_meshes.append({
			"naam": _pad(mesh),
			"waar": aabb.get_center(),
			"aabb": aabb,
			"plat": plat,
			# Dun = paneel, strip, lijst of bordje. Twee dikke volumes die
			# elkaar raken of overlappen is metselwerk (een muur die in een
			# muur steekt is normaal); pas als er een dun element bij zit
			# wordt overlap een zichtbaar artefact.
			"dun": aabb.size.min_axis_index() >= 0 and aabb.size[aabb.size.min_axis_index()] < 0.05,
			# Let op: de greybox schaalt één unit-box, dus de basis is
			# geschaald maar niet gedraaid. Alleen de oriëntatie telt —
			# orthonormaliseren haalt de schaal eruit.
			"gedraaid": not mesh.global_basis.orthonormalized().is_equal_approx(Basis()),
			"wortel": _prop_wortel(mesh),
			"node": mesh,
		})


## De scène waar een mesh uit komt. Props (deur, TL-armatuur) zijn met
## de hand gemodelleerd: dáár is overlap tussen onderdelen ontwerp, geen
## fout. Alles wat uit de datatabellen wordt gegenereerd controleren we
## wél volledig — dat is precies waar bouwfouten ontstaan.
func _prop_wortel(node: Node) -> Node:
	var huidig := node
	while huidig != null:
		if huidig.scene_file_path.contains("/game/props/"):
			return huidig
		huidig = huidig.get_parent()
	return null


func _pad(node: Node) -> String:
	var ouder := node.get_parent()
	var tak := "?" if ouder == null else str(ouder.name)
	return "%s/%s" % [tak, node.name]


## Paarsgewijze controle. O(n²) op ~500 meshes is verwaarloosbaar en
## veel betrouwbaarder dan slim willen zijn.
func _controleer_paren() -> void:
	var aantal := _meshes.size()
	for i in aantal:
		var a: Dictionary = _meshes[i]
		for j in range(i + 1, aantal):
			var b: Dictionary = _meshes[j]
			if a["wortel"] != null and a["wortel"] == b["wortel"]:
				continue
			if a["gedraaid"] or b["gedraaid"]:
				# Een gedraaide mesh heeft een ruimere AABB dan zijn echte
				# vorm; die zou alleen valse meldingen opleveren.
				continue
			_vergelijk(a, b)


func _vergelijk(a: Dictionary, b: Dictionary) -> void:
	var aa: AABB = a["aabb"]
	var bb: AABB = b["aabb"]
	if not aa.grow(KIER_MAX + 0.001).intersects(bb):
		return
	var overlap := [0.0, 0.0, 0.0]
	var afstand := [0.0, 0.0, 0.0]
	var gelijk_min := [false, false, false]
	var gelijk_max := [false, false, false]
	for as_i in 3:
		var a_min: float = aa.position[as_i]
		var a_max: float = a_min + aa.size[as_i]
		var b_min: float = bb.position[as_i]
		var b_max: float = b_min + bb.size[as_i]
		overlap[as_i] = minf(a_max, b_max) - maxf(a_min, b_min)
		afstand[as_i] = maxf(a_min - b_max, b_min - a_max)
		gelijk_min[as_i] = absf(a_min - b_min) < VLAK_TOL
		gelijk_max[as_i] = absf(a_max - b_max) < VLAK_TOL

	# 1. KIER — twee vlakken die elkaar horen te raken maar millimeters
	#    uit elkaar staan: de klassieke zwevende strip.
	for as_i in 3:
		if not _vlakken_elkaar(aa, bb, overlap, as_i):
			continue
		var d: float = afstand[as_i]
		if d > KIER_MIN and d < KIER_MAX:
			_meld("KIER", _plek(a, b),
				"%.1f mm lucht langs %s" % [d * 1000.0, _as(as_i)])
			return

	# Voor de overige klassen moet er échte volume-overlap zijn. De
	# ondergrens is bewust een halve millimeter en niet nul: vloeren,
	# wanden en daken sluiten op maten als 2,9 m op elkaar aan, en die
	# raken elkaar in drijvende komma net wél of net niet.
	if overlap[0] < 0.0005 or overlap[1] < 0.0005 or overlap[2] < 0.0005:
		return

	# 2. VLAK — z-fighting: twee oppervlakken die dezelfde kant op kijken
	#    en op dezelfde diepte liggen. Een paneel dat tégen een muur ligt
	#    is prima (die vlakken kijken van elkaar af); twee vlakken die
	#    samenvallen én dezelfde kant op staan flikkeren gegarandeerd.
	for as_i in 3:
		if not _vlakken_elkaar(aa, bb, overlap, as_i):
			continue
		# Twee dikke volumes die een vlak delen is een bouwnaad (een muur
		# die in een vloer steekt); pas met een dun element erbij — een
		# paneel, strip of lijst — wordt het zichtbaar geflikker.
		# Vlakken die samenvallen op vloerniveau (y = 0) zitten onder de
		# vloerplaat en zijn per definitie onzichtbaar.
		var op_vloer: bool = as_i == 1 and gelijk_min[1] \
			and absf(aa.position.y) < VLAK_TOL
		if (a["dun"] or b["dun"]) and not op_vloer \
				and (gelijk_min[as_i] or gelijk_max[as_i]):
			_meld("VLAK", _plek(a, b),
				"vlakken vallen samen langs %s (z-fighting)" % _as(as_i))
			return

	# 3+4. Alleen dunne elementen (panelen, strips, lijsten) kunnen
	#      zichtbaar verkeerd in een volume zitten; twee dikke volumes die
	#      in elkaar steken is gewoon metselwerk.
	var dun: Dictionary = a if a["dun"] else (b if b["dun"] else {})
	if dun.is_empty():
		return
	var dik: Dictionary = b if dun == a else a
	var d_aabb: AABB = dun["aabb"]
	var k_aabb: AABB = dik["aabb"]
	var as_dun: int = d_aabb.size.min_axis_index()
	var d_min: float = d_aabb.position[as_dun]
	var d_max: float = d_min + d_aabb.size[as_dun]
	var k_min: float = k_aabb.position[as_dun]
	var k_max: float = k_min + k_aabb.size[as_dun]
	if d_min < k_min - VLAK_TOL and d_max > k_max + VLAK_TOL:
		_meld("DOORPRIK", _plek(dun, dik),
			"paneel steekt aan beide kanten uit een volume (%s)"
			% _as(as_dun))
		return
	# Alleen écht onzichtbaar werk melden: een paneel dat volledig in een
	# ander volume ligt. Een afwerkingslaag die er 2 mm uitsteekt hoort
	# juist zo — dat is stucwerk, geen fout.
	if d_min > k_min - VLAK_TOL and d_max < k_max + VLAK_TOL:
		_meld("VERZONKEN", _plek(dun, dik),
			"paneel ligt volledig in een ander volume (%s)" % _as(as_dun))


## Overlappen twee volumes langs de twee ándere assen genoeg om van een
## gedeeld vlak te kunnen spreken?
func _vlakken_elkaar(aa: AABB, bb: AABB, overlap: Array, as_i: int) -> bool:
	for k in 3:
		if k == as_i:
			continue
		var kleinste: float = minf(aa.size[k], bb.size[k])
		if overlap[k] < maxf(kleinste * OVERLAP_MIN, 0.02):
			return false
	return true


## Waar staat het? Zonder coördinaat is een bevinding niet op te lossen.
func _plek(a: Dictionary, b: Dictionary) -> String:
	return "%s  ↔  %s" % [_beschrijf(a), _beschrijf(b)]


## Compacte, herkenbare beschrijving: middelpunt en maat, zodat een
## bevinding direct terug te vinden is in de datatabellen.
func _beschrijf(item: Dictionary) -> String:
	var aabb: AABB = item["aabb"]
	var c: Vector3 = aabb.get_center()
	var s: Vector3 = aabb.size
	return "[%.3f %.3f %.3f | %.3f %.3f %.3f]" % [c.x, c.y, c.z, s.x, s.y, s.z]


func _bevat(buiten: AABB, binnen: AABB) -> bool:
	return buiten.encloses(binnen)


func _as(index: int) -> String:
	return ["x", "y", "z"][index]


## Losse controles die niets met buren te maken hebben.
func _controleer_losse_objecten(level: Node) -> void:
	for item in _meshes:
		var aabb: AABB = item["aabb"]
		if aabb.position.y < -0.25:
			_meld("ONDER DE VLOER", item["naam"] + str(item["waar"]),
				"onderkant op y = %.3f" % aabb.position.y)
		if aabb.size.length() > 60.0:
			_meld("MAATFOUT", item["naam"],
				"onwaarschijnlijk groot volume: %s" % str(aabb.size))
	# Colliders zonder mesh mogen bestaan (bewust verborgen), maar een
	# collider die niet om zijn eigen mesh past is een bouwfout.
	for body in level.find_children("", "StaticBody3D", true, false):
		var vormen := body.find_children("", "CollisionShape3D", false, false)
		var meshes := body.find_children("", "MeshInstance3D", false, false)
		if vormen.is_empty() or meshes.is_empty():
			continue
		var vorm := vormen[0] as CollisionShape3D
		var mesh := meshes[0] as MeshInstance3D
		if vorm.shape is BoxShape3D and mesh.mesh != null:
			var doos: Vector3 = (vorm.shape as BoxShape3D).size
			var m: Vector3 = mesh.mesh.get_aabb().size * mesh.scale
			for as_i in 3:
				if absf(doos[as_i] - m[as_i]) > 0.02:
					_meld("COLLISION", _pad(body),
						"collider %s past niet om de mesh %s"
						% [str(doos.snapped(Vector3.ONE * 0.001)),
							str(m.snapped(Vector3.ONE * 0.001))])
					break


## Materiaalcontrole: elk zichtbaar vlak hoort een echt materiaal te
## hebben, en transparantie hoort een keuze te zijn, geen ongeluk.
func _controleer_materialen() -> void:
	for item in _meshes:
		var mesh: MeshInstance3D = item["node"]
		var materiaal := mesh.material_override
		if materiaal == null:
			materiaal = mesh.get_active_material(0)
		if materiaal == null:
			_meld("MATERIAAL", item["naam"], "geen materiaal toegewezen")
			continue
		if materiaal is StandardMaterial3D:
			var std := materiaal as StandardMaterial3D
			if std.albedo_texture != null and not std.uv1_triplanar \
					and std.uv1_scale == Vector3.ONE and mesh.mesh is BoxMesh \
					and mesh.scale.length() > 3.0:
				_meld("UV", item["naam"],
					"grote box met textuur zonder triplanair of UV-schaal")
			if std.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED \
					and std.albedo_color.a > 0.99:
				_meld("MATERIAAL", item["naam"],
					"transparant materiaal zonder transparante kleur")


func _meld(soort: String, waar: String, wat: String) -> void:
	_bevindingen.append({"soort": soort, "waar": waar, "wat": wat})


func _rapporteer() -> void:
	if _bevindingen.is_empty():
		print("Controle: geen bevindingen.")
		return
	var per_soort := {}
	for b in _bevindingen:
		per_soort[b["soort"]] = per_soort.get(b["soort"], 0) + 1
	print("\nControle: %d bevinding(en)" % _bevindingen.size())
	for soort in per_soort:
		print("  · %s: %d" % [soort, per_soort[soort]])
	print("")
	for b in _bevindingen:
		print("[%s] %s — %s" % [b["soort"], b["waar"], b["wat"]])
