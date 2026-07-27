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
├── actors/      # Alles wat "leeft": speler, monster (elk in eigen submap)
├── systems/     # Interactie, inventory, saves, events (scene-onafhankelijk)
├── levels/      # Hoofdstukken; elke ruimte een eigen scène
├── props/       # Interacteerbare objecten, herbruikbaar over levels
└── ui/          # HUD, menu's, ondertitels, leesbare documenten
```

Regels:

- **Een scène + haar script + haar lokale resources horen bij elkaar** in
  dezelfde map (`game/actors/player/player.tscn` + `player.gd` +
  `player_footsteps.tres`).
- `assets/` bevat **bronmateriaal** (audio, modellen, textures); `game/`
  bevat **samenstellingen** (scènes die assets gebruiken). Assets weten
  niets van scènes.
- Gedeeld gedrag → `game/systems/`. Iets dat maar in één level bestaat →
  bij dat level.

## 4. Autoloads (bewust maar vier)

| Autoload | Verantwoordelijkheid |
|---|---|
| `EventBus` | Centrale signalen tussen systemen (`speler_gezien`, `hoofdstuk_gestart`, `geluid_gemaakt(positie, luidheid)`). Geen logica, alleen doorgeefluik. |
| `GameState` | Spelvoortgang: hoofdstuk, vlaggen, gelezen documenten. Serialiseerbaar voor saves. |
| `AudioDirector` | Mixgroepen, ambience-lagen, muziek-cues, ducking. Het enige systeem dat rechtstreeks met audio-bussen praat. |
| `SaveManager` | Checkpoints, laden/opslaan van `GameState`, save-bestandsversies. |

Waarom zo weinig: elke autoload is globale staat, en globale staat is waar
onderhoudbaarheid sterft. Nieuw autoload-voorstel = architectuurbeslissing.

**De event-bus is dun.** Signalen erop zijn feiten ("er is een geluid gemaakt
op positie X met luidheid Y"), geen commando's ("monster, ga naar X"). Wie er
wat mee doet, beslist de ontvanger. Dit houdt het monster testbaar zonder
speler, en de speler testbaar zonder monster.

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
- Het monster **abonneert** zich daarop; er is geen directe koppeling
  speler→monster. Hierdoor is "hoorbaarheid" één systeem voor deuren,
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
