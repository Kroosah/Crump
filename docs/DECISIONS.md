# CRUMP — Beslissingenlogboek (DECISIONS.md)

*Elke betekenisvolle beslissing wordt hier vastgelegd: wat, waarom, en wat het
alternatief was. Doel: nooit meer "waarom doen we dit ook alweer zo?" —
maanden later is de context er nog. **Verplicht bijhouden** bij elke taak
(zie CLAUDE.md).*

**Formaat**: oplopend genummerd, nieuwste onderaan. Een beslissing wordt nooit
verwijderd; wordt hij teruggedraaid, dan komt er een nieuwe beslissing die
daarnaar verwijst (status van de oude → *vervangen door D-xxx*).

| Veld | Betekenis |
|---|---|
| **Status** | actief · vervangen door D-xxx · heroverwegen bij <moment> |
| **Wie** | GD = Game Director (Randy) · TD = Technical Director (ChatGPT) · LD = Lead Developer (Claude) |

---

## D-001 — Engine: Godot 4.7.1 stable, official build
**Datum**: 2026-07-27 · **Wie**: GD/TD · **Status**: actief
Godot 4.7.1 als vaste engineversie tot na de release van hoofdstuk 1.
**Waarom**: gratis, open source, sterk in first person 3D, geen royalty's
richting Steam-release; versie vastpinnen voorkomt upgrade-verrassingen
middenin productie. **Alternatief**: Unity/Unreal — afgewezen om licenties,
zwaarte en leercurve t.o.v. de scope van dit project.

## D-002 — Headless ontwikkelen op de VPS, visueel beoordelen op de ontwikkelmachine
**Datum**: 2026-07-27 · **Wie**: GD/LD · **Status**: actief
De bouw-VPS heeft geen scherm; Godot draait er met `--headless` (import,
tests, validatie). Al het visuele/audio-oordeel gebeurt in de editor bij de
Game Director. **Waarom**: de VPS is de plek waar Claude werkt; headless is
sinds Godot 4 een volwaardige modus van dezelfde binary. **Consequentie**:
elke taak markeert expliciet wat "te beoordelen in de editor" is.

## D-003 — GDScript, geen C#
**Datum**: 2026-07-27 · **Wie**: TD · **Status**: actief
Eén taal voor het hele project. **Waarom**: laagste drempel, snel genoeg voor
dit genre, geen mono-runtime in de build. **Heroverwegen bij**: bewezen
performance-hotspot (dan gerichte GDExtension, geen taalwissel).

## D-004 — Renderer Forward+, doel 60 fps @ 1080p op GTX 1060-klasse
**Datum**: 2026-07-27 · **Wie**: TD · **Status**: actief
**Waarom**: desktop-only doelgroep en dynamisch licht als kernmechaniek;
het performance-doel is een ontwerpbeperking vooraf, geen naderhand-probleem.

## D-005 — Vier autoloads, niet meer (EventBus, GameState, AudioDirector, SaveManager)
**Datum**: 2026-07-27 · **Wie**: TD · **Status**: actief
**Waarom**: globale staat is waar onderhoudbaarheid sterft; elk nieuw
autoload-voorstel is een expliciete architectuurbeslissing (nieuwe D-entry).

## D-006 — Alles in tekstformaat (.tscn/.tres/.gd), main altijd importeerbaar
**Datum**: 2026-07-27 · **Wie**: TD/LD · **Status**: actief
**Waarom**: leesbare diffs en reviewbare wijzigingen zijn de basis van
AI-gedreven ontwikkeling; een kapotte main blokkeert elke volgende sessie.

## D-007 — Visie-herziening: naamloze hoofdpersoon, voetbalclub-opening, CRUMP als mysterie
**Datum**: 2026-07-27 · **Wie**: GD · **Status**: actief
De speler ís de naamloze hoofdpersoon; de game opent na een wedstrijd bij
VV Drechtstreek (Sportpark Oostpolder) met de verdwijning-uit-de-kantine;
CRUMP is geen locatie/club maar het mysterie én de latere dreiging; de eerste
15 minuten bevatten geen monster/achtervolging/jumpscares. **Vervangt** de
oorspronkelijke nachtdienst-premisse uit de eerste documentatieversie.
Volledig doorgevoerd in alle documenten (commit `dd76e69`).

## D-008 — Rolverdeling en ontwikkelregels
**Datum**: 2026-07-27 · **Wie**: GD · **Status**: actief
Game Director (Randy) beslist creatief en geeft opdrachten; Technical
Director (ChatGPT) adviseert architectuur/strategie; Lead Developer (Claude)
voert per opdracht exact één taak uit volgens de documentatie. Tien bindende
regels vastgelegd in CLAUDE.md.

## D-009 — Projectmap hernoemd naar `crump`
**Datum**: 2026-07-27 · **Wie**: GD · **Status**: actief
`~/projects/nachtdienst` → `~/projects/crump`, vóór taak 001 zodat er nog
geen paden in Godot-config stonden. **Waarom**: mapnaam was een restant van
de vervangen premisse.

## D-010 — Studio-administratie verplicht (DECISIONS/CHANGELOG/KNOWN_ISSUES/TECH_DEBT)
**Datum**: 2026-07-27 · **Wie**: GD (op advies TD) · **Status**: actief
Vier levende documenten die bij elke taak worden bijgewerkt; onderdeel van de
Definitie van "af" in CLAUDE.md. **Waarom**: beslissingen, wijzigingen, bugs
en tijdelijke oplossingen mogen nooit alleen in gespreksgeschiedenis leven.

## D-011 — SettingsManager als vijfde autoload, los van GameState
**Datum**: 2026-07-27 · **Wie**: GD (richting) / LD (uitvoering) · **Status**: actief · **wijzigt D-005**
Instellingen bestaan onafhankelijk van een actieve spelsessie (hoofdmenu
heeft ze al nodig, een nieuw spel mag ze niet resetten) en staan daarom in
een eigen autoload, niet in GameState. D-005 ("vier autoloads") is hiermee
bijgesteld naar **vijf**; de lat voor een zesde blijft even hoog.

## D-012 — Log als statische klasse, geen autoload
**Datum**: 2026-07-27 · **Wie**: LD · **Status**: actief
`Log` (game/systems/log.gd) heeft geen node-lifecycle nodig; een statische
klasse houdt het autoload-aantal klein en werkt overal, ook in resources en
statische context. Console + user://logs/ met rotatie (max 5), flush per
regel. **Alternatief**: autoload-node — afgewezen als onnodige globale staat.

## D-013 — Testrunner: eigen smoke-suite in het spel, geen plugin
**Datum**: 2026-07-27 · **Wie**: GD (kader: geen externe plugin) / LD · **Status**: actief
Tests draaien in het échte spel: `godot --headless --path . -- --smoke-test`
laat de bootstrap `tests/smoke_test.gd` uitvoeren; exitcode 0/1. **Waarom**:
autoloads en projectconfig worden zo mét het spel getest (geen aparte
MainLoop-context), nul dependencies, CI-klaar. **Heroverwegen bij**: behoefte
aan echte unit-test-isolatie (dan GUT of de ingebouwde runner alsnog wegen).

## D-015 — Modulariteit als harde eis: elke feature volledig verwijderbaar
**Datum**: 2026-07-27 · **Wie**: GD · **Status**: actief
Elke nieuwe feature moet uit het project te verwijderen zijn zonder de rest
te breken; gameplay-systemen mogen geen onderlinge afhankelijkheden hebben.
**Waarom**: houdt het project jarenlang wendbaar — features kunnen sneuvelen
na een playtest zonder sloopwerk, en systemen blijven los testbaar.
**Hoe geborgd**: ARCHITECTURE §4a (de verwijderbaarheidstest + zes regels),
CLAUDE.md ontwikkelregel 11, en een toets per taak. De EventBus is hiervoor
het centrale mechanisme: signalen zijn feiten zonder verplichte ontvanger.
**Consequentie**: geen directe cross-systeem-verwijzingen meer, ook niet
"heel even" — een tijdelijke koppeling is een TECH_DEBT-entry of niet.

## D-014 — Grafische presets met DEVELOPMENT_LOW als dev-default
**Datum**: 2026-07-27 · **Wie**: GD (aanleiding: zwakkere dev-pc) / LD · **Status**: actief
Vijf presets (DEVELOPMENT_LOW/LOW/MEDIUM/HIGH/ULTRA) die renderschaal, MSAA
en schaduw-atlas runtime zetten. Dev-default = DEVELOPMENT_LOW zodat de
Game Director soepel kan testen; de game moet op HIGH/ULTRA kunnen draaien
en het release-default wordt in fase 6 bepaald (TD-002).

## D-016 — De developer room heeft een eigen testcamera die opzij stapt
**Datum**: 2026-07-27 · **Wie**: LD (bugfix KI-001) · **Status**: actief
De dev room bevat een vaste `TestCamera` met `dev_camera.gd`. Zonder camera
rendert Godot niets en toont de viewport de default clear color — een egaal
grijs scherm dat als kapotte render gelezen wordt (KI-001). **Waarom in de
dev room en niet in de bootstrap**: de ruimte moet los in de editor te openen
en te beoordelen zijn (LEVEL_GUIDELINES §7), en de bootstrap moet levels
kunnen laden zonder aannames over hun inhoud. **Waarom hij opzij stapt**: een
ontwikkelhulpmiddel mag gameplay nooit overschrijven — zodra er een echte
camera het beeld heeft (de spelerscamera uit taak 002) laat de testcamera los
en logt dat. Springt hij bij (geen enkele camera actief), dan is dat een
`warn`, want dan is er iets mis in de scèneopbouw. **Consequentie**: elk
volgend level krijgt óf een eigen camera óf een speler; "geen camera" is
vanaf nu een testfout in plaats van een raadsel.

## D-017 — Godot's vorm van project.godot is de canon; intenties borgen we in tests
**Datum**: 2026-07-27 · **Wie**: GD (besluit) / LD (onderzoek) · **Status**: actief
De Godot-editor herschrijft `project.godot` bij het openen: hij vervangt het
header-commentaar door zijn eigen boilerplate en laat elke instelling weg die
gelijk is aan de engine-default. We nemen die vorm over in plaats van hem
terug te draaien. **Waarom**: reverten levert dezelfde diff op bij élke keer
dat het project geopend wordt, en wie went aan ruis in `git status` ziet een
échte wijziging (een omgevallen renderer bijvoorbeeld) een keer over het hoofd.
**Prijs**: `renderer/rendering_method="forward_plus"`, `physics_ticks_per_second=60`
en `window/size/mode=0` stonden er als bewuste keuze uit taak 001 en zijn nu
impliciet. Ze terugzetten werkt niet — Godot strijkt ze bij de volgende save
weer weg. **Daarom**: die intenties zijn verplaatst naar de smoke-suite, die
ze via `ProjectSettings` toetst. Verandert een toekomstige Godot-versie een
default, dan valt de test om in plaats van dat het project stilzwijgend
meebeweegt. **Regel hieruit**: een projectinstelling die bewust op de
engine-default staat, hoort in een test — niet in een comment.
**Gerelateerd**: `.gitattributes` dwingt LF af op alle tekstbestanden, zodat
`core.autocrlf` op Windows nooit een hele `.tscn` als gewijzigd kan tonen.

## D-018 — Spelers komen een level binnen via een PlayerSpawn-marker
**Datum**: 2026-07-28 · **Wie**: GD (keuze uit voorgelegde opties) / LD · **Status**: actief
De speler zit niet ín een level-scène; de bootstrap instantieert
`player.tscn` en zet hem op de `Marker3D` genaamd `PlayerSpawn` van het
geladen level. Ontbreekt de spelerscène (map verwijderd, D-015) of de marker,
dan draait het level zonder speler door en springt de testcamera bij (D-016).
**Waarom**: het level kent de speler niet en de speler kent het level niet —
de verwijderbaarheidstest blijft in beide richtingen groen, en elk toekomstig
hoofdstuk hoeft alleen een marker neer te zetten. **Alternatieven**: speler
als instantie in de level-scène (koppelt level aan speler — afgewezen) of
speler alleen in de smoke-test (niet rondlopen in de editor — afgewezen).

## D-019 — De consequentie van rennen is geluid, geen uithoudingsvermogen
**Datum**: 2026-07-28 · **Wie**: GD (keuze uit voorgelegde opties) / LD · **Status**: heroverwegen bij taak 009
GAME_BIBLE §5 noemt rennen "kort, hoorbaar, met consequentie". In taak 002 is
die consequentie uitsluitend akoestisch: rennen draagt 14 m op de EventBus
(lopen 6, sluipen 2) met een sneller stapritme — wie rent, roept CRUMP.
**Waarom**: sluit direct aan op pijler 1 ("stilte is het instrument") en
houdt taak 002 vrij van een stamina-systeem dat pas betekenis krijgt als er
iets is dat je hoort (009). **Heroverwegen**: als playtests uitwijzen dat
onbeperkt rennen de spanning breekt, is een uithoud-systeem een eigen taak.

## D-020 — De interactor gebruikt de actieve viewport-camera, niet "de speler"
**Datum**: 2026-07-28 · **Wie**: LD (binnen GD-kaders van 2026-07-28) · **Status**: actief
De interactor raycast vanaf `get_viewport().get_camera_3d()` — wie er ook
kijkt. Hij kent geen speler, geen level en geen proptypes; zijn enige
wereldkennis is het `Interactable`-contract, en de prompt is letterlijk wat
`prompt_text()` teruggeeft (harde eisen GD: geen typechecks, prompt volledig
data-gedreven; de toets-hint komt later in de UI-laag uit de InputMap).
**Waarom**: nul koppelingen — speler weg betekent interactor idle, niet
kapot; en het werkt met elke toekomstige camera (cutscene, debug).
**Consequentie**: props staan op layer wereld+interactable zodat één ray
(eerste hit telt) occlusie gratis meeneemt en de speler er niet doorheen
loopt. De bootstrap spawnt de interactor met bestaanscheck (patroon D-018).

## D-021 — Verwijdereenheid van een feature: het systeem als geheel, half is stuk
**Datum**: 2026-07-28 · **Wie**: LD (uitwerking van D-015) · **Status**: actief
De D-015-verwijdertest voor het interactiesysteem geldt voor de hele
feature: contract + interactor + props sámen. Alles weg → suite groen, spel
draait. Een hálve verwijdering (props weg, interactor aanwezig) faalt de
suite bewust luid — dat is geen ontbreken maar een kapotte tussentoestand,
en die stil laten passeren zou een echte regressie (per ongeluk verwijderde
prop) onvindbaar maken. **Les daarbij**: testcode noemt global classes van
verwijderbare systemen nooit bij naam — `is Interactable` in de suite was
een parse-time-afhankelijkheid waardoor de suite zélf niet meer laadde
zonder het systeem; contracten in tests toets je duck-typed
(`has_method(...)`).

## D-022 — Oppakken is een verzoek-antwoord op de bus; één autoritatieve inventory
**Datum**: 2026-07-28 · **Wie**: GD (ontwerp-review) / LD · **Status**: actief
Vier bus-signalen met uitsluitend basistypen (D-021):
`item_pickup_requested(source: Node, item: Resource)`,
`item_pickup_resolved(source: Node, accepted: bool)`,
`item_added(item: Resource)`, `item_removed(item: Resource)`. `source` is
een opaak token dat de inventory alleen terug-echoot; een prop verdwijnt
uitsluitend na een geldige accepted-response binnen zijn eigen synchrone
verzoekvenster en bezit zijn eigen feedback. **Waarom**: dit is de enige
vorm die "verdwijnt pas na bevestiging" én D-015 tegelijk waarmaakt —
zonder inventory blijft een verzoek onbeantwoord en het object liggen.
Maximaal één autoritatieve inventory: alleen de eerste node in groep
`inventory` verbindt zich met de bus (bootstrap-guard + zelfcheck + test).
**Let op**: deze signaturen zijn een geconsumeerd contract — wijzigen is
vanaf nu een breaking change met eigen D-entry.

## D-023 — Geen stacking; capaciteit is een klein getal (6)
**Datum**: 2026-07-28 · **Wie**: GD (ontwerp-review) / LD · **Status**: actief · **heroverwegen bij**: het eerste item waarvan aantallen betekenis hebben
Elk item is een betekenisvol individueel object (GAME_BIBLE §8); er is geen
consumable-economie, dus stacken zou alleen save-, UI- en testcomplexiteit
toevoegen. Dezelfde item-id mag wél meerdere slots innemen (twee
batterijen); twee verschillende .tres-definities met dezelfde id zijn een
configuratiefout die de suite afvangt. **Terugweg**: een `max_stack`-veld
op ItemResource (default 1) + telling — additief, geen breuk in model of
bus. `ItemResource` is runtime read-only configuratiedata: niemand muteert
de velden, de inventory bewaart alleen referenties.

## D-024 — Hoorbare audio: eigen bus-feit, eigen verwijderbaar systeem, id's als grensvaluta
**Datum**: 2026-07-28 · **Wie**: GD (ontwerp-review, 2 rondes) / LD · **Status**: actief
`audio_cue(sound_id: StringName, position: Vector3)` is het hoorbare feit
op de bus, strikt gescheiden van `noise_made` (gameplay-gehoor): geen van
beide veroorzaakt ooit automatisch de ander; bronnen zenden bewust beide
voor dezelfde actie. Het afspelen leeft in `game/systems/audio/`
(resolver + one-shot-pool + ambience + muziek-API) — **AudioDirector
blijft de dunne mixer** en groeit niet (God-Object-besluit). Id's zijn de
grensvaluta (keuze B2): props/speler dragen alleen StringNames, alle
akoestiek leeft in SoundResources binnen het systeem. Ambience staat
standaard uit (levels activeren expliciet); muziek heeft alleen de
minimale API zonder triggers; kader §8: geen geluid bestaat uitsluitend
als opvulling. **Let op**: de `audio_cue`-signatuur is vanaf nu een
geconsumeerd contract (zelfde regime als D-022). Reverb/ruimte-akoestiek
komt later als eigen systeem (dossier 005 §12), nooit in AudioDirector.

## D-025 — De zaklamp is betrouwbaar en bezit is een gesloten-falende projectie
**Datum**: 2026-07-28 · **Wie**: GD (ontwerp-review, 3 rondes) / LD · **Status**: actief
De zaklamp hapert nooit willekeurig: HORROR §7 belooft betrouwbaar
gereedschap en P7 legt de twijfel in de wéreld — het oude scope-punt
"subtiele flikker" is verworpen; een ooit falende zaklamp wordt een
ontworpen gebeurtenis met eigen ontwerpronde. Alleen de zaklampcomponent
bezit de aan/uit-state. Een geslaagde toggle zendt drie gescheiden feiten
ná de statewijziging, exact één per kanaal: `flashlight_toggled(is_on)`
(toestand, geconsumeerd contract vanaf 009), `audio_cue` en `noise_made`
op de semantische spelerpositie (licht volgt de camera; geluid de
body-origin). Bezit faalt gesloten: geen inventory of geen zaklamp-item =
geen state, geen licht, geen enkele emissie — een ontbrekend systeem
levert nooit gratis bezit op. De projectie is eventgedreven
(`item_added`/`item_removed` → `has_item`-hercontrole aan de bron, geen
eigen telling, geen polling); verdwijnt het laatste exemplaar terwijl de
lamp aan is, dan gaat hij direct uit met alléén `flashlight_toggled(false)`
(geen klik — geen spelershandeling). `debug_bezit_bypass`: default uit,
alleen debugbuilds, nooit in gecommitte scènes.

## D-026 — Schaduwbudget: 4 totaal, waarvan 1 gereserveerd zaklampslot
**Datum**: 2026-07-28 · **Wie**: GD (ontwerp-review) / LD · **Status**: actief
Maximaal 4 realtime schaduw-werpende lichten tegelijk; levels ontwerpen op
3 — het vierde slot is van de zaklamp en degradeert nooit. Handhaving in
drie lagen: de suite laat een configfout niet op main (telling ≤ 3);
`game/systems/light_budget/` (eigen verwijdereenheid, bewust géén
framework) geeft runtime één warning per overtollige lamp en degradeert
deterministisch op scene-boomvolgorde (eerste 3 behouden schaduw, de rest
verliest alléén `shadow_enabled` — de lamp blijft aan); F3 toont de
telling. Er bestaat geen dynamische licht-spawning in 006.

## D-027 — Brightness: smalle compensatierange 0.8–1.2 op adjustment_brightness
**Datum**: 2026-07-28 · **Wie**: GD (ontwerp-review) / LD · **Status**: actief
Het spel wordt gekalibreerd op 1.0; de slider compenseert schermen, nooit
lichtontwerp. De oude 0.5–2.0-clamp stamde van vóór het moment dat
brightness ergens op aangreep (TD-003) en is vervangen: ×2.0 zou het
near-black naar een dagbeeld tillen, ×0.5 breekt de contour-garantie.
Waarden buiten de range (ook uit een oude settings.cfg) worden stil
geclampt. Aangrijpingspunt is uitsluitend `adjustment_brightness` op de
level-Environment (via `environment_tuner`, `brightness_changed`-signaal):
CanvasLayer-UI, lampenergieën en het schaduwbudget blijven onaangeraakt.
Afwijken van de range is een nieuw GD-besluit.

## D-028 — Canonieke openingspremisse: de vergeten sporttas
**Datum**: 2026-07-28 · **Wie**: GD (creatieve review VS-ontwerp) · **Status**: actief
De speler keert na een belangrijke avondwedstrijd terug naar het
verlaten, regenachtige stadion omdat zijn sporttas nog in de kleedkamer
hangt — **met zijn telefoon en autosleutels erin**. Dit vervangt het
eerdere afsluitverzoek van de barman (en de gespeelde
verdwijning-tijdens-het-douchen) als canonieke opening. **Waarom**: de
tas maakt elke stap het gebouw in een redelijke menselijke beslissing
(P6), de ingesloten telefoon verklaart diegetisch waarom de speler
niemand kan bereiken (P1), en de terugkeer-structuur laat het "normaal"
via herkenning werken zonder verplichte proloogscène. Of "de derde
helft" ooit als speelbare proloog wordt gebouwd, blijft open (STORY §8).
Uitsluitend de direct rakende passages zijn gecorrigeerd (STORY
§1/§3/§6/§8/§9, GAME_BIBLE §1/§7, HORROR §7, LEVEL §3, ROADMAP fase 4,
canon-notitie in tasks/010) — géén brede lore-herschrijving; de
uitgewerkte eerste ±20 minuten staan in tasks/008_vertical_slice_01.md.
In hetzelfde besluit is de taaknummering herzien: 007 = minimale
documentlezer, 008 = Vertical Slice 0.1, 009 = monster-AI (was 007),
010 = hoofdstuk 1 (was 008).

## D-029 — document_opened draagt de titel; lezen pauzeert via deferred arming
**Datum**: 2026-07-28 · **Wie**: GD (ontwerp-review 007, 2 rondes) / LD · **Status**: actief
`document_opened(document_id: StringName, title: String, text: String)`
— eenmalig gecorrigeerd van 2 naar 3 argumenten vóór de eerste
productieconsumer bestond; vanaf nu geconsumeerd contract
(D-022-regime). De titel reist mee als basistype: geen register, lookup
of documentdatabase, en de reader kent geen prop- of resource-klassen
(D-021). Data leeft als runtime read-only `DocumentResource` bíj de
prop; validatie aan de bron (lege id/tekst = warning, geen feit, geen
GameState-mutatie) en defensief herhaald in de reader. Modaal gedrag:
lezen pauzeert de wereld via het bestaande pauzemechanisme (polling-
input is niet met handled-events te stoppen), met expliciet ownership
(statusopname vóór de eerste opening; herstel idempotent, exact één
keer, alleen eigen wijzigingen — een vooraf gepauzeerde boom blijft
gepauzeerd). Zelfde-inputevent-bescherming via **deferred arming**
(OPEN_ONGEWAPEND → `call_deferred` → OPEN_GEWAPEND): deterministisch op
engine-volgorde, geen timers; sluit-input wordt in `_input` opgegeten
zodat één Esc nooit tegelijk document én pauzemenu bedient. Dit
arming+ownership-patroon is de standaard voor elke latere modale UI
(pauzemenu, inventory-UI).

## D-030 — Startlevel gesplitst: clubgebouw voor het spel, dev room voor de suite
**Datum**: 2026-07-28 · **Wie**: LD (uitvoering VS-fase C) · **Status**: actief
Normale runs starten in `game/levels/clubgebouw/` (de eerste echte
locatie); de smoke-suite draait op de dev room — die blijft de
testruimte met de vaste meetpunten van taken 001–007 — en wisselt aan
het éínde zelf via de echte `_load_level`-route naar het clubgebouw
voor de locatiecontroles (schaal, staten, budget, deuren). **Waarom**:
de suite-meetpunten slopen en herbouwen op elke levelwijziging zou de
tests aan het leveldesign klinken; zo test één run beide werelden én de
levelwissel zelf. Bestaanscheck beide kanten op (D-015): zonder
clubgebouw valt het spel terug op de dev room.

## D-031 — Artpass-besluiten: clubkleuren, CC0-bronnen, silhouet-rig, demo-focusgebied
**Datum**: 2026-07-29 · **Wie**: GD (review fase F-artplan) · **Status**: actief
Vier bindende besluiten bij het goedgekeurde art-direction-plan
(tasks/008_artdirection.md v1.1): **(1)** de clubkleuren van VV
Drechtstreek zijn **blauw-wit** (canon; rood blijft gereserveerd als
signaalkleur). **(2)** **Poly Haven en ambientCG (CC0)** zijn de
toegestane assetbibliotheken; licenties komen per bron mee in de repo
(CLAUDE.md-akkoord hiermee verleend; andere bronnen vergen nieuw
akkoord). **(3)** CRUMP krijgt voorlopig een **tijdelijk silhouet-rig**
als glimp-representatie; het definitieve ontwerp volgt in een eigen
GD-sessie vóór VS-fase I. **(4)** De demo is **niet** de volledige
route op één kwaliteitsniveau maar een **extreem hoogwaardig
focusgebied** — entree, hal, gang (verbinder), kleedkamers 3+4,
douches en bestuurskamer — dat eerst volledig áf moet voelen (gate)
voordat de rest tier-gewijs volgt. Consequentie: de bestuurskamer
wordt betreedbaar (deur van het slot) en ingericht; de VS-deurtabel
(tasks/008 §3) wordt daarop bij fase D herijkt.

## D-032 — De bestuurskamer is de beloning van de demo (op slot achter de sleutel)
**Datum**: 2026-07-29 · **Wie**: GD (startsein fase G) · **Status**: actief
Wijziging op de v1.1-consequentie van het artplan (deur zou van het
slot): de bestuurskamer **blijft tijdens de demo op slot**; de speler
bereikt haar pas nadat de sleutel is gevonden. De ruimte wordt volledig
uitgewerkt (artplan §5.8) en vormt de beloning van de demo, die daar
eindigt met de **eerste ontmoeting met CRUMP** (representatie: het
tijdelijke silhouet-rig, D-031; de ontmoeting zelf is fase I-werk).
Consequenties: de VS-deurtabel (tasks/008 §3) is herzien
(bestuurskamer: op slot → sleutel); de demo-flow van fase D werkt de
sleutelroute uit en herijkt daarbij de slotbeats van de slice (de
buitenglimp bij mast 3 en de ketting uit tasks/008 §4) op dit nieuwe
einde — dat is een fase-D-ontwerpbeslissing, niet iets dat de artpass
nu vastlegt.

## D-033 — De F2-artpass is een losse detaillaag naast de greybox, geen herbouw
**Datum**: 2026-08-01 · **Wie**: Lead Developer (uitvoering GD-brief F2) · **Status**: actief
Tier F2 kleedt kleedkamer 3 en de gang aan vanuit één verwijderbare
eenheid (`game/levels/clubgebouw/f2_detail/`) met een eigen
kitbash-bouwer (box/cilinder/bol/torus/vlak, rotatie, decals) in plaats
van de F1-greybox te herschrijven. Reden: de goedgekeurde maatvoering
mag niet bewegen (artplan §2.6), de artpass moet in één map te
verwijderen zijn (D-015) en elke prop blijft één tabelregel — dus
GD-correcties blijven één getal. De vijf F1-volumes die door echte
props worden vervangen (twee banken, twee rails, lockers,
brandblusser) dragen in `clubgebouw.gd` de vlag `"f2"`; is de map weg,
dan bouwt het level ze gewoon zelf weer. Consequentie: TD-007 wordt
hiermee **niet** afgelost — beide lagen blijven datatabellen; de
omzetting naar ruimte-scènes verschuift naar het moment dat de GD de
demo-zone visueel áf verklaart (F4-gate).

## D-034 — Het westeinde van de gang is donker: de gang is het horrorbeeld
**Datum**: 2026-08-01 · **Wie**: Lead Developer (uitvoering GD-brief F2 §3/§4) · **Status**: actief
De westelijkste gang-TL is defect gezet (nachtverdeling wordt 4
stabiel / 1 flikkerend / 9 defect; de suite toetst die verdeling) en de
kleedkamer-TL is teruggebracht tot een echte lichtpool (energie 1,0 /
bereik 4,8). Daardoor loopt de gang letterlijk het donker in, met als
enige rest de groene gloed van het nooduitgangbord — een lamp zonder
schaduw, dus het schaduwbudget (D-026, 3 + zaklampslot) blijft
onaangeraakt. SSAO staat aan voor contactschaduw. Dit is bewust een
**lokale** pass: de volledige lighting phase blijft een eigen fase, en
de 006-referentiewaarden (ambient, fog, tonemap) zijn niet aangeraakt.

## D-035 — De sporttas in kleedkamer 3 is aankleding, niet de premisse-tas
**Datum**: 2026-08-01 · **Wie**: Lead Developer (signalering aan GD) · **Status**: actief
De GD-brief vraagt om een sporttas als aankleding; de canon (D-028)
maakt de **vergeten sporttas** juist de openingspremisse en daarmee een
fase-D-gameplayprop. Gekozen: onder de westbank ligt een neutrale,
generieke tas (grijsgroen, geen clubkleur, geen interactie) puur als
bewijs van gebruik; de premisse-tas blijft ongebouwd tot fase D en
krijgt daar zijn eigen plek en materiaal. Als de GD ook die
dubbelzinnigheid niet wil, is de tas één tabelregel verwijderen.

## D-036 — Het derde schaduwslot hoort in de hero room, niet in de kantine
**Datum**: 2026-08-01 · **Wie**: Lead Developer (uitvoering GD-brief F2.1 §3) · **Status**: actief
De GD-review van F2 wees grounding aan als belangrijkste bron van de
CG-look. Het schaduwbudget (D-026) staat vast op drie level-lampen plus
het zaklampslot, en die drie waren: kantinebar, gang-oost, lichtmast.
De kantine ligt buiten de demo-zone en is nog greybox — daar kost een
schaduw niets op en levert hij niets op. Het slot is daarom verhuisd
naar de TL van kleedkamer 3, waar bankpoten, kast, jack en losse
spullen zichtbaar contact met de ruimte krijgen. Budget, telling en
suite-controle blijven ongewijzigd. Aanvullend, want schaduw alleen is
niet genoeg: contactvlekken als decals onder en achter elk meubel —
dat is geen schaduw maar het vuil-en-occlusierandje dat elk gebruikt
object heeft, en het werkt ook waar geen lamp schijnt.

## D-037 — Realism-polish gaat via decals en materiaalrespons, niet via geometrie
**Datum**: 2026-08-01 · **Wie**: Lead Developer (uitvoering GD-brief F2.1) · **Status**: actief
De F2.1-opdracht vroeg om minder CG-look zonder prop-pass en zonder
bevel-pass. Gekozen middel: (1) decals voor alles wat "gebruikt" moet
lezen — verfvariatie, reparatieplekken, tegelvuil, vloerverkleuring,
roet, contactvlekken; (2) ORM-decals voor ruwheidsvariatie, zodat een
looppad glánzender wordt in plaats van donkerder; (3) materiaalrespons
(ruwheid, metallic, twee tinten voor dezelfde banklatten). Geen extra
polygonen, geen randafschuiningen, geen nieuwe props. Reden: decals
kosten vrijwel niets, zijn per stuk één tabelregel en zijn daarmee net
zo makkelijk terug te draaien als bij te stellen — precies wat een
polish-ronde nodig heeft die nog een paar keer langs de GD gaat.

## D-038 — Afgeleide geometrie: kozijnen en binnenafwerking komen uit de data, niet uit de hand
**Datum**: 2026-08-01 · **Wie**: Lead Developer (opdracht GD: integriteitspass) · **Status**: actief
De GD trof zichtbare bouwfouten aan binnen én buiten. De oorzaak was
niet één fout object maar twee gewoontes: (1) een wand is één blok met
één materiaal, dus het buitenmetselwerk stond ook binnen, en dat werd
per ruimte met de hand bijgeplakt; (2) kozijnen, strips en lijsten
werden met de hand uitgerekend, waardoor ze millimeters naast hun
drager stonden. Besluit: alles wat **uit iets anders volgt** wordt
voortaan **afgeleid**. Concreet: een wandsegment krijgt zijn
binnenafwerking via `"binnen"`/`"buiten"`; deurkozijnen worden gerekend
uit scharnier, bladmaat en draairichting; raamkozijnen uit het
glaspaneel. Handmatige varianten zijn verwijderd, niet toegevoegd.
Regel voor de toekomst: hangt een element aan een ander element, dan
overlapt het dat met een vaste marge (`KOZIJN_OVERLAP`, 4 mm) — nooit
"precies aanliggend", want dan is de eerstvolgende maatwijziging weer
een kier.

## D-039 — Geometriecontrole is een vaste stap, geen eenmalige actie
**Datum**: 2026-08-01 · **Wie**: Lead Developer · **Status**: actief
`tools/controleer_geometrie.gd` blijft in de repo en hoort bij de
oplevering van elke bouwtaak, naast import en smoke-test (opgenomen in
QA_CHECKLIST). De tool meldt kieren, samenvallende vlakken, verzonken
en doorstekende panelen, verkeerde colliders en materiaalfouten mét
coördinaat. Hij is bewust een **triage-instrument** en geen orakel: hij
kan niet zien of een vlak zichtbaar is, dus bouwnaden onder de vloer en
hoekaansluitingen van panelen blijven als melding staan (TD-009). De
regel is: het aantal bevindingen mag na een taak niet stijgen, en elke
nieuwe melding wordt beoordeeld — niet weggeklikt.

## D-040 — De F3-laag is een eigen verwijdereenheid, en de bestuurskamer krijgt haar raam
**Datum**: 2026-08-03 · **Wie**: Lead Developer (op GD-startsein F3) · **Status**: actief
Tier F3 (bestuurskamer, hal, entree-buitenkant) leeft in
`game/levels/clubgebouw/f3_detail/`, naast en gelijkwaardig aan de
F2-laag: map weg = tier F2.1-staat, de `"f3"`-vlag in de leveltabellen
is de enige koppeling (D-015). Nieuw ten opzichte van de F2-bouwer:
emissieve materialen (apparaat-LED's — puur emissief, nooit een
Light3D) en de regenlaag. Verder is de zuidgevel gesplitst voor een
**bestuurskamerraam** volgens het kantinepatroon: het goedgekeurde
artplan gaf de kamer al een vensterbank (§5.8), dus het raam bestond
op papier — de gevel liep alleen achter. Kozijn uit de glastabel
(D-038), middenstijl en tussendorpel omdat een vlak van 1,4 m glas in
Nederland niet bestaat.

## D-041 — De bestuurskamer-TL werkt zonder schaduwslot; contrast komt uit de val van het licht
**Datum**: 2026-08-03 · **Wie**: Lead Developer · **Status**: actief
Hero room #2 heeft één werkende TL nodig (F3-brief §4), maar alle drie
de schaduwsloten zijn vergeven (gang, kleedkamer 3, lichtmast — D-026
en D-036 blijven staan). De TL staat daarom bewust uit het midden
(west), met korte range en hoge attenuatie (0,85 / 2,45 / 2,7): een
lichtpool boven de vergadertafel, en de historie-wand, het bureau en de
hoeken lopen weg in schemer. Grounding komt uit de F2.1-decaltechniek,
niet uit slagschaduw. Gevolg voor de tests: nachtstaat is nu
5 stabiel / 1 flikkerend / 9 defect.

## D-042 — Regen is een wereldlaag van de F3-unit, geen ambience-laag en geen camera-effect
**Datum**: 2026-08-03 · **Wie**: Lead Developer · **Status**: actief
De regen bestaat uit twee GPU-particlevolumes boven het voorplein en
achter het hek (wereldposities — hij valt waar hij valt, ook als de
camera wegkijkt) plus drie licht verstemde `AudioStreamPlayer3D`-loops
langs de gevel. Bewust géén 2D-ambiencelaag: die is overal even luid,
terwijl regen per positie moet verschillen — buiten vol, onder de
luifel gedempt, dieper het gebouw in zakt hij vanzelf weg met de
afstand. Alles zit in de F3-unit en verdwijnt met de map (D-015);
zonder de gegenereerde texture of WAV bouwt de laag stil verder.
Beperking: de demping is puur afstand, geen occlusie (TD-010).

## D-043 — Een deur is een keten van gebeurtenissen, geen kraak
**Datum**: 2026-08-03 · **Wie**: Lead Developer (GD-brief F3 §14) · **Status**: actief
Het deurgeluid is opgebouwd uit klink-tikken, de schoot die vrijkomt,
de bladbeweging (lage ruis-sweep), een zachte scharnierkraak en een
lichte kozijnresonantie — een normale deur die in een stil gebouw echt
klinkt, geen horror-creak. De vervanging loopt via het
005-vervangingscontract: zelfde bestandsnamen, dus SoundResources en
props onaangeraakt. `tools/genereer_f3_audio.gd` is deterministisch en
draait ná de placeholder-generator (die verwijst er nu naar).
