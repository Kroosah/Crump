extends SceneTree
## Maakt screenshots van het clubgebouw op de bouw-VPS (VS-fase G).
## Draait met software-Vulkan (lavapipe) onder xvfb — de enige manier om
## op deze headless machine echt te renderen. Puur gereedschap: laadt de
## levelscène los (zonder bootstrap/speler) en fotografeert vaste
## standpunten. Gebruik:
##   VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/lvp_icd.json \
##   xvfb-run -a godot --path . --rendering-driver vulkan \
##     -s tools/maak_screenshots.gd
## Output: schermafbeeldingen in user://screenshots/ (pad wordt gelogd).
##
## Twee dingen die het spel wél heeft en dit gereedschap zelf moet
## nabootsen, omdat er geen speler en geen autoloads zijn:
## - de deur van kleedkamer 3 wordt opengedraaid (puur de transform, geen
##   signalen), zodat de doorkijk kleedkamer ↔ gang te zien is;
## - de zaklamp is een SpotLight3D met exact de exportwaarden uit
##   game/systems/flashlight/flashlight.gd (35°, 12 m, energie 4,0,
##   kleur 1/0,93/0,82, attenuatie 1,2, schaduw aan).

const LEVEL := "res://game/levels/clubgebouw/clubgebouw.tscn"
const BREEDTE := 1600
const HOOGTE := 900

## [naam, camerapositie, kijkdoel, zaklamp aan]. Shots 01–12 volgen de
## verplichte AD-renderlijst uit de F3-opdracht; shot 11 is de
## vergelijkingsopname met de F2.1-hero-kleedkamer (zelfde camera als
## F2.1/01). Daarna contextbeelden, waaronder de protected-darkness-
## controle op de gang (F3-brief §6).
const SHOTS := [
	["01_bestuurskamer_deuropening", Vector3(2.30, 1.62, 5.74), Vector3(5.40, 1.05, 5.20), false],
	["02_bestuurskamer_naar_deur", Vector3(5.35, 1.58, 6.30), Vector3(2.20, 1.25, 5.55), false],
	["03_bestuurskamer_bureau_detail", Vector3(4.30, 1.40, 5.05), Vector3(5.40, 0.90, 4.05), false],
	["04_bestuurskamer_donkerste", Vector3(2.55, 1.60, 6.55), Vector3(5.85, 1.35, 6.35), false],
	["05_hal_richting_gang", Vector3(1.30, 1.62, 5.60), Vector3(-2.05, 1.25, 4.30), false],
	["06_hal_richting_bestuurskamer", Vector3(-1.45, 1.62, 3.55), Vector3(2.10, 1.40, 6.00), false],
	["07_entree_binnen_naar_buiten", Vector3(0.00, 1.62, 5.10), Vector3(-0.20, 1.45, 9.50), false],
	["08_entree_buiten_naar_binnen", Vector3(-0.30, 1.62, 9.70), Vector3(0.10, 1.55, 6.90), false],
	["09_brede_buitenopname", Vector3(-8.60, 1.70, 12.40), Vector3(2.00, 1.90, 7.30), false],
	["10_nat_materiaal_closeup", Vector3(2.05, 1.10, 9.40), Vector3(2.75, 0.05, 8.45), false],
	["11_F21_hero_referentie", Vector3(-2.95, 1.62, -0.55), Vector3(-6.50, 1.05, 2.30), false],
	["12_best_shot_entree", Vector3(-3.30, 1.55, 9.90), Vector3(0.70, 2.10, 7.25), false],
	# Context: samenhang van de route en de beschermde gang.
	["13_hal_overzicht", Vector3(1.55, 1.60, 2.75), Vector3(-1.30, 1.30, 6.60), false],
	["14_bestuurskamer_tl_zijde", Vector3(4.90, 1.55, 4.35), Vector3(2.60, 1.20, 6.30), false],
	["15_gang_protected_check", Vector3(-2.30, 1.65, 4.30), Vector3(-14.50, 1.30, 4.30), false],
	["16_voorplein_vanaf_poort", Vector3(0.40, 1.65, 13.20), Vector3(-0.40, 1.80, 7.40), false],
	["17_historie_wand_zaklamp", Vector3(4.20, 1.55, 5.85), Vector3(5.95, 1.55, 6.30), true],
	["18_kleedkamer_naar_gang_check", Vector3(-5.70, 1.65, 0.85), Vector3(-3.80, 1.42, 3.60), false],
]

var _spot: SpotLight3D


func _init() -> void:
	root.size = Vector2i(BREEDTE, HOOGTE)
	var packed: PackedScene = load(LEVEL)
	if packed == null:
		push_error("Screenshots: levelscène niet gevonden")
		quit(1)
		return
	var level: Node = packed.instantiate()
	root.add_child.call_deferred(level)
	_run.call_deferred()


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path("user://screenshots"))
	_open_deur("DeurKleedkamer3")
	# F3: de bestuurskamer is in het spel op slot (sleutelflow, D-032),
	# maar de AD-renders beoordelen de kamer zelf — dus hier open. De
	# hoofdentree en de gangdeur staan open voor de routeshots.
	_open_deur("DeurBestuurskamer")
	_open_deur("DeurHoofdentree")
	_open_deur("DeurHalGang")
	var camera := Camera3D.new()
	camera.fov = 70.0
	camera.near = 0.05
	camera.far = 120.0
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
	# Eerste frames laten de TL's en shaders settelen.
	for i in 5:
		await process_frame
	for shot in SHOTS:
		camera.global_position = shot[1]
		camera.look_at(shot[2])
		_spot.visible = shot[3]
		# Een paar frames per standpunt: belichting en flikkerfase.
		for i in 8:
			await process_frame
		var image := root.get_texture().get_image()
		var path: String = "user://screenshots/%s.png" % shot[0]
		image.save_png(path)
		# Meteen de rendermeters van dít standpunt: zo staat de
		# performance-impact van een artpass zwart-op-wit in het rapport.
		print("  → %s  [objecten %d · draw calls %d · primitieven %d]" % [
			ProjectSettings.globalize_path(path),
			RenderingServer.get_rendering_info(
				RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME),
			RenderingServer.get_rendering_info(
				RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
			RenderingServer.get_rendering_info(
				RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)])
	print("Screenshots klaar (%d standpunten)." % SHOTS.size())
	quit(0)


## Draait een deurpaneel open zonder de prop-logica aan te roepen: dit
## gereedschap draait zonder autoloads, dus signalen en audio-cues zouden
## hier alleen maar fouten opleveren.
func _open_deur(deur_naam: String) -> void:
	var deur: Node = root.find_child(deur_naam, true, false)
	if deur is Node3D:
		# 150° = wagenwijd open, blad schuin tegen de gangwand. In het
		# spel opent de deur 90°; dat blad zou precies de doorkijk
		# kleedkamer ↔ gang wegnemen die de GD wil beoordelen.
		(deur as Node3D).rotate_y(deg_to_rad(-150.0))
