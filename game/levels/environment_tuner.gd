extends WorldEnvironment
## Environment-tuner (taak 006, keuze F): past de gebruikersinstelling
## `brightness` toe op de Environment van dít level — en op niets anders.
## Hoort als script op de WorldEnvironment-node van elk level.
##
## Brightness is een nabewerking op het eindbeeld (adjustment_brightness):
## UI-lagen (CanvasLayer), lampenergieën en het schaduwbudget blijven
## onaangeraakt, en dankzij de smalle range in SettingsManager kan de
## instelling het lichtontwerp nooit herschrijven (dossier 006 §6).

func _ready() -> void:
	if environment == null:
		# Luid in ontwikkeling (CODING_STANDARDS §7): een level zonder
		# environment is een configuratiefout, geen tuning-kwestie.
		push_warning("EnvironmentTuner: '%s' heeft geen Environment-resource"
			% name)
		return
	environment.adjustment_enabled = true
	_apply_brightness(SettingsManager.brightness)
	SettingsManager.brightness_changed.connect(_apply_brightness)


func _exit_tree() -> void:
	# Symmetrisch met _ready (zelfde patroon als inventory/audio).
	if SettingsManager.brightness_changed.is_connected(_apply_brightness):
		SettingsManager.brightness_changed.disconnect(_apply_brightness)


func _apply_brightness(value: float) -> void:
	environment.adjustment_brightness = value
