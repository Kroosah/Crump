# CRUMP — Sessiestatus

*Het startpunt van elke nieuwe sessie: waar staan we, wat is er net gebeurd,
wat is de volgende stap. **Bijwerken aan het eind van elke sessie** en na elke
afgeronde taak. Dit document is een momentopname — de bron van waarheid voor
regels en ontwerp blijven de andere docs.*

**Laatst bijgewerkt**: 2026-07-28 (na KI-003-fix, v0.0.12)

---

## 1. Laatste afgeronde taak

**Taak 002 — Player controller** ✅ (v0.0.11 + KI-003-fix in v0.0.12,
**goedgekeurd door de Game Director op 2026-07-28** na lokale test: WASD,
muislook, sprint, sluipen, bukken, F3 én de Esc-pauze werken).

Opgeleverd: `game/actors/player/` met vier gangmodi (lopen/sluipen/rennen/
bukken, prioriteit bukken > sluipen > rennen), acceleratie/deceleratie,
muis-look zonder versnelling, uitschakelbare head-bob, buk-ooghoogte en
voetstap-events op de EventBus (luidheid per modus: 2/2.5/6/14 m). Spawn via
`PlayerSpawn`-marker (D-018); ren-consequentie is geluid, geen stamina
(D-019). Smoke-suite van 52 → 75 controles met echte input-simulatie;
verwijderbaarheidstest in beide richtingen geverifieerd.

Daarvóór (2026-07-27): taak 001 volledig afgerond en goedgekeurd (52/52),
KI-001 en KI-002 gesloten.

## 2. Laatste commit

```
[002] Bouw player controller met gangmodi en voetstap-events
```

Werkmap schoon; `main` gepusht naar `origin/main`.

## 3. GitHub-status

- **Remote**: `origin` → `git@github.com:Kroosah/Crump.git` (privé, SSH)
- **Branch**: `main`, met upstream-tracking naar `origin/main`
- **Synchroon**: alle commits gepusht (`git status` schoon, geen ahead/behind)
- **Authenticatie**: deploy key met schrijfrechten (`crump-deploy@VPS-Focus`),
  privésleutel `/root/.ssh/id_ed25519_github`, ssh-config-entry voor github.com
- **GitHub is de officiële bron van waarheid**: elke afgeronde taak wordt
  gecommit én gepusht.

## 4. Huidige projectstatus

| Onderdeel | Status |
|---|---|
| Fase 0 — Fundering (structuur + documentatie) | ✅ afgerond |
| Taak 001 — Project-setup & bootstrap | ✅ afgerond en goedgekeurd |
| Taak 002 — Player controller | ✅ afgerond en goedgekeurd |
| Taak 003 — Interactiesysteem | ⬜ **volgende** (wacht op startsein) |
| Taken 004–008 | ⬜ open |

**Technische staat**: `godot --headless --path . --import` schoon (exit 0),
smoke-suite **81/81 groen** (exit 0). Verwijderbaarheidstest D-015: zonder
`game/actors/player/` blijft de suite 54/54 groen en springt de testcamera
bij. `config/version` = 0.0.12.

**Visueel beoordeeld door de GD (2026-07-28)**: alles werkt — WASD, muislook,
sprint, sluipen, bukken, F3-overlay én (na de KI-003-fix, door de GD
herbevestigd) de Esc-pauze met muis-vrijgave en hervatten.

**Omgeving**: Godot 4.7.1 headless op de bouw-VPS
(`/opt/godot/godot-4.7.1`, symlink `/usr/local/bin/godot`). Projectpad:
`/home/kroosah/projects/crump`.

## 5. Volgende taak

**Op startsein van de Game Director**: **Taak 003 — Interactiesysteem**
(`tasks/003_interaction_system.md`): raycast vanaf de spelerscamera, het
`Interactable`-contract in `game/systems/`, en de interactieprompt via
`EventBus.interact_prompt_changed`. De haak ervoor bestaat al (input-actie
`interact`, het EventBus-signaal, en de spelerscamera als raycast-oorsprong).

## 6. Open aandachtspunten

- **TD-004** (Laag, nieuw): bukken verkleint de collider niet — kruipruimtes
  bestaan nog niet; aflossen zodra een level er een krijgt.
- **TD-002** (Middel): grafische presets eerste ruwe versie; release-default
  op ontwikkelwaarde. Aflossen bij taak 006/fase 6.
- **TD-003** (Laag): `brightness` opgeslagen maar nog niet toegepast —
  koppelen in taak 006 (licht & sfeer).
- **KNOWN_ISSUES**: geen open issues.
- **Export-templates** (TD-001) bewust niet geïnstalleerd (~1 GB) — pas
  nodig bij de eerste echte export.
- **Verwijderbaarheidstest** (D-015) blijft onderdeel van elke taak; voor de
  speler is hij tweezijdig geborgd (bootstrap-bestaanscheck + conditionele
  spelertests in de suite).
- **Pushen vanaf de VPS** kan door de auto-mode-classifier haperen; de kale
  vorm `git push -u origin main` (zonder pipes) werkte.
- **Openstaande ontwerpsessie**: wát CRUMP is (aard, vorm, verklaring van de
  verdwijning) — zie `STORY.md` §8. Nodig vóór hoofdstuk 3/4, niet vóór
  taak 003.
