# Async / Await / Delay

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: it -->

Async Function crea un’attività dello script. Await sospende quella funzione per consentire altro lavoro pronto nello stesso script. Non crea un thread nuovo e non include l’intera libreria Task di VB.NET.

## Sintassi esatta

```text
Async Function Work(ByVal value As Integer) As Task(Of Integer)
    Await Delay(100)
    Return value
End Function
Async Function Work() As Task
    Await Delay(100)
End Function
Delay(milliseconds) -> Object (ScriptTask)
Await task
Dim value = Await task
value = Await task
Return Await task
task.IsCompleted() -> Integer (0/1)
task.IsFaulted() -> Integer (0/1)
task.IsCanceled() -> Integer (0/1)
task.Result() -> T / Unit
```

## Parametri

- `milliseconds` — Delay accetta Integer da 0 a 2147483647 millisecondi. Zero termina subito; numeri negativi, frazioni e String generano un errore intercettabile. L’orologio monotono indica l’attesa minima, senza garantire l’istante esatto di esecuzione.
- `Async Function / ByVal / Task(Of T)` — As Task non produce un valore; As Task(Of T) produce uno scalare Basic o Object/Variant. I parametri richiedono ByVal esplicito o ParamArray; Optional e argomenti nominati funzionano. ByRef e Async Sub/Declare sono vietati. Creare attività nel corpo delle procedure, dopo l’inizializzazione globale e dei parametri predefiniti.
- `task / Await` — Memorizzare l’attività senza tipo dichiarato o As Object. Await accetta un’attività dell’esecuzione attuale: istruzione intera, intero lato destro di una dichiarazione/assegnazione scalare o Return Await. Non in aritmetica, condizioni, assegnazioni a campo/indice, Catch/Finally o fuori da Async Function. Più funzioni possono attendere la stessa attività; dipendenze cicliche generano errore.
- `IsCompleted / IsFaulted / IsCanceled / Result` — IsCompleted vale 1 dopo successo, errore o annullamento; IsFaulted dopo errore; IsCanceled dopo annullamento. Questi predicati Integer si confrontano anche con True/False. Result() restituisce il valore salvato, fallisce se incompleto e rilancia l’errore precedente se fallito. Le attività di esecuzioni precedenti non sono valide.

## Restituisce

Una chiamata dello script a Async Function e Delay restituisce Object (ScriptTask), non subito T. Await e Result() restituiscono T; As Task e Delay terminano con Unit, senza valore. Se il client avvia una Async Function come punto d’ingresso, attende cooperativamente il risultato finale. Un dato numerico non è necessariamente Boolean.

## Comportamento

- La funzione parte subito fino al primo Await incompleto. Variabili locali, posizione del ciclo, oggetto With e frame del debugger sono salvati e ripristinati. Un’attività già completa non sospende; l’operando Await viene valutato una volta.
- Il thread dello script verifica le scadenze nei punti sicuri ed esegue fino a 64 continuazioni per passaggio. Nessun nuovo thread. Wait sincrono o una lunga chiamata nativa/del gioco può ritardare altre attività; preferire Await Delay. Limite: 1024 attività incomplete o errori non osservati.
- La pausa blocca le continuazioni ma il tempo avanza; la ripresa elabora quelle scadute. Stop, errore o ritorno del punto d’ingresso annulla le rimanenti e libera risorse Using e iteratori. L’annullamento d’emergenza salta Catch/Finally dello script. Gli errori non osservati sono segnalati alla fine del punto d’ingresso. Chiudere IDE da solo non ferma uno script attivo.
- Non sono disponibili Task.Run/WhenAll, attività .NET esterne, Async Sub, Await in Catch/Finally o dichiarazioni locali As Task. Non lasciare attività necessarie dopo il ritorno di Main. Async/Await sono parole riservate.

## Esempi

### 1. Due attese indipendenti

```vb
# ValueLater riceve value e milliseconds per valore. Entrambe le chiamate iniziano prima della lettura: 22 dopo 10 ms, 20 dopo 30 ms. Main attende entrambe fino a 5000 ms e somma i risultati Integer: 42. Wait Until genera errore alla scadenza.
Option Explicit On
Async Function ValueLater(ByVal value As Integer, ByVal milliseconds As Integer) As Task(Of Integer)
    Await Delay(milliseconds)
    Return value
End Function

Sub Main()
    Dim first = ValueLater(20, 30)
    Dim second = ValueLater(22, 10)
    Wait Until first.IsCompleted() AndAlso second.IsCompleted() Timeout 5000
    Return first.Result() + second.Result()
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

ValueLater riceve value e milliseconds per valore. Entrambe le chiamate iniziano prima della lettura: 22 dopo 10 ms, 20 dopo 30 ms. Main attende entrambe fino a 5000 ms e somma i risultati Integer: 42. Wait Until genera errore alla scadenza.

### 2. Intercettare un errore

```vb
# FailLater non produce un valore e fallisce dopo 5 ms. ReadFailure riceve l’errore su Await, salva il testo e imposta il flag condiviso in Finally. Main attende fino a 5000 ms e restituisce String "failed:1"; 1 significa True. Catch/Finally non contengono Await.
Option Explicit On
Module State
    Public Dim cleaned As Boolean = False
End Module

Async Function FailLater() As Task
    Await Delay(5)
    Throw "failed"
End Function

Async Function ReadFailure() As Task(Of String)
    Dim message As String = ""
    Try
        Await FailLater()
    Catch problem
        message = problem
    Finally
        State.cleaned = True
    End Try
    Return message & ":" & CStr(State.cleaned)
End Function

Sub Main()
    Dim task = ReadFailure()
    Wait Until task.IsCompleted() Timeout 5000
    Return task.Result()
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

FailLater non produce un valore e fallisce dopo 5 ms. ReadFailure riceve l’errore su Await, salva il testo e imposta il flag condiviso in Finally. Main attende fino a 5000 ms e restituisce String "failed:1"; 1 significa True. Catch/Finally non contengono Await.

### 3. Ciclo e inoltro del risultato

```vb
# IncrementLater(value) attende 5 ms e restituisce value+1. SumLater attende in sequenza i=1..3 conservando total e i. ForwardResult inoltra 9 con Return Await. Main restituisce Integer 9, una somma e non un risultato logico.
Option Explicit On
Async Function IncrementLater(ByVal value As Integer) As Task(Of Integer)
    Await Delay(5)
    Return value + 1
End Function

Async Function SumLater() As Task(Of Integer)
    Dim total As Integer = 0
    For Var i = 1 To 3
        Dim nextValue = Await IncrementLater(i)
        total += nextValue
    Next
    Return total
End Function

Async Function ForwardResult() As Task(Of Integer)
    Return Await SumLater()
End Function

Sub Main()
    Dim task = ForwardResult()
    Wait Until task.IsCompleted() Timeout 5000
    Return task.Result()
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

IncrementLater(value) attende 5 ms e restituisce value+1. SumLater attende in sequenza i=1..3 conservando total e i. ForwardResult inoltra 9 con Return Await. Main restituisce Integer 9, una somma e non un risultato logico.


### Funzioni interne: dalla chiamata al risultato

La funzione parte subito fino al primo Await incompleto. Variabili locali, posizione del ciclo, oggetto With e frame del debugger sono salvati e ripristinati. Un’attività già completa non sospende; l’operando Await viene valutato una volta.

#### 1. Delay

Delay accetta Integer da 0 a 2147483647 millisecondi. Zero termina subito; numeri negativi, frazioni e String generano un errore intercettabile. L’orologio monotono indica l’attesa minima, senza garantire l’istante esatto di esecuzione.

due = monotonicNow + milliseconds
return task

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/ScriptAsyncScheduler.cs`; funzione `Delay`.

#### 2. ResolveAwaitTask

Memorizzare l’attività senza tipo dichiarato o As Object. Await accetta un’attività dell’esecuzione attuale: istruzione intera, intero lato destro di una dichiarazione/assegnazione scalare o Return Await. Non in aritmetica, condizioni, assegnazioni a campo/indice, Catch/Finally o fuori da Async Function. Più funzioni possono attendere la stessa attività; dipendenze cicliche generano errore.

validate owner and dependency chain
evaluate operand once

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Async.cs`; funzione `ResolveAwaitTask`.

#### 3. ExecuteSubrutine

La funzione parte subito fino al primo Await incompleto. Variabili locali, posizione del ciclo, oggetto With e frame del debugger sono salvati e ripristinati. Un’attività già completa non sospende; l’operando Await viene valutato una volta.

save locals, With receiver, debugger frame
suspend until task completes
restore saved state

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.cs`; funzione `ExecuteSubrutine`.

#### 4. Pump

Il thread dello script verifica le scadenze nei punti sicuri ed esegue fino a 64 continuazioni per passaggio. Nessun nuovo thread. Wait sincrono o una lunga chiamata nativa/del gioco può ritardare altre attività; preferire Await Delay. Limite: 1024 attività incomplete o errori non osservati.

if earliest deadline reached: complete delays
resume at most 64 queued continuations
refresh function results

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/ScriptAsyncScheduler.cs`; funzione `Pump`.

#### 5. GetResult

IsCompleted vale 1 dopo successo, errore o annullamento; IsFaulted dopo errore; IsCanceled dopo annullamento. Questi predicati Integer si confrontano anche con True/False. Result() restituisce il valore salvato, fallisce se incompleto e rilancia l’errore precedente se fallito. Le attività di esecuzioni precedenti non sono valide.

if pending: error
if failed: rethrow
return saved value

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ScriptTaskObject.cs`; funzione `GetResult`.

#### 6. Release

La pausa blocca le continuazioni ma il tempo avanza; la ripresa elabora quelle scadute. Stop, errore o ritorno del punto d’ingresso annulla le rimanenti e libera risorse Using e iteratori. L’annullamento d’emergenza salta Catch/Finally dello script. Gli errori non osservati sono segnalati alla fine del punto d’ingresso. Chiudere IDE da solo non ferma uno script attivo.

cancel pending tasks
drain cleanup continuations
release resources
report unobserved failure

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/ScriptAsyncScheduler.cs`; funzione `Release`.

Una chiamata dello script a Async Function e Delay restituisce Object (ScriptTask), non subito T. Await e Result() restituiscono T; As Task e Delay terminano con Unit, senza valore. Se il client avvia una Async Function come punto d’ingresso, attende cooperativamente il risultato finale. Un dato numerico non è necessariamente Boolean.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: ASYNC / awaitExpression / taskType
Analysis/AsyncValidator.cs: supported statement forms and signatures
Runtime/Interpreter.cs: ExecuteSubrutine / statement suspension / cleanup
Runtime/Interpreter.Async.cs: ResolveAwaitTask / ResumeAsync / WaitForTask
Runtime/ScriptAsyncScheduler.cs: Delay / Track / Pump / Release
Runtime/ObjectTypes/ScriptTaskObject.cs: GetResult / Complete / Awaiter
Runtime/SemanticScope.cs: SuspendCurrent / Resume
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/modifiers/async
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/operators/await-operator
-->
