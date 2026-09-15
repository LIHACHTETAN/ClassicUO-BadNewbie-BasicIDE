# UO.GetScriptName

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: en -->

Reads the display name of one active execution.

## Exact syntax

```text
UO.GetScriptName(ScriptIndex:Any) -> String
```

## Parameters

- `ScriptIndex` — Required zero-based Integer ScriptIndex, obtained from a fresh GetScriptsList result. Negative or absent indices return the documented empty/unknown result. Do not pass an item serial, procedure name or IDE run ID.

## Returns

String: display name, or "" when the index is absent. A valid execution can also have an explicitly empty name.

## Behavior

- The pool includes running and paused executions; completed or cancellation-requested runs are excluded. An active script normally counts itself. Loaded but never-started IDE tabs are not executions.
- Indices are current positions ordered by launch sequence. Starting/stopping scripts can shift positions. Separate calls are not one atomic snapshot; re-read the list before later control actions.
- Closing Basic IDE does not remove active executions. These commands query this client, not other clients or Windows processes.
- GetScriptsList supplies indices; GetScriptsCount supplies a count; GetScriptState supplies a three-state code. Do not interchange these values or interpret every nonzero result as true.
- ScriptIndex=0 means the first current execution, not necessarily the caller. SetScriptName changes the display name without renaming the file.

### Internal functions: from call to result

Implementation trace below uses actual client method names. The Basic examples include complete callable helpers; these C# method names are not additional script commands.

#### 1. ExecuteStealthCompatibility

The runtime dispatches the registered UO call and wraps the bridge result as Integer, String or Array.

String: display name, or "" when the index is absent. A valid execution can also have an explicitly empty name.

Project source: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; function `ExecuteStealthCompatibility`.

#### 2. GetScriptName

The bridge delegates to the execution manager belonging to this client.

ScriptIndex=0 means the first current execution, not necessarily the caller. SetScriptName changes the display name without renaming the file.

Project source: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; function `GetScriptName`.

#### 3. GetScriptName

`ElementAt(RunningScripts(), index)?.Name ?? string.Empty`

Indices are current positions ordered by launch sequence. Starting/stopping scripts can shift positions. Separate calls are not one atomic snapshot; re-read the list before later control actions.

Project source: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; function `GetScriptName`.

Closing Basic IDE does not remove active executions. These commands query this client, not other clients or Windows processes.


## Examples

### First call and result

```vb
# First call and result
#
# Reads the display name of one active execution.
#
# String: display name, or "" when the index is absent. A valid execution can also have an
# explicitly empty name.

SUB Main()
    # Run Sub Main. Literal 0 is an index where present; empty parentheses mean no arguments. The
    # text passed to Print is only a demonstration message.
    # ScriptIndex=0 means the first current execution, not necessarily the caller. SetScriptName
    # changes the display name without renaming the file.
    # String: display name, or "" when the index is absent. A valid execution can also have an
    # explicitly empty name.
    # Required zero-based Integer ScriptIndex, obtained from a fresh GetScriptsList result. Negative
    # or absent indices return the documented empty/unknown result. Do not pass an item serial,
    # procedure name or IDE run ID.

    Dim index=0
    Dim name=UO.GetScriptName(index)
    UO.Print(name)
END SUB
```

**Parameter and execution notes:**

- Run Sub Main. Literal 0 is an index where present; empty parentheses mean no arguments. The text passed to Print is only a demonstration message.
- ScriptIndex=0 means the first current execution, not necessarily the caller. SetScriptName changes the display name without renaming the file.
- String: display name, or "" when the index is absent. A valid execution can also have an explicitly empty name.
- Required zero-based Integer ScriptIndex, obtained from a fresh GetScriptsList result. Negative or absent indices return the documented empty/unknown result. Do not pass an item serial, procedure name or IDE run ID.

### Loop or conditional use

```vb
# Loop or conditional use
#
# Reads the display name of one active execution.
#
# String: display name, or "" when the index is absent. A valid execution can also have an
# explicitly empty name.

SUB Main()
    # This separate example combines the result with other calls. Array positions start at zero;
    # check the array length before indexing. Wait(250), where used, is 250 milliseconds.
    # ScriptIndex=0 means the first current execution, not necessarily the caller. SetScriptName
    # changes the display name without renaming the file.
    # String: display name, or "" when the index is absent. A valid execution can also have an
    # explicitly empty name.
    # Required zero-based Integer ScriptIndex, obtained from a fresh GetScriptsList result. Negative
    # or absent indices return the documented empty/unknown result. Do not pass an item serial,
    # procedure name or IDE run ID.

    Dim indices=UO.GetScriptsList()
    For Each index In indices
        Dim name=UO.GetScriptName(index)
        UO.Print(CStr(index) & " = " & name)
    Next
END SUB
```

**Parameter and execution notes:**

- This separate example combines the result with other calls. Array positions start at zero; check the array length before indexing. Wait(250), where used, is 250 milliseconds.
- ScriptIndex=0 means the first current execution, not necessarily the caller. SetScriptName changes the display name without renaming the file.
- String: display name, or "" when the index is absent. A valid execution can also have an explicitly empty name.
- Required zero-based Integer ScriptIndex, obtained from a fresh GetScriptsList result. Negative or absent indices return the documented empty/unknown result. Do not pass an item serial, procedure name or IDE run ID.

### Complete helper function

```vb
# Complete helper function
#
# Reads the display name of one active execution.
#
# String: display name, or "" when the index is absent. A valid execution can also have an
# explicitly empty name.

SUB Main()
    # The full helper is included below Main. Its parameters and return contract are described
    # separately from the API call it uses.
    # DescribeScript checks the state and combines name and path. Calls can race a stop; "missing"
    # is this helper’s fallback, not GetScriptName’s return value.
    # String: display name, or "" when the index is absent. A valid execution can also have an
    # explicitly empty name.
    # Required zero-based Integer ScriptIndex, obtained from a fresh GetScriptsList result. Negative
    # or absent indices return the documented empty/unknown result. Do not pass an item serial,
    # procedure name or IDE run ID.

    UO.Print(DescribeScript(0))
END SUB

Function DescribeScript(index) As String
    If UO.GetScriptState(index)=0 Then
        Return "missing"
    End If
    Return UO.GetScriptName(index) & " | " & UO.GetScriptPath(index)
End Function
```

**Parameter and execution notes:**

- The full helper is included below Main. Its parameters and return contract are described separately from the API call it uses.
- DescribeScript checks the state and combines name and path. Calls can race a stop; "missing" is this helper’s fallback, not GetScriptName’s return value.
- String: display name, or "" when the index is absent. A valid execution can also have an explicitly empty name.
- Required zero-based Integer ScriptIndex, obtained from a fresh GetScriptsList result. Negative or absent indices return the documented empty/unknown result. Do not pass an item serial, procedure name or IDE run ID.
