# JsonParse

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: de -->

Liest JSON-Text als Basic-Werte ein.

## Genaue Syntax

```text
JsonParse(text:String) -> Any
```

## Parameter

- `text` — Erforderlicher JSON-String: genau ein Wert. Eindeutige Schlüssel beachten Groß-/Kleinschreibung; Kommentare und abschließende Kommas sind Fehler.

## Rückgabewert

Any: Objekt→Dictionary, Array→List, Text→String, Zahl→Integer oder Decimal(Double), true/false→JsonBoolean, null→JsonNull. Kein Erfolgsindikator.

## Verhalten

- Lokale Basic-Funktionen ohne UO. und ohne Spielpakete. JsonParse/JsonStringify arbeiten im Speicher. Basic True wird als Zahl1 geschrieben; für JSON true JsonBoolean(True) verwenden. JsonNull() trennt null von0.
- Nur endliche Zahlen. Ganzzahlige Werte außerhalb ±9007199254740991 werden abgelehnt; große IDs als Strings speichern. Sonst gilt Double-Genauigkeit. Striktes UTF-8: Eingabe-BOM erlaubt, Ausgabe ohne BOM. Ungültiges Unicode ist ein Fehler.
- Grenzen:1048576 UTF-16-Codeeinheiten,4MiB Dateiausgabe,64 verschachtelte Container,100000 Wertknoten. Überschreitungen sind Fehler. Lesen erzeugt neue Sammlungen; Speichern klont keine Speicherobjekte.
- Save prüft alle Daten, erstellt Ordner, schreibt eine temporäre Nachbardatei, leert Puffer und verschiebt/ersetzt sie. Fehler/Abbruch vor Ersetzung erhalten die alte Datei. Temporärdateien werden entfernt, soweit das Betriebssystem es zulässt. Abgeschlossene Ersetzungen werden nicht zurückgenommen.
- Pause/Stopp werden alle256 Werte, zwischen4096-Byte/Zeichen-Blöcken und vor Ersetzung geprüft. Kein zusätzlicher Thread; OS-Aufrufe sind nicht zwangsweise unterbrechbar. Gleichzeitiges Speichern: letzte erfolgreiche Ersetzung gewinnt; keine Datenbanktransaktion.

### Interne Funktionen: vom Aufruf zum Ergebnis

Liest JSON-Text als Basic-Werte ein.

#### 1. Parse

Erforderlicher JSON-String: genau ein Wert. Eindeutige Schlüssel beachten Groß-/Kleinschreibung; Kommentare und abschließende Kommas sind Fehler.

Any: Objekt→Dictionary, Array→List, Text→String, Zahl→Integer oder Decimal(Double), true/false→JsonBoolean, null→JsonNull. Kein Erfolgsindikator.

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; Funktion `Parse`.

Config.Load(fileName, defaults) liefert ein neues Dictionary: gespeicherte oberste Schlüssel überschreiben eine tiefe Kopie von defaults. Verschachtelte Objekte werden vollständig ersetzt. Config.Save(fileName, settings) speichert ausdrücklich, ohne Rückgabewert. Config.GetFlag(settings, key, fallback=False) liefert1/True oder0/False; vorhandene nichtlogische Werte verursachen Fehler. Config.SetFlag(settings, key, value) ändert nur den Speicher und liefert nichts. Load/Save benötigen Dictionaries mit String-Schlüsseln. Private RequireObject prüft die äußere Art; JSON prüft den gesamten Inhalt.


## Beispiele

### JsonParse · 1

```vb
# JsonParse · 1
#
# Liest JSON-Text als Basic-Werte ein.
#
# Any: Objekt→Dictionary, Array→List, Text→String, Zahl→Integer oder Decimal(Double),
# true/false→JsonBoolean, null→JsonNull. Kein Erfolgsindikator.

Option Explicit On
Sub Main()
    # Main ausführen. text={"delay":350} → Dictionary; d["delay"] → Integer350.

    Dim d=JsonParse('{"delay":350}')
    Return d['delay']
End Sub
```

**Erläuterung der Parameter und Ausführung:**

- Main ausführen. text={"delay":350} → Dictionary; d["delay"] → Integer350.

### JsonParse · 2

```vb
# JsonParse · 2
#
# Liest JSON-Text als Basic-Werte ein.
#
# Any: Objekt→Dictionary, Array→List, Text→String, Zahl→Integer oder Decimal(Double),
# true/false→JsonBoolean, null→JsonNull. Kein Erfolgsindikator.

Option Explicit On
Sub Main()
    # Main ausführen. text=[true,null,12] → List; index0 → JsonBoolean.Value()=1; index1 → null;
    # index2 → Integer12.

    Dim a=JsonParse('[true,null,12]')
    Dim flag=a[0]
    Return CStr(flag.Value()) & ':' & JsonKind(a[1]) & ':' & CStr(a[2])
End Sub
```

**Erläuterung der Parameter und Ausführung:**

- Main ausführen. text=[true,null,12] → List; index0 → JsonBoolean.Value()=1; index1 → null; index2 → Integer12.

### JsonParse · 3

```vb
# JsonParse · 3
#
# Liest JSON-Text als Basic-Werte ein.
#
# Any: Objekt→Dictionary, Array→List, Text→String, Zahl→Integer oder Decimal(Double),
# true/false→JsonBoolean, null→JsonNull. Kein Erfolgsindikator.

Option Explicit On
Sub Main()
    # Main ausführen. text={"x":1,"x":2} → Catch → "duplicate key".

    Try
    Dim bad=JsonParse('{"x":1,"x":2}')
    Catch problem
    Return 'duplicate key'
    End Try
    Return 'unexpected'
End Sub
```

**Erläuterung der Parameter und Ausführung:**

- Main ausführen. text={"x":1,"x":2} → Catch → "duplicate key".
