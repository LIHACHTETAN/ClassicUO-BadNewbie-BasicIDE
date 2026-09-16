# Event / AddHandler / RemoveHandler / RaiseEvent

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: it -->

Event dichiara un evento dello script. AddHandler collega una Sub, RemoveHandler la scollega e RaiseEvent chiama i gestori in modo sincrono nell’ordine di iscrizione.

## Sintassi esatta

```text
Event Changed(ByVal value As Integer)
Public Event Adjust(ByRef value As Integer)
Private Event Completed()
AddHandler EventName, AddressOf Handler
AddHandler Module.EventName, callback
RemoveHandler EventName, AddressOf Handler
RaiseEvent EventName(arguments)
```

## Parametri

- `EventName / Public / Private` — Dichiarare un nome semplice a livello di file (modulo implicito) o dentro Module, fuori dalle procedure. Il valore predefinito è Public; Private richiede Module. Dall’esterno iscriversi con Module.EventName. Solo il modulo che dichiara l’evento può eseguire RaiseEvent, anche se Public. Evitare conflitti con procedure o variabili.
- `Handler / callback` — Handler è una Sub univoca indicata con AddressOf o una variabile/fabbrica di callback dello script caricato. Function, nomi sotto forma di stringa, riferimenti estranei e sovraccarichi non sono validi. Numero, tipi e modalità ByVal/ByRef devono corrispondere esattamente. Scrivere ByVal esplicitamente nei gestori: le procedure ordinarie mantengono il precedente valore predefinito ByRef.
- `arguments / ByVal / ByRef` — RaiseEvent richiede tutti gli argomenti posizionali. Optional, ParamArray, valori predefiniti, argomenti evento denominati e Safe Call non sono supportati. Event usa ByVal se omesso: copia il valore scalare o il riferimento, non il contenuto dell’oggetto. Le modifiche ByRef passano ai gestori successivi e alla variabile o all’elemento indicizzato scrivibile del chiamante. Argomenti e indici vengono valutati una volta nell’ordine scritto.

## Restituisce

Event, AddHandler, RemoveHandler e RaiseEvent non restituiscono valori (Unit): né Boolean, né ID, né numero di iscritti. Usare ByRef o lo stato condiviso di Module per ottenere un risultato. Main restituisce String "ready", Integer 8 e String "ABAC:handler failed".

## Comportamento

- Le iscrizioni appartengono a un interprete. Altri script e un nuovo caricamento partono senza iscrizioni. Ulteriori ingressi nello stesso interprete caricato le conservano fino alla rimozione o al rilascio dell’interprete. Chiudere l’IDE mantiene lo script in esecuzione, senza creare un servizio di eventi indipendente.
- AddHandler aggiunge in coda; i duplicati ripetono la stessa Sub. RemoveHandler elimina l’ultima occorrenza; se non esiste, non cambia nulla. Il motore verifica dichiarazione, accesso e firma, valuta gli argomenti e fissa la lista ordinata. Le modifiche alle iscrizioni durante un gestore valgono dal RaiseEvent successivo.
- Un errore interrompe i gestori rimanenti e raggiunge Catch/Finally del chiamante. Le modifiche ByRef precedenti vengono copiate indietro. Pausa e arresto di emergenza valgono nei gestori; Catch non assorbe l’arresto. Nessun nuovo thread. Le chiamate native bloccanti mantengono i propri limiti di annullamento.
- Limiti: 4096 iscrizioni per evento, 16 RaiseEvent annidati e 32 frame di procedure. Cicli e ricorsioni profonde producono un errore intercettabile anziché esaurire lo stack del client. Usare un ciclo per elaborazioni profonde. Gli scalari condivisi vanno nei campi Module; quelli storici a livello di file restano ereditati come copie.
- Gli eventi dichiarati dallo script richiedono ancora RaiseEvent. Le sottoscrizioni automatiche a diario, risorse e connessione usano gli eventi client UO. descritti in Basic.GameEvents. Handles, WithEvents, Custom Event, tipi delegato di eventi ed eventi di classe restano non supportati.

## Esempi

### 1. Iscrivere e rimuovere

```vb
# Feed.Message trasporta text As String ByVal. Feed.Publish, mostrata interamente, attiva l’evento; Record aggiunge a State.log. handler iscrive Record e "ready" viene salvato. RemoveHandler riconosce la stessa Sub anche da un’altra riga AddressOf. "ignored" dopo la rimozione non aggiunge nulla. Main restituisce "ready".
Option Explicit On
Module Feed
    Public Event Message(ByVal text As String)
    Public Sub Publish(ByVal text As String)
        RaiseEvent Message(text)
    End Sub
End Module

Module State
    Public Dim log As String = ""
End Module

Sub Record(ByVal text As String)
    State.log = State.log & text
End Sub

Sub Main()
    Dim handler = AddressOf Record
    AddHandler Feed.Message, handler
    Feed.Publish("ready")
    RemoveHandler Feed.Message, AddressOf Record
    Feed.Publish("ignored")
    Return State.log
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

Feed.Message trasporta text As String ByVal. Feed.Publish, mostrata interamente, attiva l’evento; Record aggiunge a State.log. handler iscrive Record e "ready" viene salvato. RemoveHandler riconosce la stessa Sub anche da un’altra riga AddressOf. "ignored" dopo la rimozione non aggiunge nulla. Main restituisce "ready".

### 2. Modificare un valore in sequenza

```vb
# Adjust ed entrambe le Sub usano total As Integer ByRef. Increment trasforma 3 in 4; DoubleValue riceve 4 e lo porta a 8. RaiseEvent ricopia 8 in Main. Le due iscrizioni vengono rimosse. Integer 8 è una quantità, non True/False; RaiseEvent non restituisce valori.
Option Explicit On
Event Adjust(ByRef total As Integer)

Sub Increment(ByRef total As Integer)
    total += 1
End Sub

Sub DoubleValue(ByRef total As Integer)
    total *= 2
End Sub

Sub Main()
    Dim total As Integer = 3
    AddHandler Adjust, AddressOf Increment
    AddHandler Adjust, AddressOf DoubleValue
    RaiseEvent Adjust(total)
    RemoveHandler Adjust, AddressOf Increment
    RemoveHandler Adjust, AddressOf DoubleValue
    Return total
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

Adjust ed entrambe le Sub usano total As Integer ByRef. Increment trasforma 3 in 4; DoubleValue riceve 4 e lo porta a 8. RaiseEvent ricopia 8 in Main. Le due iscrizioni vengono rimosse. Integer 8 è una quantità, non True/False; RaiseEvent non restituisce valori.

### 3. Gestire un errore e ripartire

```vb
# Ready non ha parametri. First aggiunge A, Failing aggiunge B e genera un errore; Last viene saltata. Catch salva il messaggio, Finally rimuove Failing. Il prossimo evento aggiunge AC. Main restituisce "ABAC:handler failed". Tutti i gestori e State sono inclusi.
Option Explicit On
Event Ready()
Module State
    Public Dim log As String = ""
End Module

Sub First()
    State.log = State.log & "A"
End Sub

Sub Failing()
    State.log = State.log & "B"
    Throw "handler failed"
End Sub

Sub Last()
    State.log = State.log & "C"
End Sub

Sub Main()
    Dim message As String = ""
    AddHandler Ready, AddressOf First
    AddHandler Ready, AddressOf Failing
    AddHandler Ready, AddressOf Last
    Try
        RaiseEvent Ready()
    Catch problem
        message = problem
    Finally
        RemoveHandler Ready, AddressOf Failing
    End Try
    RaiseEvent Ready()
    Return State.log & ":" & message
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

Ready non ha parametri. First aggiunge A, Failing aggiunge B e genera un errore; Last viene saltata. Catch salva il messaggio, Finally rimuove Failing. Il prossimo evento aggiunge AC. Main restituisce "ABAC:handler failed". Tutti i gestori e State sono inclusi.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: eventDeclaration / eventHandler / raiseEvent
Runtime/EventCatalog.cs: Build / TryResolve / HandlerError
Analysis/EventValidator.cs: ValidateHandler / ValidateRaise / ValidateNativeNames
Runtime/Interpreter.Events.cs: VisitEventHandler / VisitRaiseEvent
Runtime/Interpreter.cs: CallSubrutine / ExecuteSubrutine / ByRef copy-back
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/event-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/addhandler-statement
-->
