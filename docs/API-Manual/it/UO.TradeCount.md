# UO.TradeCount

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: it -->

Conta le finestre di scambio aperte.

## Sintassi esatta

```text
UO.TradeCount() -> Integer
```

## Parametri

Nessun parametro.

## Restituisce

Integer: numero di finestre da 0. Non Boolean; verificare > 0.

## Comportamento

- GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade partono da 1; TradeContainer/TradeOpponent/TradeName e tutte le forme TradeCheck da 0. Sono convenzioni conservate da questo client; manuali di motori diversi possono differire.
- Lettura sul thread del gioco dalle finestre vive del World corrente. Finestre chiuse escluse. Leggere non invia pacchetti né attende risposte. Aprire, chiudere o portare avanti una finestra cambia l’ordine UI; l’indice non è un ID permanente.
- ConfirmTrade e scrivere il proprio TradeCheck inviano solo quando cambia il consenso. Il server controlla la casella altrui. CancelTrade invia una volta. 1/TRUE indica stato/elaborazione locale, non trasferimento concluso. Nomi e caselle non provano che gli oggetti siano invariati.

### Funzioni interne: dalla chiamata al risultato

Seguono percorso C# ed esempi Basic eseguibili. Gli script non reimplementano il protocollo di rete.

#### 1. TradeCount

La registrazione seleziona per numero di argomenti; NumberConversions converte i numeri. TradeCheck con due argomenti valida 1/2 e li mappa su 0/1 del bridge. ToHex formatta i serial legacy.

Integer: numero di finestre da 0. Non Boolean; verificare > 0.

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; funzione `TradeCount`.

#### 2. TradeCount

Invoke passa lettura/scrittura al thread del gioco con annullamento dello script; legge ID1/ID2, LocalSerial, OpponentName o le caselle del TradingGump scelto.

Conta le finestre di scambio aperte.

Sorgente del progetto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; funzione `TradeCount`.

La funzione completa viene chiamata da Main. Controlli di limiti/ID riducono gli errori ma le chiamate non sono atomiche: la finestra può cambiare. expectedPartner è un serial del personaggio salvato, non una verifica di prezzo/contenuto.


## Esempi

### Lettura o azione diretta

```vb
# Lettura o azione diretta
#
# Conta le finestre di scambio aperte.
#
# Integer: numero di finestre da 0. Non Boolean; verificare > 0.

SUB Main()
    # Una chiamata, salvata in value/result. 0 è il primo indice, 1 il primo numero (vedere
    # sintassi). HEX mostra serial numerici; CStr numeri o testo.

    VAR value = UO.TradeCount()
    UO.Print(CStr(value))
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

- Una chiamata, salvata in value/result. 0 è il primo indice, 1 il primo numero (vedere sintassi). HEX mostra serial numerici; CStr numeri o testo.

### Altro scenario e parametri

```vb
# Altro scenario e parametri
#
# Conta le finestre di scambio aperte.
#
# Integer: numero di finestre da 0. Non Boolean; verificare > 0.

SUB Main()
    # before/after sono istantanee separate da 500 millisecondi. La pausa non attende uno scambio
    # specifico e può perdere modifiche intermedie.

    VAR before = UO.TradeCount()
    WAIT(500)
    VAR after = UO.TradeCount()
    UO.Print(CStr(before) + " -> " + CStr(after))
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

- before/after sono istantanee separate da 500 millisecondi. La pausa non attende uno scambio specifico e può perdere modifiche intermedie.

### Funzione ausiliaria completa

```vb
# Funzione ausiliaria completa
#
# Conta le finestre di scambio aperte.
#
# Integer: numero di finestre da 0. Non Boolean; verificare > 0.

SUB Main()
    # La funzione completa viene chiamata da Main. Controlli di limiti/ID riducono gli errori ma le
    # chiamate non sono atomiche: la finestra può cambiare. expectedPartner è un serial del
    # personaggio salvato, non una verifica di prezzo/contenuto.

    VAR value = ReadTradeState()
    UO.Print(CStr(value))
END SUB

FUNCTION ReadTradeState()
    RETURN UO.TradeCount()
END FUNCTION
```

**Spiegazione dei parametri e dell’esecuzione:**

- La funzione completa viene chiamata da Main. Controlli di limiti/ID riducono gli errori ma le chiamate non sono atomiche: la finestra può cambiare. expectedPartner è un serial del personaggio salvato, non una verifica di prezzo/contenuto.
