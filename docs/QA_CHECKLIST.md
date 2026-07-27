# CRUMP — QA Checklist

*Wat er getest wordt voordat iets "af" heet. Twee niveaus: per taak (elke
bouwsteen) en per release-kandidaat (hele game). Op de VPS draait alles
headless; visuele/audio-checks staan expliciet als "editor/hardware" gemarkeerd
en gebeuren op de ontwikkelmachine.*

---

## 1. Per taak — altijd

Voor elke afgeronde taak, ongeacht wat het is:

- [ ] `godot --headless --path . --import` draait schoon (exitcode 0, geen
      errors of pushed warnings in de output).
- [ ] Geen achtergebleven `print()`, dode code of TODO zonder taaknummer.
- [ ] Tuning zit in `@export`/resources, niet in magic numbers
      (CODING_STANDARDS §3.5).
- [ ] Nieuwe logica heeft een smoke- of unit-test in `tests/` waar zinvol.
- [ ] Bestaande tests draaien nog groen.
- [ ] Taakdossier bijgewerkt; gecommit volgens CODING_STANDARDS §6.
- [ ] Scène(s) los te instantiëren zonder crash (nodig voor tests én reuse).
- [ ] **Verwijderbaarheidstest** (ARCHITECTURE §4a, D-015): map van het
      nieuwe systeem tijdelijk weghalen → `--import` en smoke-suite blijven
      groen, spel start nog. Geen directe verwijzingen naar andere
      gameplay-systemen (alleen EventBus, contracten, autoloads, `Log`).

## 2. Headless-tests (automatiseerbaar in `tests/`)

Deze draaien op de VPS en later in CI:

- [ ] **Import-test**: project importeert zonder fouten.
- [ ] **Scene-load-test**: elke hoofdscène instantieert los zonder errors.
- [ ] **Autoload-test**: alle autoloads laden en zijn bereikbaar.
- [ ] **Save round-trip**: `GameState` → save → nieuwe sessie → load levert
      identieke staat op (inclusief een save-versie-migratietest zodra er
      migraties zijn).
- [ ] **Event-bus-contract**: kernsignalen bestaan met de juiste signatuur
      (vangt breuk tussen zender en ontvanger vroeg af).
- [ ] **Resource-integriteit**: alle `.tres`-item/AI-profielen laden en
      hebben geldige verplichte velden.

## 3. Speler & besturing (editor/hardware)

- [ ] Beweging voelt bewust en gegrond (niet "camera op wieltjes"),
      GAME_BIBLE §5.
- [ ] Lopen/sluipen/rennen/bukken werken en verschillen hoorbaar én in
      snelheid.
- [ ] Muisgevoeligheid instelbaar; geen versnelling tenzij bewust.
- [ ] Geen door-de-muur-vallen, vastlopen in geometrie of blijven haken.
- [ ] Head-bob uitschakelbaar (motion sickness, HORROR_GUIDELINES §8).
- [ ] Interactie-prompt verschijnt alleen bij bruikbare objecten en klopt.

## 4. Audio (hardware — koptelefoon + speakers)

- [ ] 3D-positionering klopt: richting van geluid is blind te bepalen.
- [ ] Ambient-nulpunt zit goed; afwijkingen springen eruit
      (HORROR_GUIDELINES §3).
- [ ] Speler-geluid ↔ door-de-wereld-gehoorde luidheid komen overeen
      (de speler leert intuïtief wat "te luid" is).
- [ ] Geen clipping/oversturing; jumpscare-pieken begrensd (§ gehoor hieronder).
- [ ] Mixbalans getest op koptelefoon **en** laptopspeakers (kleine
      speakers verliezen laag — dreiging mag niet onhoorbaar worden).
- [ ] Muziek-cues triggeren op de bedoelde momenten en verklappen de AI niet.

### Gehoor-veiligheid
- [ ] Geen enkele sound-cue overschrijdt de vastgestelde piek-limiet
      (zodat schrikken geen fysieke pijn wordt, HORROR_GUIDELINES §5b.4).
- [ ] Master- en effect-volume laag genoeg instelbaar voor gevoelige spelers.

## 5. Licht & sfeer (editor/hardware)

- [ ] Donkere zones blijven leesbaar (contouren zichtbaar), nergens
      informatie-loos pikzwart (HORROR_GUIDELINES §4).
- [ ] Helderheid-slider werkt en dekt uiteenlopende schermen.
- [ ] Elke lichtbron heeft een zichtbare wereld-oorzaak (LEVEL_GUIDELINES §5).
- [ ] Lichtbudget per ruimte gerespecteerd; geen framedrops bij lichtwissels.

## 6. CRUMP & AI (editor/hardware, vanaf taak 007)

- [ ] AI reageert uitsluitend op gedefinieerde zintuigen (gehoor via
      event-bus, zicht via cone+LOS) — geen wallhacks (HORROR_GUIDELINES §6).
- [ ] Spawnt nooit in beeld, geen aantoonbare teleportatie.
- [ ] Elke dreigingssituatie heeft een leesbare overlevingsoptie.
- [ ] Navigatie soepel; CRUMP loopt niet vast en "glitcht" niet door muren.
- [ ] Toestandsovergangen (patrouille→onderzoek→achtervolging→verliezen)
      kloppen en zijn voor de speler leesbaar aan tells.
- [ ] Gepakt-worden → eerlijk checkpoint, herstart binnen enkele minuten.

## 7. Verhaal & consistentie

- [ ] Vondsten, namen en jaartallen consistent met STORY.md.
- [ ] Documenten kort en scanbaar; geen verplichte leesmuren.
- [ ] Geen essentiële voortgang achter optionele lore verstopt.
- [ ] Ondertitels aanwezig en correct, inclusief geluidsbeschrijvingen.

## 8. Saves & voortgang

- [ ] Checkpoints op de bedoelde, veilige plekken.
- [ ] Save bij verlaten herstelt correct.
- [ ] Corrupt/ongeldig savebestand geeft nette afhandeling, geen crash.
- [ ] Save-versie-migratie getest bij elke formaatwijziging.

## 9. Toegankelijkheid

- [ ] Ondertitels aan/uit + leesbaar.
- [ ] Helderheid, FOV, head-bob, muisgevoeligheid instelbaar.
- [ ] Volume per bus (master/sfx/ambience/muziek/stem) instelbaar.
- [ ] Geen puzzels die uitsluitend op kleur of uitsluitend op geluid leunen
      zonder alternatief.

## 10. Per release-kandidaat — extra

Bovenop alle bovenstaande, voor een build die naar buiten gaat:

- [ ] Volledige playthrough zonder blockers, van start tot elk einde.
- [ ] Performance: 60 fps @ 1080p op de minimale doel-hardware
      (ARCHITECTURE §7), gemeten, niet geschat.
- [ ] Windows-export start schoon op een kale machine (geen dev-dependencies).
- [ ] Geen console-errors/warnings tijdens een volledige speelsessie.
- [ ] Opties-menu volledig functioneel; instellingen blijven bewaard.
- [ ] Alle eindes (STORY §8) bereikbaar en correct.
- [ ] Lokalisatie-strings compleet voor de talen in de build.
- [ ] Externe playtest verwerkt; geen bekende immersie-brekende bugs open.

---

## Werkwijze

- Secties 1–2 zijn **verplicht per taak** en grotendeels te automatiseren.
- Secties 3–9 gelden zodra de betreffende functionaliteit bestaat; vink af
  wat van toepassing is en noteer wat "n.v.t." is.
- Sectie 10 is de poort naar buiten: geen release-kandidaat zonder volledige
  doorloop op de minimale doel-hardware.
- Bevindingen worden bugs met een taaknummer; niets "af" met een bekende
  immersie-breker open.
