# CRUMP — Sessiestatus

*Het startpunt van elke nieuwe sessie: waar staan we, wat is er net gebeurd,
wat is de volgende stap. **Bijwerken aan het eind van elke sessie** en na elke
afgeronde taak. Dit document is een momentopname — de bron van waarheid voor
regels en ontwerp blijven de andere docs.*

**Laatst bijgewerkt**: 2026-07-29 (fase C **goedgekeurd door de GD**
("de basis staat"); GD-besluit: **artpass F→G naar voren**, vóór
gameplayflow D/E — richtdoel: speelbare demo ±10 min; **fase
F-ontwerp (art direction) in tasks/008_artdirection.md ter review**)

---

## 1. Laatste taak

**VS-fase C — Greybox clubgebouw (taak 008)** ✅ gebouwd (2026-07-28)
en **lokaal goedgekeurd door de GD (2026-07-29: "de basis staat")** —
geen maatcorrecties gevraagd. `game/levels/clubgebouw/`: het clubhuis onder de
hoofdtribune van VV Drechtstreek, 's nachts — 12 ruimtes/zones op
menselijke maat (plafonds 2,3–2,7 m), 214 volumes, 11 echte deuren
(bestuurskamer/keuken/terras op slot; onderhoudsruimte in fase C bewust
open — slot is fase-D-flow), 14 TL's (5 stabiel/1 flikkerend/8 defect;
schaduw bar+gang+mast = 3/3, zaklampslot vrij), voorplein met dichte
poort + ketting, pad langs het veld, veld met doel-silhouet in de fog,
lichtmast 3, dak met tribune-treden. Greybox als datatabellen (TD-007,
aflossen fase G). Bootstrap: normale runs starten in het clubgebouw,
suite draait op de dev room en wisselt aan het einde zelf (D-030).
Suite **230 → 250**; zonder clubgebouw 230 (terugval). v0.0.19.
GD-teststappen: zie het vier-vragen-rapport van deze sessie / §5.

Eerder vandaag: **taak 007 — minimale documentlezer (VS-fase B)** ✅ afgerond en
**lokaal goedgekeurd door de GD (2026-07-28)**: alle acceptatiepunten
bevestigd (één-E-druk-gedrag, Esc zonder gelijktijdige pauze,
muisherstel, betrouwbare inputblokkering, leesbaarheid nachtstaat,
F5 warning-vrij); geen presentatienotities. Gebouwd conform ontwerp
v1.1 (twee reviewrondes, expliciete go). Opgeleverd: `document_opened` eenmalig gecorrigeerd naar 3
argumenten (id/titel/tekst, D-029 — vanaf nu geconsumeerd contract);
`DocumentResource` runtime read-only bij de prop met validatie aan de
bron; `game/ui/document_reader/` als verwijdereenheid: deferred arming
(één E-druk kan nooit openen én sluiten), sluit-input opgegeten in
`_input` (één Esc raakt nooit tegelijk de pauze), exact
pauze-/muisownership met idempotent herstel, atomaire vervanging bij
een tweede feit, ScrollContainer met vaste paneelmaat, sluithint uit de
InputMap. Suite **208 → 230**; D-015: zonder reader 209, zonder
interactie-unit incl. documentprops 172 (reader stabiel), alles 230.
`config/version` = 0.0.18. GD-teststappen: tasks/007 §Lokale
GD-acceptatie.

Eerder vandaag: **taak 006 afgerond en lokaal goedgekeurd** (donkerte
overtuigend, zaklamp correct — waarden zijn de referentie). Gebouwd
conform ontwerp v2.1. Opgeleverd:
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
| **Fase 2½ — Vertical Slice 01** | A ✅ · B ✅ · C ✅ · **F 🔵 ontwerp ter review** (naar voren gehaald vóór D/E, GD-besluit 2026-07-29) · D/E/G–J ⬜ |
| Taak 007 — Minimale documentlezer (VS-fase B) | ✅ afgerond en lokaal goedgekeurd |
| Taak 009 — Monster-AI (was 007) | ⬜ open |
| Taak 010 — Hoofdstuk 1 (was 008) | ⬜ open; skelet-beats achterhaald door D-028, herontwerp na de VS |

**Technische staat**: import schoon (exit 0), smoke-suite **250/250
groen**. D-015 geverifieerd (0 fouten): zonder clubgebouw 230 (terugval
dev room), zonder documentlezer 209, zonder interactie-unit incl.
documentprops 172, zonder zaklampsysteem 188, zonder complete lighting
176, zonder inventory 169. `config/version` = 0.0.19. Warnings in de suite-output zijn
uitsluitend de bewust geteste luide faalpaden — normale opstart is
schoon (geverifieerd). Incidentele exit-leak-warning van de ambience is
pre-existent en geregistreerd als KI-004. Debug-prompt (TD-006) blijft
tot de echte HUD. Codecommentaar-taaknummers zijn bijgewerkt naar de
D-028-nummering (aandachtspunt uit §6 afgehandeld).

**Nog niet visueel beoordeeld**: de interactieronde uit het 003-dossier én
de volledige 006-sfeerpass (het fase 2-exit-criterium "onaangenaam" is een
hardware-oordeel) — zie de GD-testinstructie in tasks/006 §Uitvoeringsverslag.

**Omgeving**: Godot 4.7.1 headless op de bouw-VPS
(`/opt/godot/godot-4.7.1`, symlink `/usr/local/bin/godot`). Projectpad:
`/home/kroosah/projects/crump`.

## 5. Volgende stap (voor de verse sessie)

**De GD reviewt het fase F-ontwerp** in `tasks/008_artdirection.md`
(art direction + assetplan voor de artpass), inclusief de vier
§14-keuzes: clubkleuren (advies blauw-wit), bronnen-akkoord (Poly
Haven + ambientCG, CC0, licenties in de repo), de tijdelijke
CRUMP-silhouet-representatie voor de latere glimp, en de demo-scope
(hele route, tier-gewijs). Na akkoord (+ evt. correctierondes, alleen
docs) volgt **fase G: de artpass in tier-volgorde** (§13 van het plan;
tier 1 = materialen + deuren + TL-behuizingen + bewegwijzering,
gebouwbreed), commit per tier, GD-blik na elke tier, TD-007 lost
gaandeweg af. **GD-besluit vastgelegd: D (flow) en E (pacing-gate)
volgen ná de artpass; geen monster-AI of nieuwe gameplay nu.**
Overige haken: monster-AI (009), TD-005, TD-004, save-integratie,
inventory-UI/HUD (TD-006), canonvraag "derde helft als proloog"
(STORY §8), KI-004.

## 6. Open aandachtspunten

- **Nummering opgelost (D-028-besluit)**: 007 = documentlezer, 008 =
  Vertical Slice, 009 = monster-AI, 010 = hoofdstuk 1. Codecommentaar
  is in taak 007 mee-gecorrigeerd (✅). Historische CHANGELOG-regels
  blijven staan (logboek herschrijven we niet).
- **Premisse-delta opgelost**: de vergeten sporttas is canon (D-028);
  STORY/GAME_BIBLE/HORROR/LEVEL gericht gecorrigeerd. Open canonvraag:
  wordt "de derde helft" ooit een speelbare proloog (STORY §8)?
  De canon-ronde over CRUMP-de-entiteit zelf (GAME_BIBLE §6/STORY §5)
  staat ook nog open — zie de monster-notitie verderop.
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
