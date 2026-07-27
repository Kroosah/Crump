# CRUMP — Coding Standards

*Bindende afspraken voor alle code en scènes in dit project — voor mensen én
AI-sessies. Consistentie boven voorkeur: de stijl die hier staat wint.*

---

## 1. Taal en toon

- **Code-taal**: GDScript, Godot 4.7-syntax. Geen Godot 3-constructies
  (`yield`, `onready` zonder `@`, oude signal-syntax).
- **Naamgeving in het Engels** (klassen, functies, variabelen) — dat matcht
  de engine-API en voorkomt half-om-half-code. **Commentaar, docstrings,
  commits en speler-teksten in het Nederlands.**
- Commentaar legt *waarom* uit, niet *wat*. Slechte comment: `# verhoog i`.
  Goede comment: `# Gehoor-radius schaalt met luidheid: fluisteren draagt 2m,
  een dichtslaande deur 20m (zie HORROR_GUIDELINES §3).`

## 2. Bestandsnamen en mappen

| Wat | Conventie | Voorbeeld |
|---|---|---|
| Mappen | `snake_case` | `game/actors/player/` |
| Scènes | `snake_case.tscn` | `player.tscn`, `door_wooden.tscn` |
| Scripts | `snake_case.gd`, zelfde naam als de scène waar hij bij hoort | `player.gd` |
| Resources | `snake_case.tres` met type-suffix | `item_flashlight.tres`, `footsteps_concrete.tres` |
| Shaders | `snake_case.gdshader` | `flicker_light.gdshader` |
| Audio | `categorie_beschrijving_variant.ogg` | `sfx_door_creak_01.ogg`, `amb_hum_fluorescent.ogg` |
| Autoloads | `PascalCase`-naam in project settings | `EventBus`, `GameState` |

Eén scène + script + lokale resources bij elkaar in één map (zie
ARCHITECTURE §3). Assets krijgen nooit spaties of hoofdletters in de naam.

## 3. GDScript-stijl

Basis = de officiële GDScript style guide; daarbovenop onze keuzes:

```gdscript
class_name Player
extends CharacterBody3D
## Speler-controller: beweging, sluipen, camera.
## Tuning gebeurt via de export-groep "Movement" — niet hardcoden.

signal noise_made(position: Vector3, loudness: float)

const STEP_INTERVAL_WALK := 0.55  # seconden tussen voetstappen bij lopen

@export_group("Movement")
@export var walk_speed := 2.6      # m/s — bewust traag, zie GAME_BIBLE §5
@export var sneak_speed := 1.2
@export var run_speed := 4.6

var _step_timer := 0.0             # privé: underscore-prefix

@onready var _camera: Camera3D = %Camera


func _physics_process(delta: float) -> void:
    _apply_movement(delta)


func _apply_movement(delta: float) -> void:
    # Bewuste, iets zware beweging: acceleratie i.p.v. instant snelheid,
    # anders voelt de speler als een camera op wieltjes.
    ...
```

Regels:

1. **Volgorde in een script**: `class_name`/`extends` → docstring → signals →
   enums/consts → exports → publieke vars → privé-vars (`_prefix`) →
   `@onready` → lifecycle-functies (`_ready`, `_process`, ...) → publieke
   functies → privé-functies.
2. **Types waar het kan**: parameters en returns altijd getypt
   (`func open(by: Node) -> bool:`); `:=` voor afleidbare types.
3. **Signalen boven directe aanroepen omhoog**: een kind roept nooit
   functies op zijn parent/verdere voorouders aan; het zendt een signaal.
   Omlaag (parent stuurt kind aan) mag wel direct.
4. **`%UniqueName`-nodes** voor interne verwijzingen in een scène; nooit
   lange `get_node("../../..")`-paden.
5. **Magic numbers bestaan niet**: het is een `const` met naam, of een
   `@export` als het tuning is.
6. **Geen `print()` in gecommitte code**; debug via een `Debug`-helper of
   verwijder het. Foutpaden gebruiken `push_warning`/`push_error`.
7. Functies doen één ding en passen op een scherm; erboven = opsplitsen.
8. `await` alleen met duidelijke eigenaar en afbreekpad — geen zwevende
   coroutines die na scène-wissel nog leven.

## 4. Scène-conventies

1. **Elke scène heeft één verantwoordelijkheid** en kan zelfstandig
   geïnstantieerd worden zonder te crashen (nodig voor tests).
2. Root-node draagt de scène-naam in PascalCase (`Player`, `DoorWooden`).
3. Scène-structuur is ondiep en leesbaar; groepeer met `Node3D`-containers
   met betekenisvolle namen (`Visuals`, `Colliders`, `Audio`).
4. **Signalen verbinden in code** (`_ready`), niet in de editor-UI —
   editor-connecties zijn onzichtbaar in diffs en reviews.
5. Herbruikbare props zijn eigen scènes in `game/props/`, geïnstantieerd in
   levels — nooit gekopieerde subtrees.
6. Physics-lagen krijgen namen in de project settings (geen "Layer 7");
   de indeling wordt bij taak 001 vastgelegd.

## 5. Resources en data

- Tuning-data en definities (items, voetstap-sets, AI-profielen) zijn
  `Resource`-subklassen met `class_name`, opgeslagen als `.tres`.
- Resources bevatten **data, geen gedrag** (hooguit pure helper-functies).
- Geen dictionaries-als-schema door de codebase; als data structuur heeft,
  krijgt het een Resource-klasse met getypte velden.

## 6. Git-afspraken

- **Commits**: Nederlands, gebiedende wijs, klein en thematisch.
  Prefix met taaknummer of `[docs]`:
  - `[002] Voeg sneak-modus met halve gehoor-radius toe`
  - `[docs] Scherp lichtbudget aan in LEVEL_GUIDELINES`
- **main is altijd importeerbaar.** Grote/risicovolle taken op een
  `taak/NNN-naam`-branch, mergen wanneer headless-import + tests groen zijn.
- Gegenereerde bestanden (`.godot/`, `builds/`, importcache) nooit committen.
- Eén commit wijzigt niet én code én ontwerp-documenten, tenzij de wijziging
  ze onlosmakelijk verbindt (dan uitleggen in de commit-body).

## 7. Foutafhandeling en robuustheid

- Systemen falen **luid in ontwikkeling** (`assert`, `push_error`) en
  **stil-veilig in release** (fallback zonder crash).
- Nooit stil `null` doorgeven: als een dependency ontbreekt is dat een bug
  die we nú willen zien, niet in een playtest.
- Save-code behandelt elk bestand als mogelijk corrupt: versie-check,
  try-parse, en een nette "save onleesbaar"-afhandeling.

## 8. Definition of Done (per taak)

1. Acceptatiecriteria uit het taakdossier gehaald.
2. `godot --headless --path . --import` schoon (exitcode 0, geen errors).
3. Smoke-/unit-tests groen; nieuwe logica heeft tests waar zinvol.
4. Geen debug-prints, geen dode code, geen TODO zonder taaknummer.
5. Tuning zit in exports/resources, niet in magic numbers.
6. Taakdossier bijgewerkt (status, afwijkingen, vervolgpunten).
7. Gecommit volgens §6.
