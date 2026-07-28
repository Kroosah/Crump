# CRUMP

**First person psychological horror** · Godot 4.7 · Windows (later Steam)

Een game van **Kroosah Interactive**.

---

## Wat is CRUMP?

CRUMP is een first person psychological horror-game waarin spanning wordt
opgebouwd door sfeer, geluid en onzekerheid, niet door goedkope jumpscares.
De speler is kwetsbaar, de omgeving vertelt het verhaal, en wat je *niet*
ziet is enger dan wat je wel ziet.

De volledige visie staat in [docs/GAME_BIBLE.md](docs/GAME_BIBLE.md).

## Projectstatus

| Fase | Status |
|---|---|
| Fundering (structuur, documentatie) | ✅ afgerond |
| Project-setup in Godot | ✅ [tasks/001](tasks/001_project_setup.md) |
| Player controller | ✅ [tasks/002](tasks/002_player_controller.md) |
| Interactiesysteem | ✅ [tasks/003](tasks/003_interaction_system.md) |
| Inventory | ✅ [tasks/004](tasks/004_inventory.md) |
| Audio-fundament | ✅ [tasks/005](tasks/005_audio.md) |
| Licht & sfeer | ✅ [tasks/006](tasks/006_lighting.md) |
| Minimale documentlezer | ✅ [tasks/007](tasks/007_document_reader.md) |
| Vertical Slice 01 "De vergeten tas" | 🟡 fase C (greybox) gebouwd, wacht op GD-test — [tasks/008](tasks/008_vertical_slice_01.md) |
| Monster-AI | ⬜ [tasks/009](tasks/009_monster_ai.md) |
| Hoofdstuk 1 | ⬜ [tasks/010](tasks/010_chapter1.md) |

De actuele planning staat in [docs/ROADMAP.md](docs/ROADMAP.md).

## Snel starten

```bash
# Project openen in de Godot-editor (lokale machine):
godot --path . -e

# Headless importeren/valideren (VPS/CI):
godot --headless --path . --import
```

Vereisten: **Godot 4.7.1** (official build). Geen extra dependencies.

## Mappenstructuur

```
crump/
├── game/            # Alle scènes en scripts (de daadwerkelijke game)
│   ├── autoload/    # Singletons (GameState, AudioDirector, ...)
│   ├── actors/      # Speler, CRUMP (de dreiging)
│   ├── systems/     # Herbruikbare systemen (interactie, inventory, saves)
│   ├── levels/      # Hoofdstukken en ruimtes
│   ├── props/       # Interacteerbare objecten (deuren, laden, items)
│   └── ui/          # Menu's, HUD, ondertitels
├── assets/          # Bronbestanden: audio, modellen, textures, shaders,
│                    # ui, branding, concept_art, reference
├── addons/          # Third-party plugins (met bronvermelding + licentie)
├── docs/            # Alle ontwerpen en richtlijnen (start hier!)
├── tasks/           # Uitgewerkte taakdossiers per bouwsteen
├── tests/           # GUT-tests / smoke-tests
├── tools/           # Hulpscripts (export, asset-checks)
├── localization/    # Vertaalbestanden (nl als bron, en volgt)
└── builds/          # Export-output (staat in .gitignore)
```

Waarom deze indeling: zie [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Documentatie

| Document | Inhoud |
|---|---|
| [GAME_BIBLE.md](docs/GAME_BIBLE.md) | Wat CRUMP is: visie, pijlers, toon, speler-fantasie |
| [STORY.md](docs/STORY.md) | Verhaal, setting, personages, hoofdstukindeling |
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | Technische architectuur en de redenen erachter |
| [ROADMAP.md](docs/ROADMAP.md) | Fasering van prototype tot Steam-release |
| [CODING_STANDARDS.md](docs/CODING_STANDARDS.md) | GDScript-stijl, naamgeving, scene-conventies |
| [HORROR_GUIDELINES.md](docs/HORROR_GUIDELINES.md) | Wat maakt CRUMP eng, en wat doen we bewust niet |
| [LEVEL_GUIDELINES.md](docs/LEVEL_GUIDELINES.md) | Hoe een CRUMP-ruimte ontworpen wordt |
| [QA_CHECKLIST.md](docs/QA_CHECKLIST.md) | Wat er getest wordt vóór iets "af" heet |

**Studio-administratie** (levend, verplicht bijgewerkt bij elke taak):

| Document | Inhoud |
|---|---|
| [DECISIONS.md](docs/DECISIONS.md) | Beslissingenlogboek: wat, waarom, alternatief |
| [CHANGELOG.md](docs/CHANGELOG.md) | Versiegeschiedenis per taak/wijziging |
| [KNOWN_ISSUES.md](docs/KNOWN_ISSUES.md) | Bekende bugs en beperkingen, met ernst en status |
| [TECH_DEBT.md](docs/TECH_DEBT.md) | Bewuste tijdelijke oplossingen, met aflosmoment |

## Werkwijze

- Elke bouwsteen heeft een dossier in `tasks/` met doel, aanpak en acceptatiecriteria.
- Er wordt pas aan een taak gebouwd als het dossier gelezen is.
- Elke wijziging wordt gecommit met een duidelijke boodschap (zie CODING_STANDARDS).
- Na elke taak: studio-administratie bijwerken (DECISIONS/CHANGELOG/
  KNOWN_ISSUES/TECH_DEBT) en het vier-vragen-rapport (zie CLAUDE.md).
- AI-assistentie (Claude Code) werkt volgens de afspraken in [CLAUDE.md](CLAUDE.md).

---

© Kroosah Interactive. Alle rechten voorbehouden.
