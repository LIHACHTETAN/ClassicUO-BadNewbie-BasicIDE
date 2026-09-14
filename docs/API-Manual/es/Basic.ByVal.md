# ByVal

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: es -->

Los parámetros pasan datos a SUB/FUNCTION. ByRef escribe el valor modificado en el llamador; ByVal conserva su variable. Optional proporciona un argumento omitido y ParamArray agrupa los restantes. Son modificadores de declaración, no comandos invocables.

## Sintaxis exacta

```text
Sub Change(ByVal value)
Function Increment(ByVal value)
Increment(expression)
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

### 1. Conservar un escalar

```vb
# Change recibe una copia de amount=5. La asignación local 99 no cambia la variable exterior. Main devuelve Integer 5.
Option Explicit On
Sub Change(ByVal amount)
    amount = 99
End Sub
Sub Main()
    Var amount = 5
    Change(amount)
    Return amount
End Sub
```

**Explicación de los parámetros y la ejecución:**

Change recibe una copia de amount=5. La asignación local 99 no cambia la variable exterior. Main devuelve Integer 5.

### 2. Matriz compartida y ReDim local

```vb
# ByVal todavía comparte el elemento, que pasa a 9. ReDim crea otra matriz local; 20 se escribe solo allí. La matriz exterior conserva longitud 1 y valor 9. Main devuelve Integer 91.
Option Explicit On
Sub Change(ByVal items)
    items[0] = 9
    ReDim items[1]
    items[0] = 20
End Sub
Sub Main()
    Dim items[0]
    items[0] = 4
    Change(items)
    Return items[0] * 10 + GetArrayLength(items)
End Sub
```

**Explicación de los parámetros y la ejecución:**

ByVal todavía comparte el elemento, que pasa a 9. ReDim crea otra matriz local; 20 se escribe solo allí. La matriz exterior conserva longitud 1 y valor 9. Main devuelve Integer 91.

### 3. Expresión y resultado separado

```vb
# amount+3 da 7. Increment cambia su valor local a 8 y lo devuelve. amount exterior sigue siendo 4. Main devuelve 4*10+8, Integer 48.
Option Explicit On
Function Increment(ByVal value)
    value += 1
    Return value
End Function
Sub Main()
    Var amount = 4
    Var result = Increment(amount + 3)
    Return amount * 10 + result
End Sub
```

**Explicación de los parámetros y la ejecución:**

amount+3 da 7. Increment cambia su valor local a 8 y lo devuelve. amount exterior sigue siendo 4. Main devuelve 4*10+8, Integer 48.

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
