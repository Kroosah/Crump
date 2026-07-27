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
