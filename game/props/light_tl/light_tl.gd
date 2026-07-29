extends Node3D
## TL-armatuur (taak 006, keuze E): één herbruikbare prop met drie
## expliciete, per lamp gekozen staten. Een kapotte buis ís zijn eigen
## wereld-oorzaak (HORROR §4).
##
## Invarianten (bindend, dossier 006 §4): STABIEL flikkert nooit spontaan;
## DEFECT is uit en flikkert nooit; FLIKKEREND is een bewuste per-lamp-
## keuze met een deterministisch patroon (vaste seed) dat rust bevat —
## geen strobe, geen globale flikkercontroller, geen automatische
## overgangen tussen staten.

enum TlState { STABIEL, DEFECT, FLIKKEREND }

## De staat is een expliciete editor-keuze per lamp, nooit een gevolg.
@export var state: TlState = TlState.STABIEL:
	set(value):
		state = value
		if is_inside_tree():
			_apply_state()

@export_group("Licht")
@export var light_energy_on := 1.6
## Koel TL-wit; de warme zaklampbundel steekt hier bewust tegen af (§1).
@export var light_color := Color(0.82, 0.88, 1.0)
@export var light_range := 7.0
## Schaduw is een budgetkeuze per lamp: maximaal 3 level-lampen werpen
## schaduw (dossier 006 §5) — dus bewust default uit.
@export var cast_shadow := false

@export_group("Uiterlijk")
## Zwartgeblakerd buiseinde (taak 008G, artplan §8): de zichtbare
## wereld-oorzaak van een haperende buis. Puur visueel, per lamp gekozen.
@export var scorched := false

@export_group("Flikker")
## Vaste seed: zelfde seed = identiek patroonverloop, frame voor frame
## (physics-tick is de klok) — reproduceerbaar en headless testbaar.
@export var flicker_seed := 1
## Seconden rust (buis gewoon aan) tussen twee flikkerbursts.
@export var rest_min_s := 1.2
@export var rest_max_s := 3.5
## Haperingen per burst.
@export var burst_ticks_min := 2
@export var burst_ticks_max := 5

## Herhalend patroon als segmenten: x = duur (s), y = lichtniveau 0..1.
var _segments := PackedVector2Array()
var _pattern_length := 0.0
var _pattern_time := 0.0

@onready var _light: OmniLight3D = %Light
@onready var _tube: MeshInstance3D = %Tube


func _ready() -> void:
	_light.light_color = light_color
	_light.omni_range = light_range
	_light.shadow_enabled = cast_shadow
	if scorched:
		_add_scorch_mark()
	_apply_state()


func _physics_process(delta: float) -> void:
	# Alleen actief in FLIKKEREND (zie _apply_state). Op de physics-tick:
	# vaste stapgrootte, dus het verloop is per frame deterministisch.
	_pattern_time = fmod(_pattern_time + delta, _pattern_length)
	_set_level(_level_at(_pattern_time))


## Voor de F3-telling (duck-typed via de groep `light_tl`).
func get_tl_state() -> int:
	return state


func _apply_state() -> void:
	set_physics_process(state == TlState.FLIKKEREND)
	match state:
		TlState.STABIEL:
			_set_level(1.0)
		TlState.DEFECT:
			_set_level(0.0)
		TlState.FLIKKEREND:
			_build_pattern()
			_pattern_time = 0.0
			_set_level(_level_at(0.0))


## Bouwt ~20 s naadloos herhalend patroon: grotendeels áán met korte
## haperingsbursts — flikkeren mét rust (invariant keuze E).
func _build_pattern() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = flicker_seed
	_segments = PackedVector2Array()
	_pattern_length = 0.0
	while _pattern_length < 20.0:
		_append_segment(rng.randf_range(rest_min_s, rest_max_s), 1.0)
		for i in rng.randi_range(burst_ticks_min, burst_ticks_max):
			_append_segment(rng.randf_range(0.03, 0.1),
				rng.randf_range(0.0, 0.25))
			_append_segment(rng.randf_range(0.04, 0.15), 1.0)


func _append_segment(duration: float, level: float) -> void:
	_segments.append(Vector2(duration, level))
	_pattern_length += duration


func _level_at(time: float) -> float:
	var cursor := 0.0
	for segment in _segments:
		cursor += segment.x
		if time < cursor:
			return segment.y
	return 1.0


## Klein donker overzetje over het buiseinde — geen licht, geen gedrag.
func _add_scorch_mark() -> void:
	var mark := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.2, 0.068, 0.128)
	mark.mesh = box
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.07, 0.06, 0.06, 0.88)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.roughness = 0.6
	mark.material_override = material
	_tube.add_child(mark)
	mark.position = Vector3(0.5, 0.0, 0.0)


func _set_level(level: float) -> void:
	# Licht en buisgloed uit dezelfde waarde: ze kunnen nooit uit de pas.
	_light.light_energy = light_energy_on * level
	_light.visible = level > 0.0
	_tube.set_instance_shader_parameter(&"flicker", level)
