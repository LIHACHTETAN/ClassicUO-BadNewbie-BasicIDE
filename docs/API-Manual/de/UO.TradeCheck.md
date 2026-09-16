# UO.TradeCheck

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: de -->

Liest Zustimmungshäkchen; die Form mit drei Argumenten kann das eigene ändern.

## Genaue Syntax

```text
UO.TradeCheck(TradeNum:Any, Num:Any) -> Any
UO.TradeCheck(windowIndex:Any) -> Integer
UO.TradeCheck(windowIndex:Any, checkbox:Any, stateValue:Any) -> Integer
```

## Parameter

- `windowIndex` — Ganzzahliger aktueller Fensterindex 0..TradeCount()-1. Negativ/fehlend ergibt einen leeren Rückgabewert. Keine Serial.
- `TradeNum` — Ganzzahliger aktueller Fensterindex 0..TradeCount()-1. Negativ/fehlend ergibt einen leeren Rückgabewert. Keine Serial.
- `Num` — Nur zwei Argumente: 1 eigenes Häkchen, 2 Partnerhäkchen; sonst 0. TradeNum beginnt hier bei 0.
- `checkbox` — Nur drei Argumente: 0 eigenes Häkchen, 1 Partnerhäkchen (nur lesbar); andere Werte ergeben 0.
- `stateValue` — Nur checkbox=0: 0/FALSE entfernt, jeder Nichtnullwert/TRUE setzt Zustimmung. Bei checkbox=1 ignoriert.

## Rückgabewert

Integer: 1 = TRUE bei gesetztem gewähltem Häkchen; 0 = FALSE bei ungesetzt/fehlendem Fenster/ungültiger Seite. Schreiben liefert den Zustand, keinen Handelserfolg: Entfernen liefert 0.

Logisches Ergebnis: 1 = TRUE, 0 = FALSE. Nach VAR result = Befehl(...) sind IF result = TRUE THEN und IF result = 1 THEN gleichwertig; entsprechend IF result = FALSE THEN und IF result = 0 THEN. TRUE/FALSE ohne Anführungszeichen. Einmal aufrufen und speichern: Ein weiterer Aufruf kann die Aktion wiederholen oder einen geänderten Zustand lesen.

## Verhalten

- GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade beginnen bei 1; TradeContainer/TradeOpponent/TradeName und alle TradeCheck-Formen bei 0. Dieser Client erhält diese Konventionen; externe Handbücher verschiedener Engines verwenden unterschiedliche Anfänge.
- Lesen erfolgt im Spielthread aus lebenden Fenstern dieser World. Geschlossene Fenster zählen nicht. Lesen sendet keine Pakete und wartet nicht. Öffnen, Schließen und In-den-Vordergrund-Bringen können die UI-Reihenfolge ändern; der Index ist keine dauerhafte ID.
- ConfirmTrade und eigenes TradeCheck-Schreiben senden nur bei geänderter Zustimmung. Die Gegenseite steuert der Server. CancelTrade sendet einmal. 1/TRUE bedeutet lokalen Zustand/Verarbeitung, keinen abgeschlossenen Transfer. Namen und Häkchen beweisen keinen unveränderten Inhalt.

### Interne Funktionen: vom Aufruf zum Ergebnis

Unten stehen der C#-Aufrufpfad und danach ausführbare Basic-Beispiele. Die Skripte implementieren kein eigenes Netzwerkprotokoll.

#### 1. TradeCheck

Die Registrierung wählt nach Argumentanzahl; NumberConversions wandelt Zahlen. Zweistelliges TradeCheck prüft Seiten 1/2 und bildet sie auf Bridge-Indizes 0/1 ab. ToHex formatiert Legacy-Serials.

Integer: 1 = TRUE bei gesetztem gewähltem Häkchen; 0 = FALSE bei ungesetzt/fehlendem Fenster/ungültiger Seite. Schreiben liefert den Zustand, keinen Handelserfolg: Entfernen liefert 0.

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; Funktion `TradeCheck`.

#### 2. TradeCheck

Invoke verlegt Lesen/Schreiben in den Spielthread mit Skriptabbruch; gelesen werden ID1/ID2, LocalSerial, OpponentName oder Häkchen des gewählten TradingGump.

Liest Zustimmungshäkchen; die Form mit drei Argumenten kann das eigene ändern.

Projektquelle: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; Funktion `TradeCheck`.

#### 3. FindTrade

FindNumberedTrade prüft number>0 vor dem Abziehen von 1; FindTrade weist negative Indizes zurück und zählt nur offene TradingGump dieser World.

GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade beginnen bei 1; TradeContainer/TradeOpponent/TradeName und alle TradeCheck-Formen bei 0. Dieser Client erhält diese Konventionen; externe Handbücher verschiedener Engines verwenden unterschiedliche Anfänge.

Projektquelle: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; Funktion `FindTrade`.

#### 4. AcceptTrade

Bei eigener Zustandsänderung ruft GameActions.AcceptTrade Send_TradeResponse mit Code 2, ID1 und Zustand auf. Lesen und unveränderte Werte senden nichts.

Integer: 1 = TRUE bei gesetztem gewähltem Häkchen; 0 = FALSE bei ungesetzt/fehlendem Fenster/ungültiger Seite. Schreiben liefert den Zustand, keinen Handelserfolg: Entfernen liefert 0.

Projektquelle: `src/ClassicUO.Client/Game/GameActions.cs`; Funktion `AcceptTrade`.

Die vollständige Hilfsfunktion wird von Main aufgerufen. Bereichs-/ID-Prüfungen verringern Fehler, machen mehrere Aufrufe aber nicht atomar. Das Fenster kann wechseln. expectedPartner ist eine gespeicherte Charakter-Serial, keine Preis-/Inhaltsprüfung.


## Beispiele

### Direkt lesen oder ausführen

```vb
# Direkt lesen oder ausführen
#
# Liest Zustimmungshäkchen; die Form mit drei Argumenten kann das eigene ändern.
#
# Integer: 1 = TRUE bei gesetztem gewähltem Häkchen; 0 = FALSE bei ungesetzt/fehlendem
# Fenster/ungültiger Seite. Schreiben liefert den Zustand, keinen Handelserfolg: Entfernen
# liefert 0.
#
# Logisches Ergebnis: 1 = TRUE, 0 = FALSE. Nach VAR result = Befehl(...) sind IF result = TRUE
# THEN und IF result = 1 THEN gleichwertig; entsprechend IF result = FALSE THEN und IF result =
# 0 THEN. TRUE/FALSE ohne Anführungszeichen. Einmal aufrufen und speichern: Ein weiterer Aufruf
# kann die Aktion wiederholen oder einen geänderten Zustand lesen.

SUB Main()
    # TradeCheck(0) und TradeCheck(0,1) lesen das eigene Häkchen des ersten Fensters,
    # TradeCheck(0,2) das fremde. Kein Schreiben und keine automatische Zustimmung.

    VAR own = UO.TradeCheck(0)
    VAR sameOwn = UO.TradeCheck(0, 1)
    VAR other = UO.TradeCheck(0, 2)
    UO.Print(CStr(own) + "/" + CStr(sameOwn) + "/" + CStr(other))
END SUB
```

**Erläuterung der Parameter und Ausführung:**

- TradeCheck(0) und TradeCheck(0,1) lesen das eigene Häkchen des ersten Fensters, TradeCheck(0,2) das fremde. Kein Schreiben und keine automatische Zustimmung.

### Weiteres Szenario und Parameter

```vb
# Weiteres Szenario und Parameter
#
# Liest Zustimmungshäkchen; die Form mit drei Argumenten kann das eigene ändern.
#
# Integer: 1 = TRUE bei gesetztem gewähltem Häkchen; 0 = FALSE bei ungesetzt/fehlendem
# Fenster/ungültiger Seite. Schreiben liefert den Zustand, keinen Handelserfolg: Entfernen
# liefert 0.
#
# Logisches Ergebnis: 1 = TRUE, 0 = FALSE. Nach VAR result = Befehl(...) sind IF result = TRUE
# THEN und IF result = 1 THEN gleichwertig; entsprechend IF result = FALSE THEN und IF result =
# 0 THEN. TRUE/FALSE ohne Anführungszeichen. Einmal aufrufen und speichern: Ein weiterer Aufruf
# kann die Aktion wiederholen oder einen geänderten Zustand lesen.

SUB Main()
    # TradeCheck(0,0,FALSE) entfernt eigene Zustimmung. TradeCheck(0,1,FALSE) liest nur die fremde:
    # FALSE ändert sie nicht. 0 nach Entfernen ist korrekt.

    VAR cleared = UO.TradeCheck(0, 0, FALSE)
    VAR other = UO.TradeCheck(0, 1, FALSE)
    UO.Print(CStr(cleared) + "/" + CStr(other))
END SUB
```

**Erläuterung der Parameter und Ausführung:**

- TradeCheck(0,0,FALSE) entfernt eigene Zustimmung. TradeCheck(0,1,FALSE) liest nur die fremde: FALSE ändert sie nicht. 0 nach Entfernen ist korrekt.

### Vollständige Hilfsfunktion

```vb
# Vollständige Hilfsfunktion
#
# Liest Zustimmungshäkchen; die Form mit drei Argumenten kann das eigene ändern.
#
# Integer: 1 = TRUE bei gesetztem gewähltem Häkchen; 0 = FALSE bei ungesetzt/fehlendem
# Fenster/ungültiger Seite. Schreiben liefert den Zustand, keinen Handelserfolg: Entfernen
# liefert 0.
#
# Logisches Ergebnis: 1 = TRUE, 0 = FALSE. Nach VAR result = Befehl(...) sind IF result = TRUE
# THEN und IF result = 1 THEN gleichwertig; entsprechend IF result = FALSE THEN und IF result =
# 0 THEN. TRUE/FALSE ohne Anführungszeichen. Einmal aufrufen und speichern: Ein weiterer Aufruf
# kann die Aktion wiederholen oder einen geänderten Zustand lesen.

SUB Main()
    # Die vollständige Hilfsfunktion wird von Main aufgerufen. Bereichs-/ID-Prüfungen verringern
    # Fehler, machen mehrere Aufrufe aber nicht atomar. Das Fenster kann wechseln. expectedPartner
    # ist eine gespeicherte Charakter-Serial, keine Preis-/Inhaltsprüfung.

    VAR accepted = BothAccepted(0)
    IF accepted = TRUE THEN
        UO.Print("Both boxes are checked; server completion is not known")
    END IF
END SUB

FUNCTION BothAccepted(index)
    IF index < 0 OR index >= UO.TradeCount() THEN
        RETURN FALSE
    END IF
    VAR own = UO.TradeCheck(index, 1)
    VAR other = UO.TradeCheck(index, 2)
    RETURN own = TRUE AND other = TRUE
END FUNCTION
```

**Erläuterung der Parameter und Ausführung:**

- Die vollständige Hilfsfunktion wird von Main aufgerufen. Bereichs-/ID-Prüfungen verringern Fehler, machen mehrere Aufrufe aber nicht atomar. Das Fenster kann wechseln. expectedPartner ist eine gespeicherte Charakter-Serial, keine Preis-/Inhaltsprüfung.
