# CRUMP — Level Guidelines

*Hoe een CRUMP-ruimte ontworpen en gebouwd wordt. Vertaalt de horror-visie
naar concrete leveldesign-regels en technische kaders. Elk level wordt tegen
dit document getoetst voordat het "af" heet.*

---

## 1. Filosofie: de plek is een personage

Sportpark Oostpolder is geen decor maar een verteller (GAME_BIBLE pijler 2).
Een ruimte moet vóór er iets gebeurt al iets zeggen: over wie hier net nog
waren, wat hier elke zaterdag gebeurt, en wat er dus mist nu iedereen weg is.
Als een lege ruimte niets vertelt, is hij nog niet af.

## 2. De gouden regels

1. **Leesbaarheid onder druk.** De speler moet ook in het donker, ook in
   paniek, de ruimte kunnen lezen: waar is de uitgang, waar kan ik heen. Een
   ruimte waarin je alleen bij daglicht wegwijs wordt, is een ontwerpfout.
2. **Elke ruimte heeft een reden om er te zijn** — een taak, een vondst, een
   doorgang, een beslissing. Ruimtes-om-de-ruimte bestaan niet.
3. **Oriëntatiepunten.** Herkenbare ankers (de bar, de trofeeënkast, de
   tv-hoek, de doorgang naar de kleedkamers) zodat de speler een mentale
   kaart bouwt — nodig om "het is veranderd"-momenten te laten landen.
4. **Meerdere routes waar het telt.** Zeker in ruimtes waar CRUMP kan komen:
   minstens twee manieren erdoor/eruit, en een verstopplek die eerlijk
   zichtbaar is.
5. **Sightlines zijn ontwerp.** Wat de speler wel/niet kan zien vanaf welk
   punt is bewust geplaatst — voor suggestie (iets nét buiten beeld) en voor
   eerlijkheid (de dreiging zien aankomen als het mag).

## 3. De vertrouwde route als ruggengraat

De opening (STORY §3) legt de basisroute vast: kantine → gang → kleedkamer
→ terug. Die aangeleerde route is de leidraad voor de plattegrond:

- De speler keert **herhaaldelijk langs dezelfde plekken** terug — dat maakt
  afwijkingen leesbaar (HORROR_GUIDELINES §7). De kantine is de referentie-
  staat van het hele spel: elke wijziging t.o.v. de openingsscène is
  informatie.
- Latere doelen (bijgebouwen, velden, de rand van het park) haken aan op
  deze basisroute, zodat de speler zijn mentale kaart uitbreidt in plaats
  van steeds opnieuw begint.
- Hoofdstuk 1 leert de route in zijn "normale" staat; latere hoofdstukken
  schenden precies die aangeleerde verwachting.

## 4. Spanningskaart per ruimte

Elke ruimte krijgt in zijn ontwerp-notitie een label op de spanningsboog
(HORROR_GUIDELINES §1):

| Label | Rol | Kenmerken |
|---|---|---|
| **Adem** | rust/veilig | licht, overzicht, geen dreiging; save-plek |
| **Onrust** | onbehagen | subtiele afwijkingen, geluid uit de verte |
| **Druk** | dreiging | slecht zicht, meerdere routes, monster kan hier |
| **Scharnier** | beslissing/confrontatie | keuze of climax; zeldzaam |

Een goede plattegrond wisselt deze labels af — nooit vijf "Druk"-ruimtes op
rij (afstomping), nooit alleen maar "Adem" (verveling).

## 5. Licht als leveldesign

- **Lichtbudget per ruimte** (ARCHITECTURE §7): richtlijn **max. 4 realtime
  schaduw-werpende lichten** tegelijk zichtbaar; de rest is gebakken of
  schaduwloos. Licht is de duurste post van dit spel.
- Elke lichtbron heeft een **bron in de wereld** (armatuur, raam, het
  zaklampje) — geen zwevende fill-lights zonder verklaring.
- Ontwerp met **licht én donker als vorm**: donkere zones zijn plekken waar
  de speler niet wíl kijken maar moet; lichte zones zijn adem. Pikzwart
  zonder enige contour is verboden (HORROR_GUIDELINES §4).
- Flikkering/uitval is een ontworpen gebeurtenis met oorzaak, geen decoratie.

## 6. Schaal, tempo en navigatie

- **Menselijke maat.** Deurhoogtes, gangbreedtes, plafonds realistisch;
  Sportpark Oostpolder moet aanvoelen als een echt Nederlands sportcomplex
  (clubhuis, kleedkamergang, materiaalhok), niet als een game-level. Het
  alledaagse is de basis waar de horror tegen afsteekt.
- **Bewuste krapte en ruimte** als ritme-instrument: de nauwe kleedkamergang
  (kwetsbaar, geen ontsnapping) tegenover een open veld onder lichtmasten
  (blootgesteld, ver zicht).
- **Loopafstanden dienen het tempo, niet de padding.** Nooit lange lege
  loopstukken zonder betekenis; als de speler ergens heen loopt, gebeurt er
  onderweg iets of vertelt de ruimte iets.
- **Backtracking mag** (past bij de vertrouwde route) maar verandert de
  tweede keer: ander licht, andere staat, andere dreiging.

## 7. Technische bouwstandaard

- **Blockout eerst.** Elke ruimte begint als grijze blokkendoos met correcte
  maten en collision; pas als de *ruimte werkt* (navigatie, sightlines,
  spanning) volgt art-pass. Nooit andersom.
- **Ruimte = eigen scène**, geïnstantieerd in de hoofdstuk-scène
  (ARCHITECTURE §5.5). Een ruimte moet los in de editor te openen en te
  testen zijn.
- **Collision klopt met de visuals**: geen onzichtbare muren, geen geometrie
  waar de speler doorheen valt. Wordt in QA expliciet gelopen.
- **Navigatie-mesh** per ruimte gebakken en aansluitend op de buren, zodat
  CRUMP naadloos kan navigeren (taak 007).
- **Props uit `game/props/`** worden geïnstantieerd, niet gedupliceerd;
  ruimte-specifieke staat (welke deur op slot) leeft in `GameState`.
- **Occlusion/performance**: grote panden worden in secties opgedeeld zodat
  niet het hele gebouw tegelijk rendert; het 60fps-doel (ARCHITECTURE §7)
  is een ontwerpbeperking, niet een naderhand-probleem.

## 8. Environmental storytelling in de praktijk

- **Toon, vertel niet.** Een half getapt biertje, een telefoon die nog op
  tafel ligt, een stoel die half naar achteren staat — de verdwijning
  verteld in stillevens, zonder één regel uitleg.
- **Leesbaar in seconden.** Documenten zijn kort en scanbaar; de speler mag
  nooit een leesmuur voor de kiezen krijgen om verder te mogen.
- **Consistentie met de canon.** Elke vondst klopt met STORY.md; namen en
  details (VV Drechtstreek, Sportpark Oostpolder, de spelregels rond CRUMP
  als mysterie) blijven consistent.
- **Gelaagd, niet verplicht.** De hoofdlijn is voor iedereen leesbaar; de
  diepere waarheid beloont wie zoekt. Nooit essentiële voortgang achter
  optionele lore verstoppen.

## 9. Checklist: is deze ruimte af?

- [ ] Spanningslabel toegewezen en past in het ritme van het hoofdstuk (§4).
- [ ] Vertelt iets in lege staat (§1, §8).
- [ ] Leesbaar en navigeerbaar in het donker (§2.1).
- [ ] ≥2 routes en een eerlijke verstopplek als het een "Druk"-ruimte is (§2.4).
- [ ] Binnen het lichtbudget; elke lichtbron heeft een wereld-oorzaak (§5).
- [ ] Blockout-getest op maat, sightlines en spanning vóór art-pass (§7).
- [ ] Collision en navmesh kloppen, geen doorval-geometrie (§7).
- [ ] Draait binnen het performance-budget (§7).
- [ ] Vondsten consistent met STORY.md (§8).
- [ ] Als eigen scène te openen en te testen (§7).
