# Async / Await / Delay

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: en -->

Async Function creates a script task. Await suspends that function while other ready work in the same script can proceed. This is cooperative Basic execution, not a new thread or the full VB.NET Task library.

## Exact syntax

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

## Parameters

- `milliseconds` — Delay takes an Integer from 0 to 2147483647 milliseconds. Zero completes immediately. Negative, fractional and String arguments raise a catchable error. Time uses a monotonic clock; the deadline is a minimum, not an exact scheduling guarantee.
- `Async Function / ByVal / Task(Of T)` — Declare As Task for no value or As Task(Of T) for a scalar Basic result or Object/Variant. Arguments require explicit ByVal or ParamArray; Optional and named arguments work. ByRef and Async Sub/Declare are rejected. Create tasks in procedure bodies, not global/default-parameter initializers.
- `task / Await` — Store a task in an untyped variable or As Object. Await accepts a task from this run. Use it as a whole statement, the complete RHS of one scalar declaration/assignment, or Return Await. It is not allowed inside arithmetic, conditions, member/index assignments, Catch or Finally. Await outside an Async Function is an error. Multiple consumers may await the same task; dependency cycles raise an error.
- `IsCompleted / IsFaulted / IsCanceled / Result` — IsCompleted is 1 after success, failure or cancellation. IsFaulted is 1 for failure; IsCanceled is 1 for cancellation. These Integer predicates also compare with True/False. Result() returns the saved value, throws if pending, and rethrows a failure. Completed handles from a previous run cannot be reused.

## Returns

A script call to an Async Function and Delay returns Object (ScriptTask), not its final T. Await and Result() return T; As Task and Delay complete with Unit (no value). If the client launches an Async Function as the entry point, it waits cooperatively and receives the unwrapped result. Numeric data results are not automatically Boolean.

## Behavior

- The function starts immediately and runs to its first incomplete Await. Locals, loop position, With receiver and debugger frame are saved, then restored on resumption. An already-complete task does not suspend. Await evaluates its operand once.
- The owning script thread checks deadlines at safe checkpoints and resumes at most 64 queued continuations per pass. No worker threads are created. A synchronous Wait or long game/native call can delay other tasks; prefer Await Delay in asynchronous helpers. At most 1024 pending or unobserved failed tasks are retained.
- Pause prevents continuations; deadlines still advance. Resume processes overdue work. Stop, error or entry-point return cancels unfinished tasks and releases Using resources and iterators. Emergency cancellation bypasses script Catch/Finally. An unobserved task failure is reported when the entry point returns. Closing IDE alone does not stop a running script.
- This subset has no Task.Run/WhenAll, external .NET awaitables, Async Sub, Await in Catch/Finally, or typed Task local declarations. Do not leave tasks running after Main returns. Async/Await are reserved keywords in this engine.

## Examples

### 1. Two independent delayed values

```vb
# ValueLater receives value and milliseconds by value. The two calls start before either result is read: 22 is ready after 10 ms, 20 after 30 ms. Main waits up to 5000 ms for both, then Result() returns Integer values whose sum is 42. Wait Until throws on timeout.
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

**Parameter and execution notes:**

ValueLater receives value and milliseconds by value. The two calls start before either result is read: 22 is ready after 10 ms, 20 after 30 ms. Main waits up to 5000 ms for both, then Result() returns Integer values whose sum is 42. Wait Until throws on timeout.

### 2. Catch an awaited failure

```vb
# FailLater has no result and throws after a 5 ms delay. ReadFailure receives that error at Await, stores its text and sets the shared cleanup flag in Finally. Main waits up to 5000 ms and returns String "failed:1"; 1 is the True flag. No Await occurs inside Catch/Finally.
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

**Parameter and execution notes:**

FailLater has no result and throws after a 5 ms delay. ReadFailure receives that error at Await, stores its text and sets the shared cleanup flag in Finally. Main waits up to 5000 ms and returns String "failed:1"; 1 is the True flag. No Await occurs inside Catch/Finally.

### 3. Preserve a loop and forward its result

```vb
# IncrementLater(value) waits 5 ms and returns value+1. SumLater awaits each call sequentially for i=1..3, preserving total and i. ForwardResult uses Return Await to forward 9. Main waits for that task and returns Integer 9, a sum rather than a logical result.
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

**Parameter and execution notes:**

IncrementLater(value) waits 5 ms and returns value+1. SumLater awaits each call sequentially for i=1..3, preserving total and i. ForwardResult uses Return Await to forward 9. Main waits for that task and returns Integer 9, a sum rather than a logical result.


### Internal functions: from call to result

The function starts immediately and runs to its first incomplete Await. Locals, loop position, With receiver and debugger frame are saved, then restored on resumption. An already-complete task does not suspend. Await evaluates its operand once.

#### 1. Delay

Delay takes an Integer from 0 to 2147483647 milliseconds. Zero completes immediately. Negative, fractional and String arguments raise a catchable error. Time uses a monotonic clock; the deadline is a minimum, not an exact scheduling guarantee.

due = monotonicNow + milliseconds
return task

Project source: `external/InjectionScript/src/InjectionScript/Runtime/ScriptAsyncScheduler.cs`; function `Delay`.

#### 2. ResolveAwaitTask

Store a task in an untyped variable or As Object. Await accepts a task from this run. Use it as a whole statement, the complete RHS of one scalar declaration/assignment, or Return Await. It is not allowed inside arithmetic, conditions, member/index assignments, Catch or Finally. Await outside an Async Function is an error. Multiple consumers may await the same task; dependency cycles raise an error.

validate owner and dependency chain
evaluate operand once

Project source: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Async.cs`; function `ResolveAwaitTask`.

#### 3. ExecuteSubrutine

The function starts immediately and runs to its first incomplete Await. Locals, loop position, With receiver and debugger frame are saved, then restored on resumption. An already-complete task does not suspend. Await evaluates its operand once.

save locals, With receiver, debugger frame
suspend until task completes
restore saved state

Project source: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.cs`; function `ExecuteSubrutine`.

#### 4. Pump

The owning script thread checks deadlines at safe checkpoints and resumes at most 64 queued continuations per pass. No worker threads are created. A synchronous Wait or long game/native call can delay other tasks; prefer Await Delay in asynchronous helpers. At most 1024 pending or unobserved failed tasks are retained.

if earliest deadline reached: complete delays
resume at most 64 queued continuations
refresh function results

Project source: `external/InjectionScript/src/InjectionScript/Runtime/ScriptAsyncScheduler.cs`; function `Pump`.

#### 5. GetResult

IsCompleted is 1 after success, failure or cancellation. IsFaulted is 1 for failure; IsCanceled is 1 for cancellation. These Integer predicates also compare with True/False. Result() returns the saved value, throws if pending, and rethrows a failure. Completed handles from a previous run cannot be reused.

if pending: error
if failed: rethrow
return saved value

Project source: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ScriptTaskObject.cs`; function `GetResult`.

#### 6. Release

Pause prevents continuations; deadlines still advance. Resume processes overdue work. Stop, error or entry-point return cancels unfinished tasks and releases Using resources and iterators. Emergency cancellation bypasses script Catch/Finally. An unobserved task failure is reported when the entry point returns. Closing IDE alone does not stop a running script.

cancel pending tasks
drain cleanup continuations
release resources
report unobserved failure

Project source: `external/InjectionScript/src/InjectionScript/Runtime/ScriptAsyncScheduler.cs`; function `Release`.

A script call to an Async Function and Delay returns Object (ScriptTask), not its final T. Await and Result() return T; As Task and Delay complete with Unit (no value). If the client launches an Async Function as the entry point, it waits cooperatively and receives the unwrapped result. Numeric data results are not automatically Boolean.

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
