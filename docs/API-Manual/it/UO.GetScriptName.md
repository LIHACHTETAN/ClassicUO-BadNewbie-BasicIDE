# UO.GetScriptName

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: it -->

Legge il nome visualizzato di un’esecuzione attiva.

## Sintassi esatta

```text
UO.GetScriptName(ScriptIndex:Any) -> String
```

## Parametri

- `ScriptIndex` — ScriptIndex obbligatorio: indice intero da zero ricavato da un GetScriptsList recente. Un indice negativo o assente dà il risultato vuoto/sconosciuto documentato. Non passare serial di oggetti, nomi di procedure o ID di esecuzione IDE.

## Restituisce

String: nome visualizzato, oppure "" se l’indice manca. Anche un’esecuzione esistente può avere un nome esplicitamente vuoto.

## Comportamento

- Sono incluse esecuzioni attive e in pausa; quelle terminate o con annullamento richiesto sono escluse. Il chiamante normalmente conta anche se stesso. Una scheda solo caricata non è un’esecuzione.
- Gli indici sono posizioni correnti in ordine di avvio. Avvii/arresti possono spostarle. Chiamate separate non formano un’unica istantanea atomica: rileggere prima di controlli successivi.
- Chiudere Basic IDE non elimina le esecuzioni attive. Questi comandi riguardano questo client, non altri client o processi Windows.
- GetScriptsList fornisce indici, GetScriptsCount un conteggio, GetScriptState un codice a tre stati. Non scambiarli e non interpretare ogni valore diverso da zero come true.
- ScriptIndex=0 è la prima esecuzione corrente, non necessariamente il chiamante. SetScriptName cambia il nome visualizzato senza rinominare il file.

### Funzioni interne: dalla chiamata al risultato

Seguono i metodi reali del client. Gli esempi Basic contengono funzioni complete; i nomi interni C# non sono comandi di script aggiuntivi.

#### 1. ExecuteStealthCompatibility

Il runtime invoca il comando UO registrato e converte il risultato del ponte in Integer, String o Array.

String: nome visualizzato, oppure "" se l’indice manca. Anche un’esecuzione esistente può avere un nome esplicitamente vuoto.

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; funzione `ExecuteStealthCompatibility`.

#### 2. GetScriptName

Il ponte usa il gestore delle esecuzioni di questo client.

ScriptIndex=0 è la prima esecuzione corrente, non necessariamente il chiamante. SetScriptName cambia il nome visualizzato senza rinominare il file.

Sorgente del progetto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; funzione `GetScriptName`.

#### 3. GetScriptName

`ElementAt(RunningScripts(), index)?.Name ?? string.Empty`

Gli indici sono posizioni correnti in ordine di avvio. Avvii/arresti possono spostarle. Chiamate separate non formano un’unica istantanea atomica: rileggere prima di controlli successivi.

Sorgente del progetto: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; funzione `GetScriptName`.

Chiudere Basic IDE non elimina le esecuzioni attive. Questi comandi riguardano questo client, non altri client o processi Windows.


## Esempi

### Prima chiamata e risultato

```vb
# Prima chiamata e risultato
#
# Legge il nome visualizzato di un’esecuzione attiva.
#
# String: nome visualizzato, oppure "" se l’indice manca. Anche un’esecuzione esistente può
# avere un nome esplicitamente vuoto.

SUB Main()
    # Eseguire Sub Main. Lo 0 passato è un indice; parentesi vuote indicano nessun argomento. I
    # testi Print sono messaggi dimostrativi.
    # ScriptIndex=0 è la prima esecuzione corrente, non necessariamente il chiamante. SetScriptName
    # cambia il nome visualizzato senza rinominare il file.
    # String: nome visualizzato, oppure "" se l’indice manca. Anche un’esecuzione esistente può
    # avere un nome esplicitamente vuoto.
    # ScriptIndex obbligatorio: indice intero da zero ricavato da un GetScriptsList recente. Un
    # indice negativo o assente dà il risultato vuoto/sconosciuto documentato. Non passare serial di
    # oggetti, nomi di procedure o ID di esecuzione IDE.

    Dim index=0
    Dim name=UO.GetScriptName(index)
    UO.Print(name)
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

- Eseguire Sub Main. Lo 0 passato è un indice; parentesi vuote indicano nessun argomento. I testi Print sono messaggi dimostrativi.
- ScriptIndex=0 è la prima esecuzione corrente, non necessariamente il chiamante. SetScriptName cambia il nome visualizzato senza rinominare il file.
- String: nome visualizzato, oppure "" se l’indice manca. Anche un’esecuzione esistente può avere un nome esplicitamente vuoto.
- ScriptIndex obbligatorio: indice intero da zero ricavato da un GetScriptsList recente. Un indice negativo o assente dà il risultato vuoto/sconosciuto documentato. Non passare serial di oggetti, nomi di procedure o ID di esecuzione IDE.

### Uso in un ciclo o condizione

```vb
# Uso in un ciclo o condizione
#
# Legge il nome visualizzato di un’esecuzione attiva.
#
# String: nome visualizzato, oppure "" se l’indice manca. Anche un’esecuzione esistente può
# avere un nome esplicitamente vuoto.

SUB Main()
    # Esempio autonomo che combina comandi. Gli indici partono da zero: controllare la lunghezza
    # prima dell’accesso. Wait(250), se presente, attende 250 millisecondi.
    # ScriptIndex=0 è la prima esecuzione corrente, non necessariamente il chiamante. SetScriptName
    # cambia il nome visualizzato senza rinominare il file.
    # String: nome visualizzato, oppure "" se l’indice manca. Anche un’esecuzione esistente può
    # avere un nome esplicitamente vuoto.
    # ScriptIndex obbligatorio: indice intero da zero ricavato da un GetScriptsList recente. Un
    # indice negativo o assente dà il risultato vuoto/sconosciuto documentato. Non passare serial di
    # oggetti, nomi di procedure o ID di esecuzione IDE.

    Dim indices=UO.GetScriptsList()
    For Each index In indices
        Dim name=UO.GetScriptName(index)
        UO.Print(CStr(index) & " = " & name)
    Next
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

- Esempio autonomo che combina comandi. Gli indici partono da zero: controllare la lunghezza prima dell’accesso. Wait(250), se presente, attende 250 millisecondi.
- ScriptIndex=0 è la prima esecuzione corrente, non necessariamente il chiamante. SetScriptName cambia il nome visualizzato senza rinominare il file.
- String: nome visualizzato, oppure "" se l’indice manca. Anche un’esecuzione esistente può avere un nome esplicitamente vuoto.
- ScriptIndex obbligatorio: indice intero da zero ricavato da un GetScriptsList recente. Un indice negativo o assente dà il risultato vuoto/sconosciuto documentato. Non passare serial di oggetti, nomi di procedure o ID di esecuzione IDE.

### Funzione ausiliaria completa

```vb
# Funzione ausiliaria completa
#
# Legge il nome visualizzato di un’esecuzione attiva.
#
# String: nome visualizzato, oppure "" se l’indice manca. Anche un’esecuzione esistente può
# avere un nome esplicitamente vuoto.

SUB Main()
    # La funzione completa è sotto Main. Parametri e risultato sono distinti da quelli della
    # chiamata API usata.
    # DescribeScript controlla lo stato e unisce nome e percorso. Può avvenire un arresto fra le
    # chiamate; "missing" appartiene alla funzione, non a GetScriptName.
    # String: nome visualizzato, oppure "" se l’indice manca. Anche un’esecuzione esistente può
    # avere un nome esplicitamente vuoto.
    # ScriptIndex obbligatorio: indice intero da zero ricavato da un GetScriptsList recente. Un
    # indice negativo o assente dà il risultato vuoto/sconosciuto documentato. Non passare serial di
    # oggetti, nomi di procedure o ID di esecuzione IDE.

    UO.Print(DescribeScript(0))
END SUB

Function DescribeScript(index) As String
    If UO.GetScriptState(index)=0 Then
        Return "missing"
    End If
    Return UO.GetScriptName(index) & " | " & UO.GetScriptPath(index)
End Function
```

**Spiegazione dei parametri e dell’esecuzione:**

- La funzione completa è sotto Main. Parametri e risultato sono distinti da quelli della chiamata API usata.
- DescribeScript controlla lo stato e unisce nome e percorso. Può avvenire un arresto fra le chiamate; "missing" appartiene alla funzione, non a GetScriptName.
- String: nome visualizzato, oppure "" se l’indice manca. Anche un’esecuzione esistente può avere un nome esplicitamente vuoto.
- ScriptIndex obbligatorio: indice intero da zero ricavato da un GetScriptsList recente. Un indice negativo o assente dà il risultato vuoto/sconosciuto documentato. Non passare serial di oggetti, nomi di procedure o ID di esecuzione IDE.
