# Taak 008 — Vertical Slice 01: "De vergeten tas"

**Type**: Game Director-ontwerpdocument (géén technisch dossier) ·
**Status**: 🟢 **creatief goedgekeurd door de GD (2026-07-28, v1.1)** —
besluiten verwerkt, productieplan A–J vastgesteld (§15); implementatie
per fase, elke fase pas na expliciete go ·
**Omvang**: de eerste ±20 minuten van CRUMP · **Vereist**: 007
(documentlezer — de vijf documenten zijn pas speelbaar daarna)

*Dit document ontwerpt de eerste speelbare snede van CRUMP zoals de
speler hem beleeft: minuut voor minuut, deur voor deur, geluid voor
geluid. Het zegt niets over systemen, code of assets — dat volgt pas na
expliciete implementatie-go, in een apart technisch ontwerp. Toetssteen
overal: de zeven Design Pillars (P1 kwetsbaarheid, P2 stilte, P3 gezien
worden, P4 minder is enger, P5 de wereld is groter dan CRUMP, P6
gameplay boven spektakel, P7 onzekerheid), HORROR_GUIDELINES en
LEVEL_GUIDELINES.*

---

## 0. Canon-notitie (vooraf, belangrijk)

De canon van deze slice is door de GD vastgesteld (2026-07-28):

- De speler is een **voetballer**. Hij keert **na een avondwedstrijd
  terug omdat hij zijn sporttas is vergeten**.
- Het stadion lijkt **verlaten**. Buiten **regent** het.
- De eerste 15–20 minuten zijn **sfeer, verkennen en spanning**. Geen
  achtervolging. CRUMP wordt **hooguit één à twee keer heel kort
  gezien** en **vaker gehoord dan gezien**.
- De speelruimte blijft bewust klein: **ingang, kantine, gang, twee
  kleedkamers, onderhoudsruimte, klein stukje buiten**.

**Canon-status (bijgewerkt na de creatieve review)**: de vergeten
sporttas is per GD-besluit **de canonieke openingspremisse** geworden
(**D-028**); STORY §1/§3 zijn hierop gecorrigeerd en het oude
afsluitverzoek van de barman is vervallen. De eerdere delta-notitie is
daarmee opgelost. Het "normaal" wordt gevestigd door herkenning
(iedereen kent een clubgebouw) en door de sporen van een avond die een
kwartier eerder nog leefde; of "de derde helft" ooit een speelbare
proloog wordt, is een open vraag voor de hoofdstuk 1-sessie (STORY §8).

De harde regel HORROR §5a (eerste 15 minuten: geen monster, geen
achtervolging, geen jumpscares) blijft onverkort van kracht: alles wat
CRUMP in deze slice doet vóór minuut 15 is **geluid op afstand en
afwijking** (ladder-trede 1–2); de ene echte glimp valt ná minuut 15 en
is de climax van de snede.

## 1. De inzet: waarom hij komt, waarom hij blijft

**Hij komt** voor iets banaals: zijn sporttas hangt nog aan het haakje
in kleedkamer 3. **Hij kan niet weg zonder die tas**, want erin zitten
zijn **telefoon en autosleutels** — dit ene detail draagt de hele
slice:

- het verklaart diegetisch waarom hij niet belt, niet appt, niemand
  bereikt (P1: kwetsbaar zonder één mechaniek te bouwen);
- het maakt elk "nog even verder" een redelijke, menselijke beslissing
  in plaats van horror-logica (P6: de speler kan elk moment navertellen
  als eigen keuze);
- het maakt de tas een doel dat de speler écht wil, niet een quest-item.

**Hij blijft** — en loopt steeds verder het gebouw in — omdat elke stap
de kleinst mogelijke logische vervolgstap is (§5, de doelketen): de tas
hangt er niet → gevonden voorwerpen liggen in de onderhoudsruimte → die
is op slot → de sleutels horen in het kastje achter de bar → het
beheerdershaakje is leeg → de beheerder was bezig in kleedkamer 4 →
daar ligt de sleutelbos. Geen enkele stap vraagt moed; elke stap is
"nog heel even, dan ben ik weg". Nederlandse nuchterheid is het
voertuig: er is vást een verklaring — een feestje elders, een storing,
de beheerder is even weg. De speler stelt het moment uit waarop hij
moet toegeven dat er iets mis is; wíj niet — wij stapelen intussen
stilletjes de bewijslast (P7).

## 2. De ruimte: het clubgebouw onder de hoofdtribune

VV Drechtstreek, Sportpark Oostpolder (STORY §4). De slice speelt in
het clubgebouw dat onder de hoofdtribune van het stadionnetje is
gebouwd, plus een klein stuk buitenterrein. Menselijke maat, echt
Nederlands sportcomplex (LEVEL §6). Avond, regen, één brandende
lichtmast op het veld.

**Plattegrond in woorden** (spanningslabel per ruimte, LEVEL §4):

| Ruimte | Rol | Label |
|---|---|---|
| **Buiten (voorplein + pad langs het veld)** | aankomst en slot van de slice; regen als geluidsdeken; zicht op het veld en lichtmast 3 | Onrust → Scharnier |
| **Ingang/hal** | ankerpunt en kruispunt: prikbord, kapstok, deuren naar kantine en gang | Adem |
| **Kantine** | het warme hart dat leeg is; tv, bar, sleutelkastje, meterkast; hier ligt de zaklamp | Adem → Onrust |
| **Gang (kleedkamergang)** | de ruggengraat; smal, TL-verlicht (deels defect, één buis flikkert); drie keer doorlopen, drie keer anders | Onrust |
| **Kleedkamer 3 (thuis)** | "zijn" kleedkamer; het lege haakje — het eerste doel dat kantelt | Onrust |
| **Kleedkamer 4 (uit)** | de afgebroken schoonmaak; sleutelbos; het eerste geluid dichtbij | Onrust → Druk |
| **Onderhoudsruimte** | de donkerste ruimte; gevonden voorwerpen; de tas; zaklamp-territorium | Druk |

Oriëntatie-ankers (LEVEL §2.3): de verlichte kantinepui vanaf buiten,
het prikbord in de hal, de flikkerende TL halverwege de gang, het rode
nooddeur-bordje aan het eind ervan. De speler bouwt in één doorloop een
mentale kaart die we daarna drie keer subtiel schenden.

**Wat er bewust níét is** (P4): geen bestuurskamer of keuken om in te
lopen (hun deuren bestaan en zitten op slot — de wereld is groter dan
de slice, P5), geen tweede verdieping, geen tribune-trap op, geen
velden in. Klein houden is het punt: twintig minuten in zeven ruimtes
die je leert kennen, is enger dan veertig ruimtes die je vergeet.

## 3. Deuren en sleutels

**Begintoestand van elke deur** — en de regel: op slot is nooit
willekeur, het vertelt wie hier het laatst was.

| Deur | Begintoestand | Waarom / wat het vertelt |
|---|---|---|
| Hoofdentree (hal) | dicht, **niet op slot** | eerste stille afwijking: ná een wedstrijdavond hóórt dit afgesloten te zijn — iemand is niet toegekomen aan afsluiten |
| Hal ↔ kantine | open op een kier | licht en tv-gemompel lekken de hal in; lokt de eerste omweg (P6: verleiden, niet dwingen) |
| Kantine → terras | **op slot**, blijft dicht | begrenst de slice; glas toont het natte terras — zien wél, kunnen niet |
| Keuken (achter de bar) | **op slot**, blijft dicht | wereld groter dan de slice (P5) |
| Bestuurskamer (hal) | **op slot**, blijft dicht | idem; het naambordje is het enige verhaal |
| Hal → gang | dicht, niet op slot | drempel tussen licht en TL-schemer |
| Kleedkamer 3 (thuis) | niet op slot | zijn eigen kleedkamer; hier begint en kantelt het doel |
| Kleedkamer 4 (uit) | dicht, niet op slot | de beheerder was hier bezig; de deur staat later ánders (op een kier) dan de speler hem aantrof |
| **Onderhoudsruimte** | **op slot** → **beheerderssleutelbos** | de enige echte slot-barrière van de slice |
| Nooddeur (einde gang) | dicht; paniekbalk — van binnenuit áltijd te openen | eerlijkheid (HORROR §6): er is altijd een uitweg; het matglas erin is een projectiescherm voor twijfel (§8) |

**Sleutels: er is er precies één** (P4) — de **sleutelbos van de
beheerder**, met een handgeschreven label "onderhoud". Nodig vanaf
±minuut 9 (deur op slot ontdekt), gevonden ±minuut 11 in kleedkamer 4,
gebruikt ±minuut 14. Eén sleutel betekent: geen sleuteljacht, geen
inventariteitspuzzel — één helder "dit ontbreekt nog" per moment.

## 4. Minuut-tot-minuut

*Tijden zijn richtwaarden voor een speler die kijkt en leest; wie rent,
is er sneller doorheen en mist precies de dingen die het eng maken —
dat is prima (P6: niets hieronder vereist dat de speler ernaar kijkt,
HORROR §5b.5). Kolom "boog" = HORROR §1; "ladder" = HORROR §2.*

| Tijd | Beat | Boog / ladder | Pijlers |
|---|---|---|---|
| **00:00–02:00** | **Aankomst in de regen.** Zijn auto is de laatste op de parkeerplaats (D-028: de sleutels zitten in de tas); het hek staat open. Regen op capuchon-oren, de verre provincialeweg, één zoemende lichtmast (mast 3) over een leeg, glimmend veld. De kantinepui geeft warm licht af. Doel is meteen helder en klein: *tas halen, wegwezen.* | rust → onbehagen / — | P5, P2 |
| **02:00–04:30** | **Hal en kantine.** De hoofdentree blijkt niet op slot (afwijking nr. 1 — registreert pas achteraf). Binnen valt de regen weg tot een gedempte deken: de eerste bewuste stilte-beat (§7). Uit de kantine: tv-gemompel. Wie naar binnen kijkt ziet: tafels half opgeruimd, stoelen scheef zoals mensen ze achterlieten, één tafel nog vol glazen, de tv op een late sportherhaling, koeling zoemt. Niemand. De speler mag hier dralen; niets duwt hem. | onbehagen / trede 2 | P5, P2, P7 |
| **04:30–07:00** | **Gang en kleedkamer 3.** De gangdeur door: TL-schemer — twee buizen doen het, één flikkert halverwege (verklaring zichtbaar: de buis is oud, dit is een clubgebouw). Kleedkamer 3: banken, één vergeten scheenbeschermer, de douche drupt. **Zijn haakje is leeg.** De tas is weg. Op het gangbordje bij de deur, clubgewoon: *"Spullen laten liggen? Gevonden voorwerpen → onderhoudsruimte."* Doel kantelt: niet naar huis — dieper het gebouw in. | onbehagen / trede 2 | P1, P5, P6 |
| **07:00–09:00** | **Onderhoudsruimte op slot; terug naar de kantine.** De deur aan het eind van de gang geeft niet mee. Terug door de gang (tweede doorloop — alles staat nog exact zoals net: wij spelen hier bewust níét vals, het normaal moet eerst verdiend zijn). In de kantine, achter de bar: het **sleutelkastje**. Briefje ernaast: *"Sleutels na sluit terug in het kastje!"* Maar het haakje "onderhoud" is **leeg**. In de la eronder, naast de meterkast: de **zaklamp** (§9). En nu de speler tóch achter de bar staat: **de tv blijkt op stil te staan**. Het beeld speelt door; het gemompel van daarnet is weg. Wanneer is dat gebeurd? (afwijking nr. 2 — betwistbaar, precies goed) | onbehagen / trede 2 | P7, P4, P3 |
| **09:00–12:00** | **Kleedkamer 4.** Terug de gang in — en halverwege: **geluid uit kleedkamer 4**. Iets kantelt, klettert; een **voetbal rolt traag door de deuropening de gang in** en komt tegen de plint tot stilstand (§10). Binnen: een afgebroken schoonmaak — kar, emmer, de vloer half gemopt en opgedroogd, een klembord met een **takenlijst die midden in een regel stopt** (§6, document 3). Op de bank: de **sleutelbos**. De verklaring van het geluid ligt er ook: de bezem is omgevallen, het ballennet hangt scheef. Kán het de bezem zijn geweest die de bal losduwde? Ja. Wíl de speler dat geloven? Ook ja. (P7: we bevestigen niets.) | onbehagen, randje dreiging / trede 1–2 | P7, P2, P5 |
| **12:00–13:00** | **De schreeuw.** Terwijl de speler kleedkamer 4 uitloopt, sleutelbos in de hand: **ver buiten, gedempd door de regen, één schreeuw** (§11). Te lang voor een vogel, te vervormd voor een mens, te ver om zeker te zijn. Eén keer. Nooit herhaald, nooit oproepbaar. Daarna: de langste stilte van de slice (§7) — zelfs de flikkerbuis houdt een paar tellen vol. | **onbehagen → dreiging** / trede 1 (op zijn zwaarst) | P2, P7, P4 |
| **13:00–14:00** | **De gang, derde doorloop.** Alles is stil — en dat is de hele beat: de speler draagt de naklank van de schreeuw zélf de gang door. De flikkerbuis hervat zijn tik. Wie de zaklamp aanknipt bij het matglas van de nooddeur, beseft dat het glas twee kanten op werkt (P3 — puur ruimtelijk, zonder dat er iets gebeurt). *De eerder overwogen schaduw achter het matglas is per GD-besluit **geschrapt** (§12.1): drie escalaties zijn genoeg — minder is enger.* | dreiging (naklank) / trede 1–2 | P2, P3, P7 |
| **14:00–17:00** | **De onderhoudsruimte.** De sleutel past. Binnen: geen ramen, één peertje dat het niet doet — **zaklamp-territorium**, de donkerste drie minuten van de slice. Rekken, reserve-doelnetten, de cv-ketel die zacht bromt. Het gevonden-voorwerpen-rek: kratten met verweesde spullen — bidons, één schoen, regenjassen. En dáár, netjes op de plank: **zijn sporttas**. Wie hem openmaakt: telefoon en autosleutels erin, onaangeraakt. Bij het pakken van de tas **slaat de cv-ketel af** — de brom die de speler drie minuten niet bewust hoorde, valt weg, en de stilte duwt hem de ruimte uit (§7). Op de deurpost, aan de binnenkant, laag: **krassen** — te regelmatig voor slijtage, te grillig voor letters (§6, vondst 4; het woord "CRUMP" valt hier bewust nérgens, STORY §5). | dreiging / trede 2–3 | P1, P2, P7, P4 |
| **17:00–19:00** | **Naar buiten — en de glimp.** Doel gehaald; nu alleen nog naar huis. Door de hal, de regen weer in (de deken valt over de oren — wat hoor je nú niet? P3). Het pad langs het veld richting hek. Halverwege flikkert **lichtmast 3** — de mast waarover het logboekje in de onderhoudsruimte klaagde (§6, vondst 5: setup → payoff) — twee keer, en in de tweede lichtvlaag, aan de overkant van het veld, op de middenlijn: **een gestalte**. Stil. Verkeerde verhoudingen, op deze afstand niet te benoemen. Anderhalve seconde. De mast dooft; als hij weer aanflitst is de middenlijn leeg. **Dit is de glimp** (§11): geen sting, geen muziek, de regen ruist gewoon door — de wereld doet alsof er niets gebeurd is, en dát is het engste eraan (P5). Of hij de speler zag, wordt niet beantwoord (P3/P7). | **confrontatie op afstand** / trede 5, minimaal gedoseerd | P3, P7, P4, P2 |
| **19:00–20:00** | **Het hek.** De speler haast zich het pad af — en het hek waar hij doorheen kwam zit dicht, **met de ketting erom**. Die ketting hing er twintig minuten geleden los bij. Iemand — iets — heeft hem omgelegd terwijl de speler binnen was. Geen paniekmuziek, geen gerammel-cutscene: alleen de regen, het natte staal, en het besef dat de enige andere route naar buiten **terug door het gebouw** loopt. **Einde slice.** | scharnier / trede 2–3 (afwijking als mokerslag) | P1, P7, P5 |

**Boog-balans over de slice** (HORROR §1-kompas): ±2 min rust, ±11 min
onbehagen, ±5 min dreiging, ±2 min scharnier/confrontatie-op-afstand.
Dat is bewust onbehagen-zwaar: dit zijn de eerste twintig minuten van
een spel van drie tot vijf uur — wie hier al piekt, heeft straks niets
meer.

## 5. De doelketen (spelerdoelen, aaneengesloten)

1. **"Tas pakken"** (00:00) → kleedkamer 3.
2. **"Waar zijn mijn spullen?"** (±06:00) → het bordje: gevonden
   voorwerpen → onderhoudsruimte.
3. **"Ik heb die sleutel nodig"** (±08:00) → sleutelkastje achter de
   bar → haakje leeg.
4. **"Waar is de beheerder gebleven?"** (±09:30) → de afgebroken
   schoonmaak in kleedkamer 4 → sleutelbos.
5. **"Tas, en dan wegwezen"** (±14:00) → onderhoudsruimte → tas (mét
   telefoon en autosleutels — de uitweg lonkt).
6. **"Naar huis"** (±17:00) → naar buiten → glimp → hek op de ketting.
7. **"…terug naar binnen"** (20:00) — het doel van de vólgende snede,
   hier alleen geplant.

Elk doel is klein, banaal en dwingend tegelijk; geen enkel doel wordt
door UI opgelegd (geen questmarker, geen doellijst — P7: het spel
bevestigt niet wat je moet vinden; de wereld maakt het duidelijk).

## 6. Vondsten en documenten

Alle documenten kort en scanbaar (LEVEL §8); niets ervan is verplichte
lectuur; geen enkel document bevestigt wat er aan de hand is (P7). Geen
namen die de speler-identiteit invullen (STORY §2).

| # | Wat | Waar | Wat het doet |
|---|---|---|---|
| 1 | **Prikbord**: wedstrijdschema, kantinedienst-rooster, pupil-van-de-week-foto | hal | het normaal vestigen; de club bestond vanmiddag nog gewoon (P5) |
| 2 | **Briefje "Sleutels na sluit terug in het kastje!"** | naast het sleutelkastje, achter de bar | stuurt doelketen-stap 3 én maakt het lege haakje betekenisvol: de régel bestaat, iemand heeft hem gebroken |
| 3 | **Takenlijst van de beheerder** (klembord op de kar): "doelen op slot ✓ / kleedk. 3 ✓ / kleedk. 4 —" en dan niets meer, midden in de regel | kleedkamer 4 | het onaffe als onbehagen: hij is niet gestópt, hij is opgehóúden (P7); dateert de verlating impliciet |
| 4 | **De krassen** op de deurpost, binnenkant, kniehoogte | onderhoudsruimte | te regelmatig voor slijtage, te grillig voor letters; wie wil, ziet er bijna een woord in — wij bevestigen niets (P7; het woord CRUMP valt pas veel later, STORY §5) |
| 5 | **Storingslogboekje veldverlichting**: "mast 3 valt steeds uit. Monteur geweest, geen oorzaak. Doet het 's ochtends weer gewoon." | plank in de onderhoudsruimte | banale setup (P5) voor de payoff van 17:30: als mast 3 flikkert, wéét de lezer dat dit al langer speelt — en de niet-lezer mist niets essentieels (LEVEL §8: gelaagd, niet verplicht) |

## 7. Stilte-regie (P2 in de praktijk)

**Er klinkt in de hele slice geen noot muziek.** De eerste twintig
minuten van CRUMP verdienen hun spanning zonder score — muziek is
schaars en verdiend (HORROR §3), en de afwezigheid ervan ís hier het
statement: niemand vertelt je hoe je je moet voelen.

De vier bewuste stiltes, elk met een taak:

1. **02:10 — de deur valt dicht.** De regen-deken valt in één klap weg;
   binnen blijft alleen koelingzoem en tv-gemompel. De speler hóórt dat
   hij binnen is. (contrast vestigt het nulpunt)
2. **12:20 — na de schreeuw.** De langste stilte van de slice (±25 s
   niets, zelfs de flikkerbuis even stabiel). Stilte als naklank: het
   geluid is weg, maar niet vertrokken. (P7: was het er wel?)
3. **16:30 — de cv-ketel slaat af.** Een brom die de speler nooit
   bewust registreerde, verdwijnt — en ineens is de onderhoudsruimte
   té stil. De stilte duwt hem naar buiten. (stilte als beweegreden)
4. **18:00 — na de glimp.** Géén sting, géén stilte-truc: de regen
   ruist gewoon door alsof er niets is gebeurd. De wereld weigert het
   moment te bevestigen. (P5 en P7 in één beat)

## 8. Audio-regie (de uitgaven uit het stiltebudget)

Elk geluid is een gebeurtenis met een bron (P2); de belangrijkste
uitgaven, in volgorde van opkomst:

- **De regen** — buiten een deken die richtinghoren dempt (de speler
  is buiten dus dóver, precies wanneer hij het liefst zou horen — P3
  zonder één systeem); binnen een gedempt getrommel op het dak dat
  nooit helemaal weg is.
- **Koelingzoem + tv-gemompel** (kantine) — het warme nulpunt; het
  wegvallen van het tv-geluid (±08:00) is daarom informatie.
- **De druppende douche** (kleedkamer 3) — traag, onregelmatig genoeg
  om te blijven opvallen.
- **De flikkerbuis** (gang) — tik en zoem met zichtbare oorzaak; het
  ritme-anker van drie gangdoorlopen.
- **De val + de rollende bal** (±09:30, kleedkamer 4) — het eerste
  geluid van iets dat *gebeurt* in plaats van *doorloopt*; verklaring
  aanwezig maar niet sluitend (§10).
- **De schreeuw** (±12:20) — zie §11.
- **De cv-ketel** (onderhoudsruimte) — brom die je pas hoort als hij
  stopt.
- **Het hek en de ketting** (±19:30) — nat staal, dof; het laatste
  geluid van de slice is het geluid van een deur die de wereld achter
  je dichttrok.

De speler zelf blijft de luidste bron in het gebouw (voetstappen per
gangsoort, deuren, de zaklampklik) — alles wat hij doet, hoort hij, en
alles wat hij hoort, kan gehoord worden (P3; het spel bevestigt dat
nooit met een meter, P7).

## 9. Licht en de zaklamp

- **Vindplaats zaklamp**: de la achter de bar, naast de meterkast —
  dáár bewaart elke kantineploeg hem, voor de avond dat de stoppen
  eruit klappen. De speler vindt hem op het natuurlijke moment (±08:00,
  bij het sleutelkastje) en heeft hem nodig vanaf de onderhoudsruimte
  (±14:00). Tussen vondst en noodzaak zit bewust lucht: de speler
  ontdekt zélf dat aanknippen fijn is in de gang — en dat het glas van
  de nooddeur twee kanten op werkt (P3: zien kost gezien worden; de
  slice predikt dat niet, ze laat het voelen).
- **Lichtverloop van de slice**: van warm (kantinepui in de regen) via
  TL-schemer (gang: twee werkende buizen, één flikkerend — precies het
  006-fundament) naar zwart (onderhoudsruimte, zaklamp verplicht) en
  dan het buitendonker met één onbetrouwbare lichtmast. Licht wordt
  gaandeweg schaarser naarmate de speler verder van de uitgang is —
  de ruimte zegt wat de speler te verliezen heeft (P1).
- **Elke bron heeft een oorzaak** (LEVEL §5): de flikkerbuis is oud,
  mast 3 heeft een gedocumenteerde storing (§6.5), het peertje in de
  onderhoudsruimte is gewoon kapot. In deze slice is álle lichtgedrag
  nog verklaarbaar (HORROR §4: in hoofdstuk-1-territorium is elke
  flikkering verklaarbaar; de onzekerheid komt later).
- **Licht suggereert veiligheid maar garandeert niets** (kader 006):
  de kantine vóélt veilig — er is geen mechaniek die dat waarmaakt of
  breekt. In deze slice wordt dat vertrouwen alleen opgebouwd; het
  schenden is voor later.

## 10. De rollende bal (eventueel, geplaatst)

**Plek**: ±09:30, kleedkamer 4 — de bal rolt traag door de deuropening
de gang in, net vóór de speler de kleedkamer bereikt, en komt tegen de
plint tot stilstand.

- **Waarom hier**: het is het eerste *gebeuren* van de slice en het
  staat precies op de grens van verklaarbaar: in de kleedkamer ligt de
  omgevallen bezem en hangt het ballennet scheef. De speler kan de
  keten sluiten (bezem viel → net schoof → bal rolde) — maar wat déd
  de bezem omvallen? De verklaring lost het kleine raadsel op en laat
  het grote staan (P7).
- **Regels**: de bal rolt traag (geen worp, geen richting-naar-speler),
  het werkt óók als de speler net de andere kant op kijkt (dan hoort
  hij hem alleen — HORROR §5b.5), en het gebeurt exact één keer (P4).
- **Alternatief** (GD-keuze): dezelfde beat buiten op het pad
  (±17:20), een natte bal die zonder aanwijsbare reden van de
  middenstip wegrolt, vlak vóór de mast flikkert. Sterker beeld, maar
  hij concurreert daar met de glimp — twee bijzonderheden in dertig
  seconden devalueren elkaar (P4). **Advies: binnen, bij kleedkamer 4.**

## 11. CRUMP in deze slice: twee oren, anderhalve seconde

De totale aanwezigheid van CRUMP in twintig minuten: **één verre
schreeuw en één glimp van anderhalve seconde.** Meer niet (de eerder
overwogen schaduw achter het matglas is geschrapt, §12.1) — en elk
moment houdt zich aan de canon-correctie (CRUMP zwerft door het stadion
en over het terrein, wordt vaker gehoord dan gezien, schreeuwt zeer
zelden).

- **De schreeuw (±12:20)**: van buiten, ver (gevoelsmatig de overkant
  van het terrein), gedempt door regen en muren. Lang aangehouden,
  net-niet-dierlijk, zonder woorden. Eén keer in de hele slice, nooit
  herhaalbaar (P7: wie het wil terughoren om het zeker te weten, krijgt
  die kans nooit). Volume ruim onder schrik-piek (HORROR §5b.4): dit is
  géén jumpscare maar een mededeling van afstand — *er is hier iets,
  en het is ver weg.* Timing direct na het vinden van de sleutelbos:
  de speler heeft net zijn reden om verder te gaan, wij geven hem
  tegelijk de reden om dat niet te willen (P1).
- **De glimp (±18:00)**: op afstand (de overkant van het veld), in
  flikkerend lichtmastlicht, anderhalve seconde, roerloos of hooguit
  half afgewend. Regels, hard: CRUMP beweegt niet naar de speler toe;
  er volgt géén achtervolging, géén tweede kans, géén sting; het
  moment werkt ook als de speler net niet kijkt (dan blijft alleen de
  flikkering — en het latere gevoel iets gemist te hebben, wat bijna
  erger is); en de verschijning klopt ruimtelijk (hij stond ergens,
  hij is ergens heen — niets teleporteert aantoonbaar, GAME_BIBLE §6).
  Of CRUMP de speler heeft gezien, wordt niet beantwoord — niet nu,
  misschien nooit (P3: gezien wórden is de angst; P7: zekerheid is
  verdiend schaars).

**Wat CRUMP hier expliciet níét doet**: achtervolgen, jagen, deuren
openen, geluid maken binnen het gebouw, reageren op de zaklamp of op
gemaakt geluid. Deze slice bouwt de rekening op; innen komt later.

## 12. GD-besluiten (creatieve review 2026-07-28 — bindend)

1. **De schaduw achter het matglas is geschrapt.** De slice bevat al
   drie duidelijke escalaties (rollende bal, verre schreeuw, glimp);
   een extra vroege silhouetbeat maakt de opbouw te druk en vermindert
   de impact van de glimp rond minuut 18. Minder is enger (P4).
2. **De rollende bal blijft binnen**, in/nabij de kleedkamergang, met
   de omgevallen bezem als betwistbare natuurlijke verklaring. Nergens
   wordt bevestigd wat de bal werkelijk liet rollen (P7).
3. **De ketting om het buitenhek is de definitieve slotbeat.** De
   speler heeft tas, telefoon en autosleutels terug maar kan het
   terrein niet af; de enige voortgang loopt terug door het gebouw —
   de overgang naar het volgende deel van de game.
4. **De vergeten sporttas is de canonieke openingspremisse** (D-028);
   STORY en aanpalende canon zijn gecorrigeerd (§0).

## 13. Pillars-verantwoording (samenvatting)

- **P1 Kwetsbaarheid**: telefoon en autosleutels in de tas; geen enkel
  nieuw vermogen; de uitweg wordt hem aan het slot afgenomen.
- **P2 Stilte**: geen muziek in de hele slice; vier ontworpen stiltes;
  elk geluid een gebeurtenis met bron en betekenis.
- **P3 Gezien worden**: de zaklamp bij het matglas, de regen die het
  eigen gehoor dempt, de onbeantwoorde vraag of de gestalte keek.
- **P4 Minder is enger**: één sleutel, één schreeuw, één glimp, één
  bal, zeven ruimtes. Elke beat gebeurt exact één keer.
- **P5 De wereld is groter dan CRUMP**: de slice werkt óók als CRUMP
  nooit verschijnt — een verlaten clubgebouw in de regen, een
  afgebroken schoonmaak, een tv op stil. De gesloten deuren en het
  logboekje beloven een wereld voorbij de snede.
- **P6 Gameplay boven spektakel**: de speler kiest elke stap zelf
  (doelketen van banale beslissingen); geen enkel moment vereist dat
  hij de goede kant op kijkt. Kanttekening, eerlijk benoemd: deze
  slice is als opening **geplaatst en eenmalig** — regie is hier de
  bewuste uitzondering (zelfde regime als de opening, GAME_BIBLE),
  want er bestaat nog geen systeem-CRUMP. Alles wat hier gescript
  wordt, is later door systemen te vervangen zonder het ontwerp te
  breken.
- **P7 Onzekerheid**: elke afwijking is betwistbaar (de tv, de bal),
  niets wordt bevestigd, niets is herhaalbaar, en de enige
  onweerlegbare feiten (de tas op de plank, de ketting om het hek)
  verklaren níéts.

**HORROR §9-toets** (de vijf vragen, voor de slice als geheel): (1) de
boog loopt van rust naar één gedoseerde confrontatie-op-afstand met
±60/25/10/5-verhouding; (2) het normaal is het clubgebouw zoals
iedereen het kent, geschonden in millimeters; (3) elke gebeurtenis is
achteraf reconstrueerbaar (bezem, storing mast 3, paniekbalk); (4) geen
enkele beat vereist camerarichting; (5) haal CRUMP en alle geluid weg
en er blijft een gebouw over dat óók dan onaangenaam is — dat is
precies de fase-2-lat die de GD zojuist heeft goedgekeurd.

## 14. Wat dit ontwerp bewust níét regelt — en de harde randvoorwaarden

Geen systeemontwerp, geen AI, geen techniek: hoe de beats, deurstaten
en vondsten gebouwd worden is aan de technische ontwerpen per
productiefase (§15). Ook buiten scope: save/checkpoints van de slice,
UI/HUD voorbij de documentlezer, de eventuele proloog "de derde helft"
(STORY §8), en alles voorbij minuut 20 (de terugkeer het gebouw in is
de cliffhanger, niet het onderwerp).

**Randvoorwaarden uit de creatieve review (bindend):**

- **De vijf documenten (§6) zijn pas speelbaar na taak 007** (minimale
  documentlezer). Tot die tijd bestaan ze hooguit als props zonder
  lees-UI.
- **De slice wordt eerst volledig als greybox gevalideerd** (fases C–E):
  route, maten, deurflow en pacing krijgen GD-akkoord vóórdat er één
  finaal materiaal, model of sfeerasset in gaat (fases F–G). Blockout
  eerst is al huisregel (LEVEL §7); hier is het bovendien een gate.
- **De glimp van CRUMP vereist géén monster-AI** en loopt nergens
  vooruit op taak 009: het is een eenmalig geplaatste, getriggerde
  verschijning van een representatie (tijdelijk of definitief — besluit
  in fase F), zonder waarneming, navigatie of gedrag. Fase I start pas
  als die representatie er is.

## 15. Productieplan (besluit GD: kleine, afzonderlijk reviewbare fasen)

*De slice wordt níét als één implementatietaak gebouwd. Iedere fase
volgt het vaste ritme (ontwerp waar nodig → go → bouw → rapport →
GD-test) en is klein genoeg om afzonderlijk te reviewen. Volgorde is
dwingend waar afhankelijkheden staan; B kan parallel aan C.*

### Fase A — Canon- en taaknummercorrectie ✅ (afgerond 2026-07-28)
- **Doel**: één kloppende papierwereld vóór er iets gebouwd wordt.
- **Scope**: D-028 doorgevoerd (STORY, GAME_BIBLE, HORROR, LEVEL,
  ROADMAP); nummering 007–010 herzien; dit dossier bijgewerkt.
- **Buiten scope**: brede lore-herschrijving; codecommentaar (volgt in
  de eerstvolgende codetaak).
- **Afhankelijkheden**: geen. · **Exit**: gepusht, geen dubbele of
  verouderde taaknummers in docs. · **Pijlers**: P5 (consistente
  wereld). · **GD-test**: docs-review.

### Fase B — Minimale documentlezer (taak 007)
- **Doel**: documenten kunnen gelezen worden — de vijf vondsten van de
  slice worden speelbaar.
- **Scope**: conform `tasks/007_document_reader.md` (datamodel,
  verwijderbare lees-UI, inputblokkering, Esc-sluiten).
- **Buiten scope**: codex, verzamellijsten, documentinventaris,
  voice-over, animaties, save/load.
- **Afhankelijkheden**: A. Kan parallel aan C. · **Exit**: suite groen,
  D-015 beide richtingen, GD leest het dev-room-briefje en sluit met
  Esc. · **Pijlers**: P2 (lezen is stil), P5 (de omgeving vertelt), P7
  (documenten mogen onvolledig zijn). · **GD-test**: briefje openen,
  bewegen geblokkeerd, Esc herstelt alles.

### Fase C — Greybox van alle ruimtes en de hoofdroute
- **Doel**: de zeven ruimtes van §2 op menselijke maat, loopbaar als
  één route.
- **Scope**: hal, kantine, gang, kleedkamers 3+4, onderhoudsruimte,
  buitenstuk (voorplein + pad + hek); collision; sightlines en
  oriëntatie-ankers; alle deuren van §3 geplaatst met begintoestand;
  werklicht-/nachtstaat zoals de dev room (006-fundament).
- **Buiten scope**: art, beats, documenten-inhoud, tuning van sfeer;
  de dev room blijft bestaan als testruimte.
- **Afhankelijkheden**: A. · **Exit**: import + suite groen (incl.
  budgetregels per ruimte), route start-tot-hek loopbaar. · **Pijlers**:
  P5, P1 (maat en krapte). · **GD-test**: route lopen in werklicht én
  nacht; maten en zichtlijnen beoordelen.

### Fase D — Gameplay-objectieven en sleutel-/zaklampflow
- **Doel**: de doelketen van §5 speelbaar van aankomst tot ketting.
- **Scope**: tas-prop + gevonden-voorwerpen-plek; leeg haakje; bordje
  en briefjes op hun plek (leesbaar via B); sleutelkastje met leeg
  haakje; sleutelbos in kleedkamer 4; slot op de onderhoudsruimte;
  zaklamp-vindplaats naar de bar-la; de ketting als eindtoestand.
- **Buiten scope**: alle sfeerbeats (H), art (G), de glimp (I).
- **Afhankelijkheden**: B + C. · **Exit**: slice start-tot-slot
  speelbaar als kale flow; tests dekken deurstaten, sleutel- en
  bezitflow. · **Pijlers**: P6 (doelen zonder markers), P4 (één
  sleutel). · **GD-test**: de keten blind kunnen volgen zonder UI-hulp.

### Fase E — Pacing- en looprouteacceptatie (GD-gate) 🔑
- **Doel**: het go/no-go-moment vóór alle aankleding.
- **Scope**: GD speelt de greybox-slice volledig; looptijden per beat
  naast §4 gelegd; correcties op maat/route/volgorde.
- **Buiten scope**: oordeel over sfeer of art (bestaat nog niet).
- **Afhankelijkheden**: C + D. · **Exit**: **expliciete GD-go op
  greybox en pacing** — de poort naar F–I. · **Pijlers**: P6. ·
  **GD-test**: volledige doorloop, klok ernaast.

### Fase F — Art-direction- en assetplan
- **Doel**: vastleggen hoe de slice eruit gaat zien vóór er assets
  ontstaan.
- **Scope**: visuele richting per ruimte (referenties, paletten,
  Nederlands-nuchter); assetlijst (modellen, materialen, props,
  geluiden) met per asset placeholder/zelf maken/inkopen; **besluit
  over de CRUMP-representatie voor de glimp** (tijdelijk silhouet of
  definitief ontwerp — randvoorwaarde voor I).
- **Buiten scope**: assets bouwen; addons zonder GD-akkoord (CLAUDE.md).
- **Afhankelijkheden**: E. · **Exit**: GD keurt plan + assetlijst. ·
  **Pijlers**: P4 (geen content-vulling), P5. · **GD-test**:
  plan-review (docs).

### Fase G — Eerste environment-artpass
- **Doel**: van greybox naar de sfeer van §2/§9 — het "onaangenaam
  zonder dat er iets gebeurt"-niveau van 006, nu per slice-ruimte.
- **Scope**: materialen/modellen/props conform F; lichtontwerp per
  ruimte binnen het schaduwbudget (D-026); TL-staten per ruimte;
  fog-/ambientkalibratie per ruimte.
- **Buiten scope**: beats (H), glimp (I), finale audio-assets.
- **Afhankelijkheden**: E + F; kan parallel aan H. · **Exit**: suite
  groen (budget per ruimte), GD-hardware-oordeel per ruimte. ·
  **Pijlers**: P5, P2 (visuele stilte), P4. · **GD-test**: elke ruimte
  in nachtstaat lopen, met en zonder zaklamp.

### Fase H — Gescripte sfeerbeats
- **Doel**: de eenmalige, geplaatste gebeurtenissen van §4/§7/§8: de
  rollende bal (binnen, §12.2), de verre schreeuw, de stiltewisselingen
  (tv-mute, cv-ketel) en de stroommomenten (flikkerbuis-ritme, mast 3).
- **Scope**: elk beat eenmalig, met wereld-oorzaak waar ontworpen,
  volgens de eerlijkheidsregels (werkt ook als de speler wegkijkt);
  placeholder-audio waar finale assets ontbreken.
- **Buiten scope**: de glimp (I); alles herhaalbaars of systemisch —
  dit is de regie-uitzondering (P6-kanttekening §13) en blijft dat.
- **Afhankelijkheden**: D (flow) + E; audio-assets uit F waar gereed. ·
  **Exit**: beats headless triggerbaar en getest waar mogelijk;
  GD-doorloop met beats voelt als §4. · **Pijlers**: P2, P7, P4. ·
  **GD-test**: volledige doorloop; elke beat exact één keer.

### Fase I — De eerste CRUMP-glimp
- **Doel**: de climax van de slice (±18:00) — anderhalve seconde onder
  mast 3.
- **Scope**: getriggerde, eenmalig geplaatste verschijning van de in F
  gekozen representatie; mast-flikkering als lichtgebeurtenis;
  ruimtelijk kloppend (ergens vandaan, ergens heen); werkt ook zonder
  dat de speler kijkt.
- **Buiten scope**: élke vorm van AI, waarneming, navigatie of gedrag —
  niets hiervan loopt vooruit op taak 009; geen sting, geen muziek.
- **Afhankelijkheden**: F (representatie beschikbaar) + G/H. ·
  **Exit**: glimp voldoet op hardware aan alle regels van §11. ·
  **Pijlers**: P3, P7, P4. · **GD-test**: meerdere doorlopen (kijkend,
  wegkijkend, rennend) — het moment mag nooit breken.

### Fase J — Eindtuning en Vertical Slice-acceptatie
- **Doel**: het geheel — de eerste twintig minuten als één ervaring.
- **Scope**: pacingtuning over de hele boog, audiomix, lichtkalibratie,
  kleine leesbaarheidscorrecties; registers en dossiers bij.
- **Buiten scope**: nieuwe features, nieuwe beats, scope-groei — wat er
  in J niet in zit, zit er niet in (P4).
- **Afhankelijkheden**: alle voorgaande. · **Exit**: **volledige
  GD-acceptatie van de slice op hardware** = exit fase 2½ (ROADMAP);
  daarna pas besluiten over het vervolg (taak 009 of hoofdstuk 1-
  ontwerpsessie). · **Pijlers**: alle zeven. · **GD-test**: de slice
  van aankomst tot ketting, in één sessie, koptelefoon op.
