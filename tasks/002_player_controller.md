# Taak 002 — Player Controller

**Fase**: 1 (De wandeling) · **Status**: ⬜ open · **Vereist**: 001

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

- [ ] Speler-scène instantieert los zonder errors.
- [ ] Lopen/sluipen/rennen/bukken werken en verschillen in snelheid + luidheid.
- [ ] Camera voelt gegrond; head-bob uitschakelbaar; gevoeligheid instelbaar.
- [ ] Geen door-de-vloer/muur-vallen in de testruimte.
- [ ] Voetstappen emitten `noise_made` met correcte, per-modus schalende
      luidheid.
- [ ] Alle tuning via exports; geen magic numbers.
- [ ] Headless-import schoon; smoke-test groen. Dossier + README bijgewerkt.

## Te beoordelen in de editor (VPS kan dit niet)

Het *gevoel* van beweging (traagheid, head-bob, camerahoogte) is de kern van
deze taak en moet door Randy op de ontwikkelmachine worden ervaren. Lever
daarom met duidelijke export-defaults en een korte notitie welke waarden
bewust zo staan.
