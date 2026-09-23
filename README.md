# GearShare – Multiuser Geräteausleihe und Geräteverwaltung

> **Modul 223:** Multi-User-Applikationen objektorientiert realisieren
> **Autor:** Martin Evers
> **Klasse:** 24-223-E
> **Datum:** 25.09.2026

---

## 1. Kurzbeschreibung

**GearShare** ist eine webbasierte Multiuser-Applikation für die Verwaltung und Ausleihe von gemeinsam genutzten Geräten.

Dazu gehören zum Beispiel:

* Laptops
* Kameras
* Adapter
* Audio-Zubehör

Benutzer können verfügbare Geräte ansehen, ausleihen und wieder zurückgeben. Administratoren können Geräte und Benutzer verwalten.

Damit ein Gerät nicht gleichzeitig von mehreren Benutzern ausgeliehen werden kann, verwendet GearShare zwei Sicherheitsmechanismen:

1. **Applikations-Locking:**
   Das Gerät wird während der Ausleihe mit `with_lock` beziehungsweise `SELECT ... FOR UPDATE` gesperrt.

2. **Datenbank-Constraint:**
   Ein partieller Unique Index mit `WHERE returned_at IS NULL` stellt sicher, dass pro Gerät nur eine aktive Ausleihe existieren kann.

---

## 2. Technologien und Versionen

* **Programmiersprache:** Ruby `4.0.6`
* **Web-Framework:** Ruby on Rails `8.1.3.1`
* **Datenbank:** SQLite3 `>= 2.1`
* **Authentifizierung:** `has_secure_password` mit BCrypt `3.1.22`
* **Asset Pipeline:** Propshaft
* **Tests:** Minitest mit 62 automatisierten Tests
* **Dokumentation:** Markdown, Mermaid und Headless Chromium für PDF-Dateien

---

## 3. Voraussetzungen

Für das Projekt werden folgende Programme benötigt:

* Ruby `4.0.x` oder neuer
* Bundler
* SQLite3

Bundler kann mit folgendem Befehl installiert werden:

```bash
gem install bundler
```

Optional für den PDF-Export:

* Node.js
* Chromium

---

## 4. Installation

Nach dem Herunterladen des Repositorys müssen zuerst die benötigten Abhängigkeiten installiert werden.

```bash
# Abhängigkeiten installieren
bundle install

# Datenbank vorbereiten
bin/rails db:prepare

# Demo-Daten erstellen
bin/rails db:seed
```

Alternativ kann das Rails-Setup-Skript verwendet werden:

```bash
bin/setup
```

---

## 5. Applikation starten

Der lokale Rails-Server kann mit folgendem Befehl gestartet werden:

```bash
bin/rails server
```

Danach ist GearShare im Browser unter folgender Adresse erreichbar:

http://localhost:3000

Bei parallelen Instanzen kann zum Beispiel auch Port `3333` verwendet werden.

---

## 6. Demo-Benutzerkonten

Für Tests und die Präsentation gibt es bereits mehrere Benutzerkonten.

Das Passwort ist bei allen Konten:

```text
password123
```

| Rolle             | Name          | E-Mail-Adresse       | Beschreibung                                                                                                                                                          |
| ----------------- | ------------- | -------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Administrator** | Admin User    | `admin@gearshare.ch` | Kann Geräte erstellen, bearbeiten und deaktivieren. Kann Benutzerrollen verwalten, alle Ausleihen ansehen, Rückgaben durchführen und das Aktivitätsprotokoll ansehen. |
| **Benutzer**      | Max Muster    | `max@beispiel.ch`    | Hat bereits «Laptop 01» ausgeliehen. Kann Geräte suchen, ausleihen und eigene Geräte zurückgeben.                                                                     |
| **Benutzerin**    | Anna Beispiel | `anna@beispiel.ch`   | Hat bereits «Laptop 02» ausgeliehen. Kann für Concurrency-Tests verwendet werden.                                                                                     |
| **Benutzer**      | Luca Muster   | `luca@beispiel.ch`   | Hat bereits einen «USB-C Adapter» ausgeliehen.                                                                                                                        |

---

## 7. Tests ausführen

Das Projekt verwendet automatisierte Tests.

Getestet werden unter anderem:

* Ausleihen und Rückgaben
* Race Conditions
* Concurrency und Locking
* Benutzerrechte
* Administratorrechte
* wichtige Workflows

Alle Tests ausführen:

```bash
bin/rails test
```

Nur die Concurrency- und Locking-Tests ausführen:

```bash
bin/rails test test/models/concurrency_test.rb
```

Nur die Tests für Ausleihen ausführen:

```bash
bin/rails test test/models/loan_test.rb
```

Nur die Tests für Administratorrechte ausführen:

```bash
bin/rails test test/controllers/admin_controllers_test.rb
```

Aktuelles Testergebnis:

```text
Finished in 0.60s, 102 runs/s, 465 assertions/s.
62 runs, 282 assertions, 0 failures, 0 errors, 0 skips
```

---

## 8. Dokumentation

Die Projektdokumentation und Präsentation befinden sich im Ordner [`docs/`](docs/).

### Projektdokumentation

Markdown:

[`docs/DOKUMENTATION.md`](docs/DOKUMENTATION.md)

PDF:

[`docs/evers-martin_dokumentation.pdf`](docs/evers-martin_dokumentation.pdf)

Die Dokumentation enthält unter anderem:

* Problemstellung
* Vision
* funktionale Anforderungen
* nicht-funktionale Anforderungen
* Rollen und Berechtigungen
* Locking-Konzept
* ERM
* Breadboards
* Wireframes
* erreichter Stand
* Abweichungen
* Testprotokoll

### Präsentation

Markdown:

[`docs/PRAESENTATION.md`](docs/PRAESENTATION.md)

PDF:

[`docs/evers-martin_praesentation.pdf`](docs/evers-martin_praesentation.pdf)

### Bilder und Diagramme

Die Bilder befinden sich unter:

[`docs/images/`](docs/images/)

Dazu gehören:

* ERM-Diagramm: [`docs/images/erm_diagram.png`](docs/images/erm_diagram.png)
* Breadboard: [`docs/images/breadboard.png`](docs/images/breadboard.png)
* Konzept-Skizzen: [`docs/images/sketch_*.png`](docs/images/)
* Screenshots der Applikation: [`docs/images/screenshot_*.png`](docs/images/)

---
