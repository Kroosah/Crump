# CRUMP — Sessiestatus

*Het startpunt van elke nieuwe sessie: waar staan we, wat is er net gebeurd,
wat is de volgende stap. **Bijwerken aan het eind van elke sessie** en na elke
afgeronde taak. Dit document is een momentopname — de bron van waarheid voor
regels en ontwerp blijven de andere docs.*

**Laatst bijgewerkt**: 2026-07-28 (na implementatie taak 004, v0.0.15)

---

## 1. Laatste afgeronde taak

**Taak 004 — Inventory** ✅ afgerond en **lokaal goedgekeurd door de GD
(2026-07-28)**: positieve flow bevestigd (pickup, inventory-update, F3
`inventory: 1/6 · sleutel_kleedkamer`); reject-flow en invarianten
geaccepteerd op de geautomatiseerde dekking; geen hoorbare audio =
bewust taak 005 (bindend kader in dat dossier, commit `409c718`).

Opgeleverd: `ItemResource` (minimaal, runtime read-only) + drie
voorbeelditems; inventory-node (capaciteit 6, geen stacking D-023,
`add_item -> bool` als enig besliskanaal, weigeren = nul mutatie); één
autoritatieve inventory (groep-guard in bootstrap + zelfcheck + test);
pickupflow via `item_pickup_requested`/`item_pickup_resolved` (D-022) —
prop verdwijnt uitsluitend na geldige accepted-response in zijn eigen
synchrone venster en bezit zijn eigen feedback; F3-regel
`inventory: n/cap · id's`. Suite 120 → 145.

Eerder vandaag: taken 002 en 003 afgerond en goedgekeurd; fase 1 compleet.

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
| Taak 003 — Interactiesysteem | ✅ afgerond en goedgekeurd |
| **Fase 1 — De wandeling** | ✅ **compleet** (GD-akkoord 2026-07-28) |
| Taak 004 — Inventory | ✅ afgerond en lokaal goedgekeurd |
| Taak 005 — Audio-fundament | ⬜ **volgende** (bindend kader ligt klaar) |
| Taken 006–008 | ⬜ open |

**Technische staat**: import schoon (exit 0), smoke-suite **145/145
groen**. D-015 geverifieerd: zonder inventory 119/119 (pickups blijven
liggen), zonder interactiesysteem 95/95 (inventory idle), alles aanwezig
145/145; halve verwijdering faalt bewust luid (D-021).
`config/version` = 0.0.15. Warnings in de suite-output zijn uitsluitend de
bewust geteste luide faalpaden (add_item(null) e.d.) — normale opstart is
schoon. Debug-prompt (TD-006) toont "[E] …" tot de echte HUD er is.

**Nog niet visueel beoordeeld**: de interactieronde uit het
003-taakdossier (prompts, deur/la/sleutel/briefje, op-slot-deur,
interactie-afstand 2,5 m).

**Omgeving**: Godot 4.7.1 headless op de bouw-VPS
(`/opt/godot/godot-4.7.1`, symlink `/usr/local/bin/godot`). Projectpad:
`/home/kroosah/projects/crump`.

## 5. Volgende taak

**Taak 005 — Audio-fundament** (fase 2), **op startsein van de GD**.
Het bindende architectuurkader staat bovenin `tasks/005_audio.md`
(scheiding noise_made ↔ hoorbare audio, audiosysteem bezit de
player-lifecycle, vier verplichte tests); TD-005 (props bewegen instant)
wordt in/na 005 afgelost. Verdere vervolghaken uit 004:
sleutel-deur-logica, la-koppeling, save-integratie en de inventory-UI
(elk een eigen taak; dossier 004 §1/§6).

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
