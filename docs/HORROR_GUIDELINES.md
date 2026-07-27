# CRUMP — Horror Guidelines

*Hoe CRUMP eng is. Dit document maakt van "horror" een ontwerpdiscipline met
regels, zodat elke scène, elk geluid en elke AI-beslissing dezelfde soort angst
opbouwt. Gebaseerd op de pijlers uit GAME_BIBLE §3.*

---

## 1. Het spanningsmodel: de boog, niet de piek

Angst in CRUMP is een **boog** die we bewust opbouwen, vasthouden en lossen:

```
rust → onbehagen → dreiging → confrontatie/ontlading → (nieuwe) rust
```

- Spelers kunnen niet permanent bang zijn; wie constant piekt, stompt af.
  **Rust is dus geen pauze van de horror, het is onderdeel ervan** — de
  veilige momenten maken de onveilige leesbaar.
- Elke ruimte/sequentie weet waar hij op deze boog zit (leg dit vast in het
  levelontwerp, zie LEVEL_GUIDELINES §4).
- Vuistregel-ritme per half uur spel: ~60% onbehagen, ~25% dreiging,
  ~10% rust, ~5% confrontatie. Dit is een kompas, geen wet.

## 2. De ladder van angst (gebruik de laagste trede die werkt)

1. **Suggestie** — een geluid uit een ruimte die leeg hoort te zijn.
2. **Afwijking** — iets is anders dan de speler het achterliet.
3. **Aanwezigheid** — bewijs dat iets er nú is (schaduw, deurklink beweegt).
4. **Dreiging** — het is dichtbij en de speler moet handelen (verstoppen).
5. **Confrontatie** — zien en gezien worden. Zeldzaam, dus betekenisvol.

Hoe lager op de ladder, hoe vaker het mag voorkomen. Trede 5 is een budget:
**maximaal enkele keren per hoofdstuk.**

## 3. Geluid (pijler 1 in de praktijk)

- **Stilte is de standaard.** De ambient-laag van het verlaten sportpark
  (zoemende koeling achter de bar, de tv die nog aanstaat, wind langs de
  lichtmasten, de verre provincialeweg) is het nulpunt; elke afwijking
  dáárvan is informatie.
- **Diegetisch eerst**: geluiden komen uit de wereld (leidingen, deuren,
  iets dat valt). Niet-diegetische stingers zijn zeldzaam en gekoppeld aan
  echte gebeurtenissen, nooit "sfeer-spam".
- **Geluid is tweerichtingsverkeer**: de speler máákt ook geluid (rennen,
  deuren, vallende props) en CRUMP hoort dat (event-bus,
  ARCHITECTURE §5.3). Het volume dat de speler hoort ≈ de luidheid die de
  wereld registreert; zo leert de speler intuïtief wat "te luid" is.
- **Richtinghoren moet kloppen.** 3D-audio positioneel correct; de speler
  moet blind kunnen navigeren op waar het geluid vandaan komt. Test met
  koptelefoon (QA_CHECKLIST).
- Muziek: schaars, verdiend, en nooit als waarschuwingssysteem dat de AI
  verklapt — spanning mag stijgen zonder dat er echt gevaar is (en andersom
  één keer per hoofdstuk juist wél gevaar zonder muziek: de speler mag het
  systeem nooit volledig vertrouwen).

## 4. Licht en zicht

- **Donker is informatie-arm, nooit informatie-loos**: silhouetten en
  contouren blijven leesbaar. Frustratie ("ik zie gewoon niks") doodt angst.
- De zaklamp is een keuze met een prijs: zien kost zichtbaarheid. Dat
  dilemma is een kernmechaniek — licht aan = beter zicht én beter gezien.
- Lichtwisselingen (flikkeren, uitval) zijn gebeurtenissen met oorzaak in de
  wereld (meterkast, storing), geen willekeurige spookjes. In hoofdstuk 1
  is elke flikkering nog verklaarbaar; pas later wordt dat onzeker.

## 5a. De eerste 15 minuten (harde regel)

De openingsfase van het spel — vanaf het moment dat de speler de lege
kantine ontdekt — is heilig:

1. **Geen monster.** CRUMP verschijnt pas veel later in het spel.
2. **Geen achtervolging.**
3. **Geen goedkope jumpscares.**
4. **Alleen subtiele veranderingen in de omgeving** (ladder-trede 1–2):
   dingen die nét anders staan, geluiden die nét niet kloppen.

Doelgevoel van deze fase, letterlijk: *"er klopt iets niet."* Niet meer.
Wie hier spanning wil "helpen" met een schrikmoment, breekt de hele opbouw
van het spel — deze regel heeft geen uitzonderingen.

## 5b. Jumpscares: het contract

Jumpscares zijn kruiden, geen hoofdgerecht. Regels:

1. **Budget: maximaal één harde jumpscare per hoofdstuk** — en hij moet
   verdiend zijn (opgebouwd, met betekenis, gevolg hebbend).
2. Nooit als straf voor nieuwsgierigheid die we juist aanmoedigen (een la
   opentrekken mag niet willekeurig een schreeuw opleveren, anders stopt de
   speler met het gedrag waar het spel op draait).
3. Geen fake-outs met kat-uit-de-kast-logica ("haha, het was een kapstok").
   Eén keer nep en de speler gelooft ook de echte niet meer.
4. Volume-piek begrensd (QA_CHECKLIST §gehoor): schrikken ≠ pijn doen.
5. Een gemiste jumpscare (speler keek net de andere kant op) moet géén
   probleem zijn — als de scène alleen werkt met perfecte camerarichting,
   is het geen goede scène.

## 6. CRUMP inzetten

*Gedragssysteem in taak 007; dit zijn de regels voor hoe de dreiging gebruikt
wordt zodra hij — veel later in het spel — actief wordt.*

- **Zeldzaamheid = waarde.** Elke seconde vol zicht op CRUMP verlaagt
  zijn prijs. Suggestie en aanwezigheid (ladder 1–3) zijn het dagelijkse
  gereedschap; volledig zicht is een climax.
- **Eerlijk en leesbaar**: CRUMP heeft hoorbare/zichtbare tells, het
  spawnt nooit in beeld en teleporteert nooit aantoonbaar (GAME_BIBLE §6).
  De speler moet achteraf altijd kunnen reconstrueren hoe het hem vond.
- **Geen scripted kill zonder uitweg.** Elke dreigingssituatie heeft
  minstens één leesbare overlevingsoptie. Gepakt worden is de schuld van
  een inschattingsfout, nooit van de regie.
- **De AI speelt niet vals**: geen wallhacks op spelerspositie buiten de
  gedefinieerde zintuigen. Spanning die uit valsspelen komt, voelt de
  speler — en het went bovendien verkeerd.

## 7. Psychologische horror: de CRUMP-specialiteit

- **Het vertrouwde is het paard van Troje.** De opening (STORY §3) laat de
  speler de kantine en kleedkamer in hun normale, levende staat zien; daarna
  keert hij er telkens terug. Afwijking-van-bekend is ons krachtigste wapen —
  daarom is de openingsscène zo gewoon: ze bouwt het "normaal" op dat we de
  rest van het spel kunnen schenden.
- **Kleine afwijkingen winnen**: een stoel die 30 cm verschoven is, is enger
  dan een omgegooide kast. De speler moet twijfelen of hij het zich verbeeldt.
- **Onzekerheid boven uitleg**: we bevestigen of ontkennen zo laat en zo min
  mogelijk. Wat de speler zelf invult is enger dan wat wij tonen.
- **De speler is nooit "gek"**: we suggereren onbetrouwbaarheid van de
  wereld, niet van de bediening. Besturing, saves en UI zijn altijd
  betrouwbaar (geen meta-trucs, GAME_BIBLE §8) — het contract is: jij bent
  echt, de wereld misschien niet.

## 8. Respect voor de speler

- **Toegankelijkheid ondermijnt horror niet**: helderheid-slider,
  ondertitels (met geluidsbeschrijvingen: *"[gekras boven het plafond]"*),
  motion-sickness-opties (FOV, head-bob uit). Een speler die misselijk wordt
  is geen bange speler.
- **Geen goedkope trauma-triggers** als schrikmateriaal (geen kinderen in
  gevaar als effectbejag, geen huisdieren-gore). Wij bouwen onbehagen, geen
  walging.
- **Falen respecteert tijd**: checkpoints zó dat een dood maximaal enkele
  minuten kost. Frustratie over verloren voortgang vervangt angst door
  irritatie — en irritatie is het einde van elke horror-ervaring.

## 9. Toetssteen bij elke nieuwe scène

Vijf vragen die bij review beantwoord moeten worden:

1. Waar zit dit op de spanningsboog (§1) en op de ladder (§2)?
2. Wat is hier het "normaal", en wat schendt het?
3. Kan de speler achteraf reconstrueren wat er gebeurde? (eerlijkheid)
4. Werkt de scène ook als de speler nét de verkeerde kant op kijkt?
5. Zou de scène nog werken zónder muziek en zónder CRUMP? Zo nee, doet de
   ruimte zelf te weinig werk.
