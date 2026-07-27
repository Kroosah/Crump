# CRUMP — Technische Architectuur

*Hoe de codebase in elkaar zit en waarom. Nieuwe systemen volgen dit document;
afwijken mag alleen met een goede reden die hier vervolgens wordt vastgelegd.*

---

## 1. Uitgangspunten

1. **Eenvoud wint.** Een horrorgame van deze omvang heeft geen framework op
   een framework nodig. We bouwen het simpelste dat het ontwerp draagt.
2. **Systemen, geen spaghetti.** Gedrag zit in herbruikbare systemen
   (`game/systems/`), niet in scène-scripts die alles aan elkaar knopen.
3. **Data boven hardcode.** Afstembare waarden (loopsnelheid, gehoor-radius,
   volumes) leven in `@export`-variabelen of Resources, zodat tunen geen
   code-wijziging is.
4. **Ontkoppeld via signalen en events.** Systemen kennen elkaar zo min
   mogelijk; communicatie loopt via Godot-signalen en een centrale event-bus.
5. **Alles is tekst.** Scènes (`.tscn`), resources (`.tres`) en scripts
   (`.gd`) blijven tekstbestanden → leesbare diffs, bruikbare code-reviews.
6. **Elke feature is verwijderbaar.** Ieder gameplay-systeem moet volledig
   uit het project te halen zijn zonder dat de rest breekt (D-015).
   Praktisch: systemen kennen elkaar niet rechtstreeks — ze publiceren en
   consumeren signalen op de EventBus. Een ontbrekende ontvanger is nooit
   een fout; een ontbrekende zender betekent alleen dat het signaal nooit
   komt. Verwijder je een systeem, dan verdwijnen zijn map, zijn signalen-
   abonnementen en zijn scène-instanties — en niets anders merkt het.

## 2. Engine en versie

- **Godot 4.7.1 stable, official build.** Vast tot na release van
  hoofdstuk 1; engine-upgrades zijn een bewuste, geteste beslissing (aparte
  branch, volledige QA-ronde), nooit een bijzaak.
- **Renderer: Forward+** (desktop-doelgroep, dynamisch licht is de kern van
  het spel). Windows-export via de officiële export-templates.
- **GDScript** als taal. Geen C# — één taal houdt de drempel laag, GDScript
  is ruim snel genoeg voor dit genre, en de AI-gedragslogica is niet
  rekenintensief. Mocht een hotspot ontstaan, dan is een gerichte
  GDExtension een optie — pas als profiling dat bewijst.

## 3. Mappenstructuur en eigenaarschap

```
game/
├── autoload/    # Singletons — zo min mogelijk, elk met één taak
├── actors/      # Alles wat "leeft": speler, CRUMP (elk in eigen submap)
├── systems/     # Interactie, inventory, saves, events (scene-onafhankelijk)
├── levels/      # Hoofdstukken; elke ruimte een eigen scène
├── props/       # Interacteerbare objecten, herbruikbaar over levels
└── ui/          # HUD, menu's, ondertitels, leesbare documenten
```

Regels:

- **Een scène + haar script + haar lokale resources horen bij elkaar** in
  dezelfde map (`game/actors/player/player.tscn` + `player.gd` +
  `player_footsteps.tres`).
- `assets/` bevat **bronmateriaal** (audio, modellen, textures, ui,
  branding); `game/` bevat **samenstellingen** (scènes die assets
  gebruiken). Assets weten niets van scènes.
- `assets/concept_art/` en `assets/reference/` zijn **studiomateriaal**
  (schetsen, moodboards, referentiefoto's): ze horen in de repo maar nooit
  in de game-build — bij het opzetten van de export-presets (fase 6) worden
  ze expliciet uitgesloten.
- Gedeeld gedrag → `game/systems/`. Iets dat maar in één level bestaat →
  bij dat level.

## 4. Autoloads (bewust maar vijf — zie D-011)

| Autoload | Verantwoordelijkheid |
|---|---|
| `EventBus` | Centrale signalen tussen systemen (`noise_made(position, loudness)`, `chapter_started`, `player_spotted`, ...). Geen logica, alleen doorgeefluik. |
| `GameState` | Spelvoortgang: hoofdstuk, vlaggen, gelezen documenten. Serialiseerbaar voor saves. |
| `AudioDirector` | Mixgroepen, ambience-lagen, muziek-cues, ducking. Het enige systeem dat rechtstreeks met audio-bussen praat. |
| `SettingsManager` | Gebruikersinstellingen (volumes, gevoeligheid, comfort, grafische presets) — los van de spelsessie; laadt/bewaart `user://settings.cfg`. |
| `SaveManager` | Checkpoints, laden/opslaan van `GameState`, save-bestandsversies. |

Daarnaast bestaat `Log` (game/systems/log.gd) als **statische klasse** —
bewust geen autoload (D-012).

Waarom zo weinig: elke autoload is globale staat, en globale staat is waar
onderhoudbaarheid sterft. Nieuw autoload-voorstel = architectuurbeslissing.

**De event-bus is dun.** Signalen erop zijn feiten ("er is een geluid gemaakt
op positie X met luidheid Y"), geen commando's ("CRUMP, ga naar X"). Wie er
wat mee doet, beslist de ontvanger. Dit houdt CRUMP testbaar zonder
speler, en de speler testbaar zonder CRUMP.

## 4a. Modulariteit: de verwijderbaarheidstest

*Vastgelegd als D-015 op verzoek van de Game Director. Dit is een **harde
eis**, geen streven — elke taak wordt eraan getoetst.*

**De test**: gooi de map van één gameplay-systeem weg (bijv.
`game/actors/monster/`), draai `godot --headless --path . --import` en de
smoke-suite. Blijft alles groen en start het spel? Dan is de module goed
ontkoppeld. Zo niet, dan zit er een verboden afhankelijkheid.

**Regels die dat garanderen:**

1. **Gameplay-systemen kennen elkaar niet.** Geen `get_node("/root/...")`
   naar een ander systeem, geen `preload()` van een andere systeem-scène,
   geen class-verwijzing over systeemgrenzen heen. Communicatie loopt via
   de EventBus of via een expliciet contract (`Interactable`).
2. **Signalen zijn feiten, geen commando's** (§4). Een zender heeft nooit
   een ontvanger nodig: `noise_made` uitzenden werkt ook zonder monster.
   Een ontvanger zonder zender wacht simpelweg eeuwig — geen fout.
3. **Autoloads zijn infrastructuur, geen gameplay.** EventBus, GameState,
   AudioDirector, SettingsManager en SaveManager bevatten nooit
   feature-specifieke logica; ze weten niet wat een monster of een
   inventory is. Daarom overleven ze het verwijderen van elke feature.
4. **Optioneel opzoeken, nooit hard aannemen.** Heb je toch een verwijzing
   nodig (bv. de debug overlay die de spelerspositie toont), gebruik dan
   `get_first_node_in_group()` / `get_node_or_null()` en handel `null`
   netjes af — precies zoals de overlay nu doet (toont "—" zonder speler).
5. **Één map per feature.** Alles wat bij een systeem hoort (scène, script,
   resources, tests) staat bij elkaar, zodat "verwijderen" letterlijk één
   map weggooien is. Gedeelde onderdelen horen in `game/systems/`.
6. **Registratie boven bedrading.** Levels bezitten hun eigen inhoud; de
   bootstrap laadt een level en weet verder niets van wat erin zit.

**Toegestane koppelingen** (de enige uitzonderingen):
autoloads (infrastructuur), `Log`, gedeelde contracten in `game/systems/`,
en de Godot-API zelf.

## 5. Kernsystemen (ontwerp op hoofdlijnen)

Details per systeem staan in het bijbehorende taakdossier; dit is het contract
ertussen.

### 5.1 Interactie (`tasks/003`)
- Speler cast een ray vanaf de camera; objecten implementeren het
  `Interactable`-contract (klasse met `kan_interactie()`, `interactie()`,
  `prompt_tekst()`).
- Props zenden hun effect via signalen; een deur weet niet wie hem opent.

### 5.2 Inventory (`tasks/004`)
- Klein en diegetisch (geen grid van 40 slots): een handvol items, gedefinieerd
  als `ItemResource` (.tres) met id, naam, beschrijving, icoon en vlaggen.
- Items zijn data; effecten van gebruik lopen via de event-bus.

### 5.3 Geluid als gameplay (`tasks/005`)
- Elke luide actie publiceert `geluid_gemaakt(positie, luidheid)` op de bus.
- CRUMP **abonneert** zich daarop; er is geen directe koppeling
  speler→CRUMP. Hierdoor is "hoorbaarheid" één systeem voor deuren,
  voetstappen, vallende objecten.

### 5.4 Monster-AI (`tasks/007`)
- Eindige-toestandsmachine (patrouille / onderzoeken / achtervolgen /
  verliezen), navigatie via NavigationServer, waarneming = gehoor (event-bus)
  + zicht (cone + line-of-sight).
- Volledig data-gedreven af te stemmen (radii, tijden, snelheden in exports).

### 5.5 Levels (`tasks/008`, richtlijnen in `LEVEL_GUIDELINES.md`)
- Elke ruimte een eigen scène; hoofdstuk-scène stitcht ruimtes en bezit de
  triggers. Toestand van een ruimte (welke deur open) leeft in `GameState`,
  niet in de scène — nodig voor saves én voor "het gebouw is 's nachts
  veranderd"-momenten.

## 6. Save-systeem

- Saves zijn JSON met een versienummer (`save_version`), weggeschreven via
  `SaveManager` naar `user://`.
- Alleen `GameState` wordt geserialiseerd; scènes herstellen zichzelf uit die
  staat. Nooit hele scene-trees dumpen (onhoudbaar bij elke scène-wijziging).
- Elke wijziging aan het save-formaat verhoogt `save_version` en krijgt een
  migratiefunctie. Vanaf de eerste externe playtest zijn saves heilig.

## 7. Performance-kaders

- Doel: 60 fps op een mid-range gaming-pc uit ~2020 (GTX 1060-klasse) op
  1080p. Horror met haperingen is geen horror.
- Licht is het duurste onderdeel van dit spel: budget per ruimte wordt in
  `LEVEL_GUIDELINES.md` vastgelegd (aantal realtime schaduwlichten beperkt).
- Meten vóór optimaliseren: Godot-profiler, en pas ingrijpen bij bewezen
  hotspots.

## 8. Tests en validatie

- **Headless smoke-tests** in `tests/`: project importeert schoon, hoofdscènes
  instantiëren zonder errors, save→load round-trip behoudt staat.
- Systemen met logica (inventory, state machine, save-migraties) krijgen
  unit-tests zodra ze bestaan; het framework (GUT of Godot's ingebouwde
  test-runner) wordt bij taak 001 definitief gekozen.
- Op de VPS draait alles headless (zie `CLAUDE.md`); visuele checks gebeuren
  in de editor op de ontwikkelmachine.

## 9. Versiebeheer

- Git, branch `main` is altijd importeerbaar (geen kapotte scènes op main).
- `.godot/`, `builds/` en editor-metadata staan in `.gitignore`.
- Grote binaire assets: zolang het project klein is gewoon in git; groeit
  `assets/` boven ~500 MB, dan stappen we op **git-lfs** over (beslismoment
  vastgelegd in ROADMAP fase 2).

## 10. Wat we bewust níet bouwen

- ❌ Eigen ECS, eigen scripting-laag, of "engine boven de engine" — Godot's
  nodes en signalen zíjn het framework.
- ❌ Multiplayer-voorbereidingen. CRUMP is singleplayer; elke networking-hook
  is dood gewicht.
- ❌ Generieke "asset-pipelines" voordat er assets zijn.
- ❌ Abstractielagen voor "misschien ooit een andere engine". Nee.
