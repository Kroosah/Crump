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
**Datum**: 2026-07-28 · **Wie**: GD (keuze uit voorgelegde opties) / LD · **Status**: heroverwegen bij taak 007
GAME_BIBLE §5 noemt rennen "kort, hoorbaar, met consequentie". In taak 002 is
die consequentie uitsluitend akoestisch: rennen draagt 14 m op de EventBus
(lopen 6, sluipen 2) met een sneller stapritme — wie rent, roept CRUMP.
**Waarom**: sluit direct aan op pijler 1 ("stilte is het instrument") en
houdt taak 002 vrij van een stamina-systeem dat pas betekenis krijgt als er
iets is dat je hoort (007). **Heroverwegen**: als playtests uitwijzen dat
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
