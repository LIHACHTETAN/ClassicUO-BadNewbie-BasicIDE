# Sub / Call / Exit Sub / End Sub

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: es -->

Sub agrupa instrucciones en un procedimiento con nombre para tratar objetos, validar datos o finalizar una operación. La llamada es síncrona dentro del script actual y no inicia otro script en segundo plano.

## Sintaxis exacta

```text
Sub name(parameters)
    statements
End Sub
name(arguments)
Call name(arguments)
Call name arguments
Call name
Exit Sub
Return
Return expression
```

## Parámetros

- `name` — Identificador que no distingue mayúsculas. El código propio se llama sin UO.; un miembro de módulo es Tools.Work(...). Public/Private controlan su acceso: véanse Basic.Module y Basic.Visibility.
- `parameters / arguments` — Declare parámetros entre paréntesis y pase argumentos en su orden. ByRef es el valor predeterminado; ByVal copia el valor, Optional aporta el omitido y el último ParamArray reúne argumentos adicionales. Los cinco capítulos de parámetros detallan tipos, matrices, referencias compartidas y escritura de vuelta.
- `statements / End Sub` — El cuerpo puede estar vacío; End Sub es obligatorio. Cada llamada tiene sus propias variables locales, también en recursión. Declare procedimientos a nivel de archivo o módulo, no dentro de otro procedimiento.
- `Call` — Call es opcional en name(arguments). Call name arguments también admite argumentos sin paréntesis; Call name invoca un procedimiento sin parámetros. Call descarta cualquier valor devuelto. Los argumentos mantienen el sentido normal de sus expresiones.
- `Exit Sub / Return` — Exit Sub o Return sin expresión termina esta llamada. Return expression dentro de Sub es una extensión de compatibilidad de Basic que no existe en Sub de VB.NET. Exit Function dentro de Sub produce un error de carga.

## Devuelve

End Sub, Exit Sub y Return vacío producen Unit: ningún resultado significativo, ni éxito booleano ni ID. Un Sub antiguo de Basic puede devolver expression mediante Return. ByRef puede cambiar por separado una variable del llamador. Prefiera Function para calcular un resultado.

## Comportamiento

- La preparación normaliza cabeceras compatibles y Call, valida el bloque y resuelve nombres. Evalúa y enlaza los argumentos antes de entrar. Las llamadas reutilizan instrucciones preparadas, sin compartir valores locales.
- El intérprete crea el ámbito, ejecuta el cuerpo y continúa tras la llamada. La salida normal y Exit Sub ejecutan los Finally abandonados antes de completar la escritura de parámetros. Las excepciones pasan al manejador activo; una llamada fallida no significa éxito.
- Se conservan las comprobaciones de pausa y parada. No se crea ningún hilo, espera automática ni timeout. La recursión necesita un caso final. Asignar al nombre de Sub no define su resultado: use Function.
- Las llamadas anidadas se limitan a 32 marcos, incluidos callbacks y controladores de eventos. Superarlos produce un error capturable; use bucles para procesamiento profundo. El retorno o error libera el marco y permite llamadas posteriores.

## Ejemplos

### 1. Tres formas de llamada

```vb
# total comienza en 4. AddAmount recibe total ByRef; amount omitido vale 1 y los valores explícitos 3 y 2 son ByVal. Call con paréntesis, sin paréntesis y la llamada normal ejecutan el mismo ayudante. Main devuelve 4+1+3+2=10.
Option Explicit On
Sub AddAmount(ByRef total, Optional ByVal amount=1)
    total += amount
End Sub

Sub Main()
    Dim total=4
    Call AddAmount(total)
    Call AddAmount total, 3
    AddAmount(total, 2)
    Return total
End Sub
```

**Explicación de los parámetros y la ejecución:**

total comienza en 4. AddAmount recibe total ByRef; amount omitido vale 1 y los valores explícitos 3 y 2 son ByVal. Call con paréntesis, sin paréntesis y la llamada normal ejecutan el mismo ayudante. Main devuelve 4+1+3+2=10.

### 2. Entrada pública y ayudante privado

```vb
# Batches.SumInto recibe total ByRef y reúne 3,-9,4 en values. For Each llama a AppendAmount. La condición negativa sale solamente del ayudante: se omite -9 y continúa el bucle. Partiendo de 2 se obtiene 2+3+4=9. Desde fuera se usa el nombre público cualificado.
Option Explicit On
Module Batches
    Private Sub AppendAmount(ByRef total, ByVal value)
        If value < 0 Then
            Exit Sub
        End If
        total += value
    End Sub

    Public Sub SumInto(ByRef total, ParamArray values)
        For Each value In values
            AppendAmount(total, value)
        Next
    End Sub
End Module

Sub Main()
    Dim total=2
    Batches.SumInto(total, 3, -9, 4)
    Return total
End Sub
```

**Explicación de los parámetros y la ejecución:**

Batches.SumInto recibe total ByRef y reúne 3,-9,4 en values. For Each llama a AppendAmount. La condición negativa sale solamente del ayudante: se omite -9 y continúa el bucle. Partiendo de 2 se obtiene 2+3+4=9. Desde fuera se usa el nombre público cualificado.

### 3. Salida anticipada y limpieza

```vb
# Finish asigna trace=1 y sale; trace=99 no se ejecuta. Finally añade 2 y trace=12 vuelve mediante ByRef. LegacyValue demuestra Return 7 dentro de un Sub Basic. Main devuelve 12*10+7=127. Las cifras de trace pertenecen al ejemplo y no son códigos del juego.
Option Explicit On
Sub Finish(ByRef trace)
    Try
        trace=1
        Exit Sub
        trace=99
    Finally
        trace=trace*10+2
    End Try
End Sub

Sub LegacyValue()
    Return 7
End Sub

Sub Main()
    Dim trace=0
    Call Finish(trace)
    Return trace*10+LegacyValue()
End Sub
```

**Explicación de los parámetros y la ejecución:**

Finish asigna trace=1 y sale; trace=99 no se ejecuta. Finally añade 2 y trace=12 vuelve mediante ByRef. LegacyValue demuestra Return 7 dentro de un Sub Basic. Main devuelve 12*10+7=127. Las cifras de trace pertenecen al ejemplo y no son códigos del juego.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: subrutine / parameters / returnStatement / exitProcedure
Runtime/BasicSyntaxPreprocessor.cs: Normalize / NormalizeArguments
Analysis/ProcedureStructureValidator.cs: VisitSubrutine / VisitExitProcedure / CheckName
Runtime/SubrutineDefinition.cs: IsFunction / ReturnType / ResultName
Runtime/Interpreter.cs: CallSubrutine / FunctionResult / DeferReturn / DefaultValueForType
Runtime/SemanticScope.cs: DefineVar / SetVar
Runtime/ScriptBindings.cs: Builder.VisitSubrutine
ClassicUO.Client/Game/Managers/YokoInjectionManager.cs: DiscoverProcedures / DiscoverScopedProcedures
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/sub-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/call-statement
-->
