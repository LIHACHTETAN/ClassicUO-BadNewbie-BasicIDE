# Named arguments / :=

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: en -->

Named arguments bind values to declared parameter names, so their order can differ from the declaration. They work for script procedures/functions, qualified module calls, registered Basic/UO functions and native object methods.

## Exact syntax

```text
FunctionName(parameterName:=expression, otherName:=expression)
FunctionName(positionalExpression, optionalName:=expression)
FunctionName([reservedName]:=expression)
```

## Parameters

- `parameterName / [reservedName]` — Use the exact name shown in the declaration or runtime signature; matching ignores case. Write name:=value. Square brackets escape a reserved parameter name, for example [to]:=100. These brackets belong to the argument label, not an array index. Unknown or duplicate names are errors.
- `expression` — Every supplied expression is evaluated once, left to right in the written call. Values are then assigned to their parameter slots. Types, bounds and ByVal/ByRef behavior remain those of the called function. Named syntax cannot turn a value into a writable ByRef variable.
- `positionalExpression / optionalName` — Positional arguments must come first; all arguments after the first named one must also be named. Required parameters cannot be omitted. Omitted Optional parameters in script procedures use their declared defaults, evaluated in declaration order after supplied expressions. Native overloads accept only their registered arity and names; there are no invented defaults.

## Returns

The := notation returns no independent value. A Function/API call returns exactly its own result; a Sub has no implicit result. The examples return Integer 129 and Strings "21:12" and "20:10:2", not Boolean success flags.

## Behavior

- Preparation checks known procedure/API signatures and reports SC027 with the source location for invalid names, duplicates, missing required parameters or ambiguous calls. A dynamic object is checked at runtime before evaluating its argument expressions. An absent native overload does not silently fall back to a zero-argument call.
- The interpreter caches immutable mappings for static call sites. It evaluates arguments in source order and uses the map for parameter assignment and ByRef copy-back. Defaults and debugger parameter values reflect the selected signature. Dynamic object receivers are captured for that invocation, never reused from a previous object.
- ParamArray cannot be supplied by name; calls with any named arguments may leave it empty, but supplying its values requires a positional-only call. Empty comma placeholders are unsupported. This supported subset uses the positional-first rule, not the more permissive mixing in recent VB.NET. It starts no extra threads and does not change game delays.

## Examples

### 1. Skip an optional middle parameter

```vb
# Encode declares x, y=2, z=3. z:=9 supplies z first and x:=1 supplies x second; y is omitted and uses 2. The function computes 1*100+2*10+9=129. The equivalent positional call is Encode(1,2,9); Encode(1,z:=9) is another supported form.
Option Explicit On
Function Encode(ByVal x, Optional ByVal y=2, Optional ByVal z=3) As Integer
    Return x*100 + y*10 + z
End Function

Sub Main()
    Dim encoded = Encode(z:=9, x:=1)
    Return encoded
End Sub
```

**Parameter and execution notes:**

Encode declares x, y=2, z=3. z:=9 supplies z first and x:=1 supplies x second; y is omitted and uses 2. The function computes 1*100+2*10+9=129. The equivalent positional call is Encode(1,2,9); Encode(1,z:=9) is another supported form.

### 2. Write back to the right variables

```vb
# Change declares ByRef left and right. right:=a binds a=1 to right; left:=b binds b=2 to left. The procedure adds 10 to left and 20 to right, then writes back b=12 and a=21. Main returns "21:12". The label selects a parameter, while the expression after := selects the caller variable.
Option Explicit On
Sub Change(ByRef left, ByRef right)
    left += 10
    right += 20
End Sub

Sub Main()
    Dim a = 1
    Dim b = 2
    Change(right:=a, left:=b)
    Return CStr(a) & ":" & CStr(b)
End Sub
```

**Parameter and execution notes:**

Change declares ByRef left and right. right:=a binds a=1 to right; left:=b binds b=2 to left. The procedure adds 10 to left and 20 to right, then writes back b=12 and a=21. Main returns "21:12". The label selects a parameter, while the expression after := selects the caller variable.

### 3. Use a native collection with named operands

```vb
# List() creates an empty list. Add(value:=10) appends 10 and returns no value. Insert(value:=20,index:=0) inserts 20 at zero-based index 0 and shifts 10 to index 1. Item(index:=...) returns that element; Count() returns 2. Main formats "20:10:2". The same binding rules apply to UO.Name(...), using that command’s registered names and result contract.
Option Explicit On
Sub Main()
    Dim items = List()
    items.Add(value:=10)
    items.Insert(value:=20, index:=0)
    Dim first = items.Item(index:=0)
    Dim second = items.Item(index:=1)
    Return CStr(first) & ":" & CStr(second) & ":" & CStr(items.Count())
End Sub
```

**Parameter and execution notes:**

List() creates an empty list. Add(value:=10) appends 10 and returns no value. Insert(value:=20,index:=0) inserts 20 at zero-based index 0 and shifts 10 to index 1. Item(index:=...) returns that element; Count() returns 2. Main formats "20:10:2". The same binding rules apply to UO.Name(...), using that command’s registered names and result contract.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: argument
Runtime/NamedArgumentBinding.cs: TryCreate / TryCustom
Runtime/Interpreter.NamedArguments.cs: CallNamed
Runtime/Interpreter.cs: CallSubrutine / CreateArgumentWriter
Analysis/NamedArgumentsValidator.cs
https://learn.microsoft.com/en-us/dotnet/visual-basic/programming-guide/language-features/procedures/passing-arguments-by-position-and-by-name
-->
