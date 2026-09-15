# Windows.bas

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: de -->

Windows.bas ist ein bearbeitbares Basic-Modul mit sechs öffentlichen Helfern für Prozessdaten, kurze Zeitintervalle und Desktopgröße. Vollständiger Quelltext und private Declare-Anweisungen stehen unten; Main allein reicht nicht.

## Genaue Syntax

```text
Include "Windows.bas"
Windows.ProcessId() As Integer
Windows.Milliseconds() As Double
Windows.ElapsedMilliseconds(ByVal startMilliseconds As Double) As Double
Windows.ScreenWidth() As Integer
Windows.ScreenHeight() As Integer
Windows.DesktopBounds() As Object
```

## Parameter

- `Include / Windows.bas` — Include "Windows.bas" lädt Scripts/Include/Windows.bas. Bei einem eigenen Skriptordner die Bibliothek in dessen Include-Unterordner kopieren. Das Beispiel enthält Main.bas und Include/Windows.bas. Aufrufe mit Windows., ohne UO.; es ist ein Skriptmodul.
- `ProcessId()` — ProcessId() ohne Argumente liefert die Windows-Prozess-ID des Clients als Integer, keine UO-Seriennummer oder Verbindungs-ID.
- `Milliseconds()` — Milliseconds() liefert ohne Argumente Double in 0..4294967295: den vorzeichenlosen 32-Bit-GetTickCount. Negative native Ergebnisse werden um 4294967296.0 erhöht. Überlauf etwa alle 49,7 Tage; keine Kalenderzeit oder hochauflösende Messuhr.
- `ElapsedMilliseconds(startMilliseconds)` — ElapsedMilliseconds(startMilliseconds) erhält einen gespeicherten Milliseconds()-Wert als Double und liefert vergangene Millisekunden als Double. Außerhalb 0..4294967295 entsteht ein Skriptfehler. Eine negative Differenz wird um 4294967296.0 erhöht; nur ein Überlauf wird berücksichtigt. Intervall kürzer als ein Umlauf halten. Die Funktion wartet nicht.
- `ScreenWidth() / ScreenHeight()` — ScreenWidth()/ScreenHeight() ohne Argumente liefern Integer-Abmessungen des Hauptmonitors aus Metriken 0/1 im DPI-Kontext des Prozesses. Keine UO-Kacheln oder Größe des Spielfensters.
- `DesktopBounds()` — DesktopBounds() liefert ein neues Dictionary mit String-Schlüsseln X, Y, Width, Height und Integer-Werten, gelesen über Item("X") usw. Metriken 76–79 umfassen alle Monitore; X/Y können negativ sein. Änderungen am Dictionary verändern keine Fenster.

## Rückgabewert

Prozess-ID und Bildschirmgrößen sind Integer-Zahlen. Zeitwerte sind Double-Millisekunden, keine Boolean-Flags. DesktopBounds ist ein Object (Dictionary) mit Integer-Werten. Include und Deklarationen liefern nichts. Main liefert in jedem Beispiel 1/True nach erfolgreicher Prüfung; 0/False bedeutet eine fehlgeschlagene Prüfung, nicht die Bedeutung jedes nativen Zahlenwerts.

## Verhalten

- Windows x64 erforderlich. Die privaten NativeTicks, NativeProcessId und NativeMetric sind unten als Declare definiert. DLL-Verhalten siehe Basic.Declare. Kein Spielverkehr, keine geänderten Einstellungen oder Charakterbewegung.
- Es werden aktuelle Systemwerte gelesen. Milliseconds wird typischerweise alle 10–16 ms aktualisiert. Mehrere Überläufe oder Werte aus einer anderen Windows-Sitzung sind nicht erkennbar. Für kurze Vorgänge verwenden; Wait garantiert keine exakte Dauer.
- Main.bas gemeinsam mit Include/Windows.bas kopieren; Quelltext ist in der IDE bearbeitbar. DesktopBounds erstellt jeweils einen unabhängigen Schnappschuss. Monitoranordnung oder DPI-Änderungen beeinflussen spätere Ergebnisse.

## Beispiele

### 1. Prozess und Zähler

```vb
# Main lädt Windows.bas, liest ProcessId() und speichert Milliseconds() in startedAt. AndAlso prüft positive ID und den Bereich 0..4294967295. Ergebnis 1/True bei gültigen Daten; konkrete Werte hängen vom Rechner ab.
Option Explicit On
Include "Windows.bas"

Sub Main()
    Dim processId = Windows.ProcessId()
    Dim startedAt = Windows.Milliseconds()
    Return processId > 0 AndAlso startedAt >= 0 AndAlso startedAt <= 4294967295.0
End Sub
```

**Erläuterung der Parameter und Ausführung:**

Main lädt Windows.bas, liest ProcessId() und speichert Milliseconds() in startedAt. AndAlso prüft positive ID und den Bereich 0..4294967295. Ergebnis 1/True bei gültigen Daten; konkrete Werte hängen vom Rechner ab.

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

### 2. Wartezeit messen

```vb
# MeasureWait(delayMilliseconds) weist negative Werte ab, speichert den Zähler, ruft Wait auf und liefert ElapsedMilliseconds(startMilliseconds:=startedAt). Main übergibt 15 und prüft elapsed >= 0. Tatsächliche Dauer kann länger sein. Alle Helfer und die Überlaufbehandlung sind vollständig gezeigt.
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

**Erläuterung der Parameter und Ausführung:**

MeasureWait(delayMilliseconds) weist negative Werte ab, speichert den Zähler, ruft Wait auf und liefert ElapsedMilliseconds(startMilliseconds:=startedAt). Main übergibt 15 und prüft elapsed >= 0. Tatsächliche Dauer kann länger sein. Alle Helfer und die Überlaufbehandlung sind vollständig gezeigt.

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

### 3. Desktopgeometrie

```vb
# Main liest X/Y/Width/Height über Get aus einem eigenen Dictionary und vergleicht die Größen mit dem Hauptmonitor. Dessen Dimensionen müssen positiv, der gesamte Desktop mindestens so groß sein. left/top dürfen negativ sein und sind keine UO-Bewegungskoordinaten.
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

**Erläuterung der Parameter und Ausführung:**

Main liest X/Y/Width/Height über Get aus einem eigenen Dictionary und vergleicht die Größen mit dem Hauptmonitor. Dessen Dimensionen müssen positiv, der gesamte Desktop mindestens so groß sein. left/top dürfen negativ sein und sind keine UO-Bewegungskoordinaten.

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


### Interne Funktionen: vom Aufruf zum Ergebnis

Windows.bas ist ein bearbeitbares Basic-Modul mit sechs öffentlichen Helfern für Prozessdaten, kurze Zeitintervalle und Desktopgröße. Vollständiger Quelltext und private Declare-Anweisungen stehen unten; Main allein reicht nicht.

#### 1. ProcessId / Milliseconds

Milliseconds() liefert ohne Argumente Double in 0..4294967295: den vorzeichenlosen 32-Bit-GetTickCount. Negative native Ergebnisse werden um 4294967296.0 erhöht. Überlauf etwa alle 49,7 Tage; keine Kalenderzeit oder hochauflösende Messuhr.

`GetTickCount -> signed Integer -> if negative add 4294967296.0 -> Double`

Projektquelle: `src/ClassicUO.Client/Scripts/Include/Windows.bas`; Funktion `ProcessId / Milliseconds`.

#### 2. ElapsedMilliseconds

ElapsedMilliseconds(startMilliseconds) erhält einen gespeicherten Milliseconds()-Wert als Double und liefert vergangene Millisekunden als Double. Außerhalb 0..4294967295 entsteht ein Skriptfehler. Eine negative Differenz wird um 4294967296.0 erhöht; nur ein Überlauf wird berücksichtigt. Intervall kürzer als ein Umlauf halten. Die Funktion wartet nicht.

`validate start -> now - start -> if negative add one wrap -> Double`

Projektquelle: `src/ClassicUO.Client/Scripts/Include/Windows.bas`; Funktion `ElapsedMilliseconds`.

#### 3. ScreenWidth / ScreenHeight / DesktopBounds

DesktopBounds() liefert ein neues Dictionary mit String-Schlüsseln X, Y, Width, Height und Integer-Werten, gelesen über Item("X") usw. Metriken 76–79 umfassen alle Monitore; X/Y können negativ sein. Änderungen am Dictionary verändern keine Fenster.

`metrics 0, 1: primary; 76, 77, 78, 79: desktop X, Y, Width, Height`

Projektquelle: `src/ClassicUO.Client/Scripts/Include/Windows.bas`; Funktion `ScreenWidth / ScreenHeight / DesktopBounds`.

Prozess-ID und Bildschirmgrößen sind Integer-Zahlen. Zeitwerte sind Double-Millisekunden, keine Boolean-Flags. DesktopBounds ist ein Object (Dictionary) mit Integer-Werten. Include und Deklarationen liefern nichts. Main liefert in jedem Beispiel 1/True nach erfolgreicher Prüfung; 0/False bedeutet eine fehlgeschlagene Prüfung, nicht die Bedeutung jedes nativen Zahlenwerts.

<!-- implementation references (not callable script procedures):
src/ClassicUO.Client/Scripts/Include/Windows.bas: all declarations and helpers
Runtime/ExternalLibraries.cs: GetCallable / Invoke / Dispose
Parsing/ScriptSourceGraph.cs: Include resolution
https://learn.microsoft.com/en-us/windows/win32/api/sysinfoapi/nf-sysinfoapi-gettickcount
https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getsystemmetrics
-->
