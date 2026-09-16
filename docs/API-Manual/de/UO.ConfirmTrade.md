# UO.ConfirmTrade

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: de -->

Setzt die eigene Zustimmung im gewählten Handel.

## Genaue Syntax

```text
UO.ConfirmTrade(TradeNum:Any) -> Any
```

## Parameter

- `TradeNum` — Ganzzahlige aktuelle Fensternummer 1..TradeCount(). Null/negativ ungültig. Keine Serial.

## Rückgabewert

Integer: 1 = TRUE bei vorhandenem Fenster und gesetzter/bereits gesetzter eigener Zustimmung; sonst 0 = FALSE. Kein Nachweis des Serverabschlusses. Wiederholung schaltet nicht aus.

Logisches Ergebnis: 1 = TRUE, 0 = FALSE. Nach VAR result = Befehl(...) sind IF result = TRUE THEN und IF result = 1 THEN gleichwertig; entsprechend IF result = FALSE THEN und IF result = 0 THEN. TRUE/FALSE ohne Anführungszeichen. Einmal aufrufen und speichern: Ein weiterer Aufruf kann die Aktion wiederholen oder einen geänderten Zustand lesen.

## Verhalten

- GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade beginnen bei 1; TradeContainer/TradeOpponent/TradeName und alle TradeCheck-Formen bei 0. Dieser Client erhält diese Konventionen; externe Handbücher verschiedener Engines verwenden unterschiedliche Anfänge.
- Lesen erfolgt im Spielthread aus lebenden Fenstern dieser World. Geschlossene Fenster zählen nicht. Lesen sendet keine Pakete und wartet nicht. Öffnen, Schließen und In-den-Vordergrund-Bringen können die UI-Reihenfolge ändern; der Index ist keine dauerhafte ID.
- ConfirmTrade und eigenes TradeCheck-Schreiben senden nur bei geänderter Zustimmung. Die Gegenseite steuert der Server. CancelTrade sendet einmal. 1/TRUE bedeutet lokalen Zustand/Verarbeitung, keinen abgeschlossenen Transfer. Namen und Häkchen beweisen keinen unveränderten Inhalt.

### Interne Funktionen: vom Aufruf zum Ergebnis

Unten stehen der C#-Aufrufpfad und danach ausführbare Basic-Beispiele. Die Skripte implementieren kein eigenes Netzwerkprotokoll.

#### 1. ExecuteStealthCompatibility

Die Registrierung wählt nach Argumentanzahl; NumberConversions wandelt Zahlen. Zweistelliges TradeCheck prüft Seiten 1/2 und bildet sie auf Bridge-Indizes 0/1 ab. ToHex formatiert Legacy-Serials.

Integer: 1 = TRUE bei vorhandenem Fenster und gesetzter/bereits gesetzter eigener Zustimmung; sonst 0 = FALSE. Kein Nachweis des Serverabschlusses. Wiederholung schaltet nicht aus.

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; Funktion `ExecuteStealthCompatibility`.

#### 2. ConfirmTrade

Invoke verlegt Lesen/Schreiben in den Spielthread mit Skriptabbruch; gelesen werden ID1/ID2, LocalSerial, OpponentName oder Häkchen des gewählten TradingGump.

Setzt die eigene Zustimmung im gewählten Handel.

Projektquelle: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; Funktion `ConfirmTrade`.

#### 3. FindNumberedTrade

FindNumberedTrade prüft number>0 vor dem Abziehen von 1; FindTrade weist negative Indizes zurück und zählt nur offene TradingGump dieser World.

GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade beginnen bei 1; TradeContainer/TradeOpponent/TradeName und alle TradeCheck-Formen bei 0. Dieser Client erhält diese Konventionen; externe Handbücher verschiedener Engines verwenden unterschiedliche Anfänge.

Projektquelle: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; Funktion `FindNumberedTrade`.

#### 4. AcceptTrade

Bei eigener Zustandsänderung ruft GameActions.AcceptTrade Send_TradeResponse mit Code 2, ID1 und Zustand auf. Lesen und unveränderte Werte senden nichts.

Integer: 1 = TRUE bei vorhandenem Fenster und gesetzter/bereits gesetzter eigener Zustimmung; sonst 0 = FALSE. Kein Nachweis des Serverabschlusses. Wiederholung schaltet nicht aus.

Projektquelle: `src/ClassicUO.Client/Game/GameActions.cs`; Funktion `AcceptTrade`.

Die vollständige Hilfsfunktion wird von Main aufgerufen. Bereichs-/ID-Prüfungen verringern Fehler, machen mehrere Aufrufe aber nicht atomar. Das Fenster kann wechseln. expectedPartner ist eine gespeicherte Charakter-Serial, keine Preis-/Inhaltsprüfung.


## Beispiele

### Direkt lesen oder ausführen

```vb
# Direkt lesen oder ausführen
#
# Setzt die eigene Zustimmung im gewählten Handel.
#
# Integer: 1 = TRUE bei vorhandenem Fenster und gesetzter/bereits gesetzter eigener Zustimmung;
# sonst 0 = FALSE. Kein Nachweis des Serverabschlusses. Wiederholung schaltet nicht aus.
#
# Logisches Ergebnis: 1 = TRUE, 0 = FALSE. Nach VAR result = Befehl(...) sind IF result = TRUE
# THEN und IF result = 1 THEN gleichwertig; entsprechend IF result = FALSE THEN und IF result =
# 0 THEN. TRUE/FALSE ohne Anführungszeichen. Einmal aufrufen und speichern: Ein weiterer Aufruf
# kann die Aktion wiederholen oder einen geänderten Zustand lesen.

SUB Main()
    # Ein Aufruf, gespeichert in value/result. 0 ist der erste Index, 1 die erste Nummer (siehe
    # Syntax). HEX zeigt numerische Serials; CStr Zahlen oder Text.

    VAR result = UO.ConfirmTrade(1)
    IF result = TRUE THEN
        UO.Print("Local request processed")
    END IF
END SUB
```

**Erläuterung der Parameter und Ausführung:**

- Ein Aufruf, gespeichert in value/result. 0 ist der erste Index, 1 die erste Nummer (siehe Syntax). HEX zeigt numerische Serials; CStr Zahlen oder Text.

### Weiteres Szenario und Parameter

```vb
# Weiteres Szenario und Parameter
#
# Setzt die eigene Zustimmung im gewählten Handel.
#
# Integer: 1 = TRUE bei vorhandenem Fenster und gesetzter/bereits gesetzter eigener Zustimmung;
# sonst 0 = FALSE. Kein Nachweis des Serverabschlusses. Wiederholung schaltet nicht aus.
#
# Logisches Ergebnis: 1 = TRUE, 0 = FALSE. Nach VAR result = Befehl(...) sind IF result = TRUE
# THEN und IF result = 1 THEN gleichwertig; entsprechend IF result = FALSE THEN und IF result =
# 0 THEN. TRUE/FALSE ohne Anführungszeichen. Einmal aufrufen und speichern: Ein weiterer Aufruf
# kann die Aktion wiederholen oder einen geänderten Zustand lesen.

SUB Main()
    # ConfirmTrade und eigenes TradeCheck-Schreiben senden nur bei geänderter Zustimmung. Die
    # Gegenseite steuert der Server. CancelTrade sendet einmal. 1/TRUE bedeutet lokalen
    # Zustand/Verarbeitung, keinen abgeschlossenen Transfer. Namen und Häkchen beweisen keinen
    # unveränderten Inhalt.

    VAR tradeNumber = 2
    IF UO.TradeCount() >= tradeNumber THEN
        VAR result = UO.ConfirmTrade(tradeNumber)
        UO.Print(CStr(result))
    END IF
END SUB
```

**Erläuterung der Parameter und Ausführung:**

- ConfirmTrade und eigenes TradeCheck-Schreiben senden nur bei geänderter Zustimmung. Die Gegenseite steuert der Server. CancelTrade sendet einmal. 1/TRUE bedeutet lokalen Zustand/Verarbeitung, keinen abgeschlossenen Transfer. Namen und Häkchen beweisen keinen unveränderten Inhalt.

### Vollständige Hilfsfunktion

```vb
# Vollständige Hilfsfunktion
#
# Setzt die eigene Zustimmung im gewählten Handel.
#
# Integer: 1 = TRUE bei vorhandenem Fenster und gesetzter/bereits gesetzter eigener Zustimmung;
# sonst 0 = FALSE. Kein Nachweis des Serverabschlusses. Wiederholung schaltet nicht aus.
#
# Logisches Ergebnis: 1 = TRUE, 0 = FALSE. Nach VAR result = Befehl(...) sind IF result = TRUE
# THEN und IF result = 1 THEN gleichwertig; entsprechend IF result = FALSE THEN und IF result =
# 0 THEN. TRUE/FALSE ohne Anführungszeichen. Einmal aufrufen und speichern: Ein weiterer Aufruf
# kann die Aktion wiederholen oder einen geänderten Zustand lesen.

SUB Main()
    # Die vollständige Hilfsfunktion wird von Main aufgerufen. Bereichs-/ID-Prüfungen verringern
    # Fehler, machen mehrere Aufrufe aber nicht atomar. Das Fenster kann wechseln. expectedPartner
    # ist eine gespeicherte Charakter-Serial, keine Preis-/Inhaltsprüfung.

    VAR expectedPartner = UO.GetTradeOpponent(1)
    VAR result = ApplyToPartner(1, expectedPartner)
    UO.Print(CStr(result))
END SUB

FUNCTION ApplyToPartner(tradeNumber, expectedPartner)
    IF expectedPartner = 0 THEN
        RETURN FALSE
    END IF
    IF UO.GetTradeOpponent(tradeNumber) <> expectedPartner THEN
        RETURN FALSE
    END IF
    RETURN UO.ConfirmTrade(tradeNumber)
END FUNCTION
```

**Erläuterung der Parameter und Ausführung:**

- Die vollständige Hilfsfunktion wird von Main aufgerufen. Bereichs-/ID-Prüfungen verringern Fehler, machen mehrere Aufrufe aber nicht atomar. Das Fenster kann wechseln. expectedPartner ist eine gespeicherte Charakter-Serial, keine Preis-/Inhaltsprüfung.
