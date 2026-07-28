# CRUMP — Changelog

*Elke afgeronde taak of betekenisvolle wijziging krijgt een versienummer en
een korte omschrijving. Nieuwste bovenaan. **Verplicht bijwerken** bij elke
taak (zie CLAUDE.md).*

**Versienummering**: `v0.0.x` tijdens de fundering; `v0.x.0` per afgeronde
roadmap-fase; `v1.0.0` = release. Het nummer zegt niets over kwaliteit, alleen
over volgorde — het doel is dat je maanden later kunt terugvinden wanneer
iets veranderde en in welke commit.

---

## v0.0.18 — 2026-07-28
**Taak 007: minimale documentlezer — papier wordt leesbaar** *(lokaal goedgekeurd door de GD, 2026-07-28; geen presentatienotities)*
- **`document_opened` → 3 argumenten** (id, titel, tekst; D-029):
  eenmalig gecorrigeerd vóór de eerste productieconsumer; vanaf nu
  geconsumeerd contract. `DocumentResource` (runtime read-only) als
  data bij de prop; ReadableNote valideert aan de bron (lege id/tekst =
  warning, geen feit, geen GameState-mutatie) en zendt alleen
  basistypen. Dev-room-briefje gemigreerd naar
  `documents/briefje_dev_room.tres`.
- **`game/ui/document_reader/`** (verwijdereenheid): CanvasLayer-
  luisteraar, bootstrap-spawn met groep-guard. Deferred arming
  (OPEN_ONGEWAPEND → OPEN_GEWAPEND ná de openingsdispatch): één E-druk
  kan nooit openen én sluiten; Esc/E sluiten daarna, opgegeten in
  `_input` — één Esc raakt nooit tegelijk de pauze. Exact
  pauze-/muisownership (statusopname, idempotent herstel, vooraf
  gepauzeerde boom blijft gepauzeerd); atomaire vervanging bij een
  tweede feit; lege titel verbergt de titelregel; ScrollContainer met
  vaste paneelmaat (geen harde tekstlimiet); sluithint uit de InputMap.
- **Suite 208 → 230**; D-015: zonder reader 209, zonder interactie-unit
  incl. documentprops 172 (reader stabiel), alles 230 — telkens 0
  fouten. Codecommentaar-taaknummers bijgewerkt naar de
  D-028-nummering. `config/version` → 0.0.18.

## v0.0.17 — 2026-07-28
**Taak 006: licht & sfeer — bijna zwart is de standaardtoestand** *(lokaal goedgekeurd door de GD, 2026-07-28)*
- **Nacht-environment** dev room: near-black achtergrond, lage koele
  ambient-vloer (contour-garantie: > 0), exponentiële diepte-fog,
  filmische tonemap, debanding. De oude heldere verlichting is een
  verborgen werklicht-rig (editor-/debugoptie, default uit, suite bewaakt).
- **`game/systems/flashlight/`** (verwijdereenheid): camera-volgend
  zaklampsysteem met realistische warme bundel en betrouwbare bediening —
  flikkert nooit willekeurig (D-025). Gesloten bezit-gate op het
  zaklamp-item via eventgedreven `has_item`-hercontrole; geslaagde toggle
  = exact één emissie per kanaal (`flashlight_toggled` nieuw op de bus +
  klik-cue + noise) op de spelerpositie, terwijl het licht de camera
  volgt. `debug_bezit_bypass` (default uit, alleen debugbuilds).
- **`game/props/light_tl/`** (verwijdereenheid): TL-armatuur met drie
  expliciete staten (STABIEL/DEFECT/FLIKKEREND); flikkerpatroon
  seed-deterministisch mét rustperiodes via `flicker_light.gdshader`
  (instance-uniform; licht en gloed uit één waarde). Dev room-nachtstaat:
  2 stabiele ankers (schaduw), 1 flikkerbuis, 5 defect — als data
  geplaatst met bestaanscheck (D-015).
- **`game/systems/light_budget/`** (verwijdereenheid): schaduwbudget-
  bewaking — max 3 level-schaduwlichten + gereserveerd zaklampslot
  (D-026); boven budget deterministische degradatie op boomvolgorde met
  één warning per lamp; de lamp zelf blijft aan.
- **Brightness werkt** (lost TD-003 af): default 1.0, clamp 0.8–1.2
  (D-027), toegepast als `adjustment_brightness` op de level-Environment
  via de herbruikbare `environment_tuner`; UI, lampen en budget blijven
  onaangeraakt. Zaklamp-pickup in de dev room via de echte flow;
  placeholder-klik + SoundResource (12 geluiden totaal).
- **F3**: `zaklamp: bezit … · aan/uit` en `licht: n/4 schaduw ·
  helderheid … · tl: telling` (duck-typed).
- **Suite 166 → 208**; visibility-checks herijkt op de nachtstaat
  (KI-001/KI-002-dekking onverkort). D-015-richtingen aangetoond: zonder
  zaklamp 188, zonder complete lighting 176, zonder inventory 169, alles
  208 — telkens 0 fouten. `config/version` → 0.0.17.

## v0.0.16 — 2026-07-28
**Taak 005: audio-fundament — het spel is hoorbaar**
- `game/systems/audio/` (verwijdereenheid, keuze A): façade met centrale
  cue-resolver (mapscan-registry, dubbele/lege id's loggen luid, onbekende
  cue = warning zonder geclaimde player), one-shot-pool (12×3D + 4×vlak;
  exacte event-positie, alle akoestiek uit SoundResource-data,
  deterministisch stelen bij uitputting, volledige reset bij hergebruik),
  ambience-lagen (standaard álles uit; levels activeren expliciet) en de
  minimale muziek-cue-API zonder triggers. AudioDirector ongegroeid.
- **`audio_cue(sound_id, position)`** op de bus: hoorbaar feit, strikt
  gescheiden van `noise_made` (kader §1); StringName als grensvaluta (B2).
  Speler (per-gait voetstappen), deur (kraak + slot-rammel), la en pickup
  (alleen ná accepted) zenden nu beide feiten; het briefje blijft stil.
- **Placeholder-audio**: deterministische generator
  (`tools/genereer_placeholder_audio.gd`, vaste seed) → 15 WAV's + 11
  SoundResources met doelentabel (kader §8) in het dossier. Dev room zet
  zijn nulpunt-laag (koeling/tl-zoem) expliciet zelf aan.
- **F3**: "actieve geluiden: n/16 · cue-ids | amb: lagen" (duck-typed).
- **Suite 145 → 166**: alle vier kader-tests (one-shot overleeft de
  verdwenen prop, max één cue per actie, geen cue bij rejected,
  kanalen onafhankelijk) + datamodel/id-discipline, pool zonder lek incl.
  finished-release (headless-driver speelt écht af), veilig falen,
  tweede-systeem-doofheid, ambience-standaard-stil, muziek-API, F3.
  D-015: zonder audio 145, zonder interactie 109, alles 166.
- `config/version` → 0.0.16.

## v0.0.15 — 2026-07-28
**Taak 004: inventory — itemmodel, kern en request/resolved-pickupflow**
- `game/systems/inventory/`: `ItemResource` (id/display_name/description/
  icon; runtime read-only configuratiedata) + drie voorbeelditems
  (kleedkamersleutel, achtergelaten telefoon, zaklamp) + de inventory-node:
  capaciteit 6, geen stacking (D-023), `add_item(Resource) -> bool` als
  enig besliskanaal — weigeringen (vol/null/verkeerd type/lege id) muteren
  niets en zenden geen signaal; `remove_item` idem bij mislukking.
- **Eén autoritatieve inventory** (dossier §2): bootstrap spawnt éénmalig
  als SceneHost-kind met groep-guard; alleen de eerste node in de groep
  verbindt zich met de bus, een tweede meldt luid en blijft doof;
  connecties symmetrisch in `_ready`/`_exit_tree`.
- **Pickupflow herzien** (D-022): verzoek → `item_pickup_requested` →
  inventory beslist → `item_pickup_resolved` → de prop verdwijnt
  uitsluitend na een geldige accepted-response binnen zijn eigen synchrone
  verzoekvenster, met eigen geluid/`picked_up`/`queue_free` — exact één
  keer. Rejected/geen listener/vreemde response = prop blijft, direct
  opnieuw interacteerbaar. Vier nieuwe bus-signalen met basistypen.
- F3-overlay toont `inventory: n/cap · id's` (null-veilig via de groep).
- **Smoke-suite 120 → 145**: itemmodel + id-uniciteit, add/remove-
  semantiek, reject-zonder-mutatie, response-invarianten (verdwaald/
  vreemde source/dubbel), ongeldige itemdata, tweede-inventory-doofheid,
  F3-regel. D-015 in drie richtingen: zonder inventory 119, zonder
  interactiesysteem 95, alles 145.
- `config/version` → 0.0.15.

## v0.0.14 — 2026-07-28
**Debug-prompt: interactieprompt zichtbaar voor de visuele beoordeling**
- N.a.v. de terechte GD-vraag "de prompt staat op de bus, maar wie tekent
  hem?": taak 003 leverde bewust alleen het signaal (de echte HUD is
  fase 2/4), dus visueel was er niets te zien terwijl alles werkte.
- Nieuw `game/ui/debug_prompt/` (TD-006): label onderin beeld, alleen in
  debugbuilds, luistert uitsluitend naar `interact_prompt_changed`, geen
  eigen logica; de toets komt dynamisch uit de InputMap ("[E] Open deur" —
  rebinds volgen gratis). Suite 117 → 120; map-weg = alles blijft groen.
- `config/version` → 0.0.14.

## v0.0.13 — 2026-07-28
**Taak 003: interactiesysteem — contract, interactor en de eerste vier props**
- `game/systems/interaction/`: `Interactable`-contract (StaticBody3D-basis,
  `can_interact`/`interact`/`prompt_text`) + interactor die raycast vanaf de
  **actieve viewport-camera** — geen speler-, level- of propkennis (D-020).
  Prompt gaat letterlijk uit `prompt_text()` naar
  `EventBus.interact_prompt_changed`; harde eisen GD geborgd: geen
  typechecks op props, prompt volledig data-gedreven, toets-hint is
  UI-werk.
- `game/props/`: `door_wooden` (scharnier, op-slot met hoorbare rammel),
  `drawer_cabinet` (schuift, eenmalig `item_found`), `pickup_item`
  (`picked_up`, verdwijnt), `note_readable` (`document_opened` + GameState,
  bewust stil). Props hebben **geen class_name** — er bestaat geen type om
  op te checken. EventBus + `document_opened`-signaal.
- Dev room: `TestProps`-spawner plaatst de props alleen als hun scènes
  bestaan; bootstrap spawnt de interactor met bestaanscheck.
- **Smoke-suite 81 → 117**: volledige keten per prop (prompt → interact →
  eigen gedrag/geluid/signalen → prompt-verloop), wegkijken en
  niet-interactable. Verwijdereenheid = hele systeem (D-021): zonder = 82
  groen, zonder speler = 61 groen; halve verwijdering faalt bewust luid.
  Suite toetst het contract duck-typed — `is Interactable` in de suite zelf
  bleek een parse-time-afhankelijkheid die de D-015-run liet hangen.
- `config/version` → 0.0.13.

## v0.0.12 — 2026-07-28
**KI-003 opgelost: Escape pauzeert nu echt (spelwereld op PAUSABLE)**
- De bootstrap zette zichzelf op `PROCESS_MODE_ALWAYS`; kinderen erfden dat,
  waardoor `tree.paused` wél toggelde maar níéts pauzeerde — Esc leek dood
  en de muis kwam nooit vrij (geen `NOTIFICATION_PAUSED` bij de speler).
- Fix: `SceneHost` expliciet op `PROCESS_MODE_PAUSABLE`; de debug overlay
  blijft bewust ALWAYS (bruikbaar tijdens pauze).
- Smoke-suite 75 → 81: procesmodi structureel getoetst (ook zonder speler)
  én een functionele Esc-round-trip — pauzeert, speler staat stil, hervat,
  speler beweegt weer; muismodus-checks draaien alleen met echt scherm
  (headless kent geen muismodus). Zonder de fix falen deze tests aantoonbaar.
- `config/version` → 0.0.12.

## v0.0.11 — 2026-07-28
**Taak 002: player controller — lopen, sluipen, rennen, bukken**
- `game/actors/player/` (nieuw): `CharacterBody3D`-speler met vier gangmodi,
  acceleratie/deceleratie, muis-look zonder versnelling (gevoeligheid via
  `SettingsManager.mouse_sensitivity`), uitschakelbare head-bob
  (`head_bob_enabled`), buk-ooghoogte en voetstap-events: elke stap emit
  `EventBus.noise_made(positie, luidheid)` — luidheid per modus
  (sluipen 2 m / bukken 2.5 m / lopen 6 m / rennen 14 m). Alle tuning in
  export-groepen.
- **Ren-consequentie is geluid, geen stamina** (D-019); prioriteit bij
  tegelijk indrukken: bukken > sluipen > rennen.
- **Bootstrap spawnt de speler op een `PlayerSpawn`-marker** in het geladen
  level (D-018); de dev room heeft er een gekregen. Geen spelerscène of
  marker aanwezig = level draait gewoon zonder speler (D-015 geverifieerd).
- De spelerscamera neemt het beeld over; de testcamera van de dev room laat
  los zoals ontworpen (D-016). Esc-pauze geeft de muis vrij.
- **Smoke-suite 52 → 75 controles**, nu async: spelertests simuleren échte
  input per gangmodus en toetsen verplaatsing, event-emissie, luidheid,
  event-positie en buk-ooghoogte. Camera-controles aangepast op twee
  camera's; zonder spelersmap blijven alle 52 basiscontroles groen.
- `config/version` liep achter (0.0.4) en is gelijkgetrokken naar 0.0.11.
- Voetstap-guard: een timer-tick net ná het stoppen emit geen stap meer
  (geen voetstap in de stilte).

## v0.0.10 — 2026-07-27
**KI-002 opgelost: SunKey schijnt weer omlaag — taak 001 definitief dicht**
- `SunKey`-transform vervangen door de getransponeerde variant; lichtrichting
  van `(-0.62, +0.62, -0.49)` (omhoog, deed niets) naar `(0.38, -0.79, -0.49)`
  (boven-voor, zoals bedoeld in v0.0.7).
- Smoke-suite 51 → 52: DirectionalLights in de dev room moeten omlaag
  schijnen (`y < -0.2`); met de oude transform faalt de suite aantoonbaar.
- Kijkrichting-controle van de camera aangescherpt van `dot > 0.9` naar
  `> 0.99` (~8°), zodat de 9°-transponeerfout uit v0.0.8 voortaan ook
  gevangen wordt.
- Geen open issues meer; taak 001 is hiermee volledig afgerond.

## v0.0.9 — 2026-07-27
**project.godot genormaliseerd; regeleindes en projectintenties vastgelegd**
- De Godot-editor herschrijft `project.godot` bij het openen: eigen
  header-commentaar wordt vervangen door engine-boilerplate, en instellingen
  die gelijk zijn aan de engine-default worden weggelaten
  (`window/size/mode=0`, `physics_ticks_per_second=60`,
  `renderer/rendering_method="forward_plus"`). Functioneel verandert er niets
  — geverifieerd tegen de engine-defaults. Deze vorm is vanaf nu de canon;
  reverten had alleen tot een terugkerende diff geleid (D-017).
- **`.gitattributes` toegevoegd**: alle tekstbestanden LF in repo én werkmap,
  binaire assets uitgesloten van conversie. Voorkomt dat `core.autocrlf` op
  Windows ooit een hele `.tscn` als gewijzigd laat zien.
- **Smoke-suite 48 → 51 controles**: renderer (`forward_plus`), physics-ticks
  (60) en window-mode (`MODE_WINDOWED`) worden nu expliciet getoetst via
  `ProjectSettings`. Die keuzes stonden voorheen als documentatie in
  `project.godot`; nu ze impliciete defaults zijn, is de test de enige plek
  waar ze nog vastliggen.

## v0.0.8 — 2026-07-27
**Testcamera op ooghoogte + notatiefout in Transform3D blootgelegd**
- `TestCamera` van (0, 2.6, 9) met 9° kanteling naar **(0, 1.7, 9) horizontaal**:
  menselijk perspectief en een betere basis voor taak 002 (GD-besluit).
- Gemeten effect (headless, via `unproject_position`): lege achtergrond boven
  de muren van 60% → 45% van het beeld, vloer van 28% → 44%.
- **Bevinding**: de 12-float `Transform3D(...)`-notatie in een `.tscn` is
  **rij-georiënteerd** en dus getransponeerd t.o.v. de GDScript-constructor
  `Basis(x_as, y_as, z_as)`. De in v0.0.7 berekende transforms stonden
  daardoor gespiegeld: de camera keek 9° omhoog i.p.v. omlaag. De nieuwe
  camerabasis is de identiteit en is immuun voor deze fout.
- Zelfde oorzaak treft `Lighting/SunKey`, die nu omhoog schijnt → **KI-002**
  (open; wacht op akkoord van de Game Director, want fixen verandert het licht).

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
