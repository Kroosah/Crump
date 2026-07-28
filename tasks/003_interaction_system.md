# Taak 003 — Interactiesysteem

**Fase**: 1 (De wandeling) · **Status**: ⬜ open · **Vereist**: 002

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

- [ ] Interactor detecteert alleen `interactable`-objecten binnen bereik.
- [ ] Prompt-signaal verschijnt/verdwijnt correct bij aankijken.
- [ ] Alle vier props implementeren het contract en werken los-instantieerbaar.
- [ ] Deur/la publiceren `noise_made` met passende luidheid.
- [ ] Op-slot-deur weigert zonder crash en meldt dat (prompt).
- [ ] Geen directe parent-aanroepen; alles via contract + signalen.
- [ ] Headless-import schoon; prop- en interactie-tests groen. Dossier +
      README bijgewerkt.

## Ontwerpnotitie

Het contract moet zó generiek zijn dat een lichtschakelaar, een achtergelaten
telefoon, of de tv in de kantine er later moeiteloos op passen — maar we
bouwen nu alleen de vier props die fase 1 nodig heeft. Weersta de neiging het
contract "vast alvast" uit te breiden voor onbestaande props.

**Harde eis (GD, 2026-07-28) — puur polymorf, geen typechecks.** De
interactor mag nooit weten wát hij aankijkt: geen `if object is Door`,
`is Drawer`, `match`-op-type of naam-/groep-sniffing per propsoort. De
speler weet uitsluitend "dit object is Interactable" en roept blind
`can_interact()` / `interact()` / `prompt_text()` aan; élk object bepaalt
zelf wat dat betekent. Elke prop-specifieke kennis in de interactor is een
verboden afhankelijkheid (D-015) en hoort in de prop zelf. Dit geldt ook
voor toekomstige afnemers: wie op interacties wil reageren, luistert naar
signalen — niet naar types.
