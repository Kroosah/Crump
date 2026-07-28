# Taak 010 — Hoofdstuk 1: "De derde helft"

> **Canon-notitie (2026-07-28, D-028)**: dit skelet dateert van vóór de
> Vertical Slice en de nieuwe canonieke openingspremisse (terugkeer voor
> de vergeten sporttas — D-028). De beats hieronder met het
> afsluitverzoek van de barman, het douchen en de gespeelde verdwijning
> zijn **achterhaald**; ook is hoofdstuk 1 niet langer "de eerste
> verticale slice" (dat is taak 008). Dit dossier wordt herontworpen in
> een eigen GD-sessie ná de Vertical Slice, samen met de open vraag of
> "de derde helft" een speelbare proloog wordt (STORY §8). Tot die tijd:
> niets uit dit dossier bouwen.

**Fase**: 4 · **Status**: ⬜ open · **Vereist**: 002, 003, 004, 005, 006 (009 niet nodig — hoofdstuk 1 bevat geen actieve dreiging)

Het eerste speelbare verhaaldeel: alle
systemen komen samen in echte spelinhoud. Hoofdstuk 1 bevat **geen monster,
geen achtervolging en geen jumpscares** (HORROR_GUIDELINES §5a) — het bouwt
het "normaal" op dat de rest van de game kan schenden, en laat het dan
verdwijnen.

## Doel

Een van start tot slot speelbaar hoofdstuk 1 (~45–60 min) op slice-kwaliteit:
de levende clubavond, de verdwijning, en de eerste verkenning van het lege
clubhuis — onbehagen puur uit suggestie en subtiele afwijking.

## Scope

**Wel:**
- **Blockout van het clubhuis** (kantine, bar, kleedkamergang, kleedkamers,
  entree, zicht op de parkeerplaats) volgens LEVEL_GUIDELINES: de vertrouwde
  route (kantine → gang → kleedkamer → terug), oriëntatiepunten (bar,
  trofeeënkast, tv-hoek), spanningslabels per ruimte.
- **De opening, beat voor beat** (STORY §3, canoniek):
  1. levende kantine na de wedstrijd (muziek, teamgenoten, tv aan, gepraat);
  2. de trainer vertrekt;
  3. de barman vraagt de speler de kleedkamer af te sluiten;
  4. douchen en omkleden als voelbare overgang;
  5. terugkeer: iedereen verdwenen — glazen vol, stoelen verschoven, tv aan,
     parkeerplaats leeg.
- **De eerste-15-minutenfase** na de verdwijning (HORROR_GUIDELINES §5a):
  uitsluitend subtiele omgevingsveranderingen (ladder-trede 1–2); doelgevoel
  *"er klopt iets niet"*. Geen dreiging, geen schrikmomenten.
- **Environmental storytelling** (STORY §9): achtergelaten telefoons en
  tassen, halfvolle glazen, het prikbord — de verdwijning verteld in
  stillevens; alles consistent met STORY.md.
- **De kantine als referentie-staat**: de exacte begintoestand wordt
  vastgelegd (posities, licht, geluid) zodat álle latere afwijkingen
  daartegen ontworpen kunnen worden.
- **Afsluitende eerste onmiskenbare afwijking** (STORY §7, hoofdstuk 1-slot):
  het moment waarop "er klopt iets niet" kantelt naar "dit is echt" — de
  haak naar hoofdstuk 2. Nog steeds zonder zichtbare dreiging.
- **Checkpoints + save** in de praktijk (ARCHITECTURE §6).
- **Opties-menu**: audio (per bus), muisgevoeligheid, helderheid, head-bob,
  ondertitels — de toegankelijkheidshaken uit eerdere taken samengebracht
  (QA §9).
- **Eerste externe playtest-ronde** + verwerking van de bevindingen.

**Niet:**
- Geen hoofdstuk 2-content; **geen enkele verschijning van CRUMP** (ook geen
  silhouet "voor de spanning" — zie de ontwerpnotitie).
- Geen finale art-productie voor het hele sportpark — slice-kwaliteit op de
  gespeelde route, niet elke hoek af.
- De velden en bijgebouwen buiten het clubhuis alleen als zicht/decor, nog
  niet begaanbaar (dat is hoofdstuk 2).

## Aanpak

1. Blockout de route en ruimtes (grijs, correcte maten, navigatie,
   sightlines); toets aan de LEVEL_GUIDELINES-checklist vóór art-pass.
2. Bouw de opening met de bestaande systemen (interactie 003 voor kleine
   kantine-interacties, inventory 004 voor de kleedkamersleutel, audio 005
   voor de levende-kantine-laag én de stilte erna, licht 006).
3. Script de beat-overgangen (trainer weg → barman-vraag → kleedkamer →
   verdwijning) als leesbare, eerlijke sequentie; de kleedkamer is de sluis
   (geluid gedempt, tijd verstrijkt).
4. Leg de referentie-staat van de kantine vast en bouw de subtiele
   afwijkingen van de eerste-15-minutenfase daarop.
5. Plaats de environmental storytelling; controleer canon tegen STORY.md.
6. Voeg checkpoints/saves en het opties-menu toe; verifieer round-trips.
7. Sfeer- en audiopass op de gespeelde route (HORROR_GUIDELINES §1-ritme;
   het contrast levend↔leeg is de kern van dit hoofdstuk).
8. Interne doorloop → QA_CHECKLIST secties 1–9 → externe playtest → verwerken.
9. Commits met `[010]`-prefix; grote deelstukken op een branch.

## Acceptatiecriteria

- [ ] Hoofdstuk 1 is van start tot slot speelbaar (~45–60 min) zonder blockers.
- [ ] De opening volgt de canonieke beats (STORY §3) exact.
- [ ] De verdwijning landt: identieke ruimte, ontbrekende mensen; de
      referentie-staat is vastgelegd en herbruikbaar.
- [ ] De eerste 15 minuten na de verdwijning bevatten aantoonbaar geen
      dreiging, achtervolging of jumpscare (HORROR_GUIDELINES §5a).
- [ ] Environmental storytelling consistent met STORY.md; documenten kort en
      scanbaar; geen naam legt de hoofdpersoon vast (STORY §2).
- [ ] Afsluitende afwijking werkt als haak naar hoofdstuk 2, zonder
      zichtbare dreiging.
- [ ] Checkpoints/saves werken; opties-menu compleet en instellingen blijven
      bewaard.
- [ ] Ruimtes voldoen aan de LEVEL_GUIDELINES-checklist.
- [ ] QA_CHECKLIST secties 1–9 doorlopen; externe playtest gedaan en verwerkt.
- [ ] Headless-import schoon; scene-load- en save-tests groen. Dossier +
      README + ROADMAP bijgewerkt.

## Exit-criterium (ROADMAP fase 4)

Hoofdstuk 1 speelt van start tot slot en **playtesters willen weten hoe het
verdergaat** — zonder dat er één gevecht, één achtervolging of één
monster-verschijning aan te pas kwam.

## Ontwerpnotitie

Dit hoofdstuk is de test van de hele fundering én van onze discipline: de
verleiding zal groot zijn om "voor de zekerheid" toch een silhouet of een
schrikmoment toe te voegen. Doe het niet — HORROR_GUIDELINES §5a is hard.
De kracht van hoofdstuk 1 is de verdwijning zelf: een kantine vol leven die
tien minuten later doodstil is, is enger dan alles wat we eraan toe zouden
kunnen voegen.
