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

## [naam, camerapositie, kijkdoel, zaklamp aan]. De eerste zes volgen de
## verplichte lijst uit de F2.1-opdracht en gebruiken exact dezelfde
## camera's als hun F2-tegenhangers (01=F2/01, 02=F2/02, 03=F2/03,
## 04=F2/13, 05=F2/07, 06=F2/08), zodat voor/na objectief te vergelijken
## is. Daarna staan de contextbeelden.
const SHOTS := [
	["01_F21_kleedkamer_wide", Vector3(-2.95, 1.62, -0.55), Vector3(-6.50, 1.05, 2.30), false],
	["02_F21_kleedkamer_deuropening", Vector3(-3.88, 1.62, 3.28), Vector3(-6.40, 1.10, -0.30), false],
	["03_F21_vloer_wand_bank_detail", Vector3(-6.00, 1.05, 1.65), Vector3(-6.95, 0.50, 0.95), false],
	["04_F21_kast_kozijn", Vector3(-5.90, 1.60, 0.30), Vector3(-2.90, 1.10, 2.70), false],
	["05_F21_gang_reference", Vector3(-8.00, 1.65, 4.25), Vector3(-15.00, 1.30, 4.32), false],
	["06_F21_gang_donkerste", Vector3(-10.20, 1.65, 4.85), Vector3(-14.90, 1.20, 4.20), false],
	# Context: banken, doorkijk, zaklamp en de gang van beide kanten.
	["11_banken_props", Vector3(-5.30, 1.25, 1.95), Vector3(-6.78, 0.28, 0.45), false],
	["12_blik_richting_gang", Vector3(-5.70, 1.65, 0.85), Vector3(-3.80, 1.42, 3.60), false],
	["13_gang_vanaf_kleedkamer", Vector3(-3.15, 1.65, 4.40), Vector3(-14.00, 1.32, 4.34), false],
	["14_zaklamp_aan", Vector3(-11.50, 1.65, 4.35), Vector3(-15.00, 1.45, 4.31), true],
	["15_zaklamp_uit", Vector3(-11.50, 1.65, 4.35), Vector3(-15.00, 1.45, 4.31), false],
	["16_kleedkamer_zaklamp", Vector3(-5.90, 1.60, 0.30), Vector3(-2.90, 1.10, 2.70), true],
	["17_gang_oost", Vector3(-2.60, 1.65, 4.30), Vector3(-14.50, 1.30, 4.30), false],
	["18_kleedkamer3_douche", Vector3(-4.20, 1.65, 0.40), Vector3(-3.90, 1.20, -3.60), false],
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
