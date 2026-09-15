# AS

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: es -->

AS establece la conversión de una variable escalar. Los tipos internos son Integer, Decimal, String, Array, Object y Unit (sin valor). Boolean usa Integer 1/0. Los alias de este Basic no garantizan los tamaños de almacenamiento de VB.NET.

## Sintaxis exacta

```text
VAR name AS type [= value]
DIM name AS type [= value]
```

## Parámetros

- `name` — Nombre declarado. Su lectura da el valor actual; cada asignación posterior vuelve a aplicar AS.
- `type` — Integer, Long, Short, Byte: entero con signo de 32 bits, -2147483648…2147483647; Short y Byte no reducen ese rango. Double, Single, Decimal: coma flotante binaria de 64 bits, llamada Decimal internamente, sin aritmética decimal exacta. String: texto. Boolean, Bool: Integer 1/0. Variant, Object: conservan el tipo suministrado sin exigir una instancia de objeto. No distingue mayúsculas.
- `value` — Valor inicial opcional: número, texto, variable o resultado de función. AS pertenece a la declaración; CInt(value), CDbl(value), CStr(value), CBool(value) hacen conversiones explícitas en expresiones.

## Devuelve

AS no devuelve nada. Leer la variable devuelve el tipo y valor almacenados. Los resultados lógicos usan TRUE=1 y FALSE=0. La cantidad 2 no es cero, pero 2=TRUE es falso; compruebe si hay objetos con count<>0 o CBool(count).

## Comportamiento

- Sin inicializador, VAR tipado da 0 para enteros/Boolean, cero flotante para Double/Single/Decimal y texto vacío para String. VAR sin tipo y VAR AS Variant/Object dan Unit. DIM escalar inserta texto vacío para String, o 0 en los demás casos. Unit permanece Unit al asignarlo mediante AS.
- AS Integer trunca hacia cero las fracciones dentro del rango permitido. CInt/CLng redondean, alejando de cero las mitades: 2.6 da 3, mientras AS Integer almacena 2. El texto entero debe ser completamente entero decimal o hexadecimal 0x; "2.6" no sirve. Compruebe el rango antes de convertir.
- AS Boolean compara el valor original con cero numérico: número no nulo → 1, cero → 0. No interpreta palabras: incluso el texto "false" da 1. CBool convierte primero a número. Use números/valores lógicos o compare explícitamente el texto con la palabra esperada.
- AS String usa la representación textual del motor. AS Double/Single/Decimal interpreta números con punto decimal. AS numérico convierte Array en 0, pero rechaza Object y texto numérico inválido con un error tratable mediante TRY/CATCH. CInt/CLng/CDbl/CSng/CBool son permisivos: texto no reconocido, Array, Object o Unit pasan primero a 0. Compruebe IsNumeric(value) antes de confiar en la conversión del texto.
- La declaración evalúa el inicializador, aplica AS y guarda resultado y nombre de tipo. Cada asignación repite la conversión. Los flotantes son aproximados, sin garantía de cálculos monetarios decimales exactos. VAR / DIM describe ámbitos y CONST protege asociaciones.
- As también acepta el nombre de una Structure declarada. VAR y DIM de ese tipo sin inicializador crean sus campos predeterminados. Solo es compatible el mismo tipo declarado; no se convierten tipos de estructura distintos. Structure / New describe copias anidadas y referencias.

## Ejemplos

### 1. Conversión y redondeo

```vb
# source=2.6 es flotante. whole AS Integer almacena 2; CInt(source) da 3 en rounded. Main devuelve 2*10+3=23 para comprobar ambas conversiones.
Option Explicit On
SUB Main()
    VAR source = 2.6
    VAR whole AS Integer = source
    VAR rounded = CInt(source)
    RETURN whole * 10 + rounded
END SUB
```

**Explicación de los parámetros y la ejecución:**

source=2.6 es flotante. whole AS Integer almacena 2; CInt(source) da 3 en rounded. Main devuelve 2*10+3=23 para comprobar ambas conversiones.

### 2. Cantidad y valor lógico

```vb
# count=2 es una cantidad. hasItems AS Boolean pasa a 1. count=TRUE es falso porque TRUE vale exactamente 1; count<>0 es verdadero. Main devuelve hasItems=1: hay objetos, sin afirmar que haya solo uno.
Option Explicit On
SUB Main()
    VAR count = 2
    VAR hasItems AS Boolean = count
    IF count = TRUE THEN
        RETURN -1
    END IF
    IF count <> 0 THEN
        RETURN hasItems
    END IF
    RETURN FALSE
END SUB
```

**Explicación de los parámetros y la ejecución:**

count=2 es una cantidad. hasItems AS Boolean pasa a 1. count=TRUE es falso porque TRUE vale exactamente 1; count<>0 es verdadero. Main devuelve hasItems=1: hay objetos, sin afirmar que haya solo uno.

### 3. Variant conserva el tipo del valor

```vb
# value AS Variant contiene primero Integer 7 y luego String "ore". text AS String empieza vacío. CStr(12) produce "12"; unir los textos da "ore12", devuelto por Main. Variant permite el cambio de tipo.
Option Explicit On
SUB Main()
    VAR value AS Variant = 7
    value = "ore"
    VAR text AS String
    text = value + CStr(12)
    RETURN text
END SUB
```

**Explicación de los parámetros y la ejecución:**

value AS Variant contiene primero Integer 7 y luego String "ore". text AS String empieza vacío. CStr(12) produce "12"; unir los textos da "ore12", devuelto por Main. Variant permite el cambio de tipo.

<!-- implementation references (not callable script procedures):
Runtime/InjectionValueKind.cs
Runtime/SemanticScope.cs: Coerce
Runtime/NumberConversions.cs
Runtime/Interpreter.cs: DefaultValueForType
Runtime/InjectionApi.cs: CInt / CLng / CDbl / CStr / CBool
-->
