# Function / Return / Exit Function / End Function

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: es -->

Function define un ayudante que devuelve una cantidad, texto o referencia List/Dictionary. Se llama sin UO.; UO.GetType(item) sigue siendo una API del juego distinta de una Function GetType(value) propia.

## Sintaxis exacta

```text
Function name(parameters) As type
    name = expression
End Function
Function name(parameters)
    Return expression
End Function
result = name(arguments)
Exit Function
Return
```

## Parámetros

- `name` — El nombre, sin distinguir mayúsculas, también es la variable local implícita del resultado dentro del cuerpo. name lee el resultado; name(arguments) llama a la función, incluso recursivamente. No lo vuelva a declarar con Dim, Var, Const ni como parámetro.
- `parameters / arguments` — Parámetros posicionales con las reglas de Sub: ByRef predeterminado, ByVal, Optional y ParamArray final. Véanse Basic.Parameters y los capítulos específicos. Tools.Calculate(...) llama a una función del módulo respetando Public/Private.
- `As type` — Tipo opcional: Integer/Long/Short/Byte usan Integer del motor; Double/Single/Decimal usan Double; String guarda texto; Boolean/Bool normaliza a 1/0; Object/Variant conserva la clase de valor. No son todas las anchuras numéricas de VB.NET. Se rechazan tipos desconocidos. Sin As es Variant; los sufijos del nombre no deducen aquí el tipo.
- `name = expression` — Guarda el resultado y CONTINÚA con la siguiente instrucción. Puede leerse o modificarse de nuevo, incluso con +=. Es una variable local de esta invocación, no una global ni una nueva llamada.
- `Return / Exit Function / End Function` — Return expression asigna el resultado tipado e inicia la salida. Return vacío, Exit Function y End Function devuelven el resultado actual. End Function es obligatorio; Exit Sub dentro de Function es un error de carga.

## Devuelve

El resultado actual se devuelve tras los Finally normales. Valores iniciales: Integer 0, Double 0.0, Boolean FALSE/0, String vacía; sin tipo, Variant/Object empiezan con Unit sin valor significativo. List/Dictionary/Object mantienen referencias. Boolean produce 1/0 comparables con TRUE/FALSE; una cantidad o un ID no es automáticamente un código de éxito.

## Comportamiento

- La preparación conserva Function, valida tipo y salidas, vincula el resultado local y prepara el cuerpo una vez. Cada llamada recibe argumentos y un resultado tipado nuevo. La asignación aplica las conversiones normales de variables tipadas.
- Return guarda el resultado y recorre los Finally de dentro hacia fuera. Estos aún pueden modificarlo. La escritura ByRef termina después de una finalización correcta. Los errores sin manejar y las conversiones inválidas se propagan en lugar de dar éxito.
- La recursión tiene parámetros, locales y resultado independientes: Factorial(n-1) no sobrescribe el resultado del llamador. Hace falta un caso final. No hay hilo, espera ni timeout implícito; se mantienen pausa y parada.
- Las llamadas anidadas se limitan a 32 marcos, incluidos callbacks y controladores de eventos. Superarlos produce un error capturable; use bucles para procesamiento profundo. El retorno o error libera el marco y permite llamadas posteriores.

## Ejemplos

### 1. Asignar y continuar

```vb
# TotalPrice recibe count y price ByVal y devuelve Integer. Un valor negativo devuelve -1 inmediatamente. En otro caso guarda count*price y luego suma 2. Las llamadas (3,4) y (-1,4) dan 14 y -1; Main devuelve 14:-1. El significado de -1 lo elige este ayudante.
Option Explicit On
Function TotalPrice(ByVal count, ByVal price) As Integer
    If count < 0 OrElse price < 0 Then
        Return -1
    End If
    TotalPrice=count*price
    TotalPrice+=2
End Function

Sub Main()
    Return CStr(TotalPrice(3, 4)) & ":" & CStr(TotalPrice(-1, 4))
End Sub
```

**Explicación de los parámetros y la ejecución:**

TotalPrice recibe count y price ByVal y devuelve Integer. Un valor negativo devuelve -1 inmediatamente. En otro caso guarda count*price y luego suma 2. Las llamadas (3,4) y (-1,4) dan 14 y -1; Main devuelve 14:-1. El significado de -1 lo elige este ayudante.

### 2. Resultado recursivo independiente

```vb
# Factorial recibe n ByVal e inicia su resultado en 1. Con n<=1 Exit Function devuelve ese 1; si no, n*Factorial(n-1) usa una invocación nueva. Para las entradas pequeñas no negativas, 5!+3!=120+6=126. Los negativos también alcanzan el caso final; no se valida todo el dominio matemático del factorial.
Option Explicit On
Function Factorial(ByVal n) As Integer
    Factorial=1
    If n <= 1 Then
        Exit Function
    End If
    Factorial=n*Factorial(n-1)
End Function

Sub Main()
    Return Factorial(5)+Factorial(3)
End Sub
```

**Explicación de los parámetros y la ejecución:**

Factorial recibe n ByVal e inicia su resultado en 1. Con n<=1 Exit Function devuelve ese 1; si no, n*Factorial(n-1) usa una invocación nueva. Para las entradas pequeñas no negativas, 5!+3!=120+6=126. Los negativos también alcanzan el caso final; no se valida todo el dominio matemático del factorial.

### 3. Return y dos Finally

```vb
# Calculate recibe trace ByRef. Return 1 asigna el resultado e inicia la salida. El Finally interior cambia resultado y trace de 1 a 12; el exterior los convierte en 123. Main recibe ambos y devuelve 123:123. Finally modifica el valor incluso después de Return expression; no se simula movimiento del juego.
Option Explicit On
Function Calculate(ByRef trace) As Integer
    Try
        Try
            trace=1
            Return 1
        Finally
            Calculate=Calculate*10+2
            trace=trace*10+2
        End Try
    Finally
        Calculate=Calculate*10+3
        trace=trace*10+3
    End Try
End Function

Sub Main()
    Dim trace=0
    Dim result=Calculate(trace)
    Return CStr(result) & ":" & CStr(trace)
End Sub
```

**Explicación de los parámetros y la ejecución:**

Calculate recibe trace ByRef. Return 1 asigna el resultado e inicia la salida. El Finally interior cambia resultado y trace de 1 a 12; el exterior los convierte en 123. Main recibe ambos y devuelve 123:123. Finally modifica el valor incluso después de Return expression; no se simula movimiento del juego.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: subrutine / parameters / returnStatement / exitProcedure
Runtime/BasicSyntaxPreprocessor.cs: Normalize / NormalizeArguments
Analysis/ProcedureStructureValidator.cs: VisitSubrutine / VisitExitProcedure / CheckName
Runtime/SubrutineDefinition.cs: IsFunction / ReturnType / ResultName
Runtime/Interpreter.cs: CallSubrutine / FunctionResult / DeferReturn / DefaultValueForType
Runtime/SemanticScope.cs: DefineVar / SetVar
Runtime/ScriptBindings.cs: Builder.VisitSubrutine
ClassicUO.Client/Game/Managers/YokoInjectionManager.cs: DiscoverProcedures / DiscoverScopedProcedures
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/function-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/return-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/exit-statement
-->
