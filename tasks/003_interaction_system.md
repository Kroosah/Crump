# Taak 003 — Interactiesysteem

**Fase**: 1 (De wandeling) · **Status**: ✅ gebouwd, wacht op visuele beoordeling · **Vereist**: 002

De werkwoorden van CRUMP zijn kijken, oppakken, openen, lezen (GAME_BIBLE §5).
Deze taak bouwt het systeem waarmee de speler met de wereld praat — generiek,
zodat elke prop erop kan aansluiten.

## Doel

Een raycast-gebaseerd interactiesysteem met een helder `Interactable`-contract,
plus de eerste handvol props die het bewijzen.

## Scope

**Wel:**
- **Interactor** op de speler: ray vanaf de camera tot een beperkte afstand,
  detecteert objecten op de `interactable`-physicslayer.
- **`Interactable`-contract** (base-klasse of interface-conventie) met
  minimaal: `can_interact() -> bool`, `interact(by: Node) -> void`,
  `prompt_text() -> String`.
- **Prompt-signaal**: de interactor meldt via EventBus/HUD-signaal welke
  prompt getoond moet worden (tekst tekenen is UI, hier alleen het signaal).
- **Eerste props** in `game/props/`, elk een eigen scène die het contract
  implementeert:
  - **Deur** (open/dicht, kan op slot; sluit-/openluid publiceert
    `noise_made`).
  - **La/kast** (open/dicht, kan een item bevatten — item pas echt in 004).
  - **Oppakbaar object** (verplaatsbaar/oppakbaar; haakt later op inventory).
  - **Leesbaar briefje** (opent een leesweergave-signaal; tekst als data).
- Props zenden hun effecten via **signalen**; niemand kent iemand rechtstreeks
  (ARCHITECTURE §5.1).

**Niet:**
- Geen inventory-opslag (004) — een opgepakt item verdwijnt voorlopig of
  logt alleen; de haak is er, de opslag nog niet.
- Geen definitieve lees-UI (dat is UI-werk in fase 2/4) — alleen het signaal
  "toon dit document".

## Aanpak

1. Definieer het `Interactable`-contract als `class_name Interactable`
   (of duidelijke conventie) met de drie methodes + een `prompt_text`.
2. Bouw de `Interactor` op de speler: raycast in `_physics_process`, houd het
   huidige target bij, emit prompt-signaal bij wisseling, roep `interact()` op
   de `interact`-input.
3. Bouw de vier props als losstaande scènes, elk met eigen script dat overerft
   van/voldoet aan het contract. Deur en la publiceren `noise_made` bij
   gebruik.
4. Tests: elk prop-scène instantieert los; `interact()` op een deur wisselt
   staat en emit het geluid-event; een op-slot-deur weigert netjes.
5. Commits met `[003]`-prefix, bij voorkeur per prop een commit.

## Acceptatiecriteria

- [x] Interactor detecteert alleen `interactable`-objecten binnen bereik
      *(ray-mask wereld+interactable: eerste hit telt, muren blokkeren)*.
- [x] Prompt-signaal verschijnt/verdwijnt correct bij aankijken *(smoke:
      per prop, plus wegkijken en niet-interactable)*.
- [x] Alle vier props implementeren het contract en werken los-instantieerbaar.
- [x] Deur/la publiceren `noise_made` met passende luidheid *(deur 7 m,
      la 4 m, slot-rammel 4 m, oppakken 2 m; briefje bewust stil)*.
- [x] Op-slot-deur weigert zonder crash en meldt dat (prompt "Op slot").
- [x] Geen directe parent-aanroepen; alles via contract + signalen.
- [x] Headless-import schoon; suite 117/117 groen. Dossier + README
      bijgewerkt.

## Wat er gebouwd is (2026-07-28)

- `game/systems/interaction/` — `interactable.gd` (contract, class_name,
  StaticBody3D-basis met layer-waarschuwing) + `interactor.tscn/gd`:
  raycast vanaf de **actieve viewport-camera** (geen spelerkennis, D-020),
  prompt letterlijk uit `prompt_text()` op `EventBus.interact_prompt_changed`,
  alleen emitten bij verandering. Bootstrap spawnt hem met bestaanscheck.
- `game/props/` — vier mappen, elk scène+script, **zonder class_name**
  (er bestaat geen type om op te checken) en alle teksten/tuning als exports:
  `door_wooden` (draait om scharnier-oorsprong, `locked`, rammelt op slot,
  `toggled`-signaal), `drawer_cabinet` (schuift langs eigen as, eenmalig
  `item_found`), `pickup_item` (`picked_up` + verdwijnt), `note_readable`
  (`document_opened` + GameState; lezen is stil).
- Dev room: `TestProps`-spawner (`dev_props.gd`) plaatst deur, op-slot-deur,
  la-met-sleutel, sleutel en briefje — uitsluitend als de scènes bestaan.
- EventBus: nieuw signaal `document_opened(document_id, text)`.
- Smoke-suite 81 → 117 met de volledige keten per prop. **Verwijdereenheid
  = contract + interactor + props sámen** (D-021): alles weg = 82/82 groen;
  halve verwijdering faalt bewust luid.

## Te beoordelen in de editor (VPS kan dit niet)

F5 en loop de props langs (deuren links-achter, kast+sleutel rechts-achter,
briefje op de noordmuur):

1. Kijk naar de **deur** → "Open deur"; **E** → klapt open (bewust instant,
   TD-005) en je hóórt hem straks pas (audio is taak 005) — nu is het effect
   zichtbaar + prompt wisselt naar "Sluit deur" (even meelopen om het paneel).
2. **Op-slot-deur** (verder naar links) → "Op slot"; E doet zichtbaar niets.
3. **La** → "Open la"; E → schuift uit; log meldt de sleutelvondst (F3/console).
4. **Sleutel** op de rode kist → "Pak sleutel op"; E → verdwijnt, prompt weg.
5. **Briefje** (noordmuur) → "Lees briefje"; E → nog geen leesvenster (komt
   in fase 2/4), wel een `document_opened`-signaal — zichtbaar in de log.
6. Kijk weg / kijk naar een kale kist → geen prompt.
7. Prompt-afstand is 2,5 m (export `max_distance` op de Interactor) — voelt
   dat goed?

## Ontwerpnotitie

Het contract moet zó generiek zijn dat een lichtschakelaar, een achtergelaten
telefoon, of de tv in de kantine er later moeiteloos op passen — maar we
bouwen nu alleen de vier props die fase 1 nodig heeft. Weersta de neiging het
contract "vast alvast" uit te breiden voor onbestaande props.

**Harde eis (GD, 2026-07-28) — de prompt is volledig data-gedreven.**
Nergens in speler, interactor of UI wordt een prompttekst samengesteld op
basis van wat het object is ("Druk op E om deur te openen"). Elk object
bepaalt zijn eigen tekst via `prompt_text()` — "Open deur", "Lees brief",
"Pak sleutel op", "Schakel stroom in" — en de interactor geeft die tekst
letterlijk en ongewijzigd door op het prompt-signaal. Daarbij hoort ook:
de **toets** ("E") staat nooit in de proptekst; de prop levert alleen de
handeling, en de UI-laag die de prompt straks tekent plakt daar zelf de
actueel gebonden toets uit de InputMap bij. Zo overleven alle prompts een
toets-rebind én de latere vertaling (`localization/`) zonder dat één prop
wijzigt.

**Harde eis (GD, 2026-07-28) — puur polymorf, geen typechecks.** De
interactor mag nooit weten wát hij aankijkt: geen `if object is Door`,
`is Drawer`, `match`-op-type of naam-/groep-sniffing per propsoort. De
speler weet uitsluitend "dit object is Interactable" en roept blind
`can_interact()` / `interact()` / `prompt_text()` aan; élk object bepaalt
zelf wat dat betekent. Elke prop-specifieke kennis in de interactor is een
verboden afhankelijkheid (D-015) en hoort in de prop zelf. Dit geldt ook
voor toekomstige afnemers: wie op interacties wil reageren, luistert naar
signalen — niet naar types.
