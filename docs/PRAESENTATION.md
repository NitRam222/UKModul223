# GearShare – Multiuser Geräteausleihe
## Abschlusspräsentation Modul 223: Multi-User-Applikationen objektorientiert realisieren

**Referent:** Martin Evers | **Klasse:** 24-223-E | **Datum:** 21.09.2026 | **Dauer:** 7-10 Minuten

---

## Folie 1: Titelfolie

### GearShare
**Verlässliche Multiuser-Geräteausleihe & Geräteverwaltung**

- **Modul:** Modul 223 (ilv Informatik Lehrbetriebsverband)
- **Autor:** Martin Evers (Klasse 24-223-E)
- **Technologie:** Ruby on Rails 8.1 / SQLite3 / Solid Framework
- **Repository:** `m223` (Multi-User Application)

> *«Keine Doppelbelegungen. Jederzeit transparent. Vollständig transaktionssicher.»*

---

## Folie 2: Ausgangslage & Problemstellung

### Das Problem im Schul- und Betriebsalltag
- **Gemeinsame Ressourcen:** Laptops, Kameras, Adapter, Audio-Equipment werden von Dutzenden Personen geteilt.
- **Intransparenz:** Niemand weiss in Echtzeit, welche Geräte frei sind oder wer ein fehlendes Gerät hat.
- **Konflikte & Doppelbelegungen:** Zwei Personen reservieren dasselbe Gerät zur gleichen Zeit.
- **Scheitern von Zetteln & Excel:** Analoge Listen und statische Tabellen bieten keine Gleichzeitigkeits-Koordination und keine Zugriffskontrollen.

---

## Folie 3: Projektvision & Kernfunktionalität

### Die Vision von GearShare
Eine moderne Webplattform, die den gesamten Ausleih- und Rückgabeprozess automatisiert und absolute Datenkonsistenz garantiert.

### Kernfunktionen (1. Iteration / MVP)
1. **Gerätekatalog:** Filterung nach Kategorien (Laptop, Kamera, Zubehör, Audio) und Volltextsuche.
2. **1-Klick-Ausleihe:** Sofortige verbindliche Buchung verfügbarer Hardware.
3. **Persönliche Ausleihübersicht:** Aktive Ausleihen und Historie einsehen.
4. **Sichere Rückgabe:** Freigabe des Geräts für den nächsten Benutzer.
5. **Admin-Verwaltung:** Geräte-Stammdaten pflegen, Benutzerrollen steuern, Gesamtübersicht aller Ausleihen.

---

## Folie 4: Multi-User Kernherausforderung: Concurrency & Locking

### Was passiert bei gleichzeitigem Klick? (Race Condition)
Wenn Benutzerin Anna und Benutzer Max zur selben Millisekunde auf «Ausleihen» für den letzten verfügbaren Laptop klicken:
- **Ohne Locking:** Beide Lese-Prüfungen sind erfolgreich $\rightarrow$ Zwei aktive Ausleihen entstehen $\rightarrow$ **Datenkorruption!**

### Das 2-Stufen-Schutzkonzept von GearShare
1. **Applikations-Ebene:**
   - Active Record Transaktion mit **pessimistischem Locking** (`Device.lock.find(id)`)
   - Sequenzialisierung der Lese- und Schreibvorgänge via `SELECT ... FOR UPDATE`
2. **Datenbank-Ebene:**
   - **Partieller Unique Index:** `WHERE returned_at IS NULL`
   - Selbst bei direkten Datenbank-Zugriffen kann physisch niemals eine zweite aktive Ausleihe persistiert werden!
3. **User Feedback:**
   - Sauberes Abfangen von Konflikten: *«Das Gerät wurde inzwischen von einem anderen Benutzer ausgeliehen.»* Keine 500er-Fehler!

---

## Folie 5: Domänenmodell & Architektur (ERM)

### Relationales Datenmodell
- **User:** Authentifizierung via BCrypt, Rollen (`user`, `admin`), Kontostatus
- **Device:** Name, Kategorie, Inventar-Code (Unique), Beschreibung, Aktiv/Inaktiv
- **Loan:** `user_id`, `device_id`, `borrowed_at`, `returned_at` (NULL = aktiv), Notiz
- **ActivityLog:** Revisionssicherer Audit Trail für alle Systemereignisse

```text
+-------------------+           +-------------------+
|      User         | 1       * |      Loan         |
|-------------------|-----------|-------------------|
| id (PK)           |           | id (PK)           |
| name              |           | user_id (FK)      |
| email (UK)        |           | device_id (FK)    |
| role (user/admin) |           | borrowed_at       |
+-------------------+           | returned_at (NULL)|
                                +-------------------+
+-------------------+                     * |
|     Device        | 1                     |
|-------------------|-----------------------+
| id (PK)           |
| name              |
| category          |
| inventory_code(UK)|
| active (boolean)  |
+-------------------+
```

---

## Folie 6: Rollen- & Berechtigungskonzept

| Bereich / Feature | Standard-Benutzer | Administrator |
| :--- | :---: | :---: |
| Geräte durchsuchen & einsehen | ✅ | ✅ |
| Freie Geräte ausleihen | ✅ | ✅ |
| Eigene Geräte zurückgeben | ✅ | ✅ |
| Fremde Geräte zurückgeben | ❌ | ✅ (Notfall-Rückgabe) |
| Eigene Historie anzeigen | ✅ | ✅ |
| Alle Ausleihen aller Benutzer | ❌ | ✅ |
| Geräte anlegen, editieren, deaktivieren | ❌ | ✅ |
| Benutzer verwalten & Rollen zuweisen | ❌ | ✅ |
| Aktivitätsprotokoll (Audit Trail) | ❌ | ✅ |

*Sicherheitsgarantie: Alle Admin-Endpunkte werden serverseitig via `before_action :require_admin` geschützt.*

---

## Folie 7: Live-Demo – Ablaufplan

### Szenario 1: Der normale Ausleih- und Rückgabe-Flow
- **Akteur:** Benutzer Max Muster (`max@beispiel.ch`)
- Gerät **«Laptop 03»** in der Übersicht filtern und auswählen
- Auf **«Ausleihen»** klicken $\rightarrow$ Bestätigungsbanner erscheint
- Wechsel zu **«Meine Ausleihen»** $\rightarrow$ Laptop 03 ist aktiv gebucht
- Auf **«Zurückgeben»** klicken $\rightarrow$ Gerät wird sofort wieder freigegeben

### Szenario 2: Konkurrierender Zugriff & Fehlerbehandlung
- Simulation von zwei parallelen Benutzern auf das letzte freie Gerät
- System weist die zweite Ausleihe ab: *«Das Gerät wurde inzwischen von einem anderen Benutzer ausgeliehen.»*
- Formulardaten bleiben erhalten, Datenbestand bleibt 100% konsistent

### Szenario 3: Administrator-Aufsicht & Audit Trail
- **Akteur:** Administrator (`admin@gearshare.ch`)
- Aufruf **«Geräteverwaltung»** $\rightarrow$ Neues Gerät anlegen
- Aufruf **«Aktivitätsprotokoll»** $\rightarrow$ Alle Aktionen der Demo sind lückenlos protokolliert

---

## Folie 8: Qualitätssicherung & Testabdeckung

### 62 Automatisierte Tests – 100% Erfolgreich (0 Fehler, 0 Skips)
- **Modell-Tests:** Validierung von Pflichtfeldern, E-Mail-Format, Uniqueness, Statuslogik.
- **Zentrale Fachregel-Tests:** Prüfung auf Modell- und Datenbankebene.
- **Multi-Threading Concurrency-Test:** Reale parallele OS-Threads simulieren gleichzeitige Klicks.
- **Berechtigungstests:** Verifikation, dass reguläre Benutzer keinen Zugriff auf `/admin/*` erhalten.
- **Controller- & Flow-Tests:** End-to-End-Prüfung von Login, Profil, Ausleihe und Rückgabe.

---

## Folie 9: Reflexion, Fazit & Fragen

### Was habe ich im Modul 223 gelernt?
1. **Multi-User erfordert Umdenken:** Einfache sequentielle Logik reicht bei nebenläufigen Anfragen nicht aus.
2. **Pessimistisches Locking:** Zuverlässiges Mittel gegen Überbuchungen kritischer Ressourcen.
3. **Ganzheitliche Sicherheit:** Validierung im Modell, Schutz in Controllern und Integritätsregeln in der Datenbank (Defense-in-Depth).
4. **Rails 8 & Ergonomie:** Schnelle Entwicklung robuster Architekturen mit modernen Konventionen.

### Vielen Dank für Ihre Aufmerksamkeit!
**Gibt es Fragen zum Projekt GearShare?**
