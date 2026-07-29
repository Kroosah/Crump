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

const LEVEL := "res://game/levels/clubgebouw/clubgebouw.tscn"

## [naam, camerapositie, kijkdoel] — ooghoogte 1,65 m tenzij anders.
const SHOTS := [
	["entree_buiten", Vector3(0.0, 1.65, 11.5), Vector3(0.0, 1.6, 7.1)],
	["hal", Vector3(0.0, 1.65, 6.6), Vector3(-1.2, 1.4, 2.6)],
	["hal_naar_gang", Vector3(1.2, 1.65, 4.8), Vector3(-2.2, 1.4, 4.3)],
	["gang_oost", Vector3(-2.6, 1.65, 4.3), Vector3(-14.5, 1.3, 4.3)],
	["gang_west", Vector3(-13.6, 1.65, 4.5), Vector3(-2.4, 1.4, 4.2)],
	["kleedkamer3", Vector3(-3.0, 1.65, 2.7), Vector3(-6.2, 1.1, -0.6)],
	["kleedkamer3_douche", Vector3(-4.2, 1.65, 0.4), Vector3(-3.9, 1.2, -3.6)],
	["douche3", Vector3(-3.9, 1.65, -1.9), Vector3(-4.4, 1.3, -4.4)],
	["kleedkamer4", Vector3(-8.0, 1.65, 2.8), Vector3(-10.6, 1.1, -0.4)],
	["bestuurskamer", Vector3(2.7, 1.65, 6.6), Vector3(5.4, 1.3, 4.3)],
	["voorplein_gevel", Vector3(-4.5, 1.65, 12.8), Vector3(2.0, 1.8, 7.1)],
]

var _frames_left := 0


func _init() -> void:
	root.size = Vector2i(1280, 720)
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
	var camera := Camera3D.new()
	camera.fov = 70.0
	camera.near = 0.05
	camera.far = 120.0
	root.add_child(camera)
	camera.make_current()
	# Eerste frames laten de TL's en shaders settelen.
	for i in 5:
		await process_frame
	for shot in SHOTS:
		camera.global_position = shot[1]
		camera.look_at(shot[2])
		# Een paar frames per standpunt: belichting en flikkerfase.
		for i in 8:
			await process_frame
		var image := root.get_texture().get_image()
		var path: String = "user://screenshots/%s.png" % shot[0]
		image.save_png(path)
		print("  → %s" % ProjectSettings.globalize_path(path))
	print("Screenshots klaar (%d standpunten)." % SHOTS.size())
	quit(0)
