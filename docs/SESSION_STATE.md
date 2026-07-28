# CRUMP — Sessiestatus

*Het startpunt van elke nieuwe sessie: waar staan we, wat is er net gebeurd,
wat is de volgende stap. **Bijwerken aan het eind van elke sessie** en na elke
afgeronde taak. Dit document is een momentopname — de bron van waarheid voor
regels en ontwerp blijven de andere docs.*

**Laatst bijgewerkt**: 2026-07-28 (na implementatie taak 005, v0.0.16)

---

## 1. Laatste afgeronde taak

**Taak 005 — Audio-fundament** ✅ gebouwd conform het goedgekeurde
ontwerp (v0.0.16) — **wacht op lokale GD-test** (hardware: mix,
3D-positionering, oor). Opgeleverd: `audio_cue`-kanaal strikt gescheiden
van `noise_made`; `game/systems/audio/` (resolver, one-shot-pool 12+4,
ambience-lagen standaard uit, muziek-API zonder triggers); AudioDirector
ongegroeid; 11 SoundResources + 15 gegenereerde placeholder-WAV's met
doelentabel; speler/deur/la/pickup zenden beide feiten; dev room zet zijn
nulpunt-laag zelf aan; F3 toont actieve geluiden. Suite 145 → 166.

Eerder vandaag: taken 002 t/m 004 afgerond en goedgekeurd; fase 1
compleet; Design Pillars (7 pijlers) vastgesteld.

Opgeleverd: `ItemResource` (minimaal, runtime read-only) + drie
voorbeelditems; inventory-node (capaciteit 6, geen stacking D-023,
`add_item -> bool` als enig besliskanaal, weigeren = nul mutatie); één
autoritatieve inventory (groep-guard in bootstrap + zelfcheck + test);
pickupflow via `item_pickup_requested`/`item_pickup_resolved` (D-022) —
prop verdwijnt uitsluitend na geldige accepted-response in zijn eigen
synchrone venster en bezit zijn eigen feedback; F3-regel
`inventory: n/cap · id's`. Suite 120 → 145.

Eerder vandaag: taken 002 en 003 afgerond en goedgekeurd; fase 1 compleet.

## 2. Laatste commit

```
[docs] Werk administratie bij voor taak 003
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
| Fase 0 — Fundering | ✅ afgerond |
| Taak 001 — Project-setup & bootstrap | ✅ afgerond en goedgekeurd |
| Taak 002 — Player controller | ✅ afgerond en goedgekeurd |
| Taak 003 — Interactiesysteem | ✅ afgerond en goedgekeurd |
| **Fase 1 — De wandeling** | ✅ **compleet** (GD-akkoord 2026-07-28) |
| Taak 004 — Inventory | ✅ afgerond en lokaal goedgekeurd |
| Taak 005 — Audio-fundament | ✅ gebouwd, **lokale GD-test open** |
| Taken 006–008 | ⬜ open |

**Technische staat**: import schoon (exit 0), smoke-suite **166/166
groen**. D-015 geverifieerd: zonder audiosysteem 145/145 (spel draait
stil), zonder interactiesysteem 109/109, alles aanwezig 166/166; eerdere
richtingen (zonder speler/inventory) blijven gedekt door dezelfde
conventies. `config/version` = 0.0.16. Warnings in de suite-output zijn
uitsluitend de bewust geteste luide faalpaden — normale opstart is
schoon (geverifieerd). Debug-prompt (TD-006) blijft tot de echte HUD.

**Nog niet visueel beoordeeld**: de interactieronde uit het
003-taakdossier (prompts, deur/la/sleutel/briefje, op-slot-deur,
interactie-afstand 2,5 m).

**Omgeving**: Godot 4.7.1 headless op de bouw-VPS
(`/opt/godot/godot-4.7.1`, symlink `/usr/local/bin/godot`). Projectpad:
`/home/kroosah/projects/crump`.

## 5. Volgende taak

**Eerst**: GD test taak 005 op hardware (stappen in het dossier /
vier-vragen-rapport: voetstappen per gait, deur/pickup positioneel,
nulpunt-laag, stilte, Esc). **Daarna, op startsein**: taak 006 (licht &
sfeer) of de door de GD gekozen stap. Openstaande vervolghaken: TD-005
(deur/la-tween op het nieuwe audioritme), sleutel-deur, la-koppeling,
save-integratie, inventory-UI/HUD (lost ook TD-006 af).

## 6. Open aandachtspunten

- **TD-005** (Laag, nieuw): deur/la bewegen instant — tween zodra audio
  (005) het ritme geeft.
- **TD-004** (Laag): bukken verkleint de collider niet — aflossen bij de
  eerste kruipruimte.
- **TD-002** (Middel): grafische presets eerste ruwe versie — taak 006/fase 6.
- **TD-003** (Laag): `brightness` nog niet toegepast — taak 006.
- **KNOWN_ISSUES**: geen open issues.
- **Export-templates** (TD-001) bewust niet geïnstalleerd (~1 GB).
- **Testcode-les (D-021)**: global classes van verwijderbare systemen nooit
  bij naam noemen in de suite — duck-typen met `has_method()`.
- **Pushen vanaf de VPS**: de kale vorm `git push -u origin main` (zonder
  pipes) werkt het betrouwbaarst.
- **Canon-correctieronde nodig (geregistreerd 2026-07-28, opdracht GD bij
  005)**: de GD heeft CRUMP nader bepaald — een **monster** dat door het
  stadion en over het terrein zwerft, de speler achtervolgt en besluipt,
  vaker gehoord dan gezien, met zeer zeldzaam een harde onmenselijke
  schreeuw (geen timer-jumpscare; in 005 alleen als toekomstige cue
  mogelijk gemaakt, geen AI-gedrag). Dit vervangt deels "vorm en aard
  bewust onbeschreven" in GAME_BIBLE §6 en STORY §5/§8 — die documenten in
  een aparte, gerichte canon-ronde bijwerken; géén brede lore-herbouw.
  Nergens in de bestaande docs staat een "speler = CRUMP"-implicatie
  (gecontroleerd).
- **Openstaande ontwerpsessie**: de verklaring achter CRUMP en de
  verdwijning — zie `STORY.md` §8. Nodig vóór hoofdstuk 3/4.
