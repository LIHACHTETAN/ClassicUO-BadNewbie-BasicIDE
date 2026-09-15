# Class / New / Me / Property

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: es -->

Class agrupa el estado y los métodos de cada objeto. New crea una referencia: asignarla a otra variable conserva el mismo objeto, a diferencia de una copia de Structure. Los ejemplos incluyen todos sus constructores, métodos y accesores.

## Sintaxis exacta

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

## Parámetros

- `TypeName / Public / Private` — TypeName es un nombre simple único a nivel de archivo o Module; fuera use ModuleName.TypeName. Class es Public por defecto; Private Class solo pertenece a su Module. No se implementan herencia, interfaces, genéricos, clases anidadas, Shared, sobrecargas, destructores ni declaraciones Event de instancia.
- `field As FieldType / Me` — Cada campo exige As Integer, Double, Boolean, String, Object o un Enum, Structure, Class declarado; también funcionan los alias Basic existentes. Los campos son Private por defecto; el acceso externo requiere Public explícito. Valores iniciales: números/Boolean 0, String vacío, Structure con campos cero, Object/Class Nothing (Unit). Inicialice otros valores en Sub New. Me identifica la instancia y no puede reasignarse/redeclararse; los nombres locales pueden ocultar otros miembros.
- `New / Sub New` — New TypeName(arguments) crea campos independientes y ejecuta Public Sub New una vez. Sin constructor solo admite New TypeName(). Hay un constructor; Optional, valores predeterminados y argumentos nombrados siguen las reglas normales. Los argumentos se evalúan una vez en orden de escritura; un error impide devolver el objeto creado. As TypeName sin New conserva Nothing.
- `Sub / Function / arguments` — Sub/Function se invocan como instance.Method(...); dentro de la clase también Method(...)/Me.Method(...). Private solo permite acceso desde esa Class, incluso a otra instancia del mismo tipo. Se admiten tipos, ByVal/ByRef, Optional, ParamArray y argumentos nombrados, pero no elementos nombrados de ParamArray. Function devuelve su tipo; Sub Unit. TypeName.Method(...) e instance.New(...) no son válidos; AddressOf requiere un procedimiento envolvente de archivo/módulo.
- `Property / Get / Set` — Property Name[()] As ValueType no admite índices. Lea instance.Name sin paréntesis. Get devuelve Return o lo asignado a Name; Exit Property devuelve ese resultado/valor predeterminado. La asignación invoca Set(ByVal value As ValueType) sin leer el Get final. La propiedad ordinaria requiere un Get y un Set. Declare visibilidad en Property; Set exige un parámetro ByVal explícito del mismo tipo.
- `ReadOnly / WriteOnly / auto Property` — ReadOnly con cuerpo contiene solo Get; WriteOnly solo Set. El acceso prohibido provoca un error capturable. Una propiedad automática almacena sin Get/Set ni End Property; su versión ReadOnly solo puede asignarse en Sub New de esa instancia. WriteOnly sin Set no es válido. Una propiedad ReadOnly que devuelve Class permite cambiar los miembros mutables del objeto devuelto.
- `ByVal / ByRef / With` — ByVal copia la referencia: los cambios de miembros afectan al original, reemplazar el parámetro no reemplaza la variable del llamador. ByRef copia de vuelta también una referencia nueva conforme a copy-in/copy-out. La igualdad compara identidad. With instance captura el objeto una vez y admite campos, propiedades y métodos. Class no es IDisposable automáticamente; Using se aplica a los recursos admitidos.

## Devuelve

New devuelve Object con referencia Class, no ID/gráfico UO. Get y Function devuelven el tipo declarado; Set, Sub y declaraciones Unit. Sin New: Nothing. La igualdad de referencias y As Boolean usan 1/True o 0/False; las cantidades Integer no indican automáticamente éxito. Main devuelve "5:2:1", "1:0:6", "ore:1:replacement:0".

## Comportamiento

- SC032 rechaza declaraciones incorrectas antes de ejecutar, incluso sin Option Explicit. Límites: 256 clases, 256 campos/propiedades y 256 métodos por clase; 32 llamadas anidadas contando New/Get/Set. Rutas de asignación/ByRef: 64 componentes. Se permiten ciclos de referencias; metadatos/valores iniciales se preparan y cada New recibe almacenamiento mutable independiente.
- La ruta del receptor se captura antes del lado derecho/argumentos; cada Get de la ruta se evalúa una vez. La copia de vuelta conserva el destino inicial aunque un procedimiento sustituya una variable intermedia. El valor se convierte al tipo declarado. Try/Catch captura errores de constructor, métodos y accesores; no revierte cambios previos.
- Pausa, parada, líneas y límite de profundidad usan los marcos normales del script. Cerrar IDE no detiene el script. El inspector muestra tipo/cantidad de miembros sin Get ni recorrer ciclos. Watch lee campos/propiedades automáticas, pero no ejecuta Get personalizados, métodos ni constructores. Es el subconjunto descrito, no clases .NET arbitrarias.

## Ejemplos

### 1. Objetos independientes y referencia compartida

```vb
# New Counter(label:="ore", start:=2) recibe String label e Integer start y establece Label/stored. second tiene campos separados; alias=first copia una referencia. Add(amount:=3) escribe mediante Value.Set, comprueba negativos y devuelve Integer desde Value.Get. first queda en 5, second en 2 y alias=first es 1/True. Todos los métodos están incluidos.
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

**Explicación de los parámetros y la ejecución:**

New Counter(label:="ore", start:=2) recibe String label e Integer start y establece Label/stored. second tiene campos separados; alias=first copia una referencia. Add(amount:=3) escribe mediante Value.Set, comprueba negativos y devuelve Integer desde Value.Get. first queda en 5, second en 2 y alias=first es 1/True. Todos los métodos están incluidos.

### 2. Lectura, escritura y Boolean

```vb
# Limit=10 llama a Set con value=10. Remaining.Get asigna el nombre de resultado y usa Exit Property. TrySpend(cost:=4) resta cuatro y devuelve 1/True; cost=9 supera los seis restantes y devuelve 0/False. Limit=-3 lanza antes de modificar; Catch lee Remaining=6. Main produce "1:0:6" sin acciones de servidor.
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

**Explicación de los parámetros y la ejecución:**

Limit=10 llama a Set con value=10. Remaining.Get asigna el nombre de resultado y usa Exit Property. TrySpend(cost:=4) resta cuatro y devuelve 1/True; cost=9 supera los seis restantes y devuelve 0/False. Limit=-3 lanza antes de modificar; Catch lee Remaining=6. Main produce "1:0:6" sin acciones de servidor.

### 3. Module, ByVal y reemplazo ByRef

```vb
# Jobs.WorkItem(name) guarda String Name y Done empieza en cero. Tick(ByVal job) incrementa el Done compartido a 1, pero su reemplazo por "local" solo es local. Replace(ByRef job, ByVal name) crea "replacement" y copia la referencia al llamador; los argumentos nombrados se escriben al revés intencionalmente. original sigue "ore"/1, job es "replacement"/0. Module Jobs aparece completo.
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

**Explicación de los parámetros y la ejecución:**

Jobs.WorkItem(name) guarda String Name y Done empieza en cero. Tick(ByVal job) incrementa el Done compartido a 1, pero su reemplazo por "local" solo es local. Replace(ByRef job, ByVal name) crea "replacement" y copia la referencia al llamador; los argumentos nombrados se escriben al revés intencionalmente. original sigue "ore"/1, job es "replacement"/0. Module Jobs aparece completo.


### Funciones internas: de la llamada al resultado

Class agrupa el estado y los métodos de cada objeto. New crea una referencia: asignarla a otra variable conserva el mismo objeto, a diferencia de una copia de Structure. Los ejemplos incluyen todos sus constructores, métodos y accesores.

#### 1. ClassCatalog.Build / Complete

SC032 rechaza declaraciones incorrectas antes de ejecutar, incluso sin Option Explicit. Límites: 256 clases, 256 campos/propiedades y 256 métodos por clase; 32 llamadas anidadas contando New/Get/Set. Rutas de asignación/ByRef: 64 componentes. Se permiten ciclos de referencias; metadatos/valores iniciales se preparan y cada New recibe almacenamiento mutable independiente.

`declarations -> unique typed members -> accessor validation -> prepared metadata; SC032 on invalid Class`

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/ClassCatalog.cs`; función `ClassCatalog.Build / Complete`.

#### 2. ConstructClass

New TypeName(arguments) crea campos independientes y ejecuta Public Sub New una vez. Sin constructor solo admite New TypeName(). Hay un constructor; Optional, valores predeterminados y argumentos nombrados siguen las reglas normales. Los argumentos se evalúan una vez en orden de escritura; un error impide devolver el objeto creado. As TypeName sin New conserva Nothing.

`new instance -> independent field slots -> bind constructor arguments -> Sub New -> Object reference`

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Classes.cs`; función `ConstructClass`.

#### 3. ClassObject.Member / Read

Property Name[()] As ValueType no admite índices. Lea instance.Name sin paréntesis. Get devuelve Return o lo asignado a Name; Exit Property devuelve ese resultado/valor predeterminado. La asignación invoca Set(ByVal value As ValueType) sin leer el Get final. La propiedad ordinaria requiere un Get y un Set. Declare visibilidad en Property; Set exige un parámetro ByVal explícito del mismo tipo.

`check member visibility -> stored value OR Get frame -> declared value type`

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ClassObject.cs`; función `ClassObject.Member / Read`.

#### 4. MemberAccess.Resolve / ClassObject.Write

La ruta del receptor se captura antes del lado derecho/argumentos; cada Get de la ruta se evalúa una vez. La copia de vuelta conserva el destino inicial aunque un procedimiento sustituya una variable intermedia. El valor se convierte al tipo declarado. Try/Catch captura errores de constructor, métodos y accesores; no revierte cambios previos.

`capture receiver once -> evaluate RHS/arguments -> coerce value -> Set OR stored slot`

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/MemberAccess.cs`; función `MemberAccess.Resolve / ClassObject.Write`.

#### 5. CallClassMethod / CallSubrutine

Sub/Function se invocan como instance.Method(...); dentro de la clase también Method(...)/Me.Method(...). Private solo permite acceso desde esa Class, incluso a otra instancia del mismo tipo. Se admiten tipos, ByVal/ByRef, Optional, ParamArray y argumentos nombrados, pero no elementos nombrados de ParamArray. Function devuelve su tipo; Sub Unit. TypeName.Method(...) e instance.New(...) no son válidos; AddressOf requiere un procedimiento envolvente de archivo/módulo.

`check method visibility -> bind named/positional arguments -> Me frame -> return -> ByRef copy-out`

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Classes.cs`; función `CallClassMethod / CallSubrutine`.

#### 6. ClassObject.DisplayValue

Pausa, parada, líneas y límite de profundidad usan los marcos normales del script. Cerrar IDE no detiene el script. El inspector muestra tipo/cantidad de miembros sin Get ni recorrer ciclos. Watch lee campos/propiedades automáticas, pero no ejecuta Get personalizados, métodos ni constructores. Es el subconjunto descrito, no clases .NET arbitrarias.

`debugger: type + member count; no getter calls and no traversal of reference cycles`

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ClassObject.cs`; función `ClassObject.DisplayValue`.

New devuelve Object con referencia Class, no ID/gráfico UO. Get y Function devuelven el tipo declarado; Set, Sub y declaraciones Unit. Sin New: Nothing. La igualdad de referencias y As Boolean usan 1/True o 0/False; las cantidades Integer no indican automáticamente éxito. Main devuelve "5:2:1", "1:0:6", "ore:1:replacement:0".

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
