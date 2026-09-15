# UO.GetScriptsCount

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: it -->

Conta le esecuzioni attive di questo client.

## Sintassi esatta

```text
UO.GetScriptsCount() -> Integer
```

## Parametri

Nessun parametro.

## Restituisce

Integer >= 0: numero di esecuzioni attive, incluse quelle in pausa. Un conteggio, non un Boolean né un indice.

## Comportamento

- Sono incluse esecuzioni attive e in pausa; quelle terminate o con annullamento richiesto sono escluse. Il chiamante normalmente conta anche se stesso. Una scheda solo caricata non è un’esecuzione.
- Gli indici sono posizioni correnti in ordine di avvio. Avvii/arresti possono spostarle. Chiamate separate non formano un’unica istantanea atomica: rileggere prima di controlli successivi.
- Chiudere Basic IDE non elimina le esecuzioni attive. Questi comandi riguardano questo client, non altri client o processi Windows.
- GetScriptsList fornisce indici, GetScriptsCount un conteggio, GetScriptState un codice a tre stati. Non scambiarli e non interpretare ogni valore diverso da zero come true.
- Nessun argomento. Il conteggio non ordina l’elenco e non modifica le esecuzioni.

### Funzioni interne: dalla chiamata al risultato

Seguono i metodi reali del client. Gli esempi Basic contengono funzioni complete; i nomi interni C# non sono comandi di script aggiuntivi.

#### 1. ExecuteStealthCompatibility

Il runtime invoca il comando UO registrato e converte il risultato del ponte in Integer, String o Array.

Integer >= 0: numero di esecuzioni attive, incluse quelle in pausa. Un conteggio, non un Boolean né un indice.

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; funzione `ExecuteStealthCompatibility`.

#### 2. GetScriptsCount

Il ponte usa il gestore delle esecuzioni di questo client.

Nessun argomento. Il conteggio non ordina l’elenco e non modifica le esecuzioni.

Sorgente del progetto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; funzione `GetScriptsCount`.

#### 3. GetScriptsCount

`_running.Count(entry => !entry.Value.Cancellation.IsCancellationRequested)`

Gli indici sono posizioni correnti in ordine di avvio. Avvii/arresti possono spostarle. Chiamate separate non formano un’unica istantanea atomica: rileggere prima di controlli successivi.

Sorgente del progetto: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; funzione `GetScriptsCount`.

Chiudere Basic IDE non elimina le esecuzioni attive. Questi comandi riguardano questo client, non altri client o processi Windows.


## Esempi

### Prima chiamata e risultato

```vb
# Prima chiamata e risultato
#
# Conta le esecuzioni attive di questo client.
#
# Integer >= 0: numero di esecuzioni attive, incluse quelle in pausa. Un conteggio, non un
# Boolean né un indice.

SUB Main()
    # Eseguire Sub Main. Lo 0 passato è un indice; parentesi vuote indicano nessun argomento. I
    # testi Print sono messaggi dimostrativi.
    # Nessun argomento. Il conteggio non ordina l’elenco e non modifica le esecuzioni.
    # Integer >= 0: numero di esecuzioni attive, incluse quelle in pausa. Un conteggio, non un
    # Boolean né un indice.

    Dim count=UO.GetScriptsCount()
    UO.Print(CStr(count))
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

- Eseguire Sub Main. Lo 0 passato è un indice; parentesi vuote indicano nessun argomento. I testi Print sono messaggi dimostrativi.
- Nessun argomento. Il conteggio non ordina l’elenco e non modifica le esecuzioni.
- Integer >= 0: numero di esecuzioni attive, incluse quelle in pausa. Un conteggio, non un Boolean né un indice.

### Uso in un ciclo o condizione

```vb
# Uso in un ciclo o condizione
#
# Conta le esecuzioni attive di questo client.
#
# Integer >= 0: numero di esecuzioni attive, incluse quelle in pausa. Un conteggio, non un
# Boolean né un indice.

SUB Main()
    # Esempio autonomo che combina comandi. Gli indici partono da zero: controllare la lunghezza
    # prima dell’accesso. Wait(250), se presente, attende 250 millisecondi.
    # Nessun argomento. Il conteggio non ordina l’elenco e non modifica le esecuzioni.
    # Integer >= 0: numero di esecuzioni attive, incluse quelle in pausa. Un conteggio, non un
    # Boolean né un indice.

    Dim before=UO.GetScriptsCount()
    Wait(250)
    Dim after=UO.GetScriptsCount()
    UO.Print(CStr(after-before))
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

- Esempio autonomo che combina comandi. Gli indici partono da zero: controllare la lunghezza prima dell’accesso. Wait(250), se presente, attende 250 millisecondi.
- Nessun argomento. Il conteggio non ordina l’elenco e non modifica le esecuzioni.
- Integer >= 0: numero di esecuzioni attive, incluse quelle in pausa. Un conteggio, non un Boolean né un indice.

### Funzione ausiliaria completa

```vb
# Funzione ausiliaria completa
#
# Conta le esecuzioni attive di questo client.
#
# Integer >= 0: numero di esecuzioni attive, incluse quelle in pausa. Un conteggio, non un
# Boolean né un indice.

SUB Main()
    # La funzione completa è sotto Main. Parametri e risultato sono distinti da quelli della
    # chiamata API usata.
    # HasOtherScripts confronta con 1 perché il chiamante occupa normalmente una voce. Solo la
    # funzione ausiliaria restituisce true/false.
    # Integer >= 0: numero di esecuzioni attive, incluse quelle in pausa. Un conteggio, non un
    # Boolean né un indice.

    If HasOtherScripts() Then
        UO.Print("Other executions are active")
    Else
        UO.Print("No other active executions")
    End If
END SUB

Function HasOtherScripts() As Boolean
    Dim count=UO.GetScriptsCount()
    Return count > 1
End Function
```

**Spiegazione dei parametri e dell’esecuzione:**

- La funzione completa è sotto Main. Parametri e risultato sono distinti da quelli della chiamata API usata.
- HasOtherScripts confronta con 1 perché il chiamante occupa normalmente una voce. Solo la funzione ausiliaria restituisce true/false.
- Integer >= 0: numero di esecuzioni attive, incluse quelle in pausa. Un conteggio, non un Boolean né un indice.
