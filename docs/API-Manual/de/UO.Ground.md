# UO.Ground

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: de -->

Liefert den besonderen Boden-Selektor für den Suchbehälter oder das Transferziel.

## Genaue Syntax

```text
UO.Ground() -> Integer
```

## Parameter

Keine Parameter.

## Rückgabewert

Integer, immer 0. Diese Null bezeichnet gültig den Boden, nicht FALSE, einen Suchfehler, eine Objekt-ID, Grafik, Kartennummer oder Koordinate. Prüfen Sie das Ergebnis der Suche bzw. des Transfers, nicht Ground() als Erfolgswert.

## Verhalten

- Keine Parameter. Ground() allein sucht und bewegt nichts, öffnet kein Target, sendet keine Pakete und ändert keine Suchergebnisse. Auch vor der Anmeldung ist das Ergebnis 0.
- Als container/destination in FindType, FindList, Count, FindTypeEx, FindTypesArrayEx, CountEx oder MoveItem verwenden. Die Suche sieht geladene Weltobjekte, lädt aber keine entfernten Felder. Boden-X/Y/Z sind Weltkoordinaten, keine Behälterfenster-Pixel.
- FindType(type, color) durchsucht weiterhin das Inventar: Argument zwei ist die Farbe. Boden: FindType(type, color, UO.Ground()). Kompakte FindType/MoveItem verwenden -1 fürs Inventar; kompatible FindTypeEx/FindTypesArrayEx/CountEx akzeptieren -1 auch als Boden. UO.Ground() oder den Namen ground bevorzugen; Zahlenkonventionen unterscheiden sich.
- Primärquelle: [Stealth Ground](https://stealth.od.ua/api/Ground/). Die beschriebenen Konventionen und Beispiele gelten für diesen Client.

### Interne Funktionen: vom Aufruf zum Ergebnis

Tatsächliche interne Schritte. FindGroundTypes ist eine vollständige Benutzerfunktion, kein zusätzlicher eingebauter Befehl.

#### 1. ExecuteStealthCompatibility

Die Runtime gibt ohne Argumente Integer 0 zurück, ohne die Spiel-Bridge aufzurufen.

Integer, immer 0. Diese Null bezeichnet gültig den Boden, nicht FALSE, einen Suchfehler, eine Objekt-ID, Grafik, Kartennummer oder Koordinate. Prüfen Sie das Ergebnis der Suche bzw. des Transfers, nicht Ground() als Erfolgswert.

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; Funktion `ExecuteStealthCompatibility`.

#### 2. ConvertContainer

Der kompakte Suchadapter übersetzt explizit 0 in den internen Bodenbereich und behält -1 als Inventarstandard. Der kompatible Adapter akzeptiert 0 und historisch -1 als Boden; benannte Behälter werden separat aufgelöst.

FindType(type, color) durchsucht weiterhin das Inventar: Argument zwei ist die Farbe. Boden: FindType(type, color, UO.Ground()). Kompakte FindType/MoveItem verwenden -1 fürs Inventar; kompatible FindTypeEx/FindTypesArrayEx/CountEx akzeptieren -1 auch als Boden. UO.Ground() oder den Namen ground bevorzugen; Zahlenkonventionen unterscheiden sich.

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; Funktion `ConvertContainer`.

#### 3. ConvertStealthSearchContainer

Der kompakte Suchadapter übersetzt explizit 0 in den internen Bodenbereich und behält -1 als Inventarstandard. Der kompatible Adapter akzeptiert 0 und historisch -1 als Boden; benannte Behälter werden separat aufgelöst.

FindType(type, color) durchsucht weiterhin das Inventar: Argument zwei ist die Farbe. Boden: FindType(type, color, UO.Ground()). Kompakte FindType/MoveItem verwenden -1 fürs Inventar; kompatible FindTypeEx/FindTypesArrayEx/CountEx akzeptieren -1 auch als Boden. UO.Ground() oder den Namen ground bevorzugen; Zahlenkonventionen unterscheiden sich.

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; Funktion `ConvertStealthSearchContainer`.

#### 4. ResolveTransferDestination

Die Zielauflösung erhält Boden als 0. Die Client-Bridge verwendet Weltkoordinaten; das Containerfeld im Drop-Paket ist 0xFFFFFFFF. API-Selektor und Paketfeld sind unterschiedliche Darstellungen.

0x40001001 durch eine erreichbare Objekt-Serial ersetzen. IsObjectExists prüft das geladene Objekt. MoveItem(item, amount, destination, X, Y, Z): amount=0 bedeutet ganzer Stapel; Ground() wählt Boden; GetX/GetY/GetZ liefern das Spielerfeld. result=1 bedeutet, dass der Client die Anfrage annimmt, sonst 0. Das ist weder Ground()s Ergebnis noch eine Serverbestätigung.

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; Funktion `ResolveTransferDestination`.

#### 5. MoveItem

Die Zielauflösung erhält Boden als 0. Die Client-Bridge verwendet Weltkoordinaten; das Containerfeld im Drop-Paket ist 0xFFFFFFFF. API-Selektor und Paketfeld sind unterschiedliche Darstellungen.

0x40001001 durch eine erreichbare Objekt-Serial ersetzen. IsObjectExists prüft das geladene Objekt. MoveItem(item, amount, destination, X, Y, Z): amount=0 bedeutet ganzer Stapel; Ground() wählt Boden; GetX/GetY/GetZ liefern das Spielerfeld. result=1 bedeutet, dass der Client die Anfrage annimmt, sonst 0. Das ist weder Ground()s Ergebnis noch eine Serverbestätigung.

Projektquelle: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; Funktion `MoveItem`.

Keine Parameter. Ground() allein sucht und bewegt nichts, öffnet kein Target, sendet keine Pakete und ändert keine Suchergebnisse. Auch vor der Anmeldung ist das Ergebnis 0.


## Beispiele

### Selektor lesen

```vb
# Selektor lesen
#
# Liefert den besonderen Boden-Selektor für den Suchbehälter oder das Transferziel.
#
# Integer, immer 0. Diese Null bezeichnet gültig den Boden, nicht FALSE, einen Suchfehler, eine
# Objekt-ID, Grafik, Kartennummer oder Koordinate. Prüfen Sie das Ergebnis der Suche bzw. des
# Transfers, nicht Ground() als Erfolgswert.

SUB Main()
    # destination erhält Integer 0, Print zeigt ihn an. Es wird nichts abgelegt.

    VAR destination = UO.Ground()
    UO.Print(CStr(destination))
END SUB
```

**Erläuterung der Parameter und Ausführung:**

- destination erhält Integer 0, Print zeigt ihn an. Es wird nichts abgelegt.

### Goldstapel am Boden finden

```vb
# Goldstapel am Boden finden
#
# Liefert den besonderen Boden-Selektor für den Suchbehälter oder das Transferziel.
#
# Integer, immer 0. Diese Null bezeichnet gültig den Boden, nicht FALSE, einen Suchfehler, eine
# Objekt-ID, Grafik, Kartennummer oder Koordinate. Prüfen Sie das Ergebnis der Suche bzw. des
# Transfers, nicht Ground() als Erfolgswert.

SUB Main()
    # 0x0EED: Goldgrafik; zweites -1: beliebige Farbe. Ground() wählt die Welt; FALSE deaktiviert
    # Behälterrekursion. FindTypeEx liefert eine Serial oder 0; <> 0 prüft diese Serial.
    # FindDistance/FindVertical und Ignore gelten.

    VAR id = UO.FindTypeEx(0x0EED, -1, UO.Ground(), FALSE)
    IF id <> 0 THEN
        UO.Print(HEX(id))
    ELSE
        UO.Print('0')
    END IF
END SUB
```

**Erläuterung der Parameter und Ausführung:**

- 0x0EED: Goldgrafik; zweites -1: beliebige Farbe. Ground() wählt die Welt; FALSE deaktiviert Behälterrekursion. FindTypeEx liefert eine Serial oder 0; <> 0 prüft diese Serial. FindDistance/FindVertical und Ignore gelten.

### Vollständige Suche nach zwei Grafiken

```vb
# Vollständige Suche nach zwei Grafiken
#
# Liefert den besonderen Boden-Selektor für den Suchbehälter oder das Transferziel.
#
# Integer, immer 0. Diese Null bezeichnet gültig den Boden, nicht FALSE, einen Suchfehler, eine
# Objekt-ID, Grafik, Kartennummer oder Koordinate. Prüfen Sie das Ergebnis der Suche bzw. des
# Transfers, nicht Ground() als Erfolgswert.

SUB Main()
    # FindGroundTypes(firstType, secondType, radius, height) sucht Gold 0x0EED und schwarze Perlen
    # 0x0F7A mit radius=5, height=10. DIM types[1] erzeugt zwei Plätze, colors[0] und containers[0]
    # je einen. Ein Stapel zählt als ein Objekt. Typen/Farben sind Alternativen; überlappende
    # Behälter erzeugen keine doppelten IDs. Rückgabe: gespeichertes Serial-Array. Finally stellt
    # beide Grenzen wieder her, Main zeigt jede ID. Die Funktion ist vollständig angegeben.

    VAR ids = FindGroundTypes(0x0EED, 0x0F7A, 5, 10)
    FOR EACH id IN ids
        UO.Print(HEX(id))
    NEXT
END SUB

FUNCTION FindGroundTypes(firstType, secondType, radius, height)
    VAR oldDistance = UO.FindDistance()
    VAR oldVertical = UO.FindVertical()
    DIM types[1]
    types[0] = firstType
    types[1] = secondType
    DIM colors[0]
    colors[0] = -1
    DIM containers[0]
    containers[0] = UO.Ground()
    TRY
        UO.FindDistance(radius)
        UO.FindVertical(height)
        UO.FindTypesArrayEx(types, colors, containers, FALSE)
        RETURN UO.GetFoundItems()
    FINALLY
        UO.FindDistance(oldDistance)
        UO.FindVertical(oldVertical)
    END TRY
END FUNCTION
```

**Erläuterung der Parameter und Ausführung:**

- FindGroundTypes(firstType, secondType, radius, height) sucht Gold 0x0EED und schwarze Perlen 0x0F7A mit radius=5, height=10. DIM types[1] erzeugt zwei Plätze, colors[0] und containers[0] je einen. Ein Stapel zählt als ein Objekt. Typen/Farben sind Alternativen; überlappende Behälter erzeugen keine doppelten IDs. Rückgabe: gespeichertes Serial-Array. Finally stellt beide Grenzen wieder her, Main zeigt jede ID. Die Funktion ist vollständig angegeben.

### Bekanntes Objekt auf das Spielerfeld legen

```vb
# Bekanntes Objekt auf das Spielerfeld legen
#
# Liefert den besonderen Boden-Selektor für den Suchbehälter oder das Transferziel.
#
# Integer, immer 0. Diese Null bezeichnet gültig den Boden, nicht FALSE, einen Suchfehler, eine
# Objekt-ID, Grafik, Kartennummer oder Koordinate. Prüfen Sie das Ergebnis der Suche bzw. des
# Transfers, nicht Ground() als Erfolgswert.

SUB Main()
    # 0x40001001 durch eine erreichbare Objekt-Serial ersetzen. IsObjectExists prüft das geladene
    # Objekt. MoveItem(item, amount, destination, X, Y, Z): amount=0 bedeutet ganzer Stapel;
    # Ground() wählt Boden; GetX/GetY/GetZ liefern das Spielerfeld. result=1 bedeutet, dass der
    # Client die Anfrage annimmt, sonst 0. Das ist weder Ground()s Ergebnis noch eine
    # Serverbestätigung.

    VAR item = 0x40001001
    IF UO.IsObjectExists(item) THEN
        VAR result = UO.MoveItem(item, 0, UO.Ground(), UO.GetX('self'), UO.GetY('self'), UO.GetZ('self'))
    END IF
END SUB
```

**Erläuterung der Parameter und Ausführung:**

- 0x40001001 durch eine erreichbare Objekt-Serial ersetzen. IsObjectExists prüft das geladene Objekt. MoveItem(item, amount, destination, X, Y, Z): amount=0 bedeutet ganzer Stapel; Ground() wählt Boden; GetX/GetY/GetZ liefern das Spielerfeld. result=1 bedeutet, dass der Client die Anfrage annimmt, sonst 0. Das ist weder Ground()s Ergebnis noch eine Serverbestätigung.
