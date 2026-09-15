# UO.FindAtCoord

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: de -->

Sucht geladene Weltobjekte an einer exakten X/Y-Zelle der aktuellen Karte.

## Genaue Syntax

```text
UO.FindAtCoord(X:Any, Y:Any) -> Integer
```

## Parameter

- `X` — horizontale Weltkoordinate, Integer 0..65535. Erforderlich; keine Pixelposition im Behälterfenster.
- `Y` — vertikale Weltkoordinate, Integer 0..65535. Erforderlich. Es gibt keine zusätzlichen Argumente für Z, Karte, Typ oder Radius.

## Rückgabewert

Integer-Serial des ersten passenden Objekts in der Ergebnisliste dieses Clients. 0 bedeutet: kein Treffer, Spieler fehlt/ist entfernt oder Koordinaten außerhalb 0..65535. Das ist eine Objekt-ID, kein Typ, keine Anzahl und kein Boolean. Alle 32 Bits bleiben erhalten; mit <> 0 prüfen, nicht mit = TRUE oder > 0. Dieselbe ID wird FindItem().

## Verhalten

- Erfasst nicht entfernte Items auf dem Boden und Mobiles, auch den Spieler an dieser Zelle. Behälterinhalt und angelegte Gegenstände werden ausgeschlossen: deren X/Y sind keine Weltpositionen. Ignorierte Serials werden übersprungen.
- Alle Z-Höhen an diesen X/Y sind zulässig. FindDistance und FindVertical begrenzen diese genaue Zellensuche nicht. Nur geladene Objekte der aktuellen Welt sind sichtbar; Gelände, Statics oder fremde Karten werden nicht geladen. Kein Paket, Zielcursor oder Gegenstandstransfer wird ausgelöst.
- Jeder Aufruf leert zunächst die vorherigen Suchergebnisse. FindCount() zählt Objekte, FindFullQuantity() Stapelmengen (ein Mobile zählt eins), GetFoundItems() liefert Serials. Zuerst werden Items, dann Mobiles in der aktuellen Reihenfolge ihrer Sammlung geprüft. Die Liste vor einer weiteren Suche speichern.
- Referenz: [Stealth FindAtCoord](https://stealth.od.ua/api/FindAtCoord/). Die oben genannten Filter und Reihenfolgen gelten für diesen Client.

### Interne Funktionen: vom Aufruf zum Ergebnis

Dies sind die tatsächlichen internen Schritte. CountGraphicAt ist eine vollständig definierte Skriptfunktion, kein weiterer eingebauter Befehl.

#### 1. ExecuteStealthCompatibility

Der registrierte Laufzeitpfad wandelt zwei positionale oder benannte X/Y-Argumente um und liefert den Integer der Bridge zurück.

Integer-Serial des ersten passenden Objekts in der Ergebnisliste dieses Clients. 0 bedeutet: kein Treffer, Spieler fehlt/ist entfernt oder Koordinaten außerhalb 0..65535. Das ist eine Objekt-ID, kein Typ, keine Anzahl und kein Boolean. Alle 32 Bits bleiben erhalten; mit <> 0 prüfen, nicht mit = TRUE oder > 0. Dieselbe ID wird FindItem().

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; Funktion `ExecuteStealthCompatibility`.

#### 2. FindAtCoord

Auf dem Spielthread werden alte Ergebnisse gelöscht, Spieler und Koordinaten geprüft und passende Boden-Items sowie Mobiles durchsucht. Behälterinhalt wird ausgeschlossen.

Erfasst nicht entfernte Items auf dem Boden und Mobiles, auch den Spieler an dieser Zelle. Behälterinhalt und angelegte Gegenstände werden ausgeschlossen: deren X/Y sind keine Weltpositionen. Ignorierte Serials werden übersprungen.

Projektquelle: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; Funktion `FindAtCoord`.

#### 3. RegisterFound

Jeder Treffer erhöht den Zähler und ergänzt die Serial. Die erste Serial bleibt FindItem; Item.Amount trägt mindestens eine Einheit bei, ein Mobile genau eine.

Jeder Aufruf leert zunächst die vorherigen Suchergebnisse. FindCount() zählt Objekte, FindFullQuantity() Stapelmengen (ein Mobile zählt eins), GetFoundItems() liefert Serials. Zuerst werden Items, dann Mobiles in der aktuellen Reihenfolge ihrer Sammlung geprüft. Die Liste vor einer weiteren Suche speichern.

Projektquelle: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; Funktion `RegisterFound`.

Alle Z-Höhen an diesen X/Y sind zulässig. FindDistance und FindVertical begrenzen diese genaue Zellensuche nicht. Nur geladene Objekte der aktuellen Welt sind sichtbar; Gelände, Statics oder fremde Karten werden nicht geladen. Kein Paket, Zielcursor oder Gegenstandstransfer wird ausgelöst.


## Beispiele

### Eine Objekt-ID lesen

```vb
# Eine Objekt-ID lesen
#
# Sucht geladene Weltobjekte an einer exakten X/Y-Zelle der aktuellen Karte.
#
# Integer-Serial des ersten passenden Objekts in der Ergebnisliste dieses Clients. 0 bedeutet:
# kein Treffer, Spieler fehlt/ist entfernt oder Koordinaten außerhalb 0..65535. Das ist eine
# Objekt-ID, kein Typ, keine Anzahl und kein Boolean. Alle 32 Bits bleiben erhalten; mit <> 0
# prüfen, nicht mit = TRUE oder > 0. Dieselbe ID wird FindItem().

SUB Main()
    # 1445 und 1690 sind beispielhafte Weltkoordinaten; durch die eigene Zelle ersetzen. id
    # speichert die Serial, HEX formatiert sie. <> 0 prüft einen Treffer, keine Anzahl.

    VAR id = UO.FindAtCoord(1445, 1690)
    IF id <> 0 THEN
        UO.Print(HEX(id))
    ELSE
        UO.Print('No loaded object')
    END IF
END SUB
```

**Erläuterung der Parameter und Ausführung:**

- 1445 und 1690 sind beispielhafte Weltkoordinaten; durch die eigene Zelle ersetzen. id speichert die Serial, HEX formatiert sie. <> 0 prüft einen Treffer, keine Anzahl.

### Alle Objekte an der Spielerzelle prüfen

```vb
# Alle Objekte an der Spielerzelle prüfen
#
# Sucht geladene Weltobjekte an einer exakten X/Y-Zelle der aktuellen Karte.
#
# Integer-Serial des ersten passenden Objekts in der Ergebnisliste dieses Clients. 0 bedeutet:
# kein Treffer, Spieler fehlt/ist entfernt oder Koordinaten außerhalb 0..65535. Das ist eine
# Objekt-ID, kein Typ, keine Anzahl und kein Boolean. Alle 32 Bits bleiben erhalten; mit <> 0
# prüfen, nicht mit = TRUE oder > 0. Dieselbe ID wird FindItem().

SUB Main()
    # x/y stammen vom Spieler; ids speichert die aktuelle Liste. Jede ID steht für ein Objekt, auch
    # einen ganzen Stapel. GetType(id) liest Graphic/Body. Nichts wird ausgewählt oder benutzt.

    VAR x = UO.GetX('self')
    VAR y = UO.GetY('self')
    UO.FindAtCoord(x, y)
    VAR ids = UO.GetFoundItems()
    FOR EACH id IN ids
        UO.Print(HEX(id) + ' type=' + HEX(UO.GetType(id)))
    NEXT
END SUB
```

**Erläuterung der Parameter und Ausführung:**

- x/y stammen vom Spieler; ids speichert die aktuelle Liste. Jede ID steht für ein Objekt, auch einen ganzen Stapel. GetType(id) liest Graphic/Body. Nichts wird ausgewählt oder benutzt.

### Vollständige Hilfsfunktion CountGraphicAt

```vb
# Vollständige Hilfsfunktion CountGraphicAt
#
# Sucht geladene Weltobjekte an einer exakten X/Y-Zelle der aktuellen Karte.
#
# Integer-Serial des ersten passenden Objekts in der Ergebnisliste dieses Clients. 0 bedeutet:
# kein Treffer, Spieler fehlt/ist entfernt oder Koordinaten außerhalb 0..65535. Das ist eine
# Objekt-ID, kein Typ, keine Anzahl und kein Boolean. Alle 32 Bits bleiben erhalten; mit <> 0
# prüfen, nicht mit = TRUE oder > 0. Dieselbe ID wird FindItem().

SUB Main()
    # CountGraphicAt(x, y, graphic) sucht einmal und zählt in den gespeicherten IDs die passende
    # Grafik. graphic=0x0EED bedeutet Gold. Rückgabe ist die Anzahl der Objekte/Stapel, weder
    # Einheitenmenge noch true/false; ein Stapel zählt eins. Die vollständige Funktion steht unter
    # Main.

    VAR count = CountGraphicAt(1445, 1690, 0x0EED)
    UO.Print('Objects/stacks: ' + CStr(count))
END SUB

FUNCTION CountGraphicAt(x, y, graphic)
    UO.FindAtCoord(x, y)
    VAR ids = UO.GetFoundItems()
    VAR count = 0
    FOR EACH id IN ids
        IF UO.GetType(id) = graphic THEN
            count += 1
        END IF
    NEXT
    RETURN count
END FUNCTION
```

**Erläuterung der Parameter und Ausführung:**

- CountGraphicAt(x, y, graphic) sucht einmal und zählt in den gespeicherten IDs die passende Grafik. graphic=0x0EED bedeutet Gold. Rückgabe ist die Anzahl der Objekte/Stapel, weder Einheitenmenge noch true/false; ein Stapel zählt eins. Die vollständige Funktion steht unter Main.
