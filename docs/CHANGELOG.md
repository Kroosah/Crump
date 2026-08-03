# CRUMP — Changelog

*Elke afgeronde taak of betekenisvolle wijziging krijgt een versienummer en
een korte omschrijving. Nieuwste bovenaan. **Verplicht bijwerken** bij elke
taak (zie CLAUDE.md).*

**Versienummering**: `v0.0.x` tijdens de fundering; `v0.x.0` per afgeronde
roadmap-fase; `v1.0.0` = release. Het nummer zegt niets over kwaliteit, alleen
over volgorde — het doel is dat je maanden later kunt terugvinden wanneer
iets veranderde en in welke commit.

---

## v0.0.24 — 2026-08-03
**Tier F3: bestuurskamer, hal en entree-buitenkant** *(VS-fase G, na GD-startsein op F2.1)*
- **Nieuwe verwijdereenheid `game/levels/clubgebouw/f3_detail/`**
  (zelfde D-015-contract als de F2-laag): map weg = tier F2.1-staat.
  437 onderdelen als datatabellen, gebouwd met de bewezen kitbash plus
  twee uitbreidingen: emissieve materialen (apparaat-LED's) en de
  regenlaag.
- **Bestuurskamer als hero room #2 (D-040)**: volledige inrichting —
  vergadertafel met zes ongelijke stoelen, bureau met jaren-negentig-
  computer, dossierkast met ordners, ladekast met printer, dressoir met
  archiefdozen en koffiezetapparaat met opgedroogde kan, sleutelkastje,
  wandtelefoon, historie-wand (verkleurde luchtfoto, oprichtingsakte,
  oude elftalfoto, kampioensvaan), whiteboard met half uitgewiste
  agenda, clubvlag en trainersjack over stoelleuningen. Het raam in de
  zuidgevel dat het artplan al impliceerde (§5.8: vensterbank) bestaat
  nu echt, met middenstijl en tussendorpel. Eén werkende TL uit het
  midden, zonder schaduwslot (D-041): lichtpool boven de tafel, de
  historie leeft in de schaduw.
- **Hal als transition space**: echt prikbord met gevuld kurkvlak,
  kapstokrail met dubbele haken en schoenenbank, radiator met
  vensterbank en te droge plant, half dichtgeschoven gordijn,
  brandslanghaspel, clublogo-deurmat met druppelsporen, stilstaande
  klok. Geen nieuwe lichtbronnen — de darkness hierarchy richting de
  gang is intact (renders 05/15).
- **Entree-buitenzijde**: betonplint en antraciet boeiboord rondom,
  zinken hemelwaterafvoeren met lekspoor, luifel-afwerking met hangende
  entreelamp, vlaggenmast zonder vlag, beugel-fietsenrek, kliko-hoek,
  hangslot aan de poortketting. Het clubnaambord verhuisde naar het
  boeiboord en wordt aangelicht — de eerste indruk van het sportpark.
- **Natte nacht (D-042)**: plassen als albedo+ORM-decals (glad waar
  water logisch samenkomt, droger onder de luifel), natte gevelvoet,
  onkruid in de naden; regen als twee GPU-particlevolumes plus drie
  verstemde 3D-audio-emitters — buiten vol, binnen zakt hij met de
  afstand weg.
- **Audio-micropass (D-043)**: het deurgeluid is nu een keten (klink,
  schoot, bladbeweging, zachte scharnierkraak, kozijnresonantie) uit
  `tools/genereer_f3_audio.gd`; 1-op-1 WAV-vervanging, geen code
  geraakt.
- **Materiaal-ijking**: tapijt naar naaldvilt (2,4/m, grijsblauw
  gedempt), nat asfalt donkerder.
- **2D-werk**: `tools/genereer_f3_textures.sh` (12 panelen, 6 decals).
- Testverwachtingen: TL-samenstelling 5/1/9, nieuw meetpunt
  bestuurskamer. Suite **251/251** groen; geometriecontrole gedraaid
  tegen de v0.0.23-baseline, alle echte fouten in de bron opgelost.
  Piek 248 draw calls / ~19k primitieven (buitenshot mét regen).

## v0.0.23 — 2026-08-01
**Geometrie- en materiaalintegriteit over het hele clubgebouw** *(vóór F3, op GD-opdracht)*
- **Nieuw gereedschap `tools/controleer_geometrie.gd`**: bouwt het level
  zoals het spel dat doet en trekt alle 584 zichtbare meshes na op
  kieren, samenvallende vlakken, verzonken panelen, doorstekende
  elementen, colliders die niet om hun mesh passen en materiaalfouten.
  Elke bevinding komt met coördinaat en maat, zodat hij terug te vinden
  is in de datatabellen.
- **Nieuw gereedschap `tools/maak_inspectie.gd`**: 50 vaste standpunten
  langs elke deuropening (van beide kanten), elk raam (binnen en buiten),
  alle vier de gevels, dakrand, terrein en de donkere ruimtes met én
  zonder zaklamp.
- **Bron 1 — een muur is één blok met één materiaal.** Daardoor stond
  het buitenmetselwerk óók in de toiletten, de onderhoudsruimte en langs
  de gang. Opgelost met een afgeleide binnenafwerking (`"binnen"` /
  `"buiten"` op een wandsegment): het level plakt zelf een 2 cm
  afwerkingslaag op de juiste zijde. De negen handgemaakte liners zijn
  verwijderd — die liepen per definitie achter op de tabellen.
- **Bron 2 — kozijnen waren met de hand ingetikt.** Alle 30 stijlen zijn
  vervangen door kozijnen die uit de deurtabel worden gerekend (D-038):
  het blad is 1,00 m, de opening 1,02 m, en het kozijn overlapt het blad
  nu altijd 4 mm. Dat sluit de 10 mm-spleet die om elke deur stond — een
  zichtbare naad én een lichtlek. Ramen kregen hetzelfde: zes
  raamkozijnen dekken de dagkant af, waar je eerst tegen het
  buitenmetselwerk aankeek.
- **Bron 3 — onderdelen raakten hun drager net niet.** Bankzittingen
  zweefden 5 mm boven hun schragen, kapstokhaken 5 mm van de rail,
  lockergrepen 2,5 mm van de deur, de entreeluifel 5 mm boven zijn
  staanders, elftalfoto's 7 mm van de wand, leidingbeugels 11 mm onder
  het plafond. Alles vastgezet met overlap in plaats van "net aan".
- **Verder opgelost**: de lichtschakelaar en het stopcontact zaten
  volledig ín de tegelband (onzichtbaar), poster en tactiekbord hingen
  17–22 mm van de wand, roosterlamellen zaten in de muur, de entreedeur
  hing 10 mm naast zijn eigen opening, hekpalen lagen exact in het vlak
  van het gaas (z-fighting), vloeren en plafonds liepen door tot in het
  buitenvlak van de gevel (z-fighting op de gevel), en de latei liep over
  de stijlen heen (z-fighting in elke kozijnhoek).
- **Noord- en oostgevel** stonden nog in greyboxgrijs; het hele gebouw
  heeft nu hetzelfde metselwerk met greybox-binnenafwerking.
- **Bouwerfout**: een cilinder kreeg een collider ter grootte van zijn
  straal in plaats van zijn doorsnede (afvalbak, emmer).
- Suite 250/250 groen, performance ongewijzigd (105 vs 104 draw calls in
  de kleedkamer). `config/version` → 0.0.23.

## v0.0.22 — 2026-08-01
**VS-fase G, tier F2.1: realism correction pass op de kleedkamer** *(gebouwd; wacht op art-direction-review)*
- **Grounding**: 30 nieuwe contactdecals (`ao_vlek`, `ao_lijn`) zetten
  bankpoten, kast, afvalbak, tas, radiator, leidingvoet, kozijnen,
  plint- en tegelrand en de wand/plafond-naden vast in hun omgeving.
  Geen zwarte AO-randen: alles blijft onder de helft van de
  dekkingsschaal.
- **Echte contactschaduw**: het derde schaduwslot is verhuisd van de
  kantinebar (buiten de demo-zone, nog greybox) naar de TL van
  kleedkamer 3 (D-036). Bank, kast, jack en losse spullen werpen nu
  schaduw; schaduwbudget onveranderd 3 + zaklampslot (D-026).
- **De TL is een lokale lichtbron**: nieuwe export `light_attenuation`
  op het TL-prop (default = engine-gedrag, dus geen enkele andere lamp
  verandert); kleedkamer 3 staat op energie 1,2 / bereik 3,9 /
  attenuatie 2,1 — pool onder de buis, zachte val naar de hoeken. En de
  buis hangt niet meer in het niets: aansluitdoos, buis naar de wand en
  twee beugels.
- **Materiaalbreukvlakken** (18 nieuwe decals, alleen kleedkamer 3):
  verfrolvariatie en een reparatieplek op de bovenwand, grauwsluier en
  ongelijk gepoetste velden op de tegels, drie grote vloerverkleuringen,
  roet rond de TL, en twee ORM-decals die het looppad *gladder* maken in
  plaats van donkerder (ruwheidsvariatie zonder kleurverandering).
- **Bank en kast minder "asset"**: banklatten om en om in twee tinten en
  ruwheden, matter gelakt hout, krasspoor over de zitting; de kast is
  donkerder, matter en minder metallisch — hij domineert het beeld niet
  meer.
- **Props alleen verplaatst, niet toegevoegd**: afvalbak scheef bij de
  hoek, handdoek schuin over de bank, flesje aan de rand, tas verder
  onder de bank gedraaid, jack schever aan zijn haak, tactiekbord een
  halve graad uit het lood. Nul nieuwe props behalve de TL-aansluiting
  en het achterblad van de poster (papier heeft dikte).
- **De gang is niet aangeraakt** — lichtcompositie, decoratie en
  materialen van de gang staan exact zoals in F2 goedgekeurd; de enige
  gedeelde wijziging (tegelnormaal 0,8) raakt geen gangoppervlak.
- Performance vrijwel gelijk (piek 104 vs 101 draw calls in de
  kleedkamer). Suite 250/250 groen, verwijderbaarheidstest opnieuw
  gedaan. `config/version` → 0.0.22.

## v0.0.21 — 2026-08-01
**VS-fase G, tier F2: kleedkamer 3 en de gang** *(gebouwd; wacht op art-direction-review)*
- **Kleedkamer 3 als hero room**: banken van latten op stalen schragen,
  kapstokrails met dubbele haken (incl. het vergeten trainingsjack),
  stalen lockers met een deurtje op een kier, radiator met leidingen en
  kraan, verwarmingsleiding in de hoek, lichtschakelaar, stopcontact,
  ventilatierooster, afvalbak, tactiekbord met stiftgoot, NVVB-poster,
  en schaars achtergelaten spullen (sok, handdoek, twee flesjes,
  scheenbeschermer, wedstrijdformulier, generieke sporttas — D-035).
- **Geometriedetail**: tegelrand op 1,40 m, plinten rondom, deurkozijn
  aan de kamerzijde, drempelstrips in beide doorgangen.
- **De gang als horrorbeeld**: plinten, leidingen alleen langs de
  noordzijde (asymmetrie), deurmatten, wachtbank, gestapelde stoelen als
  natuurlijke obstructie, doos aan het donkere westeinde, echte
  brandblusser met keuringskaartje, schoonmaaknis met emmer en mop,
  vier ingelijste elftalfoto's (geen echte gezichten).
- **Material breakup**: negen zelfgegenereerde decals
  (`tools/genereer_f2_textures.sh`) in 34 plaatsingen — vuilranden langs
  wandvoeten, looplijnen, schoenstrepen, vochtplekken, verfschade,
  krassen, veegsporen, kalk. Ze projecteren over álles, ook over de
  deuren.
- **Materialen op echte maat geijkt**: tegel 15 cm en baksteen 21 cm
  (tier F1 herhaalde te grof, waardoor elke ruimte te groot oogde),
  blauwzweem uit wanden en plafonds, granito in de gang, gladde
  plafondverf, mattere deuren, dieper clubblauw kozijn. Vijf nieuwe
  CC0-sets (ambientCG) via `tools/haal_cc0_textures.sh`.
- **Lokale lichtpass** (D-034): kleedkamer-TL wordt een echte lichtpool,
  westelijkste gang-TL defect — de gang loopt het donker in met alleen
  de groene gloed van het nooduitgangbord. SSAO aan voor contactschaduw.
  Schaduwbudget en 006-referentiewaarden onaangeraakt.
- **Architectuur**: alles in één verwijderbare eenheid
  `game/levels/clubgebouw/f2_detail/` (D-033, D-015-test gedaan: map weg
  = tier F1-staat, suite groen). Nieuwe TD-008 (geen instancing/LOD).
- **Renders**: 1600×900, zestien standpunten incl. de tien verplichte
  beelden en een zaklamp-equivalent; de rendermeters staan per beeld in
  de log (piek 152 draw calls, ~7k primitieven).
- Suite 250/250 groen (TL-verwachting bijgewerkt). `config/version` → 0.0.21.

## v0.0.20 — 2026-07-29
**VS-fase G, tier F1: de eerste grote visuele sprong** *(gebouwd; wacht op lokale GD-test)*
- **CC0-materialen** (13 PBR-sets, 1K; ambientCG + Poly Haven, met
  volledige herkomst in `assets/textures/LICENSE.md`, D-031) via een
  wereld-triplanaire materiaal-motor op de greybox: 56 vlakken in het
  demo-focusgebied omgezet (zeil, stucwerk, witgeschilderd metselwerk,
  systeemplafond, kleedkamercoating, witte wandtegel + grijze
  vloertegel, tapijt, gevelmetselwerk, nat asfalt).
- **Afwerkingslaag** (zonder collision): douches volledig betegeld,
  tegelbanden halfhoog in de kleedkamers, stuc-liners op
  gevel-binnenkanten, clubblauwe kozijnen rond negen deuren
  (nooddeur staal), lambrisering, kabelgoot.
- **Bewegwijzering**: tien gegenereerde borden (wit-op-clubblauw,
  `tools/genereer_bordjes.sh`), incl. clubnaambord buiten en emissief
  NOODUITGANG-bordje (geen Light3D — budget onaangetast).
- **Prop-artpass**: deuren in echt hardhout met RVS-krukken en
  tint-varianten (entree aluminium, nooddeur staal); TL-armaturen met
  metalen behuizing; de gang-flikkerbuis heeft een zwartgeblakerd
  uiteinde (zichtbare wereld-oorzaak).
- **Renderpijplijn op de VPS**: `tools/maak_screenshots.gd` maakt via
  software-Vulkan (lavapipe + xvfb) echte 1280×720-renders van elf
  standpunten — voor GD-review én eigen kwaliteitscontrole.
- **D-032**: de bestuurskamer blijft op slot (sleutel = demo-flow
  fase D) en is de beloning van de demo, die daar eindigt met de
  eerste CRUMP-ontmoeting (fase I); VS-deurtabel herzien.
- Architectuur, gameplay, routing, schaduwbudget en 006-tuning
  aantoonbaar ongewijzigd (suite 250 groen). `config/version` → 0.0.20.

## v0.0.19 — 2026-07-28
**VS-fase C: greybox clubgebouw — de eerste echte locatie** *(lokaal goedgekeurd door de GD, 2026-07-29: "de basis staat")*
- **`game/levels/clubgebouw/`**: het clubhuis onder de hoofdtribune van
  VV Drechtstreek, 's nachts. Twaalf ruimtes/zones op menselijke maat
  (plafonds 2,3–2,7 m): entree/hal, kantine met bar + doorgeefluik +
  meterkast, bestuurskamer en keuken (op slot, wereldgrenzen),
  kleedkamergang met flikkerbuis, kleedkamers 3+4 met banken/rails/
  lockers en open douches met koppen en afvoerputten, toiletten,
  schoonmaaknis, onderhoudsruimte, voorplein met luifel/fietsenrek/
  gaashek + dichte poort met ketting, pad langs het veld met boarding,
  veld dat in de fog oplost met één doel als silhouet, lichtmast 3.
  Dak met tribune-treden als silhouet. 214 volumes + 11 echte deuren +
  14 TL-armaturen (5 stabiel/1 flikkerend/8 defect; schaduw: bar +
  gang + mast = 3/3, zaklampslot vrij). Greybox als datatabellen
  (TD-007, bewust — aflossen in fase G); onderhoudsruimte in fase C
  bewust niet op slot (slot hoort bij de fase-D-sleutelflow).
- **Bootstrap**: normale runs starten in het clubgebouw; de suite
  draait op de dev room en wisselt aan het einde zelf voor de
  locatiecontroles (D-030). Testcamera-script gegeneraliseerd.
- **Suite 230 → 250**: nachtstaat, TL-samenstelling, budget, 11
  deurtoestanden, menselijke schaal via vloer-/plafondmetingen op 12
  punten, ambience-nulpunt. D-015: zonder clubgebouw 230 (terugval dev
  room). `config/version` → 0.0.19.

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
