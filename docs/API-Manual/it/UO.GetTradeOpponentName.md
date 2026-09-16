# UO.GetTradeOpponentName

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: it -->

Legge il nome ricevuto all’apertura dello scambio.

## Sintassi esatta

```text
UO.GetTradeOpponentName(TradeNum:Any) -> Any
```

## Parametri

- `TradeNum` — Numero intero corrente: 1..TradeCount(). Zero/negativi non validi. Non è un serial.

## Restituisce

String: nome ricevuto all’apertura; vuota senza finestra/nome. Non richiede aggiornamenti.

## Comportamento

- GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade partono da 1; TradeContainer/TradeOpponent/TradeName e tutte le forme TradeCheck da 0. Sono convenzioni conservate da questo client; manuali di motori diversi possono differire.
- Lettura sul thread del gioco dalle finestre vive del World corrente. Finestre chiuse escluse. Leggere non invia pacchetti né attende risposte. Aprire, chiudere o portare avanti una finestra cambia l’ordine UI; l’indice non è un ID permanente.
- ConfirmTrade e scrivere il proprio TradeCheck inviano solo quando cambia il consenso. Il server controlla la casella altrui. CancelTrade invia una volta. 1/TRUE indica stato/elaborazione locale, non trasferimento concluso. Nomi e caselle non provano che gli oggetti siano invariati.

### Funzioni interne: dalla chiamata al risultato

Seguono percorso C# ed esempi Basic eseguibili. Gli script non reimplementano il protocollo di rete.

#### 1. ExecuteStealthCompatibility

La registrazione seleziona per numero di argomenti; NumberConversions converte i numeri. TradeCheck con due argomenti valida 1/2 e li mappa su 0/1 del bridge. ToHex formatta i serial legacy.

String: nome ricevuto all’apertura; vuota senza finestra/nome. Non richiede aggiornamenti.

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; funzione `ExecuteStealthCompatibility`.

#### 2. GetTradeOpponentName

Invoke passa lettura/scrittura al thread del gioco con annullamento dello script; legge ID1/ID2, LocalSerial, OpponentName o le caselle del TradingGump scelto.

Legge il nome ricevuto all’apertura dello scambio.

Sorgente del progetto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; funzione `GetTradeOpponentName`.

#### 3. FindNumberedTrade

FindNumberedTrade verifica number>0 prima di sottrarre 1; FindTrade rifiuta indici negativi ed enumera solo TradingGump aperti di questo World.

GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade partono da 1; TradeContainer/TradeOpponent/TradeName e tutte le forme TradeCheck da 0. Sono convenzioni conservate da questo client; manuali di motori diversi possono differire.

Sorgente del progetto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; funzione `FindNumberedTrade`.

La funzione completa viene chiamata da Main. Controlli di limiti/ID riducono gli errori ma le chiamate non sono atomiche: la finestra può cambiare. expectedPartner è un serial del personaggio salvato, non una verifica di prezzo/contenuto.


## Esempi

### Lettura o azione diretta

```vb
# Lettura o azione diretta
#
# Legge il nome ricevuto all’apertura dello scambio.
#
# String: nome ricevuto all’apertura; vuota senza finestra/nome. Non richiede aggiornamenti.

SUB Main()
    # Una chiamata, salvata in value/result. 0 è il primo indice, 1 il primo numero (vedere
    # sintassi). HEX mostra serial numerici; CStr numeri o testo.

    VAR value = UO.GetTradeOpponentName(1)
    UO.Print(CStr(value))
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

- Una chiamata, salvata in value/result. 0 è il primo indice, 1 il primo numero (vedere sintassi). HEX mostra serial numerici; CStr numeri o testo.

### Altro scenario e parametri

```vb
# Altro scenario e parametri
#
# Legge il nome ricevuto all’apertura dello scambio.
#
# String: nome ricevuto all’apertura; vuota senza finestra/nome. Non richiede aggiornamenti.

SUB Main()
    # total conserva il numero di finestre; index è indice/numero corrente. Enumerare non conferma
    # nulla. GetTradeContainer legge i contenitori proprio (1) e altrui (2) della finestra 1.

    VAR total = UO.TradeCount()
    FOR VAR index = 1 TO total - 0
        VAR value = UO.GetTradeOpponentName(index)
        UO.Print(CStr(index) + ": " + CStr(value))
    NEXT
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

- total conserva il numero di finestre; index è indice/numero corrente. Enumerare non conferma nulla. GetTradeContainer legge i contenitori proprio (1) e altrui (2) della finestra 1.

### Funzione ausiliaria completa

```vb
# Funzione ausiliaria completa
#
# Legge il nome ricevuto all’apertura dello scambio.
#
# String: nome ricevuto all’apertura; vuota senza finestra/nome. Non richiede aggiornamenti.

SUB Main()
    # La funzione completa viene chiamata da Main. Controlli di limiti/ID riducono gli errori ma le
    # chiamate non sono atomiche: la finestra può cambiare. expectedPartner è un serial del
    # personaggio salvato, non una verifica di prezzo/contenuto.

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

**Spiegazione dei parametri e dell’esecuzione:**

- La funzione completa viene chiamata da Main. Controlli di limiti/ID riducono gli errori ma le chiamate non sono atomiche: la finestra può cambiare. expectedPartner è un serial del personaggio salvato, non una verifica di prezzo/contenuto.
