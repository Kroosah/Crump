extends SceneTree
## Inspectiesweep over het volledige bereikbare demo-gebied (VS-fase G,
## integriteitspass). Anders dan tools/maak_screenshots.gd — dat maakt de
## mooie beoordelingsbeelden — loopt dit gereedschap juist de plekken af
## waar bouwfouten zichtbaar worden: elke deuropening van beide kanten,
## elk raam van binnen en buiten, alle gevels, hoeken, dakrand en het
## terrein. Donkere ruimtes worden twee keer gefotografeerd: met en
## zonder zaklamp, want een lichtlek of een zwevende strip zie je in het
## donker soms júist wel.
##
## Alle deuren die in het spel open kunnen, staan hier open (puur de
## transform, geen prop-logica: dit gereedschap draait zonder autoloads).
## Deuren die op slot zijn blijven dicht — die kozijnen bekijken we van
## de kant waar de speler staat.
##
## Gebruik:
##   VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/lvp_icd.json \
##   xvfb-run -a godot --path . --rendering-driver vulkan \
##     -s tools/maak_inspectie.gd
## Output: user://inspectie/

const LEVEL := "res://game/levels/clubgebouw/clubgebouw.tscn"
const BREEDTE := 1280
const HOOGTE := 720

const OPEN_DEUREN := [
	"DeurHoofdentree", "DeurHalKantine", "DeurHalGang", "DeurKleedkamer3",
	"DeurKleedkamer4", "DeurOnderhoudsruimte", "DeurToiletten", "Nooddeur",
]

## [naam, camera, kijkdoel, zaklamp]
const SHOTS := [
	# ── Buitenzijde: gevels, dakrand, terrein ──
	["b01_entree_buiten", Vector3(0.0, 1.65, 10.6), Vector3(0.0, 1.7, 7.1), false],
	["b02_entree_luifel", Vector3(0.0, 1.65, 9.0), Vector3(0.0, 2.6, 7.6), false],
	["b03_zuidgevel_west", Vector3(-6.0, 1.70, 11.0), Vector3(-8.0, 1.6, 7.2), false],
	["b04_zuidgevel_oost", Vector3(6.0, 1.70, 11.0), Vector3(8.0, 1.6, 7.2), false],
	["b05_zuidgevel_raam", Vector3(1.45, 1.60, 9.2), Vector3(1.45, 1.55, 7.1), false],
	["b06_hoek_zuidwest", Vector3(-16.6, 1.70, 9.5), Vector3(-15.1, 1.8, 7.1), false],
	["b07_westgevel_nooddeur", Vector3(-16.7, 1.65, 4.3), Vector3(-15.1, 1.5, 4.3), false],
	["b08_westgevel_noord", Vector3(-16.7, 1.70, -2.0), Vector3(-15.1, 1.6, -4.0), false],
	["b09_noordgevel_kleedkamers", Vector3(-6.5, 1.70, -7.0), Vector3(-6.5, 1.7, -4.6), false],
	["b10_noordgevel_kiepraam", Vector3(-3.9, 1.80, -6.6), Vector3(-3.9, 2.05, -4.6), false],
	["b11_noordgevel_kantine", Vector3(8.0, 1.70, -7.2), Vector3(7.4, 1.6, -4.6), false],
	["b12_hoek_noordoost", Vector3(14.5, 1.70, -6.5), Vector3(12.3, 1.7, -4.6), false],
	["b13_oostgevel_terras", Vector3(14.8, 1.65, -2.5), Vector3(12.3, 1.5, -2.5), false],
	["b14_dakrand_tribune", Vector3(0.0, 1.70, 12.5), Vector3(0.0, 4.2, 7.0), false],
	["b15_poort_hek", Vector3(0.0, 1.65, 16.5), Vector3(0.0, 1.1, 13.95), false],
	["b16_fietsenrek", Vector3(4.5, 1.60, 15.0), Vector3(4.5, 0.5, 12.45), false],
	["b17_lichtmast_voet", Vector3(-14.0, 1.65, -6.2), Vector3(-16.6, 1.0, -6.3), false],
	["b18_pad_langs_veld", Vector3(-12.0, 1.65, -5.8), Vector3(2.0, 1.5, -5.8), false],
	["b19_veld_doel", Vector3(-6.0, 1.70, -8.0), Vector3(0.0, 1.5, -24.0), false],
	["b20_voorplein_overzicht", Vector3(-9.0, 1.70, 12.5), Vector3(2.0, 1.8, 7.5), false],

	# ── Binnen: elke doorgang van beide kanten ──
	["i01_entree_binnen", Vector3(0.0, 1.65, 5.4), Vector3(0.0, 1.6, 7.2), false],
	["i02_hal_hoeken", Vector3(1.4, 1.65, 6.4), Vector3(-1.8, 1.9, 2.4), false],
	["i03_hal_naar_kantine", Vector3(0.6, 1.65, 3.8), Vector3(2.2, 1.5, 3.0), false],
	["i04_kantine_naar_hal", Vector3(4.2, 1.65, 2.6), Vector3(2.0, 1.5, 3.4), false],
	["i05_bestuurskamerdeur", Vector3(0.4, 1.65, 5.6), Vector3(2.1, 1.5, 6.24), false],
	["i06_hal_naar_gang", Vector3(0.8, 1.65, 4.9), Vector3(-2.2, 1.5, 4.4), false],
	["i07_gang_naar_hal", Vector3(-3.6, 1.65, 4.4), Vector3(-2.1, 1.5, 4.8), false],
	["i08_deur_kleedkamer3", Vector3(-3.9, 1.65, 4.6), Vector3(-3.9, 1.4, 3.2), false],
	["i09_kleedkamer3_naar_gang", Vector3(-4.6, 1.65, 1.6), Vector3(-3.8, 1.5, 3.5), false],
	["i10_deur_kleedkamer4", Vector3(-9.3, 1.65, 4.6), Vector3(-9.3, 1.4, 3.2), false],
	["i11_kleedkamer4_binnen", Vector3(-8.0, 1.65, 2.6), Vector3(-10.6, 1.1, -0.6), false],
	["i12_kleedkamer4_zaklamp", Vector3(-8.0, 1.65, 2.6), Vector3(-10.6, 1.1, -0.6), true],
	["i13_douche3", Vector3(-3.9, 1.65, -1.9), Vector3(-4.4, 1.3, -4.4), true],
	["i14_douche3_terug", Vector3(-4.0, 1.65, -3.8), Vector3(-4.0, 1.5, -1.2), true],
	["i15_douche4", Vector3(-9.0, 1.65, -1.9), Vector3(-9.4, 1.3, -4.4), true],
	["i16_deur_onderhoud", Vector3(-12.9, 1.65, 4.6), Vector3(-12.9, 1.4, 3.2), false],
	["i17_onderhoud_binnen", Vector3(-13.2, 1.65, 2.4), Vector3(-13.4, 1.2, -0.8), true],
	["i18_deur_toiletten", Vector3(-5.1, 1.65, 4.0), Vector3(-5.1, 1.4, 5.4), false],
	["i19_toiletten_binnen", Vector3(-5.1, 1.65, 5.6), Vector3(-5.6, 1.2, 6.9), true],
	["i20_schoonmaaknis", Vector3(-8.0, 1.65, 4.6), Vector3(-8.0, 1.3, 6.2), true],
	["i21_nooddeur_binnen", Vector3(-13.4, 1.65, 4.4), Vector3(-15.0, 1.5, 4.4), false],
	["i22_gang_west_zaklamp", Vector3(-12.6, 1.65, 4.3), Vector3(-15.0, 1.3, 4.3), true],
	["i23_kantine_bar", Vector3(6.5, 1.65, 0.4), Vector3(10.8, 1.3, 3.0), false],
	["i24_kantine_ramen", Vector3(8.0, 1.65, 0.0), Vector3(7.4, 1.6, -4.5), false],
	["i25_keukendeur", Vector3(7.2, 1.65, 2.0), Vector3(8.8, 1.5, 3.6), false],
	["i26_terrasdeur_binnen", Vector3(10.0, 1.65, -1.6), Vector3(12.4, 1.5, -2.5), false],
	["i27_bestuurskamer_gesloten", Vector3(1.2, 1.65, 6.6), Vector3(2.2, 2.2, 5.9), false],
	["i28_kleedkamer3_plafond", Vector3(-5.6, 1.65, 1.4), Vector3(-3.0, 2.5, -1.0), false],
	["i29_kleedkamer3_hoek_west", Vector3(-4.4, 1.55, 0.6), Vector3(-7.0, 0.6, 2.9), true],
	["i30_gang_plafond", Vector3(-5.0, 1.65, 4.3), Vector3(-9.0, 2.4, 4.3), false],
]

var _spot: SpotLight3D


func _init() -> void:
	root.size = Vector2i(BREEDTE, HOOGTE)
	var packed: PackedScene = load(LEVEL)
	if packed == null:
		push_error("Inspectie: levelscène niet gevonden")
		quit(1)
		return
	root.add_child.call_deferred(packed.instantiate())
	_run.call_deferred()


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path("user://inspectie"))
	for naam in OPEN_DEUREN:
		var deur: Node = root.find_child(naam, true, false)
		if deur is Node3D:
			(deur as Node3D).rotate_y(deg_to_rad(-150.0))
	var camera := Camera3D.new()
	camera.fov = 70.0
	camera.near = 0.05
	camera.far = 140.0
	root.add_child(camera)
	camera.make_current()
	_spot = SpotLight3D.new()
	_spot.spot_angle = 35.0
	_spot.spot_range = 12.0
	_spot.light_energy = 4.0
	_spot.light_color = Color(1.0, 0.93, 0.82)
	_spot.spot_attenuation = 1.2
	_spot.shadow_enabled = true
	_spot.visible = false
	camera.add_child(_spot)
	for i in 5:
		await process_frame
	for shot in SHOTS:
		camera.global_position = shot[1]
		camera.look_at(shot[2])
		_spot.visible = shot[3]
		for i in 6:
			await process_frame
		var image := root.get_texture().get_image()
		image.save_png("user://inspectie/%s.png" % shot[0])
	print("Inspectie klaar (%d standpunten) → %s" % [SHOTS.size(),
		ProjectSettings.globalize_path("user://inspectie/")])
	quit(0)
