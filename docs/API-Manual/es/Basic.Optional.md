# Optional

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: es -->

Los parámetros pasan datos a SUB/FUNCTION. ByRef escribe el valor modificado en el llamador; ByVal conserva su variable. Optional proporciona un argumento omitido y ParamArray agrupa los restantes. Son modificadores de declaración, no comandos invocables.

## Sintaxis exacta

```text
Function Scale(ByVal value, Optional ByVal factor = 2)
Scale(3)
Scale(3, 4)
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

### 1. Factor omitido o explícito

```vb
# Scale(3) usa factor=2 y devuelve 6. Scale(3,4) usa 4 y devuelve 12. Main devuelve 6*100+12, Integer 612.
Option Explicit On
Function Scale(ByVal value, Optional ByVal factor = 2)
    Return value * factor
End Function
Sub Main()
    Return Scale(3) * 100 + Scale(3, 4)
End Sub
```

**Explicación de los parámetros y la ejecución:**

Scale(3) usa factor=2 y devuelve 6. Scale(3,4) usa 4 y devuelve 12. Main devuelve 6*100+12, Integer 612.

### 2. Cuándo se evalúa el valor predeterminado

```vb
# Pick(5) devuelve 5 sin llamar a DefaultAmount. Pick() lo llama una vez: calls=1, valor 7. Main devuelve 5*100+7*10+1, Integer 571.
Option Explicit On
Module Counter
    Public Var calls = 0
End Module
Function DefaultAmount()
    Counter.calls += 1
    Return 7
End Function
Function Pick(Optional ByVal value = DefaultAmount())
    Return value
End Function
Sub Main()
    Var first = Pick(5)
    Var second = Pick()
    Return first * 100 + second * 10 + Counter.calls
End Sub
```

**Explicación de los parámetros y la ejecución:**

Pick(5) devuelve 5 sin llamar a DefaultAmount. Pick() lo llama una vez: calls=1, valor 7. Main devuelve 5*100+7*10+1, Integer 571.

### 3. Optional, ByRef y As Integer

```vb
# value empieza en 1. Increase(value) suma amount=2 y guarda 3; Increase(value,4) suma 4 y guarda 7. Ambos parámetros son Integer. Main devuelve Integer 7.
Option Explicit On
Sub Increase(ByRef value As Integer, Optional ByVal amount As Integer = 2)
    value += amount
End Sub
Sub Main()
    Var value As Integer = 1
    Increase(value)
    Increase(value, 4)
    Return value
End Sub
```

**Explicación de los parámetros y la ejecución:**

value empieza en 1. Increase(value) suma amount=2 y guarda 3; Increase(value,4) suma 4 y guarda 7. Ambos parámetros son Integer. Main devuelve Integer 7.

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
