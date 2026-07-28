# Taak 007 — Minimale documentlezer

**Fase**: 2½ (Vertical Slice, productiefase B) · **Status**: 🟡
**gebouwd conform ontwerp v1.1 (2026-07-28, suite 230 groen) — wacht op
lokale GD-test** · **Vereist**:
003 (ReadableNote + `document_opened`) · **Maakt mogelijk**: de vijf
documenten van de Vertical Slice (tasks/008 §6)

De vondsten van de slice zijn papier: een briefje, een takenlijst, een
logboekje. Ze bestaan al als prop (taak 003) en als feit op de bus —
alleen kan niemand ze *lezen*. Deze taak bouwt het kleinste ding dat
dat oplost: een verwijderbare lees-UI die het bestaande feit toont en
netjes weer verdwijnt. Niets meer. Lezen is stil (P2), documenten mogen
onvolledig zijn en elkaar tegenspreken (P7) — de lezer zelf is dom
gereedschap en voegt geen betekenis toe.

## Doel

Een speler die een leesbaar object activeert, ziet de tekst rustig en
leesbaar in beeld; gameplay-input ligt betrouwbaar stil; Esc (of de
interactietoets) sluit en herstelt alles exact. Verwijder de reader-map
en het spel draait door alsof er nooit een lees-UI was.

## Scope

**Wel:**
- Een klein `DocumentResource`-datamodel (documentinhoud als data).
- `ReadableNote` (bestaande prop) leest zijn inhoud voortaan uit die
  resource; het bus-contract wordt eenmalig gecorrigeerd naar drie
  basistypen (id, titel, tekst — keuze A).
- Eén verwijderbare `DocumentReader`-UI-luisteraar die `document_opened`
  toont, input blokkeert en met Esc sluit.
- Dev-room-briefje omgezet naar het nieuwe datamodel; suite bijgewerkt.

**Niet (bindend, GD 2026-07-28):** geen codex; geen verzamellijst; geen
documentinventaris; geen drag-and-drop; geen save/load-werk; geen
voice-over; geen uitgebreide animaties; geen concrete briefje-types in
de reader (de reader kent alleen tekst, nooit props of soorten).

---

# Technisch ontwerp (v1.1, 2026-07-28 — correctieronde na GD-review)

*v1.1 verwerkt de GD-correctieronde: het buscontract draagt voortaan
ook de titel (drie basistypen, §1/§2 — eenmalig gecorrigeerd nu er nog
geen productieconsumer bestaat), dezelfde-E-druk-bescherming via
deferred arming (§4a), exact pauze-/muisherstel met ownershipregels
(§4b), gedefinieerde vervang-semantiek bij een tweede document-event
(§4c), datavalidatie en lange-tekstgedrag (§4d) en het aangevulde
testplan (§6). Scope en architectuur verder ongewijzigd.*

## 1. Architectuur — nieuwe en gewijzigde onderdelen

```
game/props/note_readable/document_resource.gd  ← datamodel (bij de prop:
 └─ + documents/*.tres                            de prop is eigenaar van
                                                  zijn data, reader niet)
game/props/note_readable/note_readable.gd      ← leest uit de resource
game/ui/document_reader/                       ← verwijdereenheid: de lees-UI
 └─ document_reader.tscn/gd                       (bootstrap-spawn, groep
                                                  "document_reader")
EventBus                                       ← document_opened krijgt de titel
                                                  erbij (3 basistypen, keuze A)
```

**Keuze A — het bus-contract wordt eenmalig gecorrigeerd: de titel
reist mee als derde basistype.** *(besluit GD 2026-07-28;
D-021/D-022-regime)* Definitieve signatuur:

```gdscript
## Een leesbaar document is geopend (taak 003/007). De lees-UI toont
## title en text letterlijk; lege title = geen titelregel. Het briefje
## zelf heeft GameState al bijgewerkt. Lezen is stil — dit signaal gaat
## bewust niet vergezeld van noise_made (pijler 1).
signal document_opened(document_id: StringName, title: String, text: String)
```

- `ReadableNote` leest **id, titel en tekst** uit zijn
  `DocumentResource` en zendt **uitsluitend deze drie basistypen** —
  de resource gaat nooit over de bus.
- `DocumentReader` kent geen ReadableNote-, DocumentResource- of enig
  ander concreet proptype: hij consumeert alleen het feit.
- Er komt **geen centraal documentregister of lookup** alleen om een
  titel terug te vinden — de titel reist gewoon mee in het feit.
- Dit is een wijziging van een bestaand signaal (003), maar er bestaat
  nog **geen productieconsumer**: alleen de suite-recorder luistert.
  Dáárom wordt het contract nú eenmalig gecorrigeerd, vóór het breder
  wordt gebruikt — hierna geldt het D-022-regime (wijzigen = breaking
  change met eigen D-entry). De signaturentest gaat van 2 naar 3
  argumenten; de 003-notetest wordt in dezelfde beweging bijgewerkt.

**Verworpen**: `document_opened(resource)` (klasse over de bus =
D-021-breuk); titel vóór de tekst in de payload plakken (de
v1-oplossing — verstopt structuur in een string en dwingt de UI tot
parsen); een apart titel-opzoekkanaal (register = precies het
documentensysteem dat we niet bouwen, P4).

**Keuze B — het datamodel ligt bij de prop, niet bij de reader.**
*(ARCHITECTURE §3: een scène + haar resources horen bij elkaar)* De
reader consumeert alleen het bus-feit; de prop bezit zijn data. Dus:
`document_resource.gd` + de `.tres`-bestanden leven in
`game/props/note_readable/`. Verwijder je de reader-map → prop en
resources parsen en werken (feit zonder ontvanger, D-015). Verwijder je
de prop-map (incl. datamodel) → de reader parst en wacht eeuwig op een
feit dat nooit komt — ook goed. **Verworpen**: een
`game/systems/documents/`-map (suggereert een documentensysteem dat we
per GD-besluit juist níét bouwen).

## 2. Datamodel

```gdscript
class_name DocumentResource
extends Resource
## Inhoud van één leesbaar document (taak 007). Data, geen gedrag
## (CODING_STANDARDS §5). Kort en scanbaar (LEVEL §8) — nooit leesmuren.

## Identiteit: verplicht en uniek (zelfde discipline als items/sounds;
## de suite dwingt dit af over de documents-map).
@export var id: StringName = &""

## Optionele kop boven de tekst ("TAKENLIJST WEEK 30"); leeg = geen kop.
@export var title := ""

## De volledige tekst, letterlijk getoond. Opmaak is aan de UI, nooit
## aan de data.
@export_multiline var text := ""
```

`ReadableNote` verandert minimaal: de exports `document_id` +
`document_text` worden vervangen door één `@export var document:
DocumentResource`. `interact()` wordt:
`GameState.mark_document_read(document.id)` +
`EventBus.document_opened.emit(document.id, document.title,
document.text)` — de drie waarden letterlijk uit de resource, niets
erbij verzonnen, niets samengeplakt. Guards aan de bron (§4d): geen
resource, lege `id` of lege `text` → stil geweigerd met een duidelijke
`push_warning`, geen emissie én geen GameState-mutatie (zelfde regime
als de pickup zonder item). `DocumentResource` is runtime read-only
configuratiedata (zelfde regel als ItemResource/SoundResource): niemand
muteert de velden.

**Migratie**: het dev-room-briefje wordt
`documents/briefje_dev_room.tres`; de dev_props-tabel verwijst met een
`.tres`-pad (bestaand bestaanscheck-patroon). GameState-koppeling
blijft exact zoals hij is (003): de prop registreert het lezen; de
reader raakt GameState nooit aan — er is geen werkelijke behoefte, dus
geen koppeling (eis GD).

## 3. Eventflow

```
speler → interact (003-keten, ongewijzigd)
  ReadableNote.interact()
    ├─ GameState.mark_document_read(id)             (bestaand)
    └─ EventBus.document_opened(id, titel, tekst)   (keuze A, 3 basistypen)
         └─ DocumentReader (indien aanwezig, groep-guard):
              valideert (§4d) · bewaart pauze-/muisstatus (§4b) ·
              toont paneel · wapent zich deferred (§4a) ·
              Esc/E sluit → herstelt exact (§4b)
```

- De reader is een `CanvasLayer` die éénmalig door de bootstrap wordt
  gespawnd (bestaanscheck, zelfde patroon als debug-tools maar **niet**
  debug-only — dit is gameplay-UI), als kind van de bootstrap met
  `process_mode = ALWAYS` (hij moet werken terwijl de wereld stilstaat).
- Groep `document_reader` + eerste-in-groep-guard (het
  inventory-patroon): een tweede instantie meldt zich luid en blijft
  doof. Connectie op `document_opened` in `_ready`, symmetrisch
  verbroken in `_exit_tree`.
- Een `document_opened` terwijl de reader al open staat, vervangt de
  inhoud (laatste feit wint — kan in de praktijk niet via interactie,
  want de wereld staat stil; dit is alleen robuustheid tegen handmatige
  emissies in tests).

## 4. Inputfocus en pauzesemantiek

**Keuze C — lezen pauzeert de wereld via het bestaande
pauzemechanisme.** *(KI-003-architectuur; P2)* Bij openen zet de reader
`get_tree().paused = true` en onthoudt dat híj de pauze bezit
(`_owns_pause`); bij sluiten geeft hij hem terug (`paused = false`).
Waarom dit de juiste blokkering is:

- **Betrouwbaar per constructie**: de speler leest input in
  `_physics_process` (polling) — events "handled" markeren blokkeert
  hem niet. PAUSABLE stilzetten wél, gegarandeerd en overal tegelijk
  (speler, interactor, zaklamp, props). Geen input-lock-vlag in de
  speler nodig (dat zou reader→speler-koppeling zijn).
- **De bestaande semantiek doet het werk**: muis komt vrij
  (NOTIFICATION_PAUSED in de speler, bestaand), wereld en audio staan
  stil — lezen is een rustmoment (HORROR §1: rust hoort bij de boog).
- **Eén regel extra**: lezen kan alleen starten via interactie, en de
  interactor is PAUSABLE — dus openen-tijdens-pauze kan niet, en
  dubbel-openen evenmin.

### 4a. Dezelfde-E-druk-bescherming: deferred arming

E opent (via de interactor) én mag sluiten. Hetzelfde fysieke
inputevent mag nooit beide doen. De oplossing is een expliciete
lifecycle-toestand, geen timer en geen cooldown:

- De reader opent in de toestand **OPEN_ONGEWAPEND**: het paneel is
  zichtbaar, maar sluit-input wordt nog niet geaccepteerd.
- Direct bij het openen plant hij `_arm.call_deferred()`; die zet de
  toestand op **OPEN_GEWAPEND** aan het **einde van de huidige frame-
  verwerking** — dus gegarandeerd nádat de dispatch van het openende
  E-event volledig is afgerond, en vóórdat welk volgend inputevent dan
  ook wordt bezorgd. Deterministisch (engine-volgorde, geen tijdsduur)
  en headless testbaar: input in hetzelfde frame injecteren sluit
  niet, input in het volgende frame wél.
- Alleen in OPEN_GEWAPEND accepteert `_input` de sluitacties `pause`
  (Esc) en `interact` (E). **Esc is hierdoor de facto altijd direct**:
  Esc kan nooit het openende event zijn (openen loopt uitsluitend via
  interact), dus elk Esc-event is per definitie een volgend event en
  treft een gewapende reader. Eén E-druk toont het document daarmee
  minimaal tot een volgende, afzonderlijke inputactie.
- Tweede verdedigingslinie (gratis, geen aparte logica): binnen de
  dispatch van het openende event draait `_input` van de reader
  sowieso vóór `_unhandled_input` van de interactor — op het moment
  dat het openen plaatsvindt, is het event de reader al gepasseerd.
  De arming maakt dit expliciet en testbaar in plaats van impliciet.

**Verworpen**: een tijd-/cooldownvenster (racegevoelig, ontestbaar
deterministisch); sluiten op key-release (voelt traag en wijkt af van
alle andere input in het spel).

### 4b. Pauze- en muis-ownership: exact herstellen, exact één keer

De reader bewaart **vóór** het openen drie dingen, en alleen bij een
échte opening (niet bij vervanging, §4c):

1. `_prev_paused := get_tree().paused`
2. `_prev_mouse_mode := Input.mouse_mode`
3. `_owns_pause := not _prev_paused` — alleen als de boom nog niet
   gepauzeerd was, zet de reader zelf de pauze en bezit hij die claim.

Openen: als `_owns_pause` → `paused = true`; daarna muis zichtbaar
(voor het latere scrollen/lezen). Sluiten (of `_exit_tree` terwijl
open — verwijderd worden telt als sluiten) herstelt **uitsluitend wat
de reader zelf wijzigde**, in deze vaste volgorde:

1. paneel verbergen en interne staat naar GESLOTEN;
2. `Input.mouse_mode = _prev_mouse_mode` — exact de oude modus;
3. alléén als `_owns_pause`: `paused = false`. Een boom die al
   gepauzeerd wás vóór het openen wordt dus **nooit** onbedoeld actief
   gemaakt, en het (latere) pauzemenu wordt nooit onder de reader
   vandaan getrokken.

Stap 3 ná stap 2 is bewust: het hervatten triggert de bestaande
NOTIFICATION_UNPAUSED van de speler (muis vangen) — de spelerlogica
is en blijft de eigenaar van muis-in-gameplay; het herstel van de
reader is alleen relevant wanneer er géén hervatting volgt (boom was
al gepauzeerd). Herstel gebeurt exact één keer: de sluitroutine is
idempotent (GESLOTEN → no-op).

**Eén Esc = één gevolg**: de reader vangt zijn sluit-input in
`_input` (eerder in de pijplijn dan `_unhandled_input` van de
bootstrap) en markeert het event met `set_input_as_handled` — één druk
op Esc sluit alléén het document en bereikt de pauze-toggle van de
bootstrap nooit; de éérstvolgende Esc werkt weer gewoon als pauze. De
reader raakt de bootstrap zelf nooit aan.

### 4c. Tweede document_opened terwijl de reader open staat

Kan in normale gameplay niet voorkomen (de wereld staat stil), maar
het gedrag is gedefinieerd en getest voor robuustheid:

- een tweede **geldig** feit vervangt id, titel en tekst **atomair**
  (één toewijzing van alle drie, scrollpositie terug naar boven);
- er ontstaat géén tweede overlay en géén extra pauzeclaim — de
  open-routine slaat bij een al-open reader de statusopname van §4b
  volledig over;
- de oorspronkelijk bewaarde `_prev_paused`/`_prev_mouse_mode`/
  `_owns_pause` blijven onaangetast;
- sluiten herstelt die oorspronkelijke toestand exact één keer;
- een **ongeldig** tweede feit (§4d) wordt geweigerd en laat de
  getoonde inhoud ongemoeid.

### 4d. Datavalidatie en lange tekst

Validatie gebeurt primair aan de bron (de prop, §2); de reader
herhaalt de guard zodat ook handmatige emissies (tests, toekomstige
zenders) veilig falen:

- **lege `document_id`**: veilig weigeren + duidelijke `push_warning`
  ("DocumentReader: feit met lege id genegeerd") — reader opent niet
  resp. prop zendt niet;
- **lege `text`**: idem — een leeg document bestaat niet;
- **lege `title`**: toegestaan; de titelregel (aparte Label) wordt
  verborgen, de tekst schuift op — geen lege kopruimte;
- het tekstgebied is een **ScrollContainer**: lange documenten
  scrollen en breken de layout nooit (paneel heeft vaste maximale
  maat, tekst wrapt);
- **geen hardgecodeerde maximale tekstlengte** in runtimecode — "kort
  en scanbaar" (LEVEL §8) is en blijft een redactionele regel voor de
  ontwerpers, geen code-limiet;
- `DocumentResource` blijft runtime **read-only**; reader noch prop
  muteert ooit een veld.

## 5. Debugbaarheid

- `Log.info` bij openen ("DocumentReader: '<id>' geopend") en sluiten —
  de vaste logdiscipline; geen F3-regel (er valt niets doorlopends te
  tonen; P4, geen gratis zekerheid over wat gelezen is — P7).
- De bestaande F3-regels blijven bruikbaar tijdens het lezen (overlay
  is ALWAYS).

## 6. Teststrategie

1. **Contract**: `document_opened` met **3 argumenten** in de
   signaturentest (de 003-notetest gaat in dezelfde beweging mee);
   documents-map-scan: elke `.tres` laadt met geldige, unieke `id` en
   niet-lege `text` (zelfde discipline als items/sounds).
2. **Prop**: ReadableNote instantieert los; met resource → interact
   zendt exact één feit waarin **id, titel én tekst letterlijk** uit de
   resource komen, en registreert in GameState; zonder resource, met
   lege `id` of met lege `text` → veilig geweigerd (warning is het
   bewijs), geen feit, geen GameState-mutatie, geen crash; lezen blijft
   stil (geen `noise_made`).
3. **Titel end-to-end**: de titel uit de resource verschijnt letterlijk
   via de bus in de titel-Label van de reader; een **lege titel**
   verbergt uitsluitend de titelregel — de tekst blijft normaal
   leesbaar.
4. **Dezelfde-E-druk (arming, §4a)**: één E-druk opent het paneel en
   sluit het aantoonbaar níét in datzelfde frame (paneel is ná de
   dispatch nog zichtbaar); een volgende, afzonderlijke E-druk sluit
   wél. Idem: een handmatig geïnjecteerd sluit-event binnen het
   openingsframe wordt genegeerd (OPEN_ONGEWAPEND), hetzelfde event
   één frame later niet.
5. **Reader-keten (e2e)**: briefje aankijken + interact → paneel
   zichtbaar, boom gepauzeerd; bewegingsinput verplaatst de speler
   aantoonbaar niet; Esc → paneel dicht, boom hervat, speler beweegt
   weer; **en Esc opende niet in hetzelfde event het pauzemenu** — de
   éérstvolgende Esc pauzeert het spel gewoon (het opgegeten event
   lekt niet).
6. **Exact herstel (§4b)**: de `Input.mouse_mode` van vóór het openen
   wordt exact hersteld (headless beperkt meetbaar — VISIBLE blijft
   VISIBLE; de capture-kant is GD-hardware-punt, zelfde voorbehoud als
   de pauzetests van 002); een **vooraf gepauzeerde boom** (feit
   handmatig gezonden terwijl `paused == true`) blijft ná het sluiten
   gepauzeerd — de reader claimde niets en geeft dus niets vrij.
7. **Vervang-semantiek (§4c)**: tweede geldig feit terwijl open →
   getoonde id/titel/tekst atomair vervangen, geen tweede overlay,
   geen extra pauzeclaim (bewaarde status ongewijzigd); sluiten
   herstelt de oorspronkelijke toestand exact één keer. Ongeldig
   tweede feit → inhoud ongemoeid.
8. **Lange tekst**: een gegenereerd lang testdocument blijft via de
   ScrollContainer bruikbaar (scrollbereik > 0, paneel binnen zijn
   maximale maat) — geen layoutbreuk, geen afkapping in code.
9. **Guard**: tweede reader-instantie blijft doof (één feit → één
   paneel).
10. **D-015 beide richtingen**: zonder `game/ui/document_reader/`
    blijft alles parsebaar en stabiel — interactie werkt, GameState
    registreert, er verschijnt alleen geen paneel (het 003-gedrag van
    vandaag); zonder `game/props/note_readable/` (prop + documenten)
    draait de rest incl. reader-spawn gewoon door — de reader wacht op
    een feit dat nooit komt. Testcode noemt geen klassen (D-021,
    duck-typed).
11. **Reader verwijderd terwijl open** (unit): `_exit_tree` herstelt de
    eigen wijzigingen (§4b) — pauzeclaim vrijgegeven, muismodus terug,
    geen bevroren spel.

## 7. Risico's

| Risico | Zwaarte | Mitigatie |
|---|---|---|
| Esc-botsing reader ↔ bootstrap-pauze geeft dubbelgedrag | middel | `_input` + `set_input_as_handled` vóór de bootstrap; expliciete suite-test (3) op "Esc sluit alleen het document" |
| Pauze-eigenaarschap botst met een toekomstig menu/HUD | laag | `_owns_pause`-vlag + vastgelegde semantiek (§4); het latere menu erft dit patroon |
| Tekstweergave (font/grootte) is op de VPS niet te beoordelen | laag | leesbaarheid is een GD-hardware-punt; opmaak minimaal houden (P4), tuning is data |
| Migratie breekt de 003-tests (document_id/document_text weg; signatuur naar 3 argumenten) | laag | suite en signaturentest in dezelfde fase mee; het contract wordt eenmalig gecorrigeerd vóór er een productieconsumer bestaat (keuze A) en valt daarna onder het D-022-regime |
| Zelfde-E-druk sluit het net geopende paneel | middel | deferred arming (§4a): sluit-input pas geaccepteerd ná de dispatch van het openende event; expliciete suite-test (§6.4) |

## 8. Lokale GD-acceptatie

1. Loop naar het dev-room-briefje → "Lees briefje" → tekst rustig
   leesbaar in beeld; wereld en audio staan stil; muis zichtbaar.
2. Probeer te lopen: niets beweegt. Esc: paneel weg, spel loopt, muis
   gevangen; nogmaals Esc: gewone pauze.
3. Leesbaarheid op jouw scherm (font, grootte, contrast op de
   nachtstaat) — het enige echte hardware-oordeel van deze taak.

## 9. Exit-criteria

1. Ontwerp door de GD gereviewd en akkoord; bouw in twee kleine blokken
   (datamodel + prop-migratie → reader-UI + tests), commit per blok.
2. Suite volledig groen incl. de nieuwe tests (§6); import schoon;
   D-015 beide richtingen aantoonbaar; normale F5-run warning-vrij.
3. Registers bijgewerkt (CHANGELOG, DECISIONS: bus-contract-besluit +
   pauzesemantiek, SESSION_STATE, README, dit dossier).
4. GD-acceptatie op hardware (§8) → daarmee is productiefase B van de
   Vertical Slice (tasks/008 §15) afgerond.

---

# Uitvoeringsverslag (2026-07-28, gebouwd conform ontwerp v1.1)

Gebouwd in twee blokken, commit per blok: datamodel + prop-migratie +
contractcorrectie → reader-UI + tests. Suite **208 → 230**, alles
groen; import exit 0; normale F5-run warning-vrij. Registers: D-029
(contract + arming/ownership-patroon), CHANGELOG v0.0.18.

**Verduidelijkingen t.o.v. het ontwerp** (geen gedragsafwijkingen):

1. **D-015-richting "zonder documentprops"** is aangetoond via de
   003-verwijdereenheid (interactor + álle props samen, incl.
   note_readable + documents): suite 172/172 groen met een gespawnde,
   stabiele, doelloze reader. De prop alléén verwijderen is per D-021
   een halve verwijdering die de suite bewust luid laat falen — dat is
   bestaand 003-beleid, geen 007-keuze.
2. De 003-notetest sluit de reader voortaan via de echte sluitroute
   (E, ná arming) zodat de vervolgtests een draaiende wereld aantreffen
   — en test daarmee gratis de volledige open/dicht-cyclus in de keten.
3. Meegenomen (toegezegd in SESSION_STATE): verouderde taaknummers in
   codecommentaar zijn bijgewerkt naar de D-028-nummering (007→009
   waar monster-AI werd bedoeld).

## Lokale GD-acceptatie — uit te voeren stappen

1. F5 → loop naar het briefje op de noordwand ("Lees briefje", E):
   paneel gecentreerd, titel "Testbriefje", tekst eronder, sluithint
   onderin; wereld en audio staan stil; muis zichtbaar; F3 blijft
   werken.
2. Houd E niet vast maar druk één keer: het paneel moet blíjven staan
   (niet flitsen). Druk daarna nog eens E → dicht, spel loopt, muis
   gevangen. Herhaal met Esc als sluittoets; controleer dat die Esc
   níét tegelijk pauzeert en dat een volgende Esc dat wél doet.
3. Leesbaarheid op jouw scherm: fontgrootte/contrast van het paneel op
   de nachtstaat (het paneel heeft een eigen donkere backdrop en hoort
   identiek leesbaar te zijn met en zonder zaklamp/brightness 0.8–1.2).
4. Lange tekst: zet tijdelijk in
   `game/props/note_readable/documents/briefje_dev_room.tres` een lap
   tekst van tientallen regels → het paneel blijft even groot en de
   tekst scrolt (muiswiel). Daarna terugdraaien (niet committen).
5. Herhaald feit (optioneel, editor): tweemaal snel achter elkaar
   interacten kan niet (wereld staat stil) — het vervanggedrag is
   headless getest; visueel niets te doen.
