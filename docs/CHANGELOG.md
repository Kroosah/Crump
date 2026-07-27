# CRUMP — Changelog

*Elke afgeronde taak of betekenisvolle wijziging krijgt een versienummer en
een korte omschrijving. Nieuwste bovenaan. **Verplicht bijwerken** bij elke
taak (zie CLAUDE.md).*

**Versienummering**: `v0.0.x` tijdens de fundering; `v0.x.0` per afgeronde
roadmap-fase; `v1.0.0` = release. Het nummer zegt niets over kwaliteit, alleen
over volgorde — het doel is dat je maanden later kunt terugvinden wanneer
iets veranderde en in welke commit.

---

## v0.0.3 — 2026-07-27
**Studio-administratie toegevoegd**
- DECISIONS.md, CHANGELOG.md, KNOWN_ISSUES.md en TECH_DEBT.md aangemaakt en
  verankerd in README en CLAUDE.md (verplicht onderdeel van elke taak).
- Nieuwe vaste regel: na elke taak beantwoordt de Lead Developer de vier
  rapportagevragen (wat gebouwd / waarom zo / risico's / advies volgende taak).
- Scope van taak 001 uitgebreid op aanwijzing van de Game Director
  (bootstrap, developer room, logging, debug overlay, game lifecycle,
  instellingen).

## v0.0.2 — 2026-07-27
**Visie herzien: naamloze hoofdpersoon, voetbalclub-opening, CRUMP als mysterie**
- STORY.md volledig herschreven (opening VV Drechtstreek / Sportpark
  Oostpolder, verdwijning uit de kantine, canonieke beats).
- CRUMP nergens meer locatie/club: het is het mysterie en de latere dreiging.
- Harde regel "eerste 15 minuten" toegevoegd (HORROR_GUIDELINES §5a).
- Rolverdeling + tien ontwikkelregels vastgelegd in CLAUDE.md.
- Projectmap hernoemd: `nachtdienst` → `crump`.
- Commits: `dd76e69`, `90bee25`.

## v0.0.1 — 2026-07-27
**Project gestart (fase 0: fundering)**
- Repository, mappenstructuur en volledige documentatieset aangemaakt
  (README, CLAUDE, game bible, story, architecture, roadmap, coding
  standards, horror/level guidelines, QA-checklist).
- Acht taakdossiers (001–008) uitgewerkt.
- Godot 4.7.1 headless geïnstalleerd en geverifieerd op de bouw-VPS.
- Commit: `adcc2ec`.
