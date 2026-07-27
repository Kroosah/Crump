# CRUMP — Technische schuld (TECH_DEBT.md)

*Elke bewuste tijdelijke oplossing, elk uitgesteld besluit en elke bekende
tekortkoming in de architectuur staat hier. Zo kan een tijdelijke oplossing
nooit stilletjes permanent worden. **Verplicht bijhouden** bij elke taak
(zie CLAUDE.md).*

## Werkwijze

- **Schuld aangaan mag** — bewust en gedocumenteerd. Wie iets tijdelijks
  bouwt, maakt in dezelfde commit een entry aan (`TD-xxx`).
- **Status** geeft de urgentie:
  - **Hoog** — remt de ontwikkeling of riskeert bugs; aflossen bij de
    eerstvolgende taak die het gebied raakt.
  - **Middel** — moet vóór de release van de betreffende fase opgelost zijn.
  - **Laag** — acceptabel; heroverwegen op het genoemde moment.
- Elke entry noemt een **aflosmoment**: de taak of fase waarin de schuld
  wordt opgelost of opnieuw beoordeeld.
- Afgeloste schuld verhuist naar de historie onderaan, met commit-verwijzing.
- Tijdelijke oplossingen zónder entry zijn niet toegestaan (CLAUDE.md,
  ontwikkelregel 6: geen hacks — een gedocumenteerde tijdelijke oplossing
  mét aflosplan is het enige toegestane compromis).

## Formaat

```
## TD-001 — Korte titel
**Datum**: jjjj-mm-dd · **Status**: Hoog/Middel/Laag · **Aflosmoment**: taak/fase
**Waar**: systeem/bestand
**Schuld**: wat is er tijdelijk of onaf, en waarom is daarvoor gekozen.
**Aflossing**: wat er moet gebeuren om dit netjes te maken.
```

---

## Openstaande schuld

## TD-001 — Export-templates nog niet geïnstalleerd op de bouw-VPS
**Datum**: 2026-07-27 · **Status**: Laag · **Aflosmoment**: fase 6 (Polish & Steam), of eerder bij de eerste export-behoefte
**Waar**: bouw-VPS (Godot-installatie)
**Schuld**: alleen de engine-binary is geïnstalleerd; de export-templates
(~1 GB) bewust niet — er valt nog niets te exporteren (CLAUDE.md: niet
downloaden zonder noodzaak).
**Aflossing**: officiële templates van de 4.7.1-release installeren en het
export-preset + build-script in `tools/` opzetten (ROADMAP fase 6).

## Afgeloste schuld

*Nog geen.*
