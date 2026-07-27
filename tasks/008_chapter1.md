# Taak 008 — Hoofdstuk 1: "Eerste dienst"

**Fase**: 4 · **Status**: ⬜ open · **Vereist**: 002, 003, 004, 005, 006 (007 grotendeels)

Het eerste speelbare verhaaldeel en de eerste **verticale slice**: alle
systemen komen samen in echte spelinhoud. Hoofdstuk 1 is vrijwel monstervrij
(STORY §5) — het bouwt het "normaal" op dat de rest van de game kan schenden.

## Doel

Een van start tot slot speelbaar hoofdstuk 1 (~45–60 min) op slice-kwaliteit,
waarin de speler het gebouw en de routine leert en het onbehagen zich opbouwt
via pure suggestie — met de vondst van Ruuds eerste logboek als kantelpunt.

## Scope

**Wel:**
- **Blockout van De Crump** (begane grond + kantoren) volgens
  LEVEL_GUIDELINES: de rondgang-lus, taakpunten (meterkast, logboek,
  sleutelkast), oriëntatiepunten, spanningslabels per ruimte.
- **De routine-loop**: controleronde lopen, logboek invullen, meterkast —
  de "normale staat" die later geschonden wordt.
- **Environmental storytelling hfst 1** (STORY §5): verplaatste objecten,
  het tweede warme koffiekopje, Ruuds eerste logboek, Halberstadts
  openingsvoicemail. Alles consistent met STORY.md.
- **Suggestie-horror** (HORROR_GUIDELINES ladder 1–2): geluid uit een lege
  ruimte, een deur die anders staat — nog geen zichtbaar monster.
- **Eén kelder-geluid** aan het eind dat er niet hoort te zijn (haak naar
  hoofdstuk 2 / taak 007).
- **Checkpoints + save** in de praktijk (ARCHITECTURE §6).
- **Opties-menu**: audio (per bus), muisgevoeligheid, helderheid, head-bob,
  ondertitels — de toegankelijkheidshaken uit eerdere taken samengebracht
  (QA §9).
- **Eerste externe playtest-ronde** + verwerking van de bevindingen.

**Niet:**
- Geen hoofdstuk 2-content, geen volledige monster-encounter (hoogstens de
  suggestie ervan).
- Geen finale art-productie voor het hele gebouw — slice-kwaliteit op de
  gespeelde route, niet elke hoek af.

## Aanpak

1. Blockout de route en ruimtes (grijs, correcte maten, navigatie,
   sightlines); toets aan de LEVEL_GUIDELINES-checklist vóór art-pass.
2. Implementeer de routine-loop met de bestaande systemen (interactie 003,
   inventory 004 voor sleutels/logboek, audio 005, licht 006).
3. Plaats de environmental storytelling en documenten; controleer canon tegen
   STORY.md.
4. Voeg checkpoints/saves en het opties-menu toe; verifieer round-trips.
5. Sfeer- en audiopass op de gespeelde route (HORROR_GUIDELINES §1 ritme:
   afwisseling van Adem/Onrust/Druk-labels).
6. Interne doorloop → QA_CHECKLIST secties 1–9 → externe playtest → verwerken.
7. Commits met `[008]`-prefix; grote deelstukken op een branch.

## Acceptatiecriteria

- [ ] Hoofdstuk 1 is van start tot slot speelbaar (~45–60 min) zonder blockers.
- [ ] De rondgang-lus en routine-loop werken; taakpunten zijn logisch geplaatst.
- [ ] Environmental storytelling consistent met STORY.md; documenten kort en
      scanbaar.
- [ ] Horror volledig via suggestie (ladder 1–2); geen zichtbaar monster;
      afsluitend kelder-geluid als haak.
- [ ] Checkpoints/saves werken; opties-menu compleet en instellingen blijven
      bewaard.
- [ ] Ruimtes voldoen aan de LEVEL_GUIDELINES-checklist.
- [ ] QA_CHECKLIST secties 1–9 doorlopen; externe playtest gedaan en verwerkt.
- [ ] Headless-import schoon; scene-load- en save-tests groen. Dossier +
      README + ROADMAP bijgewerkt.

## Exit-criterium (ROADMAP fase 4)

Hoofdstuk 1 speelt van start tot slot en **playtesters willen weten hoe het
verdergaat** — zonder dat er één gevecht of één volledige monster-confrontatie
aan te pas kwam.

## Ontwerpnotitie

Dit hoofdstuk is de test van de hele fundering: als de systemen goed zijn,
voelt een bijna lege eerste dienst al spannend. Weersta de drang om "voor de
zekerheid" toch een monster of een jumpscare toe te voegen — de kracht van
hoofdstuk 1 is juist de opgebouwde, onvervulde dreiging (HORROR_GUIDELINES §7).
