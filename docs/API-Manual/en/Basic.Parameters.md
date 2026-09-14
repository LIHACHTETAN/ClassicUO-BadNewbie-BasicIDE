# Parameters / ByRef / ByVal / Optional / ParamArray

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: en -->

Parameters pass data into SUB/FUNCTION. ByRef writes an updated value back to the caller; ByVal preserves the caller’s variable. Optional supplies an omitted argument and ParamArray collects remaining arguments. These are declaration modifiers, not callable commands.

## Exact syntax

```text
Sub name(ByRef target, ByVal value, Optional ByVal amount = 2, ParamArray rest())
Function name(parameters) As type
name(arguments)
```

## Parameters

- `name / As type` — name / As type: Parameter name and optional As input conversion. Arguments can bind by position or name:=value; modifiers belong in declarations. See Basic.NamedArguments.
- `ByRef` — ByRef: a writable variable or an existing indexed element. This engine also copies back unmodified parameters without ByVal, unlike the VB.NET default. Literals, constants and computed expressions are temporary values.
- `ByVal` — ByVal: a local value copy. Assigning the parameter does not replace the caller’s variable. Arrays and objects still share references; this is not a deep copy.
- `Optional / defaultValue` — Optional / defaultValue: omit a trailing argument to evaluate its = expression. Supply an explicit useful default; an omitted parameter without one receives uninitialized Unit.
- `ParamArray` — ParamArray values(): the last parameter receives zero or more remaining values. A single array is reused directly; scalar arguments create a new array. GetArrayLength returns its length.

## Returns

Modifiers return no value. RETURN independently sets the function result. ByRef write-back changes an argument; it is not the result. A SUB without RETURN produces Unit. Example numbers are calculated results, not TRUE/FALSE flags.

## Behavior

- Arguments evaluate once, left to right. Indexed ByRef captures the container and index/key; another argument reassigning the container variable cannot redirect that write-back.
- Entry creates local parameters. On exit, after inner FINALLY blocks, ByRef values copy back in parameter order, including errors leaving the body. Passing the same variable twice does not create a live alias between parameter locals: the last write-back wins.
- ByVal prevents replacement of the caller’s variable but permits mutations inside a shared array or object. ReDim on a ByVal array creates a new local reference. Independent data requires an explicit copy.
- For positional calls: Omit optional arguments from the end; empty positions between commas are unsupported. Defaults can be engine expressions and run on each omission; they need not be VB.NET constants. Positional arguments must come first; all arguments after the first named one must also be named. Required parameters cannot be omitted. Omitted Optional parameters in script procedures use their declared defaults, evaluated in declaration order after supplied expressions. Native overloads accept only their registered arity and names; there are no invented defaults.
- ParamArray does not copy packed scalars back into their original variables. Mutating an explicitly supplied array is visible to the caller. Forwarding that array into another ParamArray function does not add nesting.
- Write ByRef and ByVal explicitly to show intent. These rules describe script calls to user procedures; built-in command argument contracts are in their own cards.
- ParamArray cannot be supplied by name; calls with any named arguments may leave it empty, but supplying its values requires a positional-only call. Empty comma placeholders are unsupported. This supported subset uses the positional-first rule, not the more permissive mixing in recent VB.NET. It starts no extra threads and does not change game delays.

## Examples

### 1. Update a variable

```vb
# Adjust receives amount=5 by reference and increment=3 by value. It updates amount to 8 and copies it back. Main returns Integer 8; Adjust has no result.
Option Explicit On
Sub Adjust(ByRef amount, ByVal increment)
    amount += increment
End Sub
Sub Main()
    Var amount = 5
    Adjust(amount, 3)
    Return amount
End Sub
```

**Parameter and execution notes:**

Adjust receives amount=5 by reference and increment=3 by value. It updates amount to 8 and copies it back. Main returns Integer 8; Adjust has no result.

### 2. Omitted and supplied factor

```vb
# Scale(3) uses factor=2 and returns 6. Scale(3,4) uses factor=4 and returns 12. Main returns 6*100+12, Integer 612.
Option Explicit On
Function Scale(ByVal value, Optional ByVal factor = 2)
    Return value * factor
End Function
Sub Main()
    Return Scale(3) * 100 + Scale(3, 4)
End Sub
```

**Parameter and execution notes:**

Scale(3) uses factor=2 and returns 6. Scale(3,4) uses factor=4 and returns 12. Main returns 6*100+12, Integer 612.

### 3. Empty and populated arguments

```vb
# Sum() receives an empty array and returns 0. Sum(2,3,4) receives three values and returns 9. For Each visits each value. Main returns Integer 9.
Option Explicit On
Function Sum(ParamArray values())
    Var total = 0
    For Each value In values
        total += value
    Next
    Return total
End Function
Sub Main()
    Return Sum() + Sum(2, 3, 4)
End Sub
```

**Parameter and execution notes:**

Sum() receives an empty array and returns 0. Sum(2,3,4) receives three values and returns 9. For Each visits each value. Main returns Integer 9.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: parameterName / parameterModifier / defaultValue
Runtime/SubrutineDefinition.cs: WritableParameters / RequiredArgumentCount / HasParamArray
Runtime/Interpreter.cs: VisitCall / CreateArgumentWriter / CallSubrutine / EvaluateInitializer
Runtime/IndexedValueSlot.cs: Read / Write
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/modifiers/byref
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/modifiers/byval
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/modifiers/optional
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/modifiers/paramarray
-->
