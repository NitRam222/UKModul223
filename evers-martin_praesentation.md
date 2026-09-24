---
marp: true
theme: default
paginate: true
header: "Modul 223 - GearShare"
footer: "Martin Evers - 25.09.2026"
---

# GearShare 
## Multiuser Geräteausleihe und Geräteverwaltung

**Modul 223:** Multi-User-Applikationen objektorientiert realisieren
**Autor:** Martin Evers (24-223-E)
**Datum:** 25.09.2026

---

# Problemstellung & Vision

**Das Problem:**
In Schulen und Unternehmen werden Geräte (Laptops, Kameras) oft über unübersichtliche Listen verwaltet.
-> *Folge: Unklare Verfügbarkeit, Doppelbelegungen, fehlende Nachvollziehbarkeit.*

**Die Vision:**
GearShare ist eine webbasierte Multiuser-Applikation (Ruby on Rails). 
Sie stellt sicher, dass ein Gerät **immer nur von einer Person gleichzeitig** ausgeliehen werden kann. 

---

# Domäne & Zielgruppen

**Fachbereich / Domäne:** 
Geräteausleihe und Hardware-Inventarverwaltung.

**Zielgruppen:**
- **Benutzer (Lernende, Mitarbeitende):** Geräte suchen, Verfügbarkeit prüfen, ausleihen und zurückgeben.
- **Administratoren (IT-Verantwortliche):** Gesamten Hardware-Bestand verwalten, Benutzerrollen zuweisen und Aktivitätsprotokoll überwachen.

---

# Wichtigste Anforderungen (MVP)

- **FA-01:** Übersicht aller aktiven Geräte inkl. Verfügbarkeitsstatus.
- **FA-02:** Ausleihen eines freien Geräts mit sofortigem Statuswechsel.
- **FA-03:** Persönliche Ausleihen ansehen und Geräte zurückgeben.
- **FA-05 (Zentrale Regel):** Konkurrierende Ausleihen abweisen.
- **QA-01:** Datenkonsistenz sichern (Schutz vor Race Conditions).

---

# Multi-User-Konzept: Locking

Die Kernherausforderung sind gleichzeitige Zugriffe (Race Conditions). 
GearShare löst dies durch ein **zweistufiges Schutzkonzept**:

1. **Applikationsebene (Pessimistisches Locking):**
   `SELECT FOR UPDATE` bzw. `device.with_lock` beim Ausleihen.
2. **Datenbankebene (Partieller Unique Index):**
   Eine Regel auf der Tabelle (`where: "returned_at IS NULL"`) garantiert, dass pro Gerät maximal eine *aktive* Ausleihe existiert.

---

# Domänenmodell (ERM)

- **User:** Angemeldete Person (Rolle: User oder Admin)
- **Device:** Ein Gerät (Kategorie, Inventar-Code, Status)
- **Loan:** Verbindet User und Device (`borrowed_at` / `returned_at`)
- **ActivityLog:** Revisionssicheres Audit Trail für Änderungen

---

# Live-Demo

**Gezeigte Workflows:**
1. Multi-User-Funktionalität (Gleichzeitiger Zugriff & Locking)
2. Kernfunktionalität (Geräteübersicht, Ausleihen, Rückgabe)
3. Administrator-Ansicht

*Start der Live-Demo im Browser!*
