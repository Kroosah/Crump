# CRUMP — Roadmap

*Fasering van fundering tot Steam. Geen datums maar mijlpalen: een fase is af
als de exit-criteria gehaald zijn, niet als de kalender dat zegt. Volgorde is
bewust: eerst voelen (speler + geluid), dan vrezen (CRUMP), dan vertellen
(hoofdstukken).*

---

## Fase 0 — Fundering ✅

**Doel**: professionele projectbasis waar jaren op gebouwd kan worden.

- [x] Repository, mappenstructuur, documentatieset, taakdossiers.
- [x] Godot 4.7.1 headless op de bouw-VPS, geverifieerd.

**Exit-criteria**: gehaald op 27-07-2026.

---

## Fase 1 — De wandeling (taken 001–003) ✅

**Doel**: het voelt al goed om alleen maar rond te lopen in een lege testruimte.
In een horrorgame is beweging 50% van de ervaring; dit wordt niet afgeraffeld.

- [x] **001** Project-setup: project.godot, input-map, bussen, autoload-skelet,
      smoke-test, .gitignore.
- [x] **002** Player controller: lopen/sluipen/rennen, bukken, hoofdbeweging,
      camera-gevoel, voetstapgeluid-events.
- [x] **003** Interactiesysteem: raycast + `Interactable`-contract, eerste
      props (deur, la, oppakbaar object, leesbaar briefje).

**Exit-criteria**: gehaald op 28-07-2026 — bewegen en interacteren door de
GD in de editor beoordeeld, headless-tests groen, tuning via exports.

## Fase 2 — Het gereedschap (taken 004–006)

**Doel**: de systemen die sfeer dragen: spullen, geluid, licht.

- [x] **004** Inventory + items als resources *(afgerond 28-07-2026;
      de diegetische UI is bij de ontwerp-review bewust uit 004 gehaald en
      volgt in een eigen UI-taak — zie tasks/004 §1)*.
- [x] **005** Audio-fundament: mixbussen, ambience-lagen, gescheiden
      audio_cue-kanaal, one-shot-pool, muziek-API *(afgerond 28-07-2026;
      "geluid-als-event" is conform het bindende kader gesplitst in
      gameplay-gehoor en hoorbare audio — zie tasks/005)*.
- [ ] **006** Licht & sfeer: zaklamp, lichtbudget, donker-maar-leesbaar-kaders,
      eerste sfeerpass op de testruimte *(gebouwd 28-07-2026, suite 208
      groen; wacht op lokale GD-test — de fase-exit-lat is een
      hardware-oordeel)*.
- [ ] Beslismoment: git-lfs nodig? (assets > ~500 MB)

**Exit-criteria**: de testruimte is 's nachts *onaangenaam* om in te zijn,
zonder dat er ook maar iets gebeurt. Dat is de lat.

## Fase 3 — De dreiging (taak 007)

**Doel**: CRUMP als leesbare, systemische dreiging.

- [ ] **007** AI: state machine, navigatie, gehoor via event-bus, zicht,
      spanningsregels (afstand-audio, muziekcues via AudioDirector).
- [ ] Kat-en-muis-prototype in de testruimte: verstoppen, ontwijken, gepakt
      worden, checkpoint-herstart.

**Exit-criteria**: 15 minuten kat-en-muis in de testruimte is spannend zonder
één gescript moment. Playtest met ≥3 personen buiten het team.

## Fase 4 — Hoofdstuk 1: "De derde helft" (taak 008)

**Doel**: het eerste speelbare verhaaldeel, verticale slice-kwaliteit.

- [ ] Blockout van het clubhuis (kantine, kleedkamergang, entree) volgens LEVEL_GUIDELINES.
- [ ] De opening (levende kantine → kleedkamer → verdwijning, STORY §3) + de eerste-15-minutenfase (HORROR_GUIDELINES §5a) + omgevingsvertelling hfst 1.
- [ ] Save/checkpoints in de praktijk; opties-menu (audio, gevoeligheid,
      helderheid, toegankelijkheid-basis).
- [ ] Eerste externe playtest-ronde + verwerking.

**Exit-criteria**: hoofdstuk 1 van start tot slot speelbaar (~45–60 min),
playtesters willen weten hoe het verdergaat.

## Fase 5 — Hoofdstukken 2–4

**Doel**: het volledige verhaal, met per hoofdstuk dezelfde slice-kwaliteit.

- [ ] Hoofdstuk 2 (het sportpark wordt groter en vreemder; eerste sporen van het woord CRUMP).
- [ ] Hoofdstuk 3 (escalatie + keuzes; CRUMP-ontwerpsessie vooraf, zie STORY §8).
- [ ] Hoofdstuk 4 (de confrontatie met wat CRUMP is + eindes).
- [ ] Volledige playthrough-playtests per toevoeging.

**Exit-criteria**: complete run van 3–5 uur, alle eindes bereikbaar,
consistente kwaliteit.

## Fase 6 — Polish & Steam

**Doel**: van "af" naar "uitgebracht".

- [ ] Windows-export-pipeline (export-templates, tools/build-script, itch/Steam
      builds via `builds/`).
- [ ] Steamworks: pagina, capsule-art, trailer, achievements (spaarzaam en
      spoilervrij), cloud saves.
- [ ] Lokalisatie EN vanuit `localization/` (NL is bron).
- [ ] Performance-pass tegen het 60fps/1080p-doel (ARCHITECTURE §7).
- [ ] QA-eindronde: volledige `QA_CHECKLIST.md` op elke release-kandidaat.
- [ ] Demo (hoofdstuk 1, ingekort) voor Steam Next Fest overwegen.

**Exit-criteria**: release-kandidaat die de volledige QA-checklist haalt op
de minimale doel-hardware.

---

## Werkafspraken bij deze roadmap

- **Volgorde is heilig, tempo niet.** Fases schuiven mag, overslaan niet:
  elk systeem bouwt op het vorige.
- **Eén taak = één dossier = één reeks commits.** Zie `tasks/`.
- **Playtesten is een mijlpaal-activiteit**, geen bijzaak: fase 3, 4 en 5
  bevatten elk expliciet extern testen.
- Statusoverzicht per taak staat in `README.md`; dit document beschrijft de
  fases, de dossiers beschrijven het werk.
