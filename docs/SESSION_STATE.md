# CRUMP — Sessiestatus

*Het startpunt van elke nieuwe sessie: waar staan we, wat is er net gebeurd,
wat is de volgende stap. **Bijwerken aan het eind van elke sessie** en na elke
afgeronde taak. Dit document is een momentopname — de bron van waarheid voor
regels en ontwerp blijven de andere docs.*

**Laatst bijgewerkt**: 2026-07-27

---

## 1. Laatste afgeronde taak

**Taak 001 — Project-setup & bootstrap** ✅ (goedgekeurd door de Game Director)

Opgeleverd: `project.godot` (Forward+, input-map, physics-layers, audiobussen),
vijf autoloads (EventBus, GameState, AudioDirector, SettingsManager,
SaveManager), bootstrap + game-lifecycle, developer room (grijze blockout),
Log-systeem, debug overlay (F3), settings met grafische presets, en een
smoke-test-suite van 31 controles.

Daarna nog vastgelegd: **modulariteit als harde eis** (D-015) — elke feature
moet volledig verwijderbaar zijn zonder de rest te breken.

Daarna volgde één gerichte bugfix: **KI-001 — de developer room toonde een
egaal grijs beeld** omdat het project nergens een `Camera3D` had. Opgelost met
een vaste testcamera, zwaardere tijdelijke verlichting, contrasterende
materialen en 17 extra smoke-controles (D-016, CHANGELOG v0.0.7).

## 2. Laatste commit

```
[001] Los KI-002 op: SunKey schijnt omlaag; scherp lichtcontroles aan
```

Werkmap schoon; `main` gepusht naar `origin/main`.

## 3. GitHub-status

- **Remote**: `origin` → `git@github.com:Kroosah/Crump.git` (privé, SSH)
- **Branch**: `main`, met upstream-tracking naar `origin/main`
- **Synchroon**: alle commits gepusht (`git status` schoon, geen ahead/behind)
- **Authenticatie**: deploy key met schrijfrechten (`crump-deploy@VPS-Focus`),
  privésleutel `/root/.ssh/id_ed25519_github`, ssh-config-entry voor github.com
- **GitHub is de officiële bron van waarheid**: elke afgeronde taak wordt
  gecommit én gepusht.

## 4. Huidige projectstatus

| Onderdeel | Status |
|---|---|
| Fase 0 — Fundering (structuur + documentatie) | ✅ afgerond |
| Taak 001 — Project-setup & bootstrap | ✅ afgerond en goedgekeurd |
| Taak 002 — Player controller | ⬜ **volgende** |
| Taken 003–008 | ⬜ open |

**Technische staat**: het project draait. `godot --headless --path . --import`
is schoon (exit 0), de smoke-suite geeft 52/52 groen (exit 0), de bootstrap
laadt de developer room, en de vier registers (DECISIONS/CHANGELOG/
KNOWN_ISSUES/TECH_DEBT) zijn bijgewerkt.

**Visueel bevestigd (2026-07-27)**: de Game Director heeft de dev room op
Windows in beeld gehad — vloer, muren en zes gekleurde objecten met schaduwen.
KI-001 is daarmee ook visueel dicht, en Forward+ met schaduwwerpende lichten
draait aantoonbaar op de Intel UHD Graphics. Daarna is de testcamera op
ooghoogte gezet (v0.0.8); dat beeld moet nog opnieuw bekeken worden.

**Nog niet visueel beoordeeld**: de debug overlay (F3) en de pauze (Esc).

**Omgeving**: Godot 4.7.1 headless op de bouw-VPS
(`/opt/godot/godot-4.7.1`, symlink `/usr/local/bin/godot`). Projectpad:
`/home/kroosah/projects/crump`.

## 5. Volgende taak

**Taak 002 — Player controller** (`tasks/002_player_controller.md`)

Lopen/sluipen/rennen/bukken, camera op ooghoogte, bewuste beweging, en
voetstap-events die `EventBus.noise_made(position, loudness)` publiceren.
Geen interactie (003), geen zaklamp (006), geen daadwerkelijke
voetstapgeluiden (005) — alleen de events.

Alles staat klaar: de dev room bestaat, de input-acties zijn gedefinieerd,
`SettingsManager.mouse_sensitivity` en `head_bob_enabled` wachten op een
afnemer, en de debug overlay heeft al een haak voor de spelerspositie
(zoekt een node in de groep `player`).

**Let op bij deze taak**: het *gevoel* van beweging is het hele punt en is
niet headless te beoordelen — lever met bewuste export-defaults en een
korte instructie wat de Game Director in de editor moet testen.

## 6. Open aandachtspunten

- **TD-002** (Middel): grafische presets zijn een eerste ruwe versie;
  release-default staat nog op ontwikkelwaarde. Aflossen bij taak 006/fase 6.
- **TD-003** (Laag): `brightness` wordt opgeslagen maar nog nergens toegepast
  — koppelen in taak 006 (licht & sfeer).
- **KNOWN_ISSUES**: geen open issues; KI-001 (grijs beeld) en KI-002
  (zon schijnt omhoog) zijn opgelost. Les eruit: "de logs zijn schoon"
  bewijst niet dat er beeld is, en `.tscn`-Transform3D's zijn rij-
  georiënteerd — de smoke-suite toetst nu rendervoorwaarden én lichtrichting.
- **Export-templates** (TD-001) bewust niet geïnstalleerd (~1 GB) — pas
  nodig bij de eerste echte export.
- **Verwijderbaarheidstest** (D-015) is vanaf nu onderdeel van elke taak:
  map van het nieuwe systeem tijdelijk weghalen → import en smoke-suite
  blijven groen.
- **Pushen vanaf de VPS** kan door de auto-mode-classifier haperen; de kale
  vorm `git push -u origin main` (zonder pipes) werkte.
- **Openstaande ontwerpsessie**: wát CRUMP is (aard, vorm, verklaring van de
  verdwijning) — zie `STORY.md` §8. Nodig vóór hoofdstuk 3/4, niet vóór
  taak 002.
