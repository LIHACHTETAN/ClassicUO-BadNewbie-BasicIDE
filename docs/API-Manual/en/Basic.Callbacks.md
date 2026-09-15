# AddressOf / callbacks

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: en -->

AddressOf stores a reference to a script Sub or Function without calling it. Pass the reference to another procedure, return it from a function or keep it in a collection to select your own processing rule.

## Exact syntax

```text
Dim callback = AddressOf ProcedureName
Dim callback As Object = AddressOf Tools.FunctionName
callback(arguments)
callback.Invoke(arguments)
Process(values, AddressOf Predicate)
```

## Parameters

- `ProcedureName` — A declared procedure name, optionally qualified with its Module. Exactly one declaration must match. Unknown names, inaccessible Private members and overloaded names are rejected before execution. For a Basic built-in or UO command, write a uniquely named script wrapper and take its AddressOf. Do not append parentheses after the name.
- `callback / arguments` — callback is an Object value. callback(...) and callback.Invoke(...) call the referenced procedure synchronously on the current script thread. Use its actual parameter names for named arguments. Capture a collection element into a variable before calling it. The reference is captured before argument expressions can reassign the variable.
- `ByRef / ByVal / Optional / ParamArray` — Normal procedure rules apply: ByVal copies the value/reference, ByRef copies writable arguments back, Optional evaluates omitted defaults, ParamArray packs positional values. Named arguments follow positional arguments; ParamArray values require a positional-only call. Bad arity or names fail before argument side effects.

## Returns

AddressOf returns an Object reference, not an ID, pointer, Boolean or the function result. Invoking a Function returns its declared result. A Sub without Return expression yields no value (Unit). IsPositive below returns 1/True or 0/False; Main returns a String in examples 1 and 3, Integer 15 in example 2.

## Behavior

- A reference identifies a procedure, not the local variables of the factory. This is not a lambda or closure. It belongs to the loaded script that created it; another runtime or a reloaded script cannot invoke an old handle. A public factory can deliberately return a reference to its own Private helper.
- Preparation checks name and access. The interpreter caches an immutable handle per AddressOf location, resolves the current callback variable at each call, validates the signature, evaluates arguments once in written order and enters a normal procedure frame. It uses the same ByRef copy-back and exception handling as a direct call.
- Callbacks create no thread or timer and do not run independently. Pause and cancellation use normal script checkpoints, including loops inside the callback. Errors reach the caller’s Catch/Finally; emergency stop is not swallowed by Catch. Blocking native calls still obey their own cancellation limitations.
- Delegate type declarations, lambdas, native DLL function pointers and references to overloaded procedures are not supported by this feature. AddressOf is a Basic operator without UO.; game commands inside wrappers retain UO.
- Nested script procedure calls are limited to 32 frames, including callbacks and event handlers. Exceeding the limit raises a catchable script error; use a loop for deep processing. Returning or failing releases the frame, so later calls can proceed.

## Examples

### 1. Filter with a predicate

```vb
# values is the input List; predicate is AddressOf IsPositive. FilterValues calls predicate(number) once per value. IsPositive returns True only above zero; the result contains 4 and 7. selected.Count() is 2 and selected[0] is 4, so Main returns "2:4". FilterValues and IsPositive are fully shown script helpers, not extra API commands.
Option Explicit On
Function IsPositive(ByVal number) As Boolean
    Return number > 0
End Function

Function FilterValues(ByVal values, ByVal predicate)
    Dim result = List()
    For Each number In values
        If predicate(number) Then
            result.Add(number)
        End If
    Next
    Return result
End Function

Sub Main()
    Dim numbers = List()
    numbers.Add(-2)
    numbers.Add(4)
    numbers.Add(7)
    Dim selected = FilterValues(numbers, AddressOf IsPositive)
    Return CStr(selected.Count()) & ":" & CStr(selected[0])
End Sub
```

**Parameter and execution notes:**

values is the input List; predicate is AddressOf IsPositive. FilterValues calls predicate(number) once per value. IsPositive returns True only above zero; the result contains 4 and 7. selected.Count() is 2 and selected[0] is 4, so Main returns "2:4". FilterValues and IsPositive are fully shown script helpers, not extra API commands.

### 2. Modify a caller variable

```vb
# AddAmount receives total ByRef and amount ByVal, default 1. update(total) changes 10 to 11; update.Invoke(amount:=4, total:=total) binds by name and changes 11 to 15. ByRef writes back to the caller. AddAmount is a Sub with no result; Main returns Integer 15, not a Boolean.
Option Explicit On
Sub AddAmount(ByRef total As Integer, Optional ByVal amount = 1)
    total += amount
End Sub

Sub Main()
    Dim update = AddressOf AddAmount
    Dim total = 10
    update(total)
    update.Invoke(amount:=4, total:=total)
    Return total
End Sub
```

**Parameter and execution notes:**

AddAmount receives total ByRef and amount ByVal, default 1. update(total) changes 10 to 11; update.Invoke(amount:=4, total:=total) binds by name and changes 11 to 15. ByRef writes back to the caller. AddAmount is a Sub with no result; Main returns Integer 15, not a Boolean.

### 3. Export a private rule and handle failure

```vb
# Rules.Create returns a handle to Private CheckedDouble; outside code cannot take AddressOf Rules.CheckedDouble directly. operation(6) returns 12. operation(-1) throws "negative" before assignment, so result remains 12. Catch receives the message and Finally appends ":done"; Main returns "12:negative:done". Closing the IDE does not cancel an otherwise running script.
Option Explicit On
Module Rules
    Private Function CheckedDouble(ByVal number) As Integer
        If number < 0 Then
            Throw "negative"
        End If
        Return number * 2
    End Function

    Public Function Create()
        Return AddressOf CheckedDouble
    End Function
End Module

Sub Main()
    Dim operation = Rules.Create()
    Dim result = operation(6)
    Dim message = ""
    Try
        result = operation(-1)
    Catch problem
        message = problem
    Finally
        message = message & ":done"
    End Try
    Return CStr(result) & ":" & message
End Sub
```

**Parameter and execution notes:**

Rules.Create returns a handle to Private CheckedDouble; outside code cannot take AddressOf Rules.CheckedDouble directly. operation(6) returns 12. operation(-1) throws "negative" before assignment, so result remains 12. Catch receives the message and Finally appends ":done"; Main returns "12:negative:done". Closing the IDE does not cancel an otherwise running script.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: addressOf / ADDRESSOF
Runtime/Metadata.cs: TryGetCallbackTarget
Analysis/InvalidSymbolVisitor.cs: VisitAddressOf
Runtime/Interpreter.Callbacks.cs: VisitAddressOf / TryGetCallback / CallCallback
Runtime/Interpreter.cs: CreateArgumentWriter / CallSubrutine
Runtime/NamedArgumentBinding.cs: TryCreate
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/operators/addressof-operator
-->
