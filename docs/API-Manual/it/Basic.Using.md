# Using / End Using

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: it -->

Using chiude una risorsa nativa quando si esce dal blocco. La forma supportata usa una variabile esistente o un’espressione che restituisce una risorsa.

## Sintassi esatta

```text
Dim resource = MemoryStream()
Using resource
    statements
End Using
Using resourceExpression
    statements
End Using
```

## Parametri

- `resourceExpression` — Valutata una volta. Sono validi File(path), MemoryStream() e CreateTimer(...). Liberare il timer lo ferma definitivamente (Basic.Timers); String, numeri, List e Dictionary causano un errore con riga prima del corpo. Dichiarare prima la variabile: dichiarazioni nell’intestazione, As New, elenchi separati da virgole e Dispose utente non sono supportati.
- `statements / End Using` — End Using chiude l’oggetto catturato. La variabile resta visibile ma la risorsa è chiusa. Annidare blocchi per più risorse. Riassegnare la variabile non cambia l’oggetto originale da chiudere.

## Restituisce

L’istruzione non restituisce valori. Return libera prima la risorsa. IsClosed è una funzione dell’esempio che restituisce 1/True o 0/False; Main restituisce stringhe, non indicatori di successo.

## Comportamento

- File(path) crea un contenitore: chiamare Create() per scrivere oppure Open() per leggere nel blocco. Dispose chiama Close(), scarica il buffer e libera l’handle. Length() su MemoryStream chiuso genera errore. Gli esempi usano solo memoria.
- Il compilatore genera una regione protetta; l’interprete conserva l’oggetto nella chiamata corrente. End Using, Return, Exit, Continue e salti verso l’esterno chiudono dall’interno all’esterno. I salti nel corpo sono rifiutati prima dell’avvio.
- Gli errori normali chiudono prima del Catch esterno. Dispose fallito non viene ripetuto; le risorse esterne vengono comunque chiuse. Lo stop di emergenza salta Catch/Finally dello script ma libera le risorse native, senza sostituire l’annullamento con errori di chiusura. La pausa mantiene le risorse fino alla ripresa o stop. Nessun nuovo thread; una chiusura bloccata dal sistema non può essere interrotta forzatamente.
- Inserire Try/Catch dentro Using per gestire un errore mantenendo aperta la risorsa. Un errore non gestito con On Error Resume Next chiude la risorsa e continua dopo tutto il blocco. On Error GoTo non può puntare a un’etichetta dentro Using, perché rientrerebbe in una regione già chiusa.
- Dopo un errore che esce da Using, Resume nel gestore esterno On Error GoTo ripete l’intero blocco dall’intestazione e rivaluta la risorsa. Resume Next continua subito dopo End Using. Una variabile riferita a un oggetto chiuso non lo riapre: per riprovare usare un’espressione che crea una nuova risorsa. Le azioni già eseguite possono ripetersi.

## Esempi

### 1. Chiudere un flusso in memoria

```vb
# stream è la risorsa; size legge Length()=0 mentre è aperta. IsClosed intercetta poi l’errore e restituisce True=1; Main restituisce "0:1". ByVal copia il riferimento. La funzione didattica considera ogni errore Length come chiusura solo per questi flussi.
Option Explicit On
Function IsClosed(ByVal stream) As Boolean
    Try
        Dim size = stream.Length()
        Return False
    Catch closed
        Return True
    End Try
End Function

Sub Main()
    Dim stream = MemoryStream()
    Dim size = -1
    Using stream
        size = stream.Length()
    End Using
    Return CStr(size) & ":" & CStr(IsClosed(stream))
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

stream è la risorsa; size legge Length()=0 mentre è aperta. IsClosed intercetta poi l’errore e restituisce True=1; Main restituisce "0:1". ByVal copia il riferimento. La funzione didattica considera ogni errore Length come chiusura solo per questi flussi.

### 2. Ritornare da una funzione

```vb
# ReadLength(stream) calcola Integer 0. Return chiude il flusso prima che Main riceva size. Il successivo Length fallisce: closed=True, risultato "0:1". Non passare una risorsa che il chiamante vuole tenere aperta.
Option Explicit On
Function ReadLength(ByVal stream) As Integer
    Using stream
        Return stream.Length()
    End Using
End Function

Sub Main()
    Dim stream = MemoryStream()
    Dim size = ReadLength(stream)
    Dim closed = False
    Try
        Dim after = stream.Length()
    Catch problem
        closed = True
    End Try
    Return CStr(size) & ":" & CStr(closed)
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

ReadLength(stream) calcola Integer 0. Return chiude il flusso prima che Main riceva size. Il successivo Length fallisce: closed=True, risultato "0:1". Non passare una risorsa che il chiamante vuole tenere aperta.

### 3. Pulizia annidata dopo un errore

```vb
# outer e inner sono distinti. Throw "demo" chiude prima inner, poi outer. Catch conserva il testo; IsClosed restituisce 1 per ciascuno. Main restituisce "demo:2". Due conta gli oggetti chiusi, non è Boolean.
Option Explicit On
Function IsClosed(ByVal stream) As Boolean
    Try
        Dim size = stream.Length()
        Return False
    Catch closed
        Return True
    End Try
End Function

Sub Main()
    Dim outer = MemoryStream()
    Dim inner = MemoryStream()
    Dim message = ""
    Try
        Using outer
            Using inner
                Throw "demo"
            End Using
        End Using
    Catch problem
        message = problem
    End Try
    Return message & ":" & CStr(IsClosed(outer) + IsClosed(inner))
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

outer e inner sono distinti. Throw "demo" chiude prima inner, poi outer. Catch conserva il testo; IsClosed restituisce 1 per ciascuno. Main restituisce "demo:2". Due conta gli oggetti chiusi, non è Boolean.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: usingStatement / USING / END_USING
Runtime/Instructions/Generator.cs: Generate(UsingStatementContext)
Runtime/Interpreter.cs: TryExecutionScope.DisposeResource / Transfer / DeferReturn / CallSubrutine
Runtime/ObjectTypes/FileObject.cs: Dispose / Close
Runtime/ObjectTypes/MemoryStreamObject.cs: Dispose
Analysis/TryStructureValidator.cs: Regions
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/using-statement
-->
