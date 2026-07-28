# Taak 007 — Minimale documentlezer

**Fase**: 2½ (Vertical Slice, productiefase B) · **Status**: 🔵
technisch ontwerp ter review (GD), geen implementatie · **Vereist**:
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
  resource; het bus-contract blijft ongewijzigd.
- Eén verwijderbare `DocumentReader`-UI-luisteraar die `document_opened`
  toont, input blokkeert en met Esc sluit.
- Dev-room-briefje omgezet naar het nieuwe datamodel; suite bijgewerkt.

**Niet (bindend, GD 2026-07-28):** geen codex; geen verzamellijst; geen
documentinventaris; geen drag-and-drop; geen save/load-werk; geen
voice-over; geen uitgebreide animaties; geen concrete briefje-types in
de reader (de reader kent alleen tekst, nooit props of soorten).

---

# Technisch ontwerp (v1, 2026-07-28 — ter review GD)

## 1. Architectuur — nieuwe en gewijzigde onderdelen

```
game/props/note_readable/document_resource.gd  ← datamodel (bij de prop:
 └─ + documents/*.tres                            de prop is eigenaar van
                                                  zijn data, reader niet)
game/props/note_readable/note_readable.gd      ← leest uit de resource
game/ui/document_reader/                       ← verwijdereenheid: de lees-UI
 └─ document_reader.tscn/gd                       (bootstrap-spawn, groep
                                                  "document_reader")
EventBus                                       ← ongewijzigd: document_opened
                                                  (document_id, text) blijft exact
```

**Keuze A — het bus-contract wijzigt niet.** *(D-021/D-022-regime)*
`document_opened(document_id: StringName, text: String)` bestaat sinds
003, draagt uitsluitend basistypen en is precies genoeg: de reader
heeft alleen tekst nodig. De resource gaat dus **niet** over de bus —
de prop "plat" zijn data naar het bestaande feit. Daardoor kent de
reader geen enkel proptype en geen resource-klasse (eis GD: geen
concrete briefje-types in de reader), en overleeft élke kant het
verwijderen van de andere. **Verworpen**: `document_opened(resource)`
(klasse over de bus = D-021-breuk); een tweede signaal (bestaand
contract is toereikend, P4).

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
DocumentResource`. `interact()` blijft:
`GameState.mark_document_read(document.id)` +
`EventBus.document_opened.emit(document.id, document.text)` — met een
null-guard (prop zonder document weigert stil met een `push_warning`;
zelfde regime als de pickup zonder item). De titel gaat als onderdeel
van de tekst-payload mee? **Nee** — keuze: de titel gaat níét over de
bus (contract wijzigt niet); de prop plakt hem vóór de tekst
(`"KOP\n\ntekst"`) zodat het bestaande tweeargument-feit volstaat. De
reader toont letterlijk wat hij krijgt.

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
    ├─ GameState.mark_document_read(id)        (bestaand)
    └─ EventBus.document_opened(id, tekst)     (bestaand feit)
         └─ DocumentReader (indien aanwezig, groep-guard):
              toont paneel · pauzeert de boom · Esc sluit → hervat
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

**Sluiten en de Esc-botsing**: de bootstrap luistert in
`_unhandled_input` (ALWAYS) naar `pause`. De reader vangt zijn
sluit-input daarom in **`_input`** (eerder in de pijplijn) en markeert
het event als afgehandeld (`set_input_as_handled`) — één druk op Esc
sluit dus alléén het document en opent nooit tegelijk de pauze;
daarná werkt Esc weer gewoon als pauze. Sluiten kan met `pause` (Esc)
én `interact` (E) — beide voelen natuurlijk. De reader raakt de
bootstrap nooit aan; hij eet alleen het event op vóórdat het daar
aankomt.

**Randgevallen, vastgelegd**: opent nooit zonder tekst-feit; sluit
zichzelf en geeft de pauze terug in `_exit_tree` als hij verwijderd
wordt terwijl hij open staat (geen eeuwig bevroren spel); als iets
anders ooit óók pauzeert (toekomstig menu), geeft de reader de pauze
alleen terug als hij hem zelf bezat (`_owns_pause`-vlag).

## 5. Debugbaarheid

- `Log.info` bij openen ("DocumentReader: '<id>' geopend") en sluiten —
  de vaste logdiscipline; geen F3-regel (er valt niets doorlopends te
  tonen; P4, geen gratis zekerheid over wat gelezen is — P7).
- De bestaande F3-regels blijven bruikbaar tijdens het lezen (overlay
  is ALWAYS).

## 6. Teststrategie

1. **Contract**: `document_opened` ongewijzigd (2 argumenten) in de
   signaturentest; documents-map-scan: elke `.tres` laadt met geldige,
   unieke `id` en niet-lege `text` (zelfde discipline als items/sounds).
2. **Prop**: ReadableNote instantieert los; met resource → interact
   zendt exact één feit met de juiste id/tekst en registreert in
   GameState; zonder resource → stil geweigerd (warning is het bewijs),
   geen feit, geen crash; lezen blijft stil (geen `noise_made`).
3. **Reader-keten (e2e)**: briefje aankijken + interact → paneel
   zichtbaar, tekst letterlijk gelijk aan de resource, boom gepauzeerd;
   bewegingsinput verplaatst de speler aantoonbaar niet; Esc → paneel
   dicht, boom hervat, speler beweegt weer; daarná pauzeert Esc het
   spel gewoon (het opgegeten event lekt niet).
4. **Sluiten via interact**: zelfde round-trip met de E-toets.
5. **Guard**: tweede reader-instantie blijft doof (één feit → één
   paneel).
6. **D-015 beide richtingen**: zonder `game/ui/document_reader/` blijft
   alles parsebaar en groen — interactie werkt, GameState registreert,
   er verschijnt alleen geen paneel (het 003-gedrag van vandaag);
   zonder `game/props/note_readable/` draait de rest incl. reader-spawn
   gewoon door. Testcode noemt geen klassen (D-021, duck-typed).
7. **Reader verwijderd terwijl open** (unit): pauze komt terug bij de
   boom, geen bevroren spel.

## 7. Risico's

| Risico | Zwaarte | Mitigatie |
|---|---|---|
| Esc-botsing reader ↔ bootstrap-pauze geeft dubbelgedrag | middel | `_input` + `set_input_as_handled` vóór de bootstrap; expliciete suite-test (3) op "Esc sluit alleen het document" |
| Pauze-eigenaarschap botst met een toekomstig menu/HUD | laag | `_owns_pause`-vlag + vastgelegde semantiek (§4); het latere menu erft dit patroon |
| Tekstweergave (font/grootte) is op de VPS niet te beoordelen | laag | leesbaarheid is een GD-hardware-punt; opmaak minimaal houden (P4), tuning is data |
| Migratie breekt de 003-tests (document_id/document_text weg) | laag | suite in dezelfde fase mee; het bus-contract zelf wijzigt niet |

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
