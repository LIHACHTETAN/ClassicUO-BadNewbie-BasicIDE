# UO.GetScriptState

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: en -->

Reads the execution state associated with an index.

## Exact syntax

```text
UO.GetScriptState(ScriptIndex:Any) -> Integer
```

## Parameters

- `ScriptIndex` — Required zero-based Integer ScriptIndex, obtained from a fresh GetScriptsList result. Negative or absent indices return the documented empty/unknown result. Do not pass an item serial, procedure name or IDE run ID.

## Returns

Integer state code: 0 = absent/unknown, 1 = running, 2 = paused. This is not a Boolean: compare explicitly with 1 or 2.

## Behavior

- The pool includes running and paused executions; completed or cancellation-requested runs are excluded. An active script normally counts itself. Loaded but never-started IDE tabs are not executions.
- Indices are current positions ordered by launch sequence. Starting/stopping scripts can shift positions. Separate calls are not one atomic snapshot; re-read the list before later control actions.
- Closing Basic IDE does not remove active executions. These commands query this client, not other clients or Windows processes.
- GetScriptsList supplies indices; GetScriptsCount supplies a count; GetScriptState supplies a three-state code. Do not interchange these values or interpret every nonzero result as true.
- Pause includes a manual/debugger pause and the configured disconnect pause. State 1 is a pool status, not a guarantee that the script is currently consuming CPU or receiving server data.

### Internal functions: from call to result

Implementation trace below uses actual client method names. The Basic examples include complete callable helpers; these C# method names are not additional script commands.

#### 1. ExecuteStealthCompatibility

The runtime dispatches the registered UO call and wraps the bridge result as Integer, String or Array.

Integer state code: 0 = absent/unknown, 1 = running, 2 = paused. This is not a Boolean: compare explicitly with 1 or 2.

Project source: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; function `ExecuteStealthCompatibility`.

#### 2. GetScriptState

The bridge delegates to the execution manager belonging to this client.

Pause includes a manual/debugger pause and the configured disconnect pause. State 1 is a pool status, not a guarantee that the script is currently consuming CPU or receiving server data.

Project source: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; function `GetScriptState`.

#### 3. GetScriptState

`script == null ? 0 : script.IsPaused ? 2 : 1`

Indices are current positions ordered by launch sequence. Starting/stopping scripts can shift positions. Separate calls are not one atomic snapshot; re-read the list before later control actions.

Project source: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; function `GetScriptState`.

Closing Basic IDE does not remove active executions. These commands query this client, not other clients or Windows processes.


## Examples

### First call and result

```vb
# First call and result
#
# Reads the execution state associated with an index.
#
# Integer state code: 0 = absent/unknown, 1 = running, 2 = paused. This is not a Boolean:
# compare explicitly with 1 or 2.

SUB Main()
    # Run Sub Main. Literal 0 is an index where present; empty parentheses mean no arguments. The
    # text passed to Print is only a demonstration message.
    # Pause includes a manual/debugger pause and the configured disconnect pause. State 1 is a pool
    # status, not a guarantee that the script is currently consuming CPU or receiving server data.
    # Integer state code: 0 = absent/unknown, 1 = running, 2 = paused. This is not a Boolean:
    # compare explicitly with 1 or 2.
    # Required zero-based Integer ScriptIndex, obtained from a fresh GetScriptsList result. Negative
    # or absent indices return the documented empty/unknown result. Do not pass an item serial,
    # procedure name or IDE run ID.

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

**Parameter and execution notes:**

- Run Sub Main. Literal 0 is an index where present; empty parentheses mean no arguments. The text passed to Print is only a demonstration message.
- Pause includes a manual/debugger pause and the configured disconnect pause. State 1 is a pool status, not a guarantee that the script is currently consuming CPU or receiving server data.
- Integer state code: 0 = absent/unknown, 1 = running, 2 = paused. This is not a Boolean: compare explicitly with 1 or 2.
- Required zero-based Integer ScriptIndex, obtained from a fresh GetScriptsList result. Negative or absent indices return the documented empty/unknown result. Do not pass an item serial, procedure name or IDE run ID.

### Loop or conditional use

```vb
# Loop or conditional use
#
# Reads the execution state associated with an index.
#
# Integer state code: 0 = absent/unknown, 1 = running, 2 = paused. This is not a Boolean:
# compare explicitly with 1 or 2.

SUB Main()
    # This separate example combines the result with other calls. Array positions start at zero;
    # check the array length before indexing. Wait(250), where used, is 250 milliseconds.
    # Pause includes a manual/debugger pause and the configured disconnect pause. State 1 is a pool
    # status, not a guarantee that the script is currently consuming CPU or receiving server data.
    # Integer state code: 0 = absent/unknown, 1 = running, 2 = paused. This is not a Boolean:
    # compare explicitly with 1 or 2.
    # Required zero-based Integer ScriptIndex, obtained from a fresh GetScriptsList result. Negative
    # or absent indices return the documented empty/unknown result. Do not pass an item serial,
    # procedure name or IDE run ID.

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

**Parameter and execution notes:**

- This separate example combines the result with other calls. Array positions start at zero; check the array length before indexing. Wait(250), where used, is 250 milliseconds.
- Pause includes a manual/debugger pause and the configured disconnect pause. State 1 is a pool status, not a guarantee that the script is currently consuming CPU or receiving server data.
- Integer state code: 0 = absent/unknown, 1 = running, 2 = paused. This is not a Boolean: compare explicitly with 1 or 2.
- Required zero-based Integer ScriptIndex, obtained from a fresh GetScriptsList result. Negative or absent indices return the documented empty/unknown result. Do not pass an item serial, procedure name or IDE run ID.

### Complete helper function

```vb
# Complete helper function
#
# Reads the execution state associated with an index.
#
# Integer state code: 0 = absent/unknown, 1 = running, 2 = paused. This is not a Boolean:
# compare explicitly with 1 or 2.

SUB Main()
    # The full helper is included below Main. Its parameters and return contract are described
    # separately from the API call it uses.
    # IsScriptActive maps both 1 and 2 to true and 0 to false. GetScriptState itself continues to
    # return its numeric state code.
    # Integer state code: 0 = absent/unknown, 1 = running, 2 = paused. This is not a Boolean:
    # compare explicitly with 1 or 2.
    # Required zero-based Integer ScriptIndex, obtained from a fresh GetScriptsList result. Negative
    # or absent indices return the documented empty/unknown result. Do not pass an item serial,
    # procedure name or IDE run ID.

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

**Parameter and execution notes:**

- The full helper is included below Main. Its parameters and return contract are described separately from the API call it uses.
- IsScriptActive maps both 1 and 2 to true and 0 to false. GetScriptState itself continues to return its numeric state code.
- Integer state code: 0 = absent/unknown, 1 = running, 2 = paused. This is not a Boolean: compare explicitly with 1 or 2.
- Required zero-based Integer ScriptIndex, obtained from a fresh GetScriptsList result. Negative or absent indices return the documented empty/unknown result. Do not pass an item serial, procedure name or IDE run ID.
