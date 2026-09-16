# UO.TradeOpponent

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: de -->

Liest die Serial des Partnerbehälters als Hex-String, nicht dessen Charakter-ID.

## Genaue Syntax

```text
UO.TradeOpponent(windowIndex:Any) -> String
```

## Parameter

- `windowIndex` — Ganzzahliger aktueller Fensterindex 0..TradeCount()-1. Negativ/fehlend ergibt einen leeren Rückgabewert. Keine Serial.

## Rückgabewert

String: Hex-ID2 des Partnerbehälters, sonst "0x00000000". Die Charakter-ID liefert GetTradeOpponent(index + 1).

## Verhalten

- GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade beginnen bei 1; TradeContainer/TradeOpponent/TradeName und alle TradeCheck-Formen bei 0. Dieser Client erhält diese Konventionen; externe Handbücher verschiedener Engines verwenden unterschiedliche Anfänge.
- Lesen erfolgt im Spielthread aus lebenden Fenstern dieser World. Geschlossene Fenster zählen nicht. Lesen sendet keine Pakete und wartet nicht. Öffnen, Schließen und In-den-Vordergrund-Bringen können die UI-Reihenfolge ändern; der Index ist keine dauerhafte ID.
- ConfirmTrade und eigenes TradeCheck-Schreiben senden nur bei geänderter Zustimmung. Die Gegenseite steuert der Server. CancelTrade sendet einmal. 1/TRUE bedeutet lokalen Zustand/Verarbeitung, keinen abgeschlossenen Transfer. Namen und Häkchen beweisen keinen unveränderten Inhalt.

### Interne Funktionen: vom Aufruf zum Ergebnis

Unten stehen der C#-Aufrufpfad und danach ausführbare Basic-Beispiele. Die Skripte implementieren kein eigenes Netzwerkprotokoll.

#### 1. TradeOpponent

Die Registrierung wählt nach Argumentanzahl; NumberConversions wandelt Zahlen. Zweistelliges TradeCheck prüft Seiten 1/2 und bildet sie auf Bridge-Indizes 0/1 ab. ToHex formatiert Legacy-Serials.

String: Hex-ID2 des Partnerbehälters, sonst "0x00000000". Die Charakter-ID liefert GetTradeOpponent(index + 1).

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; Funktion `TradeOpponent`.

#### 2. TradeOpponent

Invoke verlegt Lesen/Schreiben in den Spielthread mit Skriptabbruch; gelesen werden ID1/ID2, LocalSerial, OpponentName oder Häkchen des gewählten TradingGump.

Liest die Serial des Partnerbehälters als Hex-String, nicht dessen Charakter-ID.

Projektquelle: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; Funktion `TradeOpponent`.

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
# Liest die Serial des Partnerbehälters als Hex-String, nicht dessen Charakter-ID.
#
# String: Hex-ID2 des Partnerbehälters, sonst "0x00000000". Die Charakter-ID liefert
# GetTradeOpponent(index + 1).

SUB Main()
    # Ein Aufruf, gespeichert in value/result. 0 ist der erste Index, 1 die erste Nummer (siehe
    # Syntax). HEX zeigt numerische Serials; CStr Zahlen oder Text.

    VAR value = UO.TradeOpponent(0)
    UO.Print(CStr(value))
END SUB
```

**Erläuterung der Parameter und Ausführung:**

- Ein Aufruf, gespeichert in value/result. 0 ist der erste Index, 1 die erste Nummer (siehe Syntax). HEX zeigt numerische Serials; CStr Zahlen oder Text.

### Weiteres Szenario und Parameter

```vb
# Weiteres Szenario und Parameter
#
# Liest die Serial des Partnerbehälters als Hex-String, nicht dessen Charakter-ID.
#
# String: Hex-ID2 des Partnerbehälters, sonst "0x00000000". Die Charakter-ID liefert
# GetTradeOpponent(index + 1).

SUB Main()
    # total speichert die Fensteranzahl, index den aktuellen Index/die Nummer. Aufzählen bestätigt
    # nichts. GetTradeContainer liest eigenen (1) und fremden (2) Behälter von Fenster 1.

    VAR total = UO.TradeCount()
    FOR VAR index = 0 TO total - 1
        VAR value = UO.TradeOpponent(index)
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
# Liest die Serial des Partnerbehälters als Hex-String, nicht dessen Charakter-ID.
#
# String: Hex-ID2 des Partnerbehälters, sonst "0x00000000". Die Charakter-ID liefert
# GetTradeOpponent(index + 1).

SUB Main()
    # Die vollständige Hilfsfunktion wird von Main aufgerufen. Bereichs-/ID-Prüfungen verringern
    # Fehler, machen mehrere Aufrufe aber nicht atomar. Das Fenster kann wechseln. expectedPartner
    # ist eine gespeicherte Charakter-Serial, keine Preis-/Inhaltsprüfung.

    VAR value = ReadTradeValue(0)
    UO.Print(CStr(value))
END SUB

FUNCTION ReadTradeValue(index)
    VAR total = UO.TradeCount()
    IF index < 0 OR index >= total + 0 THEN
        RETURN "0x00000000"
    END IF
    RETURN UO.TradeOpponent(index)
END FUNCTION
```

**Erläuterung der Parameter und Ausführung:**

- Die vollständige Hilfsfunktion wird von Main aufgerufen. Bereichs-/ID-Prüfungen verringern Fehler, machen mehrere Aufrufe aber nicht atomar. Das Fenster kann wechseln. expectedPartner ist eine gespeicherte Charakter-Serial, keine Preis-/Inhaltsprüfung.
