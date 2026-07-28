# CRUMP — Sessiestatus

*Het startpunt van elke nieuwe sessie: waar staan we, wat is er net gebeurd,
wat is de volgende stap. **Bijwerken aan het eind van elke sessie** en na elke
afgeronde taak. Dit document is een momentopname — de bron van waarheid voor
regels en ontwerp blijven de andere docs.*

**Laatst bijgewerkt**: 2026-07-28 (na taak 003 + debug-prompt, v0.0.14)

---

## 1. Laatste afgeronde taak

**Taak 003 — Interactiesysteem** ✅ gebouwd (v0.0.13) — **wacht op visuele
beoordeling door de Game Director** (beoordelingslijstje in
`tasks/003_interaction_system.md`).

Opgeleverd: `Interactable`-contract + interactor (raycast vanaf de actieve
viewport-camera, D-020) met de prompt letterlijk uit `prompt_text()` op de
EventBus; vier props zonder class_name (deur met slot, ladekast met
item-haak, oppakbaar object, leesbaar briefje met `document_opened`);
TestProps-spawner in de dev room; suite 81 → 117. Beide harde GD-eisen
geborgd: geen typechecks op props, prompt volledig data-gedreven.
Verwijdereenheid = hele systeem (D-021).

Eerder vandaag: taak 002 afgerond en goedgekeurd (incl. KI-003-fix:
Esc-pauze werkt).

## 2. Laatste commit

```
[docs] Werk administratie bij voor taak 003
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
| Fase 0 — Fundering | ✅ afgerond |
| Taak 001 — Project-setup & bootstrap | ✅ afgerond en goedgekeurd |
| Taak 002 — Player controller | ✅ afgerond en goedgekeurd |
| Taak 003 — Interactiesysteem | ✅ gebouwd, **visuele beoordeling open** |
| Taken 004–008 | ⬜ open |

Na akkoord op 003 is **fase 1 (De wandeling) compleet** — exit-criterium is
"bewegen en interacteren voelt goed", te beoordelen door de GD.

**Technische staat**: import schoon (exit 0), smoke-suite **120/120 groen**.
D-015 geverifieerd in vier richtingen: zonder interactiesysteem 82/82,
zonder speler 61/61, zonder debug-prompt 117/117, alles aanwezig 120/120;
halve verwijdering faalt bewust luid (D-021). `config/version` = 0.0.14.
**Debug-prompt (TD-006, verzoek GD)**: de interactieprompt is nu zichtbaar
in debugbuilds — "[E] Open deur" onderin beeld, toets live uit de InputMap;
weggooien zodra de echte HUD (fase 2/4) het signaal tekent.

**Nog niet visueel beoordeeld**: de interactieronde uit het
003-taakdossier (prompts, deur/la/sleutel/briefje, op-slot-deur,
interactie-afstand 2,5 m).

**Omgeving**: Godot 4.7.1 headless op de bouw-VPS
(`/opt/godot/godot-4.7.1`, symlink `/usr/local/bin/godot`). Projectpad:
`/home/kroosah/projects/crump`.

## 5. Volgende taak

**Eerst**: GD beoordeelt taak 003 in de editor (lijstje onderaan
`tasks/003_interaction_system.md`). Daarmee sluit ook fase 1.

**Daarna, op startsein**: **Taak 004 — Inventory** (fase 2). De haken
liggen klaar: `item_found` (la), `picked_up` (pickup) en
`EventBus.item_used`.

## 6. Open aandachtspunten

- **TD-005** (Laag, nieuw): deur/la bewegen instant — tween zodra audio
  (005) het ritme geeft.
- **TD-004** (Laag): bukken verkleint de collider niet — aflossen bij de
  eerste kruipruimte.
- **TD-002** (Middel): grafische presets eerste ruwe versie — taak 006/fase 6.
- **TD-003** (Laag): `brightness` nog niet toegepast — taak 006.
- **KNOWN_ISSUES**: geen open issues.
- **Export-templates** (TD-001) bewust niet geïnstalleerd (~1 GB).
- **Testcode-les (D-021)**: global classes van verwijderbare systemen nooit
  bij naam noemen in de suite — duck-typen met `has_method()`.
- **Pushen vanaf de VPS**: de kale vorm `git push -u origin main` (zonder
  pipes) werkt het betrouwbaarst.
- **Openstaande ontwerpsessie**: wát CRUMP is — zie `STORY.md` §8. Nodig
  vóór hoofdstuk 3/4, niet vóór taak 004.
