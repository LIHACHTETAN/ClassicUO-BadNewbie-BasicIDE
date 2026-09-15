# UO.GetScriptPath

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: it -->

Legge il percorso del file sorgente di un’esecuzione attiva.

## Sintassi esatta

```text
UO.GetScriptPath(ScriptIndex:Any) -> String
```

## Parametri

- `ScriptIndex` — ScriptIndex obbligatorio: indice intero da zero ricavato da un GetScriptsList recente. Un indice negativo o assente dà il risultato vuoto/sconosciuto documentato. Non passare serial di oggetti, nomi di procedure o ID di esecuzione IDE.

## Restituisce

String: percorso sorgente memorizzato, oppure "" se manca l’indice. Per un avvio da file è normalmente completo; un comando o codice in memoria può non avere un file ordinario.

## Comportamento

- Sono incluse esecuzioni attive e in pausa; quelle terminate o con annullamento richiesto sono escluse. Il chiamante normalmente conta anche se stesso. Una scheda solo caricata non è un’esecuzione.
- Gli indici sono posizioni correnti in ordine di avvio. Avvii/arresti possono spostarle. Chiamate separate non formano un’unica istantanea atomica: rileggere prima di controlli successivi.
- Chiudere Basic IDE non elimina le esecuzioni attive. Questi comandi riguardano questo client, non altri client o processi Windows.
- GetScriptsList fornisce indici, GetScriptsCount un conteggio, GetScriptState un codice a tre stati. Non scambiarli e non interpretare ogni valore diverso da zero come true.
- ScriptIndex=0 seleziona la prima esecuzione corrente. Il getter identifica la sorgente; non apre, salva o avvia il file.

### Funzioni interne: dalla chiamata al risultato

Seguono i metodi reali del client. Gli esempi Basic contengono funzioni complete; i nomi interni C# non sono comandi di script aggiuntivi.

#### 1. ExecuteStealthCompatibility

Il runtime invoca il comando UO registrato e converte il risultato del ponte in Integer, String o Array.

String: percorso sorgente memorizzato, oppure "" se manca l’indice. Per un avvio da file è normalmente completo; un comando o codice in memoria può non avere un file ordinario.

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; funzione `ExecuteStealthCompatibility`.

#### 2. GetScriptPath

Il ponte usa il gestore delle esecuzioni di questo client.

ScriptIndex=0 seleziona la prima esecuzione corrente. Il getter identifica la sorgente; non apre, salva o avvia il file.

Sorgente del progetto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; funzione `GetScriptPath`.

#### 3. GetScriptPath

`ElementAt(RunningScripts(), index)?.FilePath ?? string.Empty`

Gli indici sono posizioni correnti in ordine di avvio. Avvii/arresti possono spostarle. Chiamate separate non formano un’unica istantanea atomica: rileggere prima di controlli successivi.

Sorgente del progetto: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; funzione `GetScriptPath`.

Chiudere Basic IDE non elimina le esecuzioni attive. Questi comandi riguardano questo client, non altri client o processi Windows.


## Esempi

### Prima chiamata e risultato

```vb
# Prima chiamata e risultato
#
# Legge il percorso del file sorgente di un’esecuzione attiva.
#
# String: percorso sorgente memorizzato, oppure "" se manca l’indice. Per un avvio da file è
# normalmente completo; un comando o codice in memoria può non avere un file ordinario.

SUB Main()
    # Eseguire Sub Main. Lo 0 passato è un indice; parentesi vuote indicano nessun argomento. I
    # testi Print sono messaggi dimostrativi.
    # ScriptIndex=0 seleziona la prima esecuzione corrente. Il getter identifica la sorgente; non
    # apre, salva o avvia il file.
    # String: percorso sorgente memorizzato, oppure "" se manca l’indice. Per un avvio da file è
    # normalmente completo; un comando o codice in memoria può non avere un file ordinario.
    # ScriptIndex obbligatorio: indice intero da zero ricavato da un GetScriptsList recente. Un
    # indice negativo o assente dà il risultato vuoto/sconosciuto documentato. Non passare serial di
    # oggetti, nomi di procedure o ID di esecuzione IDE.

    Dim index=0
    Dim path=UO.GetScriptPath(index)
    If path<>"" Then
        UO.Print(path)
    End If
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

- Eseguire Sub Main. Lo 0 passato è un indice; parentesi vuote indicano nessun argomento. I testi Print sono messaggi dimostrativi.
- ScriptIndex=0 seleziona la prima esecuzione corrente. Il getter identifica la sorgente; non apre, salva o avvia il file.
- String: percorso sorgente memorizzato, oppure "" se manca l’indice. Per un avvio da file è normalmente completo; un comando o codice in memoria può non avere un file ordinario.
- ScriptIndex obbligatorio: indice intero da zero ricavato da un GetScriptsList recente. Un indice negativo o assente dà il risultato vuoto/sconosciuto documentato. Non passare serial di oggetti, nomi di procedure o ID di esecuzione IDE.

### Uso in un ciclo o condizione

```vb
# Uso in un ciclo o condizione
#
# Legge il percorso del file sorgente di un’esecuzione attiva.
#
# String: percorso sorgente memorizzato, oppure "" se manca l’indice. Per un avvio da file è
# normalmente completo; un comando o codice in memoria può non avere un file ordinario.

SUB Main()
    # Esempio autonomo che combina comandi. Gli indici partono da zero: controllare la lunghezza
    # prima dell’accesso. Wait(250), se presente, attende 250 millisecondi.
    # ScriptIndex=0 seleziona la prima esecuzione corrente. Il getter identifica la sorgente; non
    # apre, salva o avvia il file.
    # String: percorso sorgente memorizzato, oppure "" se manca l’indice. Per un avvio da file è
    # normalmente completo; un comando o codice in memoria può non avere un file ordinario.
    # ScriptIndex obbligatorio: indice intero da zero ricavato da un GetScriptsList recente. Un
    # indice negativo o assente dà il risultato vuoto/sconosciuto documentato. Non passare serial di
    # oggetti, nomi di procedure o ID di esecuzione IDE.

    Dim indices=UO.GetScriptsList()
    For Each index In indices
        UO.Print(UO.GetScriptName(index) & " -> " & UO.GetScriptPath(index))
    Next
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

- Esempio autonomo che combina comandi. Gli indici partono da zero: controllare la lunghezza prima dell’accesso. Wait(250), se presente, attende 250 millisecondi.
- ScriptIndex=0 seleziona la prima esecuzione corrente. Il getter identifica la sorgente; non apre, salva o avvia il file.
- String: percorso sorgente memorizzato, oppure "" se manca l’indice. Per un avvio da file è normalmente completo; un comando o codice in memoria può non avere un file ordinario.
- ScriptIndex obbligatorio: indice intero da zero ricavato da un GetScriptsList recente. Un indice negativo o assente dà il risultato vuoto/sconosciuto documentato. Non passare serial di oggetti, nomi di procedure o ID di esecuzione IDE.

### Funzione ausiliaria completa

```vb
# Funzione ausiliaria completa
#
# Legge il percorso del file sorgente di un’esecuzione attiva.
#
# String: percorso sorgente memorizzato, oppure "" se manca l’indice. Per un avvio da file è
# normalmente completo; un comando o codice in memoria può non avere un file ordinario.

SUB Main()
    # La funzione completa è sotto Main. Parametri e risultato sono distinti da quelli della
    # chiamata API usata.
    # ReadScriptPath usa fallback solo per un percorso vuoto. Non è una nuova variante di
    # GetScriptPath.
    # String: percorso sorgente memorizzato, oppure "" se manca l’indice. Per un avvio da file è
    # normalmente completo; un comando o codice in memoria può non avere un file ordinario.
    # ScriptIndex obbligatorio: indice intero da zero ricavato da un GetScriptsList recente. Un
    # indice negativo o assente dà il risultato vuoto/sconosciuto documentato. Non passare serial di
    # oggetti, nomi di procedure o ID di esecuzione IDE.

    UO.Print(ReadScriptPath(0, "path unavailable"))
END SUB

Function ReadScriptPath(index, fallback) As String
    Dim path=UO.GetScriptPath(index)
    If path="" Then
        Return fallback
    End If
    Return path
End Function
```

**Spiegazione dei parametri e dell’esecuzione:**

- La funzione completa è sotto Main. Parametri e risultato sono distinti da quelli della chiamata API usata.
- ReadScriptPath usa fallback solo per un percorso vuoto. Non è una nuova variante di GetScriptPath.
- String: percorso sorgente memorizzato, oppure "" se manca l’indice. Per un avvio da file è normalmente completo; un comando o codice in memoria può non avere un file ordinario.
- ScriptIndex obbligatorio: indice intero da zero ricavato da un GetScriptsList recente. Un indice negativo o assente dà il risultato vuoto/sconosciuto documentato. Non passare serial di oggetti, nomi di procedure o ID di esecuzione IDE.
