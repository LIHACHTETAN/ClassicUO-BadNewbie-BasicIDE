# JsonBoolean

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: de -->

Erzeugt einen expliziten JSON-Wahrheitswert.

## Genaue Syntax

```text
JsonBoolean(value:Any) -> Object
```

## Parameter

- `value` — Zahl oder numerischer String:0=false, sonst true. Basic True/False sind1/0. Einen gelesenen JSON-Wahrheitswert mit flag.Value() auswerten.

## Rückgabewert

JsonBoolean-Objekt, serialisiert als true/false. Value() liefert Integer1/True oder0/False für If. Das Objekt selbst ist kein numerischer Schalter.

## Verhalten

- Lokale Basic-Funktionen ohne UO. und ohne Spielpakete. JsonParse/JsonStringify arbeiten im Speicher. Basic True wird als Zahl1 geschrieben; für JSON true JsonBoolean(True) verwenden. JsonNull() trennt null von0.
- Nur endliche Zahlen. Ganzzahlige Werte außerhalb ±9007199254740991 werden abgelehnt; große IDs als Strings speichern. Sonst gilt Double-Genauigkeit. Striktes UTF-8: Eingabe-BOM erlaubt, Ausgabe ohne BOM. Ungültiges Unicode ist ein Fehler.
- Grenzen:1048576 UTF-16-Codeeinheiten,4MiB Dateiausgabe,64 verschachtelte Container,100000 Wertknoten. Überschreitungen sind Fehler. Lesen erzeugt neue Sammlungen; Speichern klont keine Speicherobjekte.
- Save prüft alle Daten, erstellt Ordner, schreibt eine temporäre Nachbardatei, leert Puffer und verschiebt/ersetzt sie. Fehler/Abbruch vor Ersetzung erhalten die alte Datei. Temporärdateien werden entfernt, soweit das Betriebssystem es zulässt. Abgeschlossene Ersetzungen werden nicht zurückgenommen.
- Pause/Stopp werden alle256 Werte, zwischen4096-Byte/Zeichen-Blöcken und vor Ersetzung geprüft. Kein zusätzlicher Thread; OS-Aufrufe sind nicht zwangsweise unterbrechbar. Gleichzeitiges Speichern: letzte erfolgreiche Ersetzung gewinnt; keine Datenbanktransaktion.

### Interne Funktionen: vom Aufruf zum Ergebnis

Erzeugt einen expliziten JSON-Wahrheitswert.

#### 1. BasicJsonBoolean

Zahl oder numerischer String:0=false, sonst true. Basic True/False sind1/0. Einen gelesenen JSON-Wahrheitswert mit flag.Value() auswerten.

JsonBoolean-Objekt, serialisiert als true/false. Value() liefert Integer1/True oder0/False für If. Das Objekt selbst ist kein numerischer Schalter.

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApi.cs`; Funktion `BasicJsonBoolean`.

Config.Load(fileName, defaults) liefert ein neues Dictionary: gespeicherte oberste Schlüssel überschreiben eine tiefe Kopie von defaults. Verschachtelte Objekte werden vollständig ersetzt. Config.Save(fileName, settings) speichert ausdrücklich, ohne Rückgabewert. Config.GetFlag(settings, key, fallback=False) liefert1/True oder0/False; vorhandene nichtlogische Werte verursachen Fehler. Config.SetFlag(settings, key, value) ändert nur den Speicher und liefert nichts. Load/Save benötigen Dictionaries mit String-Schlüsseln. Private RequireObject prüft die äußere Art; JSON prüft den gesamten Inhalt.


## Beispiele

### JsonBoolean · 1

```vb
# JsonBoolean · 1
#
# Erzeugt einen expliziten JSON-Wahrheitswert.
#
# JsonBoolean-Objekt, serialisiert als true/false. Value() liefert Integer1/True oder0/False für
# If. Das Objekt selbst ist kein numerischer Schalter.

Option Explicit On
Sub Main()
    # Main ausführen. value=True=1 → JSON true; flag.Value()=1 → If → "enabled".

    Dim flag=JsonBoolean(True)
    If flag.Value() Then
    Return 'enabled'
    End If
    Return 'disabled'
End Sub
```

**Erläuterung der Parameter und Ausführung:**

- Main ausführen. value=True=1 → JSON true; flag.Value()=1 → If → "enabled".

### JsonBoolean · 2

```vb
# JsonBoolean · 2
#
# Erzeugt einen expliziten JSON-Wahrheitswert.
#
# JsonBoolean-Objekt, serialisiert als true/false. Value() liefert Integer1/True oder0/False für
# If. Das Objekt selbst ist kein numerischer Schalter.

Option Explicit On
Sub Main()
    # Main ausführen. value=0 → JSON false; Value() → Integer0/False; Main → "false:0".

    Dim flag=JsonBoolean(value:=0)
    Return JsonStringify(flag) & ':' & CStr(flag.Value())
End Sub
```

**Erläuterung der Parameter und Ausführung:**

- Main ausführen. value=0 → JSON false; Value() → Integer0/False; Main → "false:0".

### JsonBoolean · 3

```vb
# JsonBoolean · 3
#
# Erzeugt einen expliziten JSON-Wahrheitswert.
#
# JsonBoolean-Objekt, serialisiert als true/false. Value() liefert Integer1/True oder0/False für
# If. Das Objekt selbst ist kein numerischer Schalter.

Option Explicit On
Sub Main()
    # Main ausführen. value=-2 → JSON true; Basic True → number1; Main → String [true,1].

    Dim values=List()
    values.Add(JsonBoolean(-2))
    values.Add(True)
    Return JsonStringify(values)
End Sub
```

**Erläuterung der Parameter und Ausführung:**

- Main ausführen. value=-2 → JSON true; Basic True → number1; Main → String [true,1].
