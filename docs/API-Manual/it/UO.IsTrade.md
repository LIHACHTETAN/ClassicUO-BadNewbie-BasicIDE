# UO.IsTrade

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: it -->

Controlla se esiste una finestra di scambio sicuro aperta.

## Sintassi esatta

```text
UO.IsTrade() -> Integer
```

## Parametri

Nessun parametro.

## Restituisce

Integer: 1 = TRUE se uno scambio è aperto, altrimenti 0 = FALSE.

Risultato logico: 1 = TRUE, 0 = FALSE. Dopo VAR result = comando(...), usare IF result = TRUE THEN o IF result = 1 THEN; per il risultato negativo, IF result = FALSE THEN o IF result = 0 THEN. TRUE/FALSE senza virgolette. Chiamare una sola volta e salvare il risultato: un nuovo richiamo può ripetere l’azione o leggere uno stato cambiato.

## Comportamento

- GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade partono da 1; TradeContainer/TradeOpponent/TradeName e tutte le forme TradeCheck da 0. Sono convenzioni conservate da questo client; manuali di motori diversi possono differire.
- Lettura sul thread del gioco dalle finestre vive del World corrente. Finestre chiuse escluse. Leggere non invia pacchetti né attende risposte. Aprire, chiudere o portare avanti una finestra cambia l’ordine UI; l’indice non è un ID permanente.
- ConfirmTrade e scrivere il proprio TradeCheck inviano solo quando cambia il consenso. Il server controlla la casella altrui. CancelTrade invia una volta. 1/TRUE indica stato/elaborazione locale, non trasferimento concluso. Nomi e caselle non provano che gli oggetti siano invariati.

### Funzioni interne: dalla chiamata al risultato

Seguono percorso C# ed esempi Basic eseguibili. Gli script non reimplementano il protocollo di rete.

#### 1. ExecuteStealthCompatibility

La registrazione seleziona per numero di argomenti; NumberConversions converte i numeri. TradeCheck con due argomenti valida 1/2 e li mappa su 0/1 del bridge. ToHex formatta i serial legacy.

Integer: 1 = TRUE se uno scambio è aperto, altrimenti 0 = FALSE.

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; funzione `ExecuteStealthCompatibility`.

#### 2. IsTrade

Invoke passa lettura/scrittura al thread del gioco con annullamento dello script; legge ID1/ID2, LocalSerial, OpponentName o le caselle del TradingGump scelto.

Controlla se esiste una finestra di scambio sicuro aperta.

Sorgente del progetto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; funzione `IsTrade`.

#### 3. FindTrade

FindNumberedTrade verifica number>0 prima di sottrarre 1; FindTrade rifiuta indici negativi ed enumera solo TradingGump aperti di questo World.

GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade partono da 1; TradeContainer/TradeOpponent/TradeName e tutte le forme TradeCheck da 0. Sono convenzioni conservate da questo client; manuali di motori diversi possono differire.

Sorgente del progetto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; funzione `FindTrade`.

La funzione completa viene chiamata da Main. Controlli di limiti/ID riducono gli errori ma le chiamate non sono atomiche: la finestra può cambiare. expectedPartner è un serial del personaggio salvato, non una verifica di prezzo/contenuto.


## Esempi

### Lettura o azione diretta

```vb
# Lettura o azione diretta
#
# Controlla se esiste una finestra di scambio sicuro aperta.
#
# Integer: 1 = TRUE se uno scambio è aperto, altrimenti 0 = FALSE.
#
# Risultato logico: 1 = TRUE, 0 = FALSE. Dopo VAR result = comando(...), usare IF result = TRUE
# THEN o IF result = 1 THEN; per il risultato negativo, IF result = FALSE THEN o IF result = 0
# THEN. TRUE/FALSE senza virgolette. Chiamare una sola volta e salvare il risultato: un nuovo
# richiamo può ripetere l’azione o leggere uno stato cambiato.

SUB Main()
    # Una chiamata, salvata in value/result. 0 è il primo indice, 1 il primo numero (vedere
    # sintassi). HEX mostra serial numerici; CStr numeri o testo.

    VAR value = UO.IsTrade()
    UO.Print(CStr(value))
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

- Una chiamata, salvata in value/result. 0 è il primo indice, 1 il primo numero (vedere sintassi). HEX mostra serial numerici; CStr numeri o testo.

### Altro scenario e parametri

```vb
# Altro scenario e parametri
#
# Controlla se esiste una finestra di scambio sicuro aperta.
#
# Integer: 1 = TRUE se uno scambio è aperto, altrimenti 0 = FALSE.
#
# Risultato logico: 1 = TRUE, 0 = FALSE. Dopo VAR result = comando(...), usare IF result = TRUE
# THEN o IF result = 1 THEN; per il risultato negativo, IF result = FALSE THEN o IF result = 0
# THEN. TRUE/FALSE senza virgolette. Chiamare una sola volta e salvare il risultato: un nuovo
# richiamo può ripetere l’azione o leggere uno stato cambiato.

SUB Main()
    # before/after sono istantanee separate da 500 millisecondi. La pausa non attende uno scambio
    # specifico e può perdere modifiche intermedie.

    VAR before = UO.IsTrade()
    WAIT(500)
    VAR after = UO.IsTrade()
    UO.Print(CStr(before) + " -> " + CStr(after))
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

- before/after sono istantanee separate da 500 millisecondi. La pausa non attende uno scambio specifico e può perdere modifiche intermedie.

### Funzione ausiliaria completa

```vb
# Funzione ausiliaria completa
#
# Controlla se esiste una finestra di scambio sicuro aperta.
#
# Integer: 1 = TRUE se uno scambio è aperto, altrimenti 0 = FALSE.
#
# Risultato logico: 1 = TRUE, 0 = FALSE. Dopo VAR result = comando(...), usare IF result = TRUE
# THEN o IF result = 1 THEN; per il risultato negativo, IF result = FALSE THEN o IF result = 0
# THEN. TRUE/FALSE senza virgolette. Chiamare una sola volta e salvare il risultato: un nuovo
# richiamo può ripetere l’azione o leggere uno stato cambiato.

SUB Main()
    # La funzione completa viene chiamata da Main. Controlli di limiti/ID riducono gli errori ma le
    # chiamate non sono atomiche: la finestra può cambiare. expectedPartner è un serial del
    # personaggio salvato, non una verifica di prezzo/contenuto.

    VAR value = ReadTradeState()
    UO.Print(CStr(value))
END SUB

FUNCTION ReadTradeState()
    RETURN UO.IsTrade()
END FUNCTION
```

**Spiegazione dei parametri e dell’esecuzione:**

- La funzione completa viene chiamata da Main. Controlli di limiti/ID riducono gli errori ma le chiamate non sono atomiche: la finestra può cambiare. expectedPartner è un serial del personaggio salvato, non una verifica di prezzo/contenuto.
