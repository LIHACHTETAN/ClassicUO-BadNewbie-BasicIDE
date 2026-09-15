# Using / End Using

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: en -->

Using closes a native resource when control leaves its block. The supported form accepts an existing resource variable or an expression returning a resource.

## Exact syntax

```text
Dim resource = MemoryStream()
Using resource
    statements
End Using
Using resourceExpression
    statements
End Using
```

## Parameters

- `resourceExpression` — Evaluated once on entry. File(path), MemoryStream() and CreateTimer(...) objects are supported. Disposing a script timer stops it permanently; see Basic.Timers. A String, number, List or Dictionary is not disposable and raises a source-located error before the body runs. Declare variables before Using; declarations inside the header, As New, comma-separated resources and user-defined Dispose methods are not supported.
- `statements / End Using` — The body uses the captured object. End Using closes it. The original variable is still in scope, but the resource is closed. For several resources, nest Using blocks. Assigning another object to the variable does not change which original object is closed.

## Returns

Using returns no value and is not a Boolean test. A Return inside its body retains its ordinary meaning, with disposal before leaving the procedure. IsClosed in the examples is a user helper returning 1/True or 0/False; the complete Main results are Strings, not success flags.

## Behavior

- File(path) creates a wrapper: call Create() to write or Open() to read inside the block. Disposal calls Close() and flushes/releases the handle. MemoryStream() creates an empty stream; after disposal Length() raises an error. These examples use memory and do not create files.
- The compiler emits a protected region with native cleanup. The interpreter captures the object once, then records it in the current call. End Using, Return, Exit, Continue and a jump out unwind resources from inner to outer. A jump into the body is rejected before execution.
- Normal errors close resources before an outer Catch. A failing disposer is not retried and outer resources still close. Emergency stop skips script Catch/Finally, but releases native resources; cleanup errors cannot replace the cancellation. Pause retains resources until resume or stop. Disposal does not create threads and cannot forcibly interrupt a blocking operating-system close.
- Place Try/Catch inside Using to recover while the resource remains open. An unhandled body error with On Error Resume Next closes the resource and continues after the whole Using block. On Error GoTo cannot target a label inside any Using body: that would reenter a closed protected region.
- After an error leaves Using, Resume in an external On Error GoTo handler restarts the whole Using header and evaluates the resource expression again. Resume Next continues immediately after End Using. Retrying a variable that still refers to a closed object does not reopen it; use an expression that acquires a fresh resource when retrying. Body effects before the failure can therefore repeat.

## Examples

### 1. Close a memory stream

```vb
# stream is the resource; size reads Length()=0 while it is open. After End Using, IsClosed(stream) catches the closed-stream error and returns True=1. Main returns "0:1". ByVal copies the object reference, not the stream. This helper treats any Length error as closed and is only a demonstration for these streams.
Option Explicit On
Function IsClosed(ByVal stream) As Boolean
    Try
        Dim size = stream.Length()
        Return False
    Catch closed
        Return True
    End Try
End Function

Sub Main()
    Dim stream = MemoryStream()
    Dim size = -1
    Using stream
        size = stream.Length()
    End Using
    Return CStr(size) & ":" & CStr(IsClosed(stream))
End Sub
```

**Parameter and execution notes:**

stream is the resource; size reads Length()=0 while it is open. After End Using, IsClosed(stream) catches the closed-stream error and returns True=1. Main returns "0:1". ByVal copies the object reference, not the stream. This helper treats any Length error as closed and is only a demonstration for these streams.

### 2. Return from a helper

```vb
# ReadLength(stream) acquires ownership for its Using block and computes Integer 0. Return then closes the stream before Main receives size. Main confirms the subsequent Length error, sets closed=True and returns "0:1". Do not pass a resource here if the caller still needs it open.
Option Explicit On
Function ReadLength(ByVal stream) As Integer
    Using stream
        Return stream.Length()
    End Using
End Function

Sub Main()
    Dim stream = MemoryStream()
    Dim size = ReadLength(stream)
    Dim closed = False
    Try
        Dim after = stream.Length()
    Catch problem
        closed = True
    End Try
    Return CStr(size) & ":" & CStr(closed)
End Sub
```

**Parameter and execution notes:**

ReadLength(stream) acquires ownership for its Using block and computes Integer 0. Return then closes the stream before Main receives size. Main confirms the subsequent Length error, sets closed=True and returns "0:1". Do not pass a resource here if the caller still needs it open.

### 3. Nested cleanup after an error

```vb
# outer and inner are separate streams. Throw "demo" leaves both blocks: inner closes first, then outer. Catch stores the original message. IsClosed returns 1 for each stream, so Main returns "demo:2". The number 2 counts two closed objects and is not a Boolean value.
Option Explicit On
Function IsClosed(ByVal stream) As Boolean
    Try
        Dim size = stream.Length()
        Return False
    Catch closed
        Return True
    End Try
End Function

Sub Main()
    Dim outer = MemoryStream()
    Dim inner = MemoryStream()
    Dim message = ""
    Try
        Using outer
            Using inner
                Throw "demo"
            End Using
        End Using
    Catch problem
        message = problem
    End Try
    Return message & ":" & CStr(IsClosed(outer) + IsClosed(inner))
End Sub
```

**Parameter and execution notes:**

outer and inner are separate streams. Throw "demo" leaves both blocks: inner closes first, then outer. Catch stores the original message. IsClosed returns 1 for each stream, so Main returns "demo:2". The number 2 counts two closed objects and is not a Boolean value.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: usingStatement / USING / END_USING
Runtime/Instructions/Generator.cs: Generate(UsingStatementContext)
Runtime/Interpreter.cs: TryExecutionScope.DisposeResource / Transfer / DeferReturn / CallSubrutine
Runtime/ObjectTypes/FileObject.cs: Dispose / Close
Runtime/ObjectTypes/MemoryStreamObject.cs: Dispose
Analysis/TryStructureValidator.cs: Regions
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/using-statement
-->
