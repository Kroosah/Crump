# CRUMP — Sessiestatus

*Het startpunt van elke nieuwe sessie: waar staan we, wat is er net gebeurd,
wat is de volgende stap. **Bijwerken aan het eind van elke sessie** en na elke
afgeronde taak. Dit document is een momentopname — de bron van waarheid voor
regels en ontwerp blijven de andere docs.*

**Laatst bijgewerkt**: 2026-07-28

---

## 1. Laatste afgeronde taak

**Taak 002 — Player controller** ✅ gebouwd (v0.0.11) — **wacht op visuele
beoordeling door de Game Director** (het loopgevoel is headless niet te
toetsen; zie het beoordelingslijstje in `tasks/002_player_controller.md`).

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
| Taak 002 — Player controller | ✅ gebouwd, **visuele beoordeling open** |
| Taak 003 — Interactiesysteem | ⬜ volgende (na akkoord op 002) |
| Taken 004–008 | ⬜ open |

**Technische staat**: `godot --headless --path . --import` schoon (exit 0),
smoke-suite **75/75 groen** (exit 0). Verwijderbaarheidstest D-015: zonder
`game/actors/player/` blijft de suite 52/52 groen en springt de testcamera
bij. `config/version` gelijkgetrokken naar 0.0.11 (liep achter op 0.0.4).

**Nog niet visueel beoordeeld**: het complete loopgevoel van taak 002
(traagheid, head-bob, muisgevoeligheid, bukovergang — lijstje in het
taakdossier), de debug overlay (F3) en de pauze (Esc, geeft nu ook de muis
vrij).

**Omgeving**: Godot 4.7.1 headless op de bouw-VPS
(`/opt/godot/godot-4.7.1`, symlink `/usr/local/bin/godot`). Projectpad:
`/home/kroosah/projects/crump`.

## 5. Volgende taak

**Eerst**: Game Director beoordeelt taak 002 in de editor (F5 in de dev
room; het lijstje staat onderaan `tasks/002_player_controller.md`).
Tuning-feedback gaat via de export-groepen op de Player-node — waarden
aanpassen is geen code-wijziging.

**Daarna, op startsein**: **Taak 003 — Interactiesysteem**
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
