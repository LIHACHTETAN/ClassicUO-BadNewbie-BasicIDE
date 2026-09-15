# UO.GetScriptsList

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: en -->

Returns the current numeric script indices.

## Exact syntax

```text
UO.GetScriptsList() -> Array
```

## Parameters

No parameters.

## Returns

Array of Integer: indices 0..N-1, or an empty array. Elements are numbers, not names or text records.

## Behavior

- The pool includes running and paused executions; completed or cancellation-requested runs are excluded. An active script normally counts itself. Loaded but never-started IDE tabs are not executions.
- Indices are current positions ordered by launch sequence. Starting/stopping scripts can shift positions. Separate calls are not one atomic snapshot; re-read the list before later control actions.
- Closing Basic IDE does not remove active executions. These commands query this client, not other clients or Windows processes.
- GetScriptsList supplies indices; GetScriptsCount supplies a count; GetScriptState supplies a three-state code. Do not interchange these values or interpret every nonzero result as true.
- No arguments. Read names, paths and states with the corresponding getter using each numeric element. The returned array is a separate snapshot; editing it does not control scripts.

### Internal functions: from call to result

Implementation trace below uses actual client method names. The Basic examples include complete callable helpers; these C# method names are not additional script commands.

#### 1. ExecuteStealthCompatibility

The runtime dispatches the registered UO call and wraps the bridge result as Integer, String or Array.

Array of Integer: indices 0..N-1, or an empty array. Elements are numbers, not names or text records.

Project source: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; function `ExecuteStealthCompatibility`.

#### 2. GetScriptsList

The bridge delegates to the execution manager belonging to this client.

No arguments. Read names, paths and states with the corresponding getter using each numeric element. The returned array is a separate snapshot; editing it does not control scripts.

Project source: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; function `GetScriptsList`.

#### 3. GetScriptsList

`Enumerable.Range(0, GetScriptsCount()).ToArray()`

Indices are current positions ordered by launch sequence. Starting/stopping scripts can shift positions. Separate calls are not one atomic snapshot; re-read the list before later control actions.

Project source: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; function `GetScriptsList`.

Closing Basic IDE does not remove active executions. These commands query this client, not other clients or Windows processes.


## Examples

### First call and result

```vb
# First call and result
#
# Returns the current numeric script indices.
#
# Array of Integer: indices 0..N-1, or an empty array. Elements are numbers, not names or text
# records.

SUB Main()
    # Run Sub Main. Literal 0 is an index where present; empty parentheses mean no arguments. The
    # text passed to Print is only a demonstration message.
    # No arguments. Read names, paths and states with the corresponding getter using each numeric
    # element. The returned array is a separate snapshot; editing it does not control scripts.
    # Array of Integer: indices 0..N-1, or an empty array. Elements are numbers, not names or text
    # records.

    Dim indices=UO.GetScriptsList()
    For Each index In indices
        UO.Print(CStr(index) & ": " & UO.GetScriptName(index))
    Next
END SUB
```

**Parameter and execution notes:**

- Run Sub Main. Literal 0 is an index where present; empty parentheses mean no arguments. The text passed to Print is only a demonstration message.
- No arguments. Read names, paths and states with the corresponding getter using each numeric element. The returned array is a separate snapshot; editing it does not control scripts.
- Array of Integer: indices 0..N-1, or an empty array. Elements are numbers, not names or text records.

### Loop or conditional use

```vb
# Loop or conditional use
#
# Returns the current numeric script indices.
#
# Array of Integer: indices 0..N-1, or an empty array. Elements are numbers, not names or text
# records.

SUB Main()
    # This separate example combines the result with other calls. Array positions start at zero;
    # check the array length before indexing. Wait(250), where used, is 250 milliseconds.
    # No arguments. Read names, paths and states with the corresponding getter using each numeric
    # element. The returned array is a separate snapshot; editing it does not control scripts.
    # Array of Integer: indices 0..N-1, or an empty array. Elements are numbers, not names or text
    # records.

    Dim indices=UO.GetScriptsList()
    If GetArrayLength(indices)>0 Then
        Dim firstIndex=indices[0]
        UO.Print(UO.GetScriptPath(firstIndex))
    End If
END SUB
```

**Parameter and execution notes:**

- This separate example combines the result with other calls. Array positions start at zero; check the array length before indexing. Wait(250), where used, is 250 milliseconds.
- No arguments. Read names, paths and states with the corresponding getter using each numeric element. The returned array is a separate snapshot; editing it does not control scripts.
- Array of Integer: indices 0..N-1, or an empty array. Elements are numbers, not names or text records.

### Complete helper function

```vb
# Complete helper function
#
# Returns the current numeric script indices.
#
# Array of Integer: indices 0..N-1, or an empty array. Elements are numbers, not names or text
# records.

SUB Main()
    # The full helper is included below Main. Its parameters and return contract are described
    # separately from the API call it uses.
    # FindNamedScript scans current indices and returns the first exact display-name match, or -1.
    # Names can repeat and indices can later shift.
    # Array of Integer: indices 0..N-1, or an empty array. Elements are numbers, not names or text
    # records.

    Dim index=FindNamedScript("Mining")
    If index>=0 Then
        UO.Print(CStr(index))
    Else
        UO.Print("Name not found")
    End If
END SUB

Function FindNamedScript(wanted) As Integer
    Dim indices=UO.GetScriptsList()
    For Each index In indices
        If UO.GetScriptName(index)=wanted Then
            Return index
        End If
    Next
    Return -1
End Function
```

**Parameter and execution notes:**

- The full helper is included below Main. Its parameters and return contract are described separately from the API call it uses.
- FindNamedScript scans current indices and returns the first exact display-name match, or -1. Names can repeat and indices can later shift.
- Array of Integer: indices 0..N-1, or an empty array. Elements are numbers, not names or text records.
