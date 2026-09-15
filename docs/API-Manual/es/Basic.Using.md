# Using / End Using

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: es -->

Using cierra un recurso nativo al salir del bloque. La forma admitida recibe una variable existente o una expresión que devuelve un recurso.

## Sintaxis exacta

```text
Dim resource = MemoryStream()
Using resource
    statements
End Using
Using resourceExpression
    statements
End Using
```

## Parámetros

- `resourceExpression` — Se evalúa una vez. File(path), MemoryStream() y CreateTimer(...) son válidos. Liberar un temporizador lo detiene definitivamente (Basic.Timers); String, números, List y Dictionary producen un error con línea antes del cuerpo. Declare antes la variable: no se admiten declaraciones en la cabecera, As New, listas con comas ni Dispose definidos por el usuario.
- `statements / End Using` — End Using cierra el objeto capturado. La variable sigue visible, pero el recurso está cerrado. Anide bloques para varios recursos. Reasignar la variable no cambia el objeto original que se cerrará.

## Devuelve

La instrucción no devuelve valores. Return libera el recurso antes de abandonar la rutina. IsClosed es una función del ejemplo con resultado 1/True o 0/False; Main devuelve cadenas, no indicadores de éxito.

## Comportamiento

- File(path) crea un envoltorio: use Create() para escribir u Open() para leer dentro del bloque. Dispose llama a Close(), vacía el búfer y libera el identificador del sistema. Length() falla después de cerrar MemoryStream. Los ejemplos solo utilizan memoria.
- El compilador crea una región protegida; el intérprete conserva el objeto en la llamada actual. End Using, Return, Exit, Continue y saltos hacia fuera cierran de dentro hacia fuera. Los saltos hacia el cuerpo se rechazan antes de ejecutar.
- Los errores normales cierran antes del Catch externo. Un Dispose fallido no se repite; los recursos externos también se cierran. La parada de emergencia omite Catch/Finally del script pero libera recursos nativos; los errores de cierre no sustituyen la cancelación. Pausa mantiene el recurso hasta continuar o parar. No crea hilos ni puede interrumpir a la fuerza un cierre bloqueado del sistema.
- Coloque Try/Catch dentro de Using para recuperarse sin cerrar el recurso. Un error no capturado con On Error Resume Next cierra el recurso y continúa después del bloque completo. On Error GoTo no puede apuntar a una etiqueta dentro de Using, pues reentraría en una región ya cerrada.
- Tras un error que sale de Using, Resume en el controlador externo On Error GoTo reinicia todo el bloque desde su cabecera y evalúa de nuevo la expresión del recurso. Resume Next continúa justo después de End Using. Una variable que apunta a un objeto cerrado no lo reabre: al reintentar use una expresión que cree un recurso nuevo. Las acciones ya ejecutadas pueden repetirse.

## Ejemplos

### 1. Cerrar un flujo de memoria

```vb
# stream es el recurso; size lee Length()=0 mientras está abierto. Luego IsClosed captura el error y devuelve True=1; Main devuelve "0:1". ByVal copia la referencia. Esta función didáctica considera cualquier error de Length como cierre solo para estos flujos.
Option Explicit On
Function IsClosed(ByVal stream) As Boolean
    Try
        Dim size = stream.Length()
        Return False
    Catch closed
        Return True
    End Try
End Function

Sub Main()
    Dim stream = MemoryStream()
    Dim size = -1
    Using stream
        size = stream.Length()
    End Using
    Return CStr(size) & ":" & CStr(IsClosed(stream))
End Sub
```

**Explicación de los parámetros y la ejecución:**

stream es el recurso; size lee Length()=0 mientras está abierto. Luego IsClosed captura el error y devuelve True=1; Main devuelve "0:1". ByVal copia la referencia. Esta función didáctica considera cualquier error de Length como cierre solo para estos flujos.

### 2. Retornar desde una función auxiliar

```vb
# ReadLength(stream) calcula Integer 0. Return cierra el flujo antes de que Main reciba size. El siguiente Length falla: closed=True, resultado "0:1". No pase un recurso que el llamador necesite mantener abierto.
Option Explicit On
Function ReadLength(ByVal stream) As Integer
    Using stream
        Return stream.Length()
    End Using
End Function

Sub Main()
    Dim stream = MemoryStream()
    Dim size = ReadLength(stream)
    Dim closed = False
    Try
        Dim after = stream.Length()
    Catch problem
        closed = True
    End Try
    Return CStr(size) & ":" & CStr(closed)
End Sub
```

**Explicación de los parámetros y la ejecución:**

ReadLength(stream) calcula Integer 0. Return cierra el flujo antes de que Main reciba size. El siguiente Length falla: closed=True, resultado "0:1". No pase un recurso que el llamador necesite mantener abierto.

### 3. Liberar recursos anidados por error

```vb
# outer e inner son distintos. Throw "demo" cierra inner y después outer. Catch conserva el mensaje; IsClosed devuelve 1 por cada flujo. Main devuelve "demo:2". Dos cuenta objetos cerrados y no es Boolean.
Option Explicit On
Function IsClosed(ByVal stream) As Boolean
    Try
        Dim size = stream.Length()
        Return False
    Catch closed
        Return True
    End Try
End Function

Sub Main()
    Dim outer = MemoryStream()
    Dim inner = MemoryStream()
    Dim message = ""
    Try
        Using outer
            Using inner
                Throw "demo"
            End Using
        End Using
    Catch problem
        message = problem
    End Try
    Return message & ":" & CStr(IsClosed(outer) + IsClosed(inner))
End Sub
```

**Explicación de los parámetros y la ejecución:**

outer e inner son distintos. Throw "demo" cierra inner y después outer. Catch conserva el mensaje; IsClosed devuelve 1 por cada flujo. Main devuelve "demo:2". Dos cuenta objetos cerrados y no es Boolean.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: usingStatement / USING / END_USING
Runtime/Instructions/Generator.cs: Generate(UsingStatementContext)
Runtime/Interpreter.cs: TryExecutionScope.DisposeResource / Transfer / DeferReturn / CallSubrutine
Runtime/ObjectTypes/FileObject.cs: Dispose / Close
Runtime/ObjectTypes/MemoryStreamObject.cs: Dispose
Analysis/TryStructureValidator.cs: Regions
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/using-statement
-->
