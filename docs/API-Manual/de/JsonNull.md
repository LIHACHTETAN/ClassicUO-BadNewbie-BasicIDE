# JsonNull

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: de -->

Erzeugt einen expliziten JSON-null-Wert.

## Genaue Syntax

```text
JsonNull() -> Object
```

## Parameter

Keine Parameter.

## Rückgabewert

JsonNull-Objekt, serialisiert als null, weder0 noch leerer String. Prüfen mit JsonKind(value)="null".

## Verhalten

- Lokale Basic-Funktionen ohne UO. und ohne Spielpakete. JsonParse/JsonStringify arbeiten im Speicher. Basic True wird als Zahl1 geschrieben; für JSON true JsonBoolean(True) verwenden. JsonNull() trennt null von0.
- Nur endliche Zahlen. Ganzzahlige Werte außerhalb ±9007199254740991 werden abgelehnt; große IDs als Strings speichern. Sonst gilt Double-Genauigkeit. Striktes UTF-8: Eingabe-BOM erlaubt, Ausgabe ohne BOM. Ungültiges Unicode ist ein Fehler.
- Grenzen:1048576 UTF-16-Codeeinheiten,4MiB Dateiausgabe,64 verschachtelte Container,100000 Wertknoten. Überschreitungen sind Fehler. Lesen erzeugt neue Sammlungen; Speichern klont keine Speicherobjekte.
- Save prüft alle Daten, erstellt Ordner, schreibt eine temporäre Nachbardatei, leert Puffer und verschiebt/ersetzt sie. Fehler/Abbruch vor Ersetzung erhalten die alte Datei. Temporärdateien werden entfernt, soweit das Betriebssystem es zulässt. Abgeschlossene Ersetzungen werden nicht zurückgenommen.
- Pause/Stopp werden alle256 Werte, zwischen4096-Byte/Zeichen-Blöcken und vor Ersetzung geprüft. Kein zusätzlicher Thread; OS-Aufrufe sind nicht zwangsweise unterbrechbar. Gleichzeitiges Speichern: letzte erfolgreiche Ersetzung gewinnt; keine Datenbanktransaktion.

### Interne Funktionen: vom Aufruf zum Ergebnis

Erzeugt einen expliziten JSON-null-Wert.

#### 1. JsonNullObject



JsonNull-Objekt, serialisiert als null, weder0 noch leerer String. Prüfen mit JsonKind(value)="null".

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/JsonPrimitiveObjects.cs`; Funktion `JsonNullObject`.

Config.Load(fileName, defaults) liefert ein neues Dictionary: gespeicherte oberste Schlüssel überschreiben eine tiefe Kopie von defaults. Verschachtelte Objekte werden vollständig ersetzt. Config.Save(fileName, settings) speichert ausdrücklich, ohne Rückgabewert. Config.GetFlag(settings, key, fallback=False) liefert1/True oder0/False; vorhandene nichtlogische Werte verursachen Fehler. Config.SetFlag(settings, key, value) ändert nur den Speicher und liefert nichts. Load/Save benötigen Dictionaries mit String-Schlüsseln. Private RequireObject prüft die äußere Art; JSON prüft den gesamten Inhalt.


## Beispiele

### JsonNull · 1

```vb
# JsonNull · 1
#
# Erzeugt einen expliziten JSON-null-Wert.
#
# JsonNull-Objekt, serialisiert als null, weder0 noch leerer String. Prüfen mit
# JsonKind(value)="null".

Option Explicit On
Sub Main()
    # Main ausführen. JsonNull() → Object; JsonStringify → String "null".

    Return JsonStringify(JsonNull())
End Sub
```

**Erläuterung der Parameter und Ausführung:**

- Main ausführen. JsonNull() → Object; JsonStringify → String "null".

### JsonNull · 2

```vb
# JsonNull · 2
#
# Erzeugt einen expliziten JSON-null-Wert.
#
# JsonNull-Objekt, serialisiert als null, weder0 noch leerer String. Prüfen mit
# JsonKind(value)="null".

Option Explicit On
Sub Main()
    # Main ausführen. JsonNull() → d["selected"]; JsonKind comparison → Integer1/True.

    Dim d=Dictionary()
    d['selected']=JsonNull()
    Return JsonKind(d['selected'])='null'
End Sub
```

**Erläuterung der Parameter und Ausführung:**

- Main ausführen. JsonNull() → d["selected"]; JsonKind comparison → Integer1/True.

### JsonNull · 3

```vb
# JsonNull · 3
#
# Erzeugt einen expliziten JSON-null-Wert.
#
# JsonNull-Objekt, serialisiert als null, weder0 noch leerer String. Prüfen mit
# JsonKind(value)="null".

Option Explicit On
Sub Main()
    # Main ausführen. JsonNull(),0,"" → three distinct values → String [null,0,""] .

    Dim a=List()
    a.Add(JsonNull())
    a.Add(0)
    a.Add('')
    Return JsonStringify(a)
End Sub
```

**Erläuterung der Parameter und Ausführung:**

- Main ausführen. JsonNull(),0,"" → three distinct values → String [null,0,""] .
