# Structure / New / fields

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: es -->

Structure agrupa campos tipados, como X, Y y Z, en un valor. El motor admite estructuras de datos con copias por valor; no todo el conjunto Structure de VB.NET.

## Sintaxis exacta

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

## Parámetros

- `TypeName / Public / Private` — Nombre de tipo simple y único, a nivel de archivo o dentro de Module. Public por defecto. Private solo se permite dentro de Module; el nombre del tipo queda inaccesible fuera. Tipo público de módulo: ModuleName.TypeName. No se traducen palabras clave ni nombres de campos.
- `field / FieldType` — Nombre único del campo, As y un tipo escalar admitido, Enum u otra Structure. Campos públicos; se aceptan Public, Dim y VAR. Tipos: Integer/Long/Short/Byte, Single/Double/Decimal, String, Boolean/Bool, Object/Variant. Los alias enteros usan 32 bits con signo. Las estructuras anidadas no pueden formar ciclos.
- `Dim / New` — Dim value As TypeName y New TypeName() crean el valor predeterminado sin ejecutar código de usuario. New exige paréntesis vacíos: asigne X/Y/Z después. Dim copy = value toma el valor de la expresión. No usa prefijo UO.
- `value.field / copy` — El punto permite leer y escribir campos, incluido route.Start.X. La escritura comprueba el tipo y reemplaza el valor contenedor. copy = value copia valores escalares y estructuras anidadas: cambiar copy.X no altera value.X. Los tipos deben ser compatibles.
- `ByVal / ByRef` — ByVal pasa una copia. ByRef copia al entrar y escribe de vuelta al salir, incluso en un argumento de campo modificable. Especifique los modificadores; sin ellos se aplican las reglas Basic existentes. Return puede devolver una estructura; Function puede declarar As TypeName.

## Devuelve

Declaraciones y asignaciones devuelven Unit. New y funciones apropiadas devuelven un valor de estructura, representado como Object en observaciones con su nombre de tipo. Las coordenadas son cantidades, no indicadores Boolean. = y <> devuelven 1/True o 0/False. Resultados String: "1445:1447:1690:0", "10:15:24", "2:4:2:2".

## Comportamiento

- Se comprueban las declaraciones antes de los inicializadores: máximo 256 tipos, cada uno con 1–256 campos, y 32 niveles anidados. Duplicados, tipos desconocidos, ciclos y límites excedidos producen SC030. Private se comprueba al resolver los nombres.
- Campos predeterminados: entero/Enum 0, coma flotante 0, Boolean 0/False, String vacío, Object/Variant Unit antes de asignar. Las estructuras anidadas tienen sus propios valores predeterminados. No se admiten inicializadores de campo en la declaración: asigne después de crear.
- Los campos Object y arrays conservan referencias al copiar. Las copias pueden compartir List, Dictionary o array. Los valores escalares y estructuras anidadas cambian independientemente; modificar la colección compartida es visible en ambas copias. List conserva el valor de la estructura al añadirla.
- = compara el mismo tipo declarado y sus campos; <> es el inverso. Los campos de referencia comparan identidad. Es una extensión del motor, no una regla general de VB.NET. Los hashes guardados y las parejas ya visitadas evitan expandir repetidamente valores anidados compartidos.
- Se admiten campos públicos tipados, visibilidad Module, New(), asignación, parámetros y resultados. No se admiten métodos internos, constructores propios, inicializadores, propiedades, herencia ni campos privados. WITH .field y array[index].field no se admiten: lea en una variable, modifique y vuelva a escribir. Las declaraciones pueden estar en Include.

## Ejemplos

### 1. Coordenadas y copia independiente

```vb
# original recibe X=1445, Y=1690; Z queda en 0. copy toma el valor y copy.X += 2 cambia solo la copia. New Position() crea empty con Z=0. Resultado: 1445:1447:1690:0. Son coordenadas almacenadas; el script no mueve al personaje.
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

**Explicación de los parámetros y la ejecución:**

original recibe X=1445, Y=1690; Z queda en 0. copy toma el valor y copy.X += 2 cambia solo la copia. New Position() crea empty con Z=0. Resultado: 1445:1447:1690:0. Son coordenadas almacenadas; el script no mueve al personaje.

### 2. Ruta anidada, ByVal y ByRef

```vb
# Route contiene Start y Finish de tipo Position. Shift(point ByVal, dx ByVal) suma dx a X de la copia y devuelve Position. point:=route.Start, dx:=5 dan shifted.X=15, manteniendo Start.X=10. Advance(route ByRef, dx ByVal) suma 4 a Finish.X y escribe Route de vuelta: 24. Main devuelve 10:15:24. Se muestran todas las funciones auxiliares.
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

**Explicación de los parámetros y la ejecución:**

Route contiene Start y Finish de tipo Position. Shift(point ByVal, dx ByVal) suma dx a X de la copia y devuelve Position. point:=route.Start, dx:=5 dan shifted.X=15, manteniendo Start.X=10. Advance(route ByRef, dx ByVal) suma 4 a Finish.X y escribe Route de vuelta: 24. Main devuelve 10:15:24. Se muestran todas las funciones auxiliares.

### 3. Valor guardado y colección compartida

```vb
# Entry contiene Point como valor e Items como Object. first.Point.X=2; Items recibe List() con un texto. snapshots.Add(first) guarda el valor. second=first y second.Point.X=4 no cambian el 2 guardado. second.Items.Add("ingot") modifica la lista compartida: first.Items.Count()=2. saved=snapshots[0] permite acceder a los campos del elemento. Resultado: 2:4:2:2.
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

**Explicación de los parámetros y la ejecución:**

Entry contiene Point como valor e Items como Object. first.Point.X=2; Items recibe List() con un texto. snapshots.Add(first) guarda el valor. second=first y second.Point.X=4 no cambian el 2 guardado. second.Items.Add("ingot") modifica la lista compartida: first.Items.Count()=2. saved=snapshots[0] permite acceder a los campos del elemento. Resultado: 2:4:2:2.


### Funciones internas: de la llamada al resultado

Structure agrupa campos tipados, como X, Y y Z, en un valor. El motor admite estructuras de datos con copias por valor; no todo el conjunto Structure de VB.NET.

#### 1. Build / PrepareDefault

Se comprueban las declaraciones antes de los inicializadores: máximo 256 tipos, cada uno con 1–256 campos, y 32 niveles anidados. Duplicados, tipos desconocidos, ciclos y límites excedidos producen SC030. Private se comprueba al resolver los nombres.

`declarations -> field types -> visibility -> cycle/depth checks -> immutable defaults`

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/StructureCatalog.cs`; función `Build / PrepareDefault`.

#### 2. VisitNewStructure

Dim value As TypeName y New TypeName() crean el valor predeterminado sin ejecutar código de usuario. New exige paréntesis vacíos: asigne X/Y/Z después. Dim copy = value toma el valor de la expresión. No usa prefijo UO.

`resolve TypeName -> prepared default value; no procedure call`

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.cs`; función `VisitNewStructure`.

#### 3. WithField / SetVar

El punto permite leer y escribir campos, incluido route.Start.X. La escritura comprueba el tipo y reemplaza el valor contenedor. copy = value copia valores escalares y estructuras anidadas: cambiar copy.X no altera value.X. Los tipos deben ser compatibles.

`resolve path -> coerce field -> replace path -> assign new root value`

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/StructureObject.cs`; función `WithField / SetVar`.

#### 4. CreateArgumentWriter

ByVal pasa una copia. ByRef copia al entrar y escribe de vuelta al salir, incluso en un argumento de campo modificable. Especifique los modificadores; sin ellos se aplican las reglas Basic existentes. Return puede devolver una estructura; Function puede declarar As TypeName.

`ByVal: value copy; ByRef: value copy -> callee -> caller slot write-back`

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.cs`; función `CreateArgumentWriter`.

#### 5. ValueEquals

= compara el mismo tipo declarado y sus campos; <> es el inverso. Los campos de referencia comparan identidad. Es una extensión del motor, no una regla general de VB.NET. Los hashes guardados y las parejas ya visitadas evitan expandir repetidamente valores anidados compartidos.

`type identity -> cached hash -> distinct field pairs; reference members keep identity`

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/StructureObject.cs`; función `ValueEquals`.

Declaraciones y asignaciones devuelven Unit. New y funciones apropiadas devuelven un valor de estructura, representado como Object en observaciones con su nombre de tipo. Las coordenadas son cantidades, no indicadores Boolean. = y <> devuelven 1/True o 0/False. Resultados String: "1445:1447:1690:0", "10:15:24", "2:4:2:2".

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
