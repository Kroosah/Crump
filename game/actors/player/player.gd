class_name Player
extends CharacterBody3D
## Speler-controller (taak 002): gegronde first-person-beweging.
## Lopen/sluipen/rennen/bukken met acceleratie, muis-look zonder versnelling,
## uitschakelbare head-bob en voetstap-events op de EventBus. Alle tuning via
## de export-groepen — niet hardcoden (ARCHITECTURE §1.3).
##
## De speler kent geen enkel ander gameplay-systeem: voetstappen zijn feiten
## op de EventBus ("noise_made"), wie luistert beslist zelf (D-015).

## Gangmodi bepalen snelheid, stapritme en luidheid. Prioriteit bij tegelijk
## indrukken: bukken > sluipen > rennen — stil verslaat snel, want wie zich
## klein maakt kiest voor onhoorbaar (GAME_BIBLE §3, pijler 1).
enum Gait { WALK, SNEAK, RUN, CROUCH }

## Onder deze horizontale snelheid (m/s) telt de speler als stilstaand:
## geen voetstappen, geen head-bob.
const MIN_MOVING_SPEED := 0.5

## m/s waarmee de camera na het bewegen terugzakt naar zijn rustpositie.
const BOB_RETURN_SPEED := 0.25

@export_group("Movement")
## m/s — bewust traag: een clublid met een sporttas, geen soldaat (GAME_BIBLE §5).
@export var walk_speed := 2.6
@export var sneak_speed := 1.2
@export var run_speed := 4.6
@export var crouch_speed := 1.0
## m/s². Remmen sneller dan optrekken: gewicht zonder gladheid, anders voelt
## de speler als een camera op wieltjes (taakdossier 002).
@export var acceleration := 10.0
@export var deceleration := 14.0
## Fractie van de acceleratie die in de lucht overblijft (geen air-strafing).
@export var air_control := 0.25

@export_group("Camera")
## Radialen per pixel, vóór de gebruikersinstelling: het effectieve gevoel is
## look_sensitivity × SettingsManager.mouse_sensitivity. Rauwe muisbeweging,
## geen smoothing of acceleratie (taakdossier 002).
@export var look_sensitivity := 0.0022
@export var pitch_min_deg := -85.0
@export var pitch_max_deg := 85.0
## Ooghoogtes in meters. Bukken beweegt alleen de camera, niet de collider
## (TECH_DEBT TD-004 — kruipruimtes bestaan nog niet).
@export var stand_eye_height := 1.7
@export var crouch_eye_height := 1.15
## m/s waarmee de camera tussen sta- en bukhoogte beweegt.
@export var crouch_transition_speed := 4.0

@export_group("Head-bob")
## Amplitude in meters op topsnelheid; subtiel en uitschakelbaar via
## SettingsManager.head_bob_enabled (HORROR_GUIDELINES §8, motion sickness).
@export var bob_amplitude := 0.03
## Volledige bob-cycli per gelopen meter; koppelt het ritme aan de afstand
## zodat sneller lopen vanzelf sneller bobt.
@export var bob_cycles_per_meter := 0.9

@export_group("Footsteps")
## Seconden tussen twee stappen, per gangmodus.
@export var step_interval_walk := 0.55
@export var step_interval_sneak := 0.75
@export var step_interval_run := 0.35
@export var step_interval_crouch := 0.8
## Hoorbare cue-id per gangmodus (taak 005). StringName = grensvaluta
## (keuze B2): de speler kent geen audiosysteem; de klank leeft in
## SoundResources. Per-ondergrond-sets volgen zodra er een tweede
## ondergrond bestaat.
@export var footstep_cue_walk: StringName = &"footstep_walk"
@export var footstep_cue_sneak: StringName = &"footstep_sneak"
@export var footstep_cue_run: StringName = &"footstep_run"
@export var footstep_cue_crouch: StringName = &"footstep_crouch"
## Luidheid = draagafstand in meters op EventBus.noise_made: sluipen draagt
## amper, rennen alarmeert de halve gang. Dít is de consequentie van rennen
## (GAME_BIBLE §5, HORROR_GUIDELINES §3).
@export var loudness_walk := 6.0
@export var loudness_sneak := 2.0
@export var loudness_run := 14.0
@export var loudness_crouch := 2.5

var _gait := Gait.WALK
var _pitch := 0.0
var _bob_phase := 0.0

@onready var _head: Node3D = %Head
@onready var _camera: Camera3D = %Camera
@onready var _footstep_timer: Timer = %FootstepTimer


func _ready() -> void:
	# De spelerscamera neemt het beeld over; de testcamera van de dev room
	# laat dan los (D-016).
	_camera.make_current()
	_head.position.y = stand_eye_height
	_footstep_timer.timeout.connect(_on_footstep_timer_timeout)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Log.info("Player: actief (ooghoogte %.2f m)" % stand_eye_height)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion \
			and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_apply_look(event.relative)


func _physics_process(delta: float) -> void:
	_gait = _current_gait()
	_apply_movement(delta)
	_update_eye_height(delta)
	_update_head_bob(delta)
	_update_footsteps()


func _notification(what: int) -> void:
	# Bij pauze de muis vrijgeven zodat het (latere) menu bedienbaar is;
	# de muislook staat dan vanzelf uit via de capture-check hierboven.
	match what:
		NOTIFICATION_PAUSED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		NOTIFICATION_UNPAUSED:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _apply_look(relative: Vector2) -> void:
	var sensitivity := look_sensitivity * SettingsManager.mouse_sensitivity
	rotate_y(-relative.x * sensitivity)
	_pitch = clampf(_pitch - relative.y * sensitivity,
		deg_to_rad(pitch_min_deg), deg_to_rad(pitch_max_deg))
	_head.rotation.x = _pitch


func _current_gait() -> Gait:
	if Input.is_action_pressed("crouch"):
		return Gait.CROUCH
	if Input.is_action_pressed("sneak"):
		return Gait.SNEAK
	if Input.is_action_pressed("run"):
		return Gait.RUN
	return Gait.WALK


func _apply_movement(delta: float) -> void:
	var input_dir := Input.get_vector(
		"move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis
		* Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	var target := direction * _speed_for(_gait)

	# Bewuste beweging: naar de doelsnelheid toe werken i.p.v. hem te zíjn.
	var rate := acceleration if not direction.is_zero_approx() else deceleration
	if not is_on_floor():
		rate *= air_control
	var horizontal := Vector3(velocity.x, 0.0, velocity.z)
	horizontal = horizontal.move_toward(target, rate * delta)
	velocity.x = horizontal.x
	velocity.z = horizontal.z

	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()


func _update_eye_height(delta: float) -> void:
	var target := crouch_eye_height if _gait == Gait.CROUCH else stand_eye_height
	_head.position.y = move_toward(
		_head.position.y, target, crouch_transition_speed * delta)


func _update_head_bob(delta: float) -> void:
	var speed := Vector3(velocity.x, 0.0, velocity.z).length()
	if SettingsManager.head_bob_enabled and is_on_floor() \
			and speed > MIN_MOVING_SPEED:
		_bob_phase = wrapf(
			_bob_phase + speed * delta * bob_cycles_per_meter, 0.0, 1.0)
		var strength := clampf(speed / run_speed, 0.0, 1.0)
		_camera.position.y = sin(_bob_phase * TAU) * bob_amplitude * strength
	else:
		_camera.position.y = move_toward(
			_camera.position.y, 0.0, BOB_RETURN_SPEED * delta)


func _update_footsteps() -> void:
	var speed := Vector3(velocity.x, 0.0, velocity.z).length()
	var moving := is_on_floor() and speed > MIN_MOVING_SPEED
	if moving and _footstep_timer.is_stopped():
		_footstep_timer.start(_step_interval_for(_gait))
	elif not moving and not _footstep_timer.is_stopped():
		_footstep_timer.stop()


func _on_footstep_timer_timeout() -> void:
	# De timer loopt op kloktijd: is de speler nét gestopt, dan mag die tick
	# geen stap meer zijn — anders klinkt er een voetstap in de stilte.
	var speed := Vector3(velocity.x, 0.0, velocity.z).length()
	if not is_on_floor() or speed <= MIN_MOVING_SPEED:
		return
	# Twee gescheiden feiten per stap (kader 005 §1): het gameplay-feit voor
	# CRUMP's gehoor én het hoorbare feit — de speler hoort zijn eigen
	# prijs (P3). Geen van beide veroorzaakt ooit automatisch de ander.
	EventBus.noise_made.emit(global_position, _loudness_for(_gait))
	EventBus.audio_cue.emit(_footstep_cue_for(_gait), global_position)
	# One-shot + herstart, zodat een gangwissel meteen het nieuwe ritme pakt.
	_footstep_timer.start(_step_interval_for(_gait))


func _speed_for(gait: Gait) -> float:
	match gait:
		Gait.SNEAK:
			return sneak_speed
		Gait.RUN:
			return run_speed
		Gait.CROUCH:
			return crouch_speed
		_:
			return walk_speed


func _step_interval_for(gait: Gait) -> float:
	match gait:
		Gait.SNEAK:
			return step_interval_sneak
		Gait.RUN:
			return step_interval_run
		Gait.CROUCH:
			return step_interval_crouch
		_:
			return step_interval_walk


func _loudness_for(gait: Gait) -> float:
	match gait:
		Gait.SNEAK:
			return loudness_sneak
		Gait.RUN:
			return loudness_run
		Gait.CROUCH:
			return loudness_crouch
		_:
			return loudness_walk


func _footstep_cue_for(gait: Gait) -> StringName:
	match gait:
		Gait.SNEAK:
			return footstep_cue_sneak
		Gait.RUN:
			return footstep_cue_run
		Gait.CROUCH:
			return footstep_cue_crouch
		_:
			return footstep_cue_walk
