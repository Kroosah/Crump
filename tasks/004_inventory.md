# Taak 004 — Inventory

**Fase**: 2 (Het gereedschap) · **Status**: 🔵 ontwerp ter review (GD), geen implementatie · **Vereist**: 003

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
  gewoon een lijstje. Duplicaat-id's zijn toegestaan (twee batterijen =
  twee vermeldingen).
- **Capaciteit**: `@export var capacity := 6` (tuning, geen magic number).
  Vol = verzoek afwijzen; dát is de reject-tak van §5. Klein houden is de
  ontwerpkeuze (GAME_BIBLE §8) — de lat voor "waarom zou dit item bestaan"
  ligt bij STORY.md, niet bij de capaciteit.
- **API** (voor toekomstige afnemers via de groep, allemaal null-veilig te
  benaderen): `add_item(item) -> bool`, `remove_item(id) -> Resource`,
  `has_item(id) -> bool`, `get_items() -> Array`, `is_full() -> bool`.
  `add_item` weigert: vol, `null`, of geen `ItemResource`.
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

**Randgevallen:**
- **Geen inventory aanwezig** (D-015): niemand beantwoordt het verzoek →
  de pickup blijft liggen. Verwijderbaarheid gratis: de wereld degradeert
  netjes in plaats van te crashen.
- **Dubbel indrukken**: Godot-signalen zijn synchroon — het hele
  verzoek-antwoord loopt binnen één `interact()`-aanroep af, en na
  acceptatie is het object weg (`queue_free`). Er is geen wachttoestand
  waarin een tweede verzoek kan glippen.
- **Afwijzing zichtbaar maken** ("zakken vol"): bewust niet in 004 — dat is
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

## 7. Tests (uitbreiding smoke-suite, zelfde D-015-conventies)

1. **Itemmodel**: elke `.tres` in `items/` laadt, is een `ItemResource`,
   heeft een niet-lege `id` en `display_name`; alle id's zijn **uniek**
   (QA §2, resource-integriteit).
2. **Inventory-unit** (losse instantie): toevoegen → `item_added` + telt;
   `has_item`/`get_items`/`remove_item` (+ `item_removed`); afwijzen bij
   vol, bij `null` en bij een niet-ItemResource; capaciteit respecteren.
3. **End-to-end accept**: speler kijkt naar de sleutel → E →
   `item_pickup_resolved(…, true)`, item zit in de inventory, het geluid
   klonk **ná** de bevestiging, de prop is weg, prompt leeg.
4. **End-to-end reject**: capaciteit tijdelijk vol → E → `resolved(false)`,
   prop ligt er nog, geen geluid, inventory ongewijzigd; daarna capaciteit
   terug.
5. **D-015-richtingen**: zonder `game/systems/inventory/` → E laat de prop
   liggen, geen crash, suite groen (test-INFO); zonder interactiesysteem →
   inventory idle, groen; alles aanwezig → alles groen. Testcode noemt
   `ItemResource` **nooit** bij naam (duck-typing, les D-021).
6. **Debug-regel**: F3-overlay toont bezetting na een geslaagde opname.

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
