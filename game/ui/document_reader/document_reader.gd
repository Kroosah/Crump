extends CanvasLayer
## De documentlezer (taak 007): een verwijderbare UI-luisteraar die het
## feit document_opened(id, titel, tekst) toont. Kent geen enkel
## proptype en geen resource-klasse — alleen de drie basistypen van de
## bus (D-021). Verwijder deze map en documenten blijven registreren en
## zenden; er verschijnt alleen geen paneel (D-015).
##
## Modaal gedrag (dossier 007 §4): lezen pauzeert de wereld via het
## bestaande pauzemechanisme (polling-input is niet met handled-events
## te stoppen; PAUSABLE stilzetten wél — speler, interactor en zaklamp
## tegelijk). De reader bezit zijn pauzeclaim expliciet en herstelt bij
## sluiten uitsluitend wat hij zelf wijzigde, exact één keer.

## Lifecycle van het paneel (§4a): sluit-input wordt pas geaccepteerd in
## OPEN_GEWAPEND; het wapenen gebeurt deferred, dus gegarandeerd ná de
## volledige dispatch van het openende E-event. Geen timer, geen cooldown.
enum ReaderState { CLOSED, OPEN_UNARMED, OPEN_ARMED }

var _state := ReaderState.CLOSED
## Statusopname van vóór de eerste echte opening (§4b); een vervanging
## (§4c) raakt deze drie nooit aan.
var _prev_paused := false
var _prev_mouse_mode := Input.MOUSE_MODE_VISIBLE
var _owns_pause := false
## Alleen de eerste node in de groep verbindt zich met de bus (het
## inventory-patroon): een tweede reader meldt zich luid en blijft doof.
var _authoritative := false

@onready var _root: Control = %Root
@onready var _title_label: Label = %TitleLabel
@onready var _scroll: ScrollContainer = %Scroll
@onready var _text_label: Label = %TextLabel
@onready var _hint_label: Label = %HintLabel


func _ready() -> void:
	# De reader moet werken terwijl de wereld stilstaat (hij bezit de
	# pauze); de bootstrap-ouder is al ALWAYS, dit maakt het expliciet.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_root.visible = false
	_hint_label.text = _build_hint()
	if get_tree().get_nodes_in_group("document_reader")[0] != self:
		push_warning("DocumentReader: tweede instantie genegeerd — niet met de bus verbonden")
		return
	_authoritative = true
	EventBus.document_opened.connect(_on_document_opened)


func _exit_tree() -> void:
	# Verwijderd worden telt als sluiten: eigen wijzigingen herstellen
	# (§4b) — nooit een bevroren spel achterlaten. Daarna symmetrisch
	# met _ready afbreken.
	_close()
	if _authoritative:
		EventBus.document_opened.disconnect(_on_document_opened)
		_authoritative = false


func _input(event: InputEvent) -> void:
	# Sluiten alleen in gewapende toestand (§4a). Het event wordt
	# opgegeten vóór de _unhandled_input van de bootstrap: één Esc sluit
	# alléén het document en opent nooit tegelijk het pauzemenu (§4b).
	if _state != ReaderState.OPEN_ARMED:
		return
	if event.is_action_pressed("pause") or event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		_close()


## Leesvenster voor tests/debug: staat het paneel open?
func is_open() -> bool:
	return _state != ReaderState.CLOSED


func _on_document_opened(document_id: StringName, title: String,
		text: String) -> void:
	# Defensieve hervalidatie (§4d): de prop valideert al, maar een
	# handmatig gezonden fout feit mag nooit een leeg paneel openen —
	# en laat bij een open reader de bestaande inhoud ongemoeid.
	if document_id == &"":
		push_warning("DocumentReader: feit met lege document_id genegeerd")
		return
	if text.is_empty():
		push_warning("DocumentReader: feit met lege tekst genegeerd ('%s')"
			% document_id)
		return
	# Inhoud atomair (ver)plaatsen; lege titel = geen titelregel (§4d).
	_title_label.text = title
	_title_label.visible = not title.is_empty()
	_text_label.text = text
	_scroll.scroll_vertical = 0
	if _state == ReaderState.CLOSED:
		# Statusopname alléén bij een echte opening (§4b/§4c): een
		# vervanging mag de bewaarde toestand nooit overschrijven.
		_prev_paused = get_tree().paused
		_prev_mouse_mode = Input.mouse_mode
		_owns_pause = not _prev_paused
		if _owns_pause:
			get_tree().paused = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		_state = ReaderState.OPEN_UNARMED
		# Wapenen ná de volledige dispatch van het openende event (§4a):
		# elk vólgend inputevent treft een gewapende reader.
		_arm.call_deferred()
	_root.visible = true
	Log.info("DocumentReader: '%s' geopend" % document_id)


func _arm() -> void:
	if _state == ReaderState.OPEN_UNARMED:
		_state = ReaderState.OPEN_ARMED


func _close() -> void:
	# Idempotent: herstel gebeurt exact één keer (§4b).
	if _state == ReaderState.CLOSED:
		return
	_state = ReaderState.CLOSED
	# Vaste volgorde: paneel dicht → exacte oude muismodus → alleen bij
	# eigen claim de pauze vrijgeven. Een boom die al gepauzeerd wás,
	# wordt nooit onbedoeld actief gemaakt.
	_root.visible = false
	Input.mouse_mode = _prev_mouse_mode
	if _owns_pause:
		get_tree().paused = false
		_owns_pause = false
	Log.info("DocumentReader: gesloten")


## Sluithint uit de InputMap (geen hardcoded toetsnamen).
func _build_hint() -> String:
	var keys := PackedStringArray()
	for action in [&"pause", &"interact"]:
		for event in InputMap.action_get_events(action):
			if event is InputEventKey:
				keys.append(event.as_text_physical_keycode())
				break
	if keys.is_empty():
		return ""
	return "[%s] sluiten" % "] of [".join(keys)
