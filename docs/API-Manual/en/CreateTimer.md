# CreateTimer / script timers

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: en -->

CreateTimer creates a stopped callback timer for this script. Start schedules a Sub on the same execution thread. This project extension is separate from Basic Timer(), which reads elapsed seconds.

## Exact syntax

```text
CreateTimer(milliseconds, handler) -> Object (ScriptTimer)
CreateTimer(milliseconds, handler, repeating) -> Object (ScriptTimer)
timer.Start() -> Unit
timer.Stop() -> Unit
timer.Dispose() -> Unit
timer.Enabled() -> Integer (0/1)
timer.Interval() -> Integer (ms)
timer.SetInterval(milliseconds) -> Unit
Using timer ... End Using
```

## Parameters

- `milliseconds` — Integer milliseconds, 1..2147483647. Strings, fractions, zero and negative intervals are errors. SetInterval uses the same rule. Interval() returns the configured milliseconds, not remaining time.
- `handler` — AddressOf a uniquely declared Sub with exactly zero parameters, or a callback variable/factory from this loaded script. Function, Optional/ParamArray parameters, a name string and a foreign reference are rejected. Shared handler state belongs in Module fields; no closure is captured.
- `repeating` — Optional third argument: True/1 repeats; False/0 fires once. Default True. The named argument is repeating:=. Other numbers and strings are errors. A one-shot timer becomes disabled before invoking its handler.
- `timer / Start / Stop / Dispose / SetInterval` — The returned object owns Start(), Stop(), Dispose(), Enabled(), Interval(), SetInterval(milliseconds). Start on an enabled timer does nothing. Stop permits a later Start. SetInterval restarts an enabled timer’s interval from now; a stopped timer stays stopped. Dispose is idempotent and permanent; Start/SetInterval afterwards fail. Using disposes the captured object on exit.

## Returns

CreateTimer returns Object (ScriptTimer), never an item ID or a running-script index. Start/Stop/Dispose/SetInterval return Unit. Enabled returns Integer 1=True or 0=False; either comparison form works. Interval returns milliseconds, not a Boolean. Example results are String "3:0", "ready:0", "tick failed:0".

## Behavior

- The scheduler checks monotonic elapsed time between script statements and inside Basic Wait/Sleep and Wait Until. With enabled timers, Wait is divided into slices of at most 25 ms. A game API call or another blocking native call must return before a timer can run. Timers have no guaranteed real-time precision and do not create threads.
- Due timers run by deadline, then creation order for ties, at most 64 handlers per checkpoint. The next checkpoint handles remaining due work. Dispatch does not re-enter while a handler is executing, even if it waits. A repeating timer schedules its next interval after completion; missed intervals are skipped instead of accumulating. Pause suspends dispatch; after resume an overdue timer runs once and resumes normal scheduling.
- A handler error disables that timer and reaches the caller’s Catch/Finally. Stop or interval changes inside a handler take effect. Emergency cancellation is not caught as a normal error. Stop/exit/error of the top-level script disposes its timers; another run/reload must create new ones. Closing only the IDE keeps a running script’s timers alive. Maximum 1024 undisposed timers per interpreter; Dispose releases a slot.
- RunThreePulses and GetHandler below are fully shown script helpers, not built-in commands. Internally CreateTimer validates arguments/ownership, stores a stopped handle, Start records the next deadline, Pump calls the Sub, Fire schedules the next deadline after completion, and Release disposes handles when the root call ends. No OS timer or background service continues after the script ends.

## Examples

### 1. Three periodic calls with cleanup

```vb
# Main calls the complete RunThreePulses function. 20 is the interval in milliseconds; the missing third parameter means repeating=True. CountPulse increments shared State.count and stops at three. Wait Until pumps handlers while checking the count, with a 3000 ms timeout. Enabled() is 0 after Stop; the result is "3:0". Using disposes the timer even when the function returns.
Option Explicit On
Module State
    Public Dim count As Integer = 0
    Public Dim pulse
End Module

Sub CountPulse()
    State.count += 1
    If State.count >= 3 Then
        State.pulse.Stop()
    End If
End Sub

Function RunThreePulses() As String
    State.pulse = CreateTimer(20, AddressOf CountPulse)
    Using State.pulse
        State.pulse.Start()
        Wait Until State.count >= 3 Timeout 3000
        Return CStr(State.count) & ":" & CStr(State.pulse.Enabled())
    End Using
End Function

Sub Main()
    Return RunThreePulses()
End Sub
```

**Parameter and execution notes:**

Main calls the complete RunThreePulses function. 20 is the interval in milliseconds; the missing third parameter means repeating=True. CountPulse increments shared State.count and stops at three. Wait Until pumps handlers while checking the count, with a 3000 ms timeout. Enabled() is 0 after Stop; the result is "3:0". Using disposes the timer even when the function returns.

### 2. One-shot callback and named parameters

```vb
# GetHandler returns AddressOf SetReady. CreateTimer receives 5 ms, that callback and repeating=False in named order. SetInterval changes 5 to 10 before Start. SetReady stores "ready" in Module state; the one-shot timer is already disabled. Main waits at most 3000 ms and returns "ready:0". Every helper is included.
Option Explicit On
Module State
    Public Dim message As String = ""
End Module

Sub SetReady()
    State.message = "ready"
End Sub

Function GetHandler()
    Return AddressOf SetReady
End Function

Sub Main()
    Dim callback = GetHandler()
    Dim notice = CreateTimer(repeating:=False, handler:=callback, milliseconds:=5)
    Using notice
        notice.SetInterval(10)
        notice.Start()
        Wait Until State.message = "ready" Timeout 3000
        Return State.message & ":" & CStr(notice.Enabled())
    End Using
End Sub
```

**Parameter and execution notes:**

GetHandler returns AddressOf SetReady. CreateTimer receives 5 ms, that callback and repeating=False in named order. SetInterval changes 5 to 10 before Start. SetReady stores "ready" in Module state; the one-shot timer is already disabled. Main waits at most 3000 ms and returns "ready:0". Every helper is included.

### 3. Catch a timer failure during Wait

```vb
# FailingPulse throws "tick failed". The 5 ms timer runs during Wait(2000), is disabled on error, and interrupts that wait. Catch stores the text and reads Enabled()=0; Finally disposes it. The return "tick failed:0" includes both the error and the logical state. Emergency stop is handled by the runtime, not this Catch.
Option Explicit On
Sub FailingPulse()
    Throw "tick failed"
End Sub

Sub Main()
    Dim pulse = CreateTimer(5, AddressOf FailingPulse)
    Dim problemText As String = ""
    Dim enabledAfterError As Boolean = True
    Try
        pulse.Start()
        Wait(2000)
    Catch problem
        problemText = problem
        enabledAfterError = pulse.Enabled()
    Finally
        pulse.Dispose()
    End Try
    Return problemText & ":" & CStr(enabledAfterError)
End Sub
```

**Parameter and execution notes:**

FailingPulse throws "tick failed". The 5 ms timer runs during Wait(2000), is disabled on error, and interrupts that wait. Catch stores the text and reads Enabled()=0; Finally disposes it. The return "tick failed:0" includes both the error and the logical state. Emergency stop is handled by the runtime, not this Catch.


### Internal functions: from call to result

RunThreePulses and GetHandler below are fully shown script helpers, not built-in commands. Internally CreateTimer validates arguments/ownership, stores a stopped handle, Start records the next deadline, Pump calls the Sub, Fire schedules the next deadline after completion, and Release disposes handles when the root call ends. No OS timer or background service continues after the script ends.

#### 1. CreateTimer

Integer milliseconds, 1..2147483647. Strings, fractions, zero and negative intervals are errors. SetInterval uses the same rule. Interval() returns the configured milliseconds, not remaining time.

AddressOf a uniquely declared Sub with exactly zero parameters, or a callback variable/factory from this loaded script. Function, Optional/ParamArray parameters, a name string and a foreign reference are rejected. Shared handler state belongs in Module fields; no closure is captured.

Optional third argument: True/1 repeats; False/0 fires once. Default True. The named argument is repeating:=. Other numbers and strings are errors. A one-shot timer becomes disabled before invoking its handler.

CreateTimer returns Object (ScriptTimer), never an item ID or a running-script index. Start/Stop/Dispose/SetInterval return Unit. Enabled returns Integer 1=True or 0=False; either comparison form works. Interval returns milliseconds, not a Boolean. Example results are String "3:0", "ready:0", "tick failed:0".

Project source: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Timers.cs`; function `CreateTimer`.

#### 2. Start

The returned object owns Start(), Stop(), Dispose(), Enabled(), Interval(), SetInterval(milliseconds). Start on an enabled timer does nothing. Stop permits a later Start. SetInterval restarts an enabled timer’s interval from now; a stopped timer stays stopped. Dispose is idempotent and permanent; Start/SetInterval afterwards fail. Using disposes the captured object on exit.

`Due = now + interval; enabled = true;`

Project source: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ScriptTimerObject.cs`; function `Start`.

#### 3. WaitWithTimers

The scheduler checks monotonic elapsed time between script statements and inside Basic Wait/Sleep and Wait Until. With enabled timers, Wait is divided into slices of at most 25 ms. A game API call or another blocking native call must return before a timer can run. Timers have no guaranteed real-time precision and do not create threads.

`checkpoint -> Pump -> min(remaining, nextDue, 25 ms) -> Wait`

Project source: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Timers.cs`; function `WaitWithTimers`.

#### 4. Pump

Due timers run by deadline, then creation order for ties, at most 64 handlers per checkpoint. The next checkpoint handles remaining due work. Dispatch does not re-enter while a handler is executing, even if it waits. A repeating timer schedules its next interval after completion; missed intervals are skipped instead of accumulating. Pause suspends dispatch; after resume an overdue timer runs once and resumes normal scheduling.

`snapshot -> deadline / sequence -> checkpoint -> Fire; limit = 64`

Project source: `external/InjectionScript/src/InjectionScript/Runtime/ScriptTimerScheduler.cs`; function `Pump`.

#### 5. Fire

A handler error disables that timer and reaches the caller’s Catch/Finally. Stop or interval changes inside a handler take effect. Emergency cancellation is not caught as a normal error. Stop/exit/error of the top-level script disposes its timers; another run/reload must create new ones. Closing only the IDE keeps a running script’s timers alive. Maximum 1024 undisposed timers per interpreter; Dispose releases a slot.

`callback -> completion -> next Due; error -> disabled -> throw`

Project source: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ScriptTimerObject.cs`; function `Fire`.

#### 6. Dispose

The returned object owns Start(), Stop(), Dispose(), Enabled(), Interval(), SetInterval(milliseconds). Start on an enabled timer does nothing. Stop permits a later Start. SetInterval restarts an enabled timer’s interval from now; a stopped timer stays stopped. Dispose is idempotent and permanent; Start/SetInterval afterwards fail. Using disposes the captured object on exit.

`Release -> scheduler.Remove -> Changed`

Project source: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ScriptTimerObject.cs`; function `Dispose`.

#### 7. Release

A handler error disables that timer and reaches the caller’s Catch/Finally. Stop or interval changes inside a handler take effect. Emergency cancellation is not caught as a normal error. Stop/exit/error of the top-level script disposes its timers; another run/reload must create new ones. Closing only the IDE keeps a running script’s timers alive. Maximum 1024 undisposed timers per interpreter; Dispose releases a slot.

`timer.Release for each handle -> timers.Clear -> no pending deadline`

Project source: `external/InjectionScript/src/InjectionScript/Runtime/ScriptTimerScheduler.cs`; function `Release`.

Main calls the complete RunThreePulses function. 20 is the interval in milliseconds; the missing third parameter means repeating=True. CountPulse increments shared State.count and stops at three. Wait Until pumps handlers while checking the count, with a 3000 ms timeout. Enabled() is 0 after Stop; the result is "3:0". Using disposes the timer even when the function returns.

<!-- implementation references (not callable script procedures):
Runtime/InjectionApi.cs: CreateTimer / Wait
Runtime/Interpreter.Timers.cs: CreateTimer / WaitWithTimers / TimerCheckpoint
Runtime/ScriptTimerScheduler.cs: Pump / Delay / Release
Runtime/ObjectTypes/ScriptTimerObject.cs: Start / Fire / SetInterval / Dispose
Runtime/Interpreter.cs: statement checkpoints / VisitWaitUntilStatement / root-call cleanup
Runtime/RealTimeSource.cs: Stopwatch elapsed time
https://learn.microsoft.com/en-us/dotnet/api/system.diagnostics.stopwatch
https://learn.microsoft.com/en-us/dotnet/api/system.threading.timer (comparison only; this script timer does not use ThreadPool callbacks)
-->
