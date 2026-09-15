# Sub / Call / Exit Sub / End Sub

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: en -->

Sub groups statements into a named procedure. Use helpers to share inventory processing, validation or cleanup. Calls run synchronously in the current script; calling a helper does not start another background script.

## Exact syntax

```text
Sub name(parameters)
    statements
End Sub
name(arguments)
Call name(arguments)
Call name arguments
Call name
Exit Sub
Return
Return expression
```

## Parameters

- `name` — The procedure identifier. Names are case-insensitive. Use your own name without UO.; a module member is Tools.Work(...). Public/Private control module access; see Basic.Module and Basic.Visibility.
- `parameters / arguments` — Declare parameters between parentheses; pass positional arguments in declaration order. ByRef is the default, ByVal copies the argument value, Optional supplies a default, and the last ParamArray collects extra arguments. See the five parameter chapters for exact type, array, aliasing and copy-back rules.
- `statements / End Sub` — The procedure body may be empty. Close it with End Sub. Local variables belong to the current invocation; recursive calls have separate locals. Declare helpers at file or module level, not inside another procedure.
- `Call` — Call is optional for name(arguments). Call name arguments also accepts arguments without parentheses; Call name invokes a parameterless procedure. Call discards a returned value. Names and argument expressions keep their usual meaning; no UO. prefix is added to user procedures.
- `Exit Sub / Return` — Exit Sub or bare Return ends this invocation. Return expression is a Basic compatibility extension that returns a value even from Sub; ordinary VB.NET Sub does not have this form. Exit Function inside Sub is a load error.

## Returns

End Sub, Exit Sub and bare Return yield Unit: no meaningful result, not a success Boolean or item ID. Return expression in a legacy Basic Sub yields that expression. ByRef may separately update the caller. Prefer Function for a helper whose purpose is to return a value.

## Behavior

- Preparation normalizes compatible headers and Call forms, validates the block and resolves callable names. Arguments are evaluated and bound before entering the helper; repeated calls reuse prepared instructions, not shared local values.
- The interpreter creates the invocation scope, executes the body and then returns to the statement after the call. A normal return or Exit Sub runs any active Finally blocks it leaves, then completes parameter copy-back. An exception follows the active error handler; a failing call must not be treated as a successful result.
- Pause/stop checks remain in the script runtime. A helper adds no thread, automatic delay or timeout. Recursive code needs a terminating condition. Sub result assignment by name is not supported: use Function when writing name=expression.
- Nested script procedure calls are limited to 32 frames, including callbacks and event handlers. Exceeding the limit raises a catchable script error; use a loop for deep processing. Returning or failing releases the frame, so later calls can proceed.

## Examples

### 1. Three call forms

```vb
# total starts at 4. AddAmount receives total ByRef; omitted amount defaults to 1, while explicit 3 and 2 are ByVal. Call with parentheses, Call without parentheses and an ordinary call run the same helper. The caller reaches 4+1+3+2=10; Main explicitly returns 10.
Option Explicit On
Sub AddAmount(ByRef total, Optional ByVal amount=1)
    total += amount
End Sub

Sub Main()
    Dim total=4
    Call AddAmount(total)
    Call AddAmount total, 3
    AddAmount(total, 2)
    Return total
End Sub
```

**Parameter and execution notes:**

total starts at 4. AddAmount receives total ByRef; omitted amount defaults to 1, while explicit 3 and 2 are ByVal. Call with parentheses, Call without parentheses and an ordinary call run the same helper. The caller reaches 4+1+3+2=10; Main explicitly returns 10.

### 2. Public entry and private helper

```vb
# Batches.SumInto receives total ByRef and packs 3,-9,4 into values. For Each calls private AppendAmount for each value. Its negative check exits only that helper, so -9 is skipped and the loop continues. Starting from 2 gives 2+3+4=9. The helper is accessible inside Batches; the caller uses the public qualified name.
Option Explicit On
Module Batches
    Private Sub AppendAmount(ByRef total, ByVal value)
        If value < 0 Then
            Exit Sub
        End If
        total += value
    End Sub

    Public Sub SumInto(ByRef total, ParamArray values)
        For Each value In values
            AppendAmount(total, value)
        Next
    End Sub
End Module

Sub Main()
    Dim total=2
    Batches.SumInto(total, 3, -9, 4)
    Return total
End Sub
```

**Parameter and execution notes:**

Batches.SumInto receives total ByRef and packs 3,-9,4 into values. For Each calls private AppendAmount for each value. Its negative check exits only that helper, so -9 is skipped and the loop continues. Starting from 2 gives 2+3+4=9. The helper is accessible inside Batches; the caller uses the public qualified name.

### 3. Early exit, cleanup and a legacy result

```vb
# Finish changes trace to 1 and exits; trace=99 never runs. Finally appends 2, so ByRef returns trace=12 to Main. LegacyValue demonstrates the Basic-only Return 7 inside Sub. Main combines 12*10+7=127. These are script-owned trace numbers, not game result codes.
Option Explicit On
Sub Finish(ByRef trace)
    Try
        trace=1
        Exit Sub
        trace=99
    Finally
        trace=trace*10+2
    End Try
End Sub

Sub LegacyValue()
    Return 7
End Sub

Sub Main()
    Dim trace=0
    Call Finish(trace)
    Return trace*10+LegacyValue()
End Sub
```

**Parameter and execution notes:**

Finish changes trace to 1 and exits; trace=99 never runs. Finally appends 2, so ByRef returns trace=12 to Main. LegacyValue demonstrates the Basic-only Return 7 inside Sub. Main combines 12*10+7=127. These are script-owned trace numbers, not game result codes.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: subrutine / parameters / returnStatement / exitProcedure
Runtime/BasicSyntaxPreprocessor.cs: Normalize / NormalizeArguments
Analysis/ProcedureStructureValidator.cs: VisitSubrutine / VisitExitProcedure / CheckName
Runtime/SubrutineDefinition.cs: IsFunction / ReturnType / ResultName
Runtime/Interpreter.cs: CallSubrutine / FunctionResult / DeferReturn / DefaultValueForType
Runtime/SemanticScope.cs: DefineVar / SetVar
Runtime/ScriptBindings.cs: Builder.VisitSubrutine
ClassicUO.Client/Game/Managers/YokoInjectionManager.cs: DiscoverProcedures / DiscoverScopedProcedures
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/sub-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/call-statement
-->
