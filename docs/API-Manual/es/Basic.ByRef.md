# ByRef

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: es -->

Los parámetros pasan datos a SUB/FUNCTION. ByRef escribe el valor modificado en el llamador; ByVal conserva su variable. Optional proporciona un argumento omitido y ParamArray agrupa los restantes. Son modificadores de declaración, no comandos invocables.

## Sintaxis exacta

```text
Sub Adjust(ByRef amount, ByVal increment)
Adjust(amount, 3)
Bump(items[index])
Function name(ByRef value As type)
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

### 1. Cambiar una variable

```vb
# Adjust recibe amount=5 mediante ByRef e increment=3 mediante ByVal. amount pasa a 8 y se escribe de vuelta. Main devuelve Integer 8; Adjust no tiene resultado.
Option Explicit On
Sub Adjust(ByRef amount, ByVal increment)
    amount += increment
End Sub
Sub Main()
    Var amount = 5
    Adjust(amount, 3)
    Return amount
End Sub
```

**Explicación de los parámetros y la ejecución:**

Adjust recibe amount=5 mediante ByRef e increment=3 mediante ByVal. amount pasa a 8 y se escribe de vuelta. Main devuelve Integer 8; Adjust no tiene resultado.

### 2. Calcular el índice una vez

```vb
# items[0]=5. NextIndex incrementa calls y devuelve 0; Bump cambia ese elemento a 6. No se calcula dos veces: calls=1. Main devuelve 6*100+1, Integer 601.
Option Explicit On
Function NextIndex(ByRef calls)
    calls += 1
    Return 0
End Function
Sub Bump(ByRef amount)
    amount += 1
End Sub
Sub Main()
    Dim items[0]
    items[0] = 5
    Var calls = 0
    Bump(items[NextIndex(calls)])
    Return items[0] * 100 + calls
End Sub
```

**Explicación de los parámetros y la ejecución:**

items[0]=5. NextIndex incrementa calls y devuelve 0; Bump cambia ese elemento a 6. No se calcula dos veces: calls=1. Main devuelve 6*100+1, Integer 601.

### 3. Una variable, dos parámetros

```vb
# Ambos reciben 5. first pasa a 6 y second a 7. Al salir se escribe 6 y después 7 en value. Main devuelve Integer 7, no 8.
Option Explicit On
Sub Change(ByRef first, ByRef second)
    first += 1
    second += 2
End Sub
Sub Main()
    Var value = 5
    Change(value, value)
    Return value
End Sub
```

**Explicación de los parámetros y la ejecución:**

Ambos reciben 5. first pasa a 6 y second a 7. Al salir se escribe 6 y después 7 en value. Main devuelve Integer 7, no 8.

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
