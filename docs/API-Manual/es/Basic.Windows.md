# Windows.bas

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: es -->

Windows.bas es un módulo Basic editable con seis funciones públicas para datos del proceso, intervalos cortos y tamaño del escritorio. Abajo aparecen todo el código y los Declare privados; copiar solo Main no basta.

## Sintaxis exacta

```text
Include "Windows.bas"
Windows.ProcessId() As Integer
Windows.Milliseconds() As Double
Windows.ElapsedMilliseconds(ByVal startMilliseconds As Double) As Double
Windows.ScreenWidth() As Integer
Windows.ScreenHeight() As Integer
Windows.DesktopBounds() As Object
```

## Parámetros

- `Include / Windows.bas` — Include "Windows.bas" carga Scripts/Include/Windows.bas. En otra carpeta de scripts, copiar la biblioteca a su subcarpeta Include. El paquete incluye Main.bas e Include/Windows.bas. Llamadas con Windows., sin UO.; es un módulo del script.
- `ProcessId()` — ProcessId(), sin argumentos, devuelve Integer con el ID Windows del proceso cliente; no es serial UO ni ID de conexión.
- `Milliseconds()` — Milliseconds(), sin argumentos, devuelve Double 0..4294967295, el GetTickCount de 32 bits sin signo. Suma 4294967296.0 a resultados nativos negativos. El contador vuelve a cero aproximadamente cada 49,7 días; no es hora civil ni cronómetro de alta resolución.
- `ElapsedMilliseconds(startMilliseconds)` — ElapsedMilliseconds(startMilliseconds) recibe un Milliseconds() guardado como Double y devuelve milisegundos transcurridos Double. Fuera de 0..4294967295 genera error. Suma 4294967296.0 a una diferencia negativa, considerando una vuelta. Usar intervalos inferiores a una vuelta; no espera por sí misma.
- `ScreenWidth() / ScreenHeight()` — ScreenWidth()/ScreenHeight(), sin argumentos, devuelven Integer del monitor principal, métricas 0/1 en el contexto DPI del proceso. No son casillas UO ni tamaño de la ventana del juego.
- `DesktopBounds()` — DesktopBounds() devuelve un nuevo Dictionary con claves de texto X, Y, Width, Height y valores Integer, leídos con Item("X") etc. Las métricas 76–79 abarcan todos los monitores; X/Y pueden ser negativos. Cambiar el diccionario no cambia ventanas.

## Devuelve

ID y dimensiones son Integer. Tiempos son cantidades Double en milisegundos, no Boolean. DesktopBounds es Object (Dictionary) con valores Integer. Include y declaraciones no devuelven nada. Main de cada ejemplo devuelve 1/True después de comprobar los datos; 0/False significa comprobación fallida, no la interpretación de cualquier número nativo.

## Comportamiento

- Requiere Windows x64. NativeTicks, NativeProcessId y NativeMetric son los Declare privados mostrados abajo. Reglas DLL en Basic.Declare. Sin tráfico de juego, cambios de opciones ni movimiento del personaje.
- Se leen valores actuales. Milliseconds normalmente se actualiza cada 10–16 ms. No distingue varias vueltas o datos de otra sesión Windows. Usar para operaciones cortas; Wait no promete duración exacta.
- Copiar Main.bas junto con Include/Windows.bas; el código es editable en la IDE. DesktopBounds crea una instantánea independiente. Cambios de monitores o DPI pueden afectar resultados posteriores.

## Ejemplos

### 1. Proceso y contador

```vb
# Main carga Windows.bas, lee ProcessId() y guarda Milliseconds() en startedAt. AndAlso comprueba un ID positivo y el rango 0..4294967295; devuelve 1/True con datos válidos. Los números concretos dependen del equipo.
Option Explicit On
Include "Windows.bas"

Sub Main()
    Dim processId = Windows.ProcessId()
    Dim startedAt = Windows.Milliseconds()
    Return processId > 0 AndAlso startedAt >= 0 AndAlso startedAt <= 4294967295.0
End Sub
```

**Explicación de los parámetros y la ejecución:**

Main carga Windows.bas, lee ProcessId() y guarda Milliseconds() en startedAt. AndAlso comprueba un ID positivo y el rango 0..4294967295; devuelve 1/True con datos válidos. Los números concretos dependen del equipo.

**Include/Windows.bas**

```vbnet
Option Explicit On

' Windows x64 helpers. Include "Windows.bas" from the main script.
' These declarations use the Windows ABI, not VB6 Integer/Long widths.
Module Windows
    Private Declare Function NativeTicks Lib "kernel32.dll" Alias "GetTickCount"() As Integer
    Private Declare Function NativeProcessId Lib "kernel32.dll" Alias "GetCurrentProcessId"() As Integer
    Private Declare Function NativeMetric Lib "user32.dll" Alias "GetSystemMetrics"(ByVal index As Integer) As Integer

    ' Returns the current client process ID. This is not a character/item serial.
    Public Function ProcessId() As Integer
        Return NativeProcessId()
    End Function

    ' Unsigned 32-bit milliseconds since Windows started, represented as Double.
    ' Wraps every 4294967296 ms (about 49.7 days); this is not a calendar time.
    Public Function Milliseconds() As Double
        Dim value As Double = NativeTicks()
        If value < 0 Then
            value += 4294967296.0
        End If
        Return value
    End Function

    ' startMilliseconds must come from Milliseconds(). Handles one wrap only.
    ' Use for intervals shorter than 49.7 days; no waiting is performed here.
    Public Function ElapsedMilliseconds(ByVal startMilliseconds As Double) As Double
        If Not (startMilliseconds >= 0 AndAlso startMilliseconds <= 4294967295.0) Then
            Throw "Windows.ElapsedMilliseconds requires a tick value in 0..4294967295."
        End If
        Dim elapsed As Double = Milliseconds() - startMilliseconds
        If elapsed < 0 Then
            elapsed += 4294967296.0
        End If
        Return elapsed
    End Function

    ' Primary monitor dimensions in the process's Windows DPI coordinate space.
    ' These are desktop dimensions, not the UO game viewport size.
    Public Function ScreenWidth() As Integer
        Return NativeMetric(0)
    End Function

    Public Function ScreenHeight() As Integer
        Return NativeMetric(1)
    End Function

    ' Returns a new Dictionary: X, Y, Width, Height of the whole virtual desktop.
    ' X/Y may be negative when monitors are to the left/above the primary one.
    Public Function DesktopBounds() As Object
        Dim bounds = Dictionary()
        bounds.Set("X", NativeMetric(76))
        bounds.Set("Y", NativeMetric(77))
        bounds.Set("Width", NativeMetric(78))
        bounds.Set("Height", NativeMetric(79))
        Return bounds
    End Function
End Module
```

### 2. Medir una espera

```vb
# MeasureWait(delayMilliseconds) rechaza valores negativos, guarda el contador, llama a Wait y devuelve ElapsedMilliseconds(startMilliseconds:=startedAt). Main pasa 15 y comprueba elapsed >= 0. La duración real puede superar 15 ms. Se muestran todas las funciones y la corrección de una vuelta.
Option Explicit On
Include "Windows.bas"

Function MeasureWait(ByVal delayMilliseconds As Integer) As Double
    If delayMilliseconds < 0 Then
        Throw "delayMilliseconds must be non-negative"
    End If
    Dim startedAt = Windows.Milliseconds()
    Wait(delayMilliseconds)
    Return Windows.ElapsedMilliseconds(startMilliseconds:=startedAt)
End Function

Sub Main()
    Dim elapsed = MeasureWait(15)
    Return elapsed >= 0
End Sub
```

**Explicación de los parámetros y la ejecución:**

MeasureWait(delayMilliseconds) rechaza valores negativos, guarda el contador, llama a Wait y devuelve ElapsedMilliseconds(startMilliseconds:=startedAt). Main pasa 15 y comprueba elapsed >= 0. La duración real puede superar 15 ms. Se muestran todas las funciones y la corrección de una vuelta.

**Include/Windows.bas**

```vbnet
Option Explicit On

' Windows x64 helpers. Include "Windows.bas" from the main script.
' These declarations use the Windows ABI, not VB6 Integer/Long widths.
Module Windows
    Private Declare Function NativeTicks Lib "kernel32.dll" Alias "GetTickCount"() As Integer
    Private Declare Function NativeProcessId Lib "kernel32.dll" Alias "GetCurrentProcessId"() As Integer
    Private Declare Function NativeMetric Lib "user32.dll" Alias "GetSystemMetrics"(ByVal index As Integer) As Integer

    ' Returns the current client process ID. This is not a character/item serial.
    Public Function ProcessId() As Integer
        Return NativeProcessId()
    End Function

    ' Unsigned 32-bit milliseconds since Windows started, represented as Double.
    ' Wraps every 4294967296 ms (about 49.7 days); this is not a calendar time.
    Public Function Milliseconds() As Double
        Dim value As Double = NativeTicks()
        If value < 0 Then
            value += 4294967296.0
        End If
        Return value
    End Function

    ' startMilliseconds must come from Milliseconds(). Handles one wrap only.
    ' Use for intervals shorter than 49.7 days; no waiting is performed here.
    Public Function ElapsedMilliseconds(ByVal startMilliseconds As Double) As Double
        If Not (startMilliseconds >= 0 AndAlso startMilliseconds <= 4294967295.0) Then
            Throw "Windows.ElapsedMilliseconds requires a tick value in 0..4294967295."
        End If
        Dim elapsed As Double = Milliseconds() - startMilliseconds
        If elapsed < 0 Then
            elapsed += 4294967296.0
        End If
        Return elapsed
    End Function

    ' Primary monitor dimensions in the process's Windows DPI coordinate space.
    ' These are desktop dimensions, not the UO game viewport size.
    Public Function ScreenWidth() As Integer
        Return NativeMetric(0)
    End Function

    Public Function ScreenHeight() As Integer
        Return NativeMetric(1)
    End Function

    ' Returns a new Dictionary: X, Y, Width, Height of the whole virtual desktop.
    ' X/Y may be negative when monitors are to the left/above the primary one.
    Public Function DesktopBounds() As Object
        Dim bounds = Dictionary()
        bounds.Set("X", NativeMetric(76))
        bounds.Set("Y", NativeMetric(77))
        bounds.Set("Width", NativeMetric(78))
        bounds.Set("Height", NativeMetric(79))
        Return bounds
    End Function
End Module
```

### 3. Geometría del escritorio

```vb
# Main lee X/Y/Width/Height con Item de un Dictionary independiente y compara con el monitor principal. Las dimensiones principales deben ser positivas y el escritorio al menos igual de grande. left/top pueden ser negativos; no son coordenadas de movimiento UO.
Option Explicit On
Include "Windows.bas"

Sub Main()
    Dim desktop = Windows.DesktopBounds()
    Dim left = desktop.Item("X")
    Dim top = desktop.Item("Y")
    Dim width = desktop.Item("Width")
    Dim height = desktop.Item("Height")
    Dim primaryWidth = Windows.ScreenWidth()
    Dim primaryHeight = Windows.ScreenHeight()
    Return width >= primaryWidth AndAlso height >= primaryHeight AndAlso primaryWidth > 0 AndAlso primaryHeight > 0
End Sub
```

**Explicación de los parámetros y la ejecución:**

Main lee X/Y/Width/Height con Item de un Dictionary independiente y compara con el monitor principal. Las dimensiones principales deben ser positivas y el escritorio al menos igual de grande. left/top pueden ser negativos; no son coordenadas de movimiento UO.

**Include/Windows.bas**

```vbnet
Option Explicit On

' Windows x64 helpers. Include "Windows.bas" from the main script.
' These declarations use the Windows ABI, not VB6 Integer/Long widths.
Module Windows
    Private Declare Function NativeTicks Lib "kernel32.dll" Alias "GetTickCount"() As Integer
    Private Declare Function NativeProcessId Lib "kernel32.dll" Alias "GetCurrentProcessId"() As Integer
    Private Declare Function NativeMetric Lib "user32.dll" Alias "GetSystemMetrics"(ByVal index As Integer) As Integer

    ' Returns the current client process ID. This is not a character/item serial.
    Public Function ProcessId() As Integer
        Return NativeProcessId()
    End Function

    ' Unsigned 32-bit milliseconds since Windows started, represented as Double.
    ' Wraps every 4294967296 ms (about 49.7 days); this is not a calendar time.
    Public Function Milliseconds() As Double
        Dim value As Double = NativeTicks()
        If value < 0 Then
            value += 4294967296.0
        End If
        Return value
    End Function

    ' startMilliseconds must come from Milliseconds(). Handles one wrap only.
    ' Use for intervals shorter than 49.7 days; no waiting is performed here.
    Public Function ElapsedMilliseconds(ByVal startMilliseconds As Double) As Double
        If Not (startMilliseconds >= 0 AndAlso startMilliseconds <= 4294967295.0) Then
            Throw "Windows.ElapsedMilliseconds requires a tick value in 0..4294967295."
        End If
        Dim elapsed As Double = Milliseconds() - startMilliseconds
        If elapsed < 0 Then
            elapsed += 4294967296.0
        End If
        Return elapsed
    End Function

    ' Primary monitor dimensions in the process's Windows DPI coordinate space.
    ' These are desktop dimensions, not the UO game viewport size.
    Public Function ScreenWidth() As Integer
        Return NativeMetric(0)
    End Function

    Public Function ScreenHeight() As Integer
        Return NativeMetric(1)
    End Function

    ' Returns a new Dictionary: X, Y, Width, Height of the whole virtual desktop.
    ' X/Y may be negative when monitors are to the left/above the primary one.
    Public Function DesktopBounds() As Object
        Dim bounds = Dictionary()
        bounds.Set("X", NativeMetric(76))
        bounds.Set("Y", NativeMetric(77))
        bounds.Set("Width", NativeMetric(78))
        bounds.Set("Height", NativeMetric(79))
        Return bounds
    End Function
End Module
```


### Funciones internas: de la llamada al resultado

Windows.bas es un módulo Basic editable con seis funciones públicas para datos del proceso, intervalos cortos y tamaño del escritorio. Abajo aparecen todo el código y los Declare privados; copiar solo Main no basta.

#### 1. ProcessId / Milliseconds

Milliseconds(), sin argumentos, devuelve Double 0..4294967295, el GetTickCount de 32 bits sin signo. Suma 4294967296.0 a resultados nativos negativos. El contador vuelve a cero aproximadamente cada 49,7 días; no es hora civil ni cronómetro de alta resolución.

`GetTickCount -> signed Integer -> if negative add 4294967296.0 -> Double`

Código del proyecto: `src/ClassicUO.Client/Scripts/Include/Windows.bas`; función `ProcessId / Milliseconds`.

#### 2. ElapsedMilliseconds

ElapsedMilliseconds(startMilliseconds) recibe un Milliseconds() guardado como Double y devuelve milisegundos transcurridos Double. Fuera de 0..4294967295 genera error. Suma 4294967296.0 a una diferencia negativa, considerando una vuelta. Usar intervalos inferiores a una vuelta; no espera por sí misma.

`validate start -> now - start -> if negative add one wrap -> Double`

Código del proyecto: `src/ClassicUO.Client/Scripts/Include/Windows.bas`; función `ElapsedMilliseconds`.

#### 3. ScreenWidth / ScreenHeight / DesktopBounds

DesktopBounds() devuelve un nuevo Dictionary con claves de texto X, Y, Width, Height y valores Integer, leídos con Item("X") etc. Las métricas 76–79 abarcan todos los monitores; X/Y pueden ser negativos. Cambiar el diccionario no cambia ventanas.

`metrics 0, 1: primary; 76, 77, 78, 79: desktop X, Y, Width, Height`

Código del proyecto: `src/ClassicUO.Client/Scripts/Include/Windows.bas`; función `ScreenWidth / ScreenHeight / DesktopBounds`.

ID y dimensiones son Integer. Tiempos son cantidades Double en milisegundos, no Boolean. DesktopBounds es Object (Dictionary) con valores Integer. Include y declaraciones no devuelven nada. Main de cada ejemplo devuelve 1/True después de comprobar los datos; 0/False significa comprobación fallida, no la interpretación de cualquier número nativo.

<!-- implementation references (not callable script procedures):
src/ClassicUO.Client/Scripts/Include/Windows.bas: all declarations and helpers
Runtime/ExternalLibraries.cs: GetCallable / Invoke / Dispose
Parsing/ScriptSourceGraph.cs: Include resolution
https://learn.microsoft.com/en-us/windows/win32/api/sysinfoapi/nf-sysinfoapi-gettickcount
https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getsystemmetrics
-->
