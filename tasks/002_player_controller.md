# Taak 002 — Player Controller

**Fase**: 1 (De wandeling) · **Status**: ✅ afgerond, goedgekeurd door de GD (2026-07-28) · **Vereist**: 001

De speler ís de camera in een first person horror. Deze taak maakt het bewegen
zó goed dat rondlopen in een lege ruimte al bevredigend is (ROADMAP fase 1).
Geen combat, geen health — alleen een lichaam dat goed voelt.

## Doel

Een `CharacterBody3D`-gebaseerde speler met gegronde, bewuste beweging die de
kwetsbaarheid uit GAME_BIBLE §5 uitstraalt, volledig af te stemmen via exports.

## Scope

**Wel:**
- Beweging: lopen, **sluipen** (langzamer, stiller), **rennen** (kort,
  hoorbaar, met consequentie), **bukken** (lagere camera, langzamer).
- Camera op ooghoogte; muis-look met instelbare gevoeligheid, geen
  ongewenste acceleratie.
- Bewuste beweging: acceleratie/deceleratie i.p.v. instant snelheid; subtiele,
  **uitschakelbare** head-bob (HORROR_GUIDELINES §8).
- Zwaartekracht, correcte collision, traphoogte/slopes redelijk.
- **Voetstap-events**: elke stap publiceert `noise_made(position, loudness)`
  op de EventBus — luidheid schaalt met sluipen/lopen/rennen (koppeling voor
  taak 007). Nog geen audio afspelen (dat is taak 005), wél de events.
- Speler als eigen scène `game/actors/player/player.tscn` + `player.gd`,
  losstaand instantieerbaar.

**Niet:**
- Geen inventory (004), geen interactie-raycast (003), geen zaklamp (006),
  geen daadwerkelijke voetstapgeluiden (005) — alleen de event-emissie.

## Aanpak

1. `player.tscn`: `CharacterBody3D` → `Camera3D` (%uniek), collider,
   voetstap-timer-node. Ondiepe, nette scène-boom (CODING_STANDARDS §4).
2. `player.gd` volgens de scriptvolgorde uit CODING_STANDARDS §3, met
   `@export_group("Movement")` voor alle snelheden/tijden.
3. Bewegingslogica in kleine privé-functies (`_apply_movement`,
   `_handle_crouch`, `_update_footsteps`).
4. Voetstap-timer bepaalt ritme per gangmodus; bij elke stap
   `EventBus.noise_made.emit(global_position, huidige_luidheid)`.
5. Smoke-test: speler instantieert los, valt niet door de vloer, emits een
   noise-event bij simulatie van beweging.
6. Commit(s) met `[002]`-prefix.

## Acceptatiecriteria

- [x] Speler-scène instantieert los zonder errors *(smoke-test 12)*.
- [x] Lopen/sluipen/rennen/bukken werken en verschillen in snelheid + luidheid
      *(headless getoetst via input-simulatie; gevóél nog te beoordelen)*.
- [x] Camera voelt gegrond; head-bob uitschakelbaar; gevoeligheid instelbaar
      *(mechanisch af: SettingsManager-koppeling werkt; "voelt" = editor)*.
- [x] Geen door-de-vloer/muur-vallen in de testruimte.
- [x] Voetstappen emitten `noise_made` met correcte, per-modus schalende
      luidheid.
- [x] Alle tuning via exports; geen magic numbers.
- [x] Headless-import schoon; smoke-test groen (75/75). Dossier + README
      bijgewerkt.

## Wat er gebouwd is (2026-07-28)

- `game/actors/player/player.tscn` + `player.gd` — `CharacterBody3D` met
  `Head` (pitch + ooghoogte) → `Camera` (head-bob-offset) en een one-shot
  `FootstepTimer`. Groep `player` (debug overlay pakt hem vanzelf op).
- **Gangmodi** WALK/SNEAK/RUN/CROUCH; prioriteit bukken > sluipen > rennen
  ("stil verslaat snel"). Per modus: snelheid, stapinterval, luidheid.
- **Ren-consequentie = geluid** (besluit GD, D-019): rennen is onbeperkt maar
  draagt 14 m; geen uithoudingssysteem in deze taak.
- **Spawn via marker** (D-018): de bootstrap plaatst de speler op de
  `PlayerSpawn`-Marker3D van het geladen level; geen scène of marker = level
  draait zonder speler door (verwijderbaarheidstest D-015 geverifieerd:
  map weg → import schoon + suite 52/52 groen, testcamera springt bij).
- **Smoke-suite 52 → 75**: spelertests draaien échte input-simulatie
  (`Input.action_press`) met physics-frames; per gangmodus wordt verplaatsing,
  event-emissie, luidheid en event-positie getoetst, plus buk-ooghoogte
  heen én terug. De suite is daarvoor async geworden (bootstrap await).

## Export-defaults (bewust zo, tunen in de editor)

| Wat | Waarde | Waarom |
|---|---|---|
| walk/sneak/run/crouch-snelheid | 2.6 / 1.2 / 4.6 / 1.0 m/s | clublid, geen soldaat (GAME_BIBLE §5) |
| acceleratie / deceleratie | 10 / 14 m/s² | gewicht zonder gladheid; remmen sneller dan optrekken |
| stapinterval | 0.55 / 0.75 / 0.35 / 0.8 s | ritme hoorbaar verschillend per modus |
| luidheid (draagafstand) | 6 / 2 / 14 / 2.5 m | rennen alarmeert, sluipen draagt amper (§3 HORROR) |
| look_sensitivity | 0.0022 rad/px | × SettingsManager.mouse_sensitivity; rauw, geen smoothing |
| ooghoogte sta/buk | 1.70 / 1.15 m | buk-overgang 4 m/s |
| head-bob | 0.03 m · 0.9 cycli/m | subtiel; uit via SettingsManager.head_bob_enabled |

## Te beoordelen in de editor (VPS kan dit niet)

1. **Loopgevoel**: F5 → je start op het spawnpunt. Traagheid oké? Niet "op
   wieltjes"? Rensnelheid eng genoeg zonder arcade te worden?
2. **Muis-look**: gevoeligheid, geen versnelling, pitch-grenzen (±85°).
3. **Head-bob**: subtiel genoeg? (Uitzetten kan door in
   `user://settings.cfg` onder `[comfort]` `head_bob=false` te zetten.)
4. **Bukken**: camera-overgang (4 m/s) — te snel/langzaam?
5. **Esc** pauzeert en geeft de muis vrij; nogmaals Esc pakt hem weer.
6. F3-overlay toont nu de spelerspositie live.
