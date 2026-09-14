# ParamArray

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: en -->

Parameters pass data into SUB/FUNCTION. ByRef writes an updated value back to the caller; ByVal preserves the caller’s variable. Optional supplies an omitted argument and ParamArray collects remaining arguments. These are declaration modifiers, not callable commands.

## Exact syntax

```text
Function Sum(ParamArray values())
Sum()
Sum(2, 3, 4)
Sum(existingArray)
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

### 1. Empty and populated arguments

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

### 2. Forward an existing array

```vb
# values contains 2 and 5. Forward passes that array to Sum without an extra wrapper. Sum adds two numbers and returns Integer 7.
Option Explicit On
Function Sum(ParamArray values())
    Var total = 0
    For Each value In values
        total += value
    Next
    Return total
End Function
Function Forward(ParamArray values())
    Return Sum(values)
End Function
Sub Main()
    Dim values[1]
    values[0] = 2
    values[1] = 5
    Return Forward(values)
End Sub
```

**Parameter and execution notes:**

values contains 2 and 5. Forward passes that array to Sum without an extra wrapper. Sum adds two numbers and returns Integer 7.

### 3. Scalars versus a supplied array

```vb
# SetFirst(first,second) changes a newly packed array, preserving first=2 and second=3. SetFirst(packed) changes shared packed[0] from 4 to 9. Main returns 2*100+3*10+9, Integer 239.
Option Explicit On
Sub SetFirst(ParamArray values())
    If GetArrayLength(values) > 0 Then
        values[0] = 9
    End If
End Sub
Sub Main()
    Var first = 2
    Var second = 3
    SetFirst(first, second)
    Dim packed[0]
    packed[0] = 4
    SetFirst(packed)
    Return first * 100 + second * 10 + packed[0]
End Sub
```

**Parameter and execution notes:**

SetFirst(first,second) changes a newly packed array, preserving first=2 and second=3. SetFirst(packed) changes shared packed[0] from 4 to 9. Main returns 2*100+3*10+9, Integer 239.

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
