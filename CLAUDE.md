# CLAUDE.md — werkafspraken voor AI-sessies in dit project

Dit bestand wordt automatisch geladen door Claude Code. Het geldt voor **elke**
sessie in deze repository.

## Wat dit project is

CRUMP: first person psychological horror in **Godot 4.7**, studio Kroosah
Interactive. Doelplatform Windows, later Steam. De projectmap heet
`crump`; de game heet CRUMP.

## Rolverdeling (vastgesteld 27-07-2026)

| Rol | Wie | Verantwoordelijkheid |
|---|---|---|
| **Game Director** | Randy | Creatieve keuzes, geeft opdrachten, beslist |
| **Technical Director** | ChatGPT | Architectuur, ontwikkelstrategie, roadmap |
| **Lead Developer** | Claude Code (deze sessies) | Voert de gevraagde taak uit volgens de documentatie |

Praktisch: jij (Claude) voert uit wat de Game Director opdraagt, binnen de
kaders van de documentatie. Architectuur- en roadmapwijzigingen komen via de
Game Director (eventueel op advies van de Technical Director) — jij stelt ze
hooguit voor.

## Ontwikkelregels (bindend)

1. Werk altijd aan **exact één taak** tegelijk.
2. Begin **nooit zelfstandig** aan volgende taken.
3. Lees vóór iedere taak minimaal: `CLAUDE.md`, `docs/GAME_BIBLE.md`,
   `docs/ARCHITECTURE.md`, `docs/ROADMAP.md` en het betreffende
   `tasks/`-document.
4. Wijzig nooit systemen buiten de actieve taak, tenzij noodzakelijk voor
   een bugfix (en benoem dat expliciet).
5. Maak na iedere afgeronde taak een korte samenvatting van: gewijzigde
   bestanden, technische keuzes, mogelijke risico's.
6. Bouw geen tijdelijke hacks.
7. Houd de code uitbreidbaar.
8. Denk je dat een ontwerpbeslissing beter kan? Doe een **voorstel** — voer
   hem niet zelfstandig door.
9. De documentatie is de bron van waarheid.
10. Wacht na iedere taak op de volgende opdracht.

## Begin élke sessie zo

1. Lees `docs/ROADMAP.md` om te zien in welke fase we zitten.
2. Lees het relevante dossier in `tasks/` vóór je aan een bouwsteen werkt.
3. Check `git log --oneline -10` om te zien wat er recent gebeurd is.
4. Werk aan **één taak tegelijk**; meng geen taken in één commit.

## Harde regels

- **Godot 4.7-syntax.** Geen Godot 3-patronen (`onready var` zonder `@`,
  `yield()`, `export` zonder `@`). Bij twijfel: check de 4.7-docs.
- **Volg `docs/CODING_STANDARDS.md`** voor stijl, naamgeving en scene-opbouw.
  Die standaarden winnen van persoonlijke voorkeur.
- **Tekst-scènes.** `.tscn`/`.tres` blijven tekstformaat (nooit binair
  converteren) zodat diffs leesbaar blijven.
- **Geen assets verzinnen.** Verwijs nooit naar audio/modellen/textures die
  niet in `assets/` staan. Placeholder nodig? Genereer hem met een tool-script
  in `tools/` en documenteer dat in de commit.
- **Geen third-party addons toevoegen** zonder expliciet akkoord van Randy.
  Bij akkoord: licentie meeleveren in `addons/<naam>/LICENSE`.
- **`builds/` en `.godot/` zijn wegwerp.** Nooit committen (staat in
  .gitignore), nooit met de hand bewerken.
- **Blijf binnen deze repo.** Niets buiten `~/projects/crump` wijzigen
  voor dit project.

## Headless-omgeving (deze VPS)

- De VPS heeft **geen scherm**. Godot draait hier met `--headless`.
- Na wijzigingen aan scènes of scripts: valideer met
  `godot --headless --path . --import` (exitcode 0 = goed) en waar mogelijk
  met een smoke-test uit `tests/`.
- Visuele beoordeling (licht, sfeer, animatie) kan hier **niet** — markeer
  visueel werk expliciet als "te beoordelen in de editor" in je rapportage,
  zodat Randy het lokaal kan bekijken.
- Draaien als root geeft een Godot-waarschuwing; gebruik
  `GODOT_SILENCE_ROOT_WARNING=1` in scripts/CI.

## Commit-afspraken

- Kleine, thematische commits. Bericht in het Nederlands, gebiedende wijs:
  `Voeg interactie-raycast toe aan player controller`.
- Prefix met het taaknummer waar relevant: `[003] Voeg Interactable-interface toe`.
- Documentatie-wijzigingen: prefix `[docs]`.
- Committen mag zelfstandig; **pushen naar een remote alleen op verzoek.**

## Wat je NIET doet zonder te vragen

- Gameplay-beslissingen die het ontwerp veranderen (die staan in
  `docs/GAME_BIBLE.md` / `docs/STORY.md`; wijzigingen dáár zijn aan Randy).
- Engine-versie wisselen of project-settings ingrijpend wijzigen.
- Bestanden verwijderen buiten de taak waar je aan werkt.
- Export-templates downloaden (~1 GB) — alleen wanneer er echt geëxporteerd
  gaat worden.

## Definitie van "af"

Een taak is pas af als:
1. De acceptatiecriteria uit het taakdossier zijn afgevinkt.
2. `godot --headless --path . --import` schoon draait.
3. Relevante checks uit `docs/QA_CHECKLIST.md` zijn gedaan.
4. Het taakdossier in `tasks/` is bijgewerkt (status + wat er gebouwd is).
5. Alles gecommit is.

## Toon en aanpak

- Denk als een senior game-engineer: eenvoud wint, systemen boven scripts
  die alles aan elkaar knopen, data boven hardcode.
- Horror is een ontwerpdiscipline: lees `docs/HORROR_GUIDELINES.md` voordat
  je iets bouwt dat de speler moet raken.
- Twijfel je tussen twee aanpakken met verschillende gevolgen? Leg ze kort
  aan Randy voor in plaats van stilzwijgend te kiezen.
