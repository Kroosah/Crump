# Taak 005 — Audio-fundament

**Fase**: 2 (Het gereedschap) · **Status**: ⬜ open · **Vereist**: 001, 002

Geluid is in CRUMP geen aankleding maar het belangrijkste horror-instrument
(GAME_BIBLE pijler 1, HORROR_GUIDELINES §3). Deze taak bouwt het fundament:
mixstructuur, ambience-lagen, en geluid-als-gameplay.

## Doel

Een `AudioDirector`-autoload die de mix, ambience en cues beheert, plus de
koppeling die van speler-acties hoorbare gebeurtenissen maakt — en die
gebeurtenissen leesbaar houdt voor het monster (taak 007).

## Scope

**Wel:**
- **`AudioDirector`** (autoload) als enige systeem dat met audiobussen praat
  (ARCHITECTURE §4): volumes per bus (Master/SFX/Ambience/Music/Voice),
  ducking, fades.
- **Ambience-systeem**: gelaagde omgevingsgeluiden (het "nulpunt" uit
  HORROR_GUIDELINES §3) die per ruimte/toestand in- en uitgefade kunnen worden.
- **Geluid-als-event**: `AudioDirector` (of een dun geluid-systeem) luistert
  op `EventBus.noise_made(position, loudness)` en speelt de bijbehorende 3D-sfx
  af — één plek waar "iets maakt geluid" audio wordt, voor voetstappen (002),
  deuren en vallende props (003).
- **3D-positionele audio**: correcte richting/afstand, testbaar op koptelefoon.
- **Muziek-cues** (schaars): API om spanning te laten stijgen/dalen, met de
  regel dat muziek de AI niet verklapt (HORROR_GUIDELINES §3).
- **Volume-instellingen** koppelbaar aan het latere opties-menu (per bus).
- Placeholder-audio waar nodig, **gegenereerd** via een `tools/`-script en
  gedocumenteerd (CLAUDE.md: geen assets verzinnen).

**Niet:**
- Geen finale sounddesign/asset-productie (dat is doorlopend contentwerk).
- Geen monster-audio-gedrag (dat komt in 007, dit levert de haken).

## Aanpak

1. `AudioDirector` bouwen: busbeheer, fades, ducking, ambience-lagen.
2. Geluid-systeem abonneren op `noise_made`; map luidheid → sfx + volume +
   3D-positie. Sluit voetstappen (002) en deuren/props (003) hierop aan.
3. Voetstap-sets als `Resource` (per ondergrond: beton, tapijt, metaal) zodat
   uitbreiden data is, geen code.
4. Muziek-cue-API met een klein toestandsmodel (rust/spanning) los van de AI.
5. Placeholder-geluiden genereren met een tool-script; documenteren.
6. Tests: `noise_made` leidt tot een audio-afspeling met juiste bus/positie;
   busvolumes reageren op instellingen; ambience-fade werkt.
7. Commits met `[005]`-prefix.

## Acceptatiecriteria

- [ ] `AudioDirector` beheert alle bussen; niets anders praat direct met audio.
- [ ] `noise_made`-events resulteren in correct gepositioneerde 3D-sfx.
- [ ] Ambience-lagen faden per toestand; nulpunt-stilte klopt.
- [ ] Voetstap-ondergronden zijn data (resources), geen code.
- [ ] Muziek-cue-API werkt en is ontkoppeld van de AI.
- [ ] Busvolumes instelbaar (haak voor opties-menu).
- [ ] Placeholder-audio gegenereerd + gedocumenteerd.
- [ ] Headless-import schoon; audio-event-tests groen. Dossier + README
      bijgewerkt.

## Te beoordelen op hardware (VPS kan dit niet)

Mix, 3D-positionering en de balans koptelefoon-vs-speakers (QA_CHECKLIST §4)
zijn niet headless te beoordelen. Lever met een korte testscène-instructie
zodat Randy het op de ontwikkelmachine kan horen.
