# Async / Await / Delay

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: es -->

Async Function crea una tarea del script. Await suspende esa función para permitir otro trabajo preparado del mismo script. No crea un hilo nuevo ni incluye toda la biblioteca Task de VB.NET.

## Sintaxis exacta

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

## Parámetros

- `milliseconds` — Delay recibe Integer entre 0 y 2147483647 milisegundos. Cero termina inmediatamente; negativos, fracciones y String generan un error capturable. El reloj monótono indica un tiempo mínimo, sin garantizar la hora exacta de ejecución.
- `Async Function / ByVal / Task(Of T)` — As Task no devuelve valor; As Task(Of T) devuelve un tipo escalar Basic u Object/Variant. Los parámetros requieren ByVal explícito o ParamArray; admite Optional y argumentos con nombre. No admite ByRef ni Async Sub/Declare. Cree tareas en el cuerpo de procedimientos, después de inicializar campos globales y valores predeterminados.
- `task / Await` — Guarde tareas sin tipo declarado o As Object. Await acepta una tarea de esta ejecución como instrucción completa, lado derecho completo de una declaración/asignación escalar o Return Await. No admite aritmética, condiciones, asignación a campo/índice, Catch/Finally ni uso fuera de Async Function. Varios consumidores pueden esperar la misma tarea; los ciclos producen error.
- `IsCompleted / IsFaulted / IsCanceled / Result` — IsCompleted vale 1 tras éxito, error o cancelación; IsFaulted tras error; IsCanceled tras cancelación. Estos predicados Integer también comparan con True/False. Result() devuelve el valor guardado, falla si está pendiente y vuelve a lanzar el error de una tarea fallida. Las tareas de ejecuciones anteriores no son válidas.

## Devuelve

Una llamada del script a Async Function y Delay devuelve Object (ScriptTask), no T inmediatamente. Await y Result() devuelven T; As Task y Delay terminan con Unit, sin valor. Si el cliente inicia una Async Function como entrada, espera cooperativamente y recibe el resultado final. Un resultado numérico no es necesariamente Boolean.

## Comportamiento

- La función comienza inmediatamente hasta el primer Await pendiente. Conserva y restaura variables locales, posición del bucle, objeto With y marco del depurador. Una tarea ya terminada no suspende. El operando de Await se evalúa una sola vez.
- El hilo propietario comprueba plazos en puntos seguros y ejecuta hasta 64 continuaciones por pasada. No crea hilos. Un Wait síncrono o llamada larga del juego/nativa puede retrasar otras tareas; prefiera Await Delay. Límite: 1024 tareas pendientes o errores no observados.
- La pausa bloquea continuaciones, pero el tiempo avanza; reanudar procesa las vencidas. Stop, error o retorno de la entrada cancela pendientes y libera recursos Using e iteradores. La cancelación de emergencia omite Catch/Finally del script. Un error no observado se informa al terminar la entrada. Cerrar IDE no detiene por sí solo un script activo.
- No admite Task.Run/WhenAll, tareas externas .NET, Async Sub, Await en Catch/Finally ni variables locales As Task. No deje tareas pendientes al retornar Main. Async/Await son palabras reservadas.

## Ejemplos

### 1. Dos esperas independientes

```vb
# ValueLater recibe value y milliseconds por valor. Ambas llamadas comienzan antes de leer: 22 tras 10 ms, 20 tras 30 ms. Main espera ambas hasta 5000 ms y suma sus resultados Integer: 42. Wait Until produce error al vencer el plazo.
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

**Explicación de los parámetros y la ejecución:**

ValueLater recibe value y milliseconds por valor. Ambas llamadas comienzan antes de leer: 22 tras 10 ms, 20 tras 30 ms. Main espera ambas hasta 5000 ms y suma sus resultados Integer: 42. Wait Until produce error al vencer el plazo.

### 2. Capturar un error

```vb
# FailLater no devuelve valor y falla tras 5 ms. ReadFailure recibe el error en Await, guarda el texto y activa la bandera compartida en Finally. Main espera hasta 5000 ms y devuelve String "failed:1"; 1 significa True. No hay Await en Catch/Finally.
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

**Explicación de los parámetros y la ejecución:**

FailLater no devuelve valor y falla tras 5 ms. ReadFailure recibe el error en Await, guarda el texto y activa la bandera compartida en Finally. Main espera hasta 5000 ms y devuelve String "failed:1"; 1 significa True. No hay Await en Catch/Finally.

### 3. Bucle y reenvío del resultado

```vb
# IncrementLater(value) espera 5 ms y devuelve value+1. SumLater espera secuencialmente i=1..3, conservando total e i. ForwardResult reenvía 9 mediante Return Await. Main devuelve Integer 9, una suma y no un valor lógico.
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

**Explicación de los parámetros y la ejecución:**

IncrementLater(value) espera 5 ms y devuelve value+1. SumLater espera secuencialmente i=1..3, conservando total e i. ForwardResult reenvía 9 mediante Return Await. Main devuelve Integer 9, una suma y no un valor lógico.


### Funciones internas: de la llamada al resultado

La función comienza inmediatamente hasta el primer Await pendiente. Conserva y restaura variables locales, posición del bucle, objeto With y marco del depurador. Una tarea ya terminada no suspende. El operando de Await se evalúa una sola vez.

#### 1. Delay

Delay recibe Integer entre 0 y 2147483647 milisegundos. Cero termina inmediatamente; negativos, fracciones y String generan un error capturable. El reloj monótono indica un tiempo mínimo, sin garantizar la hora exacta de ejecución.

due = monotonicNow + milliseconds
return task

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/ScriptAsyncScheduler.cs`; función `Delay`.

#### 2. ResolveAwaitTask

Guarde tareas sin tipo declarado o As Object. Await acepta una tarea de esta ejecución como instrucción completa, lado derecho completo de una declaración/asignación escalar o Return Await. No admite aritmética, condiciones, asignación a campo/índice, Catch/Finally ni uso fuera de Async Function. Varios consumidores pueden esperar la misma tarea; los ciclos producen error.

validate owner and dependency chain
evaluate operand once

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Async.cs`; función `ResolveAwaitTask`.

#### 3. ExecuteSubrutine

La función comienza inmediatamente hasta el primer Await pendiente. Conserva y restaura variables locales, posición del bucle, objeto With y marco del depurador. Una tarea ya terminada no suspende. El operando de Await se evalúa una sola vez.

save locals, With receiver, debugger frame
suspend until task completes
restore saved state

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.cs`; función `ExecuteSubrutine`.

#### 4. Pump

El hilo propietario comprueba plazos en puntos seguros y ejecuta hasta 64 continuaciones por pasada. No crea hilos. Un Wait síncrono o llamada larga del juego/nativa puede retrasar otras tareas; prefiera Await Delay. Límite: 1024 tareas pendientes o errores no observados.

if earliest deadline reached: complete delays
resume at most 64 queued continuations
refresh function results

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/ScriptAsyncScheduler.cs`; función `Pump`.

#### 5. GetResult

IsCompleted vale 1 tras éxito, error o cancelación; IsFaulted tras error; IsCanceled tras cancelación. Estos predicados Integer también comparan con True/False. Result() devuelve el valor guardado, falla si está pendiente y vuelve a lanzar el error de una tarea fallida. Las tareas de ejecuciones anteriores no son válidas.

if pending: error
if failed: rethrow
return saved value

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ScriptTaskObject.cs`; función `GetResult`.

#### 6. Release

La pausa bloquea continuaciones, pero el tiempo avanza; reanudar procesa las vencidas. Stop, error o retorno de la entrada cancela pendientes y libera recursos Using e iteradores. La cancelación de emergencia omite Catch/Finally del script. Un error no observado se informa al terminar la entrada. Cerrar IDE no detiene por sí solo un script activo.

cancel pending tasks
drain cleanup continuations
release resources
report unobserved failure

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/ScriptAsyncScheduler.cs`; función `Release`.

Una llamada del script a Async Function y Delay devuelve Object (ScriptTask), no T inmediatamente. Await y Result() devuelven T; As Task y Delay terminan con Unit, sin valor. Si el cliente inicia una Async Function como entrada, espera cooperativamente y recibe el resultado final. Un resultado numérico no es necesariamente Boolean.

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
