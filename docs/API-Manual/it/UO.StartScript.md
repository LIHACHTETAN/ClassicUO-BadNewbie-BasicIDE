# UO.StartScript

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: it -->

Carica un file Basic e richiede la sua Sub Main pubblica.

## Sintassi esatta

```text
UO.StartScript(ScriptPath:Any) -> Integer
```

## Parametri

- `ScriptPath` — ScriptPath obbligatorio: String. I percorsi relativi partono dalla cartella AutoLoad di questo client; quelli assoluti sono accettati. Racchiudere fra virgolette i percorsi con spazi. Il file deve contenere Basic supportato e una Sub Main pubblica senza argomenti obbligatori.

## Restituisce

Integer: conteggio delle esecuzioni attive dopo l’avvio accettato; 65535 (0xFFFF) = errore di avvio. Non è il nuovo indice, un Boolean o il risultato del completamento.

## Comportamento

- Sono incluse esecuzioni attive e in pausa; quelle terminate o con annullamento richiesto sono escluse. Il chiamante normalmente conta anche se stesso. Una scheda solo caricata non è un’esecuzione.
- Gli indici sono posizioni correnti in ordine di avvio. Avvii/arresti possono spostarle. Chiamate separate non formano un’unica istantanea atomica: rileggere prima di controlli successivi.
- Chiudere Basic IDE non elimina le esecuzioni attive. Questi comandi riguardano questo client, non altri client o processi Windows.
- GetScriptsList fornisce indici, GetScriptsCount un conteggio, GetScriptState un codice a tre stati. Non scambiarli e non interpretare ogni valore diverso da zero come true.
- Creare separatamente i file Worker.bas indicati prima degli esempi. Percorso invalido/illeggibile, Main non adatta, Basic disabilitato o parallelismo rifiutato causano errore. Un’esecuzione ancora in arresto può provocare un riavvio differito; accettazione non significa completamento. Uno script breve può finire prima della lettura del conteggio.

### Funzioni interne: dalla chiamata al risultato

Seguono i metodi reali del client. Gli esempi Basic contengono funzioni complete; i nomi interni C# non sono comandi di script aggiuntivi.

#### 1. ExecuteStealthCompatibility

Il runtime invoca il comando UO registrato e converte il risultato del ponte in Integer, String o Array.

Integer: conteggio delle esecuzioni attive dopo l’avvio accettato; 65535 (0xFFFF) = errore di avvio. Non è il nuovo indice, un Boolean o il risultato del completamento.

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; funzione `ExecuteStealthCompatibility`.

#### 2. StartScript

Il ponte usa il gestore delle esecuzioni di questo client.

Creare separatamente i file Worker.bas indicati prima degli esempi. Percorso invalido/illeggibile, Main non adatta, Basic disabilitato o parallelismo rifiutato causano errore. Un’esecuzione ancora in arresto può provocare un riavvio differito; accettazione non significa completamento. Uno script breve può finire prima della lettura del conteggio.

Sorgente del progetto: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; funzione `StartScript`.

#### 3. StartScript

`Path.GetFullPath -> File.ReadAllText -> DiscoverProcedures -> SelectFileEntryPoint -> RunProcedure -> GetScriptsCount`

Gli indici sono posizioni correnti in ordine di avvio. Avvii/arresti possono spostarle. Chiamate separate non formano un’unica istantanea atomica: rileggere prima di controlli successivi.

Sorgente del progetto: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; funzione `StartScript`.

Chiudere Basic IDE non elimina le esecuzioni attive. Questi comandi riguardano questo client, non altri client o processi Windows.


## Esempi

### Prima chiamata e risultato

```vb
# Prima chiamata e risultato
#
# Carica un file Basic e richiede la sua Sub Main pubblica.
#
# Integer: conteggio delle esecuzioni attive dopo l’avvio accettato; 65535 (0xFFFF) = errore di
# avvio. Non è il nuovo indice, un Boolean o il risultato del completamento.

SUB Main()
    # Eseguire Sub Main. Lo 0 passato è un indice; parentesi vuote indicano nessun argomento. I
    # testi Print sono messaggi dimostrativi.
    # Creare separatamente i file Worker.bas indicati prima degli esempi. Percorso
    # invalido/illeggibile, Main non adatta, Basic disabilitato o parallelismo rifiutato causano
    # errore. Un’esecuzione ancora in arresto può provocare un riavvio differito; accettazione non
    # significa completamento. Uno script breve può finire prima della lettura del conteggio.
    # Integer: conteggio delle esecuzioni attive dopo l’avvio accettato; 65535 (0xFFFF) = errore di
    # avvio. Non è il nuovo indice, un Boolean o il risultato del completamento.
    # ScriptPath obbligatorio: String. I percorsi relativi partono dalla cartella AutoLoad di questo
    # client; quelli assoluti sono accettati. Racchiudere fra virgolette i percorsi con spazi. Il
    # file deve contenere Basic supportato e una Sub Main pubblica senza argomenti obbligatori.

    Dim count=UO.StartScript("Scripts/Worker.bas")
    If count=65535 Then
        UO.Print("launch failed")
    Else
        UO.Print("Active executions: " & CStr(count))
    End If
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

- Eseguire Sub Main. Lo 0 passato è un indice; parentesi vuote indicano nessun argomento. I testi Print sono messaggi dimostrativi.
- Creare separatamente i file Worker.bas indicati prima degli esempi. Percorso invalido/illeggibile, Main non adatta, Basic disabilitato o parallelismo rifiutato causano errore. Un’esecuzione ancora in arresto può provocare un riavvio differito; accettazione non significa completamento. Uno script breve può finire prima della lettura del conteggio.
- Integer: conteggio delle esecuzioni attive dopo l’avvio accettato; 65535 (0xFFFF) = errore di avvio. Non è il nuovo indice, un Boolean o il risultato del completamento.
- ScriptPath obbligatorio: String. I percorsi relativi partono dalla cartella AutoLoad di questo client; quelli assoluti sono accettati. Racchiudere fra virgolette i percorsi con spazi. Il file deve contenere Basic supportato e una Sub Main pubblica senza argomenti obbligatori.

### Uso in un ciclo o condizione

```vb
# Uso in un ciclo o condizione
#
# Carica un file Basic e richiede la sua Sub Main pubblica.
#
# Integer: conteggio delle esecuzioni attive dopo l’avvio accettato; 65535 (0xFFFF) = errore di
# avvio. Non è il nuovo indice, un Boolean o il risultato del completamento.

SUB Main()
    # Esempio autonomo che combina comandi. Gli indici partono da zero: controllare la lunghezza
    # prima dell’accesso. Wait(250), se presente, attende 250 millisecondi.
    # Creare separatamente i file Worker.bas indicati prima degli esempi. Percorso
    # invalido/illeggibile, Main non adatta, Basic disabilitato o parallelismo rifiutato causano
    # errore. Un’esecuzione ancora in arresto può provocare un riavvio differito; accettazione non
    # significa completamento. Uno script breve può finire prima della lettura del conteggio.
    # Integer: conteggio delle esecuzioni attive dopo l’avvio accettato; 65535 (0xFFFF) = errore di
    # avvio. Non è il nuovo indice, un Boolean o il risultato del completamento.
    # ScriptPath obbligatorio: String. I percorsi relativi partono dalla cartella AutoLoad di questo
    # client; quelli assoluti sono accettati. Racchiudere fra virgolette i percorsi con spazi. Il
    # file deve contenere Basic supportato e una Sub Main pubblica senza argomenti obbligatori.

    Dim count=UO.StartScript("Scripts/My Worker.bas")
    If count<>65535 Then
        Dim indices=UO.GetScriptsList()
        For Each index In indices
            UO.Print(CStr(index) & ": " & UO.GetScriptPath(index))
        Next
    End If
END SUB
```

**Spiegazione dei parametri e dell’esecuzione:**

- Esempio autonomo che combina comandi. Gli indici partono da zero: controllare la lunghezza prima dell’accesso. Wait(250), se presente, attende 250 millisecondi.
- Creare separatamente i file Worker.bas indicati prima degli esempi. Percorso invalido/illeggibile, Main non adatta, Basic disabilitato o parallelismo rifiutato causano errore. Un’esecuzione ancora in arresto può provocare un riavvio differito; accettazione non significa completamento. Uno script breve può finire prima della lettura del conteggio.
- Integer: conteggio delle esecuzioni attive dopo l’avvio accettato; 65535 (0xFFFF) = errore di avvio. Non è il nuovo indice, un Boolean o il risultato del completamento.
- ScriptPath obbligatorio: String. I percorsi relativi partono dalla cartella AutoLoad di questo client; quelli assoluti sono accettati. Racchiudere fra virgolette i percorsi con spazi. Il file deve contenere Basic supportato e una Sub Main pubblica senza argomenti obbligatori.

### Funzione ausiliaria completa

```vb
# Funzione ausiliaria completa
#
# Carica un file Basic e richiede la sua Sub Main pubblica.
#
# Integer: conteggio delle esecuzioni attive dopo l’avvio accettato; 65535 (0xFFFF) = errore di
# avvio. Non è il nuovo indice, un Boolean o il risultato del completamento.

SUB Main()
    # La funzione completa è sotto Main. Parametri e risultato sono distinti da quelli della
    # chiamata API usata.
    # TryStartBasic confronta con 65535 e restituisce true/false. Non attende il completamento né
    # converte il conteggio in indice.
    # Integer: conteggio delle esecuzioni attive dopo l’avvio accettato; 65535 (0xFFFF) = errore di
    # avvio. Non è il nuovo indice, un Boolean o il risultato del completamento.
    # ScriptPath obbligatorio: String. I percorsi relativi partono dalla cartella AutoLoad di questo
    # client; quelli assoluti sono accettati. Racchiudere fra virgolette i percorsi con spazi. Il
    # file deve contenere Basic supportato e una Sub Main pubblica senza argomenti obbligatori.

    If TryStartBasic("Scripts/Worker.bas") Then
        UO.Print("launch accepted")
    Else
        UO.Print("check file, Main and execution settings")
    End If
END SUB

Function TryStartBasic(fileName) As Boolean
    Dim count=UO.StartScript(fileName)
    Return count<>65535
End Function
```

**Spiegazione dei parametri e dell’esecuzione:**

- La funzione completa è sotto Main. Parametri e risultato sono distinti da quelli della chiamata API usata.
- TryStartBasic confronta con 65535 e restituisce true/false. Non attende il completamento né converte il conteggio in indice.
- Integer: conteggio delle esecuzioni attive dopo l’avvio accettato; 65535 (0xFFFF) = errore di avvio. Non è il nuovo indice, un Boolean o il risultato del completamento.
- ScriptPath obbligatorio: String. I percorsi relativi partono dalla cartella AutoLoad di questo client; quelli assoluti sono accettati. Racchiudere fra virgolette i percorsi con spazi. Il file deve contenere Basic supportato e una Sub Main pubblica senza argomenti obbligatori.
