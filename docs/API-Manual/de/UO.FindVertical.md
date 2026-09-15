# UO.FindVertical

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: de -->

Liest oder ändert den voreingestellten zulässigen Höhenunterschied bei der Suche.

## Genaue Syntax

```text
UO.FindVertical() -> Integer
UO.FindVertical(value:Any) -> Unit
```

## Parameter

- `value` — Optionaler Integer. Ohne Argument wird gelesen; value setzt den Wert. Begrenzung auf 0..120; negative Werte werden 0, nicht unbegrenzt. Neuer Runtime: 2; wiederhergestellter Zustand kann abweichen. Dezimalzahlen werden gegen null abgeschnitten; numerische decimal/0x-Zeichenketten sind ebenfalls zulässig. Integer vermeidet implizite Konvertierung.

## Rückgabewert

Ohne Argument: Integer, aktuelle Grenze (Differenz in Welt-Z-Einheiten), keine Objekt-ID, Anzahl oder Boolean. 0 bedeutet eine Grenze von null, keinen Fehler. Mit value: Unit, kein Rückgabewert; weder TRUE/FALSE noch vorheriger Wert. Mit FindVertical() anschließend den gespeicherten Wert lesen.

## Verhalten

- Höhe: abs(object.Z - player.Z), in beiden Richtungen inklusive Grenze. 0 erlaubt nur gleiches Z. Dies ist keine Stockwerksnummer und keine horizontale Entfernung.
- Im aktuellen Skript-Runtime gespeichert und von dessen Prozeduren geteilt; unabhängige Runtimes besitzen eigene Werte. Lesen/Schreiben sucht nicht, löscht FindItem/FindCount/GetFoundItems nicht, sendet keine Pakete, bewegt niemanden und lädt keine entfernten Objekte.
- FindTypeEx und FindTypesArrayEx nutzen die Grenzen am Boden, nicht im Behälter. Typ, Farbe, Ignore und geladene Objekte begrenzen weiterhin die Suche. FindAtCoord ignoriert beide Werte. Explizite distance/maxZ erweiterter Befehle können sie überschreiben; -1 dort nutzt den Standard, während -1 als Einstellung zu 0 wird. FindList filtert Z auch bei Behältern; die Behälterausnahme gilt dafür nicht.
- Vor einer temporären Suche speichern und in Finally wiederherstellen; kein automatisches Zurücksetzen. Finally gilt bei normalem Ende und abfangbaren Skriptfehlern. Notabbruch ist kein Aufräumverfahren.
- Referenz: [Stealth FindVertical](https://stealth.od.ua/api/FindVertical/). Dieser Client behält eigene Standardwerte/Grenzen: FindDistance 18 / 0..255; FindVertical 2 / 0..120. Basic-Syntax und erweiterte Filter beschreiben dieses Projekt.

### Interne Funktionen: vom Aufruf zum Ergebnis

Tatsächliche interne Schritte. CountGroundInRange ist eine vollständig definierte Benutzerfunktion, kein versteckter eingebauter Befehl.

#### 1. ExecuteStealthCompatibility

Ohne Argument wird gelesen; mit einem Argument wird value konvertiert und geschrieben. Metadaten unterscheiden Integer und Unit.

Ohne Argument: Integer, aktuelle Grenze (Differenz in Welt-Z-Einheiten), keine Objekt-ID, Anzahl oder Boolean. 0 bedeutet eine Grenze von null, keinen Fehler. Mit value: Unit, kein Rückgabewert; weder TRUE/FALSE noch vorheriger Wert. Mit FindVertical() anschließend den gespeicherten Wert lesen.

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; Funktion `ExecuteStealthCompatibility`.

#### 2. GetFindVertical

Die Bridge liest die Runtime-Einstellung oder begrenzt und speichert den Integer. Keine Weltsuche.

Ohne Argument: Integer, aktuelle Grenze (Differenz in Welt-Z-Einheiten), keine Objekt-ID, Anzahl oder Boolean. 0 bedeutet eine Grenze von null, keinen Fehler. Mit value: Unit, kein Rückgabewert; weder TRUE/FALSE noch vorheriger Wert. Mit FindVertical() anschließend den gespeicherten Wert lesen.

Projektquelle: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; Funktion `GetFindVertical`.

#### 3. SetFindVertical

Die Bridge liest die Runtime-Einstellung oder begrenzt und speichert den Integer. Keine Weltsuche.

Optionaler Integer. Ohne Argument wird gelesen; value setzt den Wert. Begrenzung auf 0..120; negative Werte werden 0, nicht unbegrenzt. Neuer Runtime: 2; wiederhergestellter Zustand kann abweichen. Dezimalzahlen werden gegen null abgeschnitten; numerische decimal/0x-Zeichenketten sind ebenfalls zulässig. Integer vermeidet implizite Konvertierung.

Projektquelle: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; Funktion `SetFindVertical`.

#### 4. FindType

Eine spätere Suche liest die Einstellung ohne explizite Überschreibung. Boden-Items und Mobiles durchlaufen die entsprechenden Entfernungs- und Höhenfilter.

FindTypeEx und FindTypesArrayEx nutzen die Grenzen am Boden, nicht im Behälter. Typ, Farbe, Ignore und geladene Objekte begrenzen weiterhin die Suche. FindAtCoord ignoriert beide Werte. Explizite distance/maxZ erweiterter Befehle können sie überschreiben; -1 dort nutzt den Standard, während -1 als Einstellung zu 0 wird. FindList filtert Z auch bei Behältern; die Behälterausnahme gilt dafür nicht.

Projektquelle: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; Funktion `FindType`.

#### 5. FindList

Eine spätere Suche liest die Einstellung ohne explizite Überschreibung. Boden-Items und Mobiles durchlaufen die entsprechenden Entfernungs- und Höhenfilter.

FindTypeEx und FindTypesArrayEx nutzen die Grenzen am Boden, nicht im Behälter. Typ, Farbe, Ignore und geladene Objekte begrenzen weiterhin die Suche. FindAtCoord ignoriert beide Werte. Explizite distance/maxZ erweiterter Befehle können sie überschreiben; -1 dort nutzt den Standard, während -1 als Einstellung zu 0 wird. FindList filtert Z auch bei Behältern; die Behälterausnahme gilt dafür nicht.

Projektquelle: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; Funktion `FindList`.

Im aktuellen Skript-Runtime gespeichert und von dessen Prozeduren geteilt; unabhängige Runtimes besitzen eigene Werte. Lesen/Schreiben sucht nicht, löscht FindItem/FindCount/GetFoundItems nicht, sendet keine Pakete, bewegt niemanden und lädt keine entfernten Objekte.


## Beispiele

### Lesen, setzen und Begrenzung prüfen

```vb
# Lesen, setzen und Begrenzung prüfen
#
# Liest oder ändert den voreingestellten zulässigen Höhenunterschied bei der Suche.
#
# Ohne Argument: Integer, aktuelle Grenze (Differenz in Welt-Z-Einheiten), keine Objekt-ID,
# Anzahl oder Boolean. 0 bedeutet eine Grenze von null, keinen Fehler. Mit value: Unit, kein
# Rückgabewert; weder TRUE/FALSE noch vorheriger Wert. Mit FindVertical() anschließend den
# gespeicherten Wert lesen.

SUB Main()
    # previous speichert den tatsächlichen Wert. value:=10 setzt eine normale Grenze; 1000 wird auf
    # 120 begrenzt. Print liest separat. Finally stellt previous wieder her.

    VAR previous = UO.FindVertical()
    TRY
        UO.FindVertical(value:=10)
        UO.Print(CStr(UO.FindVertical()))
        UO.FindVertical(1000)
        UO.Print(CStr(UO.FindVertical()))
    FINALLY
        UO.FindVertical(previous)
    END TRY
END SUB
```

**Erläuterung der Parameter und Ausführung:**

- previous speichert den tatsächlichen Wert. value:=10 setzt eine normale Grenze; 1000 wird auf 120 begrenzt. Print liest separat. Finally stellt previous wieder her.

### Temporäre Bodensuche

```vb
# Temporäre Bodensuche
#
# Liest oder ändert den voreingestellten zulässigen Höhenunterschied bei der Suche.
#
# Ohne Argument: Integer, aktuelle Grenze (Differenz in Welt-Z-Einheiten), keine Objekt-ID,
# Anzahl oder Boolean. 0 bedeutet eine Grenze von null, keinen Fehler. Mit value: Unit, kein
# Rückgabewert; weder TRUE/FALSE noch vorheriger Wert. Mit FindVertical() anschließend den
# gespeicherten Wert lesen.

SUB Main()
    # previous erhält den Wert des Aufrufers. 10 ändert nur FindVertical; die andere Grenze bleibt.
    # 0x0EED: Goldgrafik; -1: beliebige Farbe; Container=-1: Welt; FALSE: keine Behälterrekursion.
    # id ist eine Serial, <> 0 prüft Vorhandensein. FindCount zählt Objekte/Stapel. Finally stellt
    # die Einstellung, nicht die Ergebnisliste wieder her.

    VAR previous = UO.FindVertical()
    TRY
        UO.FindVertical(10)
        VAR id = UO.FindTypeEx(0x0EED, -1, -1, FALSE)
        IF id <> 0 THEN
            UO.Print(HEX(id) + ':' + CStr(UO.FindCount()))
        ELSE
            UO.Print('0')
        END IF
    FINALLY
        UO.FindVertical(previous)
    END TRY
END SUB
```

**Erläuterung der Parameter und Ausführung:**

- previous erhält den Wert des Aufrufers. 10 ändert nur FindVertical; die andere Grenze bleibt. 0x0EED: Goldgrafik; -1: beliebige Farbe; Container=-1: Welt; FALSE: keine Behälterrekursion. id ist eine Serial, <> 0 prüft Vorhandensein. FindCount zählt Objekte/Stapel. Finally stellt die Einstellung, nicht die Ergebnisliste wieder her.

### Vollständige Funktion CountGroundInRange

```vb
# Vollständige Funktion CountGroundInRange
#
# Liest oder ändert den voreingestellten zulässigen Höhenunterschied bei der Suche.
#
# Ohne Argument: Integer, aktuelle Grenze (Differenz in Welt-Z-Einheiten), keine Objekt-ID,
# Anzahl oder Boolean. 0 bedeutet eine Grenze von null, keinen Fehler. Mit value: Unit, kein
# Rückgabewert; weder TRUE/FALSE noch vorheriger Wert. Mit FindVertical() anschließend den
# gespeicherten Wert lesen.

SUB Main()
    # CountGroundInRange(graphic, radius, height) speichert beide Grenzen, setzt radius=5 und
    # height=10, sucht graphic=0x0EED und liefert FindCount(). Ein Stapel ist ein Objekt.
    # Vollständige Funktion unter Main. Finally stellt beide Grenzen auch bei Return wieder her;
    # Suchergebnisse bleiben verfügbar.

    VAR count = CountGroundInRange(0x0EED, 5, 10)
    UO.Print(CStr(count))
END SUB

FUNCTION CountGroundInRange(graphic, radius, height)
    VAR oldDistance = UO.FindDistance()
    VAR oldVertical = UO.FindVertical()
    TRY
        UO.FindDistance(radius)
        UO.FindVertical(height)
        UO.FindTypeEx(graphic, -1, -1, FALSE)
        RETURN UO.FindCount()
    FINALLY
        UO.FindDistance(oldDistance)
        UO.FindVertical(oldVertical)
    END TRY
END FUNCTION
```

**Erläuterung der Parameter und Ausführung:**

- CountGroundInRange(graphic, radius, height) speichert beide Grenzen, setzt radius=5 und height=10, sucht graphic=0x0EED und liefert FindCount(). Ein Stapel ist ein Objekt. Vollständige Funktion unter Main. Finally stellt beide Grenzen auch bei Return wieder her; Suchergebnisse bleiben verfügbar.
