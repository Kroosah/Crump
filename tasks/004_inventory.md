# Taak 004 — Inventory

**Fase**: 2 (Het gereedschap) · **Status**: ✅ gebouwd conform ontwerp v2 (v0.0.15), wacht op lokale GD-test · **Vereist**: 003

> **Gebouwd 2026-07-28** in de vier geplande blokken (commits `aae500c`,
> `6e54605`, `44e50f7` + registerblok). Suite 145/145; D-015 in drie
> richtingen (zonder inventory 119, zonder interactiesysteem 95, alles
> 145). Exit-criteria §9.2 t/m §9.6 gehaald; §9.7 (lokale GD-test) open.
>
> **Lokale acceptatietest** (F5, verse pull):
> 1. **Accepted**: loop naar de rode kist rechtsachter → "[E] Pak sleutel
>    op" → E → sleutel verdwijnt, F3 toont
>    `inventory: 1/6 · sleutel_kleedkamer`.
> 2. **Rejected/vol**: zet vóór het spelen op de Inventory-node (of via
>    de Remote-tab) `capacity` op `0` → E op de sleutel → hij blijft
>    liggen, geen geluid, prompt blijft staan; zet capacity terug op 6 →
>    dezelfde sleutel is direct opnieuw oppakbaar.
> 3. **Zonder inventory** (optioneel): map `game/systems/inventory/`
>    tijdelijk weg → sleutel blijft liggen, spel draait gewoon.

Een kleine, diegetische inventory (GAME_BIBLE §8: geen 40-slots-grid).
De speler draagt een handvol betekenisvolle spullen — de kleedkamersleutel
van de barman, een zaklamp, een gevonden telefoon, een enkel verhaalobject.

> **Ontwerpfase (2026-07-28, opdracht GD)**: dit dossier bevat eerst het
> volledige technische ontwerp ter review. Implementatie start pas na
> akkoord. De oorspronkelijke, bredere taakomschrijving (UI, sleutel-deur,
> save-integratie) is bewust herscopet — zie §1.

---

## 1. Scope

**Binnen taak 004:**
- `ItemResource` — het datamodel voor items (§3).
- Het inventory-systeem — opslag, capaciteit, toevoegen/verwijderen,
  signalen (§4).
- De wereldflow: pickup → EventBus → inventory → accept/reject →
  verdwijnen of blijven liggen (§5). Alleen voor het bestaande
  oppakbare object uit taak 003.
- Enkele voorbeeld-items als `.tres` (sleutel, telefoon, zaklamp) om het
  systeem te bewijzen — geen echte spelinhoud.
- Eén regel **debug-zichtbaarheid** in de bestaande F3-overlay
  ("inventory: 2/6 · sleutel_kleedkamer, …") — zelfde les als de
  debug-prompt bij 003: zonder zichtbaarheid valt er niets te beoordelen.
  Dit is debug-gereedschap, geen HUD.

**Expliciet buiten scope** (architectuurregels GD, 2026-07-28):
- ❌ UI (de diegetische inventory-weergave verhuist naar een eigen taak).
- ❌ Drag & drop, crafting, equipment, gewicht, item-combinatie.
- ❌ Save/load — de savegame-impact wordt hier alleen *beschreven* (§6).
- ❌ Sleutel-opent-deur en andere item-gebruikseffecten
  (`EventBus.item_used` blijft slapend tot een latere taak).
- ❌ De ladekast-koppeling: `item_found` van de la blijft een slapende
  haak; alleen het vrijstaande oppakbare object wordt aangesloten.
- ❌ Iconen-art (het `icon`-veld bestaat, mag leeg zijn).

## 2. Architectuur

**Nieuwe onderdelen** (samen één verwijdereenheid, D-015/D-021):

```
game/systems/inventory/
├── item_resource.gd     # class_name ItemResource (datamodel, §3)
├── inventory.gd/.tscn   # het inventory-systeem (Node, §4)
└── items/               # voorbeeld-.tres-items (sleutel, telefoon, zaklamp)
```

**Verantwoordelijkheden:**

| Onderdeel | Doet | Doet bewust NIET |
|---|---|---|
| `ItemResource` | data dragen (id, naam, …) | gedrag; effecten leven bij ontvangers |
| `Inventory` | bewaren, capaciteit bewaken, accept/reject beslissen, feiten melden | wereldobjecten kennen, UI tekenen, effecten uitvoeren, saven |
| `PickupItem` (bestaand, 003) | verzoek indienen, op eigen resolutie reageren | de inventory kennen, zelf beslissen of opname lukt |
| Bootstrap | inventory spawnen met bestaanscheck (patroon D-018) | — |

**Plaats in de boom**: de bootstrap spawnt de inventory éénmalig als kind
van de `SceneHost` (niet van het level): hij pauzeert mee (KI-003) en
overleeft een levelwissel — je spullen verdwijnen niet omdat een deur naar
een andere scène leidt. De node meldt zich in groep `inventory`; latere
afnemers (UI, sloten) vinden hem via `get_first_node_in_group()` +
null-check (ARCHITECTURE §4a.4) — nooit via een hard pad.

**Datastromen / events.** Nieuw op de EventBus, uitsluitend met
**basistypen** (Node, Resource, bool) — nooit gameplay-klassen, want de bus
is infrastructuur en moet elke feature-verwijdering overleven (les D-021):

| Signaal | Zender | Betekenis (feit, geen commando) |
|---|---|---|
| `item_pickup_requested(source: Node, item: Resource)` | pickup | "dit object wil opgenomen worden" |
| `item_pickup_resolved(source: Node, accepted: bool)` | inventory | "het verzoek van `source` is beoordeeld" |
| `item_added(item: Resource)` | inventory | "dit item zit nu in de inventory" |
| `item_removed(item: Resource)` | inventory | "dit item is eruit" |

`source` is een **opaak token**: de inventory echoot de referentie alleen
terug zodat de juiste pickup zijn eigen antwoord herkent (`source == self`)
— hij roept er nooit iets op aan en kent het type niet. Zo blijft gelden:
inventory kent geen wereldobjecten, wereldobjecten kennen de inventory niet.

**Eén autoritatieve inventory** (correctieronde GD, 2026-07-28). Tijdens
normale gameplay is er maximaal één actieve inventory. Geborgd op drie
lagen, zonder service locator of nieuw framework:

1. **Bootstrap spawnt éénmalig**: de spawn gebeurt in `_ready()` (niet in
   `_load_level()`, dus geen her-spawn per levelwissel), en alleen als
   groep `inventory` op dat moment leeg is — anders `push_warning` en
   overslaan.
2. **De inventory bewaakt zichzelf**: in zijn eigen `_ready()` checkt hij
   of hij de éérste in de groep is. Is er al een ander → `push_warning`
   ("tweede inventory genegeerd") en hij verbindt zich **niet** met de bus.
   Zo kan zelfs een per ongeluk in een scène gesleepte tweede instantie
   nooit meebeslissen. Bus-connecties worden in `_ready()` gelegd en in
   `_exit_tree()` verbroken — één node, één abonnement; dubbel verbinden
   van dezelfde Callable weigert Godot bovendien zelf met een fout.
3. **De suite bewaakt het** (§7.9): precies één node in groep `inventory`,
   en een bewust toegevoegde tweede instantie abonneert zich niet — één
   verzoek levert exact één `item_pickup_resolved` op.

**Typediscipline op de grens**: het `item`-veld van de pickup wordt
`@export var item: Resource` (basistype!). De ontwerper sleept er een
`ItemResource`-.tres in, maar het prop-script noemt die klasse nooit —
anders parst het interactiesysteem niet meer zodra de inventory-map weg is.
Alleen *binnen* de inventory-feature wordt streng getypt: de inventory
valideert `item is ItemResource` en wijst al het andere af.

## 3. Itemmodel

`ItemResource` (`class_name`, extends `Resource`), getypte velden — geen
dicts-als-schema (CODING_STANDARDS §5):

| Veld | Type | Verplicht | Betekenis |
|---|---|---|---|
| `id` | `StringName` | ja, **uniek en stabiel** | identiteit; straks de save-sleutel (§6) |
| `display_name` | `String` | ja | naam voor speler-teksten (NL) |
| `description` | `String` | nee | één à twee zinnen, voor de latere UI |
| `icon` | `Texture2D` | nee | placeholder mag leeg tot de UI-taak |

**Bewust niet nu** (uitbreidbaar zonder breuk, dus pas toevoegen bij de
taak die het nodig heeft): `usable`, `key_id` (item-gebruik/sloten),
`max_stack` (§4), gewicht. Elk veld dat er nu al zou staan zonder afnemer
is dood schema — het model groeit per bewezen behoefte, met default-waarden
zodat bestaande `.tres`-bestanden geldig blijven.

## 4. Inventory-model

- **Interne opbouw**: één `Array` van `ItemResource`-referenties, volgorde =
  opnamevolgorde. Geen slots-grid, geen dictionary — de latere UI toont
  gewoon een lijstje.
- **Capaciteit voor taak 004: 6** (`@export var capacity := 6` — tuning,
  geen magic number; 6 = "een handvol", GAME_BIBLE §8). Vol = verzoek
  afwijzen; dát is de reject-tak van §5.
- **API** (voor toekomstige afnemers via de groep, allemaal null-veilig te
  benaderen): `add_item(item) -> bool`, `remove_item(id) -> Resource`,
  `has_item(id) -> bool`, `get_items() -> Array`, `is_full() -> bool`.

**Exacte semantiek van `add_item(item)`** (correctieronde GD, 2026-07-28):

| Situatie | Returnwaarde | Effect |
|---|---|---|
| geldig item, plek vrij | `true` | item achteraan toegevoegd; `item_added` op de bus |
| inventory vol (`size >= capacity`) | `false` | **geen enkele mutatie**, geen signaal |
| `item == null` | `false` | geen mutatie; `push_warning` (contractfout van de aanroeper) |
| geen `ItemResource` (ander Resource-type) | `false` | geen mutatie; `push_warning` |
| lege `id` (`&""`) | `false` | geen mutatie; `push_warning` (item is onvindbaar voor saves — configuratiefout) |

De returnwaarde is het enige besliskanaal: `true` = opgenomen, `false` =
geweigerd; de bus-signalen zijn feiten achteraf, geen tweede waarheid.

**Duplicaat-semantiek**: dezelfde item-**id** mag meermaals in de inventory
voorkomen (twee batterijen = twee vermeldingen, elk hun eigen slot — er is
immers geen stacking). Maar **twee verschillende `ItemResource`-definities
(.tres-bestanden) met dezelfde `id` zijn een configuratiefout**: de id is
de identiteit richting saves en latere sloten, en twee definities die
erover twisten maken die betekenisloos. **Afdwinging**: (a) de smoke-suite
scant `items/` en faalt op dubbele id's en lege id's/namen (§7.8);
(b) conventie: álle ItemResources leven in die ene map, zodat de scan
dekkend is; (c) `add_item` weigert lege id's runtime. Runtime kan een
duplicaat-definitie niet zelf detecteren (hij weet niet welke canoniek is)
— dit is bewust een test-/dataprobleem, geen runtime-logica.
- **Stacken: nee.** Onderbouwing: elk item in CRUMP is een betekenisvol,
  individueel object (sleutel, telefoon, zaklamp) — er is geen
  consumable-economie waar aantallen toe doen, en GAME_BIBLE §8 verbiedt
  verzamelen-om-het-verzamelen. Stacking zou nu alleen save-, UI- en
  testcomplexiteit toevoegen zonder één afnemer. **Terugweg als het ooit
  nodig is** (batterijen?): een `max_stack`-veld op `ItemResource`
  (default 1) + telling in de inventory — additief, geen breuk in model of
  bus-signaturen. Vastleggen als D-entry bij implementatie.

## 5. Wereldinteractie — de exacte flow

```
speler kijkt → prompt "Pak sleutel op"        (bestaand, taak 003)
speler drukt E → interactor → pickup.interact()   (bestaand contract)
    ↓
pickup: EventBus.item_pickup_requested(self, item)
    │   (nog géén geluid, nog niet verdwijnen — er is nog niets gelukt)
    ↓
inventory (luistert op de bus):
    item geldig én niet vol  → bewaren
                               → EventBus.item_added(item)
                               → EventBus.item_pickup_resolved(source, true)
    anders                   → EventBus.item_pickup_resolved(source, false)
    ↓
pickup (luistert op item_pickup_resolved, alleen als source == self):
    accepted → nú pas: noise_made (oppak-geluid) + picked_up + queue_free
    rejected → blijft gewoon in de wereld liggen; prompt blijft werken
```

**De harde eis is geborgd**: de pickup verdwijnt uitsluitend nadat de
inventory de opname bevestigd heeft. Dit verandert het bestaande
`pickup_item.gd`-gedrag (dat nu direct verdwijnt) — dat is de enige
aanpassing aan taak-003-code, binnen het eigen script van de prop.

### 5a. Synchrone flow — exact gedrag per situatie (correctieronde GD)

Godot-signalen zijn **synchrone functie-aanroepen**: wanneer
`item_pickup_requested.emit(...)` terugkeert, zijn álle listeners al
geweest — inclusief een eventuele `item_pickup_resolved`-echo. Het
"verzoekvenster" bestaat dus alleen bínnen die ene emit-regel. De pickup
heeft twee lokale vlaggen en geen enkele timer of asynchrone state:
`_awaiting` (alleen waar tijdens het emit-venster) en `_picked`
(permanent waar na acceptatie).

```
interact():
    if _picked: return              # al opgenomen; nooit dubbel verwerken
    _awaiting = true
    EventBus.item_pickup_requested.emit(self, item)
    _awaiting = false               # emit is terug → venster dicht, hoe dan ook
```

| Situatie | Wat er gebeurt | Toestand ná de interactie |
|---|---|---|
| inventory aanwezig, **accepted** | resolved-handler draait bínnen de emit: `_picked = true`, eigen geluid, `picked_up`, `queue_free` | object verdwijnt (einde frame); `can_interact()` is al `false` |
| inventory aanwezig, **rejected** | resolved-handler markeert het verzoek afgehandeld; verder niets | object ligt er, **direct weer normaal interacteerbaar** — volgende E is een vers verzoek |
| **geen inventory/listener** | niemand reageert; de emit keert leeg terug en `_awaiting` gaat op `false` | object ligt er, direct weer normaal interacteerbaar; geen enkele blijvende wachtstatus |
| **ongeldige/niet-passende response** (zie 5b) | handler negeert hem volledig | ongewijzigd |

### 5b. Response-validatie aan de pickupzijde — invarianten

De resolved-handler van een pickup doet alleen iets als **alle drie**
tegelijk gelden:

1. `source == self` — het antwoord gaat exact over déze pickup;
2. `_awaiting == true` — de pickup verwerkt op dít moment zelf een verzoek
   (buiten het emit-venster bestaat er per definitie geen open verzoek);
3. het verzoek is nog niet afgehandeld — de handler zet bij de éérste
   passende response `_awaiting` meteen op `false` (en bij accepted ook
   `_picked = true`), waarna elke volgende response afketst op regel 2.

Daarmee zijn verdwaalde, dubbele en vervalste `resolved`-signalen per
constructie effectloos: buiten het synchrone emit-venster is `_awaiting`
altijd `false`, en bínnen het venster verwerkt de handler er hoogstens één.

**Re-entrancy en dubbel indrukken, zonder timers**: één E-druk = één
`interact()`-aanroep waarin het hele verzoek-antwoord synchroon afloopt —
er bestaat geen tussenmoment waarop een tweede druk kan interleaven. Een
tweede E-event (zelfde frame of later) start hooguit een nieuw, compleet
verzoek; ná acceptatie blokkeren `_picked` (in `interact()` én
`can_interact()`) en de `queue_free` elke verdere verwerking.

### 5c. Eigenaarschap van feedback (correctieronde GD)

Ná *accepted* handelt de **pickup zijn eigen wereldfeedback** af: zijn
eigen oppak-geluid (`noise_made` met zijn eigen export-luidheid), zijn
eigen `picked_up`-signaal en zijn eigen verwijdering. De inventory beslist
uitsluitend accept/reject en bestuurt **nooit** prop-specifiek geluid,
zichtbaarheid of ander gedrag — hij weet niet eens dát het een prop is.
Elke toekomstige "opgenomen"-feedback in de UI hangt aan `item_added`,
niet aan de prop.

**Afwijzing zichtbaar maken** ("zakken vol"): bewust niet in 004 — dat is
UI/feedback-werk. De F3-regel toont wel de bezetting.

## 6. Savegame-impact (alleen beschrijving — niets bouwen)

- **Wat opgeslagen moet worden**: uitsluitend de **item-id's**, in volgorde
  (`Array[StringName]`) — conform ARCHITECTUUR §6 serialiseren we staat,
  nooit resources of nodes.
- **Waar**: `GameState` krijgt in de save-taak een `items`-veld +
  `to_dict()/from_dict()`-uitbreiding; de inventory-node spiegelt zijn
  lijst daarheen (of leeft er direct op — dat besluit valt in de save-taak).
- **Versionering**: `save_version` gaat omhoog met een migratiefunctie;
  oude saves laden met een lege inventory (er bestond toen niets om te
  dragen — verliesvrij).
- **Consequentie die nú al geldt**: bij het laden moet een id weer een
  `ItemResource` worden. Dat vergt t.z.t. een vaste vindplaats
  (padconventie `…/items/<id>.tres` of een klein register). Daarom is
  **`id` vanaf dag één verplicht, uniek en stabiel** — de smoke-suite gaat
  dat afdwingen (§7), zodat de save-taak nooit op id-botsingen stuit.

**`GameState.reset()` — gecontroleerd, niet automatisch doorgeschoven**
(correctieronde GD). Feitelijke stand: `reset()` wordt vandaag op **exact
vier plekken** aangeroepen, allemaal in `tests/smoke_test.gd` als
opruimgereedschap tussen tests; er bestaat geen menu, geen
"nieuw spel"-knop en geen enkele gameplay-flow die het aanroept. Het is
dus nog geen actief nieuw-spel-moment maar een contract-in-wording.
**Besluit: inventory-legen hoort niet bij taak 004**, om twee inhoudelijke
redenen (niet alleen "save is buiten scope"):
1. Zonder echte nieuw-spel-flow zou de koppeling alléén de smoke-suite
   raken — en die gebruikt `reset()` juist als neutraal opruimmiddel.
   Tests die niets met de inventory doen (de briefje-test bijvoorbeeld)
   zouden ineens stilletjes de inventory wissen: verrassende
   volgorde-koppeling in testcode, precies wat we net (D-021) hebben
   afgeleerd.
2. De juiste vorm van de koppeling hangt af van een besluit dat pas in de
   save-taak valt (§ hierboven): leeft de inventory-lijst *in* GameState
   of spiegelt hij ernaartoe. Nu koppelen = nu dat besluit impliciet nemen.

**Concreet toekomstig aansluitpunt**: in de save-taak krijgt `GameState`
het `items`-veld; `reset()` leegt dat veld dan vanzelf mee (het is gewoon
GameState-data), en de inventory-node herlaadt zijn lijst uit GameState —
één bron van waarheid, geen apart leeg-mechanisme. Tot die tijd is de
inventory runtime-only en is "legen" = de sessie herstarten.

## 7. Tests (uitbreiding smoke-suite, zelfde D-015-conventies)

1. **Itemmodel**: elke `.tres` in `items/` laadt, voldoet duck-typed aan
   het model, heeft een niet-lege `id` en `display_name`.
2. **Id-discipline**: alle id's in `items/` zijn **uniek** — twee
   definities met dezelfde id = suite rood (QA §2,
   resource-integriteit; §4 duplicaat-semantiek).
3. **Inventory-unit** (losse instantie): toevoegen → `true` + `item_added`
   + telt; `has_item`/`get_items`/`remove_item` (+ `item_removed`);
   **volle inventory weigert zonder enige mutatie** (return `false`, geen
   signaal, lijst byte-gelijk); `null`, niet-ItemResource en lege id →
   veilig geweigerd (`false`, geen mutatie).
4. **End-to-end accept**: speler kijkt naar de sleutel → E →
   `item_pickup_resolved(…, true)`, item zit in de inventory, het geluid
   klonk **ná** de bevestiging, en de prop verdwijnt **exact één keer**
   (geen dubbele `picked_up`/`noise_made`, node daarna weg).
5. **End-to-end reject**: capaciteit tijdelijk vol → E →
   `resolved(false)`, prop bestaat nog en is **direct opnieuw
   interacteerbaar** (tweede E na capaciteitsherstel slaagt), geen geluid,
   inventory ongewijzigd.
6. **Geen inventory** (D-015): map weg → E laat de prop liggen, geen
   crash, prop blijft opnieuw interacteerbaar, suite groen (test-INFO).
7. **Response-invarianten** (§5b), via handmatig geïnjecteerde
   `item_pickup_resolved`-emissies op de bus:
   - response met een **andere source** → genegeerd (prop ongewijzigd);
   - response **zonder actief verzoek** (buiten het emit-venster) →
     genegeerd;
   - **dubbele response** binnen één verzoek → precies één afhandeling,
     geen dubbele verwijdering of dubbel geluid.
8. **Ongeldige itemdata end-to-end**: pickup met `null`/lege-id-item → E →
   afgewezen, prop blijft, geen crash.
9. **Eén autoritatieve inventory**: exact één node in groep `inventory`;
   een bewust toegevoegde tweede instantie abonneert zich niet — één
   verzoek levert exact één response op (geen dubbele bus-connecties).
10. **D-015 parseerbaarheid**: zonder `game/systems/inventory/` blijven
    interactiesysteem én pickups parsen en draaien (testcode noemt
    `ItemResource` nooit bij naam — duck-typing, les D-021); zonder
    interactiesysteem is de inventory idle en groen; alles aanwezig →
    alles groen.
11. **Debug-regel**: F3-overlay toont bezetting na een geslaagde opname.

## 8. Risico's — wat is later moeilijk te wijzigen?

| Keuze | Risico | Mitigatie |
|---|---|---|
| **Bus-signaturen** (§2) | de bus is een contract: zodra meerdere systemen consumeren is wijzigen een breaking change | signaturen nu minimaal en met basistypen; review vóór implementatie (deze fase) |
| **Item-als-payload** (Resource mee in het verzoek) i.p.v. id+register | de save-taak heeft tóch een id→resource-vindplaats nodig; wisselen naar register raakt alle props | id's nu al verplicht/uniek/stabiel (suite dwingt af); het register kan er later náást komen zonder de flow te wijzigen |
| **Niet stacken** | consumables zouden model + UI raken | additieve terugweg via `max_stack` (default 1), geen breuk — laagste risico van het stel |
| **`source` als Node-referentie** | werkt alleen binnen één draaiende sessie (prima voor CRUMP; geen save/netwerk-doorgang) | geaccepteerd; gedocumenteerd |
| **Inventory overleeft levelwissel** (SceneHost-kind) | "nieuw spel"-moment moet de inventory expliciet legen | reset koppelen aan het bestaande `GameState.reset()`-moment in de save-taak |
| **Capaciteit als enkel getal** | gewicht/grid zou een herontwerp zijn | bewust: past bij de visie; een getal wijzigen is een export |

## 9. Exit-criteria taak 004

1. Ontwerp (dit dossier) **door de GD gereviewd en akkoord** — daarna pas
   implementatie, in blokken met commit per blok.
2. Alle tests uit §7 groen; volledige suite groen; import schoon.
3. D-015 aantoonbaar in drie richtingen (§7.5).
4. De harde flow-eis aantoonbaar: prop verdwijnt pas ná bevestiging
   (accept-test) en blijft liggen zonder bevestiging (reject- en
   D-015-test).
5. Geen UI, geen save/load, geen gebruik-effecten, geen la-koppeling —
   scope §1 gerespecteerd.
6. Registers bijgewerkt (CHANGELOG, DECISIONS: stack-besluit +
   bus-signaturen, TECH_DEBT indien van toepassing, SESSION_STATE, README)
   en gepusht.
7. Lokale GD-test: sleutel oppakken → verdwijnt + F3 toont hem; volle
   inventory → sleutel blijft liggen.

## Ontwerpnotitie (ongewijzigd van kracht)

Klein houden is een ontwerpkeuze, geen beperking. Elk item dat we toevoegen
moet een reden hebben in STORY.md. De inventory is er voor betekenis en
voortgang, niet voor resource-management.
