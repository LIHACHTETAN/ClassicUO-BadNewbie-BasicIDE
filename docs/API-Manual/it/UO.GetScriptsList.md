# UO.GetScriptsList

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: it -->

Restituisce gli indici numerici attuali degli script.

## Sintassi esatta

```text
UO.GetScriptsList() -> Array
```

## Parametri

Nessun parametro.

## Restituisce

Array di Integer: indici 0..N-1 oppure array vuoto. Gli elementi sono numeri, non nomi o record di testo.

## Comportamento

- Sono incluse esecuzioni attive e in pausa; quelle terminate o con annullamento richiesto sono escluse. Il chiamante normalmente conta anche se stesso. Una scheda solo caricata non è un’esecuzione.
- Gli indici sono posizioni correnti in ordine di avvio. Avvii/arresti possono spostarle. Chiamate separate non formano un’unica istantanea atomica: rileggere prima di controlli successivi.
- Chiudere Basic IDE non elimina le esecuzioni attive. Questi comandi riguardano questo client, non altri client o processi Windows.
- GetScriptsList fornisce indici, GetScriptsCount un conteggio, GetScriptState un codice a tre stati. Non scambiarli e non interpretare ogni valore diverso da zero come true.
- Nessun argomento. Passare ciascun numero al getter di nome, percorso o stato. Modificare l’array restituito non controlla gli script.

### Funzioni interne: dalla chiamata al risultato

Seguono i metodi reali del client. Gli esempi Basic contengono funzioni complete; i nomi interni C# non sono comandi di script aggiuntivi.

#### 1. ExecuteStealthCompatibility

Il runtime invoca il comando UO registrato e converte il risultato del ponte in Integer, String o Array.

Array di Integer: indici 0..N-1 oppure array vuoto. Gli elementi sono numeri, non nomi o record di testo.

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; funzione `ExecuteStealthCompatibility`.

#### 2. GetScriptsList

Il ponte usa il gestore delle esecuzioni di questo client.

Nessun argomento. Passare ciascun numero al getter di nome, percorso o stato. Modificare l’array restituito non controlla gli script.

Sorgente del progetto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; funzione `GetScriptsList`.

#### 3. GetScriptsList

`Enumerable.Range(0, GetScriptsCount()).ToArray()`

Gli indici sono posizioni correnti in ordine di avvio. Avvii/arresti possono spostarle. Chiamate separate non formano un’unica istantanea atomica: rileggere prima di controlli successivi.

Sorgente del progetto: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; funzione `GetScriptsList`.

Chiudere Basic IDE non elimina le esecuzioni attive. Questi comandi riguardano questo client, non altri client o processi Windows.


## Esempi

### Prima chiamata e risultato

```vb
# Prima chiamata e risultato
#
# Restituisce gli indici numerici attuali degli script.
#
# Array di Integer: indici 0..N-1 oppure array vuoto. Gli elementi sono numeri, non nomi o
# record di testo.

SUB Main()
    # Eseguire Sub Main. Lo 0 passato è un indice; parentesi vuote indicano nessun argomento. I
    # testi Print sono messaggi dimostrativi.
    # Nessun argomento. Passare ciascun numero al getter di nome, percorso o stato. Modificare
    # l’array restituito non controlla gli script.
    # Array di Integer: indici 0..N-1 oppure array vuoto. Gli elementi sono numeri, non nomi o
    # record di testo.

    Dim indices=UO.GetScriptsList()
    For Each index In indices
        UO.Print(CStr(index) & ": " & UO.GetScriptName(index))
    Next
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

- Eseguire Sub Main. Lo 0 passato è un indice; parentesi vuote indicano nessun argomento. I testi Print sono messaggi dimostrativi.
- Nessun argomento. Passare ciascun numero al getter di nome, percorso o stato. Modificare l’array restituito non controlla gli script.
- Array di Integer: indici 0..N-1 oppure array vuoto. Gli elementi sono numeri, non nomi o record di testo.

### Uso in un ciclo o condizione

```vb
# Uso in un ciclo o condizione
#
# Restituisce gli indici numerici attuali degli script.
#
# Array di Integer: indici 0..N-1 oppure array vuoto. Gli elementi sono numeri, non nomi o
# record di testo.

SUB Main()
    # Esempio autonomo che combina comandi. Gli indici partono da zero: controllare la lunghezza
    # prima dell’accesso. Wait(250), se presente, attende 250 millisecondi.
    # Nessun argomento. Passare ciascun numero al getter di nome, percorso o stato. Modificare
    # l’array restituito non controlla gli script.
    # Array di Integer: indici 0..N-1 oppure array vuoto. Gli elementi sono numeri, non nomi o
    # record di testo.

    Dim indices=UO.GetScriptsList()
    If GetArrayLength(indices)>0 Then
        Dim firstIndex=indices[0]
        UO.Print(UO.GetScriptPath(firstIndex))
    End If
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

- Esempio autonomo che combina comandi. Gli indici partono da zero: controllare la lunghezza prima dell’accesso. Wait(250), se presente, attende 250 millisecondi.
- Nessun argomento. Passare ciascun numero al getter di nome, percorso o stato. Modificare l’array restituito non controlla gli script.
- Array di Integer: indici 0..N-1 oppure array vuoto. Gli elementi sono numeri, non nomi o record di testo.

### Funzione ausiliaria completa

```vb
# Funzione ausiliaria completa
#
# Restituisce gli indici numerici attuali degli script.
#
# Array di Integer: indici 0..N-1 oppure array vuoto. Gli elementi sono numeri, non nomi o
# record di testo.

SUB Main()
    # La funzione completa è sotto Main. Parametri e risultato sono distinti da quelli della
    # chiamata API usata.
    # FindNamedScript restituisce il primo indice corrente con nome visualizzato identico, oppure
    # -1. I nomi possono ripetersi e gli indici cambiare.
    # Array di Integer: indici 0..N-1 oppure array vuoto. Gli elementi sono numeri, non nomi o
    # record di testo.

    Dim index=FindNamedScript("Mining")
    If index>=0 Then
        UO.Print(CStr(index))
    Else
        UO.Print("Name not found")
    End If
END SUB

Function FindNamedScript(wanted) As Integer
    Dim indices=UO.GetScriptsList()
    For Each index In indices
        If UO.GetScriptName(index)=wanted Then
            Return index
        End If
    Next
    Return -1
End Function
```

**Spiegazione dei parametri e dell’esecuzione:**

- La funzione completa è sotto Main. Parametri e risultato sono distinti da quelli della chiamata API usata.
- FindNamedScript restituisce il primo indice corrente con nome visualizzato identico, oppure -1. I nomi possono ripetersi e gli indici cambiare.
- Array di Integer: indici 0..N-1 oppure array vuoto. Gli elementi sono numeri, non nomi o record di testo.
