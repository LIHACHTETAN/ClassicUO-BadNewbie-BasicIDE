# JsonSave

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: de -->

Speichert einen Wert in einer JSON-Datei.

## Genaue Syntax

```text
JsonSave(fileName:String, value:Any) -> Unit
JsonSave(fileName:String, value:Any, indented:Integer) -> Unit
```

## Parameter

- `fileName` — Erforderlicher Dateipfad. Relative Pfade beziehen sich auf den Hauptskriptordner, auch innerhalb von Include. Absolute Pfade sind erlaubt.
- `value` — Zahl, String, Array, List, Dictionary, JsonBoolean oder JsonNull. Dictionary-Schlüssel müssen Strings sein. Gemeinsame Referenzen sind erlaubt, Zyklen nicht.
- `indented` — Integer-Schalter:0 kompakt, ungleich0 eingerückt. Standard:Stringify=0, Save=1.

## Rückgabewert

Unit: kein Rückgabewert. Normales Ende bedeutet Erfolg; Fehler mit Try/Catch behandeln.

## Verhalten

- Lokale Basic-Funktionen ohne UO. und ohne Spielpakete. JsonParse/JsonStringify arbeiten im Speicher. Basic True wird als Zahl1 geschrieben; für JSON true JsonBoolean(True) verwenden. JsonNull() trennt null von0.
- Nur endliche Zahlen. Ganzzahlige Werte außerhalb ±9007199254740991 werden abgelehnt; große IDs als Strings speichern. Sonst gilt Double-Genauigkeit. Striktes UTF-8: Eingabe-BOM erlaubt, Ausgabe ohne BOM. Ungültiges Unicode ist ein Fehler.
- Grenzen:1048576 UTF-16-Codeeinheiten,4MiB Dateiausgabe,64 verschachtelte Container,100000 Wertknoten. Überschreitungen sind Fehler. Lesen erzeugt neue Sammlungen; Speichern klont keine Speicherobjekte.
- Save prüft alle Daten, erstellt Ordner, schreibt eine temporäre Nachbardatei, leert Puffer und verschiebt/ersetzt sie. Fehler/Abbruch vor Ersetzung erhalten die alte Datei. Temporärdateien werden entfernt, soweit das Betriebssystem es zulässt. Abgeschlossene Ersetzungen werden nicht zurückgenommen.
- Pause/Stopp werden alle256 Werte, zwischen4096-Byte/Zeichen-Blöcken und vor Ersetzung geprüft. Kein zusätzlicher Thread; OS-Aufrufe sind nicht zwangsweise unterbrechbar. Gleichzeitiges Speichern: letzte erfolgreiche Ersetzung gewinnt; keine Datenbanktransaktion.

### Interne Funktionen: vom Aufruf zum Ergebnis

Speichert einen Wert in einer JSON-Datei.

#### 1. Save

Erforderlicher Dateipfad. Relative Pfade beziehen sich auf den Hauptskriptordner, auch innerhalb von Include. Absolute Pfade sind erlaubt. Zahl, String, Array, List, Dictionary, JsonBoolean oder JsonNull. Dictionary-Schlüssel müssen Strings sein. Gemeinsame Referenzen sind erlaubt, Zyklen nicht. Integer-Schalter:0 kompakt, ungleich0 eingerückt. Standard:Stringify=0, Save=1.

Unit: kein Rückgabewert. Normales Ende bedeutet Erfolg; Fehler mit Try/Catch behandeln.

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; Funktion `Save`.

Config.Load(fileName, defaults) liefert ein neues Dictionary: gespeicherte oberste Schlüssel überschreiben eine tiefe Kopie von defaults. Verschachtelte Objekte werden vollständig ersetzt. Config.Save(fileName, settings) speichert ausdrücklich, ohne Rückgabewert. Config.GetFlag(settings, key, fallback=False) liefert1/True oder0/False; vorhandene nichtlogische Werte verursachen Fehler. Config.SetFlag(settings, key, value) ändert nur den Speicher und liefert nichts. Load/Save benötigen Dictionaries mit String-Schlüsseln. Private RequireObject prüft die äußere Art; JSON prüft den gesamten Inhalt.


## Beispiele

### JsonSave · 1

```vb
# JsonSave · 1
#
# Speichert einen Wert in einer JSON-Datei.
#
# Unit: kein Rückgabewert. Normales Ende bedeutet Erfolg; Fehler mit Try/Catch behandeln.

Option Explicit On
Sub Main()
    # Main ausführen. fileName="json-save-demo.json", value=d, indented=1 → file; JsonLoad →
    # delay=Integer350.

    Dim d=JsonParse('{"delay":350}')
    JsonSave('json-save-demo.json', d)
    Dim loaded=JsonLoad('json-save-demo.json')
    Return loaded['delay']
End Sub
```

**Erläuterung der Parameter und Ausführung:**

- Main ausführen. fileName="json-save-demo.json", value=d, indented=1 → file; JsonLoad → delay=Integer350.

### JsonSave · 2

```vb
# JsonSave · 2
#
# Speichert einen Wert in einer JSON-Datei.
#
# Unit: kein Rückgabewert. Normales Ende bedeutet Erfolg; Fehler mit Try/Catch behandeln.

Option Explicit On
Sub Main()
    # Main ausführen. fileName="json-save-array.json", value=List, indented=False=0 → compact
    # [true,null,7].

    JsonSave(indented:=False, value:=JsonParse('[true,null,7]'), fileName:='json-save-array.json')
    Return JsonStringify(JsonLoad('json-save-array.json'))
End Sub
```

**Erläuterung der Parameter und Ausführung:**

- Main ausführen. fileName="json-save-array.json", value=List, indented=False=0 → compact [true,null,7].

### JsonSave · 3

```vb
# JsonSave · 3
#
# Speichert einen Wert in einer JSON-Datei.
#
# Unit: kein Rückgabewert. Normales Ende bedeutet Erfolg; Fehler mit Try/Catch behandeln.

Option Explicit On
Sub Main()
    # Main ausführen. fileName="json-replace-demo.json", value=7; next value=cyclic List → Catch;
    # JsonLoad → original Integer7.

    JsonSave('json-replace-demo.json', 7)
    Dim cycle=List()
    cycle.Add(cycle)
    Try
    JsonSave('json-replace-demo.json', cycle)
    Catch problem
    Return JsonLoad('json-replace-demo.json')
    End Try
    Return 0
End Sub
```

**Erläuterung der Parameter und Ausführung:**

- Main ausführen. fileName="json-replace-demo.json", value=7; next value=cyclic List → Catch; JsonLoad → original Integer7.
