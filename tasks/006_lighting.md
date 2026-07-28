# Taak 006 — Licht & sfeer

**Fase**: 2 (Het gereedschap) · **Status**: 🔵 ontwerp v2 (correctieronde verwerkt), wacht op expliciete implementatie-go · **Vereist**: 001, 002

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

# Technisch ontwerp (v2, 2026-07-28 — correctieronde na GD-review)

*Elke belangrijke keuze benoemt de gediende Design Pillars (P1–P7), de
horrorrationale en de verworpen alternatieven. De creatieve
GD-uitgangspunten van 2026-07-28 zijn bindend verwerkt: bijna zwart als
standaardtoestand, Silent Hill-achtige sfeer, weinig werkende TL-buizen,
realistische zaklampbundel, oriëntatie-zonder-details zonder zaklamp,
licht suggereert veiligheid maar garandeert niets, en licht is schaars en
bewust ontworpen.*

*v2 verwerkt de GD-correctieronde van 2026-07-28: exacte
toggle-gevolgen en definitieve bus-signaturen (§3), de
bezitkoppeling zonder klasse-referentie (§3), scheiding licht- en
geluidspositie (§3a), concreet brightnessbeleid met versmalde range
(§6), TL-flikker-invarianten (§4), gedrag bij budgetoverschrijding
(§5), de drie dev-room-teststanden + F3-inhoud (§8) en het
aangevulde testplan (§9). De inhoudelijke richting van v1 is
ongewijzigd.*

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

game/systems/light_budget/    ← verwijdereenheid: schaduwbudget-bewaking (§5)
 └─ light_budget.tscn/gd         (bootstrap-spawn per level, één taak)

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

**Keuze C — aan/uit is een keuze met prijs, uitgedrukt in gescheiden
feiten.** *(P3, P7; kader 005 §1, D-021/D-024)* Toggle via de bestaande
input-actie `flashlight`. **Alleen de zaklampcomponent bezit de
aan/uit-state**; niets anders in het spel houdt of spiegelt die
toestand. Eén inputactie veroorzaakt **maximaal één statewijziging** en
per relevant kanaal **maximaal één emissie**. Een *geslaagde* toggle —
dat wil zeggen: de zaklampstate is werkelijk gewijzigd — zendt daarná
drie onafhankelijke feiten, elk voor een eigen soort afnemer:

1. `flashlight_toggled(is_on: bool)` — **toestandfeit** voor toekomstige
   afnemers (007: CRUMP *ziet* licht). Dit is een feit, géén commando:
   het bestuurt de zaklamp niet en niets kan de zaklamp via dit signaal
   aan- of uitzetten. Zonder ontvanger betekenisloos (D-015).
2. `audio_cue(&"flashlight_click", positie)` — de **hoorbare klik**
   (doel: informatie, kader 005 §8).
3. `noise_made(positie, ~2 m)` — de klik als **gameplaygeluid** voor de
   latere AI (007).

De kanalen veroorzaken elkaar nooit (kader 005) en ontstaan uitsluitend
**nadat** de state werkelijk is gewijzigd. Geen zaklampbezit (§ hieronder)
betekent: geen statewijziging, geen licht, geen audio_cue en geen
noise_made — nul emissies op álle kanalen. De prijs is dus tweeledig en
leerbaar: licht maakt je zichtbaar (straks), de klik maakt je nú al
hoorbaar. **Geen enkele meter of indicator** toont "hoe zichtbaar" je
bent (P7): de speler leest het uit de wereld — sta ik in het licht?

**Definitieve EventBus-signaturen** (uitsluitend basistypen, D-021;
`audio_cue` en `noise_made` bestaan al en wijzigen niet):

```gdscript
## De zaklamp is werkelijk van toestand gewisseld (feit, geen commando;
## taak 006). Alleen de zaklampcomponent zendt dit, uitsluitend ná een
## geslaagde statewijziging. CRUMP's zicht (taak 007) abonneert zich.
signal flashlight_toggled(is_on: bool)

# bestaand, ongewijzigd (taak 005 / taak 001):
signal audio_cue(sound_id: StringName, position: Vector3)
signal noise_made(position: Vector3, loudness: float)
```

**Keuze D — bezit via een gecachte vlag: eenmalig gelezen, daarna
eventgedreven.** *(P5; dossier 004, D-015/D-021)* Het zaklampsysteem
noemt nergens een Inventory-klasse en scant nooit per frame. De
koppeling werkt zo:

- **Initialisatie (eenmalig, bij spawn)**: duck-typed via de groep
  `inventory` — `get_first_node_in_group("inventory")`, en alleen als
  die node `has_method("has_item")` heeft: `has_item(&"zaklamp")` →
  gecachte vlag `_has_flashlight`.
- **Daarna eventgedreven**: abonneren op de bestaande bus-feiten
  `item_added(item: Resource)` / `item_removed(item: Resource)`; de id
  wordt duck-typed gelezen (`item.get("id")` — geen
  ItemResource-klassenaam, D-021). Id `&"zaklamp"` → vlag bijwerken.
  Geen polling, geen frame-werk.
- **Verwijderbaarheid, beide richtingen**: zonder inventory-systeem is
  er geen groepsnode → de bezit-gate vervalt en de zaklamp werkt gewoon
  (nette D-015-degradatie, zelfde regel als alles). Zonder
  zaklampsysteem verandert er niets aan de inventory: die kent de
  zaklamp niet — `zaklamp.tres` is dan een item als elk ander. Beide
  mappen zijn onafhankelijk verwijderbaar; alles blijft parsebaar.
- **Bewust géén** equipment-, hotbar- of selected-item-systeem: bezit
  is een booleaans feit, geen slot (P4 — geen afnemer voor meer).
- **Dev room**: dev_props plaatst een `pickup_item` met het bestaande
  `zaklamp.tres` naast de sleutel-pickup. De GD verkrijgt de zaklamp
  dus via **de echte pickup-flow** (D-022) — geen debug-give of
  autobezit, zodat de lokale test de uiteindelijke zoek-flow (zaklamp
  moet gevonden worden) niet vervalst.

Toggle zonder bezit: stil niets — geen prompt-gebedel (de speler die 'm
niet heeft, weet dat) en géén emissie op welk kanaal dan ook (keuze C).
**Verworpen**: altijd-beschikbaar (mist de schaarste én het
vindmoment); een harde inventory-dependency of klasse-referentie
(D-015/D-021-breuk); per-frame `has_item`-polling (verspilling, en het
maskeert de vraag wie de waarheid bezit).

## 3a. Lichtpositie ≠ geluidspositie

*(P1; kader 005, D-020)* Twee posities, strikt gescheiden:

- **Licht**: de `SpotLight3D` volgt de **actieve viewport-camera**
  (patroon D-020, met de na-ijling uit keuze A). Wat je ziet schijnt
  waar je kijkt — camerahoogte en headbob horen bíj het licht.
- **Geluid**: `audio_cue` en `noise_made` gebruiken de **semantische
  spelerpositie**: `global_position` van de node in de groep `player`
  (de body-origin op vloerniveau — exact dezelfde bron als de
  voetstappen uit 005). Camerahoogte, headbob of near-plane-details
  lekken dus **nooit** in wat de latere AI (007) waarneemt of wat het
  audiosysteem plaatst.
- **Degradatie**: is er geen spelernode (D-015-richting zonder speler),
  dan is er geen subject dat klikt — audio_cue en noise_made blijven
  dan achterwege; `flashlight_toggled` wordt wél gezonden (het licht is
  echt gewisseld) en het licht volgt gewoon de actieve camera.

## 4. TL-armaturen — weinig, en dat is het punt

**Keuze E — één herbruikbare prop `light_tl` met drie expliciete
staten.** *(P4, P5; LEVEL §5, HORROR §4)* Armatuur = emissive buis-mesh
+ neerwaartse `OmniLight3D`/spot; export-enum `STABIEL` (licht aan,
constant) / `DEFECT` (uit, donkere hoek) / `FLIKKEREND`. Flikkeren is
een **ontworpen gebeurtenis met wereld-oorzaak** (een kapotte buis ís
zijn eigen verklaring — hoofdstuk-1-regel HORROR §4), deterministisch
via seed-export en `assets/shaders/flicker_light.gdshader` op de
emissive + gekoppelde lichtenergie. Weinig werkende buizen is het
uitgangspunt: de nachtstaat van de dev room krijgt er **2 stabiel,
1 flikkerend, rest defect** — stabiele TL's zijn oriëntatie-ankers
(LEVEL §2.3).

**Invarianten (bindend):**

- De drie staten zijn **expliciet en per lamp** in de editor gekozen;
  er bestaat geen automatische overgang tussen staten in taak 006.
- **DEFECT flikkert nooit**: kapot betekent hier uit. Flikkeren is een
  bewuste per-lamp-keuze (`FLIKKEREND`), nooit een bijverschijnsel van
  defect.
- **STABIEL flikkert nooit spontaan** — onder geen enkele voorwaarde.
- Flikkerpatronen zijn **deterministisch** (vaste seed → identiek
  verloop) en **bevatten rust**: het patroon is grotendeels áán met
  korte onderbrekingen, geen continue strobe — reproduceerbaar,
  testbaar, en de speler krijgt adem tussen de haperingen.
- **Geen horror-eventsequencer en geen globale flikkercontroller** in
  taak 006: iedere lamp is autonoom. Verhaalde uitval, gescripte
  black-outs en CRUMP-gekoppelde lichtreacties zijn aparte
  content-/gameplaytaken met een eigen ontwerpronde (P4 — nu bouwen is
  speculatie).

**Verworpen**: per-buis zoem/tik-audio (positionele loops zijn nieuwe
audio-functionaliteit; de nulpunt-laag dekt de zoem — uitbreiding
"positionele ambience-emitters" genoteerd voor een latere taak);
willekeurige flikker zonder patroon (ontestbaar en ongeregisseerd);
automatische flikker op iedere defecte lamp (dan is flikkeren geen
ontwerpkeuze meer maar ruis).

## 5. Lichtbudget en performance

*(ARCHITECTURE §7, LEVEL §5)* **Regel: maximaal 4 realtime
schaduw-werpende lichten tegelijk zichtbaar; de zaklamp heeft daarvan
altijd een gereserveerd slot** — levels worden dus op **3** ontworpen.
In taak 006 zijn alle level-lampen statische scene-data: er bestaat
**geen dynamische licht-spawning**, dus een overschrijding is per
definitie een configuratiefout, geen runtime-verrassing.

**Handhaving in drie lagen:**

1. **Tests vangen de configuratiefout**: de smoke-suite telt de
   schaduw-werpende `Light3D`-nodes in het geladen level; meer dan 3
   (= 4 incl. het zaklamp-slot) is een **testfalen** — de fout haalt
   `main` niet.
2. **Runtime-diagnose**: een kleine verwijdereenheid
   `game/systems/light_budget/` (bootstrap-gespawnd per level, zelfde
   bestaanscheck-patroon als de interactor) telt bij levelload de
   schaduw-werpende lichten. Boven budget: één `push_warning` per
   gedegradeerde lamp met nodepad en de telling ("licht-budget: 5/3
   level-schaduwlichten — schaduw uitgeschakeld op <pad>"). Dit script
   heeft precies één taak; het is bewust **géén** generiek
   lightmanagement-framework — geen registratie-API, geen dynamische
   herverdeling, geen kwaliteitsbeheer (P4).
3. **Deterministische degradatie**: de zaklamp verliest **nooit** zijn
   schaduw (gereserveerd slot; hij is bovendien geen level-kind, dus de
   level-telling raakt hem niet). Van de level-lampen behouden de
   **eerste 3 in scene-boomvolgorde** hun schaduw; iedere volgende
   krijgt `shadow_enabled = false` — de lamp blijft áán, alleen de
   schaduw vervalt. Boomvolgorde is vast in de scene-data, dus de
   uitkomst is elke run identiek en headless testbaar.

Zonder `game/systems/light_budget/` (D-015-verwijdering) vervalt alleen
de runtime-diagnose en -degradatie; de suite-telling blijft de
configuratiefout vangen en zaklamp/TL's draaien onverstoord door. De
**F3-overlay** toont de telling duck-typed via de groep (§8). Overige
performance: geen volumetrics (§1), fog = goedkope exponentiële
diepte-fog, debanding aan (vrijwel gratis), schaduw-atlas blijft
preset-gestuurd (TD-002 wordt hier bewust níét volledig afgelost —
presets uitbreiden met fog/SSAO-kwaliteit is fase 6-kalibratiewerk;
genoteerd). Meten vóór tunen: fps staat al in F3.

## 6. Brightness/gamma-beleid (lost TD-003 af)

**Keuze F — brightness = `Environment.adjustment_brightness`, toegepast
door een klein herbruikbaar `environment_tuner.gd` op de
WorldEnvironment van elk level.** *(QA §5/§9)*

**Concrete waarden en aangrijpingspunt:**

- **Standaardwaarde 1.0** — het neutrale punt; het spel wordt hierop
  gekalibreerd en donker-maar-leesbaar moet dáár kloppen.
- **Range 0.8–1.2, geclampt** in SettingsManager: zowel bij het laden
  uit `settings.cfg` als in een setter `set_brightness()` gaat elke
  waarde door `clampf(value, 0.8, 1.2)`. Waarden uit een oude
  settings.cfg buiten de range worden dus stil binnen de range
  getrokken.
- **Motivatie van de rangewijziging** (bestaand model: clamp 0.5–2.0):
  die brede clamp stamt uit taak 001, toen brightness nog nergens op
  aangreep (TD-003) — er is dus geen bestaand spelersgedrag om te
  bewaren. Nu de waarde echt effect krijgt, past de brede range niet
  bij het lichtontwerp: ×2.0 tilt het near-black naar een grijs
  schemerbeeld (het "nachtbeeld wordt dagbeeld"-verbod) en ×0.5 drukt
  de gekalibreerde contour-garantie onder de leesbaarheidsgrens. De
  versmalde range **0.8–1.2** compenseert reële scherm- en
  omgevingslichtverschillen, maar kan het lichtontwerp niet herschrijven
  en redt nooit slecht lichtontwerp. Afwijken van deze range vraagt een
  nieuw GD-besluit.
- **Aangrijpingspunt, exact**: `environment_tuner.gd` zet
  `adjustment_enabled = true` en schrijft `adjustment_brightness` op de
  **Environment-resource van de WorldEnvironment-node van het geladen
  level** — niets anders. SettingsManager krijgt een
  `brightness_changed(value: float)`-signaal (autoload =
  infrastructuur; minimale uitbreiding); de tuner leest bij `_ready` en
  luistert daarna.
- **Wat brightness níét raakt**: de UI-lagen (debug-overlay,
  debug-prompt, latere HUD) zijn `CanvasLayer`s en vallen buiten de
  3D-adjustment-pipeline — F3 en prompts blijven dus altijd gelijk
  leesbaar. Geen enkele `Light3D`-energie, TL-staat of budgettelling
  (§5) verandert mee: brightness is een nabewerking op het eindbeeld,
  geen lichtbron.
- **Nachtgarantie**: op het maximum (1.2) blijft nacht nacht — de
  multiplicatieve aanpassing op een near-black beeld verschuift de
  leesbaarheidsgrens licht, maar kan structureel geen dagbeeld maken;
  de contour-garantie (nooit informatie-loos zwart) geldt op 1.0 en
  wordt door de GD op zijn scherm gekalibreerd.

**Verworpen**: gamma via een fullscreen-shader (duurder, en adjustment
zit gratis in de pipeline); brightness per preset (het is een
gebruikersinstelling, geen kwaliteitsknop); de oude range 0.5–2.0
handhaven (zie motivatie hierboven).

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
blijven — de stabiele TL's; schaduwbudget ≤ 4 komt erbij).

**De drie acceptatie-toestanden voor de lokale GD-ronde**, en hoe je
ertussen wisselt:

| Toestand | Doel | Hoe |
|---|---|---|
| **Werklicht aan** | inspectie van props, geometrie en systemen | in de editor op de dev-room-node de export `werklicht` op `true` zetten en F5 draaien; daarna terug op `false` (de suite bewaakt dat `false` de gecommitte standaard blijft) |
| **Nacht zonder zaklamp** | oriëntatie op silhouetten en de schaarse TL-ankers; details verdwijnen | gewoon starten (nachtstaat ís de standaard) en de zaklamp-pickup **niet** oprapen |
| **Nacht met zaklamp** | details lokaal leesbaar in de bundel; verte en periferie blijven donker | de zaklamp-pickup oprapen via de echte flow (§3, keuze D) en toggelen met de `flashlight`-toets |

**F3-overlay** krijgt er twee regels bij (beide duck-typed via groepen,
zelfde patroon als de inventory- en audioregel — de overlay overleeft
elke verwijdering):

```
zaklamp: bezit ja · aan          ← bezit + aan/uit (— zonder systeem)
licht: 3/4 schaduw · helderheid 1.0 · tl: 2 stabiel / 1 flikkert / 5 defect
```

— dus: zaklampbezit, zaklamp aan/uit, brightnesswaarde, actieve
schaduwlichten t.o.v. het budget en een compacte telling van de
TL-staten in het geladen level.

## 9. Teststrategie

1. **Zaklamp**: systeem gespawnd (bestaanscheck-patroon); toggle via echt
   input-event → licht aan/uit + de drie feiten uit keuze C **gescheiden
   geteld** (kanalen onafhankelijk, kader 005); volgt de actieve camera
   (positie/richting ≈ camera na n frames); tijdens pauze geen toggle
   (PAUSABLE).
   - **Zonder bezit: nul gevolgen** — geen statewijziging, en op géén
     van de drie kanalen (`flashlight_toggled`, `audio_cue`,
     `noise_made`) ook maar één emissie.
   - **Geslaagde toggle: exact één emissie per kanaal** — ieder feit
     precies één keer per inputactie, en pas ná de statewijziging.
   - **Positiescheiding (§3a)**: het licht volgt de camera, maar de
     positie in `audio_cue`/`noise_made` is de spelerpositie
     (groep `player`, body-origin) — aantoonbaar ongelijk aan de
     camerapositie zodra de camera op ooghoogte staat.
   - **Bezit eventgedreven**: vlag wordt correct bijgewerkt door
     `item_added`/`item_removed` (oppakken → toggle werkt; verwijderen
     → toggle weigert weer stil), zonder frame-polling.
2. **Budget**: telling schaduw-werpende lichten in het geladen level ≤ 3
   (+ het zaklamp-slot = 4 totaal).
   - **Overschrijding is deterministisch**: testscène met te veel
     schaduwlampen → de eerste 3 in boomvolgorde behouden schaduw, de
     rest verliest hem (`shadow_enabled == false`), de zaklamp behoudt
     zijn schaduw altijd, en er verschijnt een debug-warning met nodepad
     en telling.
3. **Environment/brightness**: ambient > 0, fog actief, tonemap
   niet-lineair, debanding aan; `SettingsManager.brightness` zetten →
   `adjustment_brightness` volgt (TD-003-test), terugzetten idem.
   - **Clamp en default**: default is 1.0; waarden buiten 0.8–1.2
     (zowel via de setter als uit een settings.cfg) worden op de
     randen geclampt.
4. **TL-prop**: instantieert los; drie staten gedragen zich (STABIEL =
   licht aan, DEFECT = uit, FLIKKEREND = energie varieert deterministisch
   over frames met vaste seed).
   - **Determinisme**: twee runs met dezelfde seed geven hetzelfde
     patroonverloop; het patroon bevat rustperioden.
   - **Flikker stopt correct**: staat omzetten naar STABIEL/DEFECT
     beëindigt het flikkeren onmiddellijk en definitief.
   - **STABIEL flikkert nooit spontaan**: energie blijft constant over
     een gemeten frame-reeks.
5. **D-015-richtingen**: zonder `game/systems/flashlight/` draait alles
   (geen zaklamp, geen fouten); zonder `game/systems/light_budget/`
   draait alles (alleen de runtime-diagnose vervalt); zonder audio klikt
   de zaklamp stil maar werkt; zonder inventory werkt hij zonder
   bezit-gate; **zonder de complete lighting-oplevering** (flashlight +
   light_budget + light_tl-prop) blijven player, inventory, audio en
   levels parsebaar en draait de suite van de overgebleven systemen
   groen; alles aanwezig = alles groen. Testcode noemt geen klassen
   (D-021).
6. **EventBus-contract**: `flashlight_toggled` met 1 argument in de
   signaturentest.
7. **Dev-room-nachtstaat**: de herijkte visibility-checks (§8) tonen dat
   de ruimte zonder zaklamp structureel navigeerbaar blijft — ambient
   > 0, ≥2 actieve lichtbronnen (de stabiele TL's), camera ziet
   geometrie — voor zover headless toetsbaar; `werklicht == false` is de
   gecommitte standaard.
8. **Beperking**: sfeer, leesbaarheid en het "onaangename" zijn
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
