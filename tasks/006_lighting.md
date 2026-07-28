# Taak 006 — Licht & sfeer

**Fase**: 2 (Het gereedschap) · **Status**: 🔵 technisch ontwerp ter review (GD), geen implementatie · **Vereist**: 001, 002

Licht is in CRUMP zowel gameplay (zaklamp: zien kost gezien worden) als de
duurste technische post (ARCHITECTURE §7). Deze taak legt het lichtfundament en
brengt de eerste sfeerpass op de testruimte — het moment waarop rondlopen
*onaangenaam* moet worden (ROADMAP fase 2 exit-criterium).

## Doel

Een zaklamp-systeem, een werkbaar lichtbudget-kader, en een eerste sfeerpass
die de "donker-maar-leesbaar"-regel (HORROR_GUIDELINES §4) in de praktijk
waarmaakt.

## Scope

**Wel:**
- **Zaklamp** op de speler: aan/uit (via inventory-item uit 004 of directe
  input), gerichte spot, subtiele imperfectie (lichte flikker/verzwakking) als
  toekomstig spanningsinstrument. Aan/uit is een **keuze met prijs**
  (HORROR_GUIDELINES §4) — documenteer de bedoelde afweging.
- **Lichtbudget-kader**: een praktische werkwijze + eventuele helper om het
  aantal realtime schaduw-lichten per ruimte te bewaken (LEVEL_GUIDELINES §5,
  richtlijn max. 4 zichtbaar tegelijk).
- **Environment/WorldEnvironment**-basis: tonemapping, ambient-niveau,
  fog/volumetriek zó afgesteld dat donkere zones contour houden (nooit
  informatie-loos pikzwart).
- **Helderheid-instelling** (haak voor het opties-menu; QA §5) zodat
  uiteenlopende schermen leesbaar blijven.
- **Eerste sfeerpass** op de testruimte: TL-armaturen met wereld-oorzaak,
  donkere hoeken, één ontworpen lichtgebeurtenis (bijv. een flikkerende buis
  met verklaarbare oorzaak).
- Eventuele lichtshaders (flikker) als `.gdshader` in `assets/shaders/`.

**Niet:**
- Geen volledige art-pass of finale ruimte (dat is levelwerk, taak 008).
- Geen monster-gekoppelde lichtevents (komt later; hier alleen de fundamenten).

## Aanpak

1. Zaklamp-scène/component op de speler; koppel aan input en (indien gekozen)
   aan het inventory-item. Tuning via exports (bereik, hoek, intensiteit,
   flikker).
2. WorldEnvironment afstellen op leesbaar-donker; documenteer de gekozen
   waarden en waaróm (tonemap, ambient, fog).
3. Lichtbudget-werkwijze vastleggen + eventueel een editor-/debug-helper die
   telt hoeveel schaduw-lichten zichtbaar zijn.
4. Eerste sfeerpass op de testruimte met verklaarbare bronnen; bouw één
   ontworpen lichtgebeurtenis.
5. Tests headless waar mogelijk (zaklamp-node instantieert, toggle-logica,
   budget-helper telt correct); het visuele oordeel is editor-werk.
6. Commits met `[006]`-prefix.

## Acceptatiecriteria

- [ ] Zaklamp werkt (aan/uit), tuning via exports, afweging gedocumenteerd.
- [ ] WorldEnvironment levert donker-maar-leesbaar; nergens pikzwart-zonder-
      contour.
- [ ] Lichtbudget-werkwijze vastgelegd; helper (indien gebouwd) telt correct.
- [ ] Helderheid-instelling aanwezig als opties-haak.
- [ ] Sfeerpass op de testruimte: elke lichtbron heeft een wereld-oorzaak;
      één ontworpen lichtgebeurtenis werkt.
- [ ] Headless-import schoon; toggle-/helper-tests groen. Dossier + README
      bijgewerkt.

## Te beoordelen in de editor (VPS kan dit niet)

Dit is de meest visuele taak tot nu toe; vrijwel de hele acceptatie op
"leesbaar-donker" en "onaangename sfeer" is een oordeel op de ontwikkelmachine.
Lever met screenshots-instructie en bewuste export-defaults, en markeer expliciet
wat Randy moet beoordelen.

---

# Technisch ontwerp (v1, 2026-07-28 — ter review GD)

*Elke belangrijke keuze benoemt de gediende Design Pillars (P1–P7), de
horrorrationale en de verworpen alternatieven. De creatieve
GD-uitgangspunten van 2026-07-28 zijn bindend verwerkt: bijna zwart als
standaardtoestand, Silent Hill-achtige sfeer, weinig werkende TL-buizen,
realistische zaklampbundel, oriëntatie-zonder-details zonder zaklamp,
licht suggereert veiligheid maar garandeert niets, en licht is schaars en
bewust ontworpen.*

## 1. De lichtfilosofie van CRUMP

**Bijna zwart is de standaardtoestand** — de visuele evenknie van "stilte
is de standaard" (P2). Elke lumen is een uitgave uit een klein budget en
elke lichtbron is ontworpen, met een bron in de wereld (LEVEL §5). Licht
draagt drie betekenissen, en nooit méér dan dat:

- **Oriëntatie**: de speler kan ook zonder zaklamp navigeren — silhouetten,
  contouren en een paar TL-ankers blijven leesbaar (LEVEL §2.1); details
  verdwijnen (uitgangspunt GD). Donker is informatie-arm, nooit
  informatie-loos (HORROR §4).
- **Suggestie van veiligheid — nooit garantie** (P7): lichte zones voelen
  als adem (LEVEL §4), maar er bestaat géén mechanische safe-zone en die
  komt er ook nooit. Het vertrouwen in licht is een gevoel dat wij wekken
  en later kunnen schenden; een regel zou het een meetbaar systeem maken
  en daarmee de twijfel doden.
- **Prijs** (P3): zien kost gezien worden. De zaklamp is de belichaming
  daarvan (§3).

**Silent Hill-achtig** vertalen we technisch als: een lage, koele
ambient-vloer + **diepte-fog** die verte laat oplossen in het donker
(P7: wat je niet kunt uitzien, vul je zelf in), filmische tonemapping en
debanding tegen kleurtrappen in het near-black. Geen letterlijke mist-wolk
(dat is Silent Hills handelsmerk, niet het onze — ons "normaal" is een
Nederlands sportpark bij nacht) en géén volumetrische fog in 006
(duur; heroverwegen bij de presets van fase 6).

## 2. Architectuur — nieuwe onderdelen

```
game/systems/flashlight/      ← verwijdereenheid: de zaklamp (§3)
 └─ flashlight.tscn/gd           (bootstrap-spawn, volgt de actieve camera)

game/props/light_tl/          ← verwijdereenheid: TL-armatuur (§4)
 └─ light_tl.tscn/gd + assets/shaders/flicker_light.gdshader

game/levels/dev_room/         ← nachtstaat (level-data, §5) + werklicht-toggle
game/autoload/settings_manager.gd ← brightness eindelijk toegepast (§6, TD-003)
EventBus                      ← flashlight_toggled(is_on: bool)  (§3/§7)
```

**Keuze A — de zaklamp is een verwijderbaar systeem dat de actieve
viewport-camera volgt** *(P1, P3; patroon D-020, D-015)*. Geen kind van de
spelerscène (dat zou de speler aan de zaklamp klinken — dezelfde
D-015-breuk als altijd) maar een bootstrap-gespawnd systeem met
bestaanscheck, zoals interactor en audio. Het volgt de actieve camera met
een kleine, instelbare na-ijling — dat geeft het handheld-gevoel van een
échte lamp én werkt met elke toekomstige camera. **Verworpen**: zaklamp
in player.tscn (koppeling); zaklamp als opraapbare wereld-prop met eigen
lichtje (leuk, maar dan is "dragen" een tweede systeem — de
inventory-koppeling in §3 geeft hetzelfde gevoel goedkoper).

## 3. Zaklamp als gameplaymechaniek

**Keuze B — realistische bundel, betrouwbare bediening.**
*(P1, P3; HORROR §7)* Eén `SpotLight3D`: warme kleur, realistische
bundel (hoek ~35°, zachte rand via spot-attenuation, bereik ~12 m,
schaduw-werpend — de zaklamp is altijd 1 van het schaduwbudget, §5).
Tuning volledig via exports. **De zaklamp hapert nooit willekeurig**: het
oude scope-punt "subtiele flikker als spanningsinstrument" is bewust
**verworpen** — HORROR §7 belooft dat de bediening betrouwbaar is en P7
legt de twijfel in de wéreld, niet in je gereedschap. Een zaklamp die
zomaar knippert is een goedkoop spookje (en traint de speler om óns niet
te vertrouwen in plaats van de wereld niet). Als een hoofdstuk ooit een
falende zaklamp wil, is dat een ontworpen gebeurtenis met oorzaak en een
eigen ontwerpronde (batterijen — nu geen afnemer, P4, verworpen).

**Keuze C — aan/uit is een keuze met prijs, uitgedrukt in feiten.**
*(P3, P7; kader 005 §1, D-021/D-024)* Toggle via de bestaande input-actie
`flashlight`. Elke toggle zendt drie gescheiden dingen:
1. `EventBus.flashlight_toggled(is_on: bool)` — het feit voor de latere
   AI (007: CRUMP *ziet* licht); zonder ontvanger betekenisloos (D-015);
2. `audio_cue(&"flashlight_click", positie)` — de hoorbare klik (doel:
   informatie, kader 005 §8);
3. `noise_made(positie, ~2 m)` — de klik is óók een gameplay-geluidje.
De prijs is dus tweeledig en leerbaar: licht maakt je zichtbaar (straks),
de klik maakt je nú al hoorbaar. **Geen enkele meter of indicator** toont
"hoe zichtbaar" je bent (P7): de speler leest het uit de wereld — sta ik
in het licht?

**Keuze D — bezit via de inventory, null-veilig.** *(P5; dossier 004)*
Als er een inventory is, werkt de zaklamp alleen wanneer
`has_item(&"zaklamp")` (duck-typed via de groep; het ItemResource bestaat
al sinds 004 — nu krijgt het betekenis). De dev room krijgt een
zaklamp-pickup naast de sleutel. Geen inventory-systeem = zaklamp werkt
gewoon (nette degradatie, zelfde regel als alles). Toggle zonder bezit:
stil niets (geen prompt-gebedel; de speler die 'm niet heeft, weet dat).
**Verworpen**: altijd-beschikbaar (mist de schaarste én het
vindmoment); een harde inventory-dependency (D-015-breuk).

## 4. TL-armaturen — weinig, en dat is het punt

**Keuze E — één herbruikbare prop `light_tl` met drie standen.**
*(P4, P5; LEVEL §5, HORROR §4)* Armatuur = emissive buis-mesh +
neerwaartse `OmniLight3D`/spot; export-stand `WERKEND` / `DEFECT` (uit,
donkere hoek) / `FLIKKEREND`. Flikkeren is een **ontworpen gebeurtenis
met wereld-oorzaak** (een kapotte buis ís zijn eigen verklaring —
hoofdstuk-1-regel HORROR §4) en is **deterministisch** (seed-export,
patroon via `assets/shaders/flicker_light.gdshader` op de emissive +
gekoppelde lichtenergie): reproduceerbaar, testbaar, en geen
random-spook. Weinig werkende buizen is het uitgangspunt: de nachtstaat
van de dev room krijgt er **2 werkend, 1 flikkerend, rest defect** —
werkende TL's zijn oriëntatie-ankers (LEVEL §2.3). **Verworpen**:
per-buis zoem/tik-audio (positionele loops zijn nieuwe
audio-functionaliteit; de nulpunt-laag dekt de zoem — uitbreiding
"positionele ambience-emitters" genoteerd voor een latere taak);
willekeurige flikker zonder patroon (ontestbaar en ongeregisseerd).

## 5. Lichtbudget en performance

*(ARCHITECTURE §7, LEVEL §5)* **Regel: maximaal 4 realtime
schaduw-werpende lichten tegelijk zichtbaar; de zaklamp telt daar altijd
als 1 van** — ruimtes worden dus op 3 ontworpen. Handhaving op twee
niveaus: de **smoke-suite telt** schaduw-werpende lichten in het geladen
level (+ zaklamp) en faalt boven budget; de **F3-overlay** toont "licht:
n/4 schaduw". Overige performance: geen volumetrics (§1), fog =
goedkope exponentiële diepte-fog, debanding aan (vrijwel gratis),
schaduw-atlas blijft preset-gestuurd (TD-002 wordt hier bewust níét
volledig afgelost — presets uitbreiden met fog/SSAO-kwaliteit is fase
6-kalibratiewerk; genoteerd). Meten vóór tunen: fps staat al in F3.

## 6. Brightness/gamma-beleid (lost TD-003 af)

**Keuze F — brightness = `Environment.adjustment_brightness`, toegepast
door een klein herbruikbaar `environment_tuner.gd` op de
WorldEnvironment van elk level.** *(QA §5/§9)* SettingsManager krijgt
een `brightness_changed`-signaal (autoload = infrastructuur; minimale
uitbreiding); de tuner leest bij `_ready` en luistert daarna. **Beleid**:
het spel wordt gekalibreerd op brightness 1.0 — donker-maar-leesbaar
moet dáár kloppen; de slider (0.5–2.0, bestaande clamp) compenseert
schermen en omgevingslicht, en redt nooit slecht lichtontwerp. De
contour-garantie (nooit informatie-loos zwart) geldt op 1.0 en wordt
door de GD op zijn scherm gekalibreerd. **Verworpen**: gamma via een
fullscreen-shader (duurder, en adjustment zit gratis in de pipeline);
brightness per preset (het is een gebruikersinstelling, geen
kwaliteitsknop).

## 7. Relatie licht ↔ zichtbaarheid ↔ latere AI (interface-paragraaf)

006 bouwt géén AI, maar legt de bouwstenen en de grenzen vast:
- Het feit `flashlight_toggled` staat op de bus; 007 abonneert zich.
- CRUMP's zicht (007) gebruikt uitsluitend gedefinieerde zintuigen
  (cone + LOS, HORROR §6) en gaat licht daarin meewegen; hóé (een
  `player_illumination`-meetpunt of iets anders) is een
  007-ontwerpbeslissing — nu bouwen = speculatie (P4, verworpen).
- **Nooit** een zichtbaarheidsmeter voor de speler (P7): zekerheid over
  "ziet hij mij?" blijft verdiend schaars; de speler leest de wereld.

## 8. Sfeerpass dev room + werklicht

**Keuze G — de dev room krijgt de nachtstaat als standaard, met een
werklicht-toggle voor beoordeling.** *(P5; LEVEL §7 blockout-eerst)*
Nachtstaat: SunKey en de heldere test-omni's gaan eruit; ervoor in de
plaats: TL-armaturen (§4), lage koele ambient-vloer, diepte-fog,
debanding, filmische tonemap. De contrast-testobjecten blijven (dat zijn
onze meetpunten). Een export `werklicht` (default `false`) zet de oude
heldere verlichting terug voor geometrie-/blockout-beoordeling — debug,
geen gameplay. De **smoke-visibility-tests worden herijkt** op de
nachtstaat: de KI-001-dekking (camera, zicht, materialen) blijft
onverkort; de licht-drempels toetsen voortaan de donkere waarheid
(ambient > 0 blijft de nooit-pikzwart-garantie; ≥2 actieve lichtbronnen
blijven — de werkende TL's; schaduwbudget ≤ 4 komt erbij).

## 9. Teststrategie

1. **Zaklamp**: systeem gespawnd (bestaanscheck-patroon); toggle via echt
   input-event → licht aan/uit + de drie feiten uit keuze C **gescheiden
   geteld** (kanalen onafhankelijk, kader 005); volgt de actieve camera
   (positie/richting ≈ camera na n frames); bezit-gate: zonder
   zaklamp-item weigert stil, mét item werkt, zonder inventory-systeem
   werkt (D-015-degradatie); tijdens pauze geen toggle (PAUSABLE).
2. **Budget**: telling schaduw-werpende lichten in het geladen level
   (incl. zaklamp aan) ≤ 4.
3. **Environment/brightness**: ambient > 0, fog actief, tonemap
   niet-lineair, debanding aan; `SettingsManager.brightness` zetten →
   `adjustment_brightness` volgt (TD-003-test), terugzetten idem.
4. **TL-prop**: instantieert los; drie standen gedragen zich (werkend =
   licht aan, defect = uit, flikkerend = energie varieert deterministisch
   over frames met vaste seed).
5. **D-015-richtingen**: zonder `game/systems/flashlight/` draait alles
   (geen zaklamp, geen fouten); zonder audio klikt de zaklamp stil maar
   werkt; zonder inventory werkt hij zonder bezit-gate; alles aanwezig =
   alles groen. Testcode noemt geen klassen (D-021).
6. **EventBus-contract**: `flashlight_toggled` met 1 argument in de
   signaturentest.
7. **Beperking**: sfeer, leesbaarheid en het "onaangename" zijn
   hardware-oordelen (GD, met brightness-kalibratie op zijn scherm);
   headless toetsen we waarden en gedrag, niet gevoel.

## 10. Risico's

| Risico | Zwaarte | Mitigatie |
|---|---|---|
| Near-black oogt op elk scherm anders — op de VPS is niets te zien, dus de eerste kalibratie is volledig GD-werk | hoog | bewuste export-defaults + brightness-slider werkend (§6) + expliciete kalibratiestap in de GD-ronde; tuning is data |
| Herijkte visibility-tests verzwakken per ongeluk de KI-001-dekking | middel | alle bestaande checks blijven bestaan; alleen drempelwaarden veranderen mee met de nachtstaat, en de nooit-pikzwart-eis (ambient > 0) blijft hard |
| Zaklamp-schaduw is de duurste losse post | middel | budgetregel (zaklamp = 1 van 4) + atlas per preset; meten in de GD-ronde (F3-fps) |
| Banding/kleurtrappen in near-black | laag | debanding aan; filmische tonemap; placeholder-materialen zijn vlak dus banding valt juist óp — goed testmateriaal |
| Fog maskeert de testobjecten te veel voor de bestaande cameratests | laag | fog-dichtheid als export; suite toetst geometrische zichtbaarheid, niet pixels |
| Werklicht-toggle blijft per ongeluk aan in een build | laag | default false + suite-check dat de nachtstaat de actieve staat is |

## 11. Exit-criteria taak 006

1. Dit ontwerp door de GD gereviewd en akkoord; daarna bouw in vier
   blokken (nacht-environment + brightness/TD-003 → zaklamp-systeem →
   TL-prop + sfeerpass → tests/F3/registers), commit per blok.
2. Suite volledig groen incl. de nieuwe tests (§9) en herijkte
   visibility-checks; import schoon; D-015-richtingen aantoonbaar.
3. Budgetregel aantoonbaar gehandhaafd (test + F3).
4. TD-003 afgelost (brightness werkt); TD-002 expliciet deels open
   gelaten (fase 6-kalibratie) — registers bijgewerkt (CHANGELOG,
   DECISIONS: zaklamp-betrouwbaarheidsbesluit + budgetregel, TECH_DEBT,
   SESSION_STATE, README).
5. **GD-hardware-beoordeling** (de echte lat, fase 2-exit): bijna-zwart
   maar leesbaar zonder zaklamp (oriëntatie ja, details nee); de
   zaklampbundel voelt echt; de TL-hoek met flikkerbuis is onaangenaam;
   het geheel — nulpunt-zoem + near-black + schaarse TL's — maakt de
   testruimte 's nachts onaangenaam *zonder dat er iets gebeurt*.
