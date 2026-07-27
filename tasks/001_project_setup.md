# Taak 001 — Project-setup & bootstrap

**Fase**: 1 (De wandeling) · **Status**: ⬜ open · **Vereist**: —

De technische geboorte van het Godot-project: van lege repo naar een
importeerbaar, getest, correct geconfigureerd project **met een werkende
applicatie-ruggengraat**. Vanaf deze taak is CRUMP een echte game en niet
alleen een concept. Nog steeds **geen gameplay** — wel het fundament waarin
gameplay kan bestaan.

*Scope uitgebreid op 2026-07-27 door de Game Director: naast de kale
projectconfiguratie ook bootstrap, developer room, logging, debug overlay,
game lifecycle en instellingen.*

## Doel

Een `project.godot` en bijbehorende configuratie die de afspraken uit
`ARCHITECTURE.md` en `CODING_STANDARDS.md` vastleggen, plus de
applicatie-ruggengraat: het spel start op, doorloopt een nette lifecycle,
logt wat het doet, heeft een debug overlay en bewaart instellingen — en er
is een developer room om in te bestaan.

## Scope

**A. Projectconfiguratie**
- `project.godot` (naam "CRUMP", Kroosah Interactive, Godot 4.7, Forward+).
- **Input-map**: `move_forward/back/left/right`, `sneak`, `run`, `crouch`,
  `interact`, `flashlight`, `pause`, `debug_overlay`.
- **Audiobussen**: `Master → SFX, Ambience, Music, Voice`.
- **Physics-layers** benoemd: o.a. `world`, `player`, `monster`,
  `interactable`, `sound_blocker`.
- **`.gitignore`** was er al; verifiëren dat `.godot/` en `builds/` buiten
  git blijven zodra ze ontstaan.

**B. Autoload-skelet** (contract uit ARCHITECTURE §4, nog geen implementatie
   voorbij het contract)
- `EventBus` — kernsignalen gedeclareerd (o.a. `noise_made`).
- `GameState` — hoofdstuk/vlaggen-struct, serialiseerbaar.
- `AudioDirector` — busbeheer-API (leeg maar aanroepbaar).
- `SaveManager` — save/load-API (leeg maar aanroepbaar).

**C. Bootstrap & game lifecycle**
- **Hoofdscène `game/bootstrap.tscn`**: het startpunt dat autoloads
  verifieert, instellingen laadt en doorschakelt naar de gewenste scène.
- **Lifecycle-toestanden**: opstarten → (voorlopig) developer room → nette
  afsluiting (pause/quit-afhandeling; `pause`-input werkt).
- Ontworpen om later het hoofdmenu tussen bootstrap en spel te schuiven
  zonder verbouwing.

**D. Developer room**
- `game/levels/dev_room/dev_room.tscn`: grijze blokkendoos met vloer, muren,
  wat obstakels op menselijke maat en één lichtbron — de vaste testruimte
  voor taken 002–007 (LEVEL_GUIDELINES §7: blockout-standaard).
- Nog geen speler (taak 002); de room bestaat en laadt via de bootstrap.

**E. Logging**
- Klein `Log`-hulpsysteem (`game/systems/`): niveaus (debug/info/warn/error),
  timestamp, naar console én `user://logs/` met rotatie. In release-builds
  staat debug-niveau uit.
- Vervangt losse `print()`-statements (CODING_STANDARDS §3.6) vanaf nu.

**F. Debug overlay**
- Toggle via `debug_overlay`-input: fps, frametijd, scène-naam,
  Godot-versie, aantal actieve geluiden (haak, vult later), spelerspositie
  (haak, vult in 002).
- Alleen aanwezig in debugbuilds; kost niets als hij uit staat.

**G. Instellingen**
- `Settings`-laag (onder `GameState` of als lichte eigen module — keuze
  documenteren in DECISIONS): busvolumes, muisgevoeligheid, head-bob,
  helderheid; laden/opslaan naar `user://settings.cfg`.
- Nog geen opties-UI (dat is later UI-werk); wél de werkende onderlaag met
  defaults.

**H. Tests**
- Testrunner-keuze definitief (voorstel: ingebouwde runner; vastleggen in
  DECISIONS).
- Smoke-tests: project importeert schoon; autoloads laden; bootstrap
  bereikt de dev room headless; settings save→load round-trip; log-bestand
  wordt geschreven.

**Niet:**
- Geen speler, geen interactie, geen gameplay-mechanieken (taken 002+).
- Geen hoofdmenu-UI, geen opties-UI (alleen de instellingen-onderlaag).
- Geen assets; de dev room is grijs.
- Geen export-templates (TECH_DEBT TD-001).

## Aanpak

1. `project.godot` + settings opbouwen (tekstueel, leesbaar in git);
   valideren met `godot --headless --path . --import`.
2. Autoload-skeletten met contracten en docstrings.
3. Bootstrap-scène + lifecycle; daarna de dev room en de doorschakeling.
4. `Log`-systeem, dan de debug overlay (die meteen via `Log` rapporteert).
5. Settings-laag met round-trip-test.
6. Smoke-tests; alles headless groen.
7. Commits per blok (`[001] ...`); studio-administratie bijwerken
   (CHANGELOG-entry, D-entries voor testrunner- en settings-keuze, eventuele
   TD-entries); afsluiten met het vier-vragen-rapport.

## Acceptatiecriteria

- [ ] `godot --headless --path . --import` draait schoon (exitcode 0).
- [ ] Headless run van de bootstrap bereikt de dev room zonder errors.
- [ ] Alle vier autoloads laden; kernsignalen bestaan met juiste signatuur.
- [ ] Input-map, bussen en physics-layers bestaan met de afgesproken namen.
- [ ] `Log` schrijft naar console + bestand met rotatie; geen kale `print()`.
- [ ] Debug overlay toggle't en toont fps/frametijd/scène (editor-check GD).
- [ ] Settings: wijzig → opslaan → herstart → geladen (round-trip-test groen).
- [ ] Pause/quit-afhandeling werkt netjes (geen abrupt proces-einde).
- [ ] `.godot/` en `builds/` verschijnen niet in git.
- [ ] Alle smoke-tests groen; README-statustabel, dit dossier en de
      studio-administratie bijgewerkt; vier-vragen-rapport geleverd.

## Te beoordelen in de editor (VPS kan dit niet)

De debug overlay en de dev room zelf (maten, leesbaarheid) zijn visueel;
lever met een korte instructie wat de Game Director moet controleren.
