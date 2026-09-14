# Named arguments / :=

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: es -->

Los argumentos con nombre asignan valores a parámetros declarados sin depender de su orden. Funcionan con procedimientos, funciones, módulos, funciones Basic/UO registradas y métodos de objetos nativos.

## Sintaxis exacta

```text
FunctionName(parameterName:=expression, otherName:=expression)
FunctionName(positionalExpression, optionalName:=expression)
FunctionName([reservedName]:=expression)
```

## Parámetros

- `parameterName / [reservedName]` — Escriba name:=valor usando el nombre de la declaración o firma, sin distinguir mayúsculas. Encierre un nombre reservado: [to]:=100. Esos corchetes no son un índice de matriz. Los nombres desconocidos o duplicados provocan error.
- `expression` — Cada expresión suministrada se evalúa una vez de izquierda a derecha y se asigna al parámetro correspondiente. Se conservan los tipos, límites y ByVal/ByRef de la función. La notación no convierte un valor en variable modificable.
- `positionalExpression / optionalName` — Primero van los argumentos posicionales; después del primer argumento con nombre, todos deben tener nombre. No omita parámetros obligatorios. Los Optional omitidos del script usan sus valores declarados, evaluados en orden de declaración después de las expresiones suministradas. Las sobrecargas nativas solo admiten sus nombres y aridad registrados, sin valores predeterminados inventados.

## Devuelve

:= no devuelve un valor independiente. La función/API conserva su resultado; Sub no tiene resultado implícito. Los ejemplos devuelven Integer 129 y Strings "21:12", "20:10:2", no indicadores Boolean.

## Comportamiento

- La preparación informa SC027 con ubicación de origen ante nombres incorrectos, duplicados, obligatorios ausentes o ambigüedad. Los objetos dinámicos se comprueban al ejecutar antes de evaluar sus argumentos. La ausencia de una sobrecarga nativa no produce un reemplazo por una llamada sin argumentos.
- Se almacenan mapas inmutables para los lugares de llamada estáticos. Las expresiones siguen el orden escrito; la asignación y escritura ByRef siguen los parámetros. Los valores predeterminados y del depurador corresponden a la firma elegida. Cada llamada captura su objeto dinámico, sin reutilizar el anterior.
- ParamArray no admite nombre. Puede quedar vacío en llamadas con nombres; sus valores requieren una llamada totalmente posicional. No se admiten posiciones vacías entre comas. Este subconjunto exige posicionales primero, sin la mezcla libre de VB.NET recientes. No crea hilos ni modifica las demoras del juego.

## Ejemplos

### 1. Omitir un Optional intermedio

```vb
# Encode declara x, y=2, z=3. z:=9 proporciona z y x:=1 proporciona x; y conserva 2. Calcula 1*100+2*10+9=129. Equivalentes: Encode(1,2,9) y Encode(1,z:=9).
Option Explicit On
Function Encode(ByVal x, Optional ByVal y=2, Optional ByVal z=3) As Integer
    Return x*100 + y*10 + z
End Function

Sub Main()
    Dim encoded = Encode(z:=9, x:=1)
    Return encoded
End Sub
```

**Explicación de los parámetros y la ejecución:**

Encode declara x, y=2, z=3. z:=9 proporciona z y x:=1 proporciona x; y conserva 2. Calcula 1*100+2*10+9=129. Equivalentes: Encode(1,2,9) y Encode(1,z:=9).

### 2. Actualizar las variables ByRef correctas

```vb
# Change declara ByRef left y right. right:=a enlaza a=1 con right; left:=b enlaza b=2 con left. Al sumar 10 a left y 20 a right se escriben b=12 y a=21. Main devuelve "21:12". A la izquierda de := va el parámetro; a la derecha, la variable del llamador.
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

**Explicación de los parámetros y la ejecución:**

Change declara ByRef left y right. right:=a enlaza a=1 con right; left:=b enlaza b=2 con left. Al sumar 10 a left y 20 a right se escriben b=12 y a=21. Main devuelve "21:12". A la izquierda de := va el parámetro; a la derecha, la variable del llamador.

### 3. Operar una lista nativa

```vb
# List() crea la lista. Add(value:=10) añade 10 sin resultado. Insert(value:=20,index:=0) inserta 20 en el índice 0 y desplaza 10 al índice 1. Item(index:=...) devuelve el elemento y Count() devuelve 2. Main forma "20:10:2". UO.Name(...) emplea los mismos criterios con sus nombres registrados y resultado propio.
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

**Explicación de los parámetros y la ejecución:**

List() crea la lista. Add(value:=10) añade 10 sin resultado. Insert(value:=20,index:=0) inserta 20 en el índice 0 y desplaza 10 al índice 1. Item(index:=...) devuelve el elemento y Count() devuelve 2. Main forma "20:10:2". UO.Name(...) emplea los mismos criterios con sus nombres registrados y resultado propio.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: argument
Runtime/NamedArgumentBinding.cs: TryCreate / TryCustom
Runtime/Interpreter.NamedArguments.cs: CallNamed
Runtime/Interpreter.cs: CallSubrutine / CreateArgumentWriter
Analysis/NamedArgumentsValidator.cs
https://learn.microsoft.com/en-us/dotnet/visual-basic/programming-guide/language-features/procedures/passing-arguments-by-position-and-by-name
-->
