# Vertical Slice — Art Direction & Assetplan (fase F)

**Type**: Game Director/Art Director-ontwerpdocument · **Status**: 🟢
**v1.1 — goedgekeurd door de GD (2026-07-29) met vier besluiten (§14)**;
wacht op expliciete go voor fase G · **Hoort bij**: tasks/008 §15,
fase F · **Datum**: 2026-07-29

*Dit document legt vast hoe het clubgebouw van VV Drechtstreek van
greybox naar geloofwaardige Nederlandse amateurvoetbalvereniging gaat —
zonder één wijziging aan architectuur, gameplay of systemen. De
goedgekeurde greybox (fase C) is de maatvaste onderlaag: elke muur,
deur en zichtlijn blijft exact waar hij staat. De artpass kleedt aan,
verandert niets. Na GD-review volgt pas implementatie (fase G), in
prioriteitsvolgorde (§12).*

---

## 1. De artstijl in één alinea

**Gegrond Nederlands realisme, 's nachts gefotografeerd.** Geen
stylized look, geen overdreven grunge, geen game-achtige overdaad. De
maatstaf is een foto: als een screenshot niet zou kunnen doorgaan voor
een foto die een clublid om half één 's nachts in het clubhuis maakte,
is het te veel of te weinig. De horror komt niet uit de art — die komt
uit het licht (006), de stilte (005) en wat er *mist* (de mensen). De
art heeft één taak: deze plek zó echt en zó gewoon maken dat de
afwijkingen straks pijn doen (P5: de wereld is de hoofdrolspeler;
HORROR §7: het vertrouwde is het paard van Troje).

**Silent Hill-achtig** betekent hier wat het in het 006-ontwerp al
betekende: tonaliteit, niet iconografie. Lage lichtvloer, verte die in
fog oplost, kleuren die door schaars TL-licht gefilterd worden, near-
black met leesbare silhouetten. Géén roest-en-bloed-textuur, géén
industrieel verval — ons "Otherworld" bestaat niet; ons normaal is al
genoeg.

## 2. Wereldregels (bindend voor elke asset)

1. **De vereniging is onderhouden, niet vervallen.** Dit clubhuis
   wordt gerund door vrijwilligers die er trots op zijn. Veroudering
   is **gebruikssporen, geen verwaarlozing**: glans die weg is op de
   plekken waar handen en schoenen komen, niet afbladderende muren.
   Concreet: slijtage op deurkrukken, plintranden, zitranden van
   banken, de looplijn in de gang (donkerder pad in het zeil), koffie-
   kringen op de bar, kalkaanslag in de douches, voegen die nét
   donkerder zijn. Verboden: graffiti, kapotte ruiten, gaten, schimmel-
   pluizen, zwerfvuil. Eén verbleekt element per ruimte mag (een
   poster, een gordijn) — meer wordt decor.
2. **Alles heeft een eigenaar.** Elke prop moet de vraag "wie heeft
   dit hier neergezet, en waarom?" kunnen beantwoorden. Niets staat er
   "voor de sfeer" (P4/P2-parallel: geen visuele opvulling).
3. **Rood is gereserveerd.** Het palet (§3) is koel en gedempt; rood
   bestaat alleen als signaal met betekenis (brandblusser, nooddeur-
   bordje, het slot op de ketting). Zo blijft rood later bruikbaar als
   stille alarmkleur. Sponsorborden en clubkleuren blijven van dit
   verbod weg (§3).
4. **Tekst is Nederlands, alledaags en schaars leesbaar.** Bordjes en
   posters bestaan, maar alleen wat de speler ván dichtbij bekijkt
   hoeft echt leesbaar te zijn. Geen lorem ipsum — onleesbaar-op-
   afstand is prima, nep-tekst-van-dichtbij breekt alles.
5. **Geen echte merken, geen echte namen.** Alle sponsors, logo's en
   producten zijn fictief (§10). Geen naam die de speler-identiteit
   invult (STORY §2).
6. **De architectuur is heilig.** Collision, deuropeningen, plafond-
   hoogtes, zichtlijnen en het schaduwbudget (D-026) blijven exact
   zoals goedgekeurd. Detailgeometrie (plinten, kozijnen, tegels) mag
   erbovenop, maar mag nooit een doorgang versmallen of een zichtlijn
   blokkeren.

## 3. Kleurgebruik

**Clubkleuren VV Drechtstreek: blauw-wit** *(vastgesteld door de GD,
2026-07-29 — D-031)*. Motivatie: klassieke dorpsclub-kleuren, ze overleven het
koele nachtlicht zonder te schreeuwen, en ze laten rood vrij als
signaalkleur (regel §2.3). Het clubblauw (richting RAL 5010,
gedempt) komt terug in: deuren-accenten, de bewegwijzering, de banken-
zitting, teamfoto-lijsten, de boarding-rand en het logo.

**Kleurscript over de route** — de speler loopt van koud naar warm
naar koud; kleur vertelt waar je bent:

| Zone | Temperatuur | Dominant | Accent |
|---|---|---|---|
| Buiten (voorplein, pad, veld) | koud, blauwzwart | nat asfaltgrijs, donkergroen gras | natriumwarm entreelampje |
| Hal | neutraal-warm | gebroken wit, grijs zeil | clubblauw bewegwijzering, houten prikbord |
| Kantine | **het warmste punt van het spel** | hout, crème, bruintinten | clubblauw + gedempte sponsorkleuren |
| Gang | koel, TL-groenig | grijsgroen zeil, witgrijze wand | clubblauwe deurkaders |
| Kleedkamers | neutraal, functioneel | grijsblauwe vloercoating, wit | clubblauwe bankzittingen |
| Douches/toiletten | koudst binnen | cyaanwitte tegel, voeggrijs | — (bewust accentloos) |
| Onderhoudsruimte | bruin-donker | beton, ongeschilderd hout, metaal | veiligheidsgeel op de meterkast-sticker |

De kantine als warmste punt is een bewuste valstrik: het hart van de
club voelt veilig (P7: suggestie, nooit garantie). Hoe dieper de
route, hoe kouder en kaler — de onderhoudsruimte is het eind van de
warmte.

## 4. Materialen per ruimte (vloer / wand / plafond)

*Alle materialen PBR, gedekt en mat (roughness hoog); glans alleen op
natte buitenvlakken, tegelwerk en de bar. Resoluties en bronnen: §11.*

| Ruimte | Vloer | Wand | Plafond |
|---|---|---|---|
| **Hal** | grijs linoleum/zeil, lichte spikkel; donkere looplijn richting gang | gebroken wit stucwerk; lambrisering (hout, 1,1 m) rond de kapstok | wit systeemplafond (600×600-platen, subtiel oneffen) |
| **Kantine** | eiken-look laminaat, gebruikssporen bij bar en deuren | crème geschilderd stucwerk; houten lambrisering onderlangs | wit systeemplafond; boven de bar donkerder geschilderde koof |
| **Gang** | grijsgroen zeil met donkere looplijn in het midden | witgrijs geschilderd metselwerk (blokverband voelbaar) | betongrijs, laag; kabelgoot langslopend |
| **Kleedkamer 3 & 4** | antislip-coating, grijsblauw, gevlekt bij de douche-ingang | halfhoog betegeld (wit, 15×15) met geschilderd metselwerk erboven | geschilderd beton, licht vochtgevlekt in de hoeken |
| **Douches** | kleine antisliptegel (5×5, cyaangrijs), donkerder rond de putten, kalkrand | volledig betegeld (wit/cyaan, 15×15), kalksluier op ooghoogte, donkere voeg | geschilderd beton met licht condensspoor |
| **Toiletten** | zelfde tegel als douches, iets lichter | halfhoog wit betegeld, daarboven geschilderd | geschilderd beton |
| **Onderhoudsruimte** | kaal beton met olievlek-schaduw bij de cv | ongeschilderd kalkzandsteen, stofsluier | ruw beton, zichtbare leidingen |
| **Bestuurskamer** (demo-focusgebied, §5.8) | vergrijsd naaldvilt-tapijt (blauwgrijs) | wit stucwerk; één wand houten lambrisering vol lijsten | wit systeemplafond |
| **Keuken** (alleen door het luik zichtbaar) | grijze tegel | wit tegelwerk | wit |
| **Buitenzijde** | nat asfalt (voorplein/pad), gras met kale doellijn-plekken (veld) | schoon metselwerk (bruinrood genuanceerd), betonplint; tribune-beton erboven | — (dakrand: donkere boeiboord) |

**Nat is het buiten-materiaal.** Het regent: asfalt spiegelt het
entreelampje en mast 3, het gras is donker verzadigd, metselwerk heeft
een natte onderrand, het gaashek glimt. Binnen is droog — op de
druppelsporen bij de entree-mat na.

## 5. Per ruimte: sfeer en props

*Asset-budget per ruimte in §12; hier staat wát er staat en waarom.*

### 5.1 Kantine — "de derde helft is net afgelopen"
Het bewijs van leven, bevroren. Props: de **bar** (§8) met krukken;
tafels met **stapelstoelen** (twee net aangeschoven, één schuin — zoals
mensen ze achterlaten); een paar **glazen en flesjes** op één tafel en
op de bar (half leeg — geen overdaad: één tafel vertelt meer dan
tien); **onderzetters/bierviltjes** (fictief merk); de **tv** aan de
wand (gloeit, fase H maakt hem betekenisvol); **sponsorborden** (§9)
als fries boven de lambrisering; **trofeeënkast** (§9); **prikbord**
met wedstrijdschema en kantinerooster; teamfoto's-wand (kleine lijsten,
clubblauw passe-partout); darts-hoek (bord + krijtscorebord — typisch,
goedkoop, vertelt veel); kassa/pin-blokje op de bar; koelkast-glow
achter de bar (dichte deur, lampje); plant in de hoek (iets te droog);
radiator onder de ramen; gordijnvouw langs de veldramen (open).

### 5.2 Kleedkamers — "zijn wereld"
Kleedkamer 3 (thuis) is de emotionele kern: hier hing zijn tas.
Props: de bestaande **bankjes** en **kapstokken** (§8) aangekleed;
**lockers** (§8, alleen kk3); vloerrooster bij de douche-ingang;
**tactiekbord** (whiteboard met halfuitgeveegde opstelling — magneten
blijven); pupillenposter ("normen & waarden"-poster van de bond,
fictief); één vergeten **scheenbeschermer** onder een bank en één
**sok** (het detail dat iedereen herkent); waterfles op een bank;
afvalbakje met tape-resten; deurhaakje met een vergeten aanvoerders-
band. Kleedkamer 4 (uit) is dezelfde ruimte maar **kaler**: geen
lockers, geen poster, leger — bezoekers laten niets achter. Het
verschil tussen 3 en 4 ís de vertelling.

### 5.3 Douches — "kalk en echo"
Bijna leeg, en dat hoort: doucheknoppen en koppen (bestaand volume →
echte armaturen), kalksluier, één vergeten **shampoofles** (fictief
merk, op zijn kop — zuinig clublid), zeepbakje, het rooster van de
putten. De leegte is het punt; hier geen extra props.

### 5.4 Toiletten — "TL uit, klein en koud"
Potten en wasbak (bestaand → echte modellen), spiegel (licht
beslagen randje), handdoekrol-automaat (jaren-negentig-model),
zeeppompje, prullenbakje, bordjes M/V op de hokjes, één hokdeur op
een kier. Meer niet.

### 5.5 Gang — "de ruggengraat"
De gang moet vooral **ritme** krijgen: deurkaders in clubblauw,
**bewegwijzering** (§10), de kabelgoot, de brandblusser (bestaand
volume → echt model + keuringskaartje), deurmatten bij kleedkamers,
een lage houten bank tussen kleedkamer 3 en 4 (wachtende ouders),
ingelijste **elftalfoto's door de jaren heen** langs de wand (de club
heeft geschiedenis — en de foto's kijken de speler na, zonder dat we
daar íéts mee doen. Nu niet.). De schoonmaaknis (bestaand) krijgt
echte emmer, mop, wringer en een fles allesreiniger (fictief).

### 5.6 Onderhoudsruimte — "het einde van de warmte"
Stellingen (bestaand → echt rek) met kalkzakken, lijnenverf-emmers
("veldwit"), een slang op haspel, de **kalkkar/belijningskar** (icoon
van elk sportpark), reserve-cornervlagstokken in een hoek, de cv-ketel
(bestaand → echt model met typeplaatje), gevonden-voorwerpen-krat
(nog zonder gameplay-betekenis — fase D), doelnetten aan een haak,
een oude teamfoto zonder lijst tegen de muur gezet (afgedankt — het
enige "verhaal-fluistertje" dat deze pass zich permitteert).

### 5.7 Buitenzijde — "sportpark bij nacht"
Metselwerk-gevel met betonplint en boeiboord; **ramen** (§6) met
kozijnen; de entree met clubnaambord boven de deur (**"v.v.
DRECHTSTREEK — Sportpark Oostpolder"**, aanlichtbaar door het
entreelampje); vlaggenmast zonder vlag (tikkend koord — audio is er
al in het nulpunt-palet, fase H koppelt); fietsenrek (bestaand →
echt model, één achtergebleven fiets? **nee** — de parkeerplaats-
leegte is canon, ook geen fiets); de **boarding** langs het veld met
sponsordoeken (§9, verweerd); het gaashek met ketting en hangslot
(bestaand volume → echt gaas-materiaal met transparantie); lichtmast 3
als echt vakwerkmast-silhouet; dug-outs zijn er niet (bewust: budget
en zichtlijn — heroverwegen in fase G als het veld te leeg voelt);
containerhoek naast de onderhoudsruimte-gevel (kliko's, netjes op
een rij — vrijwilligersnetheid).

### 5.8 Bestuurskamer — "het geheugen van de club" *(toegevoegd in v1.1: door de GD in het demo-focusgebied geplaatst)*
De kamer waar de club zichzelf bewaart. Vergaderopstelling: ovale tafel
met zes verschillende stoelen (bij elkaar geraapt door de jaren), een
dressoir met archiefdozen ("NOTULEN 2019–2023", handgeschreven
etiketten), een wand vol **historie**: oude elftalfoto's, het
oprichtingsdocument in een lijst, een verkleurde luchtfoto van
Sportpark Oostpolder uit de jaren tachtig; de kampioensvaan aan een
knop; een vaste telefoon (jaren negentig — hij hangt er nog); een
whiteboard met een half uitgewiste agenda ("ALV — najaar"); een
koffiezetapparaat op het dressoir met opgedroogde kan; de clubvlag
opgevouwen over een stoelleuning; radiator met vensterbank. De
dichtste, meest "bewoonde" ruimte van de demo — en 's nachts kijken
al die foto's terug; we doen er niets mee, de ruimte zelf is genoeg
(P7). **Consequentie (herzien bij het fase G-startsein, D-032)**: de
bestuurskamer blijft tijdens de demo **op slot** — de speler bereikt
haar pas met de gevonden sleutel. Ze is de beloning van de demo en de
demo eindigt hier met de eerste ontmoeting met CRUMP (silhouet-rig,
fase I). De ruimte wordt desondanks volledig uitgewerkt; de
VS-deurtabel is herzien en de fase-D-flow werkt de sleutelroute uit.

## 6. Ramen

Kozijnen: kunststof wit (jaren-2000-renovatie — herkenbaar NL),
binnenzijde vensterbank met een enkele plant of wedstrijdbeker.
Kantineramen: groot, met **condensrand onderin** en regendruppels op
het buitenglas (shader-detail, subtiel, geen streaming-druppels).
Douche-kiepramen: melkglas, op de kiepstand — er hoort 's nachts
tocht doorheen te kunnen (audio-haak, fase H). Hal-raam: gordijntje
half dicht. Glas-materiaal: licht groenige reflectie binnen, buiten
spiegelend richting de natte nacht; de bestaande transparante volumes
worden vervangen door echte glas-materialen met dezelfde maat.

## 7. Deuren

De bestaande deur-props krijgen een artpass (zelfde scène, nieuw
uiterlijk — gameplay en scharnierpunt onaangetast): binnendeuren als
**vlakke hardhouten deuren, clubblauw geschilderd kozijn**, RVS-kruk
met slijtglans, kunststof naambordje per deur (§10); kleedkamerdeuren
met stootplaat onderaan (schoenen); de **nooddeur** als staaldeur met
panieksluiting en groen "NOODUITGANG"-bordje erboven (de enige groene
lichtbron binnen — hij mag zachtjes gloeien, dat is realistisch én een
oriëntatie-anker); de **hoofdentree** als aluminium/glas-deur met
"TREKKEN"-sticker en openingstijden-bordje; terras- en keukendeur
zoals binnendeuren; bestuurskamerdeur met bordje "BESTUUR" en
melkglas-ruitje (er is níéts achter te zien — melkglas verkoopt dat).

## 8. De hero-props (custom, definitiegevend)

- **De bar**: houten front met panelen, RVS blad-rand, koffiekringen,
  tapkraan-unit (fictief biermerk "Polderbier" op de taphendel),
  spoelbakje, hangende glazenrekjes boven, doorgeefluik met roldeur-
  suggestie (dicht). De bar is het gezicht van de kantine — hoogste
  detailprioriteit van het hele plan.
- **Lockers (kk3)**: zes smalle stalen lockers, clubblauw, twee met
  hangslotje, één deurtje op een kier (leeg), sticker-restanten.
- **Bankjes**: hardhouten latten op stalen schragen, clubblauw
  gelakte zitting met slijtage op de rand; zelfde model binnen de
  hele accommodatie (consistentie = geloofwaardigheid).
- **Kapstokken**: houten rail met dubbele stalen haken (het bestaande
  volume + haakjes wordt één echt model); in kk3 hangt op één haak
  een vergeten trainingsjack (clubblauw) — het enige kledingstuk in
  het gebouw. *(Bewust: de sporttas zelf komt pas in fase D — geen
  gameplay-props in de artpass.)*
- **TL-armaturen**: het bestaande light_tl-prop krijgt een echte
  behuizing: opbouwarmatuur met geprismatiseerde kap (kantine/hal) en
  kale dubbele buis op ketting-ophang (gang/onderhoud); de flikkerbuis
  krijgt een zichtbaar **zwartgeblakerd uiteinde** (de wereld-oorzaak
  van 006 wordt zichtbaar). Gedrag, staten en budget: onaangetast.

## 9. Sponsorborden en trofeeën

- **Sponsorborden binnen** (kantine-fries, ±8 stuks): geschilderd/
  gedrukt op PVC, licht verschillende stijlen en leeftijden (de een
  strak, de ander duidelijk uit 2009). Fictieve lokale sponsors:
  *Bakkerij Van der Kolk · Autobedrijf Oostpolder · Kozijnen De Waard ·
  Snackbar 't Doelpunt · Installatiebedrijf Drechtstreek · Notariaat
  Hoogland · Polderbier · Bouwbedrijf Verhagen & Zn.* Kleuren gedempt
  (regel §2.3: geen fel rood).
- **Boarding buiten** (±6 doeken): zelfde sponsors, verweerde druk,
  natte glans; één doek half losgeschoten onderaan (de wind — subtiel).
- **Trofeeënkast**: glazen kast met ~12 bekers in verschillende
  maten/leeftijden (drie modellen, geschaald en gevarieerd), twee
  medaille-linten, een oude wisselbeker met graveerplaatjes, één
  ingelijste krantenpagina (onleesbaar op afstand, koppen suggereren
  "kampioenschap 4e klasse"), pupil-van-de-week-fotolijstje. De kast
  krijgt een eigen klein lampje **niet** — hij leeft van de TL boven
  de bar (budget D-026 blijft heilig).

## 10. Bewegwijzering en Nederlandse clubdetails

- **Bewegwijzering**: kunststof bordjes wit-op-clubblauw, consequent
  systeem: "KANTINE", "KLEEDKAMERS →", "KLEEDKAMER 3", "KLEEDKAMER 4",
  "TOILETTEN", "BESTUUR", "ONDERHOUD — verboden voor onbevoegden",
  "NOODUITGANG" (groen), "GEVONDEN VOORWERPEN → ONDERHOUDSRUIMTE"
  (het gangbordje dat in fase D gameplay-betekenis krijgt — hij hangt
  er vast alvast, als wereld, niet als systeem).
- **NL-clubdetails** (de dingen die iedereen herkent): het krijt-/
  kantinerooster op het prikbord; "wie het laatst weggaat doet het
  licht uit"-briefje bij de meterkast; pupil-van-de-week-poster;
  KNVB-achtige (fictieve bond: "NVVB") gedragsregels-poster; ballen-
  pomp aan een touwtje; sleutelkastje achter de bar (bestaat al als
  fase-D-haak — krijgt nu zijn echte kastje); collectebus van de
  clubactie op de bar; deurmat met clublogo in de hal; verjaardags-
  slinger-restje boven de bar (één punaise losgelaten — de vorige
  week leeft nog).

## 11. Assetstrategie: custom vs. bibliotheek

**Bronnenbeleid** *(vraagt GD-akkoord, CLAUDE.md: geen third-party
zonder akkoord; licenties komen per bron in `addons/`/`assets/` met
LICENSE-bestand)*: uitsluitend **CC0/publiek domein** zodat er nooit
attributie- of licentierisico in de build zit. Voorgestelde bronnen:
**Poly Haven** (PBR-texturen + enkele modellen, CC0) en **ambientCG**
(PBR-texturen, CC0). Geen Sketchfab-scrapes, geen "free for personal
use". Alles wat tekst, logo of club-identiteit draagt is per definitie
custom.

| Categorie | Route |
|---|---|
| Alle vloer-/wand-/plafond-/buitenmaterialen (§4) | **bibliotheek** (CC0 PBR-sets), afgestemd in Godot |
| Generieke props: stoelen, tafels, krukken, radiator, sanitair, emmer/mop, kliko's, pallets/kratten, cv-ketel, brandblusser | **bibliotheek** waar een CC0-model de lat haalt; anders custom-eenvoudig |
| Hero-props §8 (bar, lockers, bankjes, kapstok+jack, TL-behuizingen) | **custom** (definitiegevend voor de identiteit) |
| Alles met tekst/identiteit: clubnaambord, bewegwijzering, sponsorborden, boarding, posters, prikbord-papier, teamfoto's, trofee-graveringen, deurbordjes, stickers | **custom** (2D-werk: teksturen/decals — het meeste hiervan is grafisch ontwerp, geen 3D) |
| Teamfoto's/elftalfoto's | **custom, gegenereerd/gestileerd onherkenbaar** — geen echte gezichten, op afstand leesbaar als "team", van dichtbij bewust net-niet-scherp (P7 en privacy tegelijk) |
| Doel, vlaggenmast, lichtmast, gaashek | **custom-eenvoudig** (buizen + gaas-alpha — dichtbij de bestaande volumes) |
| CRUMP-representatie (glimp, fase I) | **besluit in dit document uitgesteld naar een eigen GD-sessie** — de glimp staat op afstand in flikkerlicht; een silhouet-rig (donkere humanoïde, verkeerde verhoudingen, geen detail) volstaat voor de demo en voorkomt dat we het definitieve ontwerp overhaasten. Voorstel: silhouet-rig als tijdelijke representatie, apart GD-akkoord vóór fase I. |

**Werkverdeling eerlijk benoemd**: de VPS kan texturen/decals/
materialen, kitbash-modellen uit primitieven en alle Godot-integratie
leveren; organisch modelleerwerk (stoelen die écht mooi zijn, het
trainingsjack) komt uit CC0-bibliotheken of wordt een GD-besluit
(aankopen/laten maken). Het plan is zo gesneden dat **geen enkele
demo-kritieke asset** van extern modelleerwerk afhangt.

**Technische kaders**: texturen 1K standaard, 2K alleen voor de bar,
vloeren en de gevel; alles in atlassen waar het kan; tri-planair op
grote vlakken tot fase G de ruimtes tot scènes ombouwt (TD-007 wordt
in G per goedgekeurde ruimte afgelost); prop-budget ~2–6k tris hero,
~300–1500 generiek; **het schaduwbudget (D-026) en alle 006-tuning
blijven onaangeraakt** — de artpass voegt geen enkel realtime
schaduwlicht toe; emissieve materialen (tv, nooduitgang-bordje,
koelkast-glow) zijn de enige nieuwe "lichten" en zijn puur emissief,
geen Light3D. Geen nieuwe systemen, geen shaders met gedrag; alleen
`flicker_light.gdshader`-hergebruik en statische materialen.

## 12. Asset-budget per ruimte

*"Uniek" = nieuw te maken/halen asset (model of decal-set); instanties
zijn gratis. Totaal ±78 unieke assets, waarvan ±30 puur 2D/decal.*

| Ruimte | Uniek 3D | Uniek 2D/decals | Zwaartepunt |
|---|---|---|---|
| Kantine | 14 | 12 | bar, sponsorfries, trofeeënkast |
| Gang | 4 | 8 | bewegwijzering, elftalfoto's, deurbordjes |
| Kleedkamer 3 | 8 | 4 | lockers, tactiekbord, bank/kapstok |
| Kleedkamer 4 | 0 (hergebruik) | 1 | leegte is het ontwerp |
| Douches | 4 | 2 | armaturen, kalk-decals |
| Toiletten | 5 | 2 | sanitair-set |
| Onderhoudsruimte | 7 | 3 | belijningskar, stellinginhoud |
| Hal | 3 | 5 | prikbord-papier, deurmat, lambrisering |
| Bestuurskamer *(v1.1)* | 9 | 7 | tafel+stoelen, dressoir/archief, historie-wand |
| Buiten | 9 | 8 | gevel-set, clubnaambord, boarding, mast |
| Materialen (§4, gebouwbreed) | 17 texture-sets | — | vloer/wand/tegel/tapijt/asfalt/gras |

## 13. Prioriteitenlijst voor de eerste speelbare demo *(v1.1 — herzien op GD-besluit)*

**GD-besluit (2026-07-29, vervangt de eerdere route-brede tiers): niet
de volledige route op één kwaliteitsniveau, maar álle prioriteit eerst
naar een extreem hoogwaardige eerste 10–15 minuten.**

**Demo-focusgebied**: entree (incl. het buitengezicht van de entree:
luifel, clubnaambord, gevel-stuk en het stukje voorplein dat je vanaf
de deur ziet) → hal → **de gang als verbinder** (niet door de GD
genoemd, maar de speler kán de kleedkamers niet bereiken zonder gang —
hij hoort er dus bij, op vol niveau) → kleedkamers 3+4 → douches →
bestuurskamer (§5.8, deur van het slot).

1. **Tier F1 — fundament van het focusgebied**: materialen (§4) op
   álle focusruimtes; deuren-artpass (§7) en TL-behuizingen (§8)
   binnen het focusgebied; bewegwijzering (§10) in hal en gang.
2. **Tier F2 — de bewoonde laag**: kleedkamer 3 volledig (§5.2),
   kleedkamer 4 als kalere spiegel, douches (§5.3).
   *(Uitgevoerd 2026-08-01 met een door de GD herziene scope — zie §16.)*
3. **Tier F3 — de zwaartepunten**: bestuurskamer volledig (§5.8);
   hal-aankleding (prikbord, deurmat, lambrisering); entree-buitenkant
   (clubnaambord, gevelmateriaal, luifel, natte entree-zone).
4. **Tier F4 — de sfeerlak op het focusgebied**: decals en
   micro-slijtage, kalk, condensranden, elftalfoto's in de gang —
   het "volledig af"-gevoel. **Gate: de GD verklaart de demo-zone
   visueel en qua sfeer áf.**
5. **Daarná, tier-gewijs, de rest van het gebouw** (herbruik van de
   oude tiers): kantine (bar + props — het grootste losse blok),
   toiletten, onderhoudsruimte, buitenwereld-volledig (boarding, mast,
   hek, veld), containerhoek/dug-outs-heroverweging.

**Kwaliteitsgrens bewaken**: zolang de rest greybox is, blijven de
niet-focusdeuren dicht (kantinedeur en toiletttendeur gewoon
sluitbaar zoals nu; wie ze opent ziet eerlijk greybox — geen nep).
De overgang focusgebied ↔ greybox wordt nergens verstopt: dit is een
gefaseerde bouw, geen illusie. In het focusgebied geldt de hoogste
lat: geen enkel zichtbaar vlak zonder echt materiaal, geen enkele
prop op placeholder-niveau.

## 14. GD-besluiten (2026-07-29 — bindend, D-031)

1. **Clubkleuren: blauw-wit.** Doorgevoerd in §3.
2. **Bronnen: Poly Haven + ambientCG (CC0) akkoord**, inclusief
   licenties in de repo.
3. **CRUMP: tijdelijk silhouet-rig** voor de latere glimp; het
   definitieve ontwerp volgt in een eigen sessie.
4. **Demo-scope (afwijkend van het voorstel)**: niet de volledige
   route op één niveau — alle prioriteit eerst naar een **extreem
   hoogwaardige eerste 10–15 minuten** (entree, hal, kleedkamers,
   douches, bestuurskamer). Pas wanneer die demo-zone visueel en qua
   sfeer volledig áf voelt, wordt de rest van het clubgebouw
   tier-gewijs uitgebreid. Verwerkt in §13 (focusgebied-tiers F1–F4 +
   gate) en §5.8 (bestuurskamer uitgewerkt, deur van het slot).

## 15. Wat deze pass uitdrukkelijk níét doet

Geen architectuur- of collisionwijzigingen; geen gameplay, flow,
documenten of sleutels (fase D); geen sfeerbeats of audio-events
(fase H); geen AI en geen CRUMP (fase I is apart, na representatie-
besluit); geen nieuwe systemen of gedragsshaders; geen presets-werk
(TD-002 blijft fase 6). Alleen de wereld geloofwaardiger maken.

**Exit fase F**: GD-akkoord op dit document (incl. §14-keuzes) →
implementatie in tier-volgorde (fase G), commit per tier, met na elke
tier een lokale GD-blik. De suite bewaakt tijdens de hele artpass dat
architectuur (schaalmetingen), deurstaten, TL-staten en schaduwbudget
niet bewegen — de artpass is pas geslaagd als álles nog exact staat
waar jij het goedkeurde.

---

## 16. Uitvoering tier F2 (2026-08-01) — scope, afwijkingen, status

**Opdracht**: de GD-brief van 2026-08-01 verlegde de F2-scope van
"kleedkamer 3 + 4 + douches" naar **de kleedkamer als hero room plus de
aangrenzende gang**, met de gang als het belangrijkste horrorbeeld
(dreigend zonder monster). Kleedkamer 4 en de douches blijven daarmee
op tier F1-niveau tot een volgende tier; ze zijn zichtbaar vanuit de
gang respectievelijk vanuit kleedkamer 3, en dat verschil is bewust
(§13: de overgang focus ↔ greybox wordt nergens verstopt).

**Afwijkingen van dit plan, met reden**:
1. **Drie lockers in plaats van zes** (§8). Tussen de oostbank en de
   zuidwand is 1,0 m vrij; zes smalle lockers vragen ±1,9 m. Zes zou
   ofwel de bank inkorten ofwel de doorloop versmallen — en de
   architectuur is heilig (§2.6).
2. **De sporttas is generiek, niet de premisse-tas** (D-035): de brief
   vroeg om een sporttas als aankleding, de canon (D-028) reserveert de
   vergeten tas voor fase D.
3. **Materiaalschaal van tier F1 gecorrigeerd**: de focusmaterialen
   herhaalden zo grof dat een tegel ±40 cm en een baksteen ±60 cm werd.
   Dat las als "grote lege ruimte" in plaats van clubgebouw op
   menselijke maat. Geijkt op 15 cm respectievelijk 21 cm; dit raakt
   ook hal, douches en bestuurskamer (zelfde materiaalsleutels).
4. **Lichtpass alleen lokaal** (D-034), conform de brief: geen
   volledige lighting phase, geen wijziging aan de 006-referentie
   (ambient, fog, tonemap) en geen extra schaduwlicht.

**Status**: gebouwd, suite 250/250 groen, verwijderbaarheidstest
gedaan. **Wacht op art-direction-review door de GD** (zestien renders,
1600×900). Tier F3 (bestuurskamer, hal-aankleding, entree-buitenkant)
begint pas na expliciet startsein.

---

## 17. Uitvoering tier F2.1 (2026-08-01) — realism correction pass

**Opdracht** (GD-review van F2): technisch sterk, visueel nog niet
approved. De gang is **beschermde art-direction-referentie** en mag niet
lichter, voller, schoner of leesbaarder worden. De kleedkamer moet
minder als een nette 3D-scène ogen — niet door méér props, maar door
grounding, materiaalbreuk en een minder egale TL.

**Wat gedaan is** (alles binnen kleedkamer 3, tenzij anders vermeld):
1. **Grounding**: contactvlekken en -lijnen als decals onder en achter
   bank, kast, afvalbak, tas, radiator, leidingvoet; langs kozijnen,
   plint, tegelrand en de wand/plafond-naden. Plus echte contactschaduw
   door het derde schaduwslot naar deze ruimte te verhuizen (D-036).
2. **TL als lokale bron**: nieuwe prop-export `light_attenuation`,
   energie/bereik/attenuatie op 1,2 / 3,9 / 2,1, en een zichtbare
   elektrische aansluiting (doos, buis, twee beugels).
3. **Materiaalbreuk**: verfrol- en reparatievariatie op de bovenwand,
   grauwsluier en ongelijk gepoetste velden op de tegels, drie grote
   vloerverkleuringen, roet rond de buis, en ORM-decals die het looppad
   gladder maken in plaats van donkerder (D-037).
4. **Bank en kast**: twee lattinten met verschillende ruwheid, matter
   lakwerk, krasspoor over de zitting; kast donkerder, matter, minder
   metallic — hij trekt het beeld niet meer naar zich toe.
5. **Props uitsluitend verplaatst/gedraaid** (afvalbak, handdoek,
   flesje, tas, jack, tactiekbord). Toegevoegd: alleen de
   TL-aansluiting en een achterblad achter de poster.

**Niet gedaan, bewust**: geen nieuwe props, geen bevel-pass, geen
flashlight-herontwerp (staat voor F3), geen wijziging aan de gang, geen
wijziging aan de globale environment (ambient/fog/tonemap/SSAO blijven
de 006-referentie — juist omdat elke globale knop ook de gang raakt).

**Status**: gebouwd, suite 250/250 groen, verwijderbaarheidstest
opnieuw gedaan. **Wacht op art-direction-review** (zes verplichte
renders + twee voor/na-vergelijkingen).

