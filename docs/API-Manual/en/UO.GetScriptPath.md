# UO.GetScriptPath

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: en -->

Reads the source-file path of one active execution.

## Exact syntax

```text
UO.GetScriptPath(ScriptIndex:Any) -> String
```

## Parameters

- `ScriptIndex` — Required zero-based Integer ScriptIndex, obtained from a fresh GetScriptsList result. Negative or absent indices return the documented empty/unknown result. Do not pass an item serial, procedure name or IDE run ID.

## Returns

String: stored source-file path, or "" when the index is absent. File launches normally have a full path; a command or in-memory source may have no ordinary source file.

## Behavior

- The pool includes running and paused executions; completed or cancellation-requested runs are excluded. An active script normally counts itself. Loaded but never-started IDE tabs are not executions.
- Indices are current positions ordered by launch sequence. Starting/stopping scripts can shift positions. Separate calls are not one atomic snapshot; re-read the list before later control actions.
- Closing Basic IDE does not remove active executions. These commands query this client, not other clients or Windows processes.
- GetScriptsList supplies indices; GetScriptsCount supplies a count; GetScriptState supplies a three-state code. Do not interchange these values or interpret every nonzero result as true.
- ScriptIndex=0 selects the first current execution. The returned text identifies its source; this getter does not open, save or run it.

### Internal functions: from call to result

Implementation trace below uses actual client method names. The Basic examples include complete callable helpers; these C# method names are not additional script commands.

#### 1. ExecuteStealthCompatibility

The runtime dispatches the registered UO call and wraps the bridge result as Integer, String or Array.

String: stored source-file path, or "" when the index is absent. File launches normally have a full path; a command or in-memory source may have no ordinary source file.

Project source: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; function `ExecuteStealthCompatibility`.

#### 2. GetScriptPath

The bridge delegates to the execution manager belonging to this client.

ScriptIndex=0 selects the first current execution. The returned text identifies its source; this getter does not open, save or run it.

Project source: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; function `GetScriptPath`.

#### 3. GetScriptPath

`ElementAt(RunningScripts(), index)?.FilePath ?? string.Empty`

Indices are current positions ordered by launch sequence. Starting/stopping scripts can shift positions. Separate calls are not one atomic snapshot; re-read the list before later control actions.

Project source: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; function `GetScriptPath`.

Closing Basic IDE does not remove active executions. These commands query this client, not other clients or Windows processes.


## Examples

### First call and result

```vb
# First call and result
#
# Reads the source-file path of one active execution.
#
# String: stored source-file path, or "" when the index is absent. File launches normally have a
# full path; a command or in-memory source may have no ordinary source file.

SUB Main()
    # Run Sub Main. Literal 0 is an index where present; empty parentheses mean no arguments. The
    # text passed to Print is only a demonstration message.
    # ScriptIndex=0 selects the first current execution. The returned text identifies its source;
    # this getter does not open, save or run it.
    # String: stored source-file path, or "" when the index is absent. File launches normally have a
    # full path; a command or in-memory source may have no ordinary source file.
    # Required zero-based Integer ScriptIndex, obtained from a fresh GetScriptsList result. Negative
    # or absent indices return the documented empty/unknown result. Do not pass an item serial,
    # procedure name or IDE run ID.

    Dim index=0
    Dim path=UO.GetScriptPath(index)
    If path<>"" Then
        UO.Print(path)
    End If
END SUB
```

**Parameter and execution notes:**

- Run Sub Main. Literal 0 is an index where present; empty parentheses mean no arguments. The text passed to Print is only a demonstration message.
- ScriptIndex=0 selects the first current execution. The returned text identifies its source; this getter does not open, save or run it.
- String: stored source-file path, or "" when the index is absent. File launches normally have a full path; a command or in-memory source may have no ordinary source file.
- Required zero-based Integer ScriptIndex, obtained from a fresh GetScriptsList result. Negative or absent indices return the documented empty/unknown result. Do not pass an item serial, procedure name or IDE run ID.

### Loop or conditional use

```vb
# Loop or conditional use
#
# Reads the source-file path of one active execution.
#
# String: stored source-file path, or "" when the index is absent. File launches normally have a
# full path; a command or in-memory source may have no ordinary source file.

SUB Main()
    # This separate example combines the result with other calls. Array positions start at zero;
    # check the array length before indexing. Wait(250), where used, is 250 milliseconds.
    # ScriptIndex=0 selects the first current execution. The returned text identifies its source;
    # this getter does not open, save or run it.
    # String: stored source-file path, or "" when the index is absent. File launches normally have a
    # full path; a command or in-memory source may have no ordinary source file.
    # Required zero-based Integer ScriptIndex, obtained from a fresh GetScriptsList result. Negative
    # or absent indices return the documented empty/unknown result. Do not pass an item serial,
    # procedure name or IDE run ID.

    Dim indices=UO.GetScriptsList()
    For Each index In indices
        UO.Print(UO.GetScriptName(index) & " -> " & UO.GetScriptPath(index))
    Next
END SUB
```

**Parameter and execution notes:**

- This separate example combines the result with other calls. Array positions start at zero; check the array length before indexing. Wait(250), where used, is 250 milliseconds.
- ScriptIndex=0 selects the first current execution. The returned text identifies its source; this getter does not open, save or run it.
- String: stored source-file path, or "" when the index is absent. File launches normally have a full path; a command or in-memory source may have no ordinary source file.
- Required zero-based Integer ScriptIndex, obtained from a fresh GetScriptsList result. Negative or absent indices return the documented empty/unknown result. Do not pass an item serial, procedure name or IDE run ID.

### Complete helper function

```vb
# Complete helper function
#
# Reads the source-file path of one active execution.
#
# String: stored source-file path, or "" when the index is absent. File launches normally have a
# full path; a command or in-memory source may have no ordinary source file.

SUB Main()
    # The full helper is included below Main. Its parameters and return contract are described
    # separately from the API call it uses.
    # ReadScriptPath returns its fallback parameter only for an empty path. This is a helper result,
    # not a new overload of GetScriptPath.
    # String: stored source-file path, or "" when the index is absent. File launches normally have a
    # full path; a command or in-memory source may have no ordinary source file.
    # Required zero-based Integer ScriptIndex, obtained from a fresh GetScriptsList result. Negative
    # or absent indices return the documented empty/unknown result. Do not pass an item serial,
    # procedure name or IDE run ID.

    UO.Print(ReadScriptPath(0, "path unavailable"))
END SUB

Function ReadScriptPath(index, fallback) As String
    Dim path=UO.GetScriptPath(index)
    If path="" Then
        Return fallback
    End If
    Return path
End Function
```

**Parameter and execution notes:**

- The full helper is included below Main. Its parameters and return contract are described separately from the API call it uses.
- ReadScriptPath returns its fallback parameter only for an empty path. This is a helper result, not a new overload of GetScriptPath.
- String: stored source-file path, or "" when the index is absent. File launches normally have a full path; a command or in-memory source may have no ordinary source file.
- Required zero-based Integer ScriptIndex, obtained from a fresh GetScriptsList result. Negative or absent indices return the documented empty/unknown result. Do not pass an item serial, procedure name or IDE run ID.
