# UO.TradeCount

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: de -->

Zählt geöffnete Handelsfenster.

## Genaue Syntax

```text
UO.TradeCount() -> Integer
```

## Parameter

Keine Parameter.

## Rückgabewert

Integer: Fensteranzahl ab 0. Kein Boolean; auf > 0 prüfen.

## Verhalten

- GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade beginnen bei 1; TradeContainer/TradeOpponent/TradeName und alle TradeCheck-Formen bei 0. Dieser Client erhält diese Konventionen; externe Handbücher verschiedener Engines verwenden unterschiedliche Anfänge.
- Lesen erfolgt im Spielthread aus lebenden Fenstern dieser World. Geschlossene Fenster zählen nicht. Lesen sendet keine Pakete und wartet nicht. Öffnen, Schließen und In-den-Vordergrund-Bringen können die UI-Reihenfolge ändern; der Index ist keine dauerhafte ID.
- ConfirmTrade und eigenes TradeCheck-Schreiben senden nur bei geänderter Zustimmung. Die Gegenseite steuert der Server. CancelTrade sendet einmal. 1/TRUE bedeutet lokalen Zustand/Verarbeitung, keinen abgeschlossenen Transfer. Namen und Häkchen beweisen keinen unveränderten Inhalt.

### Interne Funktionen: vom Aufruf zum Ergebnis

Unten stehen der C#-Aufrufpfad und danach ausführbare Basic-Beispiele. Die Skripte implementieren kein eigenes Netzwerkprotokoll.

#### 1. TradeCount

Die Registrierung wählt nach Argumentanzahl; NumberConversions wandelt Zahlen. Zweistelliges TradeCheck prüft Seiten 1/2 und bildet sie auf Bridge-Indizes 0/1 ab. ToHex formatiert Legacy-Serials.

Integer: Fensteranzahl ab 0. Kein Boolean; auf > 0 prüfen.

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; Funktion `TradeCount`.

#### 2. TradeCount

Invoke verlegt Lesen/Schreiben in den Spielthread mit Skriptabbruch; gelesen werden ID1/ID2, LocalSerial, OpponentName oder Häkchen des gewählten TradingGump.

Zählt geöffnete Handelsfenster.

Projektquelle: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; Funktion `TradeCount`.

Die vollständige Hilfsfunktion wird von Main aufgerufen. Bereichs-/ID-Prüfungen verringern Fehler, machen mehrere Aufrufe aber nicht atomar. Das Fenster kann wechseln. expectedPartner ist eine gespeicherte Charakter-Serial, keine Preis-/Inhaltsprüfung.


## Beispiele

### Direkt lesen oder ausführen

```vb
# Direkt lesen oder ausführen
#
# Zählt geöffnete Handelsfenster.
#
# Integer: Fensteranzahl ab 0. Kein Boolean; auf > 0 prüfen.

SUB Main()
    # Ein Aufruf, gespeichert in value/result. 0 ist der erste Index, 1 die erste Nummer (siehe
    # Syntax). HEX zeigt numerische Serials; CStr Zahlen oder Text.

    VAR value = UO.TradeCount()
    UO.Print(CStr(value))
END SUB
```

**Erläuterung der Parameter und Ausführung:**

- Ein Aufruf, gespeichert in value/result. 0 ist der erste Index, 1 die erste Nummer (siehe Syntax). HEX zeigt numerische Serials; CStr Zahlen oder Text.

### Weiteres Szenario und Parameter

```vb
# Weiteres Szenario und Parameter
#
# Zählt geöffnete Handelsfenster.
#
# Integer: Fensteranzahl ab 0. Kein Boolean; auf > 0 prüfen.

SUB Main()
    # before/after sind getrennte Momentaufnahmen im Abstand von 500 Millisekunden. Die Pause wartet
    # nicht auf einen bestimmten Handel und kann Zwischenänderungen übersehen.

    VAR before = UO.TradeCount()
    WAIT(500)
    VAR after = UO.TradeCount()
    UO.Print(CStr(before) + " -> " + CStr(after))
END SUB
```

**Erläuterung der Parameter und Ausführung:**

- before/after sind getrennte Momentaufnahmen im Abstand von 500 Millisekunden. Die Pause wartet nicht auf einen bestimmten Handel und kann Zwischenänderungen übersehen.

### Vollständige Hilfsfunktion

```vb
# Vollständige Hilfsfunktion
#
# Zählt geöffnete Handelsfenster.
#
# Integer: Fensteranzahl ab 0. Kein Boolean; auf > 0 prüfen.

SUB Main()
    # Die vollständige Hilfsfunktion wird von Main aufgerufen. Bereichs-/ID-Prüfungen verringern
    # Fehler, machen mehrere Aufrufe aber nicht atomar. Das Fenster kann wechseln. expectedPartner
    # ist eine gespeicherte Charakter-Serial, keine Preis-/Inhaltsprüfung.

    VAR value = ReadTradeState()
    UO.Print(CStr(value))
END SUB

FUNCTION ReadTradeState()
    RETURN UO.TradeCount()
END FUNCTION
```

**Erläuterung der Parameter und Ausführung:**

- Die vollständige Hilfsfunktion wird von Main aufgerufen. Bereichs-/ID-Prüfungen verringern Fehler, machen mehrere Aufrufe aber nicht atomar. Das Fenster kann wechseln. expectedPartner ist eine gespeicherte Charakter-Serial, keine Preis-/Inhaltsprüfung.
