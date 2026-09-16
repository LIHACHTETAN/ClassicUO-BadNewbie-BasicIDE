# UO.GetTradeOpponentName

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: de -->

Liest den beim Öffnen empfangenen Partnernamen.

## Genaue Syntax

```text
UO.GetTradeOpponentName(TradeNum:Any) -> Any
```

## Parameter

- `TradeNum` — Ganzzahlige aktuelle Fensternummer 1..TradeCount(). Null/negativ ungültig. Keine Serial.

## Rückgabewert

String: beim Öffnen empfangener Name; leer ohne Fenster/Namen. Fordert keinen neuen Namen an.

## Verhalten

- GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade beginnen bei 1; TradeContainer/TradeOpponent/TradeName und alle TradeCheck-Formen bei 0. Dieser Client erhält diese Konventionen; externe Handbücher verschiedener Engines verwenden unterschiedliche Anfänge.
- Lesen erfolgt im Spielthread aus lebenden Fenstern dieser World. Geschlossene Fenster zählen nicht. Lesen sendet keine Pakete und wartet nicht. Öffnen, Schließen und In-den-Vordergrund-Bringen können die UI-Reihenfolge ändern; der Index ist keine dauerhafte ID.
- ConfirmTrade und eigenes TradeCheck-Schreiben senden nur bei geänderter Zustimmung. Die Gegenseite steuert der Server. CancelTrade sendet einmal. 1/TRUE bedeutet lokalen Zustand/Verarbeitung, keinen abgeschlossenen Transfer. Namen und Häkchen beweisen keinen unveränderten Inhalt.

### Interne Funktionen: vom Aufruf zum Ergebnis

Unten stehen der C#-Aufrufpfad und danach ausführbare Basic-Beispiele. Die Skripte implementieren kein eigenes Netzwerkprotokoll.

#### 1. ExecuteStealthCompatibility

Die Registrierung wählt nach Argumentanzahl; NumberConversions wandelt Zahlen. Zweistelliges TradeCheck prüft Seiten 1/2 und bildet sie auf Bridge-Indizes 0/1 ab. ToHex formatiert Legacy-Serials.

String: beim Öffnen empfangener Name; leer ohne Fenster/Namen. Fordert keinen neuen Namen an.

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; Funktion `ExecuteStealthCompatibility`.

#### 2. GetTradeOpponentName

Invoke verlegt Lesen/Schreiben in den Spielthread mit Skriptabbruch; gelesen werden ID1/ID2, LocalSerial, OpponentName oder Häkchen des gewählten TradingGump.

Liest den beim Öffnen empfangenen Partnernamen.

Projektquelle: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; Funktion `GetTradeOpponentName`.

#### 3. FindNumberedTrade

FindNumberedTrade prüft number>0 vor dem Abziehen von 1; FindTrade weist negative Indizes zurück und zählt nur offene TradingGump dieser World.

GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade beginnen bei 1; TradeContainer/TradeOpponent/TradeName und alle TradeCheck-Formen bei 0. Dieser Client erhält diese Konventionen; externe Handbücher verschiedener Engines verwenden unterschiedliche Anfänge.

Projektquelle: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; Funktion `FindNumberedTrade`.

Die vollständige Hilfsfunktion wird von Main aufgerufen. Bereichs-/ID-Prüfungen verringern Fehler, machen mehrere Aufrufe aber nicht atomar. Das Fenster kann wechseln. expectedPartner ist eine gespeicherte Charakter-Serial, keine Preis-/Inhaltsprüfung.


## Beispiele

### Direkt lesen oder ausführen

```vb
# Direkt lesen oder ausführen
#
# Liest den beim Öffnen empfangenen Partnernamen.
#
# String: beim Öffnen empfangener Name; leer ohne Fenster/Namen. Fordert keinen neuen Namen an.

SUB Main()
    # Ein Aufruf, gespeichert in value/result. 0 ist der erste Index, 1 die erste Nummer (siehe
    # Syntax). HEX zeigt numerische Serials; CStr Zahlen oder Text.

    VAR value = UO.GetTradeOpponentName(1)
    UO.Print(CStr(value))
END SUB
```

**Erläuterung der Parameter und Ausführung:**

- Ein Aufruf, gespeichert in value/result. 0 ist der erste Index, 1 die erste Nummer (siehe Syntax). HEX zeigt numerische Serials; CStr Zahlen oder Text.

### Weiteres Szenario und Parameter

```vb
# Weiteres Szenario und Parameter
#
# Liest den beim Öffnen empfangenen Partnernamen.
#
# String: beim Öffnen empfangener Name; leer ohne Fenster/Namen. Fordert keinen neuen Namen an.

SUB Main()
    # total speichert die Fensteranzahl, index den aktuellen Index/die Nummer. Aufzählen bestätigt
    # nichts. GetTradeContainer liest eigenen (1) und fremden (2) Behälter von Fenster 1.

    VAR total = UO.TradeCount()
    FOR VAR index = 1 TO total - 0
        VAR value = UO.GetTradeOpponentName(index)
        UO.Print(CStr(index) + ": " + CStr(value))
    NEXT
END SUB
```

**Erläuterung der Parameter und Ausführung:**

- total speichert die Fensteranzahl, index den aktuellen Index/die Nummer. Aufzählen bestätigt nichts. GetTradeContainer liest eigenen (1) und fremden (2) Behälter von Fenster 1.

### Vollständige Hilfsfunktion

```vb
# Vollständige Hilfsfunktion
#
# Liest den beim Öffnen empfangenen Partnernamen.
#
# String: beim Öffnen empfangener Name; leer ohne Fenster/Namen. Fordert keinen neuen Namen an.

SUB Main()
    # Die vollständige Hilfsfunktion wird von Main aufgerufen. Bereichs-/ID-Prüfungen verringern
    # Fehler, machen mehrere Aufrufe aber nicht atomar. Das Fenster kann wechseln. expectedPartner
    # ist eine gespeicherte Charakter-Serial, keine Preis-/Inhaltsprüfung.

    VAR value = ReadTradeValue(1)
    UO.Print(CStr(value))
END SUB

FUNCTION ReadTradeValue(index)
    VAR total = UO.TradeCount()
    IF index < 1 OR index >= total + 1 THEN
        RETURN ""
    END IF
    RETURN UO.GetTradeOpponentName(index)
END FUNCTION
```

**Erläuterung der Parameter und Ausführung:**

- Die vollständige Hilfsfunktion wird von Main aufgerufen. Bereichs-/ID-Prüfungen verringern Fehler, machen mehrere Aufrufe aber nicht atomar. Das Fenster kann wechseln. expectedPartner ist eine gespeicherte Charakter-Serial, keine Preis-/Inhaltsprüfung.
