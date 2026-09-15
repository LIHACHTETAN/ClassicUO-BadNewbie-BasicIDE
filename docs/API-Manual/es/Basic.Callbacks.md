# AddressOf / callbacks

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: es -->

AddressOf guarda una referencia a una Sub o Function del script sin ejecutarla. Puede pasarla a otra rutina, devolverla o guardarla en una colección para elegir una regla de procesamiento.

## Sintaxis exacta

```text
Dim callback = AddressOf ProcedureName
Dim callback As Object = AddressOf Tools.FunctionName
callback(arguments)
callback.Invoke(arguments)
Process(values, AddressOf Predicate)
```

## Parámetros

- `ProcedureName` — Nombre de una rutina declarada, con Module si hace falta. Debe coincidir una sola declaración. Nombres desconocidos, miembros Private inaccesibles y sobrecargas se rechazan antes de ejecutar. Para funciones nativas Basic o comandos UO escriba una función envolvente con nombre único. No añada paréntesis al nombre tras AddressOf.
- `callback / arguments` — callback es Object. callback(...) y callback.Invoke(...) ejecutan de forma síncrona en el hilo del script. Los argumentos con nombre usan los nombres reales de los parámetros. Guarde primero un elemento de colección en una variable. La referencia se captura antes de evaluar argumentos aunque estos cambien callback.
- `ByRef / ByVal / Optional / ParamArray` — ByVal copia valor o referencia; ByRef escribe cambios de vuelta; Optional calcula valores omitidos; ParamArray agrupa valores posicionales. Los argumentos con nombre van después de los posicionales; ParamArray requiere llamadas solo posicionales. Un nombre o cantidad incorrectos fallan antes de los efectos de los argumentos.

## Devuelve

AddressOf devuelve una referencia Object, no ID, dirección de memoria, Boolean ni resultado de la función. Una Function devuelve su resultado; una Sub sin expresión Return no devuelve valor (Unit). IsPositive devuelve 1/True o 0/False. Main devuelve String en ejemplos 1 y 3 e Integer 15 en el segundo.

## Comportamiento

- La referencia no captura variables locales de la función creadora: no es una lambda ni un cierre. Pertenece al script cargado; otro intérprete o un script recargado no puede invocarla. Una fábrica Public puede exponer deliberadamente su propia función Private.
- La preparación comprueba nombre y acceso. El intérprete guarda una referencia inmutable por ubicación AddressOf. Cada llamada lee la variable actual, valida la firma, evalúa una vez los argumentos en orden escrito y entra en un marco normal. ByRef y excepciones siguen las reglas de llamadas directas.
- No crea un hilo ni un temporizador. Pausa y cancelación usan puntos de control normales, incluso dentro de bucles del callback. Los errores llegan al Catch/Finally del llamante; Catch no absorbe la parada de emergencia. Las llamadas nativas bloqueantes conservan sus límites de cancelación.
- Esta función no incluye declaraciones Delegate, lambdas, punteros DLL ni referencias a sobrecargas. AddressOf se escribe sin UO.; los comandos de juego en la envolvente mantienen UO.

## Ejemplos

### 1. Filtrar mediante un predicado

```vb
# values es la List original; predicate es AddressOf IsPositive. FilterValues llama predicate(number) una vez por número. Solo quedan 4 y 7: selected.Count()=2 y selected[0]=4. Main devuelve "2:4". Ambas funciones auxiliares están completas en el script; no son nuevos comandos API.
Option Explicit On
Function IsPositive(ByVal number) As Boolean
    Return number > 0
End Function

Function FilterValues(ByVal values, ByVal predicate)
    Dim result = List()
    For Each number In values
        If predicate(number) Then
            result.Add(number)
        End If
    Next
    Return result
End Function

Sub Main()
    Dim numbers = List()
    numbers.Add(-2)
    numbers.Add(4)
    numbers.Add(7)
    Dim selected = FilterValues(numbers, AddressOf IsPositive)
    Return CStr(selected.Count()) & ":" & CStr(selected[0])
End Sub
```

**Explicación de los parámetros y la ejecución:**

values es la List original; predicate es AddressOf IsPositive. FilterValues llama predicate(number) una vez por número. Solo quedan 4 y 7: selected.Count()=2 y selected[0]=4. Main devuelve "2:4". Ambas funciones auxiliares están completas en el script; no son nuevos comandos API.

### 2. Cambiar la variable del llamante

```vb
# AddAmount recibe total ByRef y amount ByVal, por defecto 1. update(total) cambia 10 a 11. Invoke con amount:=4 y total:=total enlaza los nombres y cambia 11 a 15. ByRef actualiza la variable original. Sub no devuelve nada; Main devuelve Integer 15, no Boolean.
Option Explicit On
Sub AddAmount(ByRef total As Integer, Optional ByVal amount = 1)
    total += amount
End Sub

Sub Main()
    Dim update = AddressOf AddAmount
    Dim total = 10
    update(total)
    update.Invoke(amount:=4, total:=total)
    Return total
End Sub
```

**Explicación de los parámetros y la ejecución:**

AddAmount recibe total ByRef y amount ByVal, por defecto 1. update(total) cambia 10 a 11. Invoke con amount:=4 y total:=total enlaza los nombres y cambia 11 a 15. ByRef actualiza la variable original. Sub no devuelve nada; Main devuelve Integer 15, no Boolean.

### 3. Regla privada y manejo de errores

```vb
# Rules.Create devuelve una referencia a Private CheckedDouble; AddressOf Rules.CheckedDouble directo desde fuera está prohibido. operation(6) devuelve 12; operation(-1) lanza "negative" antes de asignar, de modo que result sigue en 12. Catch recibe el texto y Finally agrega ":done". Main devuelve "12:negative:done". Cerrar el IDE no detiene el script.
Option Explicit On
Module Rules
    Private Function CheckedDouble(ByVal number) As Integer
        If number < 0 Then
            Throw "negative"
        End If
        Return number * 2
    End Function

    Public Function Create()
        Return AddressOf CheckedDouble
    End Function
End Module

Sub Main()
    Dim operation = Rules.Create()
    Dim result = operation(6)
    Dim message = ""
    Try
        result = operation(-1)
    Catch problem
        message = problem
    Finally
        message = message & ":done"
    End Try
    Return CStr(result) & ":" & message
End Sub
```

**Explicación de los parámetros y la ejecución:**

Rules.Create devuelve una referencia a Private CheckedDouble; AddressOf Rules.CheckedDouble directo desde fuera está prohibido. operation(6) devuelve 12; operation(-1) lanza "negative" antes de asignar, de modo que result sigue en 12. Catch recibe el texto y Finally agrega ":done". Main devuelve "12:negative:done". Cerrar el IDE no detiene el script.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: addressOf / ADDRESSOF
Runtime/Metadata.cs: TryGetCallbackTarget
Analysis/InvalidSymbolVisitor.cs: VisitAddressOf
Runtime/Interpreter.Callbacks.cs: VisitAddressOf / TryGetCallback / CallCallback
Runtime/Interpreter.cs: CreateArgumentWriter / CallSubrutine
Runtime/NamedArgumentBinding.cs: TryCreate
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/operators/addressof-operator
-->
