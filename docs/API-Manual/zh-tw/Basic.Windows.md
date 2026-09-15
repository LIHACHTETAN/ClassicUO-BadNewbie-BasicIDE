# Windows.bas

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: zh-tw -->

Windows.bas 是可編輯的 Basic 原始碼模組，提供六個公開輔助函式，用於程序資訊、短時間測量和桌面尺寸。下方列出完整程式碼與私有 Declare；只複製 Main 不足以執行。

## 完整語法

```text
Include "Windows.bas"
Windows.ProcessId() As Integer
Windows.Milliseconds() As Double
Windows.ElapsedMilliseconds(ByVal startMilliseconds As Double) As Double
Windows.ScreenWidth() As Integer
Windows.ScreenHeight() As Integer
Windows.DesktopBounds() As Object
```

## 參數

- `Include / Windows.bas` — Include "Windows.bas" 載入 Scripts/Include/Windows.bas。使用獨立腳本資料夾時，將模組複製到該資料夾的 Include 子目錄。範例含 Main.bas 與 Include/Windows.bas。使用 Windows. 呼叫，不加 UO.；這是腳本模組。
- `ProcessId()` — ProcessId() 無引數，回傳目前客戶端的 Windows 程序 ID（Integer），不是角色、物品或伺服器連線 ID。
- `Milliseconds()` — Milliseconds() 無引數，回傳 Double 0..4294967295，表示無號32位元 GetTickCount。負的原生結果加4294967296.0。約每49.7天回繞；並非日曆時間或高精度計時器。
- `ElapsedMilliseconds(startMilliseconds)` — ElapsedMilliseconds(startMilliseconds) 接受先前 Milliseconds() 的 Double 值，回傳經過的毫秒數 Double。超出0..4294967295會出錯。差值為負時加4294967296.0，僅處理一次回繞。測量間隔必須小於一圈，函式本身不等待。
- `ScreenWidth() / ScreenHeight()` — ScreenWidth()/ScreenHeight() 無引數，以指標0/1回傳主要螢幕的Integer尺寸，依程序DPI環境。不是UO地圖格數，也不是遊戲視窗大小。
- `DesktopBounds()` — DesktopBounds() 回傳新的 Dictionary，字串鍵 X、Y、Width、Height 對應 Integer 值，可用 Item("X") 等讀取。指標76–79涵蓋所有螢幕；X/Y可能為負。修改字典不會移動或調整視窗。

## 傳回值

ProcessId與螢幕尺寸是Integer數量；時間是Double毫秒數，並非Boolean旗標。DesktopBounds是Object（Dictionary），四個值均為Integer。Include與宣告無回傳值。各範例Main檢查資料後回傳1/True，0/False表示檢查失敗，不是所有原生數字都自動表示成功與否。

## 行為

- 需要Windows x64。NativeTicks、NativeProcessId、NativeMetric是下方三個私有Declare。DLL規則請見Basic.Declare。本模組不傳送遊戲封包、不改設定、不移動角色。
- 每次讀取目前系統資料。Milliseconds通常每10–16毫秒更新，無法識別多次回繞或另一Windows工作階段的數值。用於短操作；Wait不保證精確等待時間。
- 複製Main.bas時也複製Include/Windows.bas，程式碼可在IDE編輯。DesktopBounds每次產生獨立快照；螢幕配置或DPI變更會影響後續結果。

## 範例

### 1. 程序與計數器

```vb
# Main載入Windows.bas，呼叫ProcessId()，將Milliseconds()存入startedAt。AndAlso檢查ID為正及計數器位於0..4294967295，成功回傳1/True。實際數字依電腦而異。
Option Explicit On
Include "Windows.bas"

Sub Main()
    Dim processId = Windows.ProcessId()
    Dim startedAt = Windows.Milliseconds()
    Return processId > 0 AndAlso startedAt >= 0 AndAlso startedAt <= 4294967295.0
End Sub
```

**參數與執行說明:**

Main載入Windows.bas，呼叫ProcessId()，將Milliseconds()存入startedAt。AndAlso檢查ID為正及計數器位於0..4294967295，成功回傳1/True。實際數字依電腦而異。

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

### 2. 測量等待

```vb
# MeasureWait(delayMilliseconds)拒絕負數，保存計數器，執行Wait，再回傳ElapsedMilliseconds(startMilliseconds:=startedAt)。Main傳入15並檢查elapsed >= 0；實際等待可超過15毫秒。下方完整列出輔助函式與一次回繞處理。
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

**參數與執行說明:**

MeasureWait(delayMilliseconds)拒絕負數，保存計數器，執行Wait，再回傳ElapsedMilliseconds(startMilliseconds:=startedAt)。Main傳入15並檢查elapsed >= 0；實際等待可超過15毫秒。下方完整列出輔助函式與一次回繞處理。

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

### 3. 桌面幾何

```vb
# Main從獨立的 Dictionary以Item讀取X/Y/Width/Height，並比較主要螢幕尺寸。主要尺寸必須為正，整個桌面至少同樣大。left/top可為負，這些座標不會送入UO移動命令。
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

**參數與執行說明:**

Main從獨立的 Dictionary以Item讀取X/Y/Width/Height，並比較主要螢幕尺寸。主要尺寸必須為正，整個桌面至少同樣大。left/top可為負，這些座標不會送入UO移動命令。

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


### 內部函式：從呼叫到結果

Windows.bas 是可編輯的 Basic 原始碼模組，提供六個公開輔助函式，用於程序資訊、短時間測量和桌面尺寸。下方列出完整程式碼與私有 Declare；只複製 Main 不足以執行。

#### 1. ProcessId / Milliseconds

Milliseconds() 無引數，回傳 Double 0..4294967295，表示無號32位元 GetTickCount。負的原生結果加4294967296.0。約每49.7天回繞；並非日曆時間或高精度計時器。

`GetTickCount -> signed Integer -> if negative add 4294967296.0 -> Double`

專案原始碼: `src/ClassicUO.Client/Scripts/Include/Windows.bas`; 函式 `ProcessId / Milliseconds`.

#### 2. ElapsedMilliseconds

ElapsedMilliseconds(startMilliseconds) 接受先前 Milliseconds() 的 Double 值，回傳經過的毫秒數 Double。超出0..4294967295會出錯。差值為負時加4294967296.0，僅處理一次回繞。測量間隔必須小於一圈，函式本身不等待。

`validate start -> now - start -> if negative add one wrap -> Double`

專案原始碼: `src/ClassicUO.Client/Scripts/Include/Windows.bas`; 函式 `ElapsedMilliseconds`.

#### 3. ScreenWidth / ScreenHeight / DesktopBounds

DesktopBounds() 回傳新的 Dictionary，字串鍵 X、Y、Width、Height 對應 Integer 值，可用 Item("X") 等讀取。指標76–79涵蓋所有螢幕；X/Y可能為負。修改字典不會移動或調整視窗。

`metrics 0, 1: primary; 76, 77, 78, 79: desktop X, Y, Width, Height`

專案原始碼: `src/ClassicUO.Client/Scripts/Include/Windows.bas`; 函式 `ScreenWidth / ScreenHeight / DesktopBounds`.

ProcessId與螢幕尺寸是Integer數量；時間是Double毫秒數，並非Boolean旗標。DesktopBounds是Object（Dictionary），四個值均為Integer。Include與宣告無回傳值。各範例Main檢查資料後回傳1/True，0/False表示檢查失敗，不是所有原生數字都自動表示成功與否。

<!-- implementation references (not callable script procedures):
src/ClassicUO.Client/Scripts/Include/Windows.bas: all declarations and helpers
Runtime/ExternalLibraries.cs: GetCallable / Invoke / Dispose
Parsing/ScriptSourceGraph.cs: Include resolution
https://learn.microsoft.com/en-us/windows/win32/api/sysinfoapi/nf-sysinfoapi-gettickcount
https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getsystemmetrics
-->
