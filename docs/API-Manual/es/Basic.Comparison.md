# =, ==, <>, <, >, <=, >=

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: es -->

Los operadores de comparación comprueban dos valores y producen un resultado lógico para IF, una variable o el RETURN de una función auxiliar.

## Sintaxis exacta

```text
left = right
left == right
left <> right
left < right
left > right
left <= right
left >= right
```

## Parámetros

- `left` — Valor izquierdo: literal, variable declarada, expresión o resultado de función.
- `right` — Valor derecho. El orden requiere Integer o Decimal; la igualdad admite también otros tipos de valor.
- `operator` — = y == comprueban igualdad dentro de expresiones; <> desigualdad; < y > orden estricto; <= y >= incluyen igualdad. Una instrucción independiente name = expression asigna un valor.

## Devuelve

Integer 1 (TRUE) si se cumple la comparación, o Integer 0 (FALSE). Para este resultado result=1 equivale a result=TRUE y result=0 a result=FALSE. Una cantidad o ID tiene otro significado: 2 no es cero, pero 2=TRUE es falso. Use count<>0 para comprobar una cantidad no nula.

## Comportamiento

- Integer y Decimal se comparan numéricamente: 5=5.0 es verdadero. El texto no se convierte: "5"=5 es falso. La igualdad de cadenas es ordinal y distingue mayúsculas: "Ore"<>"ore". Ordenar texto, matrices, objetos o Unit con <, >, <=, >= provoca un error.
- La igualdad de matrices y objetos nativos compara identidad, no contenido. Dos Unit son iguales, pero Unit no es el cero numérico. Tipos distintos son desiguales salvo Integer/Decimal. NaN no es igual ni a sí mismo y todas sus comparaciones numéricas de orden son falsas.
- La aritmética se evalúa antes de comparar. Las cadenas van de izquierda a derecha: 1<3<2 significa (1<3)<2 y es verdadero. Para un intervalo escriba (low<=value) AND (value<=high). Los paréntesis aclaran la agrupación.
- La aritmética flotante binaria puede redondear. Para medidas aproximadas use Abs(actual-expected)<=tolerance con una tolerancia adecuada no negativa. Es una política del script, no una tolerancia automática de los operadores.
- = compara el mismo tipo declarado y sus campos; <> es el inverso. Los campos de referencia comparan identidad. Es una extensión del motor, no una regla general de VB.NET. Los hashes guardados y las parejas ya visitadas evitan expandir repetidamente valores anidados compartidos.

## Ejemplos

### 1. Intervalo inclusivo y TRUE

```vb
# InRange recibe value=4, low=2, high=5. Las comparaciones dan 1, AND las combina en 1, Main comprueba accepted=TRUE y devuelve 1. La función y su llamada están completas.
Option Explicit On
FUNCTION InRange(value, low, high)
    RETURN (low <= value) AND (value <= high)
END FUNCTION
SUB Main()
    VAR accepted = InRange(4, 2, 5)
    IF accepted = TRUE THEN
        RETURN 1
    END IF
    RETURN 0
END SUB
```

**Explicación de los parámetros y la ejecución:**

InRange recibe value=4, low=2, high=5. Las comparaciones dan 1, AND las combina en 1, Main comprueba accepted=TRUE y devuelve 1. La función y su llamada están completas.

### 2. Texto, números y mayúsculas

```vb
# sameCase compara "Ore" con "ore" y vale 0. sameKind compara "5" con Integer 5 y vale 0. converted usa explícitamente CDbl("5") y vale 1. CStr forma el diagnóstico devuelto "0:0:1".
Option Explicit On
SUB Main()
    VAR sameCase = ("Ore" = "ore")
    VAR sameKind = ("5" == 5)
    VAR converted = (CDbl("5") = 5)
    RETURN CStr(sameCase) + ":" + CStr(sameKind) + ":" + CStr(converted)
END SUB
```

**Explicación de los parámetros y la ejecución:**

sameCase compara "Ore" con "ore" y vale 0. sameKind compara "5" con Integer 5 y vale 0. converted usa explícitamente CDbl("5") y vale 1. CStr forma el diagnóstico devuelto "0:0:1".

### 3. Igualdad decimal aproximada

```vb
# NearlyEqual recibe 0.1+0.2, expected=0.3, tolerance=0.000001. Rechaza tolerancias negativas. Abs obtiene la magnitud de la diferencia; <= acepta desviaciones dentro de la tolerancia. Main devuelve 1. Todos los parámetros auxiliares se indican explícitamente.
Option Explicit On
FUNCTION NearlyEqual(actual, expected, tolerance)
    IF tolerance < 0 THEN
        RETURN FALSE
    END IF
    RETURN Abs(actual - expected) <= tolerance
END FUNCTION
SUB Main()
    RETURN NearlyEqual(0.1 + 0.2, 0.3, 0.000001)
END SUB
```

**Explicación de los parámetros y la ejecución:**

NearlyEqual recibe 0.1+0.2, expected=0.3, tolerance=0.000001. Rechaza tolerancias negativas. Abs obtiene la magnitud de la diferencia; <= acepta desviaciones dentro de la tolerancia. Main devuelve 1. Todos los parámetros auxiliares se indican explícitamente.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: logicalOperand / comparativeOperation
Runtime/Interpreter.cs: VisitLogicalOperand
Runtime/InjectionValue.cs: Equals / comparison operators
-->
