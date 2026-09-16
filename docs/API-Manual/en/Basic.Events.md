# Event / AddHandler / RemoveHandler / RaiseEvent

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: en -->

Event declares a script notification. AddHandler connects a Sub, RemoveHandler disconnects it, and RaiseEvent calls the current handlers synchronously in subscription order.

## Exact syntax

```text
Event Changed(ByVal value As Integer)
Public Event Adjust(ByRef value As Integer)
Private Event Completed()
AddHandler EventName, AddressOf Handler
AddHandler Module.EventName, callback
RemoveHandler EventName, AddressOf Handler
RaiseEvent EventName(arguments)
```

## Parameters

- `EventName / Public / Private` — Declare a simple event name at file level (the script’s implicit module) or inside Module, outside procedures. Public is the default. Private requires Module. Outside a module use Module.EventName to subscribe. Only the declaring module may RaiseEvent, including for a Public event. Event names must not conflict with procedures or variables.
- `Handler / callback` — Handler is a uniquely declared Sub, passed through AddressOf or a callback variable/factory from this loaded script. Functions, strings containing names, foreign handles and overload groups are rejected. The handler must have exactly the same number, types and ByVal/ByRef modes as the event. Write ByVal explicitly in handlers; ordinary legacy procedure parameters default to ByRef.
- `arguments / ByVal / ByRef` — RaiseEvent requires all positional arguments. Optional, ParamArray, defaults, named event arguments and Safe Call are unsupported. Event parameters default to ByVal. ByVal copies a scalar or object reference, not the object’s contents. ByRef changes reach later handlers and are copied to the caller’s writable variable or indexed element; argument/index expressions are evaluated once in written order.

## Returns

Event declarations and AddHandler/RemoveHandler/RaiseEvent produce no value (Unit): they return neither Boolean nor an ID or subscriber count. Use a ByRef parameter or shared Module state to receive data. Main returns String "ready", Integer 8 and String "ABAC:handler failed" in the three examples.

## Behavior

- Each interpreter keeps its own subscriptions. Other scripts and a reloaded script start without them. They remain for subsequent entry calls in the same loaded interpreter until removed or that interpreter is released. Closing the IDE keeps a running script and its subscriptions alive; it does not create an independent background event service.
- AddHandler appends; duplicate subscriptions call the same Sub repeatedly. RemoveHandler removes the last occurrence of that Sub; an absent matching subscription is a no-op. The runtime checks declaration/access and the handler signature, evaluates raise arguments, then uses an immutable ordered snapshot. Changes during dispatch affect the next raise; the current snapshot is not modified.
- A handler error stops later handlers in that raise and reaches the caller’s Catch/Finally. Earlier ByRef changes still copy back. Pause checkpoints and emergency cancellation apply inside handlers; Catch does not swallow emergency stop. No new thread is created. A blocking native call retains its own cancellation limits.
- Limits: 4096 subscriptions per event, 16 nested RaiseEvent calls, 32 nested script procedure frames. Cycles/deep recursion produce a catchable script error instead of exhausting the client stack. Use a loop for deep processing. Shared scalar handler state belongs in Public/Private Module fields; legacy file-level scalars retain their inherited-copy behavior.
- Script-declared events still require explicit RaiseEvent. Automatic journal, resource and connection subscriptions use the client-owned UO. events documented in Basic.GameEvents. Handles, WithEvents, Custom Event, event delegate types and class events remain unsupported.

## Examples

### 1. Subscribe and unsubscribe

```vb
# Feed.Message carries text As String ByVal. Feed.Publish is the fully shown source procedure that raises it. Record appends text to shared State.log. A callback variable subscribes Record; publishing "ready" stores it. Removing AddressOf Record matches the same Sub even though the reference occurs at another line. The second publication has no subscribers and adds nothing. Main returns "ready".
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

**Parameter and execution notes:**

Feed.Message carries text As String ByVal. Feed.Publish is the fully shown source procedure that raises it. Record appends text to shared State.log. A callback variable subscribes Record; publishing "ready" stores it. Removing AddressOf Record matches the same Sub even though the reference occurs at another line. The second publication has no subscribers and adds nothing. Main returns "ready".

### 2. Pass a mutable value through handlers

```vb
# Adjust and both handlers declare total As Integer ByRef. total starts at 3; Increment changes it to 4, then DoubleValue sees 4 and changes it to 8. RaiseEvent copies 8 back to Main. Removing handlers cleans up both subscriptions. Integer 8 is a quantity, not True/False; RaiseEvent itself returns no value.
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

**Parameter and execution notes:**

Adjust and both handlers declare total As Integer ByRef. total starts at 3; Increment changes it to 4, then DoubleValue sees 4 and changes it to 8. RaiseEvent copies 8 back to Main. Removing handlers cleans up both subscriptions. Integer 8 is a quantity, not True/False; RaiseEvent itself returns no value.

### 3. Handle an error and continue safely

```vb
# Ready has no parameters. First appends A, Failing appends B and throws, so Last is skipped in that raise. Catch stores the message; Finally removes Failing. The next raise calls First and Last, appending AC. Main returns "ABAC:handler failed". All handlers and the shared State module are included in the example.
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

**Parameter and execution notes:**

Ready has no parameters. First appends A, Failing appends B and throws, so Last is skipped in that raise. Catch stores the message; Finally removes Failing. The next raise calls First and Last, appending AC. Main returns "ABAC:handler failed". All handlers and the shared State module are included in the example.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: eventDeclaration / eventHandler / raiseEvent
Runtime/EventCatalog.cs: Build / TryResolve / HandlerError
Analysis/EventValidator.cs: ValidateHandler / ValidateRaise / ValidateNativeNames
Runtime/Interpreter.Events.cs: VisitEventHandler / VisitRaiseEvent
Runtime/Interpreter.cs: CallSubrutine / ExecuteSubrutine / ByRef copy-back
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/event-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/addhandler-statement
-->
