# Taak 001 — Project-setup

**Fase**: 1 (De wandeling) · **Status**: ⬜ open · **Vereist**: —

De technische geboorte van het Godot-project: van lege repo naar een
importeerbaar, getest, correct geconfigureerd project waarop de rest bouwt.
Nog steeds **geen gameplay** — alleen het fundament in de engine.

## Doel

Een `project.godot` en bijbehorende configuratie die de afspraken uit
`ARCHITECTURE.md` en `CODING_STANDARDS.md` in de praktijk vastleggen, zodat
elke volgende taak in een correcte omgeving begint.

## Scope

**Wel:**
- `project.godot` aanmaken (naam "CRUMP", org Kroosah Interactive, Godot 4.7).
- Renderer op **Forward+** zetten (ARCHITECTURE §2).
- **Input-map** definiëren: `move_forward/back/left/right`, `sneak`, `run`,
  `crouch`, `interact`, `flashlight`, `pause`. Namen conform CODING_STANDARDS.
- **Audiobussen** aanmaken: `Master → SFX, Ambience, Music, Voice`
  (AudioDirector bouwt hierop in taak 005).
- **Physics-layers** benoemen (o.a. `world`, `player`, `monster`,
  `interactable`, `sound_blocker`) i.p.v. kale nummers.
- **Autoload-skelet** registreren: lege maar geldige `EventBus`, `GameState`,
  `AudioDirector`, `SaveManager` (alleen `class_name` + docstring + de
  signalen/velden die het contract in ARCHITECTURE §4 vastlegt — nog geen
  implementatie).
- **`.gitignore`** voor Godot 4 (`.godot/`, `builds/`, `*.tmp`, editor-
  metadata, export-presets met secrets).
- **Test-fundament** in `tests/`: keuze tussen GUT en Godot's ingebouwde
  test-runner definitief maken en de eerste **import-smoke-test** opzetten.
- **Eerste commit** met de volledige projectbasis.

**Niet:**
- Geen speler, geen scènes met gameplay, geen assets.
- Geen export-templates downloaden.

## Aanpak

1. Genereer `project.godot` headless of met een minimale editor-run; verifieer
   met `godot --headless --path . --import`.
2. Voeg de input-map, bussen, layers en autoloads toe via de project-settings
   (in het tekstbestand, zodat het in git leesbaar is).
3. Autoload-scripts als dunne skeletten: `EventBus` declareert de kernsignalen
   uit ARCHITECTURE §4 (nog zonder emitters), de rest krijgt een docstring en
   de datavelden die het contract noemt.
4. Zet de test-runner op en schrijf de import-smoke-test.
5. Commit: `[001] Zet Godot-projectbasis op (settings, autoloads, tests)`.

## Acceptatiecriteria

- [ ] `godot --headless --path . --import` draait schoon (exitcode 0).
- [ ] Alle vier autoloads laden zonder error (autoload-test groen).
- [ ] Input-map, bussen en physics-layers bestaan met de afgesproken namen.
- [ ] `.gitignore` sluit `.godot/` en `builds/` uit; die staan niet in git.
- [ ] Import-smoke-test draait en slaagt.
- [ ] README-statustabel en dit dossier bijgewerkt.

## Openstaande beslissingen

- Testframework: **GUT** (rijker, community-standaard) vs. **ingebouwde
  test-runner** (nul dependencies). Voorstel: ingebouwd starten, GUT pas als
  we het echt nodig hebben — leg de keuze hier vast bij uitvoering.
