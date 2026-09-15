# UO.StartScript

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: en -->

Loads a Basic source file and requests its public Sub Main entry point.

## Exact syntax

```text
UO.StartScript(ScriptPath:Any) -> Integer
```

## Parameters

- `ScriptPath` — Required String ScriptPath. Relative paths start at this client’s AutoLoad directory; absolute paths are accepted. Put paths containing spaces inside quotes. The file must contain supported Basic and a runnable public Sub Main without required arguments.

## Returns

Integer: active execution count after an accepted launch; 65535 (0xFFFF) = launch failure. This is not a new script index, Boolean or completion result.

## Behavior

- The pool includes running and paused executions; completed or cancellation-requested runs are excluded. An active script normally counts itself. Loaded but never-started IDE tabs are not executions.
- Indices are current positions ordered by launch sequence. Starting/stopping scripts can shift positions. Separate calls are not one atomic snapshot; re-read the list before later control actions.
- Closing Basic IDE does not remove active executions. These commands query this client, not other clients or Windows processes.
- GetScriptsList supplies indices; GetScriptsCount supplies a count; GetScriptState supplies a three-state code. Do not interchange these values or interpret every nonzero result as true.
- Create the example Worker.bas files separately before running the samples. Missing/unreadable paths, invalid Main, disabled Basic or rejected overlapping execution fail. An already-stopping execution can cause a deferred retry; accepted launch does not mean completion. A short script may finish before the returned count is observed.

### Internal functions: from call to result

Implementation trace below uses actual client method names. The Basic examples include complete callable helpers; these C# method names are not additional script commands.

#### 1. ExecuteStealthCompatibility

The runtime dispatches the registered UO call and wraps the bridge result as Integer, String or Array.

Integer: active execution count after an accepted launch; 65535 (0xFFFF) = launch failure. This is not a new script index, Boolean or completion result.

Project source: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; function `ExecuteStealthCompatibility`.

#### 2. StartScript

The bridge delegates to the execution manager belonging to this client.

Create the example Worker.bas files separately before running the samples. Missing/unreadable paths, invalid Main, disabled Basic or rejected overlapping execution fail. An already-stopping execution can cause a deferred retry; accepted launch does not mean completion. A short script may finish before the returned count is observed.

Project source: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; function `StartScript`.

#### 3. StartScript

`Path.GetFullPath -> File.ReadAllText -> DiscoverProcedures -> SelectFileEntryPoint -> RunProcedure -> GetScriptsCount`

Indices are current positions ordered by launch sequence. Starting/stopping scripts can shift positions. Separate calls are not one atomic snapshot; re-read the list before later control actions.

Project source: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; function `StartScript`.

Closing Basic IDE does not remove active executions. These commands query this client, not other clients or Windows processes.


## Examples

### First call and result

```vb
# First call and result
#
# Loads a Basic source file and requests its public Sub Main entry point.
#
# Integer: active execution count after an accepted launch; 65535 (0xFFFF) = launch failure.
# This is not a new script index, Boolean or completion result.

SUB Main()
    # Run Sub Main. Literal 0 is an index where present; empty parentheses mean no arguments. The
    # text passed to Print is only a demonstration message.
    # Create the example Worker.bas files separately before running the samples. Missing/unreadable
    # paths, invalid Main, disabled Basic or rejected overlapping execution fail. An
    # already-stopping execution can cause a deferred retry; accepted launch does not mean
    # completion. A short script may finish before the returned count is observed.
    # Integer: active execution count after an accepted launch; 65535 (0xFFFF) = launch failure.
    # This is not a new script index, Boolean or completion result.
    # Required String ScriptPath. Relative paths start at this client’s AutoLoad directory; absolute
    # paths are accepted. Put paths containing spaces inside quotes. The file must contain supported
    # Basic and a runnable public Sub Main without required arguments.

    Dim count=UO.StartScript("Scripts/Worker.bas")
    If count=65535 Then
        UO.Print("launch failed")
    Else
        UO.Print("Active executions: " & CStr(count))
    End If
END SUB
```

**Parameter and execution notes:**

- Run Sub Main. Literal 0 is an index where present; empty parentheses mean no arguments. The text passed to Print is only a demonstration message.
- Create the example Worker.bas files separately before running the samples. Missing/unreadable paths, invalid Main, disabled Basic or rejected overlapping execution fail. An already-stopping execution can cause a deferred retry; accepted launch does not mean completion. A short script may finish before the returned count is observed.
- Integer: active execution count after an accepted launch; 65535 (0xFFFF) = launch failure. This is not a new script index, Boolean or completion result.
- Required String ScriptPath. Relative paths start at this client’s AutoLoad directory; absolute paths are accepted. Put paths containing spaces inside quotes. The file must contain supported Basic and a runnable public Sub Main without required arguments.

### Loop or conditional use

```vb
# Loop or conditional use
#
# Loads a Basic source file and requests its public Sub Main entry point.
#
# Integer: active execution count after an accepted launch; 65535 (0xFFFF) = launch failure.
# This is not a new script index, Boolean or completion result.

SUB Main()
    # This separate example combines the result with other calls. Array positions start at zero;
    # check the array length before indexing. Wait(250), where used, is 250 milliseconds.
    # Create the example Worker.bas files separately before running the samples. Missing/unreadable
    # paths, invalid Main, disabled Basic or rejected overlapping execution fail. An
    # already-stopping execution can cause a deferred retry; accepted launch does not mean
    # completion. A short script may finish before the returned count is observed.
    # Integer: active execution count after an accepted launch; 65535 (0xFFFF) = launch failure.
    # This is not a new script index, Boolean or completion result.
    # Required String ScriptPath. Relative paths start at this client’s AutoLoad directory; absolute
    # paths are accepted. Put paths containing spaces inside quotes. The file must contain supported
    # Basic and a runnable public Sub Main without required arguments.

    Dim count=UO.StartScript("Scripts/My Worker.bas")
    If count<>65535 Then
        Dim indices=UO.GetScriptsList()
        For Each index In indices
            UO.Print(CStr(index) & ": " & UO.GetScriptPath(index))
        Next
    End If
END SUB
```

**Parameter and execution notes:**

- This separate example combines the result with other calls. Array positions start at zero; check the array length before indexing. Wait(250), where used, is 250 milliseconds.
- Create the example Worker.bas files separately before running the samples. Missing/unreadable paths, invalid Main, disabled Basic or rejected overlapping execution fail. An already-stopping execution can cause a deferred retry; accepted launch does not mean completion. A short script may finish before the returned count is observed.
- Integer: active execution count after an accepted launch; 65535 (0xFFFF) = launch failure. This is not a new script index, Boolean or completion result.
- Required String ScriptPath. Relative paths start at this client’s AutoLoad directory; absolute paths are accepted. Put paths containing spaces inside quotes. The file must contain supported Basic and a runnable public Sub Main without required arguments.

### Complete helper function

```vb
# Complete helper function
#
# Loads a Basic source file and requests its public Sub Main entry point.
#
# Integer: active execution count after an accepted launch; 65535 (0xFFFF) = launch failure.
# This is not a new script index, Boolean or completion result.

SUB Main()
    # The full helper is included below Main. Its parameters and return contract are described
    # separately from the API call it uses.
    # TryStartBasic compares with 65535 and returns true/false. It does not wait for completion and
    # does not convert the count into an index.
    # Integer: active execution count after an accepted launch; 65535 (0xFFFF) = launch failure.
    # This is not a new script index, Boolean or completion result.
    # Required String ScriptPath. Relative paths start at this client’s AutoLoad directory; absolute
    # paths are accepted. Put paths containing spaces inside quotes. The file must contain supported
    # Basic and a runnable public Sub Main without required arguments.

    If TryStartBasic("Scripts/Worker.bas") Then
        UO.Print("launch accepted")
    Else
        UO.Print("check file, Main and execution settings")
    End If
END SUB

Function TryStartBasic(fileName) As Boolean
    Dim count=UO.StartScript(fileName)
    Return count<>65535
End Function
```

**Parameter and execution notes:**

- The full helper is included below Main. Its parameters and return contract are described separately from the API call it uses.
- TryStartBasic compares with 65535 and returns true/false. It does not wait for completion and does not convert the count into an index.
- Integer: active execution count after an accepted launch; 65535 (0xFFFF) = launch failure. This is not a new script index, Boolean or completion result.
- Required String ScriptPath. Relative paths start at this client’s AutoLoad directory; absolute paths are accepted. Put paths containing spaces inside quotes. The file must contain supported Basic and a runnable public Sub Main without required arguments.
