extends Camera3D
## Vaste testcamera van de developer room.
##
## Bestaat omdat de blockout ook zónder speler te beoordelen moet zijn: zolang
## er geen spelerscamera is (taak 002) valt de viewport zonder camera terug op
## de default clear color — een egaal grijs scherm dat als "kapotte render"
## gelezen wordt terwijl er niets mis is (KI-001).
##
## Deze camera is een ontwikkelhulpmiddel en wint daarom nooit van gameplay:
## een camera die later het beeld overneemt (de spelerscamera) houdt het.

func _ready() -> void:
	# Uitgesteld, want pas als de hele boom staat is te zien wie er nog meer
	# kijkt: een speler wordt na het level toegevoegd.
	_verify_view.call_deferred()


func _verify_view() -> void:
	var viewport := get_viewport()
	if viewport == null:
		return
	# Het script wordt door meerdere levels gebruikt (taak 008C); de
	# eigenaar van de melding is het level, niet dit hulpmiddel.
	var level_name := get_parent().name if get_parent() != null else name
	var active := viewport.get_camera_3d()
	if active == self:
		Log.info("%s: testcamera levert het beeld" % level_name)
		return
	if active == null:
		# Precies het geval dat een egaal grijs scherm oplevert; bijspringen.
		current = true
		Log.warn("%s: geen actieve camera gevonden — testcamera ingeschakeld" % level_name)
		return
	Log.info("%s: testcamera laat het beeld aan camera '%s'" % [level_name, active.name])
