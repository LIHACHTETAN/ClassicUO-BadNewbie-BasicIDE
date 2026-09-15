# Class / New / Me / Property

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: en -->

Class groups per-object state and script methods. New creates a reference object; assigning it to another variable keeps the same object, unlike a Structure value copy. The examples below contain every constructor, method and property accessor they use.

## Exact syntax

```text
[Public | Private] Class TypeName
    [Public | Private | Dim] field As FieldType
    Public Sub New([parameters]) ... End Sub
    [Public | Private] Sub Method([parameters]) ... End Sub
    [Public | Private] Function Method([parameters]) As ResultType ... End Function
    [Public | Private] [ReadOnly | WriteOnly] Property Name[()] As ValueType
        Get ... Return value / Name = value / Exit Property ... End Get
        Set(ByVal value As ValueType) ... End Set
    End Property
    Public Property AutoName As ValueType
End Class
Dim instance [As TypeName] = New TypeName(arguments)
instance.Property = expression
value = instance.Property
instance.Method(arguments)
With instance ... End With
```

## Parameters

- `TypeName / Public / Private` — TypeName is a unique simple name at file or Module level; use ModuleName.TypeName outside its module. Class is Public by default. Private Class is available only in its Module. Inheritance, interfaces, generics, nested classes, Shared members, overloads, destructors and instance Event declarations are not implemented.
- `field As FieldType / Me` — Fields require As Integer, Double, Boolean, String, Object, a declared Enum, Structure or Class (the existing Basic type aliases also work). Fields are Private by default; explicitly use Public to expose one. Numeric/Boolean defaults are 0, String is empty, Structure has zero fields, Object/Class is Nothing (Unit). Initialize other values in Sub New. Me is the current instance and cannot be reassigned or redeclared; parameters/locals can shadow other member names.
- `New / Sub New` — New TypeName(arguments) creates separate field storage and runs Public Sub New once. Without a constructor only New TypeName() is valid. Only one constructor is supported; normal Optional/default and named-argument rules apply. Constructor arguments are evaluated once in written order; validation errors prevent returning a constructed object. A variable declared As TypeName alone remains Nothing.
- `Sub / Function / arguments` — Instance methods use Sub or Function. Call instance.Method(...), or an unqualified method name/Me.Method(...) inside the Class. Private methods are callable only from that Class, including on another instance of the same Class. Existing typed parameters, ByVal/ByRef, Optional, ParamArray and named arguments work; named ParamArray items remain unsupported. Function returns its declared type; Sub returns Unit. Static TypeName.Method(...) and calling instance.New(...) are invalid. AddressOf requires a file/module wrapper for instance methods.
- `Property / Get / Set` — Property Name[()] As ValueType has no index parameters. Read instance.Name without call parentheses. Get returns a value through Return or assignment to Name; Exit Property returns that value/default. Assignment instance.Name=expression runs Set(ByVal value As ValueType), without calling the final getter. A normal property requires one Get and one Set; put visibility on Property, not on individual accessors. Set must explicitly declare one ByVal parameter with the same type.
- `ReadOnly / WriteOnly / auto Property` — ReadOnly with a body requires only Get; WriteOnly requires only Set. Reading WriteOnly or writing ReadOnly raises a catchable script error. An auto property has no Get/Set body or End Property and stores a value directly. ReadOnly auto properties may be assigned only in that instance’s Sub New; an auto WriteOnly property is invalid. A read-only property returning a Class reference still permits changing that object’s mutable members.
- `ByVal / ByRef / With` — ByVal copies the reference: changing members affects the original object, while replacing the parameter does not replace the caller variable. ByRef copies the value back, including a replacement reference, according to the engine’s existing copy-in/copy-out rules. Reference equality uses object identity. With instance captures its object once and supports fields, properties and methods. A Class is not automatically IDisposable; use Using on the supported resource objects themselves.

## Returns

New returns Object containing a Class reference, not a UO serial or graphic. Property reads and Function calls return their declared value type; setters, Sub and declarations return Unit. Class variables without New hold Nothing. Equality of references and As Boolean results use 1/True or 0/False; Integer amounts are not automatically success flags. Main returns "5:2:1", "1:0:6" and "ore:1:replacement:0" in the three examples.

## Behavior

- SC032 rejects invalid class/member declarations before execution, even without Option Explicit. Limits: 256 classes, 256 fields/properties and 256 methods per class; 32 nested script calls, including constructors and accessors. Assignment/ByRef member paths are limited to 64 components. Class reference cycles are allowed; metadata/defaults are cached, mutable field slots belong to each new instance.
- Receiver paths are captured before RHS or argument effects; each getter in that path is evaluated once. Copy-out keeps the original target even if a procedure replaces a variable used in the path. Stored values are coerced to the declared type. An error or Throw in a constructor, method or accessor follows ordinary Try/Catch rules; already performed changes are not rolled back.
- Pause, stop, source locations and call-depth protection use normal script frames. Merely closing IDE does not stop the root script. The inspector displays a bounded type/member summary without running getters or following cycles. Watch expressions may read stored fields/auto properties but cannot run custom getters, methods or constructors. This is a scripting subset, not arbitrary .NET classes.

## Examples

### 1. Independent objects and a shared reference

```vb
# New Counter(label:="ore", start:=2) binds the String label and Integer start; the constructor sets Label and stored. second gets separate storage. alias=first copies a reference. Add(amount:=3) writes through Value.Set, which checks for a negative value, then returns Value.Get as Integer. first becomes 5, second stays 2, and alias=first is 1/True. Every helper and accessor is included.
Option Explicit On
Class Counter
    Private stored As Integer
    Public Property Label As String
    Public Sub New(ByVal label As String, ByVal start As Integer)
        Me.Label = label
        stored = start
    End Sub
    Public Property Value As Integer
        Get
            Return stored
        End Get
        Set(ByVal value As Integer)
            If value < 0 Then
                Throw "Value must be non-negative"
            End If
            stored = value
        End Set
    End Property
    Public Function Add(ByVal amount As Integer) As Integer
        Me.Value = stored + amount
        Return Me.Value
    End Function
End Class

Sub Main()
    Dim first = New Counter(label:="ore", start:=2)
    Dim second = New Counter("wood", 2)
    Dim alias = first
    alias.Add(amount:=3)
    Return CStr(first.Value) & ":" & CStr(second.Value) & ":" & CStr(alias = first)
End Sub
```

**Parameter and execution notes:**

New Counter(label:="ore", start:=2) binds the String label and Integer start; the constructor sets Label and stored. second gets separate storage. alias=first copies a reference. Add(amount:=3) writes through Value.Set, which checks for a negative value, then returns Value.Get as Integer. first becomes 5, second stays 2, and alias=first is 1/True. Every helper and accessor is included.

### 2. Read-only result, write-only input and Boolean return

```vb
# budget.Limit=10 calls Set with value=10. Remaining.Get exposes amount without a setter and demonstrates assignment to the property result plus Exit Property. TrySpend(cost:=4) subtracts four and returns 1/True; cost 9 exceeds six and returns 0/False. Limit=-3 throws before storing anything; Catch reads Remaining=6. Therefore Main returns "1:0:6", with no server actions.
Option Explicit On
Class Budget
    Private amount As Integer
    Public ReadOnly Property Remaining() As Integer
        Get
            Remaining = amount
            Exit Property
        End Get
    End Property
    Public WriteOnly Property Limit As Integer
        Set(ByVal value As Integer)
            If value < 0 Then
                Throw "Limit must be non-negative"
            End If
            amount = value
        End Set
    End Property
    Public Function TrySpend(ByVal cost As Integer) As Boolean
        If cost < 0 Then
            Throw "cost must be non-negative"
        End If
        If cost > amount Then
            Return False
        End If
        amount -= cost
        Return True
    End Function
End Class

Sub Main()
    Dim budget = New Budget()
    budget.Limit = 10
    Dim paid = budget.TrySpend(4)
    Dim refused = budget.TrySpend(9)
    Try
        budget.Limit = -3
    Catch problem
        Return CStr(paid) & ":" & CStr(refused) & ":" & CStr(budget.Remaining)
    End Try
    Return "unexpected"
End Sub
```

**Parameter and execution notes:**

budget.Limit=10 calls Set with value=10. Remaining.Get exposes amount without a setter and demonstrates assignment to the property result plus Exit Property. TrySpend(cost:=4) subtracts four and returns 1/True; cost 9 exceeds six and returns 0/False. Limit=-3 throws before storing anything; Catch reads Remaining=6. Therefore Main returns "1:0:6", with no server actions.

### 3. Module names, ByVal mutation and ByRef replacement

```vb
# Jobs.WorkItem(name) stores a String Name and initializes Done to zero. Tick(ByVal job) increments the shared object to Done=1, then replaces only its local parameter with "local". Replace(ByRef job, ByVal name) creates "replacement" and copies that reference back to the caller; the named arguments are deliberately reversed. original still points to "ore" with Done=1; job points to a fresh object with Done=0. All functions are shown in Module Jobs.
Option Explicit On
Module Jobs
    Public Class WorkItem
        Public Property Name As String
        Public Done As Integer
        Public Sub New(ByVal name As String)
            Me.Name = name
        End Sub
    End Class
    Public Sub Tick(ByVal job As WorkItem)
        job.Done += 1
        job = New WorkItem("local")
    End Sub
    Public Sub Replace(ByRef job As WorkItem, ByVal name As String)
        job = New WorkItem(name)
    End Sub
End Module

Sub Main()
    Dim job As Jobs.WorkItem = New Jobs.WorkItem("ore")
    Dim original = job
    Jobs.Tick(job)
    Jobs.Replace(name:="replacement", job:=job)
    Return original.Name & ":" & CStr(original.Done) & ":" & job.Name & ":" & CStr(job.Done)
End Sub
```

**Parameter and execution notes:**

Jobs.WorkItem(name) stores a String Name and initializes Done to zero. Tick(ByVal job) increments the shared object to Done=1, then replaces only its local parameter with "local". Replace(ByRef job, ByVal name) creates "replacement" and copies that reference back to the caller; the named arguments are deliberately reversed. original still points to "ore" with Done=1; job points to a fresh object with Done=0. All functions are shown in Module Jobs.


### Internal functions: from call to result

Class groups per-object state and script methods. New creates a reference object; assigning it to another variable keeps the same object, unlike a Structure value copy. The examples below contain every constructor, method and property accessor they use.

#### 1. ClassCatalog.Build / Complete

SC032 rejects invalid class/member declarations before execution, even without Option Explicit. Limits: 256 classes, 256 fields/properties and 256 methods per class; 32 nested script calls, including constructors and accessors. Assignment/ByRef member paths are limited to 64 components. Class reference cycles are allowed; metadata/defaults are cached, mutable field slots belong to each new instance.

`declarations -> unique typed members -> accessor validation -> prepared metadata; SC032 on invalid Class`

Project source: `external/InjectionScript/src/InjectionScript/Runtime/ClassCatalog.cs`; function `ClassCatalog.Build / Complete`.

#### 2. ConstructClass

New TypeName(arguments) creates separate field storage and runs Public Sub New once. Without a constructor only New TypeName() is valid. Only one constructor is supported; normal Optional/default and named-argument rules apply. Constructor arguments are evaluated once in written order; validation errors prevent returning a constructed object. A variable declared As TypeName alone remains Nothing.

`new instance -> independent field slots -> bind constructor arguments -> Sub New -> Object reference`

Project source: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Classes.cs`; function `ConstructClass`.

#### 3. ClassObject.Member / Read

Property Name[()] As ValueType has no index parameters. Read instance.Name without call parentheses. Get returns a value through Return or assignment to Name; Exit Property returns that value/default. Assignment instance.Name=expression runs Set(ByVal value As ValueType), without calling the final getter. A normal property requires one Get and one Set; put visibility on Property, not on individual accessors. Set must explicitly declare one ByVal parameter with the same type.

`check member visibility -> stored value OR Get frame -> declared value type`

Project source: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ClassObject.cs`; function `ClassObject.Member / Read`.

#### 4. MemberAccess.Resolve / ClassObject.Write

Receiver paths are captured before RHS or argument effects; each getter in that path is evaluated once. Copy-out keeps the original target even if a procedure replaces a variable used in the path. Stored values are coerced to the declared type. An error or Throw in a constructor, method or accessor follows ordinary Try/Catch rules; already performed changes are not rolled back.

`capture receiver once -> evaluate RHS/arguments -> coerce value -> Set OR stored slot`

Project source: `external/InjectionScript/src/InjectionScript/Runtime/MemberAccess.cs`; function `MemberAccess.Resolve / ClassObject.Write`.

#### 5. CallClassMethod / CallSubrutine

Instance methods use Sub or Function. Call instance.Method(...), or an unqualified method name/Me.Method(...) inside the Class. Private methods are callable only from that Class, including on another instance of the same Class. Existing typed parameters, ByVal/ByRef, Optional, ParamArray and named arguments work; named ParamArray items remain unsupported. Function returns its declared type; Sub returns Unit. Static TypeName.Method(...) and calling instance.New(...) are invalid. AddressOf requires a file/module wrapper for instance methods.

`check method visibility -> bind named/positional arguments -> Me frame -> return -> ByRef copy-out`

Project source: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Classes.cs`; function `CallClassMethod / CallSubrutine`.

#### 6. ClassObject.DisplayValue

Pause, stop, source locations and call-depth protection use normal script frames. Merely closing IDE does not stop the root script. The inspector displays a bounded type/member summary without running getters or following cycles. Watch expressions may read stored fields/auto properties but cannot run custom getters, methods or constructors. This is a scripting subset, not arbitrary .NET classes.

`debugger: type + member count; no getter calls and no traversal of reference cycles`

Project source: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ClassObject.cs`; function `ClassObject.DisplayValue`.

New returns Object containing a Class reference, not a UO serial or graphic. Property reads and Function calls return their declared value type; setters, Sub and declarations return Unit. Class variables without New hold Nothing. Equality of references and As Boolean results use 1/True or 0/False; Integer amounts are not automatically success flags. Main returns "5:2:1", "1:0:6" and "ore:1:replacement:0" in the three examples.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: classDeclaration / classProperty / subrutine / newStructure
Runtime/ClassCatalog.cs: Build / Complete
Runtime/ObjectTypes/ClassObject.cs: Member / Read / Write
Runtime/Interpreter.Classes.cs: ConstructClass / CallClassMethod / InvokeAccessor
Runtime/MemberAccess.cs: Resolve / Read / Write
Runtime/SemanticScope.cs: TryMemberSlot / Coerce
Runtime/Interpreter.cs: CallSubrutine / CreateArgumentWriter
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/class-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/property-statement
-->
