# JsonLoad

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: de -->

Liest eine JSON-Datei.

## Genaue Syntax

```text
JsonLoad(fileName:String) -> Any
JsonLoad(fileName:String, defaultValue:Any) -> Any
```

## Parameter

- `fileName` — Erforderlicher Dateipfad. Relative Pfade beziehen sich auf den Hauptskriptordner, auch innerhalb von Include. Absolute Pfade sind erlaubt.
- `defaultValue` — Optionaler Ersatz nur bei fehlender Datei oder fehlendem Ordner. Unabhängige Kopie durch JSON-Konvertierung; Inhalts-, Codierungs- und Zugriffsfehler werden weitergegeben.

## Rückgabewert

Any wie bei JsonParse. Fehlende Datei ohne defaultValue löst einen Fehler aus.

## Verhalten

- Lokale Basic-Funktionen ohne UO. und ohne Spielpakete. JsonParse/JsonStringify arbeiten im Speicher. Basic True wird als Zahl1 geschrieben; für JSON true JsonBoolean(True) verwenden. JsonNull() trennt null von0.
- Nur endliche Zahlen. Ganzzahlige Werte außerhalb ±9007199254740991 werden abgelehnt; große IDs als Strings speichern. Sonst gilt Double-Genauigkeit. Striktes UTF-8: Eingabe-BOM erlaubt, Ausgabe ohne BOM. Ungültiges Unicode ist ein Fehler.
- Grenzen:1048576 UTF-16-Codeeinheiten,4MiB Dateiausgabe,64 verschachtelte Container,100000 Wertknoten. Überschreitungen sind Fehler. Lesen erzeugt neue Sammlungen; Speichern klont keine Speicherobjekte.
- Save prüft alle Daten, erstellt Ordner, schreibt eine temporäre Nachbardatei, leert Puffer und verschiebt/ersetzt sie. Fehler/Abbruch vor Ersetzung erhalten die alte Datei. Temporärdateien werden entfernt, soweit das Betriebssystem es zulässt. Abgeschlossene Ersetzungen werden nicht zurückgenommen.
- Pause/Stopp werden alle256 Werte, zwischen4096-Byte/Zeichen-Blöcken und vor Ersetzung geprüft. Kein zusätzlicher Thread; OS-Aufrufe sind nicht zwangsweise unterbrechbar. Gleichzeitiges Speichern: letzte erfolgreiche Ersetzung gewinnt; keine Datenbanktransaktion.

### Interne Funktionen: vom Aufruf zum Ergebnis

Liest eine JSON-Datei.

#### 1. LoadCore

Erforderlicher Dateipfad. Relative Pfade beziehen sich auf den Hauptskriptordner, auch innerhalb von Include. Absolute Pfade sind erlaubt. Optionaler Ersatz nur bei fehlender Datei oder fehlendem Ordner. Unabhängige Kopie durch JSON-Konvertierung; Inhalts-, Codierungs- und Zugriffsfehler werden weitergegeben.

Any wie bei JsonParse. Fehlende Datei ohne defaultValue löst einen Fehler aus.

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; Funktion `LoadCore`.

Config.Load(fileName, defaults) liefert ein neues Dictionary: gespeicherte oberste Schlüssel überschreiben eine tiefe Kopie von defaults. Verschachtelte Objekte werden vollständig ersetzt. Config.Save(fileName, settings) speichert ausdrücklich, ohne Rückgabewert. Config.GetFlag(settings, key, fallback=False) liefert1/True oder0/False; vorhandene nichtlogische Werte verursachen Fehler. Config.SetFlag(settings, key, value) ändert nur den Speicher und liefert nichts. Load/Save benötigen Dictionaries mit String-Schlüsseln. Private RequireObject prüft die äußere Art; JSON prüft den gesamten Inhalt.


## Beispiele

### JsonLoad · 1

```vb
# JsonLoad · 1
#
# Liest eine JSON-Datei.
#
# Any wie bei JsonParse. Fehlende Datei ohne defaultValue löst einen Fehler aus.

Option Explicit On
Sub Main()
    # Main ausführen. fileName="json-demo.json"; JsonSave → file; JsonLoad → Dictionary; delay →
    # Integer350.

    JsonSave('json-demo.json', JsonParse('{"delay":350}'))
    Dim d=JsonLoad('json-demo.json')
    Return d['delay']
End Sub
```

**Erläuterung der Parameter und Ausführung:**

- Main ausführen. fileName="json-demo.json"; JsonSave → file; JsonLoad → Dictionary; delay → Integer350.

### JsonLoad · 2

```vb
# JsonLoad · 2
#
# Liest eine JSON-Datei.
#
# Any wie bei JsonParse. Fehlende Datei ohne defaultValue löst einen Fehler aus.

Option Explicit On
Sub Main()
    # Main ausführen. fileName="missing-json-demo.json", defaultValue=defaults; missing file →
    # independent copy → "125:350".

    Dim defaults=Dictionary()
    defaults['delay']=350
    Dim loaded=JsonLoad('missing-json-demo.json', defaults)
    loaded['delay']=125
    Return CStr(loaded['delay']) & ':' & CStr(defaults['delay'])
End Sub
```

**Erläuterung der Parameter und Ausführung:**

- Main ausführen. fileName="missing-json-demo.json", defaultValue=defaults; missing file → independent copy → "125:350".

### JsonLoad · 3

```vb
# JsonLoad · 3
#
# Liest eine JSON-Datei.
#
# Any wie bei JsonParse. Fehlende Datei ohne defaultValue löst einen Fehler aus.

Option Explicit On
Sub Main()
    # Main ausführen. fileName="json-demo-list.json", defaultValue=List(); existing file [1,2,3] →
    # List.Count() → Integer3.

    JsonSave('json-demo-list.json', JsonParse('[1,2,3]'))
    Dim data=JsonLoad(fileName:='json-demo-list.json', defaultValue:=List())
    Return data.Count()
End Sub
```

**Erläuterung der Parameter und Ausführung:**

- Main ausführen. fileName="json-demo-list.json", defaultValue=List(); existing file [1,2,3] → List.Count() → Integer3.
