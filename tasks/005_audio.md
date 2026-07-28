# Taak 005 — Audio-fundament

**Fase**: 2 (Het gereedschap) · **Status**: ✅ gebouwd conform ontwerp (v0.0.16), **wacht op lokale GD-test** · **Vereist**: 001, 002

> **Gebouwd 2026-07-28** in vier blokken. Suite 145 → 166 (alle
> kader-tests §10.1 incl. finished-release — de headless-driver bleek
> streams écht af te spelen, dus pool-vrijgave is tóch headless getest);
> D-015: zonder audio 145, zonder interactie 109, alles 166. AudioDirector
> ongegroeid. Canonnotitie: de zeldzame CRUMP-schreeuw wordt later een
> gewone cue via dit fundament (007+), geen gedrag in 005.
>
> **Doelentabel placeholder-geluiden (kader §8)** — elk geluid dient een
> benoemd doel:
>
> | Cue-id | Doel | Toelichting |
> |---|---|---|
> | `footstep_walk/sneak/run/crouch` | informatie | de speler hoort zijn eigen waarneembaarheids-prijs (P3) |
> | `door_creak_open/close` | informatie | deurgebruik is een gebeurtenis, ook voor het eigen oor |
> | `door_rattle` | informatie | "op slot" hoorbaar bevestigd zonder UI |
> | `drawer_open/close` | informatie | idem la |
> | `item_pickup` | informatie | opname bevestigd; bewust subtiel, geen beloningsjingle |
> | `amb_hum_koeling` | sfeer | het stilte-nulpunt van HORROR §3; het wégvallen ervan wordt later een gebeurtenis |

Geluid is in CRUMP geen aankleding maar het belangrijkste horror-instrument
(GAME_BIBLE pijler 1, HORROR_GUIDELINES §3). Deze taak bouwt het fundament:
mixstructuur, ambience-lagen, en geluid-als-gameplay.

## Bindend architectuurkader (GD, 2026-07-28 — vastgelegd n.a.v. de
## "geen pickupgeluid"-bevinding bij taak 004)

*Dit kader is bindend voor de uitwerking van deze taak en wint bij
strijdigheid van de oudere scope-/aanpaktekst hieronder (met name het punt
dat sfx rechtstreeks uit `noise_made` zouden volgen — dat wordt bij de
start van 005 herzien conform dit kader).*

1. **`noise_made(position, loudness)` is gameplay-informatie** voor
   AI/gehoor (taak 007) — het is **niet** hetzelfde als hoorbare audio en
   wordt dat ook nooit. De twee blijven **afzonderlijke concepten met
   afzonderlijke signalen**.
2. **Hoorbare one-shot audio wordt afgespeeld door het audiosysteem**, in
   zijn eigen boom — nooit door een AudioStreamPlayer-child van een prop
   die tegelijk kan verdwijnen.
3. **Props (pickup, deur, la, …) sturen uitsluitend een semantisch
   audio-event of audioverzoek uit** ("er is een sleutel opgepakt op
   positie X"); ze spelen zelf niets af en bezitten geen audio-lifecycle.
4. **Het audiosysteem bezit de AudioStreamPlayer-lifecycle** en laat elk
   gestart geluid zelfstandig uitspelen.
5. **De inventory beslist uitsluitend accept/reject** en heeft geen enkele
   audioverantwoordelijkheid (D-022/§5c van dossier 004).
6. **Het verwijderen van een prop mag een reeds gestart one-shot geluid
   nooit afkappen** — de motiverende bug-in-wording: een geaccepteerde
   pickup krijgt `queue_free` binnen hetzelfde frame en zou als
   audio-eigenaar zijn eigen geluid onthoofden.
7. **Verplichte tests in taak 005**:
   - een one-shot blijft afspelen nadat de bronprop uit de wereld is
     verdwenen;
   - één gameplayactie veroorzaakt maximaal één hoorbare one-shot;
   - een geweigerde pickup veroorzaakt geen pickup-audio;
   - `noise_made` en hoorbare audio blijven aantoonbaar afzonderlijke
     concepten en signalen (aparte emissies, apart te testen).
8. **Geen geluid bestaat uitsluitend als opvulling** *(aanvulling GD,
   correctieronde 2026-07-28)*: iedere hoorbare gebeurtenis dient
   minimaal één doel — **sfeer**, **informatie** of **spanning** — en dat
   doel is benoembaar bij review. Decoratieve audio die alleen leegte
   opvult is strijdig met de Design Pillars (P2: stilte is de
   standaardtoestand; P4: wat vaak klinkt verliest lading; P7: elk
   geluid dat niets betekent, traint de speler om geluid te negeren).
   Praktisch: elke SoundResource en elke ambience-laag krijgt bij
   toevoeging zijn doel in één woord in de beschrijvende commit/dossier;
   "het was zo stil" is nooit een reden.

## Doel

Een `AudioDirector`-autoload die de mix, ambience en cues beheert, plus de
koppeling die van speler-acties hoorbare gebeurtenissen maakt — en die
gebeurtenissen leesbaar houdt voor CRUMP (taak 007).

## Scope

**Wel:**
- **`AudioDirector`** (autoload) als enige systeem dat met audiobussen praat
  (ARCHITECTURE §4): volumes per bus (Master/SFX/Ambience/Music/Voice),
  ducking, fades.
- **Ambience-systeem**: gelaagde omgevingsgeluiden (het "nulpunt" uit
  HORROR_GUIDELINES §3) die per ruimte/toestand in- en uitgefade kunnen worden.
- **Geluid-als-event**: `AudioDirector` (of een dun geluid-systeem) luistert
  op `EventBus.noise_made(position, loudness)` en speelt de bijbehorende 3D-sfx
  af — één plek waar "iets maakt geluid" audio wordt, voor voetstappen (002),
  deuren en vallende props (003).
- **3D-positionele audio**: correcte richting/afstand, testbaar op koptelefoon.
- **Muziek-cues** (schaars): API om spanning te laten stijgen/dalen, met de
  regel dat muziek de AI niet verklapt (HORROR_GUIDELINES §3).
- **Volume-instellingen** koppelbaar aan het latere opties-menu (per bus).
- Placeholder-audio waar nodig, **gegenereerd** via een `tools/`-script en
  gedocumenteerd (CLAUDE.md: geen assets verzinnen).

**Niet:**
- Geen finale sounddesign/asset-productie (dat is doorlopend contentwerk).
- Geen monster-audio-gedrag (dat komt in 007, dit levert de haken).

## Aanpak

1. `AudioDirector` bouwen: busbeheer, fades, ducking, ambience-lagen.
2. Geluid-systeem abonneren op `noise_made`; map luidheid → sfx + volume +
   3D-positie. Sluit voetstappen (002) en deuren/props (003) hierop aan.
3. Voetstap-sets als `Resource` (per ondergrond: beton, tapijt, metaal) zodat
   uitbreiden data is, geen code.
4. Muziek-cue-API met een klein toestandsmodel (rust/spanning) los van de AI.
5. Placeholder-geluiden genereren met een tool-script; documenteren.
6. Tests: `noise_made` leidt tot een audio-afspeling met juiste bus/positie;
   busvolumes reageren op instellingen; ambience-fade werkt.
7. Commits met `[005]`-prefix.

## Acceptatiecriteria

- [ ] `AudioDirector` beheert alle bussen; niets anders praat direct met audio.
- [ ] `noise_made`-events resulteren in correct gepositioneerde 3D-sfx.
- [ ] Ambience-lagen faden per toestand; nulpunt-stilte klopt.
- [ ] Voetstap-ondergronden zijn data (resources), geen code.
- [ ] Muziek-cue-API werkt en is ontkoppeld van de AI.
- [ ] Busvolumes instelbaar (haak voor opties-menu).
- [ ] Placeholder-audio gegenereerd + gedocumenteerd.
- [ ] Headless-import schoon; audio-event-tests groen. Dossier + README
      bijgewerkt.

## Te beoordelen op hardware (VPS kan dit niet)

Mix, 3D-positionering en de balans koptelefoon-vs-speakers (QA_CHECKLIST §4)
zijn niet headless te beoordelen. Lever met een korte testscène-instructie
zodat Randy het op de ontwikkelmachine kan horen.

---

# Technisch ontwerp (v1, 2026-07-28 — ter review GD)

*Uitwerking binnen het bindende architectuurkader hierboven. Elke
belangrijke keuze benoemt de gediende Design Pillars (P1–P7), waarom hij
de horrorervaring versterkt, en welke alternatieven bewust afvielen.
De oude "Aanpak"-sectie hierboven is hiermee vervangen waar strijdig
(m.n. sfx-rechtstreeks-uit-noise_made).*

## 1. Scope

**Wel:** het hoorbare fundament — één afspeelsysteem (one-shots +
ambience-lagen + muziek-cue-API), het semantische audio-event op de bus,
sound-definities als resources, per-gait voetstapaudio, placeholder-audio
via een tool-script, de F3-regel "actieve geluiden", en tests conform het
kader.

**Expliciet niet:** finale sounddesign/assets; monster-audio (007);
ondergrond-detectie voor voetstappen (structuur wél data-klaar, één
ondergrond "beton" nu); UI-/menugeluiden; koppeling van busvolumes aan een
optiescherm (API bestaat al, het scherm niet); reverb/omgevingseffecten;
aflossen van TD-005 (deur/la-tweens) — dat is een klein vervolg zodra dit
fundament het ritme geeft, geen onderdeel van 005 zelf.

## 2. Architectuur — wie doet wat

```
EventBus (autoload, feiten)
 ├─ noise_made(position, loudness)        ← GAMEPLAY, bestaat al; blijft exact zo
 └─ audio_cue(sound_id, position)         ← NIEUW: "deze actie klinkt als X op Y"

AudioDirector (autoload, bestaat al)      = ALLEEN mixer: bussen, volumes,
                                            fades/ducking. Praat als enige
                                            met AudioServer. Groeit NIET.

game/systems/audio/  (verwijdereenheid, gespawnd door bootstrap onder SceneHost)
 └─ audio_system.tscn/gd  (groep "audio_system")
     ├─ OneShotPool   — vaste pool AudioStreamPlayer3D's (eigenaar lifecycle)
     ├─ Ambience      — gelaagde loops met fade-API (bus Ambience)
     └─ Music         — cue-API rust/spanning (bus Music), zonder triggers
```

**Keuze A — het afspeelsysteem is een verwijderbaar systeem, géén
uitbreiding van AudioDirector.** *(P4 minder-is-enger, P5 wereld-groter,
D-015)* AudioDirector blijft de dunne mixer die hij is; alles wat klinkt
leeft in `game/systems/audio/` en is met map-weggooien te verwijderen —
het spel wordt dan stil maar draait (net als zonder inventory). Dit is
tegelijk het antwoord op de God-Object-zorg: de autoload krijgt er nul
verantwoordelijkheden bij, en toekomstige uitbreidingen (reverb-zones,
occlusie, monster-audio) worden **kinderen of buren van het
audio-systeem**, nooit methodes op de autoload. **Verworpen**: alles in
AudioDirector (het door de GD benoemde God-Object; bovendien is een
autoload niet verwijderbaar, dus D-015-onverenigbaar); een zesde autoload
(lat van D-005/D-011 niet gehaald — er is geen reden waarom audio vóór de
eerste scène zou moeten bestaan).

**Keuze B — één semantisch bus-feit: `audio_cue(sound_id: StringName,
position: Vector3)`.** *(P2 stilte-standaard, kader §1/§3, D-021)* Bronnen
(speler, deur, pickup) zenden voortaan twee gescheiden feiten: het
gameplay-feit `noise_made` (voor CRUMP's gehoor) én het hoorbare feit
`audio_cue` ("hier klinkt een deurkraak"). Geen ontvanger = stilte, geen
fout — precies de D-015-degradatie die de pickup al heeft. Dit versterkt
de horror omdat de twee kanalen onafhankelijk tuning krijgen: iets kan
gameplay-luid zijn maar akoestisch subtiel (en andersom — een geluid dat
de speler hóórt maar dat níéts registreert, is pijler-7-materiaal).
**Verworpen**: audio afleiden uit `noise_made` (oude aanpak-tekst —
verbiedt het kader, en het lijmt de twee concepten juist aan elkaar);
per-prop-signalen als `door_creaked` (signaalexplosie, bus vervuilt);
directe aanroepen op het audiosysteem vanuit props (koppeling, en
commando's horen niet op props thuis).

**Keuze B2 — expliciete evaluatie: StringName-id vs. AudioCueResource
(correctieronde GD, 2026-07-28).** Besluit: **het blijft een
`StringName`-id op de bus** — en dat is geen breuk met resource-first,
maar de toepassing ervan op de juiste laag:

- *Resource-first geldt voor de data, niet voor de grensovergang.* De
  audiodata ís al een resource (`SoundResource`, §3: streams, bus,
  volume, pitch, afstand). Een `AudioCueResource` zou daar niets aan
  toevoegen behalve een tweede bestand dat een id omhult — pure
  indirectie, het soort over-engineering dat P4 verbiedt. Alles wat een
  cue-resource zou kunnen dragen, woont al in de SoundResource.
- *De id is de enige vorm die D-015 volledig overleeft.* Zou een prop een
  audio-resource als export dragen, dan verwijst zijn scène (of het
  level dat hem plaatst) hard naar een bestand in
  `game/systems/audio/` — en dan breekt het weggooien van het
  audiosysteem elke scène die ooit een geluid noemde. Een StringName
  verwijst naar níéts: zonder audiosysteem is hij een betekenisloos
  woordje, precies zoals `noise_made` zonder monster betekenisloos is.
  Dit is dezelfde discipline als D-021 (basistypen op de bus) en dezelfde
  reden waarom items richting saves op id's draaien (dossier 004 §6):
  **id's zijn onze grensvaluta; resources zijn onze binnenlandse
  economie.**
- *Het bekende risico van strings — typo's falen stil — wordt actief
  afgedekt*: (1) een onbekend id logt luid (`push_warning`) bij de eerste
  trigger; (2) de suite draait de gebouwde bronnen end-to-end af (deur,
  pickup, voetstap) en faalt als hun id niet tot een SoundResource
  resolvet; (3) de id-discipline uit §3 (uniek, niet leeg, mapscan) is
  identiek aan het bewezen 004-patroon. Daarmee is het restrisico een
  typo in een nog-nooit-getriggerde toekomstige prop — die bij de eerste
  playtest luid opduikt.

**Verworpen**: `AudioCueResource` (indirectie zonder eigen data; en met
eigen data zou hij de SoundResource dupliceren); props die rechtstreeks
een `SoundResource` exporteren (editor-gemak en typo-vrij, maar de
D-015-breuk hierboven weegt zwaarder — en het editor-gemak bestaat
alsnog: de id-lijst staat in één map).

**Keuze C — plaats in de boom: SceneHost-kind via het bestaande
bootstrap-spawnpatroon.** *(P6 systemen-boven-regie, KI-003)* Pauzeert mee
met de wereld (Esc = ook akoestische stilte — de pauze is geen tweede
mixer nodig), overleeft levelwissels (ambience fadet over een wissel heen
i.p.v. hard te knippen), zelfde bestaanscheck-guard als inventory.
**Verworpen**: per-level spawnen (knipt ambience en lopende one-shots af
bij elke wissel).

## 3. Sound-datamodel

**Keuze D — `SoundResource` (.tres) per semantische id, in
`game/systems/audio/sounds/`.** *(P2, P4; CODING_STANDARDS §5; patroon
identiek aan items/ uit 004)* Velden, bewust minimaal:

| Veld | Type | Betekenis |
|---|---|---|
| `id` | `StringName` | uniek en stabiel; de sleutel die bronnen in `audio_cue` gebruiken |
| `streams` | `Array[AudioStream]` | 1..n varianten; afspelen kiest willekeurig (herhaling doodt onbehagen — P7: geen twee keer exact hetzelfde kraakje) |
| `bus` | `StringName` | default `&"SFX"`; moet bestaan in AudioDirector.BUSES |
| `volume_db` | `float` | basisvolume |
| `pitch_spread` | `float` | ± willekeurige pitch (0 = uit) — dezelfde deur klinkt nooit identiek |
| `max_distance` | `float` | 3D-draagafstand van het hóórbare geluid |

De suite dwingt af (patroon 004): alle .tres laden, id's uniek en niet
leeg, `streams` niet leeg, `bus` bestaat. **Tuning-richtlijn, geen harde
test**: `max_distance` van een geluid ligt in dezelfde orde als de
`noise_made`-luidheid van dezelfde actie (HORROR §3: wat de speler hoort ≈
wat de wereld registreert) — een bewuste afwijking is een ontwerpkeuze
(P7), geen bug. **Verworpen**: een centrale registry-resource (tweede
administratie naast de map — de mapscan volstaat, net als bij items);
uitgebreide velden (loop-instellingen, categorieën, prioriteiten) zonder
afnemer.

## 4. One-shot-lifecycle (kader §2/§4/§6)

**Keuze E — vaste pool van N AudioStreamPlayer3D's (export, default 12),
eigendom van het audiosysteem.** *(P2, P4; kader §4)* Flow:
`audio_cue` → lookup sound_id (onbekend id = `push_warning`, stil verder)
→ vrije speler uit de pool → stream/positie/bus/pitch instellen → play →
bij `finished` terug naar de pool. De speler staat in de boom van het
audiosysteem, dus **een verdwijnende prop kapt niets af** (kader §6) — de
prop was al geen eigenaar. Pool vol: de langstspelende wordt gestolen
(debug-log); dat is hoorbaar het minst erg én begrensd geheugen.
**Verworpen**: player-per-geluid spawnen (onbegrensd, en precies het
lifecycle-lek dat het kader verbiedt); AudioStreamPlayer als prop-child
(de motiverende bug); prioriteitensysteem (geen afnemer — P4).

## 5. Ambience — spanningsinstrument, geen behang

**Keuze F — benoemde lagen, standaard UIT, met fade-API.** *(P2
stilte-standaard, P5, HORROR §3)* `Ambience` beheert een set lagen
(loopende streams op de Ambience-bus) met per laag `set_layer(id, actief,
fade_s)`. **De standaardtoestand van elke laag is stil**; een level (of
straks een trigger) zet expliciet zijn nulpunt aan. De dev room activeert
bij wijze van test één nulpunt-laag ("tl-zoem/koeling") zodat de
hardware-beoordeling iets te horen heeft — gedocumenteerd als testkeuze,
niet als regel. Dit versterkt de horror omdat ambience zo een
*instrument* wordt: het wegvallen van een laag is een gebeurtenis
(ladder-trede 1) in plaats van onopgemerkt behang. **Verworpen**:
altijd-aan ambience ("sfeer") — dat is opvulling, en het ontneemt ons het
enge moment waarop de koeling stopt; per-ruimte autoplay-logica (bestaat
nog geen ruimte-systeem — niet vooruitbouwen, P4).

## 6. Muziek — API zonder triggers

**Keuze G — minimale cue-API (`play_cue(id, fade)`, `stop_cue(fade)`),
niets roept hem aan.** *(P2, P4; GD-eis "geen gameplaymuziek behalve waar
afgesproken"; HORROR §3: muziek verklapt de AI nooit)* In 005 bestaat
alleen het mechaniek + test; er is géén muziekcontent en géén systeem dat
cues start. Het rust/spanning-toestandsmodel uit de oude aanpak-tekst
wordt **uitgesteld** tot er een afnemer is (op z'n vroegst 007, en dan als
eigen ontwerpbeslissing — de regel "één keer per hoofdstuk gevaar zonder
muziek" maakt dit per definitie regie-gevoelig). **Verworpen**: nu al een
spanningsmodel bouwen (speculatieve abstractie, P4/P6-schending).

## 7. Voetstappen (koppeling met 002)

**Keuze H — de speler zendt per stap náást `noise_made` ook
`audio_cue(&"footstep_<gait>", positie)`; de klank per ondergrond is een
`FootstepSetResource`.** *(P1 kwetsbaarheid, P3 gezien-worden, HORROR §3
tweerichtingsverkeer)* Sluipen klinkt záchter en anders dan rennen — de
speler hoort zijn eigen prijs (P3: de inschatting "dit was te luid" moet
kloppen met wat de wereld registreerde). Ondergrond: één set ("beton")
nu; de resource-structuur (per ondergrond een set met per-gait volumes)
maakt uitbreiden data. **Verworpen**: ondergrond-detectie via raycast/
materialen nú bouwen (geen tweede ondergrond bestaat — P4); voetstappen
alleen als gameplay-feit laten (de speler die zichzelf niet hoort,
ondermijnt precies het leren van P3).

## 8. Placeholder-audio

**Keuze I — gegenereerd door `tools/genereer_placeholder_audio.gd`
(headless-runnable), wegschrijvend naar `assets/audio/`.** *(CLAUDE.md:
geen assets verzinnen; P4)* Korte synthetische geluiden (noise-bursts voor
voetstappen, lage kraak voor de deur, klikje voor oppakken, zoem-loop
voor de nulpunt-laag), conform naamconventie
(`sfx_footstep_walk_01.wav`). Gedocumenteerd als wegwerp: elke echte
asset vervangt 1-op-1 een placeholder via de SoundResource, zonder code.
**Verworpen**: externe placeholder-packs (licentie/herkomst-ruis, en de
regel is: genereren of niets).

## 9. Debug-zichtbaarheid

De bestaande F3-haak "actieve geluiden" gaat leven: `n/pool · ids van nu
spelende one-shots + actieve ambience-lagen`, null-veilig via de groep,
duck-typed (patroon van de inventory-regel). *(Bewust géén in-game
bevestigings-UI — P7: de spéler krijgt geen zekerheid, de ontwikkelaar
wel, en alleen achter F3 in debugbuilds.)*

## 10. Tests (suite-uitbreiding; kader §7 verplicht)

1. **Kader-tests (verplicht)**: one-shot speelt door nadat de bronprop is
   verdwenen (pickup-accept → prop weg → pool-speler nog actief met de
   juiste stream); één gameplayactie ⇒ maximaal één hoorbare one-shot;
   geweigerde pickup ⇒ géén pickup-audio; `noise_made` en `audio_cue`
   zijn aantoonbaar gescheiden emissies (apart geteld op de bus).
2. **Datamodel**: alle SoundResources laden; id's uniek/niet leeg;
   streams niet leeg; bus bestaat in AudioDirector.BUSES.
3. **Pool**: onbekend sound_id = warning + geen crash; pool-uitputting
   steelt de langstspelende (aantal spelers blijft N); positie van de
   3D-speler = event-positie; bus-toewijzing klopt.
4. **Ambience**: laag aan/uit met fade verandert de laag-status; standaard
   is álles uit (P2-test: een vers audiosysteem is stil).
5. **Muziek-API**: cue start/stop zonder dat iets anders hem triggert.
6. **D-015 drie richtingen**: zonder `game/systems/audio/` blijven speler,
   props en inventory exact werken (alleen stil); zonder interactie/
   inventory blijft audio idle; alles aanwezig = alles groen. Testcode
   noemt audio-klassen nooit bij naam (D-021).
7. **Beperking, expliciet**: de headless dummy-audiodriver mixt niet —
   "hoorbaar", `finished`-timing en mix-balans zijn alleen op hardware te
   beoordelen. Headless toetsen we de waarneembare staat (playing,
   stream, positie, bus, pool-boekhouding); de GD beoordeelt het oor.

## 11. Risico's

| Risico | Zwaarte | Mitigatie |
|---|---|---|
| `finished`-gedrag onder de headless dummy-driver is onzeker → pool-vrijgave niet volledig headless testbaar | middel | pool-boekhouding ook op `playing`-status pollen; hardware-check in de GD-ronde; testontwerp vooraf op staat i.p.v. timing |
| `audio_cue`-signatuur is na consumptie semi-bevroren (zelfde les als D-022) | middel | review nú (deze fase); minimaal gehouden (id + positie) |
| Twee emissies per actie (noise + audio) vergeten bij toekomstige props | laag | patroon in de bestaande props voorgedaan; suite-test §10.1 vangt de gebouwde bronnen; propsjabloon-notitie in dossier |
| Placeholder-geluiden sturen de tuning verkeerd (synthetisch ≠ echt) | laag | placeholders bewust neutraal/kort; tuning-pass hoort bij echte assets (contentwerk, buiten 005) |
| Pool-stelen kapt zelden een belangrijk geluid af | laag | N=12 export; debug-log maakt het zichtbaar; prioriteiten pas bij bewezen behoefte |

## 12. Toekomstparagraaf — reverb en ruimte-akoestiek (niet in 005)

Verschillende ruimtetypes (kantine, kleedkamer, gang, kelder, buiten)
krijgen later verschillende akoestische eigenschappen — de galm van een
betegelde kleedkamer vertelt iets anders dan de droge kantine of het open
veld, en die leesbaarheid ondersteunt P3 (richting en plaats inschatten)
en P5 (de wereld heeft een eigen lichaam). Vastgelegde kaders daarvoor,
zonder nu iets te bouwen:

- Dit wordt een **zelfstandig, verwijderbaar systeem** (denkrichting:
  akoestiek-zones per ruimte die de effect-keten van een bus of de
  pool-spelers beïnvloeden), met een eigen ontwerpronde wanneer er échte
  ruimtes zijn (op z'n vroegst bij de sfeerpass van taak 006, eerder
  logisch bij het levelwerk van fase 4/5).
- **AudioDirector wordt hiervan geen eigenaar** — hij blijft de dunne
  mixer; het akoestieksysteem wordt een buur van `game/systems/audio/`,
  volgens dezelfde regels (D-015, geen God Object).
- Tot die tijd geldt: SoundResources coderen geen ruimte-akoestiek in
  hun samples (geen "ingebakken galm"), zodat ze later zone-neutraal
  blijven.

## 13. Exit-criteria taak 005

1. Dit ontwerp door de GD gereviewd en akkoord; daarna bouw in blokken
   (datamodel+tools → afspeelsysteem → bronnen aansluiten →
   tests/F3/registers), commit per blok.
2. De vier kader-tests (§10.1) plus §10.2–10.6 groen — inclusief de
   bekende-id-check uit keuze B2 en het opvulverbod (kader §8: elk
   geluid heeft een benoemd doel); volledige suite groen; import schoon.
3. AudioDirector ongegroeid (alleen mixer); alle player-lifecycle in
   `game/systems/audio/`; D-015 drie richtingen aantoonbaar.
4. Stilte-standaard aantoonbaar: vers systeem zonder geactiveerde lagen
   en zonder cues produceert niets.
5. Registers bijgewerkt (CHANGELOG, DECISIONS: audio_cue-signatuur +
   systeemsplitsing, TECH_DEBT: evt. nieuwe posten, SESSION_STATE,
   README) en gepusht.
6. Hardware-beoordeling GD: voetstappen per gait hoorbaar verschillend,
   deur/pickup klinken op de juiste plek (koptelefoon), nulpunt-laag
   aan/uit, Esc pauzeert ook het geluid.
