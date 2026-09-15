# Function / Return / Exit Function / End Function

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: en -->

Function declares a helper that returns a value. It can calculate a quantity, produce text or return a List/Dictionary reference. It is user code, called without UO.; UO.GetType(item) remains a separate game API even if you declare Function GetType(value).

## Exact syntax

```text
Function name(parameters) As type
    name = expression
End Function
Function name(parameters)
    Return expression
End Function
result = name(arguments)
Exit Function
Return
```

## Parameters

- `name` — The case-insensitive identifier is both the callable name and an implicit local result variable inside its own body. Read name without parentheses for the current result; name(arguments) calls the function, including recursion. Do not redeclare the result with Dim, Var, Const or a parameter.
- `parameters / arguments` — Positional parameters follow the same ByRef (default), ByVal, Optional and last ParamArray rules as Sub. See Basic.Parameters and the dedicated parameter chapters. A module function is called as Tools.Calculate(...); Public/Private obey module access rules.
- `As type` — Optional result annotation. Integer/Long/Short/Byte use this engine’s Integer storage; Double/Single/Decimal use Double; String stores text; Boolean/Bool normalizes to 1 or 0; Object/Variant preserves the value kind. These are not all VB.NET numeric widths. Unknown return types are rejected. Without As, the result is Variant; name suffixes do not infer a result type here.
- `name = expression` — Stores the result and CONTINUES with the following statement. The result can be read or updated again, including +=. It is a local variable belonging to this invocation, not a global or a call.
- `Return / Exit Function / End Function` — Return expression assigns the typed result and starts leaving the function. Bare Return, Exit Function and reaching End Function return the current result. End Function is required. Exit Sub inside Function is a load error.

## Returns

The current result is returned after normal Finally cleanup. Initial defaults: Integer 0, Double 0.0, Boolean FALSE/0, String empty text; untyped/Variant/Object start as Unit, with no meaningful value. List/Dictionary/Object results retain references. Boolean results are numeric 1/0, so TRUE/FALSE comparisons work; an arbitrary quantity or ID is not automatically a success code.

## Behavior

- Preparation retains a real Function definition, validates return type and exits, binds the implicit result as a local, and prepares the body once. On each invocation the interpreter binds arguments and initializes a fresh typed result. Function name assignment uses ordinary typed-variable conversion.
- Return records the result and unwinds active Finally blocks from inner to outer. Finally can update the result before it reaches the caller. ByRef copy-back occurs after successful completion. An unhandled error propagates instead of returning a success value; a bad result conversion is an error.
- A recursive call has its own parameters, locals and result, so Factorial(n-1) cannot overwrite the caller’s Factorial variable. Supply a base case and avoid unbounded recursion. Calls add no automatic delay, thread or timeout; runtime pause/stop checks still apply.
- Nested script procedure calls are limited to 32 frames, including callbacks and event handlers. Exceeding the limit raises a catchable script error; use a loop for deep processing. Returning or failing releases the frame, so later calls can proceed.

## Examples

### 1. Assign, continue or return early

```vb
# TotalPrice receives count and price ByVal and returns Integer. Negative count or price returns -1 immediately. Otherwise count*price is stored, then the next instruction adds a fixed 2. TotalPrice(3,4) returns 14; TotalPrice(-1,4) returns -1. Main joins the values as 14:-1. The -1 is a rule chosen by this helper, not an automatic engine error code.
Option Explicit On
Function TotalPrice(ByVal count, ByVal price) As Integer
    If count < 0 OrElse price < 0 Then
        Return -1
    End If
    TotalPrice=count*price
    TotalPrice+=2
End Function

Sub Main()
    Return CStr(TotalPrice(3, 4)) & ":" & CStr(TotalPrice(-1, 4))
End Sub
```

**Parameter and execution notes:**

TotalPrice receives count and price ByVal and returns Integer. Negative count or price returns -1 immediately. Otherwise count*price is stored, then the next instruction adds a fixed 2. TotalPrice(3,4) returns 14; TotalPrice(-1,4) returns -1. Main joins the values as 14:-1. The -1 is a rule chosen by this helper, not an automatic engine error code.

### 2. Recursion with an independent result

```vb
# Factorial receives n ByVal and initializes its own result to 1. For n<=1, Exit Function returns that 1. Otherwise n*Factorial(n-1) computes the product using a fresh nested invocation. The script uses small nonnegative inputs: 5!+3!=120+6=126. Negative inputs also take the base branch; this example does not validate factorial’s full mathematical domain.
Option Explicit On
Function Factorial(ByVal n) As Integer
    Factorial=1
    If n <= 1 Then
        Exit Function
    End If
    Factorial=n*Factorial(n-1)
End Function

Sub Main()
    Return Factorial(5)+Factorial(3)
End Sub
```

**Parameter and execution notes:**

Factorial receives n ByVal and initializes its own result to 1. For n<=1, Exit Function returns that 1. Otherwise n*Factorial(n-1) computes the product using a fresh nested invocation. The script uses small nonnegative inputs: 5!+3!=120+6=126. Negative inputs also take the base branch; this example does not validate factorial’s full mathematical domain.

### 3. Return, two Finally blocks and ByRef

```vb
# Calculate receives trace ByRef. Return 1 sets the result and initiates exit. The inner Finally changes both result and trace from 1 to 12; the outer changes them to 123. Main receives result=123 and trace=123 and returns 123:123. Cleanup changes the returned result even after Return expression; no game movement or timing is simulated.
Option Explicit On
Function Calculate(ByRef trace) As Integer
    Try
        Try
            trace=1
            Return 1
        Finally
            Calculate=Calculate*10+2
            trace=trace*10+2
        End Try
    Finally
        Calculate=Calculate*10+3
        trace=trace*10+3
    End Try
End Function

Sub Main()
    Dim trace=0
    Dim result=Calculate(trace)
    Return CStr(result) & ":" & CStr(trace)
End Sub
```

**Parameter and execution notes:**

Calculate receives trace ByRef. Return 1 sets the result and initiates exit. The inner Finally changes both result and trace from 1 to 12; the outer changes them to 123. Main receives result=123 and trace=123 and returns 123:123. Cleanup changes the returned result even after Return expression; no game movement or timing is simulated.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: subrutine / parameters / returnStatement / exitProcedure
Runtime/BasicSyntaxPreprocessor.cs: Normalize / NormalizeArguments
Analysis/ProcedureStructureValidator.cs: VisitSubrutine / VisitExitProcedure / CheckName
Runtime/SubrutineDefinition.cs: IsFunction / ReturnType / ResultName
Runtime/Interpreter.cs: CallSubrutine / FunctionResult / DeferReturn / DefaultValueForType
Runtime/SemanticScope.cs: DefineVar / SetVar
Runtime/ScriptBindings.cs: Builder.VisitSubrutine
ClassicUO.Client/Game/Managers/YokoInjectionManager.cs: DiscoverProcedures / DiscoverScopedProcedures
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/function-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/return-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/exit-statement
-->
