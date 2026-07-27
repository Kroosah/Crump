# CRUMP — Changelog

*Elke afgeronde taak of betekenisvolle wijziging krijgt een versienummer en
een korte omschrijving. Nieuwste bovenaan. **Verplicht bijwerken** bij elke
taak (zie CLAUDE.md).*

**Versienummering**: `v0.0.x` tijdens de fundering; `v0.x.0` per afgeronde
roadmap-fase; `v1.0.0` = release. Het nummer zegt niets over kwaliteit, alleen
over volgorde — het doel is dat je maanden later kunt terugvinden wanneer
iets veranderde en in welke commit.

---

## v0.0.7 — 2026-07-27
**Bugfix: developer room toonde een egaal grijs beeld (KI-001)**
- **Oorzaak**: het project bevatte nergens een `Camera3D`. Zonder actieve
  camera rendert Godot de 3D-wereld niet en vult de viewport met
  `rendering/environment/defaults/default_clear_color` — precies het
  egale grijs (0.3, 0.3, 0.3) dat op de dev-pc te zien was.
- Vaste testcamera `TestCamera` toegevoegd aan de dev room (D-016), met
  `dev_camera.gd` die het beeld aan een latere spelerscamera laat.
- Dev room visueel robuust gemaakt: contrasterende materialen (vloer donker
  blauwgrijs, muren licht warmgrijs, zes gekleurde testobjecten), extra
  primitieven (bol, cilinder, capsule op 1,8 m als hoogtereferentie),
  en verlichting van één naar drie bronnen (DirectionalLight + twee omni's,
  twee daarvan met schaduw — binnen het lichtbudget van LEVEL_GUIDELINES §5).
- Achtergrondkleur bewust wég van het default-grijs gezet, zodat een écht
  kapot beeld voortaan te onderscheiden is van een werkende render.
- Smoke-suite uitgebreid van 31 naar 48 controles met een
  zichtbaarheidsblok: actieve camera, near/far, camera niet in geometrie,
  kijkrichting, aantal meshes, materiaalcontrast, actieve lichten en
  environment-instellingen.

## v0.0.6 — 2026-07-27
**GitHub gekoppeld + sessiestatus ingericht**
- Repository gekoppeld aan `git@github.com:Kroosah/Crump.git` (privé, SSH
  deploy key); `main` gepusht met upstream-tracking. **GitHub is vanaf nu de
  officiële bron van waarheid.**
- `docs/SESSION_STATE.md` toegevoegd: laatste taak, commit, GitHub-status,
  projectstatus, volgende taak en open aandachtspunten.
- CLAUDE.md: vaste leesvolgorde bij sessiestart (SESSION_STATE → DECISIONS →
  GAME_BIBLE → ARCHITECTURE → actieve taak); Definitie van "af" uitgebreid
  met SESSION_STATE, de verwijderbaarheidstest en verplicht pushen.
- Definition of Done voor taak 001 herbevestigd: import exit 0, smoke-suite
  31/31 groen, werkmap schoon, registers compleet.

## v0.0.5 — 2026-07-27
**Modulariteit vastgelegd als harde eis**
- D-015: elke feature moet volledig verwijderbaar zijn; gameplay-systemen
  hebben geen onderlinge afhankelijkheden.
- ARCHITECTURE §1.6 en nieuw §4a: de verwijderbaarheidstest + zes regels
  (signalen als feiten, autoloads = infrastructuur, één map per feature,
  optioneel opzoeken, registratie boven bedrading).
- CLAUDE.md: ontwikkelregel 11; QA_CHECKLIST: verwijderbaarheidstest per taak.
- Bestaande code getoetst: geen cross-systeem-verwijzingen; spel blijft
  draaien met de developer room verwijderd.

## v0.0.4 — 2026-07-27
**Taak 001 afgerond: project-setup & bootstrap — CRUMP is nu een draaiend Godot-project**
- `project.godot`: Forward+, input-map, benoemde physics-layers, audiobussen
  (Master → SFX/Ambience/Music/Voice).
- Vijf autoloads: EventBus (signalen-contract), GameState (+serialisatie),
  AudioDirector (busbeheer), SettingsManager (D-011), SaveManager
  (JSON + save_version).
- Bootstrap + lifecycle: level-laden onder SceneHost, pauze, nette shutdown.
- Developer room (grijze blockout 20×20 m) als vaste testruimte.
- Log-systeem (statische klasse, D-012): console + user://logs met rotatie.
- Debug overlay (F3, alleen debugbuilds): fps/frametijd/level + haken.
- Instellingen: volumes, muisgevoeligheid, head-bob, helderheid, grafische
  presets DEVELOPMENT_LOW t/m ULTRA (D-014).
- Smoke-test-suite (D-013): 31 controles, allemaal groen; exitcode voor CI.
- Commits: `887eaa3`…`4319d6a` (blokken 1–8) + registerblok.

## v0.0.3 — 2026-07-27
**Studio-administratie toegevoegd**
- DECISIONS.md, CHANGELOG.md, KNOWN_ISSUES.md en TECH_DEBT.md aangemaakt en
  verankerd in README en CLAUDE.md (verplicht onderdeel van elke taak).
- Nieuwe vaste regel: na elke taak beantwoordt de Lead Developer de vier
  rapportagevragen (wat gebouwd / waarom zo / risico's / advies volgende taak).
- Scope van taak 001 uitgebreid op aanwijzing van de Game Director
  (bootstrap, developer room, logging, debug overlay, game lifecycle,
  instellingen).

## v0.0.2 — 2026-07-27
**Visie herzien: naamloze hoofdpersoon, voetbalclub-opening, CRUMP als mysterie**
- STORY.md volledig herschreven (opening VV Drechtstreek / Sportpark
  Oostpolder, verdwijning uit de kantine, canonieke beats).
- CRUMP nergens meer locatie/club: het is het mysterie en de latere dreiging.
- Harde regel "eerste 15 minuten" toegevoegd (HORROR_GUIDELINES §5a).
- Rolverdeling + tien ontwikkelregels vastgelegd in CLAUDE.md.
- Projectmap hernoemd: `nachtdienst` → `crump`.
- Commits: `dd76e69`, `90bee25`.

## v0.0.1 — 2026-07-27
**Project gestart (fase 0: fundering)**
- Repository, mappenstructuur en volledige documentatieset aangemaakt
  (README, CLAUDE, game bible, story, architecture, roadmap, coding
  standards, horror/level guidelines, QA-checklist).
- Acht taakdossiers (001–008) uitgewerkt.
- Godot 4.7.1 headless geïnstalleerd en geverifieerd op de bouw-VPS.
- Commit: `adcc2ec`.
