# Windows.bas

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ko -->

Windows.bas는 프로세스 정보, 짧은 시간 측정, 데스크톱 크기를 위한 공개 함수 6개를 제공하는 편집 가능한 Basic 모듈입니다. 전체 코드와 Private Declare를 아래에 표시합니다. Main만 복사하면 실행되지 않습니다.

## 정확한 구문

```text
Include "Windows.bas"
Windows.ProcessId() As Integer
Windows.Milliseconds() As Double
Windows.ElapsedMilliseconds(ByVal startMilliseconds As Double) As Double
Windows.ScreenWidth() As Integer
Windows.ScreenHeight() As Integer
Windows.DesktopBounds() As Object
```

## 매개변수

- `Include / Windows.bas` — Include "Windows.bas"는 Scripts/Include/Windows.bas를 연결합니다. 별도 스크립트 폴더에서는 Include 하위 폴더에 복사하세요. 예제에는 Main.bas와 Include/Windows.bas가 포함됩니다. Windows.로 호출하며 UO.는 붙이지 않습니다.
- `ProcessId()` — ProcessId()는 인수 없이 현재 클라이언트의 Windows 프로세스 ID를 Integer로 반환합니다. 캐릭터·아이템 시리얼이나 서버 연결 ID가 아닙니다.
- `Milliseconds()` — Milliseconds()는 인수 없이 0..4294967295의 Double을 반환하며 부호 없는 32비트 GetTickCount를 나타냅니다. 음수인 네이티브 결과에는 4294967296.0을 더합니다. 약 49.7일마다 순환하며 달력 시간이나 고정밀 타이머가 아닙니다.
- `ElapsedMilliseconds(startMilliseconds)` — ElapsedMilliseconds(startMilliseconds)는 저장한 Milliseconds() 값을 Double로 받아 지난 밀리초를 Double로 반환합니다. 0..4294967295 밖이면 오류입니다. 음수 차이에 4294967296.0을 더해 한 번의 순환만 처리합니다. 측정은 한 주기보다 짧아야 하며 함수 자체는 기다리지 않습니다.
- `ScreenWidth() / ScreenHeight()` — ScreenWidth()/ScreenHeight()는 인수 없이 메트릭 0/1로 기본 모니터의 Integer 크기를 반환합니다. 프로세스 DPI 환경의 Windows 좌표이며 UO 타일이나 게임 창 크기가 아닙니다.
- `DesktopBounds()` — DesktopBounds()는 문자열 키 X, Y, Width, Height와 Integer 값을 가진 새 Dictionary를 반환합니다. Item("X") 등으로 읽습니다. 메트릭 76~79는 모든 모니터를 둘러싼 사각형이며 X/Y는 음수일 수 있습니다. 사전 수정은 창을 이동하거나 크기를 바꾸지 않습니다.

## 반환값

ID와 화면 크기는 Integer 수량, 시간은 Double 밀리초로 Boolean이 아닙니다. DesktopBounds는 Integer 값을 가진 Object(Dictionary)입니다. Include와 선언에는 결과가 없습니다. 각 예제 Main은 데이터 검사 성공 시 1/True, 실패 시 0/False를 반환하며 모든 네이티브 숫자가 성공 플래그라는 뜻은 아닙니다.

## 동작

- Windows x64가 필요합니다. NativeTicks, NativeProcessId, NativeMetric은 아래의 Private Declare 3개입니다. DLL 동작은 Basic.Declare를 참고하세요. 게임 패킷, 설정 변경, 캐릭터 이동은 없습니다.
- 매번 현재 값을 읽습니다. Milliseconds는 보통 10~16ms마다 갱신되며 여러 순환이나 다른 Windows 세션의 값은 구분할 수 없습니다. 짧은 작업에 사용하세요. Wait의 정확한 시간은 보장하지 않습니다.
- Main.bas와 Include/Windows.bas를 함께 복사하면 IDE에서 편집할 수 있습니다. DesktopBounds는 매번 독립된 스냅샷이며 모니터 구성이나 DPI 변경은 다음 결과에 영향을 줄 수 있습니다.

## 예제

### 1. 프로세스와 카운터

```vb
# Main은 Windows.bas를 연결하고 ProcessId()를 읽으며 Milliseconds()를 startedAt에 저장합니다. AndAlso로 양수 ID와 0..4294967295 범위를 검사해 1/True를 반환합니다. 실제 숫자는 컴퓨터마다 다릅니다.
Option Explicit On
Include "Windows.bas"

Sub Main()
    Dim processId = Windows.ProcessId()
    Dim startedAt = Windows.Milliseconds()
    Return processId > 0 AndAlso startedAt >= 0 AndAlso startedAt <= 4294967295.0
End Sub
```

**매개변수 및 실행 설명:**

Main은 Windows.bas를 연결하고 ProcessId()를 읽으며 Milliseconds()를 startedAt에 저장합니다. AndAlso로 양수 ID와 0..4294967295 범위를 검사해 1/True를 반환합니다. 실제 숫자는 컴퓨터마다 다릅니다.

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

### 2. 대기 시간 측정

```vb
# MeasureWait(delayMilliseconds)는 음수를 거부하고 카운터를 저장한 뒤 Wait를 실행하고 ElapsedMilliseconds(startMilliseconds:=startedAt)를 반환합니다. Main은 15를 전달하고 elapsed >= 0을 검사합니다. 실제 시간은 15ms보다 길 수 있습니다. 모든 보조 함수와 한 번의 순환 처리를 아래에 표시합니다.
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

**매개변수 및 실행 설명:**

MeasureWait(delayMilliseconds)는 음수를 거부하고 카운터를 저장한 뒤 Wait를 실행하고 ElapsedMilliseconds(startMilliseconds:=startedAt)를 반환합니다. Main은 15를 전달하고 elapsed >= 0을 검사합니다. 실제 시간은 15ms보다 길 수 있습니다. 모든 보조 함수와 한 번의 순환 처리를 아래에 표시합니다.

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

### 3. 데스크톱 크기

```vb
# Main은 독립된 Dictionary에서 Item으로 X/Y/Width/Height를 읽고 기본 모니터와 비교합니다. 기본 크기는 양수이고 전체 데스크톱이 더 작지 않아야 합니다. left/top은 음수일 수 있으며 UO 이동 명령으로 전달하지 않습니다.
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

**매개변수 및 실행 설명:**

Main은 독립된 Dictionary에서 Item으로 X/Y/Width/Height를 읽고 기본 모니터와 비교합니다. 기본 크기는 양수이고 전체 데스크톱이 더 작지 않아야 합니다. left/top은 음수일 수 있으며 UO 이동 명령으로 전달하지 않습니다.

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


### 내부 함수: 호출부터 결과까지

Windows.bas는 프로세스 정보, 짧은 시간 측정, 데스크톱 크기를 위한 공개 함수 6개를 제공하는 편집 가능한 Basic 모듈입니다. 전체 코드와 Private Declare를 아래에 표시합니다. Main만 복사하면 실행되지 않습니다.

#### 1. ProcessId / Milliseconds

Milliseconds()는 인수 없이 0..4294967295의 Double을 반환하며 부호 없는 32비트 GetTickCount를 나타냅니다. 음수인 네이티브 결과에는 4294967296.0을 더합니다. 약 49.7일마다 순환하며 달력 시간이나 고정밀 타이머가 아닙니다.

`GetTickCount -> signed Integer -> if negative add 4294967296.0 -> Double`

프로젝트 소스: `src/ClassicUO.Client/Scripts/Include/Windows.bas`; 함수 `ProcessId / Milliseconds`.

#### 2. ElapsedMilliseconds

ElapsedMilliseconds(startMilliseconds)는 저장한 Milliseconds() 값을 Double로 받아 지난 밀리초를 Double로 반환합니다. 0..4294967295 밖이면 오류입니다. 음수 차이에 4294967296.0을 더해 한 번의 순환만 처리합니다. 측정은 한 주기보다 짧아야 하며 함수 자체는 기다리지 않습니다.

`validate start -> now - start -> if negative add one wrap -> Double`

프로젝트 소스: `src/ClassicUO.Client/Scripts/Include/Windows.bas`; 함수 `ElapsedMilliseconds`.

#### 3. ScreenWidth / ScreenHeight / DesktopBounds

DesktopBounds()는 문자열 키 X, Y, Width, Height와 Integer 값을 가진 새 Dictionary를 반환합니다. Item("X") 등으로 읽습니다. 메트릭 76~79는 모든 모니터를 둘러싼 사각형이며 X/Y는 음수일 수 있습니다. 사전 수정은 창을 이동하거나 크기를 바꾸지 않습니다.

`metrics 0, 1: primary; 76, 77, 78, 79: desktop X, Y, Width, Height`

프로젝트 소스: `src/ClassicUO.Client/Scripts/Include/Windows.bas`; 함수 `ScreenWidth / ScreenHeight / DesktopBounds`.

ID와 화면 크기는 Integer 수량, 시간은 Double 밀리초로 Boolean이 아닙니다. DesktopBounds는 Integer 값을 가진 Object(Dictionary)입니다. Include와 선언에는 결과가 없습니다. 각 예제 Main은 데이터 검사 성공 시 1/True, 실패 시 0/False를 반환하며 모든 네이티브 숫자가 성공 플래그라는 뜻은 아닙니다.

<!-- implementation references (not callable script procedures):
src/ClassicUO.Client/Scripts/Include/Windows.bas: all declarations and helpers
Runtime/ExternalLibraries.cs: GetCallable / Invoke / Dispose
Parsing/ScriptSourceGraph.cs: Include resolution
https://learn.microsoft.com/en-us/windows/win32/api/sysinfoapi/nf-sysinfoapi-gettickcount
https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getsystemmetrics
-->
