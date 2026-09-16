# UO.ConfirmTrade

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: it -->

Imposta il proprio consenso nello scambio selezionato.

## Sintassi esatta

```text
UO.ConfirmTrade(TradeNum:Any) -> Any
```

## Parametri

- `TradeNum` — Numero intero corrente: 1..TradeCount(). Zero/negativi non validi. Non è un serial.

## Restituisce

Integer: 1 = TRUE con finestra presente e consenso proprio impostato/già impostato; altrimenti 0 = FALSE. Non prova la conclusione sul server. Ripetere non toglie il consenso.

Risultato logico: 1 = TRUE, 0 = FALSE. Dopo VAR result = comando(...), usare IF result = TRUE THEN o IF result = 1 THEN; per il risultato negativo, IF result = FALSE THEN o IF result = 0 THEN. TRUE/FALSE senza virgolette. Chiamare una sola volta e salvare il risultato: un nuovo richiamo può ripetere l’azione o leggere uno stato cambiato.

## Comportamento

- GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade partono da 1; TradeContainer/TradeOpponent/TradeName e tutte le forme TradeCheck da 0. Sono convenzioni conservate da questo client; manuali di motori diversi possono differire.
- Lettura sul thread del gioco dalle finestre vive del World corrente. Finestre chiuse escluse. Leggere non invia pacchetti né attende risposte. Aprire, chiudere o portare avanti una finestra cambia l’ordine UI; l’indice non è un ID permanente.
- ConfirmTrade e scrivere il proprio TradeCheck inviano solo quando cambia il consenso. Il server controlla la casella altrui. CancelTrade invia una volta. 1/TRUE indica stato/elaborazione locale, non trasferimento concluso. Nomi e caselle non provano che gli oggetti siano invariati.

### Funzioni interne: dalla chiamata al risultato

Seguono percorso C# ed esempi Basic eseguibili. Gli script non reimplementano il protocollo di rete.

#### 1. ExecuteStealthCompatibility

La registrazione seleziona per numero di argomenti; NumberConversions converte i numeri. TradeCheck con due argomenti valida 1/2 e li mappa su 0/1 del bridge. ToHex formatta i serial legacy.

Integer: 1 = TRUE con finestra presente e consenso proprio impostato/già impostato; altrimenti 0 = FALSE. Non prova la conclusione sul server. Ripetere non toglie il consenso.

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; funzione `ExecuteStealthCompatibility`.

#### 2. ConfirmTrade

Invoke passa lettura/scrittura al thread del gioco con annullamento dello script; legge ID1/ID2, LocalSerial, OpponentName o le caselle del TradingGump scelto.

Imposta il proprio consenso nello scambio selezionato.

Sorgente del progetto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; funzione `ConfirmTrade`.

#### 3. FindNumberedTrade

FindNumberedTrade verifica number>0 prima di sottrarre 1; FindTrade rifiuta indici negativi ed enumera solo TradingGump aperti di questo World.

GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade partono da 1; TradeContainer/TradeOpponent/TradeName e tutte le forme TradeCheck da 0. Sono convenzioni conservate da questo client; manuali di motori diversi possono differire.

Sorgente del progetto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; funzione `FindNumberedTrade`.

#### 4. AcceptTrade

Al cambiamento della propria casella, GameActions.AcceptTrade chiama Send_TradeResponse con codice 2, ID1 e stato. Letture e valori invariati non inviano pacchetti.

Integer: 1 = TRUE con finestra presente e consenso proprio impostato/già impostato; altrimenti 0 = FALSE. Non prova la conclusione sul server. Ripetere non toglie il consenso.

Sorgente del progetto: `src/ClassicUO.Client/Game/GameActions.cs`; funzione `AcceptTrade`.

La funzione completa viene chiamata da Main. Controlli di limiti/ID riducono gli errori ma le chiamate non sono atomiche: la finestra può cambiare. expectedPartner è un serial del personaggio salvato, non una verifica di prezzo/contenuto.


## Esempi

### Lettura o azione diretta

```vb
# Lettura o azione diretta
#
# Imposta il proprio consenso nello scambio selezionato.
#
# Integer: 1 = TRUE con finestra presente e consenso proprio impostato/già impostato; altrimenti
# 0 = FALSE. Non prova la conclusione sul server. Ripetere non toglie il consenso.
#
# Risultato logico: 1 = TRUE, 0 = FALSE. Dopo VAR result = comando(...), usare IF result = TRUE
# THEN o IF result = 1 THEN; per il risultato negativo, IF result = FALSE THEN o IF result = 0
# THEN. TRUE/FALSE senza virgolette. Chiamare una sola volta e salvare il risultato: un nuovo
# richiamo può ripetere l’azione o leggere uno stato cambiato.

SUB Main()
    # Una chiamata, salvata in value/result. 0 è il primo indice, 1 il primo numero (vedere
    # sintassi). HEX mostra serial numerici; CStr numeri o testo.

    VAR result = UO.ConfirmTrade(1)
    IF result = TRUE THEN
        UO.Print("Local request processed")
    END IF
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

- Una chiamata, salvata in value/result. 0 è il primo indice, 1 il primo numero (vedere sintassi). HEX mostra serial numerici; CStr numeri o testo.

### Altro scenario e parametri

```vb
# Altro scenario e parametri
#
# Imposta il proprio consenso nello scambio selezionato.
#
# Integer: 1 = TRUE con finestra presente e consenso proprio impostato/già impostato; altrimenti
# 0 = FALSE. Non prova la conclusione sul server. Ripetere non toglie il consenso.
#
# Risultato logico: 1 = TRUE, 0 = FALSE. Dopo VAR result = comando(...), usare IF result = TRUE
# THEN o IF result = 1 THEN; per il risultato negativo, IF result = FALSE THEN o IF result = 0
# THEN. TRUE/FALSE senza virgolette. Chiamare una sola volta e salvare il risultato: un nuovo
# richiamo può ripetere l’azione o leggere uno stato cambiato.

SUB Main()
    # ConfirmTrade e scrivere il proprio TradeCheck inviano solo quando cambia il consenso. Il
    # server controlla la casella altrui. CancelTrade invia una volta. 1/TRUE indica
    # stato/elaborazione locale, non trasferimento concluso. Nomi e caselle non provano che gli
    # oggetti siano invariati.

    VAR tradeNumber = 2
    IF UO.TradeCount() >= tradeNumber THEN
        VAR result = UO.ConfirmTrade(tradeNumber)
        UO.Print(CStr(result))
    END IF
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

- ConfirmTrade e scrivere il proprio TradeCheck inviano solo quando cambia il consenso. Il server controlla la casella altrui. CancelTrade invia una volta. 1/TRUE indica stato/elaborazione locale, non trasferimento concluso. Nomi e caselle non provano che gli oggetti siano invariati.

### Funzione ausiliaria completa

```vb
# Funzione ausiliaria completa
#
# Imposta il proprio consenso nello scambio selezionato.
#
# Integer: 1 = TRUE con finestra presente e consenso proprio impostato/già impostato; altrimenti
# 0 = FALSE. Non prova la conclusione sul server. Ripetere non toglie il consenso.
#
# Risultato logico: 1 = TRUE, 0 = FALSE. Dopo VAR result = comando(...), usare IF result = TRUE
# THEN o IF result = 1 THEN; per il risultato negativo, IF result = FALSE THEN o IF result = 0
# THEN. TRUE/FALSE senza virgolette. Chiamare una sola volta e salvare il risultato: un nuovo
# richiamo può ripetere l’azione o leggere uno stato cambiato.

SUB Main()
    # La funzione completa viene chiamata da Main. Controlli di limiti/ID riducono gli errori ma le
    # chiamate non sono atomiche: la finestra può cambiare. expectedPartner è un serial del
    # personaggio salvato, non una verifica di prezzo/contenuto.

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

**Spiegazione dei parametri e dell’esecuzione:**

- La funzione completa viene chiamata da Main. Controlli di limiti/ID riducono gli errori ma le chiamate non sono atomiche: la finestra può cambiare. expectedPartner è un serial del personaggio salvato, non una verifica di prezzo/contenuto.
