# UO.FindTypeEx

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: de -->

Sucht eine Grafik/Farbe in einem Behälter oder auf dem Boden und liefert eine passende ID.

## Genaue Syntax

```text
UO.FindTypeEx(ObjType:Any, Color:Any, Container:Any, InSub:Any) -> Integer
```

## Parameter

- `ObjType` — Graphic/Body, keine Objekt-Serial. 0..65534 wählt eine Grafik; -1 oder 0xFFFF jede Grafik. Andere negative Integer wirken ebenfalls als Platzhalter.
- `Color` — Hue, keine Menge. 0 bedeutet ungefärbt; -1 oder 0xFFFF jede Farbe. Andere negative Integer entfernen ebenfalls den Farbfilter.
- `Container` — Boden: UO.Ground(), 0, -1, 0xFFFFFFFF oder ground als String. Rucksack: backpack oder dessen Serial. Dezimale/Hex-Serials und AddObject-Namen sind erlaubt. my wählt das gesamte eigene Inventar einschließlich Ausrüstung und verschachtelter Taschen. Ein unbekannter Name löst einen Skriptfehler aus. Aufgelöste Serials prüfen: ausdrücklich 0 bedeutet Boden. ground/backpack vermeiden unterschiedliche Zahlenkonventionen anderer Befehle.
- `InSub` — TRUE/FALSE (1/0), erforderlich. FALSE durchsucht direkte Inhalte eines konkreten Behälters, TRUE auch geladene Unterbehälter. Für Boden ohne Wirkung. my umfasst bereits das gesamte eigene Inventar.

## Rückgabewert

Integer: Serial des ersten lokalen Treffers oder 0 ohne Treffer. Keine Grafik, Menge, Liste oder Boolean. result <> 0 prüfen, nicht result = TRUE oder result = 1. Ein Stapel zählt als ein Objekt; ein Mobile als ein Objekt und eine Einheit. Reihenfolge bedeutet nicht Nähe und ist nicht dauerhaft garantiert.

## Verhalten

- Alle vier Positionsargumente sind erforderlich; keines darf entfallen.
- Boden verwendet FindDistance/FindVertical dieses Skripts, schließt self aus und umfasst passende Items und Mobiles. Konkrete Behälter verwenden diese Entfernungs-/Höhengrenzen nicht. Ignore und zerstörte Objekte werden in beiden Fällen ausgeschlossen.
- Vor dem Durchlauf werden FindItem, FindCount, FindFullQuantity und GetFoundItems geleert. Eine erfolglose Suche hinterlässt Nullen und ein leeres Array. FindFullQuantity summiert max(1, Amount) je Item und 1 je Mobile. FindQuantity liest die aktuelle Menge von FindItem. GetFoundItems vor einer weiteren Suche speichern, wenn die alte Liste gebraucht wird.
- Die Bridge durchläuft geladene Items einmal, danach bei Bodenauswahl Mobiles. Typ, Farbe und mindestens ein Behälter müssen passen. Jedes Objekt wird einmal registriert; kein vollständiger Weltdurchlauf pro Kombination.
- Nur bereits empfangene Daten: keine Behälteröffnung, kein Nachladen von Kartenfeldern, kein Transfer. Kein Treffer beweist nicht, dass die Truhe serverseitig leer ist. Bei erforderlicher Verbindung Connected prüfen; die Suche liest lokalen Zustand.
- [Stealth FindTypeEx](https://stealth.od.ua/api/FindTypeEx/). Die Referenz beschreibt die letzte ID und Rucksackersatz bei ungültigem Behälter. Hier gilt der erste lokale Treffer; unbekannte Namen wechseln nicht zum Rucksack. Ground akzeptiert auch 0; lokaler FindDistance-Standard 18, Maximum 255.

### Interne Funktionen: vom Aufruf zum Ergebnis

Tatsächliche Implementierungsschritte, keine zusätzlichen öffentlichen Befehle. FindGoldNearSelf und SearchTypesIn sind unten vollständig definierte Skriptfunktionen.

#### 1. ExecuteStealthCompatibility

Die Runtime konvertiert Zahlenfilter und löst Behälternamen getrennt auf; Boden wird zum internen Weltbereich der Bridge.

Alle vier Positionsargumente sind erforderlich; keines darf entfallen.

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; Funktion `ExecuteStealthCompatibility`.

#### 2. ConvertStealthSearchContainer

Boden: UO.Ground(), 0, -1, 0xFFFFFFFF oder ground als String. Rucksack: backpack oder dessen Serial. Dezimale/Hex-Serials und AddObject-Namen sind erlaubt. my wählt das gesamte eigene Inventar einschließlich Ausrüstung und verschachtelter Taschen. Ein unbekannter Name löst einen Skriptfehler aus. Aufgelöste Serials prüfen: ausdrücklich 0 bedeutet Boden. ground/backpack vermeiden unterschiedliche Zahlenkonventionen anderer Befehle.

Die Runtime konvertiert Zahlenfilter und löst Behälternamen getrennt auf; Boden wird zum internen Weltbereich der Bridge.

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; Funktion `ConvertStealthSearchContainer`.

#### 3. ResetFindResults

Vor dem Durchlauf werden FindItem, FindCount, FindFullQuantity und GetFoundItems geleert. Eine erfolglose Suche hinterlässt Nullen und ein leeres Array. FindFullQuantity summiert max(1, Amount) je Item und 1 je Mobile. FindQuantity liest die aktuelle Menge von FindItem. GetFoundItems vor einer weiteren Suche speichern, wenn die alte Liste gebraucht wird.

Integer: Serial des ersten lokalen Treffers oder 0 ohne Treffer. Keine Grafik, Menge, Liste oder Boolean. result <> 0 prüfen, nicht result = TRUE oder result = 1. Ein Stapel zählt als ein Objekt; ein Mobile als ein Objekt und eine Einheit. Reihenfolge bedeutet nicht Nähe und ist nicht dauerhaft garantiert.

Projektquelle: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; Funktion `ResetFindResults`.

#### 4. FindType

Die Bridge durchläuft geladene Items einmal, danach bei Bodenauswahl Mobiles. Typ, Farbe und mindestens ein Behälter müssen passen. Jedes Objekt wird einmal registriert; kein vollständiger Weltdurchlauf pro Kombination.

Boden verwendet FindDistance/FindVertical dieses Skripts, schließt self aus und umfasst passende Items und Mobiles. Konkrete Behälter verwenden diese Entfernungs-/Höhengrenzen nicht. Ignore und zerstörte Objekte werden in beiden Fällen ausgeschlossen.

Projektquelle: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; Funktion `FindType`.

#### 5. MatchesFindIdentity

Graphic/Body, keine Objekt-Serial. 0..65534 wählt eine Grafik; -1 oder 0xFFFF jede Grafik. Andere negative Integer wirken ebenfalls als Platzhalter. Hue, keine Menge. 0 bedeutet ungefärbt; -1 oder 0xFFFF jede Farbe. Andere negative Integer entfernen ebenfalls den Farbfilter.

Die Bridge durchläuft geladene Items einmal, danach bei Bodenauswahl Mobiles. Typ, Farbe und mindestens ein Behälter müssen passen. Jedes Objekt wird einmal registriert; kein vollständiger Weltdurchlauf pro Kombination.

Projektquelle: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; Funktion `MatchesFindIdentity`.

#### 6. MatchesFindContainer

TRUE/FALSE (1/0), erforderlich. FALSE durchsucht direkte Inhalte eines konkreten Behälters, TRUE auch geladene Unterbehälter. Für Boden ohne Wirkung. my umfasst bereits das gesamte eigene Inventar.

Boden verwendet FindDistance/FindVertical dieses Skripts, schließt self aus und umfasst passende Items und Mobiles. Konkrete Behälter verwenden diese Entfernungs-/Höhengrenzen nicht. Ignore und zerstörte Objekte werden in beiden Fällen ausgeschlossen.

Projektquelle: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; Funktion `MatchesFindContainer`.

#### 7. RegisterFound

Vor dem Durchlauf werden FindItem, FindCount, FindFullQuantity und GetFoundItems geleert. Eine erfolglose Suche hinterlässt Nullen und ein leeres Array. FindFullQuantity summiert max(1, Amount) je Item und 1 je Mobile. FindQuantity liest die aktuelle Menge von FindItem. GetFoundItems vor einer weiteren Suche speichern, wenn die alte Liste gebraucht wird.

Integer: Serial des ersten lokalen Treffers oder 0 ohne Treffer. Keine Grafik, Menge, Liste oder Boolean. result <> 0 prüfen, nicht result = TRUE oder result = 1. Ein Stapel zählt als ein Objekt; ein Mobile als ein Objekt und eine Einheit. Reihenfolge bedeutet nicht Nähe und ist nicht dauerhaft garantiert.

Projektquelle: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; Funktion `RegisterFound`.

Nur bereits empfangene Daten: keine Behälteröffnung, kein Nachladen von Kartenfeldern, kein Transfer. Kein Treffer beweist nicht, dass die Truhe serverseitig leer ist. Bei erforderlicher Verbindung Connected prüfen; die Suche liest lokalen Zustand.


## Beispiele

### Direkter Rucksackinhalt

```vb
# Direkter Rucksackinhalt
#
# Sucht eine Grafik/Farbe in einem Behälter oder auf dem Boden und liefert eine passende ID.
#
# Integer: Serial des ersten lokalen Treffers oder 0 ohne Treffer. Keine Grafik, Menge, Liste
# oder Boolean. result <> 0 prüfen, nicht result = TRUE oder result = 1. Ein Stapel zählt als
# ein Objekt; ein Mobile als ein Objekt und eine Einheit. Reihenfolge bedeutet nicht Nähe und
# ist nicht dauerhaft garantiert.

SUB Main()
    # 0x0EED ist Gold, -1 jede Farbe; backpack/FALSE schließt Untertaschen aus. Ausgabe: erste
    # Hex-ID ohne 0x, Objektzahl, Einheiten. Stapel 20 und 50 ergeben 2 Objekte und 70 Einheiten.

    VAR item = UO.FindTypeEx(0x0EED, -1, 'backpack', FALSE)
    UO.Print(Hex(item))
    UO.Print(STR(UO.FindCount()))
    UO.Print(STR(UO.FindFullQuantity()))
END SUB
```

**Erläuterung der Parameter und Ausführung:**

- 0x0EED ist Gold, -1 jede Farbe; backpack/FALSE schließt Untertaschen aus. Ausgabe: erste Hex-ID ohne 0x, Objektzahl, Einheiten. Stapel 20 und 50 ergeben 2 Objekte und 70 Einheiten.

### Vollständige temporäre Bodensuche

```vb
# Vollständige temporäre Bodensuche
#
# Sucht eine Grafik/Farbe in einem Behälter oder auf dem Boden und liefert eine passende ID.
#
# Integer: Serial des ersten lokalen Treffers oder 0 ohne Treffer. Keine Grafik, Menge, Liste
# oder Boolean. result <> 0 prüfen, nicht result = TRUE oder result = 1. Ein Stapel zählt als
# ein Objekt; ein Mobile als ein Objekt und eine Einheit. Reihenfolge bedeutet nicht Nähe und
# ist nicht dauerhaft garantiert.

SUB Main()
    # radius=5 und height=10 gelten in FindGoldNearSelf. Finally stellt beide Werte auch bei Return
    # oder Fehler wieder her. Rückgabe: Gold-Serial oder 0; Main prüft <> 0.

    VAR item = FindGoldNearSelf(5, 10)
    IF item <> 0 THEN
        UO.Print(Hex(item))
    ELSE
        UO.Print('Empty')
    END IF
END SUB

FUNCTION FindGoldNearSelf(radius, height)
    VAR oldDistance = UO.FindDistance()
    VAR oldVertical = UO.FindVertical()
    TRY
        UO.FindDistance(radius)
        UO.FindVertical(height)
        RETURN UO.FindTypeEx(0x0EED, -1, UO.Ground(), FALSE)
    FINALLY
        UO.FindDistance(oldDistance)
        UO.FindVertical(oldVertical)
    END TRY
END FUNCTION
```

**Erläuterung der Parameter und Ausführung:**

- radius=5 und height=10 gelten in FindGoldNearSelf. Finally stellt beide Werte auch bei Return oder Fehler wieder her. Rückgabe: Gold-Serial oder 0; Main prüft <> 0.

### Behältername und Untertaschen

```vb
# Behältername und Untertaschen
#
# Sucht eine Grafik/Farbe in einem Behälter oder auf dem Boden und liefert eine passende ID.
#
# Integer: Serial des ersten lokalen Treffers oder 0 ohne Treffer. Keine Grafik, Menge, Liste
# oder Boolean. result <> 0 prüfen, nicht result = TRUE oder result = 1. Ein Stapel zählt als
# ein Objekt; ein Mobile als ein Objekt und eine Einheit. Reihenfolge bedeutet nicht Nähe und
# ist nicht dauerhaft garantiert.

SUB Main()
    # GetSerial löst backpack auf; Nullprüfung verhindert versehentliche Bodenauswahl. AddObject
    # speichert search_bag. TRUE umfasst Untertaschen. GetFoundItems kopiert die Liste;
    # IsObjectExists prüft jede ID erneut.

    VAR bag = UO.GetSerial('backpack')
    IF bag <> 0 THEN
        UO.AddObject('search_bag', bag)
        UO.FindTypeEx(0x0EED, -1, 'search_bag', TRUE)
        VAR items = UO.GetFoundItems()
        FOR EACH item IN items
            IF UO.IsObjectExists(item) THEN
                UO.Print(Hex(item))
            END IF
        NEXT
    END IF
END SUB
```

**Erläuterung der Parameter und Ausführung:**

- GetSerial löst backpack auf; Nullprüfung verhindert versehentliche Bodenauswahl. AddObject speichert search_bag. TRUE umfasst Untertaschen. GetFoundItems kopiert die Liste; IsObjectExists prüft jede ID erneut.
