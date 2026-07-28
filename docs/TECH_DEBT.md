# CRUMP — Technische schuld (TECH_DEBT.md)

*Elke bewuste tijdelijke oplossing, elk uitgesteld besluit en elke bekende
tekortkoming in de architectuur staat hier. Zo kan een tijdelijke oplossing
nooit stilletjes permanent worden. **Verplicht bijhouden** bij elke taak
(zie CLAUDE.md).*

## Werkwijze

- **Schuld aangaan mag** — bewust en gedocumenteerd. Wie iets tijdelijks
  bouwt, maakt in dezelfde commit een entry aan (`TD-xxx`).
- **Status** geeft de urgentie:
  - **Hoog** — remt de ontwikkeling of riskeert bugs; aflossen bij de
    eerstvolgende taak die het gebied raakt.
  - **Middel** — moet vóór de release van de betreffende fase opgelost zijn.
  - **Laag** — acceptabel; heroverwegen op het genoemde moment.
- Elke entry noemt een **aflosmoment**: de taak of fase waarin de schuld
  wordt opgelost of opnieuw beoordeeld.
- Afgeloste schuld verhuist naar de historie onderaan, met commit-verwijzing.
- Tijdelijke oplossingen zónder entry zijn niet toegestaan (CLAUDE.md,
  ontwikkelregel 6: geen hacks — een gedocumenteerde tijdelijke oplossing
  mét aflosplan is het enige toegestane compromis).

## Formaat

```
## TD-001 — Korte titel
**Datum**: jjjj-mm-dd · **Status**: Hoog/Middel/Laag · **Aflosmoment**: taak/fase
**Waar**: systeem/bestand
**Schuld**: wat is er tijdelijk of onaf, en waarom is daarvoor gekozen.
**Aflossing**: wat er moet gebeuren om dit netjes te maken.
```

---

## Openstaande schuld

## TD-001 — Export-templates nog niet geïnstalleerd op de bouw-VPS
**Datum**: 2026-07-27 · **Status**: Laag · **Aflosmoment**: fase 6 (Polish & Steam), of eerder bij de eerste export-behoefte
**Waar**: bouw-VPS (Godot-installatie)
**Schuld**: alleen de engine-binary is geïnstalleerd; de export-templates
(~1 GB) bewust niet — er valt nog niets te exporteren (CLAUDE.md: niet
downloaden zonder noodzaak).
**Aflossing**: officiële templates van de 4.7.1-release installeren en het
export-preset + build-script in `tools/` opzetten (ROADMAP fase 6).

## TD-002 — Grafische presets zijn een eerste ruwe versie
**Datum**: 2026-07-27 · **Status**: Middel · **Aflosmoment**: fase 6 (Polish & Steam) — in taak 006 bewust níét opgepakt: presets uitbreiden met fog-/SSAO-kwaliteit is kalibratiewerk dat pas zin heeft mét beeld (dossier 006 §5)
**Waar**: game/autoload/settings_manager.gd (`PRESET_VALUES`, `_apply_graphics`)
**Schuld**: presets zetten alleen renderschaal, MSAA en schaduw-atlas; zaken
als SSAO/SSIL, volumetrische mist en licht-kwaliteit per preset bestaan nog
niet (die systemen bestaan zelf nog niet). Het release-default staat
bovendien nog op ontwikkelwaarde.
**Aflossing**: bij taak 006 de licht/omgevings-opties per preset uitbreiden;
in fase 6 de presets kalibreren op echte hardware en het release-default
(HIGH) vastzetten.

## TD-003 — Helderheid-instelling wordt opgeslagen maar nog nergens toegepast
**Datum**: 2026-07-27 · **Status**: ✅ afgelost in taak 006 (CHANGELOG v0.0.17)
**Waar**: game/autoload/settings_manager.gd (`brightness`)
**Schuld**: de instelling bestond (opslag + laden werkte) maar er was geen
WorldEnvironment-koppeling om hem op toe te passen.
**Afgelost door**: `set_brightness()` + `brightness_changed`-signaal in
SettingsManager (clamp 0.8–1.2, D-027) en de herbruikbare
`environment_tuner` op de WorldEnvironment van elk level, die de waarde
als `adjustment_brightness` toepast. Suite-tests dekken default, clamping
(setter én schijf) en het daadwerkelijke volgen van de environment.

## TD-004 — Bukken verlaagt alleen de camera, niet de collider
**Datum**: 2026-07-28 · **Status**: Laag · **Aflosmoment**: de eerste taak/level met een kruipruimte (verwacht: fase 3+, leveldesign hoofdstuk 2)
**Waar**: game/actors/player/player.gd (`_update_eye_height`)
**Schuld**: bukken beweegt de ooghoogte (1.70 → 1.15 m) en vertraagt de
speler, maar de capsule-collider blijft 1.8 m hoog — je kunt dus nog nergens
ónder door kruipen. Bewust: een kleinere collider vereist een
sta-op-controle (headroom-check tegen vastzitten in geometrie) en er bestaat
nog geen enkele plek waar kruipen iets betekent.
**Aflossing**: collider meeschalen bij bukken + headroom-raycast vóór het
opstaan, zodra een level een lage doorgang krijgt; dan ook een smoke-controle
"gebukt onder een obstakel door, rechtop geblokkeerd" toevoegen.

## TD-005 — Props bewegen instant: deur klapt om, la schuift zonder overgang
**Datum**: 2026-07-28 · **Status**: Laag · **Aflosmoment**: taak 005 (audio, dan krijgen interacties hun ritme) of de eerste sfeerpass (fase 2, taak 006)
**Waar**: game/props/door_wooden/door_wooden.gd (`interact`), game/props/drawer_cabinet/drawer_cabinet.gd (`interact`)
**Schuld**: deur en la wisselen hun stand in één physics-frame — bewust
buiten scope gehouden (opdracht 003: geen deuranimaties). Voor het
horrorgevoel is het tempo van een opengaande deur straks juist betekenis
(HORROR_GUIDELINES §3): een deur die traag opent ís de spanning.
**Aflossing**: korte tween/AnimationPlayer per prop zodra audio (005) het
ritme aangeeft; de contract-API verandert daarbij niet.

## TD-006 — Debug-prompt overbrugt het ontbreken van de echte HUD
**Datum**: 2026-07-28 · **Status**: Laag · **Aflosmoment**: **DebugPrompt wordt verwijderd zodra de eerste echte gameplay-HUD `EventBus.interact_prompt_changed` consumeert** (fase 2/4) — geen "ooit", maar die concrete taak
**Waar**: game/ui/debug_prompt/ + de spawn in game/bootstrap.gd (`_add_debug_tools`)
**Schuld**: op verzoek van de GD (visuele beoordeling taak 003) toont een
debug-label onderin beeld de interactieprompt. Strikt debug: alleen
debugbuilds, luistert uitsluitend naar `EventBus.interact_prompt_changed`,
geen eigen logica, toets dynamisch uit de InputMap.
**Aflossing**: in dezelfde taak waarin de echte HUD zich op dit signaal
abonneert: de map `game/ui/debug_prompt/` weggooien en de spawn-regels +
const uit de bootstrap halen (D-015-geverifieerd: zonder de map blijft
alles groen). Twee gelijktijdige consumenten van de prompt is de
waarschuwing dat dit moment is aangebroken.

## TD-007 — Clubgebouw-greybox leeft als datatabellen, niet als ruimte-scènes
**Datum**: 2026-07-28 · **Status**: Middel · **Aflosmoment**: VS-fase G (environment-artpass)
**Waar**: game/levels/clubgebouw/clubgebouw.gd (SCHIL/VLOEREN/PLAFONDS/BUITEN/INTERIEUR/MEUBELS)
**Schuld**: LEVEL §7 wil "ruimte = eigen scène"; de greybox bouwt de
volumes runtime uit const-tabellen (patroon dev_props). Bewust: in de
maatvoeringsfase is elke GD-correctie één getal, en de fase-E-gate kan
de hele plattegrond nog omgooien — scènes bouwen vóór die gate is werk
dat sneuvelt. De echte props (deuren, TL's) zijn al scène-instanties.
**Aflossing**: in fase G worden de goedgekeurde ruimtes omgezet naar
eigen scènes met echte meshes; de tabellen verdwijnen dan volledig.

## Afgeloste schuld

*Nog geen.*
