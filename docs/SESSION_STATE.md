# CRUMP — Sessiestatus

*Het startpunt van elke nieuwe sessie: waar staan we, wat is er net gebeurd,
wat is de volgende stap. **Bijwerken aan het eind van elke sessie** en na elke
afgeronde taak. Dit document is een momentopname — de bron van waarheid voor
regels en ontwerp blijven de andere docs.*

**Laatst bijgewerkt**: 2026-07-28 (taak 006 **afgerond en lokaal
goedgekeurd door de GD**; nieuwe opdracht: GD-ontwerp Vertical Slice —
zie §5)

---

## 1. Laatste taak

**Taak 006 — Licht & sfeer** ✅ afgerond en **lokaal goedgekeurd door de
GD (2026-07-28)**: verlichting voelt goed, donkerte overtuigend, zaklamp
correct, sfeer ontstaat — geen tuningronde nodig; de opgeleverde waarden
zijn de referentie. Gebouwd conform ontwerp v2.1 (drie GD-reviewrondes,
expliciete go). Opgeleverd:
nacht-environment op de dev room (near-black, koele ambient-vloer > 0,
diepte-fog, filmische tonemap, debanding) met verborgen werklicht-rig
(export, default uit); `game/systems/flashlight/` (camera-volgend,
betrouwbaar — flikkert nooit, D-025; gesloten bezit-gate op het
zaklamp-item via eventgedreven `has_item`-hercontrole; toggle = exact één
emissie per kanaal: nieuw busfeit `flashlight_toggled(is_on)` + klik-cue +
noise op de spelerpositie; `debug_bezit_bypass` default uit);
`game/props/light_tl/` (staten STABIEL/DEFECT/FLIKKEREND, seed-
deterministisch patroon mét rust; dev room: 2 stabiel + 1 flikkerend + 5
defect, als data geplaatst); `game/systems/light_budget/` (max 3
level-schaduwlichten + gereserveerd zaklampslot, deterministische
degradatie op boomvolgorde, D-026); brightness werkt (0.8–1.2, D-027,
TD-003 afgelost) via `environment_tuner`; zaklamp-pickup via de echte
flow; F3-regels `zaklamp:` en `licht:`. Suite **166 → 208**.

Eerder vandaag: taken 002 t/m 005 afgerond en lokaal goedgekeurd; fase 1
compleet; Design Pillars vastgesteld; 006-ontwerp in drie rondes
goedgekeurd (v1 → v2 → v2.1, zie het dossier).

## 2. Laatste commit

```
[docs] Werk administratie bij voor taak 006 (gebouwd, wacht op GD-test)
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
| Taken 001–006 | ✅ afgerond en lokaal goedgekeurd |
| **Fase 1 — De wandeling** | ✅ **compleet** (GD-akkoord 2026-07-28) |
| **Fase 2 — Het gereedschap** | ✅ taken 004–006 alle afgerond (git-lfs-beslismoment nog open) |
| Vertical Slice 01 | 🔵 **GD-ontwerp in tasks/007_vertical_slice_01.md, wacht op review + go** |
| Monster-AI / hoofdstuk 1 | ⬜ open (dossiernummering herzien na de VS — zie §6) |

**Technische staat**: import schoon (exit 0), smoke-suite **208/208
groen**. D-015 geverifieerd (0 fouten): zonder zaklampsysteem 188, zonder
complete lighting (flashlight + light_budget + light_tl) 176, zonder
inventory 169 (zaklamp faalt gesloten, alles parsebaar), alles aanwezig
208. `config/version` = 0.0.17. Warnings in de suite-output zijn
uitsluitend de bewust geteste luide faalpaden (incl. de geforceerde
budgetoverschrijding) — normale opstart is schoon (geverifieerd).
Incidentele exit-leak-warning van de ambience is pre-existent en
geregistreerd als KI-004. Debug-prompt (TD-006) blijft tot de echte HUD.

**Nog niet visueel beoordeeld**: de interactieronde uit het 003-dossier én
de volledige 006-sfeerpass (het fase 2-exit-criterium "onaangenaam" is een
hardware-oordeel) — zie de GD-testinstructie in tasks/006 §Uitvoeringsverslag.

**Omgeving**: Godot 4.7.1 headless op de bouw-VPS
(`/opt/godot/godot-4.7.1`, symlink `/usr/local/bin/godot`). Projectpad:
`/home/kroosah/projects/crump`.

## 5. Volgende stap (voor de verse sessie)

**Het GD-ontwerp van de eerste Vertical Slice staat in
`tasks/007_vertical_slice_01.md` en wacht op GD-review** (opdracht GD
2026-07-28: de eerste ±20 minuten van CRUMP als Game Director-document —
géén techniek, géén implementatie). Canon van de slice: voetballer keert
na een avondwedstrijd terug voor zijn vergeten sporttas; stadion lijkt
verlaten; regen; alleen sfeer/verkennen/spanning, geen achtervolging;
CRUMP vaker gehoord dan gezien, hooguit 1–2 zeer korte glimpsen; kleine
speelruimte (ingang, kantine, gang, twee kleedkamers, onderhoudsruimte,
stukje buiten). Na review + eventuele correctierondes volgt een
**expliciete implementatie-go** — tot die tijd géén code/assets/scènes.

Openstaande vervolghaken daarna: monster-AI (abonneert op
`flashlight_toggled` en `noise_made`), TD-005 (deur/la-tween), TD-004
(bukken-collider), sleutel-deur/la-koppeling, save-integratie,
inventory-UI/HUD (lost TD-006 af), canon-correctieronde (zie §6),
KI-004 (exit-leak, batchen bij audio-/bootstrap-werk).

## 6. Open aandachtspunten

- **Dossiernummering**: `tasks/007_vertical_slice_01.md` (opdracht GD)
  botst met het bestaande skelet `tasks/007_monster_ai.md`; dat oude
  dossier is ongewijzigd gelaten. Hernummeren (monster-AI → 008+,
  chapter1 herzien t.o.v. de VS) is een GD-besluit bij de VS-review.
- **Premisse-delta VS ↔ STORY §3**: de VS-canon (terugkeer voor de
  vergeten sporttas) wijkt af van de opening in STORY §3 (afsluitverzoek
  + verdwijning tijdens het douchen). Vastgelegd in de canon-notitie van
  het VS-dossier; beslechten in de canon-correctieronde.
- **KI-004** (Klein, nieuw): incidentele "ObjectDB leaked"-warning bij
  afsluiten (ambience-teardown-race); pre-existent, geen 006-regressie.
- **TD-005** (Laag): deur/la bewegen instant — tween zodra gewenst (audio
  geeft het ritme al).
- **TD-004** (Laag): bukken verkleint de collider niet — aflossen bij de
  eerste kruipruimte.
- **TD-002** (Middel): grafische presets eerste ruwe versie — fase 6; in
  006 bewust niet uitgebreid (kalibratie vergt beeld).
- **TD-003**: ✅ afgelost in 006 (brightness werkt, D-027).
- **Export-templates** (TD-001) bewust niet geïnstalleerd (~1 GB).
- **Testcode-les (D-021)**: global classes van verwijderbare systemen nooit
  bij naam noemen in de suite — duck-typen met `has_method()`; en (les
  006) lambda-recorders mogen geen referenties vasthouden naar instanties
  die de test later vriest — waarde vooraf lokaal vangen.
- **Pushen vanaf de VPS**: de kale vorm `git push -u origin main` (zonder
  pipes) werkt het betrouwbaarst.
- **Canon-correctieronde nodig (geregistreerd 2026-07-28, opdracht GD bij
  005)**: de GD heeft CRUMP nader bepaald — een **monster** dat door het
  stadion en over het terrein zwerft, de speler achtervolgt en besluipt,
  vaker gehoord dan gezien, met zeer zeldzaam een harde onmenselijke
  schreeuw (geen timer-jumpscare). Dit vervangt deels "vorm en aard
  bewust onbeschreven" in GAME_BIBLE §6 en STORY §5/§8 — die documenten in
  een aparte, gerichte canon-ronde bijwerken; géén brede lore-herbouw.
- **Openstaande ontwerpsessie**: de verklaring achter CRUMP en de
  verdwijning — zie `STORY.md` §8. Nodig vóór hoofdstuk 3/4.
