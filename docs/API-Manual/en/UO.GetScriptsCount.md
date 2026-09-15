# UO.GetScriptsCount

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: en -->

Counts active executions in this client.

## Exact syntax

```text
UO.GetScriptsCount() -> Integer
```

## Parameters

No parameters.

## Returns

Integer >= 0: the number of active executions, including paused ones. A count, not a Boolean or script index.

## Behavior

- The pool includes running and paused executions; completed or cancellation-requested runs are excluded. An active script normally counts itself. Loaded but never-started IDE tabs are not executions.
- Indices are current positions ordered by launch sequence. Starting/stopping scripts can shift positions. Separate calls are not one atomic snapshot; re-read the list before later control actions.
- Closing Basic IDE does not remove active executions. These commands query this client, not other clients or Windows processes.
- GetScriptsList supplies indices; GetScriptsCount supplies a count; GetScriptState supplies a three-state code. Do not interchange these values or interpret every nonzero result as true.
- No arguments. Counting does not sort the pool or change its state.

### Internal functions: from call to result

Implementation trace below uses actual client method names. The Basic examples include complete callable helpers; these C# method names are not additional script commands.

#### 1. ExecuteStealthCompatibility

The runtime dispatches the registered UO call and wraps the bridge result as Integer, String or Array.

Integer >= 0: the number of active executions, including paused ones. A count, not a Boolean or script index.

Project source: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; function `ExecuteStealthCompatibility`.

#### 2. GetScriptsCount

The bridge delegates to the execution manager belonging to this client.

No arguments. Counting does not sort the pool or change its state.

Project source: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; function `GetScriptsCount`.

#### 3. GetScriptsCount

`_running.Count(entry => !entry.Value.Cancellation.IsCancellationRequested)`

Indices are current positions ordered by launch sequence. Starting/stopping scripts can shift positions. Separate calls are not one atomic snapshot; re-read the list before later control actions.

Project source: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; function `GetScriptsCount`.

Closing Basic IDE does not remove active executions. These commands query this client, not other clients or Windows processes.


## Examples

### First call and result

```vb
# First call and result
#
# Counts active executions in this client.
#
# Integer >= 0: the number of active executions, including paused ones. A count, not a Boolean
# or script index.

SUB Main()
    # Run Sub Main. Literal 0 is an index where present; empty parentheses mean no arguments. The
    # text passed to Print is only a demonstration message.
    # No arguments. Counting does not sort the pool or change its state.
    # Integer >= 0: the number of active executions, including paused ones. A count, not a Boolean
    # or script index.

    Dim count=UO.GetScriptsCount()
    UO.Print(CStr(count))
END SUB
```

**Parameter and execution notes:**

- Run Sub Main. Literal 0 is an index where present; empty parentheses mean no arguments. The text passed to Print is only a demonstration message.
- No arguments. Counting does not sort the pool or change its state.
- Integer >= 0: the number of active executions, including paused ones. A count, not a Boolean or script index.

### Loop or conditional use

```vb
# Loop or conditional use
#
# Counts active executions in this client.
#
# Integer >= 0: the number of active executions, including paused ones. A count, not a Boolean
# or script index.

SUB Main()
    # This separate example combines the result with other calls. Array positions start at zero;
    # check the array length before indexing. Wait(250), where used, is 250 milliseconds.
    # No arguments. Counting does not sort the pool or change its state.
    # Integer >= 0: the number of active executions, including paused ones. A count, not a Boolean
    # or script index.

    Dim before=UO.GetScriptsCount()
    Wait(250)
    Dim after=UO.GetScriptsCount()
    UO.Print(CStr(after-before))
END SUB
```

**Parameter and execution notes:**

- This separate example combines the result with other calls. Array positions start at zero; check the array length before indexing. Wait(250), where used, is 250 milliseconds.
- No arguments. Counting does not sort the pool or change its state.
- Integer >= 0: the number of active executions, including paused ones. A count, not a Boolean or script index.

### Complete helper function

```vb
# Complete helper function
#
# Counts active executions in this client.
#
# Integer >= 0: the number of active executions, including paused ones. A count, not a Boolean
# or script index.

SUB Main()
    # The full helper is included below Main. Its parameters and return contract are described
    # separately from the API call it uses.
    # HasOtherScripts compares the count with 1 because the calling script normally occupies one
    # entry; the helper, unlike GetScriptsCount, returns true/false.
    # Integer >= 0: the number of active executions, including paused ones. A count, not a Boolean
    # or script index.

    If HasOtherScripts() Then
        UO.Print("Other executions are active")
    Else
        UO.Print("No other active executions")
    End If
END SUB

Function HasOtherScripts() As Boolean
    Dim count=UO.GetScriptsCount()
    Return count > 1
End Function
```

**Parameter and execution notes:**

- The full helper is included below Main. Its parameters and return contract are described separately from the API call it uses.
- HasOtherScripts compares the count with 1 because the calling script normally occupies one entry; the helper, unlike GetScriptsCount, returns true/false.
- Integer >= 0: the number of active executions, including paused ones. A count, not a Boolean or script index.
