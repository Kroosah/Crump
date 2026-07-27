# Taak 007 — Monster-AI

**Fase**: 3 (De dreiging) · **Status**: ⬜ open · **Vereist**: 002, 003, 005, 006

De dreiging als **systeem**, niet als scripted schrik (GAME_BIBLE §6,
HORROR_GUIDELINES §6). Eén monster dat patrouilleert, hoort, ziet, onderzoekt
en de speler leert lezen. Dit is het hart van de horror.

## Doel

Een data-gedreven AI die eerlijk en leesbaar is: reageert uitsluitend op
gedefinieerde zintuigen, spawnt nooit in beeld, en biedt in elke
dreigingssituatie een leesbare overlevingsoptie.

## Scope

**Wel:**
- **Eindige-toestandsmachine**: `patrol → investigate → chase → search →
  return`. Overgangen expliciet en voor de speler leesbaar aan tells
  (geluid, beweging).
- **Gehoor**: abonneert op `EventBus.noise_made(position, loudness)` — de
  koppeling met speler (002), deuren/props (003) en audio (005). Luidheid +
  afstand bepalen of het reageert. **Dit is de kernzintuig.**
- **Zicht**: view-cone + line-of-sight-check (raycast), begrensd bereik; geen
  wallhacks, geen kennis van spelerspositie buiten de zintuigen.
- **Navigatie** via NavigationServer/NavigationAgent over de per-ruimte
  gebakken navmesh (LEVEL_GUIDELINES §7).
- **Geheugen (kort)**: laatst bekende positie, verval van interesse — zodat
  ontsnappen door uit zicht/gehoor te blijven echt werkt.
- **Volledig data-gedreven**: gehoor-radii, zicht-hoek/-bereik, snelheden per
  toestand, geheugen-tijden als `@export`/AI-profiel-resource, zodat tunen
  geen code raakt.
- **Spanning-koppeling**: publiceert toestand/afstand zodat `AudioDirector`
  (005) muziek/heartbeat kan sturen — zónder dat muziek de AI verklapt.
- **Eerlijkheidsgaranties** (HORROR_GUIDELINES §6): geen spawn in beeld, geen
  aantoonbare teleportatie, minstens één leesbare uitweg per dreiging,
  eerlijk checkpoint bij gepakt worden.
- **Verstoppen**: minimale verstopmechaniek (in/uit zicht + geluid) zodat het
  kat-en-muis-prototype (ROADMAP fase 3) speelbaar is.

**Niet:**
- Geen finale monster-art/animatie (blockout-representatie volstaat om gedrag
  te bewijzen; uiterlijk komt laatst, GAME_BIBLE §6).
- Geen meerdere monsters, geen level-specifieke scripting (dat is taak 008+).

## Aanpak

1. AI-profiel als `Resource` (radii, hoeken, snelheden, tijden).
2. State machine als expliciete structuur (aparte state-objecten of een nette
   enum+dispatch); elke toestand klein en testbaar.
3. Zintuigen: gehoor-subscriber op de EventBus; zicht als cone+LOS. Alle
   waarneming via deze twee kanalen — nergens `player.global_position` direct.
4. Navigatie koppelen; laatst-bekende-positie + zoekgedrag bij verlies.
5. Verstopmechaniek + eerlijk checkpoint bij dood.
6. Spanning-signalen naar AudioDirector.
7. Tests (headless waar mogelijk): geluid-event → investigate-transition;
   LOS geblokkeerd → geen detectie; geheugen vervalt; navigatie bereikt doel.
   Gedrag-in-de-praktijk is editor/playtest-werk.
8. Commits met `[007]`-prefix, per subsysteem.

## Acceptatiecriteria

- [ ] State machine schakelt correct en leesbaar tussen alle toestanden.
- [ ] AI reageert **uitsluitend** op gehoor (event-bus) en zicht (cone+LOS);
      geen directe spelerspositie, geen wallhacks.
- [ ] Spawnt nooit in beeld; geen aantoonbare teleportatie.
- [ ] Navigatie soepel; loopt niet vast, glitcht niet door muren.
- [ ] Kort geheugen werkt: uit zicht+gehoor blijven laat het verliezen.
- [ ] Elke dreigingssituatie heeft een leesbare uitweg; gepakt → eerlijk
      checkpoint, herstart binnen minuten.
- [ ] Alle gedrag data-gedreven (profiel-resource/exports).
- [ ] Spanning-signalen bereiken AudioDirector zonder de AI te verklappen.
- [ ] Headless-import schoon; AI-unit-tests groen. Dossier + README bijgewerkt.

## Exit-criterium (ROADMAP fase 3)

15 minuten kat-en-muis in de testruimte is spannend **zonder één gescript
moment**, bevestigd door een playtest met ≥3 personen buiten het team.

## Ontwerpnotitie

De verleiding zal groot zijn om "vals te spelen" voor meer spanning (de AI net
even laten weten waar de speler is). Doe dat niet — GAME_BIBLE §6 en
HORROR_GUIDELINES §6 zijn hier hard. Leesbare, eerlijke dreiging is precies wat
CRUMP onderscheidt; oneerlijkheid voelt de speler en went verkeerd.
