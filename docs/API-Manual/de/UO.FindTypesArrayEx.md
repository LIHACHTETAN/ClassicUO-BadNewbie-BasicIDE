# UO.FindTypesArrayEx

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: de -->

Sucht alternative Grafiken, Farben und Behälter in einem Durchlauf und liefert eine ID. Die vollständige Liste steht in GetFoundItems.

## Genaue Syntax

```text
UO.FindTypesArrayEx(ObjTypes:Any, Colors:Any, Containers:Any, InSub:Any) -> Integer
```

## Parameter

- `ObjTypes` — Graphic/Body, keine Objekt-Serial. 0..65534 wählt eine Grafik; -1 oder 0xFFFF jede Grafik. Andere negative Integer wirken ebenfalls als Platzhalter.
- `Colors` — Hue, keine Menge. 0 bedeutet ungefärbt; -1 oder 0xFFFF jede Farbe. Andere negative Integer entfernen ebenfalls den Farbfilter.
- `Containers` — Boden: UO.Ground(), 0, -1, 0xFFFFFFFF oder ground als String. Rucksack: backpack oder dessen Serial. Dezimale/Hex-Serials und AddObject-Namen sind erlaubt. my wählt das gesamte eigene Inventar einschließlich Ausrüstung und verschachtelter Taschen. Ein unbekannter Name löst einen Skriptfehler aus. Aufgelöste Serials prüfen: ausdrücklich 0 bedeutet Boden. ground/backpack vermeiden unterschiedliche Zahlenkonventionen anderer Befehle.
- `InSub` — TRUE/FALSE (1/0), erforderlich. FALSE durchsucht direkte Inhalte eines konkreten Behälters, TRUE auch geladene Unterbehälter. Für Boden ohne Wirkung. my umfasst bereits das gesamte eigene Inventar.

## Rückgabewert

Integer: Serial des ersten lokalen Treffers oder 0 ohne Treffer. Keine Grafik, Menge, Liste oder Boolean. result <> 0 prüfen, nicht result = TRUE oder result = 1. Ein Stapel zählt als ein Objekt; ein Mobile als ein Objekt und eine Einheit. Reihenfolge bedeutet nicht Nähe und ist nicht dauerhaft garantiert.

## Verhalten

- Array übergeben; ein einzelner Wert wird ebenfalls als ein Element akzeptiert. DIM values[1] erzeugt Indizes 0 und 1: alle belegen. Typen/Farben sind unabhängige Alternativen, keine Indexpaare. Ein Platzhalter irgendwo oder ein leeres Typ-/Farbarray entfernt diesen Filter. Ein leeres Behälterarray wählt das eigene Inventar. Wiederholte oder überlappende Behälter erzeugen keine doppelten IDs.
- Alle vier Positionsargumente sind erforderlich; keines darf entfallen.
- Boden verwendet FindDistance/FindVertical dieses Skripts, schließt self aus und umfasst passende Items und Mobiles. Konkrete Behälter verwenden diese Entfernungs-/Höhengrenzen nicht. Ignore und zerstörte Objekte werden in beiden Fällen ausgeschlossen.
- Vor dem Durchlauf werden FindItem, FindCount, FindFullQuantity und GetFoundItems geleert. Eine erfolglose Suche hinterlässt Nullen und ein leeres Array. FindFullQuantity summiert max(1, Amount) je Item und 1 je Mobile. FindQuantity liest die aktuelle Menge von FindItem. GetFoundItems vor einer weiteren Suche speichern, wenn die alte Liste gebraucht wird.
- Die Bridge durchläuft geladene Items einmal, danach bei Bodenauswahl Mobiles. Typ, Farbe und mindestens ein Behälter müssen passen. Jedes Objekt wird einmal registriert; kein vollständiger Weltdurchlauf pro Kombination.
- Nur bereits empfangene Daten: keine Behälteröffnung, kein Nachladen von Kartenfeldern, kein Transfer. Kein Treffer beweist nicht, dass die Truhe serverseitig leer ist. Bei erforderlicher Verbindung Connected prüfen; die Suche liest lokalen Zustand.
- [Stealth FindTypesArrayEx](https://stealth.od.ua/api/FindTypesArrayEx/). Die Referenz beschreibt die letzte ID und Rucksackersatz bei ungültigem Behälter. Hier gilt der erste lokale Treffer; unbekannte Namen wechseln nicht zum Rucksack. Ground akzeptiert auch 0; lokaler FindDistance-Standard 18, Maximum 255.

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

#### 4. BuildFindIdentityMask

Array übergeben; ein einzelner Wert wird ebenfalls als ein Element akzeptiert. DIM values[1] erzeugt Indizes 0 und 1: alle belegen. Typen/Farben sind unabhängige Alternativen, keine Indexpaare. Ein Platzhalter irgendwo oder ein leeres Typ-/Farbarray entfernt diesen Filter. Ein leeres Behälterarray wählt das eigene Inventar. Wiederholte oder überlappende Behälter erzeugen keine doppelten IDs.

Die Bridge durchläuft geladene Items einmal, danach bei Bodenauswahl Mobiles. Typ, Farbe und mindestens ein Behälter müssen passen. Jedes Objekt wird einmal registriert; kein vollständiger Weltdurchlauf pro Kombination.

Projektquelle: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; Funktion `BuildFindIdentityMask`.

#### 5. FindTypes

Die Bridge durchläuft geladene Items einmal, danach bei Bodenauswahl Mobiles. Typ, Farbe und mindestens ein Behälter müssen passen. Jedes Objekt wird einmal registriert; kein vollständiger Weltdurchlauf pro Kombination.

Boden verwendet FindDistance/FindVertical dieses Skripts, schließt self aus und umfasst passende Items und Mobiles. Konkrete Behälter verwenden diese Entfernungs-/Höhengrenzen nicht. Ignore und zerstörte Objekte werden in beiden Fällen ausgeschlossen.

Projektquelle: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; Funktion `FindTypes`.

#### 6. MatchesFindIdentity

Graphic/Body, keine Objekt-Serial. 0..65534 wählt eine Grafik; -1 oder 0xFFFF jede Grafik. Andere negative Integer wirken ebenfalls als Platzhalter. Hue, keine Menge. 0 bedeutet ungefärbt; -1 oder 0xFFFF jede Farbe. Andere negative Integer entfernen ebenfalls den Farbfilter.

Die Bridge durchläuft geladene Items einmal, danach bei Bodenauswahl Mobiles. Typ, Farbe und mindestens ein Behälter müssen passen. Jedes Objekt wird einmal registriert; kein vollständiger Weltdurchlauf pro Kombination.

Projektquelle: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; Funktion `MatchesFindIdentity`.

#### 7. MatchesFindContainer

TRUE/FALSE (1/0), erforderlich. FALSE durchsucht direkte Inhalte eines konkreten Behälters, TRUE auch geladene Unterbehälter. Für Boden ohne Wirkung. my umfasst bereits das gesamte eigene Inventar.

Boden verwendet FindDistance/FindVertical dieses Skripts, schließt self aus und umfasst passende Items und Mobiles. Konkrete Behälter verwenden diese Entfernungs-/Höhengrenzen nicht. Ignore und zerstörte Objekte werden in beiden Fällen ausgeschlossen.

Projektquelle: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; Funktion `MatchesFindContainer`.

#### 8. RegisterFound

Vor dem Durchlauf werden FindItem, FindCount, FindFullQuantity und GetFoundItems geleert. Eine erfolglose Suche hinterlässt Nullen und ein leeres Array. FindFullQuantity summiert max(1, Amount) je Item und 1 je Mobile. FindQuantity liest die aktuelle Menge von FindItem. GetFoundItems vor einer weiteren Suche speichern, wenn die alte Liste gebraucht wird.

Integer: Serial des ersten lokalen Treffers oder 0 ohne Treffer. Keine Grafik, Menge, Liste oder Boolean. result <> 0 prüfen, nicht result = TRUE oder result = 1. Ein Stapel zählt als ein Objekt; ein Mobile als ein Objekt und eine Einheit. Reihenfolge bedeutet nicht Nähe und ist nicht dauerhaft garantiert.

Projektquelle: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; Funktion `RegisterFound`.

Nur bereits empfangene Daten: keine Behälteröffnung, kein Nachladen von Kartenfeldern, kein Transfer. Kein Treffer beweist nicht, dass die Truhe serverseitig leer ist. Bei erforderlicher Verbindung Connected prüfen; die Suche liest lokalen Zustand.


## Beispiele

### Zwei Grafiken am Boden

```vb
# Zwei Grafiken am Boden
#
# Sucht alternative Grafiken, Farben und Behälter in einem Durchlauf und liefert eine ID. Die
# vollständige Liste steht in GetFoundItems.
#
# Integer: Serial des ersten lokalen Treffers oder 0 ohne Treffer. Keine Grafik, Menge, Liste
# oder Boolean. result <> 0 prüfen, nicht result = TRUE oder result = 1. Ein Stapel zählt als
# ein Objekt; ein Mobile als ein Objekt und eine Einheit. Reihenfolge bedeutet nicht Nähe und
# ist nicht dauerhaft garantiert.

SUB Main()
    # types enthält Gold 0x0EED und schwarze Perlen 0x0F7A; color=-1 bedeutet jede Farbe, Ground die
    # Welt. FALSE ändert dort nichts. Aktuelle Suchgrenzen gelten. Ausgabe: ID, Objekte, Einheiten.

    DIM types[1]
    types[0] = 0x0EED
    types[1] = 0x0F7A
    DIM colors[0]
    colors[0] = -1
    DIM containers[0]
    containers[0] = UO.Ground()
    VAR first = UO.FindTypesArrayEx(types, colors, containers, FALSE)
    UO.Print(Hex(first))
    UO.Print(STR(UO.FindCount()))
    UO.Print(STR(UO.FindFullQuantity()))
END SUB
```

**Erläuterung der Parameter und Ausführung:**

- types enthält Gold 0x0EED und schwarze Perlen 0x0F7A; color=-1 bedeutet jede Farbe, Ground die Welt. FALSE ändert dort nichts. Aktuelle Suchgrenzen gelten. Ausgabe: ID, Objekte, Einheiten.

### Gold in Rucksack und Welt

```vb
# Gold in Rucksack und Welt
#
# Sucht alternative Grafiken, Farben und Behälter in einem Durchlauf und liefert eine ID. Die
# vollständige Liste steht in GetFoundItems.
#
# Integer: Serial des ersten lokalen Treffers oder 0 ohne Treffer. Keine Grafik, Menge, Liste
# oder Boolean. result <> 0 prüfen, nicht result = TRUE oder result = 1. Ein Stapel zählt als
# ein Objekt; ein Mobile als ein Objekt und eine Einheit. Reihenfolge bedeutet nicht Nähe und
# ist nicht dauerhaft garantiert.

SUB Main()
    # types enthält nur Gold, colors jede Farbe. Containers enthält backpack und Boden; TRUE umfasst
    # Untertaschen. Gesamtobjekte und Einheiten aus beiden Bereichen werden ohne doppelte Objekte
    # ausgegeben.

    DIM types[0]
    types[0] = 0x0EED
    DIM colors[0]
    colors[0] = -1
    DIM containers[1]
    containers[0] = 'backpack'
    containers[1] = UO.Ground()
    UO.FindTypesArrayEx(types, colors, containers, TRUE)
    UO.Print(STR(UO.FindCount()))
    UO.Print(STR(UO.FindFullQuantity()))
END SUB
```

**Erläuterung der Parameter und Ausführung:**

- types enthält nur Gold, colors jede Farbe. Containers enthält backpack und Boden; TRUE umfasst Untertaschen. Gesamtobjekte und Einheiten aus beiden Bereichen werden ohne doppelte Objekte ausgegeben.

### Vollständige Funktion mit Ergebnisliste

```vb
# Vollständige Funktion mit Ergebnisliste
#
# Sucht alternative Grafiken, Farben und Behälter in einem Durchlauf und liefert eine ID. Die
# vollständige Liste steht in GetFoundItems.
#
# Integer: Serial des ersten lokalen Treffers oder 0 ohne Treffer. Keine Grafik, Menge, Liste
# oder Boolean. result <> 0 prüfen, nicht result = TRUE oder result = 1. Ein Stapel zählt als
# ein Objekt; ein Mobile als ein Objekt und eine Einheit. Reihenfolge bedeutet nicht Nähe und
# ist nicht dauerhaft garantiert.

SUB Main()
    # SearchTypesIn(container,firstType,secondType) liefert Array<Integer>, der eingebaute Befehl
    # dagegen eine einzelne Integer-ID. Der vollständige Helfer befüllt Arrays, sucht rekursiv und
    # kopiert sofort GetFoundItems. Main prüft und zeigt jede gespeicherte ID.

    VAR items = SearchTypesIn('backpack', 0x0EED, 0x0F7A)
    FOR EACH item IN items
        IF UO.IsObjectExists(item) THEN
            UO.Print(Hex(item))
        END IF
    NEXT
END SUB

FUNCTION SearchTypesIn(container, firstType, secondType)
    DIM types[1]
    types[0] = firstType
    types[1] = secondType
    DIM colors[0]
    colors[0] = -1
    DIM containers[0]
    containers[0] = container
    UO.FindTypesArrayEx(types, colors, containers, TRUE)
    RETURN UO.GetFoundItems()
END FUNCTION
```

**Erläuterung der Parameter und Ausführung:**

- SearchTypesIn(container,firstType,secondType) liefert Array<Integer>, der eingebaute Befehl dagegen eine einzelne Integer-ID. Der vollständige Helfer befüllt Arrays, sucht rekursiv und kopiert sofort GetFoundItems. Main prüft und zeigt jede gespeicherte ID.
