# UO.GetScriptState

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: it -->

Legge lo stato di esecuzione associato a un indice.

## Sintassi esatta

```text
UO.GetScriptState(ScriptIndex:Any) -> Integer
```

## Parametri

- `ScriptIndex` — ScriptIndex obbligatorio: indice intero da zero ricavato da un GetScriptsList recente. Un indice negativo o assente dà il risultato vuoto/sconosciuto documentato. Non passare serial di oggetti, nomi di procedure o ID di esecuzione IDE.

## Restituisce

Codice Integer: 0 = assente/sconosciuto, 1 = in esecuzione, 2 = in pausa. Non è Boolean: confrontare esplicitamente con 1 o 2.

## Comportamento

- Sono incluse esecuzioni attive e in pausa; quelle terminate o con annullamento richiesto sono escluse. Il chiamante normalmente conta anche se stesso. Una scheda solo caricata non è un’esecuzione.
- Gli indici sono posizioni correnti in ordine di avvio. Avvii/arresti possono spostarle. Chiamate separate non formano un’unica istantanea atomica: rileggere prima di controlli successivi.
- Chiudere Basic IDE non elimina le esecuzioni attive. Questi comandi riguardano questo client, non altri client o processi Windows.
- GetScriptsList fornisce indici, GetScriptsCount un conteggio, GetScriptState un codice a tre stati. Non scambiarli e non interpretare ogni valore diverso da zero come true.
- Comprende la pausa manuale/del debugger e quella configurata alla disconnessione. Lo stato 1 non garantisce uso istantaneo della CPU o ricezione di dati del server.

### Funzioni interne: dalla chiamata al risultato

Seguono i metodi reali del client. Gli esempi Basic contengono funzioni complete; i nomi interni C# non sono comandi di script aggiuntivi.

#### 1. ExecuteStealthCompatibility

Il runtime invoca il comando UO registrato e converte il risultato del ponte in Integer, String o Array.

Codice Integer: 0 = assente/sconosciuto, 1 = in esecuzione, 2 = in pausa. Non è Boolean: confrontare esplicitamente con 1 o 2.

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; funzione `ExecuteStealthCompatibility`.

#### 2. GetScriptState

Il ponte usa il gestore delle esecuzioni di questo client.

Comprende la pausa manuale/del debugger e quella configurata alla disconnessione. Lo stato 1 non garantisce uso istantaneo della CPU o ricezione di dati del server.

Sorgente del progetto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; funzione `GetScriptState`.

#### 3. GetScriptState

`script == null ? 0 : script.IsPaused ? 2 : 1`

Gli indici sono posizioni correnti in ordine di avvio. Avvii/arresti possono spostarle. Chiamate separate non formano un’unica istantanea atomica: rileggere prima di controlli successivi.

Sorgente del progetto: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; funzione `GetScriptState`.

Chiudere Basic IDE non elimina le esecuzioni attive. Questi comandi riguardano questo client, non altri client o processi Windows.


## Esempi

### Prima chiamata e risultato

```vb
# Prima chiamata e risultato
#
# Legge lo stato di esecuzione associato a un indice.
#
# Codice Integer: 0 = assente/sconosciuto, 1 = in esecuzione, 2 = in pausa. Non è Boolean:
# confrontare esplicitamente con 1 o 2.

SUB Main()
    # Eseguire Sub Main. Lo 0 passato è un indice; parentesi vuote indicano nessun argomento. I
    # testi Print sono messaggi dimostrativi.
    # Comprende la pausa manuale/del debugger e quella configurata alla disconnessione. Lo stato 1
    # non garantisce uso istantaneo della CPU o ricezione di dati del server.
    # Codice Integer: 0 = assente/sconosciuto, 1 = in esecuzione, 2 = in pausa. Non è Boolean:
    # confrontare esplicitamente con 1 o 2.
    # ScriptIndex obbligatorio: indice intero da zero ricavato da un GetScriptsList recente. Un
    # indice negativo o assente dà il risultato vuoto/sconosciuto documentato. Non passare serial di
    # oggetti, nomi di procedure o ID di esecuzione IDE.

    Dim state=UO.GetScriptState(0)
    Select Case state
    Case 1
        UO.Print("running")
    Case 2
        UO.Print("paused")
    Case Else
        UO.Print("unknown")
    End Select
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

- Eseguire Sub Main. Lo 0 passato è un indice; parentesi vuote indicano nessun argomento. I testi Print sono messaggi dimostrativi.
- Comprende la pausa manuale/del debugger e quella configurata alla disconnessione. Lo stato 1 non garantisce uso istantaneo della CPU o ricezione di dati del server.
- Codice Integer: 0 = assente/sconosciuto, 1 = in esecuzione, 2 = in pausa. Non è Boolean: confrontare esplicitamente con 1 o 2.
- ScriptIndex obbligatorio: indice intero da zero ricavato da un GetScriptsList recente. Un indice negativo o assente dà il risultato vuoto/sconosciuto documentato. Non passare serial di oggetti, nomi di procedure o ID di esecuzione IDE.

### Uso in un ciclo o condizione

```vb
# Uso in un ciclo o condizione
#
# Legge lo stato di esecuzione associato a un indice.
#
# Codice Integer: 0 = assente/sconosciuto, 1 = in esecuzione, 2 = in pausa. Non è Boolean:
# confrontare esplicitamente con 1 o 2.

SUB Main()
    # Esempio autonomo che combina comandi. Gli indici partono da zero: controllare la lunghezza
    # prima dell’accesso. Wait(250), se presente, attende 250 millisecondi.
    # Comprende la pausa manuale/del debugger e quella configurata alla disconnessione. Lo stato 1
    # non garantisce uso istantaneo della CPU o ricezione di dati del server.
    # Codice Integer: 0 = assente/sconosciuto, 1 = in esecuzione, 2 = in pausa. Non è Boolean:
    # confrontare esplicitamente con 1 o 2.
    # ScriptIndex obbligatorio: indice intero da zero ricavato da un GetScriptsList recente. Un
    # indice negativo o assente dà il risultato vuoto/sconosciuto documentato. Non passare serial di
    # oggetti, nomi di procedure o ID di esecuzione IDE.

    Dim paused=0
    Dim indices=UO.GetScriptsList()
    For Each index In indices
        If UO.GetScriptState(index)=2 Then
            paused+=1
        End If
    Next
    UO.Print(CStr(paused))
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

- Esempio autonomo che combina comandi. Gli indici partono da zero: controllare la lunghezza prima dell’accesso. Wait(250), se presente, attende 250 millisecondi.
- Comprende la pausa manuale/del debugger e quella configurata alla disconnessione. Lo stato 1 non garantisce uso istantaneo della CPU o ricezione di dati del server.
- Codice Integer: 0 = assente/sconosciuto, 1 = in esecuzione, 2 = in pausa. Non è Boolean: confrontare esplicitamente con 1 o 2.
- ScriptIndex obbligatorio: indice intero da zero ricavato da un GetScriptsList recente. Un indice negativo o assente dà il risultato vuoto/sconosciuto documentato. Non passare serial di oggetti, nomi di procedure o ID di esecuzione IDE.

### Funzione ausiliaria completa

```vb
# Funzione ausiliaria completa
#
# Legge lo stato di esecuzione associato a un indice.
#
# Codice Integer: 0 = assente/sconosciuto, 1 = in esecuzione, 2 = in pausa. Non è Boolean:
# confrontare esplicitamente con 1 o 2.

SUB Main()
    # La funzione completa è sotto Main. Parametri e risultato sono distinti da quelli della
    # chiamata API usata.
    # IsScriptActive converte 1 e 2 in true, 0 in false. GetScriptState restituisce sempre il codice
    # numerico.
    # Codice Integer: 0 = assente/sconosciuto, 1 = in esecuzione, 2 = in pausa. Non è Boolean:
    # confrontare esplicitamente con 1 o 2.
    # ScriptIndex obbligatorio: indice intero da zero ricavato da un GetScriptsList recente. Un
    # indice negativo o assente dà il risultato vuoto/sconosciuto documentato. Non passare serial di
    # oggetti, nomi di procedure o ID di esecuzione IDE.

    If IsScriptActive(0)=True Then
        UO.Print("running or paused")
    Else
        UO.Print("not active")
    End If
END SUB

Function IsScriptActive(index) As Boolean
    Dim state=UO.GetScriptState(index)
    Return state=1 OrElse state=2
End Function
```

**Spiegazione dei parametri e dell’esecuzione:**

- La funzione completa è sotto Main. Parametri e risultato sono distinti da quelli della chiamata API usata.
- IsScriptActive converte 1 e 2 in true, 0 in false. GetScriptState restituisce sempre il codice numerico.
- Codice Integer: 0 = assente/sconosciuto, 1 = in esecuzione, 2 = in pausa. Non è Boolean: confrontare esplicitamente con 1 o 2.
- ScriptIndex obbligatorio: indice intero da zero ricavato da un GetScriptsList recente. Un indice negativo o assente dà il risultato vuoto/sconosciuto documentato. Non passare serial di oggetti, nomi di procedure o ID di esecuzione IDE.
