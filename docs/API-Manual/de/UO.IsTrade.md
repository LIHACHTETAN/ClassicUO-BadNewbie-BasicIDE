# UO.IsTrade

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: de -->

Prüft, ob ein sicheres Handelsfenster geöffnet ist.

## Genaue Syntax

```text
UO.IsTrade() -> Integer
```

## Parameter

Keine Parameter.

## Rückgabewert

Integer: 1 = TRUE bei offenem Handel, sonst 0 = FALSE.

Logisches Ergebnis: 1 = TRUE, 0 = FALSE. Nach VAR result = Befehl(...) sind IF result = TRUE THEN und IF result = 1 THEN gleichwertig; entsprechend IF result = FALSE THEN und IF result = 0 THEN. TRUE/FALSE ohne Anführungszeichen. Einmal aufrufen und speichern: Ein weiterer Aufruf kann die Aktion wiederholen oder einen geänderten Zustand lesen.

## Verhalten

- GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade beginnen bei 1; TradeContainer/TradeOpponent/TradeName und alle TradeCheck-Formen bei 0. Dieser Client erhält diese Konventionen; externe Handbücher verschiedener Engines verwenden unterschiedliche Anfänge.
- Lesen erfolgt im Spielthread aus lebenden Fenstern dieser World. Geschlossene Fenster zählen nicht. Lesen sendet keine Pakete und wartet nicht. Öffnen, Schließen und In-den-Vordergrund-Bringen können die UI-Reihenfolge ändern; der Index ist keine dauerhafte ID.
- ConfirmTrade und eigenes TradeCheck-Schreiben senden nur bei geänderter Zustimmung. Die Gegenseite steuert der Server. CancelTrade sendet einmal. 1/TRUE bedeutet lokalen Zustand/Verarbeitung, keinen abgeschlossenen Transfer. Namen und Häkchen beweisen keinen unveränderten Inhalt.

### Interne Funktionen: vom Aufruf zum Ergebnis

Unten stehen der C#-Aufrufpfad und danach ausführbare Basic-Beispiele. Die Skripte implementieren kein eigenes Netzwerkprotokoll.

#### 1. ExecuteStealthCompatibility

Die Registrierung wählt nach Argumentanzahl; NumberConversions wandelt Zahlen. Zweistelliges TradeCheck prüft Seiten 1/2 und bildet sie auf Bridge-Indizes 0/1 ab. ToHex formatiert Legacy-Serials.

Integer: 1 = TRUE bei offenem Handel, sonst 0 = FALSE.

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; Funktion `ExecuteStealthCompatibility`.

#### 2. IsTrade

Invoke verlegt Lesen/Schreiben in den Spielthread mit Skriptabbruch; gelesen werden ID1/ID2, LocalSerial, OpponentName oder Häkchen des gewählten TradingGump.

Prüft, ob ein sicheres Handelsfenster geöffnet ist.

Projektquelle: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; Funktion `IsTrade`.

#### 3. FindTrade

FindNumberedTrade prüft number>0 vor dem Abziehen von 1; FindTrade weist negative Indizes zurück und zählt nur offene TradingGump dieser World.

GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade beginnen bei 1; TradeContainer/TradeOpponent/TradeName und alle TradeCheck-Formen bei 0. Dieser Client erhält diese Konventionen; externe Handbücher verschiedener Engines verwenden unterschiedliche Anfänge.

Projektquelle: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; Funktion `FindTrade`.

Die vollständige Hilfsfunktion wird von Main aufgerufen. Bereichs-/ID-Prüfungen verringern Fehler, machen mehrere Aufrufe aber nicht atomar. Das Fenster kann wechseln. expectedPartner ist eine gespeicherte Charakter-Serial, keine Preis-/Inhaltsprüfung.


## Beispiele

### Direkt lesen oder ausführen

```vb
# Direkt lesen oder ausführen
#
# Prüft, ob ein sicheres Handelsfenster geöffnet ist.
#
# Integer: 1 = TRUE bei offenem Handel, sonst 0 = FALSE.
#
# Logisches Ergebnis: 1 = TRUE, 0 = FALSE. Nach VAR result = Befehl(...) sind IF result = TRUE
# THEN und IF result = 1 THEN gleichwertig; entsprechend IF result = FALSE THEN und IF result =
# 0 THEN. TRUE/FALSE ohne Anführungszeichen. Einmal aufrufen und speichern: Ein weiterer Aufruf
# kann die Aktion wiederholen oder einen geänderten Zustand lesen.

SUB Main()
    # Ein Aufruf, gespeichert in value/result. 0 ist der erste Index, 1 die erste Nummer (siehe
    # Syntax). HEX zeigt numerische Serials; CStr Zahlen oder Text.

    VAR value = UO.IsTrade()
    UO.Print(CStr(value))
END SUB
```

**Erläuterung der Parameter und Ausführung:**

- Ein Aufruf, gespeichert in value/result. 0 ist der erste Index, 1 die erste Nummer (siehe Syntax). HEX zeigt numerische Serials; CStr Zahlen oder Text.

### Weiteres Szenario und Parameter

```vb
# Weiteres Szenario und Parameter
#
# Prüft, ob ein sicheres Handelsfenster geöffnet ist.
#
# Integer: 1 = TRUE bei offenem Handel, sonst 0 = FALSE.
#
# Logisches Ergebnis: 1 = TRUE, 0 = FALSE. Nach VAR result = Befehl(...) sind IF result = TRUE
# THEN und IF result = 1 THEN gleichwertig; entsprechend IF result = FALSE THEN und IF result =
# 0 THEN. TRUE/FALSE ohne Anführungszeichen. Einmal aufrufen und speichern: Ein weiterer Aufruf
# kann die Aktion wiederholen oder einen geänderten Zustand lesen.

SUB Main()
    # before/after sind getrennte Momentaufnahmen im Abstand von 500 Millisekunden. Die Pause wartet
    # nicht auf einen bestimmten Handel und kann Zwischenänderungen übersehen.

    VAR before = UO.IsTrade()
    WAIT(500)
    VAR after = UO.IsTrade()
    UO.Print(CStr(before) + " -> " + CStr(after))
END SUB
```

**Erläuterung der Parameter und Ausführung:**

- before/after sind getrennte Momentaufnahmen im Abstand von 500 Millisekunden. Die Pause wartet nicht auf einen bestimmten Handel und kann Zwischenänderungen übersehen.

### Vollständige Hilfsfunktion

```vb
# Vollständige Hilfsfunktion
#
# Prüft, ob ein sicheres Handelsfenster geöffnet ist.
#
# Integer: 1 = TRUE bei offenem Handel, sonst 0 = FALSE.
#
# Logisches Ergebnis: 1 = TRUE, 0 = FALSE. Nach VAR result = Befehl(...) sind IF result = TRUE
# THEN und IF result = 1 THEN gleichwertig; entsprechend IF result = FALSE THEN und IF result =
# 0 THEN. TRUE/FALSE ohne Anführungszeichen. Einmal aufrufen und speichern: Ein weiterer Aufruf
# kann die Aktion wiederholen oder einen geänderten Zustand lesen.

SUB Main()
    # Die vollständige Hilfsfunktion wird von Main aufgerufen. Bereichs-/ID-Prüfungen verringern
    # Fehler, machen mehrere Aufrufe aber nicht atomar. Das Fenster kann wechseln. expectedPartner
    # ist eine gespeicherte Charakter-Serial, keine Preis-/Inhaltsprüfung.

    VAR value = ReadTradeState()
    UO.Print(CStr(value))
END SUB

FUNCTION ReadTradeState()
    RETURN UO.IsTrade()
END FUNCTION
```

**Erläuterung der Parameter und Ausführung:**

- Die vollständige Hilfsfunktion wird von Main aufgerufen. Bereichs-/ID-Prüfungen verringern Fehler, machen mehrere Aufrufe aber nicht atomar. Das Fenster kann wechseln. expectedPartner ist eine gespeicherte Charakter-Serial, keine Preis-/Inhaltsprüfung.
