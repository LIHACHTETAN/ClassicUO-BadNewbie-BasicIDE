# UO.FindDistance

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: de -->

Liest oder ändert den voreingestellten horizontalen Suchradius.

## Genaue Syntax

```text
UO.FindDistance() -> Integer
UO.FindDistance(value:Any) -> Unit
```

## Parameter

- `value` — Optionaler Integer. Ohne Argument wird gelesen; value setzt den Wert. Begrenzung auf 0..255; negative Werte werden 0, nicht unbegrenzt. Neuer Runtime: 18; wiederhergestellter Zustand kann abweichen. Dezimalzahlen werden gegen null abgeschnitten; numerische decimal/0x-Zeichenketten sind ebenfalls zulässig. Integer vermeidet implizite Konvertierung.

## Rückgabewert

Ohne Argument: Integer, aktuelle Grenze (Entfernung in Feldern), keine Objekt-ID, Anzahl oder Boolean. 0 bedeutet eine Grenze von null, keinen Fehler. Mit value: Unit, kein Rückgabewert; weder TRUE/FALSE noch vorheriger Wert. Mit FindDistance() anschließend den gespeicherten Wert lesen.

## Verhalten

- Entfernung: max(abs(dx), abs(dy)) vom aktuellen Entfernungsursprung des Clients; diagonal zählt ein Feld. Grenze inklusive; 0 erlaubt nur dieselben X/Y. Bei bewegten Mobiles zählt die Endposition der Schrittwarteschlange.
- Im aktuellen Skript-Runtime gespeichert und von dessen Prozeduren geteilt; unabhängige Runtimes besitzen eigene Werte. Lesen/Schreiben sucht nicht, löscht FindItem/FindCount/GetFoundItems nicht, sendet keine Pakete, bewegt niemanden und lädt keine entfernten Objekte.
- FindTypeEx und FindTypesArrayEx nutzen die Grenzen am Boden, nicht im Behälter. Typ, Farbe, Ignore und geladene Objekte begrenzen weiterhin die Suche. FindAtCoord ignoriert beide Werte. Explizite distance/maxZ erweiterter Befehle können sie überschreiben; -1 dort nutzt den Standard, während -1 als Einstellung zu 0 wird. FindList filtert Z auch bei Behältern; die Behälterausnahme gilt dafür nicht.
- Vor einer temporären Suche speichern und in Finally wiederherstellen; kein automatisches Zurücksetzen. Finally gilt bei normalem Ende und abfangbaren Skriptfehlern. Notabbruch ist kein Aufräumverfahren.
- Referenz: [Stealth FindDistance](https://stealth.od.ua/api/FindDistance/). Dieser Client behält eigene Standardwerte/Grenzen: FindDistance 18 / 0..255; FindVertical 2 / 0..120. Basic-Syntax und erweiterte Filter beschreiben dieses Projekt.

### Interne Funktionen: vom Aufruf zum Ergebnis

Tatsächliche interne Schritte. CountGroundInRange ist eine vollständig definierte Benutzerfunktion, kein versteckter eingebauter Befehl.

#### 1. ExecuteStealthCompatibility

Ohne Argument wird gelesen; mit einem Argument wird value konvertiert und geschrieben. Metadaten unterscheiden Integer und Unit.

Ohne Argument: Integer, aktuelle Grenze (Entfernung in Feldern), keine Objekt-ID, Anzahl oder Boolean. 0 bedeutet eine Grenze von null, keinen Fehler. Mit value: Unit, kein Rückgabewert; weder TRUE/FALSE noch vorheriger Wert. Mit FindDistance() anschließend den gespeicherten Wert lesen.

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; Funktion `ExecuteStealthCompatibility`.

#### 2. GetFindDistance

Die Bridge liest die Runtime-Einstellung oder begrenzt und speichert den Integer. Keine Weltsuche.

Ohne Argument: Integer, aktuelle Grenze (Entfernung in Feldern), keine Objekt-ID, Anzahl oder Boolean. 0 bedeutet eine Grenze von null, keinen Fehler. Mit value: Unit, kein Rückgabewert; weder TRUE/FALSE noch vorheriger Wert. Mit FindDistance() anschließend den gespeicherten Wert lesen.

Projektquelle: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; Funktion `GetFindDistance`.

#### 3. SetFindDistance

Die Bridge liest die Runtime-Einstellung oder begrenzt und speichert den Integer. Keine Weltsuche.

Optionaler Integer. Ohne Argument wird gelesen; value setzt den Wert. Begrenzung auf 0..255; negative Werte werden 0, nicht unbegrenzt. Neuer Runtime: 18; wiederhergestellter Zustand kann abweichen. Dezimalzahlen werden gegen null abgeschnitten; numerische decimal/0x-Zeichenketten sind ebenfalls zulässig. Integer vermeidet implizite Konvertierung.

Projektquelle: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; Funktion `SetFindDistance`.

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
# Liest oder ändert den voreingestellten horizontalen Suchradius.
#
# Ohne Argument: Integer, aktuelle Grenze (Entfernung in Feldern), keine Objekt-ID, Anzahl oder
# Boolean. 0 bedeutet eine Grenze von null, keinen Fehler. Mit value: Unit, kein Rückgabewert;
# weder TRUE/FALSE noch vorheriger Wert. Mit FindDistance() anschließend den gespeicherten Wert
# lesen.

SUB Main()
    # previous speichert den tatsächlichen Wert. value:=5 setzt eine normale Grenze; 1000 wird auf
    # 255 begrenzt. Print liest separat. Finally stellt previous wieder her.

    VAR previous = UO.FindDistance()
    TRY
        UO.FindDistance(value:=5)
        UO.Print(CStr(UO.FindDistance()))
        UO.FindDistance(1000)
        UO.Print(CStr(UO.FindDistance()))
    FINALLY
        UO.FindDistance(previous)
    END TRY
END SUB
```

**Erläuterung der Parameter und Ausführung:**

- previous speichert den tatsächlichen Wert. value:=5 setzt eine normale Grenze; 1000 wird auf 255 begrenzt. Print liest separat. Finally stellt previous wieder her.

### Temporäre Bodensuche

```vb
# Temporäre Bodensuche
#
# Liest oder ändert den voreingestellten horizontalen Suchradius.
#
# Ohne Argument: Integer, aktuelle Grenze (Entfernung in Feldern), keine Objekt-ID, Anzahl oder
# Boolean. 0 bedeutet eine Grenze von null, keinen Fehler. Mit value: Unit, kein Rückgabewert;
# weder TRUE/FALSE noch vorheriger Wert. Mit FindDistance() anschließend den gespeicherten Wert
# lesen.

SUB Main()
    # previous erhält den Wert des Aufrufers. 5 ändert nur FindDistance; die andere Grenze bleibt.
    # 0x0EED: Goldgrafik; -1: beliebige Farbe; Container=-1: Welt; FALSE: keine Behälterrekursion.
    # id ist eine Serial, <> 0 prüft Vorhandensein. FindCount zählt Objekte/Stapel. Finally stellt
    # die Einstellung, nicht die Ergebnisliste wieder her.

    VAR previous = UO.FindDistance()
    TRY
        UO.FindDistance(5)
        VAR id = UO.FindTypeEx(0x0EED, -1, -1, FALSE)
        IF id <> 0 THEN
            UO.Print(HEX(id) + ':' + CStr(UO.FindCount()))
        ELSE
            UO.Print('0')
        END IF
    FINALLY
        UO.FindDistance(previous)
    END TRY
END SUB
```

**Erläuterung der Parameter und Ausführung:**

- previous erhält den Wert des Aufrufers. 5 ändert nur FindDistance; die andere Grenze bleibt. 0x0EED: Goldgrafik; -1: beliebige Farbe; Container=-1: Welt; FALSE: keine Behälterrekursion. id ist eine Serial, <> 0 prüft Vorhandensein. FindCount zählt Objekte/Stapel. Finally stellt die Einstellung, nicht die Ergebnisliste wieder her.

### Vollständige Funktion CountGroundInRange

```vb
# Vollständige Funktion CountGroundInRange
#
# Liest oder ändert den voreingestellten horizontalen Suchradius.
#
# Ohne Argument: Integer, aktuelle Grenze (Entfernung in Feldern), keine Objekt-ID, Anzahl oder
# Boolean. 0 bedeutet eine Grenze von null, keinen Fehler. Mit value: Unit, kein Rückgabewert;
# weder TRUE/FALSE noch vorheriger Wert. Mit FindDistance() anschließend den gespeicherten Wert
# lesen.

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
