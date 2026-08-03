# CRUMP — Bekende issues (KNOWN_ISSUES.md)

*Elk bekend probleem dat niet direct wordt opgelost, staat hier — hoe klein
ook. Een bug die alleen in een gesprek of een hoofd bestaat, bestaat niet.
**Verplicht bijhouden** bij elke taak (zie CLAUDE.md).*

## Werkwijze

- **Elke bevinding krijgt een entry** met ID (`KI-xxx`), datum, ernst en een
  reproduceerbare omschrijving. Fixen mag pas "klaar" heten als de entry is
  afgesloten met verwijzing naar de commit.
- **Ernst**:
  - **Blocker** — verhindert werken of spelen; wordt vóór al het andere opgepakt.
  - **Ernstig** — breekt een systeem of de immersie; inplannen in de
    eerstvolgende relevante taak.
  - **Klein** — hinderlijk maar omzeilbaar; batchen bij gerelateerd werk.
- Een issue dat een bewuste beperking blijkt ("werkt zo by design") wordt
  afgesloten met die conclusie — niet stilletjes verwijderd.
- QA-bevindingen (QA_CHECKLIST) die niet direct gefixt worden, landen hier.

## Formaat

```
## KI-001 — Korte titel
**Datum**: jjjj-mm-dd · **Ernst**: Blocker/Ernstig/Klein · **Status**: open/opgelost (commit)
**Waar**: systeem/scène/bestand
**Omschrijving**: wat gaat er mis, hoe reproduceer je het, wat was verwacht.
```

---

## Open issues

*Geen.*

## Opgeloste issues

## KI-003 — Escape leek niets te doen: de spelwereld pauzeerde nooit
**Datum**: 2026-07-28 · **Ernst**: Ernstig · **Status**: opgelost (v0.0.12; gemeld door GD bij de lokale test van taak 002)
**Waar**: `game/bootstrap.gd` (`_ready`, procesmodi)
**Omschrijving**: Esc in het spel deed schijnbaar niets — geen pauze, muis
bleef gevangen; alleen F8 stopte de debugrun. De input-keten was in orde
(Esc → actie `pause` → bootstrap `_unhandled_input` → `tree.paused` toggelde
wél, zichtbaar in de log). De echte oorzaak: de bootstrap zet zichzelf op
`PROCESS_MODE_ALWAYS` om tijdens de pauze te blijven luisteren, maar
kinderen staan op `INHERIT` — SceneHost, level én speler erfden dus ALWAYS
en pauzeerden nooit. Ook `NOTIFICATION_PAUSED` bereikte de speler daardoor
nooit, dus de muis kwam niet vrij. **Fix**: SceneHost expliciet op
`PROCESS_MODE_PAUSABLE`; de debug overlay blijft bewust ALWAYS. **Les**:
`ALWAYS` op een voorouder schakelt stilletjes de pauze van de hele subtree
uit — de smoke-suite toetst nu zowel de procesmodi (structureel) als de
volledige Esc-round-trip (functioneel: wereld stil, muis vrij, hervatten).
Zonder de fix falen die tests aantoonbaar.

## KI-002 — DirectionalLight van de dev room schijnt omhoog
**Datum**: 2026-07-27 · **Ernst**: Klein · **Status**: opgelost (CHANGELOG v0.0.10, op aanwijzing GD)
**Waar**: `game/levels/dev_room/dev_room.tscn`, node `Lighting/SunKey`
**Omschrijving**: de key-light heeft lichtrichting `(-0.62, +0.62, -0.49)` —
de y-component is positief, dus het licht gaat de lucht in en draagt niets bij
aan de ruimte. De dev room wordt nu alleen verlicht door de twee omni's en het
ambient licht.
**Oorzaak**: de 12-float `Transform3D(...)`-notatie in een `.tscn` is
rij-georiënteerd (getransponeerd t.o.v. `Basis(x_as, y_as, z_as)` in GDScript).
De transform is met de kolom-conventie berekend en staat dus gespiegeld; bij
een rotatiematrix is de transpose de inverse rotatie. Zelfde oorzaak als de
camerakanteling die in v0.0.8 is verholpen.
**Verwacht**: licht van boven-voor, richting ongeveer `(0.38, -0.79, -0.49)`.
**Opgelost door**: `transform` van `SunKey` vervangen door de getransponeerde
variant; gemeten lichtrichting nu `(0.38, -0.79, -0.49)`. De fix is bewust
even blijven liggen tot de Game Director hem opdroeg, omdat het eerdere beeld
al visueel was goedgekeurd en de belichting merkbaar verandert. Twee
smoke-controles erbij: DirectionalLights moeten omlaag schijnen (bewezen: met
de oude transform faalt de suite met exitcode 1), en de kijkrichting-drempel
van de camera is aangescherpt van `dot > 0.9` naar `> 0.99` — de oude drempel
liet de 9°-fout van v0.0.8 nog door.

## KI-001 — Developer room toont een egaal grijs beeld
**Datum**: 2026-07-27 · **Ernst**: Blocker · **Status**: opgelost (CHANGELOG v0.0.7)
**Waar**: `game/levels/dev_room/dev_room.tscn`
**Omschrijving**: bij `F5` op de dev-pc (Windows, Vulkan Forward+, Intel UHD
Graphics, preset DEVELOPMENT_LOW) vulde het venster zich met egaal grijs,
terwijl de logs schoon waren en meldden dat de dev room geladen was.
**Oorzaak**: het project bevatte geen enkele `Camera3D`. Zonder actieve camera
rendert Godot de 3D-wereld niet; de viewport wordt dan gevuld met
`rendering/environment/defaults/default_clear_color` = `(0.3, 0.3, 0.3)`.
Het grijs was dus geen render van de grijze blockout maar de *afwezigheid*
van een render — GPU, preset en materialen hadden er niets mee te maken.
**Verwacht**: de blockout met vloer, muren en objecten in beeld.
**Opgelost door**: `TestCamera` in de dev room (D-016), zwaardere tijdelijke
verlichting, contrasterende materialen, en 17 extra smoke-controles die deze
klasse fout voortaan headless afvangen (bewezen: met de camera weggehaald
faalt de suite met exitcode 1).

## KI-004 — Incidentele "ObjectDB instances leaked"-melding bij afsluiten van de suite
**Datum**: 2026-07-28 · **Ernst**: Klein · **Status**: open
**Waar**: afsluitpad headless-run (ambience-player, `amb_hum_koeling_01.wav`)
**Omschrijving**: sommige suite-runs eindigen ná "CRUMP sluit af (code 0)"
met `WARNING: 2 ObjectDB instances were leaked at exit` (een
AudioStreamWAV + zijn playback) en `1 resources still in use`. Het is een
teardown-volgorderace bij `quit()` terwijl de ambience-loop nog speelt;
niet elke run toont hem, de uitslag van de suite is er niet door beïnvloed
en tijdens het draaien lekt er niets. Geconstateerd tijdens taak 006 op
runs van de ongewijzigde 005-code — geen regressie van 006.
**Verwacht**: een afsluitpad zonder leak-warning (ambience expliciet
stoppen vóór `quit()` in `Bootstrap.shutdown()` is de voor de hand
liggende kandidaat; batchen bij de eerstvolgende audio- of bootstrap-taak).

## KI-005 — Speculaire spikkels op systeemplafond en stucwerk onder een werkende TL
**Datum**: 2026-08-03 · **Ernst**: Klein · **Status**: open
**Waar**: bestuurskamer en hal (f_systeemplafond, f_stucwerk), zichtbaar in
de F3-renders op 1600×900 via lavapipe
**Omschrijving**: vlak onder een aanstaande TL tonen het systeemplafond en
het stucwerk fijne witte spikkels — speculaire aliasing van de normal maps
op renderresolutie, geen geometrie- of materiaalfout. In beweging en op
hogere resolutie is het minder aanwezig; op de bouw-VPS is dat niet te
verifiëren (headless, software-Vulkan).
**Verwacht**: beoordelen op echte hardware bij de GD-review; zonodig
normal-sterkte van beide materialen iets terug of roughness-ondergrens
verhogen in de F4-lichtpass.
