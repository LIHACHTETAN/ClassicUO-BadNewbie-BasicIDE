# ParamArray

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: es -->

Los parámetros pasan datos a SUB/FUNCTION. ByRef escribe el valor modificado en el llamador; ByVal conserva su variable. Optional proporciona un argumento omitido y ParamArray agrupa los restantes. Son modificadores de declaración, no comandos invocables.

## Sintaxis exacta

```text
Function Sum(ParamArray values())
Sum()
Sum(2, 3, 4)
Sum(existingArray)
```

## Parámetros

- `name / As type` — name / As type: Nombre del parámetro y conversión opcional de entrada con As. Argumentos por posición o name:=value; los modificadores van en la declaración. Véase Basic.NamedArguments.
- `ByRef` — ByRef: variable modificable o elemento indexado existente. Sin ByVal este motor también escribe de vuelta, a diferencia del valor predeterminado de VB.NET. Literales, constantes y expresiones calculadas son temporales.
- `ByVal` — ByVal: copia local del valor. Asignar al parámetro no reemplaza la variable del llamador. Matrices y objetos siguen compartiendo referencias; no es una copia profunda.
- `Optional / defaultValue` — Optional / defaultValue: omitir un argumento final evalúa su expresión tras =. Indique un valor explícito; sin él, el parámetro omitido recibe Unit sin inicializar.
- `ParamArray` — ParamArray values(): último parámetro para cero o más valores restantes. Una sola matriz se reutiliza directamente; los escalares crean una nueva. GetArrayLength devuelve su longitud.

## Devuelve

Los modificadores no devuelven valores. RETURN establece el resultado por separado. ByRef cambia un argumento, no el resultado. SUB sin RETURN produce Unit. Los números de los ejemplos son cálculos, no indicadores TRUE/FALSE.

## Comportamiento

- Los argumentos se evalúan una vez, de izquierda a derecha. ByRef indexado captura contenedor e índice/clave; reasignar la variable del contenedor desde otro argumento no redirige la escritura.
- Al entrar se crean parámetros locales. Al salir, después de los FINALLY internos, ByRef escribe en orden de parámetros, también si un error sale del cuerpo. Dos parámetros de una misma variable no son alias vivos: prevalece la última escritura.
- ByVal impide reemplazar la variable del llamador, pero permite modificar la matriz u objeto compartido. ReDim crea una nueva referencia local. Los datos independientes requieren una copia explícita.
- En llamadas posicionales: Omita argumentos Optional desde el final; no se admiten posiciones vacías entre comas. Los valores predeterminados pueden ser expresiones del motor evaluadas en cada omisión, no necesariamente constantes VB.NET. Primero van los argumentos posicionales; después del primer argumento con nombre, todos deben tener nombre. No omita parámetros obligatorios. Los Optional omitidos del script usan sus valores declarados, evaluados en orden de declaración después de las expresiones suministradas. Las sobrecargas nativas solo admiten sus nombres y aridad registrados, sin valores predeterminados inventados.
- ParamArray no escribe los escalares agrupados en sus variables originales. Modificar una matriz suministrada explícitamente sí es visible al llamador. Pasarla a otro ParamArray no añade anidamiento.
- Escriba ByRef y ByVal explícitamente. Estas reglas describen procedimientos del usuario llamados desde el script; los comandos integrados tienen fichas propias.
- ParamArray no admite nombre. Puede quedar vacío en llamadas con nombres; sus valores requieren una llamada totalmente posicional. No se admiten posiciones vacías entre comas. Este subconjunto exige posicionales primero, sin la mezcla libre de VB.NET recientes. No crea hilos ni modifica las demoras del juego.

## Ejemplos

### 1. Argumentos vacíos o presentes

```vb
# Sum() recibe una matriz vacía y devuelve 0. Sum(2,3,4) recibe tres valores y devuelve 9. For Each los recorre. Main devuelve Integer 9.
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

**Explicación de los parámetros y la ejecución:**

Sum() recibe una matriz vacía y devuelve 0. Sum(2,3,4) recibe tres valores y devuelve 9. For Each los recorre. Main devuelve Integer 9.

### 2. Reenviar una matriz existente

```vb
# values contiene 2 y 5. Forward pasa la matriz a Sum sin otra envoltura. Sum devuelve su suma, Integer 7.
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

**Explicación de los parámetros y la ejecución:**

values contiene 2 y 5. Forward pasa la matriz a Sum sin otra envoltura. Sum devuelve su suma, Integer 7.

### 3. Escalares frente a matriz suministrada

```vb
# SetFirst(first,second) cambia una matriz nueva y conserva first=2 y second=3. SetFirst(packed) cambia packed[0] compartido de 4 a 9. Main devuelve 2*100+3*10+9, Integer 239.
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

**Explicación de los parámetros y la ejecución:**

SetFirst(first,second) cambia una matriz nueva y conserva first=2 y second=3. SetFirst(packed) cambia packed[0] compartido de 4 a 9. Main devuelve 2*100+3*10+9, Integer 239.

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
