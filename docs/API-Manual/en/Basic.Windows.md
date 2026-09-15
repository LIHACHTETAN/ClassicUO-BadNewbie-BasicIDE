# Windows.bas

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: en -->

Windows.bas is an editable Basic source module with six public helpers for process information, short interval measurement and desktop dimensions. Its complete code and private Declare statements are included below; copying only Main without the Include file is insufficient.

## Exact syntax

```text
Include "Windows.bas"
Windows.ProcessId() As Integer
Windows.Milliseconds() As Double
Windows.ElapsedMilliseconds(ByVal startMilliseconds As Double) As Double
Windows.ScreenWidth() As Integer
Windows.ScreenHeight() As Integer
Windows.DesktopBounds() As Object
```

## Parameters

- `Include / Windows.bas` — Include "Windows.bas" connects Scripts/Include/Windows.bas. For a separate script folder, copy the included library into its Include subfolder. The example package contains Main.bas and Include/Windows.bas. Calls use Windows., without UO.; this is a script module, not a built-in API namespace.
- `ProcessId()` — ProcessId() has no arguments and returns the current client’s Windows process ID as Integer. It does not return a character serial, item ID or shard connection ID.
- `Milliseconds()` — Milliseconds() has no arguments. Returns Double in 0..4294967295, representing the unsigned 32-bit GetTickCount value. Negative signed native results have 4294967296.0 added. The counter wraps about every 49.7 days; it is neither calendar time nor a high-resolution benchmark clock.
- `ElapsedMilliseconds(startMilliseconds)` — ElapsedMilliseconds(startMilliseconds) takes a saved Milliseconds() value as Double and returns the elapsed Double count. Values outside 0..4294967295 raise a script error. One wrap is handled by adding 4294967296.0 to a negative difference. Measure intervals shorter than one wrap; this helper does not wait.
- `ScreenWidth() / ScreenHeight()` — ScreenWidth() and ScreenHeight() have no arguments and return Integer dimensions of the primary monitor from metrics 0 and 1. These are Windows desktop coordinates in the process’s DPI context, not UO map tiles or game-window dimensions.
- `DesktopBounds()` — DesktopBounds() has no arguments and returns a new Dictionary object with X, Y, Width, Height Integer values, read with Item("X") etc. The keys themselves are strings. Metrics 76–79 describe the bounding rectangle of all monitors; X and Y may be negative. Changing the Dictionary does not move or resize any window.

## Returns

ProcessId/ScreenWidth/ScreenHeight return Integer quantities. Milliseconds/ElapsedMilliseconds return Double millisecond quantities, not Boolean flags. DesktopBounds returns an Object (Dictionary); X/Y/Width/Height are Integer values. Include and declarations return no value. Main in each example returns 1/True after checking the returned data; 0/False means that check failed, not an automatic conversion of every native result.

## Behavior

- Requires the Windows x64 client. Private NativeTicks, NativeProcessId and NativeMetric are implemented by the three Declare lines shown in the module. DLL loading, errors and cleanup follow Basic.Declare. The module does not send game traffic, change client options or move the character.
- Each helper reads current system values. Milliseconds uses a coarse Windows tick counter, commonly updated every 10–16 ms. ElapsedMilliseconds cannot distinguish multiple wraps or values saved from a different system session. Use it for short script operations; no exact Wait duration is promised.
- Keep Main.bas and Include/Windows.bas together when copying an example. The source is editable in the IDE. Each DesktopBounds call creates an independent Dictionary snapshot; monitor layout or DPI changes can affect later results.

## Examples

### 1. Process and counter

```vb
# Main loads Windows.bas, calls ProcessId() without parameters and saves Milliseconds() in startedAt. The ID must be positive and the tick value must be in 0..4294967295. AndAlso short-circuits these checks; Main returns 1/True on valid values. Actual ID and ticks depend on the computer.
Option Explicit On
Include "Windows.bas"

Sub Main()
    Dim processId = Windows.ProcessId()
    Dim startedAt = Windows.Milliseconds()
    Return processId > 0 AndAlso startedAt >= 0 AndAlso startedAt <= 4294967295.0
End Sub
```

**Parameter and execution notes:**

Main loads Windows.bas, calls ProcessId() without parameters and saves Milliseconds() in startedAt. The ID must be positive and the tick value must be in 0..4294967295. AndAlso short-circuits these checks; Main returns 1/True on valid values. Actual ID and ticks depend on the computer.

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

### 2. Measure a cooperative wait

```vb
# MeasureWait(delayMilliseconds) rejects negative delays, saves the counter, calls Basic Wait(delayMilliseconds), then returns Windows.ElapsedMilliseconds(startMilliseconds:=startedAt). Main passes 15 and checks elapsed >= 0. The actual interval is system-dependent and may exceed 15 ms. All helper bodies are shown, including one-wrap handling.
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

**Parameter and execution notes:**

MeasureWait(delayMilliseconds) rejects negative delays, saves the counter, calls Basic Wait(delayMilliseconds), then returns Windows.ElapsedMilliseconds(startMilliseconds:=startedAt). Main passes 15 and checks elapsed >= 0. The actual interval is system-dependent and may exceed 15 ms. All helper bodies are shown, including one-wrap handling.

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

### 3. Read desktop geometry

```vb
# Main obtains an independent desktop Dictionary and reads X, Y, Width and Height through Item with exact key strings. It also reads the primary monitor dimensions. The result checks positive primary dimensions and that the whole desktop is at least as large. left/top may be negative; these are desktop coordinates and are not passed to UO movement commands.
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

**Parameter and execution notes:**

Main obtains an independent desktop Dictionary and reads X, Y, Width and Height through Item with exact key strings. It also reads the primary monitor dimensions. The result checks positive primary dimensions and that the whole desktop is at least as large. left/top may be negative; these are desktop coordinates and are not passed to UO movement commands.

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


### Internal functions: from call to result

Windows.bas is an editable Basic source module with six public helpers for process information, short interval measurement and desktop dimensions. Its complete code and private Declare statements are included below; copying only Main without the Include file is insufficient.

#### 1. ProcessId / Milliseconds

Milliseconds() has no arguments. Returns Double in 0..4294967295, representing the unsigned 32-bit GetTickCount value. Negative signed native results have 4294967296.0 added. The counter wraps about every 49.7 days; it is neither calendar time nor a high-resolution benchmark clock.

`GetTickCount -> signed Integer -> if negative add 4294967296.0 -> Double`

Project source: `src/ClassicUO.Client/Scripts/Include/Windows.bas`; function `ProcessId / Milliseconds`.

#### 2. ElapsedMilliseconds

ElapsedMilliseconds(startMilliseconds) takes a saved Milliseconds() value as Double and returns the elapsed Double count. Values outside 0..4294967295 raise a script error. One wrap is handled by adding 4294967296.0 to a negative difference. Measure intervals shorter than one wrap; this helper does not wait.

`validate start -> now - start -> if negative add one wrap -> Double`

Project source: `src/ClassicUO.Client/Scripts/Include/Windows.bas`; function `ElapsedMilliseconds`.

#### 3. ScreenWidth / ScreenHeight / DesktopBounds

DesktopBounds() has no arguments and returns a new Dictionary object with X, Y, Width, Height Integer values, read with Item("X") etc. The keys themselves are strings. Metrics 76–79 describe the bounding rectangle of all monitors; X and Y may be negative. Changing the Dictionary does not move or resize any window.

`metrics 0, 1: primary; 76, 77, 78, 79: desktop X, Y, Width, Height`

Project source: `src/ClassicUO.Client/Scripts/Include/Windows.bas`; function `ScreenWidth / ScreenHeight / DesktopBounds`.

ProcessId/ScreenWidth/ScreenHeight return Integer quantities. Milliseconds/ElapsedMilliseconds return Double millisecond quantities, not Boolean flags. DesktopBounds returns an Object (Dictionary); X/Y/Width/Height are Integer values. Include and declarations return no value. Main in each example returns 1/True after checking the returned data; 0/False means that check failed, not an automatic conversion of every native result.

<!-- implementation references (not callable script procedures):
src/ClassicUO.Client/Scripts/Include/Windows.bas: all declarations and helpers
Runtime/ExternalLibraries.cs: GetCallable / Invoke / Dispose
Parsing/ScriptSourceGraph.cs: Include resolution
https://learn.microsoft.com/en-us/windows/win32/api/sysinfoapi/nf-sysinfoapi-gettickcount
https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getsystemmetrics
-->
