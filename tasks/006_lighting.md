# Taak 006 — Licht & sfeer

**Fase**: 2 (Het gereedschap) · **Status**: ⬜ open · **Vereist**: 001, 002

Licht is in CRUMP zowel gameplay (zaklamp: zien kost gezien worden) als de
duurste technische post (ARCHITECTURE §7). Deze taak legt het lichtfundament en
brengt de eerste sfeerpass op de testruimte — het moment waarop rondlopen
*onaangenaam* moet worden (ROADMAP fase 2 exit-criterium).

## Doel

Een zaklamp-systeem, een werkbaar lichtbudget-kader, en een eerste sfeerpass
die de "donker-maar-leesbaar"-regel (HORROR_GUIDELINES §4) in de praktijk
waarmaakt.

## Scope

**Wel:**
- **Zaklamp** op de speler: aan/uit (via inventory-item uit 004 of directe
  input), gerichte spot, subtiele imperfectie (lichte flikker/verzwakking) als
  toekomstig spanningsinstrument. Aan/uit is een **keuze met prijs**
  (HORROR_GUIDELINES §4) — documenteer de bedoelde afweging.
- **Lichtbudget-kader**: een praktische werkwijze + eventuele helper om het
  aantal realtime schaduw-lichten per ruimte te bewaken (LEVEL_GUIDELINES §5,
  richtlijn max. 4 zichtbaar tegelijk).
- **Environment/WorldEnvironment**-basis: tonemapping, ambient-niveau,
  fog/volumetriek zó afgesteld dat donkere zones contour houden (nooit
  informatie-loos pikzwart).
- **Helderheid-instelling** (haak voor het opties-menu; QA §5) zodat
  uiteenlopende schermen leesbaar blijven.
- **Eerste sfeerpass** op de testruimte: TL-armaturen met wereld-oorzaak,
  donkere hoeken, één ontworpen lichtgebeurtenis (bijv. een flikkerende buis
  met verklaarbare oorzaak).
- Eventuele lichtshaders (flikker) als `.gdshader` in `assets/shaders/`.

**Niet:**
- Geen volledige art-pass of finale ruimte (dat is levelwerk, taak 008).
- Geen monster-gekoppelde lichtevents (komt later; hier alleen de fundamenten).

## Aanpak

1. Zaklamp-scène/component op de speler; koppel aan input en (indien gekozen)
   aan het inventory-item. Tuning via exports (bereik, hoek, intensiteit,
   flikker).
2. WorldEnvironment afstellen op leesbaar-donker; documenteer de gekozen
   waarden en waaróm (tonemap, ambient, fog).
3. Lichtbudget-werkwijze vastleggen + eventueel een editor-/debug-helper die
   telt hoeveel schaduw-lichten zichtbaar zijn.
4. Eerste sfeerpass op de testruimte met verklaarbare bronnen; bouw één
   ontworpen lichtgebeurtenis.
5. Tests headless waar mogelijk (zaklamp-node instantieert, toggle-logica,
   budget-helper telt correct); het visuele oordeel is editor-werk.
6. Commits met `[006]`-prefix.

## Acceptatiecriteria

- [ ] Zaklamp werkt (aan/uit), tuning via exports, afweging gedocumenteerd.
- [ ] WorldEnvironment levert donker-maar-leesbaar; nergens pikzwart-zonder-
      contour.
- [ ] Lichtbudget-werkwijze vastgelegd; helper (indien gebouwd) telt correct.
- [ ] Helderheid-instelling aanwezig als opties-haak.
- [ ] Sfeerpass op de testruimte: elke lichtbron heeft een wereld-oorzaak;
      één ontworpen lichtgebeurtenis werkt.
- [ ] Headless-import schoon; toggle-/helper-tests groen. Dossier + README
      bijgewerkt.

## Te beoordelen in de editor (VPS kan dit niet)

Dit is de meest visuele taak tot nu toe; vrijwel de hele acceptatie op
"leesbaar-donker" en "onaangename sfeer" is een oordeel op de ontwikkelmachine.
Lever met screenshots-instructie en bewuste export-defaults, en markeer expliciet
wat Randy moet beoordelen.
