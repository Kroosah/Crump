# CRUMP — Sessiestatus

*Het startpunt van elke nieuwe sessie: waar staan we, wat is er net gebeurd,
wat is de volgende stap. **Bijwerken aan het eind van elke sessie** en na elke
afgeronde taak. Dit document is een momentopname — de bron van waarheid voor
regels en ontwerp blijven de andere docs.*

**Laatst bijgewerkt**: 2026-08-03 (fase G **tier F3** — na het
GD-startsein zijn bestuurskamer, hal en entree-buitenkant gebouwd als
eigen verwijdereenheid `f3_detail/`, plus de audio-micropass
(deurgeluid, regen). Suite 251 groen — status: **F3 READY FOR
ART-DIRECTION REVIEW**, niets doorpakken naar F4 zonder startsein)

---

## 1. Laatste taak

**VS-fase G, tier F3 — bestuurskamer, hal & entree (taak 008)** 🟡
gebouwd (2026-08-03), **wacht op art-direction-review**. Op GD-startsein
na akkoord op F2/F2.1; de kleedkamer is de kwaliteitslat, de gang is
beschermd gebleven (geverifieerd in render 15). Opgeleverd in
`game/levels/clubgebouw/f3_detail/` (D-040, zelfde D-015-contract als
F2: map weg = F2.1-staat, geverifieerd):
- **Bestuurskamer (hero room #2)**: volledige §5.8-inrichting —
  vergadertafel met zes ongelijke stoelen, bureau met computer
  (standby-LED's als apparaatlicht, puur emissief), dossierkast met
  ordners, ladekast met printer, dressoir met archiefdozen en
  koffiezetapparaat met opgedroogde kan, sleutelkastje, wandtelefoon,
  historie-wand (luchtfoto/oprichtingsakte/oude elftalfoto/vaan),
  whiteboard met half uitgewiste agenda, clubvlag en trainersjack.
  Nieuw raam in de zuidgevel (kantinepatroon, kozijn uit de glastabel;
  het artplan gaf de kamer al een vensterbank) en één werkende TL
  zonder schaduwslot (D-041: lichtpool boven de tafel, 0,85/2,45/2,7 —
  de historie leeft in de schaduw; D-026 blijft 3 + zaklamp).
- **Hal (transition space)**: prikbord met gevuld kurkvlak, kapstok met
  schoenenbank, radiator + te droge plant, half dicht gordijn,
  brandslanghaspel, clublogo-deurmat met druppelsporen, stilstaande
  klok, plinten; geen nieuwe lichtbronnen.
- **Entree-buiten (natte nacht)**: betonplint + boeiboord rondom,
  HWA-pijpen met lekspoor, luifel-afwerking met hanglamp, vlaggenmast,
  beugel-fietsenrek, kliko-hoek, hangslot; plassen als albedo+ORM-
  decals, natte gevelvoet, onkruid; regen als twee GPU-particle-
  wereldvolumes + drie verstemde 3D-audio-loops (D-042). Het
  clubnaambord staat nu op het boeiboord en wordt aangelicht.
- **Audio-micropass (D-043)**: deurgeluid is een keten (klink, schoot,
  bladbeweging, zachte kraak, resonantie) uit
  `tools/genereer_f3_audio.gd`; 1-op-1 WAV-vervanging.
- **IJkingen**: tapijt → naaldvilt (2,4/m), nat asfalt donkerder,
  bestuurskamer-TL in drie rondes tegen de F2.1-referentie gelegd.
- **QA**: geometriecontrole gedraaid tegen de v0.0.23-baseline — alle
  echte nieuwe fouten in de bron opgelost (meubel-overlaps, zwevend
  whiteboard, coplanaire tafelbladen, gordijn door vensterbank,
  kabelgoot door kast, koord door mastvoet); restmeldingen zijn
  TD-009-bouwnaden. Inspectiesweep 50 standpunten. Nieuw: TD-010
  (regen-audio zonder occlusie), KI-005 (speculaire spikkels op
  systeemplafond/stucwerk — beoordelen op echte hardware).
  Suite 250 → **251** (bestuurskamer-meetpunt; TL-verwachting 5/1/9).
  v0.0.24.

Eerder: **integriteitspass** ✅ (2026-08-01, D-038/D-039, v0.0.23) en
**tier F2/F2.1** (kleedkamer 3 + gang) — door de GD goedgekeurd op
2026-08-03; de kleedkamer is sindsdien de visuele baseline en de
donkere gang is beschermde referentie.

## 2. Laatste commit

```
[docs] Werk administratie bij voor tier F3 (gebouwd, wacht op AD-review)
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
| **Fase 2½ — Vertical Slice 01** | A ✅ · B ✅ · C ✅ · F ✅ (v1.1, D-031) · **G: F1 ✅ · F2/F2.1 ✅ GD-akkoord · F3 🟡 wacht op art-direction-review** (F4 ⬜) · D/E/H–J ⬜ |
| Taak 007 — Minimale documentlezer (VS-fase B) | ✅ afgerond en lokaal goedgekeurd |
| Taak 009 — Monster-AI (was 007) | ⬜ open |
| Taak 010 — Hoofdstuk 1 (was 008) | ⬜ open; skelet-beats achterhaald door D-028, herontwerp na de VS |

**Technische staat**: import schoon (exit 0), smoke-suite **251/251
groen**. `config/version` = 0.0.24. Rendermeters demo-zone (uit
`tools/maak_screenshots.gd`, 18 standpunten): piek 248 draw calls en
~19k primitieven — het zwaarste beeld is het voorplein mét regen;
binnenshots blijven onder de 231. D-015 geverifieerd voor de nieuwe
laag: zonder `f3_detail/` valt het clubgebouw terug op de F2.1-staat
(suite groen); de eerdere terugvalpaden (F2-laag, clubgebouw,
documentlezer, interactie, zaklamp, lighting, inventory) staan in de
v0.0.23-notities en zijn ongewijzigd. Warnings in de suite-output zijn
uitsluitend de bewust geteste luide faalpaden; KI-004 (exit-leak)
pre-existent, nieuw KI-005 (speculaire spikkels — hardware-oordeel).
Debug-prompt (TD-006) blijft tot de echte HUD.

**Nog niet visueel beoordeeld**: tier F3 (deze oplevering — twaalf
verplichte AD-renders + zes contextbeelden staan klaar), en de eerder
openstaande hardware-oordelen (interactieronde 003, 006-sfeerpass).

**Omgeving**: Godot 4.7.1 headless op de bouw-VPS
(`/opt/godot/godot-4.7.1`, symlink `/usr/local/bin/godot`). Projectpad:
`/home/kroosah/projects/crump`. Renders via lavapipe + xvfb
(`tools/maak_screenshots.gd`, output `user://screenshots/`).

## 5. Volgende stap (voor de verse sessie)

**De GD beoordeelt tier F3**: renders 01–12 (verplichte lijst uit de
F3-brief §18) plus context 13–18. Toetsen tegen de F2.1-lat: loop je
van de kleedkamer naar de bestuurskamer, voelt het dan als hetzelfde
gebouw? Specifiek: (a) bestuurskamer — material realism, curated
clutter, lichtpool met schemerzones, silhouetplekken zonder
jumpscare-architectuur; (b) hal — leesbaar en terughoudend, darkness
hierarchy richting gang intact (render 05/15); (c) buiten — Nederlandse
vereniging in een natte nacht, aangelicht naambord, plassen alleen waar
logisch; (d) audio — deurgeluid-keten en regen die per zone verandert
(hardware-oordeel).

**Pas ná expliciet startsein: F4** (complete lighting / atmosphere /
horror presentation pass). Daarna G-flow (sleutel/puzzel/tension
scripting), daarna de CRUMP-encounter. Overige haken: monster-AI (009),
TD-004/005/008/009/010, save-integratie, inventory-UI/HUD (TD-006),
canonvraag "derde helft als proloog" (STORY §8), KI-004/005, en de
canon-ronde over CRUMP zelf.

## 6. Open aandachtspunten

- **Nummering (D-028)**: 007 = documentlezer, 008 = Vertical Slice,
  009 = monster-AI, 010 = hoofdstuk 1.
- **Premisse**: de vergeten sporttas is canon (D-028) en blijft een
  fase-D-gameplayprop; de F2-tas is bewust generiek (D-035).
- **KI-004** (Klein): incidentele "ObjectDB leaked"-warning bij
  afsluiten (ambience-teardown-race); pre-existent.
- **KI-005** (Klein, nieuw): speculaire spikkels op systeemplafond/
  stucwerk onder een werkende TL — hardware-oordeel bij de GD-review.
- **TD-010** (Laag, nieuw): regen-audio dempt op afstand, niet op
  occlusie — aansluiten op het fase-H-audiowerk.
- **TD-005** (Laag): deur/la bewegen instant — tween zodra gewenst.
- **TD-004** (Laag): bukken verkleint de collider niet.
- **TD-002** (Middel): grafische presets eerste ruwe versie — fase 6.
- **Export-templates** (TD-001) bewust niet geïnstalleerd (~1 GB).
- **Testcode-les (D-021)**: global classes van verwijderbare systemen
  duck-typen; lambda-recorders geen referenties laten vasthouden.
- **Pushen vanaf de VPS**: de kale vorm `git push -u origin main`
  (zonder pipes) werkt het betrouwbaarst.
- **Canon-correctieronde CRUMP** (GD, 2026-07-28): monster dat zwerft,
  achtervolgt en besluipt, vaker gehoord dan gezien — GAME_BIBLE §6 en
  STORY §5/§8 in een aparte gerichte ronde bijwerken.
- **Openstaande ontwerpsessie**: de verklaring achter CRUMP en de
  verdwijning (STORY §8) — nodig vóór hoofdstuk 3/4.
