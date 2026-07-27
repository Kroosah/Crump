# CRUMP — Game Bible

*Het ene document dat vastlegt wat CRUMP is. Bij elke ontwerpvraag is dit de
scheidsrechter. Wijzigingen aan dit document zijn een studiobeslissing (Randy),
geen implementatiedetail.*

---

## 1. Eén zin

Je bent alleen op een plek waar je 's nachts niet hoort te zijn, en iets weet
dat je er bent.

## 2. De kern-ervaring (speler-fantasie)

De speler moet zich voelen als een gewoon mens in een omgeving die eerst
vertrouwd en saai is, en langzaam onbetrouwbaar wordt. Geen soldaat, geen held:
iemand met een zaklamp, zweethanden en een reden om te blijven terwijl elke
gezonde instinct zegt: ga weg.

De drie gevoelens die we bij de speler willen oproepen, in volgorde van
belangrijkheid:

1. **Onbehagen** — er klopt iets niet, maar je kunt niet aanwijzen wat.
2. **Kwetsbaarheid** — je kunt niet vechten; zien en gezien worden is het spel.
3. **Nieuwsgierigheid** — je gaat verder, niet omdat het moet, maar omdat je
   het wíl weten.

Als een feature een van deze drie niet dient, hoort hij niet in CRUMP.

## 3. Ontwerp-pijlers

Elke beslissing wordt tegen deze vier pijlers gehouden:

### Pijler 1 — Stilte is het instrument
Geluid draagt de horror. Stilte is de standaardtoestand; elk geluid is een
gebeurtenis met betekenis. Muziek is schaars en verdiend. Zie
`HORROR_GUIDELINES.md` §3.

### Pijler 2 — De omgeving vertelt
Geen cutscene-exposition. Het verhaal zit in wat er op een bureau ligt, welke
deur op slot zit, wat er op een briefje staat. De speler reconstrueert zelf wat
er gebeurd is (environmental storytelling). Zie `STORY.md`.

### Pijler 3 — Onmacht, geen actie
Er zijn geen wapens. De werkwoorden van de speler zijn: kijken, luisteren,
lopen, sluipen, verstoppen, oppakken, lezen, kiezen. Het monster is een
probleem dat je ontwijkt en leert lezen, nooit iets dat je oplost met geweld.

### Pijler 4 — Eerlijke angst
Angst komt uit anticipatie en consequentie, niet uit willekeur. De speler mag
sterven doordat hij een risico verkeerd inschatte, nooit doordat de game
oneerlijk was. Jumpscares zijn schaars gereedschap met strikte regels
(`HORROR_GUIDELINES.md` §5).

## 4. Toon en stijl

- **Toon**: ingehouden, realistisch, Nederlands-nuchter dat langzaam kantelt.
  Denk *nachtdienst-gevoel*: TL-balken, zoemende apparaten, koffie die koud
  wordt. Het bovennatuurlijke sijpelt binnen in plaats van dat het binnenvalt.
- **Visueel**: gegrond realisme. Geen gore als versiering; sporen van iets
  vreselijks zijn effectiever dan het vreselijke zelf. Duisternis is nooit
  pikzwart-zonder-informatie: de speler moet altijd nét genoeg zien om bang
  te zijn voor wat hij niet ziet.
- **Taal**: het spel is Nederlandstalig van origine (ondertitels, briefjes,
  UI). Engels volgt bij de Steam-release via `localization/`.

## 5. De speler

- **Perspectief**: first person, camera op ooghoogte, bewuste, iets trage
  beweging (geen bunny-hop-gevoel).
- **Vaardigheden**: lopen, sluipen, rennen (kort, hoorbaar, met consequentie),
  bukken, interacteren, zaklamp, inventory van enkele items.
- **Gezondheid**: geen healthbar. Toestand wordt gecommuniceerd via beeld,
  geluid en gedrag (ademhaling, hartslag). Falen = gepakt worden, en de game
  herstart bij een eerlijk checkpoint.

## 6. Het monster (visie op hoog niveau)

*Implementatie volgt pas in taak 007; dit is het ontwerpkader.*

- Er is (in elk geval hoofdstuk 1–3) **één** dreiging. Eén monster dat de
  speler leert kennen is enger dan tien die je vergeet.
- Het monster is een **systeem**, geen scripted schrikmoment: het patrouilleert,
  hoort, onderzoekt en onthoudt kort. De speler kan het leren lezen (geluid,
  ritme, signalen) en dat lezen is de kern van de spanning.
- Het monster wordt **spaarzaam getoond**. Suggestie eerst: geluid, schaduw,
  iets dat verplaatst is. Volledig zicht is een climax, geen routine.
- Regel: het monster "spawnt" nooit in het zicht van de speler en teleporteert
  nooit aantoonbaar. De illusie dat het ergens vandaan kwam moet altijd kloppen.

## 7. Structuur van het spel

- **Omvang**: 4 hoofdstukken, samen 3–5 uur speeltijd. Kwaliteit boven lengte.
- **Opbouw**: hoofdstuk 1 is vrijwel monstervrij (vertrouwen en onbehagen
  opbouwen), hoofdstuk 2 introduceert de dreiging als systeem, hoofdstuk 3
  escaleert en geeft de speler middelen én dilemma's, hoofdstuk 4 is de
  afrekening en de onthulling. Details: `STORY.md`.
- **Save-systeem**: checkpoints op veilige momenten + save bij verlaten.
  Geen quicksave (spanning lekt weg als elke situatie herlaadbaar is).

## 8. Wat CRUMP níet is

Net zo belangrijk als wat het wel is:

- ❌ Geen combat-game, geen wapens, geen "toch nog een shotgun in act 3".
- ❌ Geen jumpscare-verzameling; zie de regels in `HORROR_GUIDELINES.md`.
- ❌ Geen open wereld. Compacte, dichte, handgemaakte ruimtes.
- ❌ Geen verzamelobjecten-om-het-verzamelen. Elk opraapbaar ding heeft
  betekenis of gebruik.
- ❌ Geen gore-spektakel. Suggestie boven expliciet.
- ❌ Geen meta-horror die de vierde wand breekt (geen nep-crashes, geen
  gerommel met de savegames van de speler). Het contract met de speler is
  heilig: de gáme is eerlijk, de wéreld is dat niet.

## 9. Referentiekader

Ter kalibratie van toon en kwaliteit (niet om te kopiëren):

- *Amnesia: The Dark Descent* — kwetsbaarheid, monster als systeem.
- *SOMA* — betekenis en onbehagen boven schrik.
- *P.T.* — herhaling van vertrouwde ruimte die subtiel verandert.
- *Alien: Isolation* — leesbare, onscriptbare dreiging.
- *Firewatch* (geen horror) — omgeving en tekst die een plek echt maken.

## 10. Succescriteria

CRUMP is geslaagd als:

1. Playtesters het licht aan doen of de koptelefoon afzetten — en daarna
   tóch verder spelen.
2. Spelers achteraf scènes navertellen die nooit gescript zijn ("toen stond
   hij ineens onderaan de trap" terwijl dat emergent AI-gedrag was).
3. De game 3–5 uur boeit zonder één gevecht.
4. Reviews het woord "sfeer" vaker gebruiken dan "schrok".
