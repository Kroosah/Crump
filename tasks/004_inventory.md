# Taak 004 — Inventory

**Fase**: 2 (Het gereedschap) · **Status**: ⬜ open · **Vereist**: 003

Een kleine, diegetische inventory (GAME_BIBLE §8: geen 40-slots-grid).
De speler draagt een handvol betekenisvolle spullen — de kleedkamersleutel
van de barman, een zaklamp, een gevonden telefoon, een enkel verhaalobject.

## Doel

Een data-gedreven inventory-systeem waarin items `Resource`s zijn en het
gebruik ervan via de EventBus verloopt, met een sobere UI die bij de toon past.

## Scope

**Wel:**
- **`ItemResource`** (`class_name`, `.tres`) met getypte velden: `id`,
  `display_name`, `description`, `icon`, en vlaggen zoals `stackable`,
  `usable`, `key_id` (voor deuren/sloten).
- **Inventory-systeem** in `game/systems/`: toevoegen, verwijderen, bevatten,
  ophalen; houdt een lijst van item-id's + aantallen bij. Serialiseerbaar
  (deel van `GameState`, ARCHITECTURE §6).
- **Koppeling met props (003)**: een opgepakt object voegt zijn `ItemResource`
  toe; een op-slot-deur checkt op `key_id` in de inventory.
- **Gebruik via events**: `EventBus.item_used(item_id)` — het effect leeft bij
  de ontvanger (een deur, de zaklamp-toggle), niet in de inventory.
- **Diegetische UI** in `game/ui/`: sobere weergave (geen HUD-clutter);
  past bij "de speler is een gewoon mens", niet bij een RPG-menu. Openen/
  sluiten met eigen input.
- Enkele voorbeeld-items als `.tres` (sleutel, telefoon, zaklamp) om het
  systeem te bewijzen — nog geen echte spelinhoud.

**Niet:**
- Geen crafting, gewicht, of item-combinatie (niet in de visie).
- Geen definitieve art voor iconen (placeholder mag, gedocumenteerd).

## Aanpak

1. Definieer `ItemResource` met getypte velden en documentatie per veld.
2. Maak de voorbeeld-`.tres`-items aan (sleutel, telefoon, zaklamp).
3. Bouw het inventory-systeem als node/service; state hangt in `GameState`
   zodat het meesaveT.
4. Sluit props aan: oppakken → `add_item`; slot-check → `has_key(key_id)`.
5. Bouw de sobere UI, verbind via signalen (geen directe koppeling).
6. Tests: item toevoegen/verwijderen/bevatten; save→load behoudt inventory;
   op-slot-deur opent met de juiste sleutel en weigert zonder.
7. Commits met `[004]`-prefix.

## Acceptatiecriteria

- [ ] Items zijn `.tres`-resources met getypte velden; geen dicts-als-schema.
- [ ] Toevoegen/verwijderen/bevatten werkt en zit in `GameState` (meesaveT).
- [ ] Oppakbaar object uit taak 003 belandt echt in de inventory.
- [ ] Deur met slot opent met de juiste sleutel, weigert zonder.
- [ ] Item-gebruik loopt via EventBus; inventory kent de effecten niet.
- [ ] UI is sober, past bij de toon, open/sluit netjes.
- [ ] Headless-import schoon; inventory- en save-round-trip-tests groen.
      Dossier + README bijgewerkt.

## Ontwerpnotitie

Klein houden is een ontwerpkeuze, geen beperking. Elk item dat we toevoegen
moet een reden hebben in STORY.md. De inventory is er voor betekenis en
voortgang, niet voor resource-management.
