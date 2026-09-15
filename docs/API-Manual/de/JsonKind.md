# JsonKind

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: de -->

Bestimmt die JSON-kompatible Wertart.

## Genaue Syntax

```text
JsonKind(value:Any) -> String
```

## Parameter

- `value` — Zahl, String, Array, List, Dictionary, JsonBoolean oder JsonNull. Dictionary-Schlüssel müssen Strings sein. Gemeinsame Referenzen sind erlaubt, Zyklen nicht.

## Rückgabewert

String:number, string, array, object, boolean, null oder unsupported. Prüft nur die äußere Wertart.

## Verhalten

- Lokale Basic-Funktionen ohne UO. und ohne Spielpakete. JsonParse/JsonStringify arbeiten im Speicher. Basic True wird als Zahl1 geschrieben; für JSON true JsonBoolean(True) verwenden. JsonNull() trennt null von0.
- Nur endliche Zahlen. Ganzzahlige Werte außerhalb ±9007199254740991 werden abgelehnt; große IDs als Strings speichern. Sonst gilt Double-Genauigkeit. Striktes UTF-8: Eingabe-BOM erlaubt, Ausgabe ohne BOM. Ungültiges Unicode ist ein Fehler.
- Grenzen:1048576 UTF-16-Codeeinheiten,4MiB Dateiausgabe,64 verschachtelte Container,100000 Wertknoten. Überschreitungen sind Fehler. Lesen erzeugt neue Sammlungen; Speichern klont keine Speicherobjekte.
- Save prüft alle Daten, erstellt Ordner, schreibt eine temporäre Nachbardatei, leert Puffer und verschiebt/ersetzt sie. Fehler/Abbruch vor Ersetzung erhalten die alte Datei. Temporärdateien werden entfernt, soweit das Betriebssystem es zulässt. Abgeschlossene Ersetzungen werden nicht zurückgenommen.
- Pause/Stopp werden alle256 Werte, zwischen4096-Byte/Zeichen-Blöcken und vor Ersetzung geprüft. Kein zusätzlicher Thread; OS-Aufrufe sind nicht zwangsweise unterbrechbar. Gleichzeitiges Speichern: letzte erfolgreiche Ersetzung gewinnt; keine Datenbanktransaktion.

### Interne Funktionen: vom Aufruf zum Ergebnis

Bestimmt die JSON-kompatible Wertart.

#### 1. Kind

Zahl, String, Array, List, Dictionary, JsonBoolean oder JsonNull. Dictionary-Schlüssel müssen Strings sein. Gemeinsame Referenzen sind erlaubt, Zyklen nicht.

String:number, string, array, object, boolean, null oder unsupported. Prüft nur die äußere Wertart.

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; Funktion `Kind`.

Config.Load(fileName, defaults) liefert ein neues Dictionary: gespeicherte oberste Schlüssel überschreiben eine tiefe Kopie von defaults. Verschachtelte Objekte werden vollständig ersetzt. Config.Save(fileName, settings) speichert ausdrücklich, ohne Rückgabewert. Config.GetFlag(settings, key, fallback=False) liefert1/True oder0/False; vorhandene nichtlogische Werte verursachen Fehler. Config.SetFlag(settings, key, value) ändert nur den Speicher und liefert nichts. Load/Save benötigen Dictionaries mit String-Schlüsseln. Private RequireObject prüft die äußere Art; JSON prüft den gesamten Inhalt.


## Beispiele

### JsonKind · 1

```vb
# JsonKind · 1
#
# Bestimmt die JSON-kompatible Wertart.
#
# String:number, string, array, object, boolean, null oder unsupported. Prüft nur die äußere
# Wertart.

Option Explicit On
Sub Main()
    # Main ausführen. value=12 → "number"; value="12" → "string".

    Return JsonKind(12) & ':' & JsonKind('12')
End Sub
```

**Erläuterung der Parameter und Ausführung:**

- Main ausführen. value=12 → "number"; value="12" → "string".

### JsonKind · 2

```vb
# JsonKind · 2
#
# Bestimmt die JSON-kompatible Wertart.
#
# String:number, string, array, object, boolean, null oder unsupported. Prüft nur die äußere
# Wertart.

Option Explicit On
Sub Main()
    # Main ausführen. value=JsonParse("[1]") → "array"; value=Dictionary() → "object".

    Return JsonKind(JsonParse('[1]')) & ':' & JsonKind(Dictionary())
End Sub
```

**Erläuterung der Parameter und Ausführung:**

- Main ausführen. value=JsonParse("[1]") → "array"; value=Dictionary() → "object".

### JsonKind · 3

```vb
# JsonKind · 3
#
# Bestimmt die JSON-kompatible Wertart.
#
# String:number, string, array, object, boolean, null oder unsupported. Prüft nur die äußere
# Wertart.

Option Explicit On
Sub Main()
    # Main ausführen. value=JsonBoolean(False) → "boolean"; value=JsonNull() → "null".

    Return JsonKind(JsonBoolean(False)) & ':' & JsonKind(JsonNull())
End Sub
```

**Erläuterung der Parameter und Ausführung:**

- Main ausführen. value=JsonBoolean(False) → "boolean"; value=JsonNull() → "null".
