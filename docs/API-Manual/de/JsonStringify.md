# JsonStringify

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: de -->

Erzeugt JSON-Text aus Basic-Werten.

## Genaue Syntax

```text
JsonStringify(value:Any) -> String
JsonStringify(value:Any, indented:Integer) -> String
```

## Parameter

- `value` — Zahl, String, Array, List, Dictionary, JsonBoolean oder JsonNull. Dictionary-Schlüssel müssen Strings sein. Gemeinsame Referenzen sind erlaubt, Zyklen nicht.
- `indented` — Integer-Schalter:0 kompakt, ungleich0 eingerückt. Standard:Stringify=0, Save=1.

## Rückgabewert

String mit JSON; erstellt keine Datei.

## Verhalten

- Lokale Basic-Funktionen ohne UO. und ohne Spielpakete. JsonParse/JsonStringify arbeiten im Speicher. Basic True wird als Zahl1 geschrieben; für JSON true JsonBoolean(True) verwenden. JsonNull() trennt null von0.
- Nur endliche Zahlen. Ganzzahlige Werte außerhalb ±9007199254740991 werden abgelehnt; große IDs als Strings speichern. Sonst gilt Double-Genauigkeit. Striktes UTF-8: Eingabe-BOM erlaubt, Ausgabe ohne BOM. Ungültiges Unicode ist ein Fehler.
- Grenzen:1048576 UTF-16-Codeeinheiten,4MiB Dateiausgabe,64 verschachtelte Container,100000 Wertknoten. Überschreitungen sind Fehler. Lesen erzeugt neue Sammlungen; Speichern klont keine Speicherobjekte.
- Save prüft alle Daten, erstellt Ordner, schreibt eine temporäre Nachbardatei, leert Puffer und verschiebt/ersetzt sie. Fehler/Abbruch vor Ersetzung erhalten die alte Datei. Temporärdateien werden entfernt, soweit das Betriebssystem es zulässt. Abgeschlossene Ersetzungen werden nicht zurückgenommen.
- Pause/Stopp werden alle256 Werte, zwischen4096-Byte/Zeichen-Blöcken und vor Ersetzung geprüft. Kein zusätzlicher Thread; OS-Aufrufe sind nicht zwangsweise unterbrechbar. Gleichzeitiges Speichern: letzte erfolgreiche Ersetzung gewinnt; keine Datenbanktransaktion.

### Interne Funktionen: vom Aufruf zum Ergebnis

Erzeugt JSON-Text aus Basic-Werten.

#### 1. Stringify

Zahl, String, Array, List, Dictionary, JsonBoolean oder JsonNull. Dictionary-Schlüssel müssen Strings sein. Gemeinsame Referenzen sind erlaubt, Zyklen nicht. Integer-Schalter:0 kompakt, ungleich0 eingerückt. Standard:Stringify=0, Save=1.

String mit JSON; erstellt keine Datei.

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; Funktion `Stringify`.

Config.Load(fileName, defaults) liefert ein neues Dictionary: gespeicherte oberste Schlüssel überschreiben eine tiefe Kopie von defaults. Verschachtelte Objekte werden vollständig ersetzt. Config.Save(fileName, settings) speichert ausdrücklich, ohne Rückgabewert. Config.GetFlag(settings, key, fallback=False) liefert1/True oder0/False; vorhandene nichtlogische Werte verursachen Fehler. Config.SetFlag(settings, key, value) ändert nur den Speicher und liefert nichts. Load/Save benötigen Dictionaries mit String-Schlüsseln. Private RequireObject prüft die äußere Art; JSON prüft den gesamten Inhalt.


## Beispiele

### JsonStringify · 1

```vb
# JsonStringify · 1
#
# Erzeugt JSON-Text aus Basic-Werten.
#
# String mit JSON; erstellt keine Datei.

Option Explicit On
Sub Main()
    # Main ausführen. value=Dictionary(name="ore",count=3), indented=0 → String
    # {"name":"ore","count":3}.

    Dim d=Dictionary()
    d['name']='ore'
    d['count']=3
    Return JsonStringify(d)
End Sub
```

**Erläuterung der Parameter und Ausführung:**

- Main ausführen. value=Dictionary(name="ore",count=3), indented=0 → String {"name":"ore","count":3}.

### JsonStringify · 2

```vb
# JsonStringify · 2
#
# Erzeugt JSON-Text aus Basic-Werten.
#
# String mit JSON; erstellt keine Datei.

Option Explicit On
Sub Main()
    # Main ausführen. value=d, indented=True=1; JsonParse(text) → independent Dictionary; JsonKind →
    # "boolean:null".

    Dim d=JsonParse('{"enabled":true,"empty":null}')
    Dim text=JsonStringify(value:=d, indented:=True)
    Dim copy=JsonParse(text)
    Return JsonKind(copy['enabled']) & ':' & JsonKind(copy['empty'])
End Sub
```

**Erläuterung der Parameter und Ausführung:**

- Main ausführen. value=d, indented=True=1; JsonParse(text) → independent Dictionary; JsonKind → "boolean:null".

### JsonStringify · 3

```vb
# JsonStringify · 3
#
# Erzeugt JSON-Text aus Basic-Werten.
#
# String mit JSON; erstellt keine Datei.

Option Explicit On
Sub Main()
    # Main ausführen. value=List → value[0]=value → Catch → "cycle".

    Dim d=List()
    d.Add(d)
    Try
    Dim text=JsonStringify(d)
    Catch problem
    Return 'cycle'
    End Try
    Return 'unexpected'
End Sub
```

**Erläuterung der Parameter und Ausführung:**

- Main ausführen. value=List → value[0]=value → Catch → "cycle".
