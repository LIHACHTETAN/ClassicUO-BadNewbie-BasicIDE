# UO.Dist

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: de -->

Berechnet die Kachelentfernung als größere absolute Differenz von X und Y.

## Genaue Syntax

```text
UO.Dist(Xfrom:Any, Yfrom:Any, Xto:Any, Yto:Any) -> Integer
```

## Parameter

- `Xfrom` — X des Startpunkts.
- `Yfrom` — Y des Startpunkts.
- `Xto` — X des Zielpunkts.
- `Yto` — Y des Zielpunkts.

## Rückgabewert

Integer-Kachelanzahl, für gültige Koordinaten nicht negativ. 0 bedeutet gleiche XY, 1 eine Kachel. Kein Erfolgsflag. Erst ein Vergleich wie distance<=2 ergibt 1/True oder 0/False.

## Verhalten

- Reine Berechnung ohne Pakete, Warten, Kartenladen, Hindernis-, Z- oder Facettenprüfung. Kein begehbarer Weg und keine Ankunftsgarantie. Punkte müssen im gleichen Koordinatensystem liegen; Umwege können länger sein.
- Alle vier Parameter sind nötig: Integer-Weltkoordinaten im dokumentierten Bereich 0..65535. Any bezeichnet den Adapter, keine Objekt-ID. Keine Vorgaben, Containerkoordinaten, fünfte Z-Koordinate oder Ein-Objekt-Überladung.
- Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). Vertauschte Punkte liefern denselben Wert. Keine euklidische Distanz, keine Summe und keine Hindernisroute.

### Interne Funktionen: vom Aufruf zum Ergebnis

Beispiel 3 rekonstruiert den Algorithmus als Skriptfunktion. Der Interpreter ruft intern nicht diesen Lernhelfer auf.

#### 1. ExecuteStealthCompatibility

Der Adapter liest Argumente 0..3 als ganze Zahlen Xfrom,Yfrom,Xto,Yto und ruft den Berechnungshelfer auf.

Integer-Kachelanzahl, für gültige Koordinaten nicht negativ. 0 bedeutet gleiche XY, 1 eine Kachel. Kein Erfolgsflag. Erst ein Vergleich wie distance<=2 ergibt 1/True oder 0/False.

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; Funktion `ExecuteStealthCompatibility`.

#### 2. GetDistance

`GetDistance(int,int,int,int): dx=Math.Abs(x1-x2); dy=Math.Abs(y1-y2); return Math.Max(dx,dy).`

Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). Vertauschte Punkte liefern denselben Wert. Keine euklidische Distanz, keine Summe und keine Hindernisroute.

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; Funktion `GetDistance`.

Reine Berechnung ohne Pakete, Warten, Kartenladen, Hindernis-, Z- oder Facettenprüfung. Kein begehbarer Weg und keine Ankunftsgarantie. Punkte müssen im gleichen Koordinatensystem liegen; Umwege können länger sein.


## Beispiele

### Direkt berechnen

```vb
# Direkt berechnen
#
# Berechnet die Kachelentfernung als größere absolute Differenz von X und Y.
#
# Integer-Kachelanzahl, für gültige Koordinaten nicht negativ. 0 bedeutet gleiche XY, 1 eine
# Kachel. Kein Erfolgsflag. Erst ein Vergleich wie distance<=2 ergibt 1/True oder 0/False.

SUB Main()
    # (100,100) und (103,104) ergeben Differenzen 3 und 4. Das Maximum ist 4; Main liefert Integer
    # 4.
    # Integer-Kachelanzahl, für gültige Koordinaten nicht negativ. 0 bedeutet gleiche XY, 1 eine
    # Kachel. Kein Erfolgsflag. Erst ein Vergleich wie distance<=2 ergibt 1/True oder 0/False.
    # Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). Vertauschte Punkte liefern denselben Wert. Keine
    # euklidische Distanz, keine Summe und keine Hindernisroute.

    Return UO.Dist(100,100,103,104)
END SUB
```

**Erläuterung der Parameter und Ausführung:**

- (100,100) und (103,104) ergeben Differenzen 3 und 4. Das Maximum ist 4; Main liefert Integer 4.
- Integer-Kachelanzahl, für gültige Koordinaten nicht negativ. 0 bedeutet gleiche XY, 1 eine Kachel. Kein Erfolgsflag. Erst ein Vergleich wie distance<=2 ergibt 1/True oder 0/False.
- Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). Vertauschte Punkte liefern denselben Wert. Keine euklidische Distanz, keine Summe und keine Hindernisroute.

### Ergebnis richtig prüfen

```vb
# Ergebnis richtig prüfen
#
# Berechnet die Kachelentfernung als größere absolute Differenz von X und Y.
#
# Integer-Kachelanzahl, für gültige Koordinaten nicht negativ. 0 bedeutet gleiche XY, 1 eine
# Kachel. Kein Erfolgsflag. Erst ein Vergleich wie distance<=2 ergibt 1/True oder 0/False.

SUB Main()
    # (100,100) und (101,99) liegen eine Kachel auseinander. distance<=2 ist True=1. In "1:1" ist
    # die erste Zahl die Entfernung, die zweite das logische Ergebnis.
    # Integer-Kachelanzahl, für gültige Koordinaten nicht negativ. 0 bedeutet gleiche XY, 1 eine
    # Kachel. Kein Erfolgsflag. Erst ein Vergleich wie distance<=2 ergibt 1/True oder 0/False.
    # Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). Vertauschte Punkte liefern denselben Wert. Keine
    # euklidische Distanz, keine Summe und keine Hindernisroute.

    Dim distance=UO.Dist(100,100,101,99)
    Dim close=distance<=2
    Return CStr(distance) & ":" & CStr(close)
END SUB
```

**Erläuterung der Parameter und Ausführung:**

- (100,100) und (101,99) liegen eine Kachel auseinander. distance<=2 ist True=1. In "1:1" ist die erste Zahl die Entfernung, die zweite das logische Ergebnis.
- Integer-Kachelanzahl, für gültige Koordinaten nicht negativ. 0 bedeutet gleiche XY, 1 eine Kachel. Kein Erfolgsflag. Erst ein Vergleich wie distance<=2 ergibt 1/True oder 0/False.
- Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). Vertauschte Punkte liefern denselben Wert. Keine euklidische Distanz, keine Summe und keine Hindernisroute.

### Vollständiger Skriptalgorithmus

```vb
# Vollständiger Skriptalgorithmus
#
# Berechnet die Kachelentfernung als größere absolute Differenz von X und Y.
#
# Integer-Kachelanzahl, für gültige Koordinaten nicht negativ. 0 bedeutet gleiche XY, 1 eine
# Kachel. Kein Erfolgsflag. Erst ein Vergleich wie distance<=2 ergibt 1/True oder 0/False.

SUB Main()
    # UO.Dist und RebuildTileDistance liefern beide 4; Main liefert "4:4". Der vollständig gezeigte
    # Helfer berechnet Abs-Differenzen und gibt die größere zurück. Er ist Beispielcode, kein
    # weiterer API-Befehl.
    # Integer-Kachelanzahl, für gültige Koordinaten nicht negativ. 0 bedeutet gleiche XY, 1 eine
    # Kachel. Kein Erfolgsflag. Erst ein Vergleich wie distance<=2 ergibt 1/True oder 0/False.
    # Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). Vertauschte Punkte liefern denselben Wert. Keine
    # euklidische Distanz, keine Summe und keine Hindernisroute.

    Dim actual=UO.Dist(100,100,103,104)
    Dim rebuilt=RebuildTileDistance(100,100,103,104)
    Return CStr(actual) & ":" & CStr(rebuilt)
END SUB

Function RebuildTileDistance(Xfrom, Yfrom, Xto, Yto) As Integer
    Dim dx = Abs(Xto-Xfrom)
    Dim dy = Abs(Yto-Yfrom)
    If dx>dy Then
        Return dx
    End If
    Return dy
End Function
```

**Erläuterung der Parameter und Ausführung:**

- UO.Dist und RebuildTileDistance liefern beide 4; Main liefert "4:4". Der vollständig gezeigte Helfer berechnet Abs-Differenzen und gibt die größere zurück. Er ist Beispielcode, kein weiterer API-Befehl.
- Integer-Kachelanzahl, für gültige Koordinaten nicht negativ. 0 bedeutet gleiche XY, 1 eine Kachel. Kein Erfolgsflag. Erst ein Vergleich wie distance<=2 ergibt 1/True oder 0/False.
- Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). Vertauschte Punkte liefern denselben Wert. Keine euklidische Distanz, keine Summe und keine Hindernisroute.
