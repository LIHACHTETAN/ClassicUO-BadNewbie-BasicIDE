# Structure / New / fields

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: en -->

Structure groups typed fields, such as X, Y and Z, into one value. This engine supports data structures with value copies; it does not implement the entire VB.NET Structure feature set.

## Exact syntax

```text
[Public | Private] Structure TypeName
    [Public | Dim | VAR] field As FieldType
End Structure
Dim value As TypeName
Dim value = New TypeName()
copy = value
value.field = expression
Sub Change(ByRef value As TypeName)
Function Copy(ByVal value As TypeName) As TypeName
```

## Parameters

- `TypeName / Public / Private` — A unique simple type name, declared at file level or inside Module. Public is the default. Private is allowed only in a Module; outside code cannot name that type. Use ModuleName.TypeName for a public module type. Keywords and field names are not translated.
- `field / FieldType` — A unique field name followed by As and a supported scalar type, Enum or another Structure. Fields are public; Public, Dim and VAR spellings are accepted. Scalar types: Integer/Long/Short/Byte, Single/Double/Decimal, String, Boolean/Bool, Object/Variant. Integer aliases use this engine’s signed 32-bit storage. Nested structures must not form cycles.
- `Dim / New` — Dim value As TypeName and New TypeName() produce the default value without calling script code. New requires empty parentheses. It takes no X/Y/Z arguments: assign fields afterward. Dim copy = value infers the value; no UO. prefix is used.
- `value.field / copy` — Read or assign a field with a dot, including route.Start.X. Field assignment checks the declared type and replaces the containing value. copy = value copies scalar and nested structure values; modifying copy.X leaves value.X unchanged. Assign only compatible structure types.
- `ByVal / ByRef` — ByVal passes a value copy. ByRef uses the engine’s copy-in/copy-out binding: updated values are written back to the caller, including a writable field argument. Use explicit modifiers; legacy unmodified parameters follow the existing Basic rules. Return can return a structure, and a Function can declare As TypeName.

## Returns

The declaration and assignment statements have no result (Unit). New and structure-valued functions return a structure value, represented as Object in runtime observations; its display includes the declared type. Numeric coordinate fields are quantities, not Boolean flags. Structure = and <> comparisons return 1/True or 0/False. Example results are the Strings "1445:1447:1690:0", "10:15:24" and "2:4:2:2".

## Behavior

- Declarations are checked before initializers run. A script may declare at most 256 structure types, each with 1–256 fields; nesting is limited to 32 levels. Duplicate/unknown field types, cycles and excess limits produce SC030. Private names are checked during binding.
- Default fields: integer/Enum 0; floating-point 0; Boolean 0/False; String empty; Object/Variant Unit until assigned. Nested fields contain their own default structure values. Field initializers in the declaration are unsupported: set them after construction.
- Object and array fields retain references when the containing structure is copied. Two copies can therefore share one List, Dictionary or array. Replacing a scalar/nested structure field is independent; changing the contents of a referenced collection is shared. Storing a structure in a List preserves its value at that moment.
- This project additionally supports value equality: = compares the same declared type and corresponding fields; <> is its inverse. Reference fields compare identity. This is an engine extension, not a claim that arbitrary VB.NET structures support =. Cached hashes and a visited-pair set prevent repeated expansion of shared nested values.
- Supported here: typed public data fields, module visibility, New(), assignment and parameter/result values. Methods inside Structure, custom constructors, field initializers, properties, inheritance and private fields are not supported. WITH .field and array[index].field syntax are not supported; first read the element into a variable, edit it, then write it back. Include can hold the declaration in a separate source file.

## Examples

### 1. Coordinates and an independent copy

```vb
# Main creates original with X=1445 and Y=1690; Z remains 0. copy receives the value, then copy.X += 2 changes only the copy. New Position() creates empty with Z=0. The four returned fields explain the exact result 1445:1447:1690:0. These are stored coordinates; this script does not move the character.
Option Explicit On
Structure Position
    Public X As Integer
    Public Y As Integer
    Public Z As Integer
End Structure

Sub Main()
    Dim original As Position
    original.X = 1445
    original.Y = 1690
    Dim copy = original
    copy.X += 2
    Dim empty = New Position()
    Return CStr(original.X) & ":" & CStr(copy.X) & ":" & CStr(copy.Y) & ":" & CStr(empty.Z)
End Sub
```

**Parameter and execution notes:**

Main creates original with X=1445 and Y=1690; Z remains 0. copy receives the value, then copy.X += 2 changes only the copy. New Position() creates empty with Z=0. The four returned fields explain the exact result 1445:1447:1690:0. These are stored coordinates; this script does not move the character.

### 2. Nested route, ByVal and ByRef

```vb
# Route contains Start and Finish of type Position. Shift(point ByVal, dx ByVal) adds dx to the copied point.X and returns that Position. With point:=route.Start and dx:=5, shifted.X becomes 15 while route.Start.X stays 10. Advance(route ByRef, dx ByVal) adds 4 to Finish.X and writes the Route back, making 24. Main returns 10:15:24; every helper is shown.
Option Explicit On
Structure Position
    Public X As Integer
    Public Y As Integer
End Structure
Structure Route
    Public Start As Position
    Public Finish As Position
End Structure

Function Shift(ByVal point As Position, ByVal dx As Integer) As Position
    point.X += dx
    Return point
End Function

Sub Advance(ByRef route As Route, ByVal dx As Integer)
    route.Finish.X += dx
End Sub

Sub Main()
    Dim route As Route
    route.Start.X = 10
    route.Finish.X = 20
    Dim shifted = Shift(point:=route.Start, dx:=5)
    Advance(route:=route, dx:=4)
    Return CStr(route.Start.X) & ":" & CStr(shifted.X) & ":" & CStr(route.Finish.X)
End Sub
```

**Parameter and execution notes:**

Route contains Start and Finish of type Position. Shift(point ByVal, dx ByVal) adds dx to the copied point.X and returns that Position. With point:=route.Start and dx:=5, shifted.X becomes 15 while route.Start.X stays 10. Advance(route ByRef, dx ByVal) adds 4 to Finish.X and writes the Route back, making 24. Main returns 10:15:24; every helper is shown.

### 3. A saved value and a shared collection

```vb
# Entry contains Point as a nested value and Items as an Object. first.Point.X=2; first.Items receives List() with one string. snapshots.Add(first) saves the value. second=first, then second.Point.X=4 leaves the saved Point at 2. second.Items.Add("ingot") changes the shared List, so first.Items.Count() is 2. saved=snapshots[0] is the supported way to access the saved fields. Result: 2:4:2:2.
Option Explicit On
Structure Position
    Public X As Integer
End Structure
Structure Entry
    Public Point As Position
    Public Items As Object
End Structure

Sub Main()
    Dim first As Entry
    first.Point.X = 2
    first.Items = List()
    first.Items.Add("ore")
    Dim snapshots = List()
    snapshots.Add(first)

    Dim second = first
    second.Point.X = 4
    second.Items.Add("ingot")
    Dim saved = snapshots[0]
    Return CStr(first.Point.X) & ":" & CStr(second.Point.X) & ":" & CStr(saved.Point.X) & ":" & CStr(first.Items.Count())
End Sub
```

**Parameter and execution notes:**

Entry contains Point as a nested value and Items as an Object. first.Point.X=2; first.Items receives List() with one string. snapshots.Add(first) saves the value. second=first, then second.Point.X=4 leaves the saved Point at 2. second.Items.Add("ingot") changes the shared List, so first.Items.Count() is 2. saved=snapshots[0] is the supported way to access the saved fields. Result: 2:4:2:2.


### Internal functions: from call to result

Structure groups typed fields, such as X, Y and Z, into one value. This engine supports data structures with value copies; it does not implement the entire VB.NET Structure feature set.

#### 1. Build / PrepareDefault

Declarations are checked before initializers run. A script may declare at most 256 structure types, each with 1–256 fields; nesting is limited to 32 levels. Duplicate/unknown field types, cycles and excess limits produce SC030. Private names are checked during binding.

`declarations -> field types -> visibility -> cycle/depth checks -> immutable defaults`

Project source: `external/InjectionScript/src/InjectionScript/Runtime/StructureCatalog.cs`; function `Build / PrepareDefault`.

#### 2. VisitNewStructure

Dim value As TypeName and New TypeName() produce the default value without calling script code. New requires empty parentheses. It takes no X/Y/Z arguments: assign fields afterward. Dim copy = value infers the value; no UO. prefix is used.

`resolve TypeName -> prepared default value; no procedure call`

Project source: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.cs`; function `VisitNewStructure`.

#### 3. WithField / SetVar

Read or assign a field with a dot, including route.Start.X. Field assignment checks the declared type and replaces the containing value. copy = value copies scalar and nested structure values; modifying copy.X leaves value.X unchanged. Assign only compatible structure types.

`resolve path -> coerce field -> replace path -> assign new root value`

Project source: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/StructureObject.cs`; function `WithField / SetVar`.

#### 4. CreateArgumentWriter

ByVal passes a value copy. ByRef uses the engine’s copy-in/copy-out binding: updated values are written back to the caller, including a writable field argument. Use explicit modifiers; legacy unmodified parameters follow the existing Basic rules. Return can return a structure, and a Function can declare As TypeName.

`ByVal: value copy; ByRef: value copy -> callee -> caller slot write-back`

Project source: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.cs`; function `CreateArgumentWriter`.

#### 5. ValueEquals

This project additionally supports value equality: = compares the same declared type and corresponding fields; <> is its inverse. Reference fields compare identity. This is an engine extension, not a claim that arbitrary VB.NET structures support =. Cached hashes and a visited-pair set prevent repeated expansion of shared nested values.

`type identity -> cached hash -> distinct field pairs; reference members keep identity`

Project source: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/StructureObject.cs`; function `ValueEquals`.

The declaration and assignment statements have no result (Unit). New and structure-valued functions return a structure value, represented as Object in runtime observations; its display includes the declared type. Numeric coordinate fields are quantities, not Boolean flags. Structure = and <> comparisons return 1/True or 0/False. Example results are the Strings "1445:1447:1690:0", "10:15:24" and "2:4:2:2".

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: structureDeclaration / structureField / newStructure
Runtime/StructureCatalog.cs: Build / PrepareDefault
Runtime/ObjectTypes/StructureObject.cs: ReadField / WithField / ValueEquals
Runtime/BasicSyntaxPreprocessor.cs: NormalizeDim
Runtime/InjectionRuntime.cs: ScriptDeclarations / Load
Runtime/ScriptBindings.cs: Variable / CheckStructureType / CallName
Runtime/SemanticScope.cs: TryStructureRoot / SetVar / Coerce
Runtime/Interpreter.cs: VisitNewStructure / CreateArgumentWriter
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/structure-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/programming-guide/language-features/data-types/structure-variables
-->
