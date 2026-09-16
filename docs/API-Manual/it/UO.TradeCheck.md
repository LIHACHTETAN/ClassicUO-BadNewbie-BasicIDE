# UO.TradeCheck

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: it -->

Legge le caselle di consenso; tre argomenti consentono anche di modificare la propria.

## Sintassi esatta

```text
UO.TradeCheck(TradeNum:Any, Num:Any) -> Any
UO.TradeCheck(windowIndex:Any) -> Integer
UO.TradeCheck(windowIndex:Any, checkbox:Any, stateValue:Any) -> Integer
```

## Parametri

- `windowIndex` — Indice intero corrente: 0..TradeCount()-1. Negativo/assente produce un risultato vuoto. Non è un serial.
- `TradeNum` — Indice intero corrente: 0..TradeCount()-1. Negativo/assente produce un risultato vuoto. Non è un serial.
- `Num` — Solo due argomenti: 1 propria casella, 2 casella altrui; altrimenti 0. Qui TradeNum parte da 0.
- `checkbox` — Solo tre argomenti: 0 propria casella, 1 quella altrui in sola lettura; altri valori restituiscono 0.
- `stateValue` — Solo checkbox=0: 0/FALSE rimuove il consenso, qualsiasi numero non nullo/TRUE lo imposta. Ignorato per checkbox=1.

## Restituisce

Integer: 1 = TRUE con casella selezionata; 0 = FALSE se deselezionata o finestra/lato non valido. La scrittura restituisce lo stato, non l’esito dello scambio: togliere il consenso restituisce 0.

Risultato logico: 1 = TRUE, 0 = FALSE. Dopo VAR result = comando(...), usare IF result = TRUE THEN o IF result = 1 THEN; per il risultato negativo, IF result = FALSE THEN o IF result = 0 THEN. TRUE/FALSE senza virgolette. Chiamare una sola volta e salvare il risultato: un nuovo richiamo può ripetere l’azione o leggere uno stato cambiato.

## Comportamento

- GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade partono da 1; TradeContainer/TradeOpponent/TradeName e tutte le forme TradeCheck da 0. Sono convenzioni conservate da questo client; manuali di motori diversi possono differire.
- Lettura sul thread del gioco dalle finestre vive del World corrente. Finestre chiuse escluse. Leggere non invia pacchetti né attende risposte. Aprire, chiudere o portare avanti una finestra cambia l’ordine UI; l’indice non è un ID permanente.
- ConfirmTrade e scrivere il proprio TradeCheck inviano solo quando cambia il consenso. Il server controlla la casella altrui. CancelTrade invia una volta. 1/TRUE indica stato/elaborazione locale, non trasferimento concluso. Nomi e caselle non provano che gli oggetti siano invariati.

### Funzioni interne: dalla chiamata al risultato

Seguono percorso C# ed esempi Basic eseguibili. Gli script non reimplementano il protocollo di rete.

#### 1. TradeCheck

La registrazione seleziona per numero di argomenti; NumberConversions converte i numeri. TradeCheck con due argomenti valida 1/2 e li mappa su 0/1 del bridge. ToHex formatta i serial legacy.

Integer: 1 = TRUE con casella selezionata; 0 = FALSE se deselezionata o finestra/lato non valido. La scrittura restituisce lo stato, non l’esito dello scambio: togliere il consenso restituisce 0.

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; funzione `TradeCheck`.

#### 2. TradeCheck

Invoke passa lettura/scrittura al thread del gioco con annullamento dello script; legge ID1/ID2, LocalSerial, OpponentName o le caselle del TradingGump scelto.

Legge le caselle di consenso; tre argomenti consentono anche di modificare la propria.

Sorgente del progetto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; funzione `TradeCheck`.

#### 3. FindTrade

FindNumberedTrade verifica number>0 prima di sottrarre 1; FindTrade rifiuta indici negativi ed enumera solo TradingGump aperti di questo World.

GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade partono da 1; TradeContainer/TradeOpponent/TradeName e tutte le forme TradeCheck da 0. Sono convenzioni conservate da questo client; manuali di motori diversi possono differire.

Sorgente del progetto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; funzione `FindTrade`.

#### 4. AcceptTrade

Al cambiamento della propria casella, GameActions.AcceptTrade chiama Send_TradeResponse con codice 2, ID1 e stato. Letture e valori invariati non inviano pacchetti.

Integer: 1 = TRUE con casella selezionata; 0 = FALSE se deselezionata o finestra/lato non valido. La scrittura restituisce lo stato, non l’esito dello scambio: togliere il consenso restituisce 0.

Sorgente del progetto: `src/ClassicUO.Client/Game/GameActions.cs`; funzione `AcceptTrade`.

La funzione completa viene chiamata da Main. Controlli di limiti/ID riducono gli errori ma le chiamate non sono atomiche: la finestra può cambiare. expectedPartner è un serial del personaggio salvato, non una verifica di prezzo/contenuto.


## Esempi

### Lettura o azione diretta

```vb
# Lettura o azione diretta
#
# Legge le caselle di consenso; tre argomenti consentono anche di modificare la propria.
#
# Integer: 1 = TRUE con casella selezionata; 0 = FALSE se deselezionata o finestra/lato non
# valido. La scrittura restituisce lo stato, non l’esito dello scambio: togliere il consenso
# restituisce 0.
#
# Risultato logico: 1 = TRUE, 0 = FALSE. Dopo VAR result = comando(...), usare IF result = TRUE
# THEN o IF result = 1 THEN; per il risultato negativo, IF result = FALSE THEN o IF result = 0
# THEN. TRUE/FALSE senza virgolette. Chiamare una sola volta e salvare il risultato: un nuovo
# richiamo può ripetere l’azione o leggere uno stato cambiato.

SUB Main()
    # TradeCheck(0) e TradeCheck(0,1) leggono il proprio consenso nella prima finestra;
    # TradeCheck(0,2) quello altrui. Nessuna scrittura o conferma automatica.

    VAR own = UO.TradeCheck(0)
    VAR sameOwn = UO.TradeCheck(0, 1)
    VAR other = UO.TradeCheck(0, 2)
    UO.Print(CStr(own) + "/" + CStr(sameOwn) + "/" + CStr(other))
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

- TradeCheck(0) e TradeCheck(0,1) leggono il proprio consenso nella prima finestra; TradeCheck(0,2) quello altrui. Nessuna scrittura o conferma automatica.

### Altro scenario e parametri

```vb
# Altro scenario e parametri
#
# Legge le caselle di consenso; tre argomenti consentono anche di modificare la propria.
#
# Integer: 1 = TRUE con casella selezionata; 0 = FALSE se deselezionata o finestra/lato non
# valido. La scrittura restituisce lo stato, non l’esito dello scambio: togliere il consenso
# restituisce 0.
#
# Risultato logico: 1 = TRUE, 0 = FALSE. Dopo VAR result = comando(...), usare IF result = TRUE
# THEN o IF result = 1 THEN; per il risultato negativo, IF result = FALSE THEN o IF result = 0
# THEN. TRUE/FALSE senza virgolette. Chiamare una sola volta e salvare il risultato: un nuovo
# richiamo può ripetere l’azione o leggere uno stato cambiato.

SUB Main()
    # TradeCheck(0,0,FALSE) toglie il proprio consenso. TradeCheck(0,1,FALSE) legge soltanto quello
    # altrui: FALSE non lo modifica. Il ritorno 0 dopo la rimozione è normale.

    VAR cleared = UO.TradeCheck(0, 0, FALSE)
    VAR other = UO.TradeCheck(0, 1, FALSE)
    UO.Print(CStr(cleared) + "/" + CStr(other))
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

- TradeCheck(0,0,FALSE) toglie il proprio consenso. TradeCheck(0,1,FALSE) legge soltanto quello altrui: FALSE non lo modifica. Il ritorno 0 dopo la rimozione è normale.

### Funzione ausiliaria completa

```vb
# Funzione ausiliaria completa
#
# Legge le caselle di consenso; tre argomenti consentono anche di modificare la propria.
#
# Integer: 1 = TRUE con casella selezionata; 0 = FALSE se deselezionata o finestra/lato non
# valido. La scrittura restituisce lo stato, non l’esito dello scambio: togliere il consenso
# restituisce 0.
#
# Risultato logico: 1 = TRUE, 0 = FALSE. Dopo VAR result = comando(...), usare IF result = TRUE
# THEN o IF result = 1 THEN; per il risultato negativo, IF result = FALSE THEN o IF result = 0
# THEN. TRUE/FALSE senza virgolette. Chiamare una sola volta e salvare il risultato: un nuovo
# richiamo può ripetere l’azione o leggere uno stato cambiato.

SUB Main()
    # La funzione completa viene chiamata da Main. Controlli di limiti/ID riducono gli errori ma le
    # chiamate non sono atomiche: la finestra può cambiare. expectedPartner è un serial del
    # personaggio salvato, non una verifica di prezzo/contenuto.

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

**Spiegazione dei parametri e dell’esecuzione:**

- La funzione completa viene chiamata da Main. Controlli di limiti/ID riducono gli errori ma le chiamate non sono atomiche: la finestra può cambiare. expectedPartner è un serial del personaggio salvato, non una verifica di prezzo/contenuto.
