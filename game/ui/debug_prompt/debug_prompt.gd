extends CanvasLayer
## Tijdelijke debug-prompt (taak 003, opdracht GD): maakt de interactieprompt
## zichtbaar zolang de echte HUD (fase 2/4) niet bestaat.
##
## Strikt debug-gereedschap: bestaat alleen in debugbuilds (de bootstrap
## spawnt hem in _add_debug_tools), luistert uitsluitend naar
## EventBus.interact_prompt_changed en bevat GEEN eigen logica — hij toont
## letterlijk de ontvangen tekst. De toets komt dynamisch uit de InputMap.
## Verwijderen = deze map weggooien (D-015); TD-006 markeert dat moment.

@onready var _label: Label = %PromptLabel


func _ready() -> void:
	_label.text = ""
	EventBus.interact_prompt_changed.connect(_on_prompt_changed)


func _on_prompt_changed(text: String) -> void:
	if text.is_empty():
		_label.text = ""
		return
	_label.text = "[%s] %s" % [_interact_key_name(), text]


## De actueel gebonden toets voor 'interact' — nooit hardcoden ("E"), zodat
## een rebind deze weergave gratis volgt (taakdossier 003).
func _interact_key_name() -> String:
	for event in InputMap.action_get_events("interact"):
		if event is InputEventKey:
			return event.as_text_physical_keycode()
	return "?"
