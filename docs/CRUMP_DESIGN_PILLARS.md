# CRUMP — Design Pillars

*De creatieve kern van CRUMP, geformuleerd als toetssteen voor
systeemontwerp. Waar GAME_BIBLE vastlegt **wat** CRUMP is en
HORROR_GUIDELINES **hoe** het eng is, legt dit document vast **waaraan elk
toekomstig systeem zich moet verantwoorden**. Bij elk taakontwerp en elke
architectuurkeuze is de vraag niet "kan dit?" maar "welke pijler dient
dit?" — het antwoord "geen" betekent: niet bouwen (GAME_BIBLE §2).
Wijzigingen aan dit document zijn een studiobeslissing (GD).*

---

## 1. Kwetsbaarheid

De speler is een clublid met natte haren en een sporttas — geen held, en
dat mag geen mechaniek ooit repareren. Kwetsbaarheid is in CRUMP geen
gebrek aan features maar een **ontwerpbudget**: elke vaardigheid die we
toevoegen, koopt iets af van de angst.

**Wat dit eist van systemen:** vaardigheden geven nooit macht óver de
dreiging, hoogstens opties eromheen (ontwijken, lezen, kiezen). Tuning
begint aan de trage, zware, menselijke kant (walk 2,6 m/s was geen
toeval). Falen is een inschattingsfout van de speler, nooit onmacht van de
besturing — het lichaam doet precies wat je vraagt, de wéreld is het
probleem.

**Toets:** *maakt dit systeem de speler bekwamer, of de wereld
beheersbaarder?* Het eerste mag, het tweede vrijwel nooit.

## 2. Stilte als standaard

Stilte is het nulpunt waartegen alles betekenis krijgt. Dat is inmiddels
architectuur: geluid bestaat bij ons éérst als feit (`noise_made`, een
draagafstand in meters) en pas daarna als iets hoorbaars — en die twee
blijven gescheiden (kader taak 005). Elke decibel is dus een uitgave uit
een klein budget.

**Wat dit eist van systemen:** geen systeem maakt "sfeergeluid" voor de
gezelligheid; elk geluid is een gebeurtenis met een bron in de wereld en
informatie erin. De standaardtoestand van elk nieuw systeem is zwijgen —
wie iets toevoegt dat klinkt, motiveert waaróm de stilte hier gebroken
wordt. Lezen is stil. Sluipen is bijna stil. Dat verschil ís de gameplay.

**Toets:** *als dit systeem vandaag zou zwijgen, zou de speler dat merken
als gemis — of als rust?*

## 3. Gezien worden is de grootste angst

Niet sterven maar **opgemerkt worden** is de kern-dreiging. Zien en gezien
worden is één transactie: de zaklamp die zicht geeft, geeft zichtbaarheid;
de ren die afstand koopt, roept (D-019: de consequentie van rennen ís
geluid). De speler betaalt voor elke vorm van waarnemen en handelen in de
munt van opvallen.

**Wat dit eist van systemen:** elke actie krijgt een
waarneembaarheids-prijs die de speler kan leren (luidheid per gangsoort,
licht als dilemma) — en die prijs is symmetrisch en eerlijk: wat de
dreiging registreert, kon de speler weten. Nooit onzichtbare detectie,
nooit valsspelende zintuigen; CRUMP's waarneming loopt over dezelfde
feiten (de bus) als die de speler zelf kan horen.

**Toets:** *kan de speler vooraf inschatten hoe zichtbaar/hoorbaar deze
actie hem maakt — en klopt die inschatting achteraf?*

## 4. Minder is enger

Eén dreiging, een handvol items (capaciteit 6 — D-023), vier hoofdstukken,
één harde jumpscare per hoofdstuk. Schaarste is bij CRUMP geen budgetkeuze
maar het mechanisme zelf: alles wat vaak voorkomt, verliest zijn lading.
De laagste trede van de ladder die werkt, is de juiste (HORROR_GUIDELINES
§2).

**Wat dit eist van systemen:** systemen worden ontworpen op hun
*spaarzaamste* gebruik, niet op hun maximale. Geen feature "omdat het kan",
geen content-vulling, geen tweede monster, geen veertig slots. Elke
uitbreiding van een bestaand systeem moet een bestaande betekenis
verdiepen in plaats van een nieuwe toe te voegen — en alles wat we bouwen
moet ook weer weggegooid kunnen worden zonder sloopwerk (D-015: sneuvelen
na een playtest is een feature van het proces).

**Toets:** *wordt dit enger door er meer van te maken — of juist door er
minder van te maken?* Bij twijfel: minder.

## 5. De wereld is groter dan CRUMP

Het sportpark is de hoofdrolspeler; CRUMP is de vraag die erin rondwaart.
De opening zet een levend, banaal, kloppend "normaal" neer en de rest van
het spel is een gesprek met die referentie-staat — een stoel die 30 cm
verschoof, een tv die nog aanstaat. De wereld moet ook zonder de dreiging
de moeite waard zijn om in rond te lopen (fase-1-lat: alleen al bewegen
voelt goed; fase-2-lat: de ruimte is 's nachts onaangenaam *zonder dat er
iets gebeurt*).

**Wat dit eist van systemen:** de wereld draait door zonder CRUMP — dat is
letterlijk zo gebouwd (verwijder het monster-systeem en niets breekt) en
blijft zo. Systemen onthouden de staat van de wereld (GameState, straks
saves) omdat afwijking-van-bekend ons wapen is: wat de speler zag, moet er
later nog precies zo staan — of nét niet. Verhaal zit in props, papier en
plekken; nooit in systemen die uitleg afdwingen.

**Toets:** *werkt deze ruimte/dit systeem ook als CRUMP nooit langskomt —
en wordt het spel armer als we het weglaten?* (HORROR_GUIDELINES §9.5)

## 6. Gameplay boven spektakel

Angst die de speler zelf veroorzaakt ("ik rende, dus hij hoorde me") is
van hem; angst die de regie veroorzaakt is van ons — en verdampt bij de
tweede playthrough. CRUMP kiest systemen boven scripts: de beste scène uit
dit spel is er een die wij nooit geschreven hebben ("toen stond hij ineens
onderaan de trap", GAME_BIBLE §10.2).

**Wat dit eist van systemen:** gedrag boven cutscene, regels boven
momenten, emergentie boven choreografie. Scripted momenten bestaan (de
opening is er één) maar zijn de uitzondering met eigen dossier-regels;
alles daarna moet uit leesbare systemen komen die de speler kan leren
bespelen. Een systeem dat alleen werkt als de speler precies de goede kant
op kijkt, is regie in vermomming (§5b.5) — en regie slijt.

**Toets:** *kan de speler dit moment navertellen als iets dat hém
overkwam door zijn eigen keuzes — of als iets dat wij hem aandeden?*

---

## Gebruik

- **Bij elk taakontwerp** (zoals de ontwerpfase van 004): benoem expliciet
  welke pijlers het ontwerp dient en waar het schuurt.
- **Bij elke review**: de vier-vragen-rapportage toetst "waarom zo
  gebouwd" mede aan deze pijlers.
- **Bij twijfel tussen twee aanpakken**: kies de kant van kwetsbaar, stil,
  schaars en systemisch — of leg de keuze voor aan de GD.

*Dit document vervangt niets: GAME_BIBLE blijft de scheidsrechter over wat
CRUMP is, HORROR_GUIDELINES over hoe het eng is. Dit is de lens waardoor
elk systeemontwerp die twee documenten binnenkomt.*
