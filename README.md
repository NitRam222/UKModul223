# GearShare – Multiuser Geräteausleihe & Geräteverwaltung

> **Modul 223:** Multi-User-Applikationen objektorientiert realisieren  
> **Autor:** Martin Evers  
> **Klasse:** 24-223-E  
> **Institution:** Informatik Lehrbetriebsverband (ilv)  
> **Datum:** 21.09.2026  

---

## 1. Kurzbeschreibung

**GearShare** ist eine moderne, webbasierte Multiuser-Applikation zur Verwaltung und Ausleihe von gemeinsam genutzten Hardware-Geräten (Laptops, Kameras, Adapter, Audio-Zubehör) in Schulen und Unternehmen.

Das System löst das Problem von Intransparenz, Verlusten und konkurrierenden Doppelbelegungen durch ein **zweistufiges Concurrency- und Locking-Konzept**:
1. **Applikatorisches Locking:** Pessimistisches Sperren (`with_lock` / `SELECT ... FOR UPDATE`) innerhalb von Active Record Transaktionen.
2. **Datenbank-Constraint:** Ein partieller Unique Index (`WHERE returned_at IS NULL`) in SQLite3 garantiert, dass zu jedem Zeitpunkt physisch höchstens eine aktive Ausleihe pro Gerät existieren kann.

---

## 2. Technologie-Stack & Versionen

- **Programmiersprache:** Ruby `4.0.6`
- **Web-Framework:** Ruby on Rails `8.1.3.1`
- **Datenbank:** SQLite3 `>= 2.1` mit partiellen Indizes
- **Authentifizierung:** `has_secure_password` via BCrypt `3.1.22`
- **Asset Pipeline:** Propshaft Asset Pipeline & modernes CSS
- **Test-Suite:** Minitest mit 62 automatisierten Tests (100% grün)
- **Dokumentations-Tools:** Markdown, Mermaid, Headless Chromium PDF-Engine

---

## 3. Voraussetzungen

- Ruby `4.0.x` (oder `>= 3.2`)
- Bundler (`gem install bundler`)
- SQLite3
- Optional (für PDF-Export): Node.js & Chromium (`node bin/generate_pdfs.js`)

---

## 4. Installation & Setup

Mit einer frischen Kopie des Repositorys kann die gesamte Applikation mit folgenden Befehlen eingerichtet werden:

```bash
# 1. Abhängigkeiten installieren
bundle install

# 2. Datenbank migrieren und vorbereiten
bin/rails db:prepare

# 3. Demo-Daten für die Präsentation und Tests einspielen
bin/rails db:seed
```

Alternativ führt das standardisierte Rails-Setup-Skript alle Schritte automatisch aus:
```bash
bin/setup
```

---

## 5. Applikation starten

Starten Sie den lokalen Puma-Webserver:

```bash
bin/rails server
```

Die Anwendung ist anschliessend im Browser erreichbar unter:  
👉 **[http://localhost:3000](http://localhost:3000)** (oder Port 3333 bei parallelen Instanzen)

---

## 6. Demo-Benutzerkonten

Für die Bewertung und die Live-Präsentation sind folgende vorkonfigurierte Benutzerkonten mit unterschiedlichen Rollen eingerichtet (Passwort ist bei allen Konten `password123`):

| Rolle | Name | E-Mail-Adresse | Passwort | Beschreibung / Berechtigungen |
| :--- | :--- | :--- | :--- | :--- |
| **Administrator** | Admin User | `admin@gearshare.ch` | `password123` | Vollzugriff: Geräte anlegen/editieren/deaktivieren, Benutzerrollen verwalten, alle Ausleihen einsehen, Notfall-Rückgaben durchführen, Aktivitätsprotokoll (Audit Trail) |
| **Benutzer** | Max Muster | `max@beispiel.ch` | `password123` | Standard-Benutzer: Hat bereits «Laptop 01» ausgeliehen. Kann Geräte durchsuchen, ausleihen, eigene Geräte zurückgeben und Profil pflegen. |
| **Benutzerin** | Anna Beispiel | `anna@beispiel.ch` | `password123` | Standard-Benutzerin: Hat «Laptop 02» ausgeliehen. Geeignet für Concurrency-Tests gegen Max. |
| **Benutzer** | Luca Muster | `luca@beispiel.ch` | `password123` | Standard-Benutzer: Hat «USB-C Adapter» ausgeliehen. |

---

## 7. Automatisierte Tests ausführen

Das Projekt verfügt über eine umfassende Testabdeckung für die zentrale Fachregel, Multi-Threading-Wettläufe (*Race Conditions*), Berechtigungsschranken und Workflows:

```bash
# Alle 62 Tests ausführen
bin/rails test

# Nur Concurrency- und Locking-Tests ausführen
bin/rails test test/models/concurrency_test.rb

# Nur zentrale Fachregel-Tests ausführen
bin/rails test test/models/loan_test.rb

# Nur Berechtigungstests (Admin vs. User) ausführen
bin/rails test test/controllers/admin_controllers_test.rb
```

**Testergebnis:**
```text
Finished in 0.60s, 102 runs/s, 465 assertions/s.
62 runs, 282 assertions, 0 failures, 0 errors, 0 skips
```

---

## 8. Verlinkung auf die Dokumentation

Die vollständige Projektdokumentation und die Präsentationsunterlagen befinden sich im Verzeichnis [`docs/`](docs/):

- 📄 **Projektdokumentation (Markdown):** [`docs/DOKUMENTATION.md`](docs/DOKUMENTATION.md)  
  *Enthält Problemstellung, Vision, funktionale & nicht-funktionale Anforderungen, Rollenmatrix, Locking-Konzept, ERM, Breadboards, Wireframes, Erreichter Stand, Abweichungen und Testprotokoll.*
- 📕 **Projektdokumentation (PDF-Export):** [`docs/evers-martin_dokumentation.pdf`](docs/evers-martin_dokumentation.pdf) (und im Root-Verzeichnis)
- 📊 **Abschlusspräsentation (Markdown):** [`docs/PRAESENTATION.md`](docs/PRAESENTATION.md)
- 📑 **Abschlusspräsentation (PDF-Export):** [`docs/evers-martin_praesentation.pdf`](docs/evers-martin_praesentation.pdf) (und im Root-Verzeichnis)
- 🖼️ **Diagramme und Screenshots:** [`docs/images/`](docs/images/)
  - ERM-Diagramm: [`docs/images/erm_diagram.png`](docs/images/erm_diagram.png)
  - Breadboard: [`docs/images/breadboard.png`](docs/images/breadboard.png)
  - Konzept-Skizzen (1-7): [`docs/images/sketch_*.png`](docs/images/)
  - Live-Screenshots aller Screens: [`docs/images/screenshot_*.png`](docs/images/)

---

## 9. PDF-Dokumente neu generieren

Falls Anpassungen an den Markdown-Dateien vorgenommen werden, können die PDF-Dokumente mit folgendem Skript jederzeit neu gerendert werden:

```bash
node bin/generate_pdfs.js
```
