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
	var active := viewport.get_camera_3d()
	if active == self:
		Log.info("DevRoom: testcamera levert het beeld")
		return
	if active == null:
		# Precies het geval dat een egaal grijs scherm oplevert; bijspringen.
		current = true
		Log.warn("DevRoom: geen actieve camera gevonden — testcamera ingeschakeld")
		return
	Log.info("DevRoom: testcamera laat het beeld aan camera '%s'" % active.name)
