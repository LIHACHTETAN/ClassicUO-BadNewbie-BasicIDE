# Windows.bas

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ja -->

Windows.bas は編集可能な Basic モジュールで、プロセス情報、短い時間測定、デスクトップ寸法の6個の公開関数を提供します。全ソースとPrivate Declareを下に示します。Mainだけのコピーでは実行できません。

## 正確な構文

```text
Include "Windows.bas"
Windows.ProcessId() As Integer
Windows.Milliseconds() As Double
Windows.ElapsedMilliseconds(ByVal startMilliseconds As Double) As Double
Windows.ScreenWidth() As Integer
Windows.ScreenHeight() As Integer
Windows.DesktopBounds() As Object
```

## パラメーター

- `Include / Windows.bas` — Include "Windows.bas"でScripts/Include/Windows.basを読み込みます。別のスクリプトフォルダーではIncludeサブフォルダーにコピーします。例にはMain.basとInclude/Windows.basが含まれます。Windows.で呼び、UO.は付けません。
- `ProcessId()` — ProcessId()は引数なしで現在のクライアントのWindowsプロセスIDをIntegerで返します。キャラクター、アイテム、サーバー接続IDではありません。
- `Milliseconds()` — Milliseconds()は引数なしで0..4294967295のDoubleを返し、符号なし32ビットGetTickCountを表します。ネイティブ結果が負なら4294967296.0を加えます。約49.7日で一周します。暦時刻でも高精度測定器でもありません。
- `ElapsedMilliseconds(startMilliseconds)` — ElapsedMilliseconds(startMilliseconds)は保存したMilliseconds()のDouble値を受け取り、経過ミリ秒をDoubleで返します。0..4294967295の範囲外はエラーです。差が負なら4294967296.0を加えて1回の周回を処理します。測定間隔は一周より短くしてください。関数自体は待機しません。
- `ScreenWidth() / ScreenHeight()` — ScreenWidth()/ScreenHeight()は引数なしで主要モニターのInteger寸法をメトリック0/1から取得します。プロセスのDPI環境によるWindows座標であり、UOタイルやゲームウィンドウ寸法ではありません。
- `DesktopBounds()` — DesktopBounds()は新しいDictionaryを返し、文字列キーX、Y、Width、HeightにInteger値を格納します。Item("X")などで読みます。メトリック76～79は全モニターを囲む矩形で、X/Yは負の場合もあります。辞書の変更はウィンドウに影響しません。

## 戻り値

IDと画面寸法はInteger数量、時間はDoubleミリ秒数でBooleanではありません。DesktopBoundsはInteger値を持つObject（Dictionary）です。Includeと宣言は戻り値なしです。各例のMainは検査成功時に1/Trueを返します。0/Falseは検査失敗を表し、すべてのネイティブ数値が成功フラグという意味ではありません。

## 動作

- Windows x64が必要です。NativeTicks、NativeProcessId、NativeMetricは下の3個のPrivate Declareです。DLLの規則はBasic.Declareを参照してください。ゲーム通信、設定変更、キャラクター移動は行いません。
- 毎回現在の値を読みます。Millisecondsの更新は通常10～16ミリ秒程度で、複数周回や別Windowsセッションの値は識別できません。短い操作の計測向けで、Waitの正確な時間は保証されません。
- Main.basとInclude/Windows.basを一緒にコピーし、IDEで編集できます。DesktopBoundsは毎回独立したスナップショットです。モニター配置やDPI変更により次の値が変わる場合があります。

## 使用例

### 1. プロセスとカウンター

```vb
# MainがWindows.basを読み、ProcessId()を呼び、Milliseconds()をstartedAtに保存します。AndAlsoでIDが正、カウンターが0..4294967295内と検査し1/Trueを返します。具体値は環境依存です。
Option Explicit On
Include "Windows.bas"

Sub Main()
    Dim processId = Windows.ProcessId()
    Dim startedAt = Windows.Milliseconds()
    Return processId > 0 AndAlso startedAt >= 0 AndAlso startedAt <= 4294967295.0
End Sub
```

**パラメーターと実行の説明:**

MainがWindows.basを読み、ProcessId()を呼び、Milliseconds()をstartedAtに保存します。AndAlsoでIDが正、カウンターが0..4294967295内と検査し1/Trueを返します。具体値は環境依存です。

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

### 2. 待機を測る

```vb
# MeasureWait(delayMilliseconds)は負値を拒否し、カウンター保存後にWaitを実行、ElapsedMilliseconds(startMilliseconds:=startedAt)を返します。Mainは15を渡しelapsed >= 0を検査します。実時間は15ミリ秒を超える場合があります。全補助関数と周回処理を示しています。
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

**パラメーターと実行の説明:**

MeasureWait(delayMilliseconds)は負値を拒否し、カウンター保存後にWaitを実行、ElapsedMilliseconds(startMilliseconds:=startedAt)を返します。Mainは15を渡しelapsed >= 0を検査します。実時間は15ミリ秒を超える場合があります。全補助関数と周回処理を示しています。

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

### 3. デスクトップ寸法

```vb
# Mainは独立したDictionaryからItemでX/Y/Width/Heightを読み、主要モニター寸法と比較します。主要寸法は正で、全デスクトップはそれ以上であることを検査します。left/topは負の場合もあり、UO移動座標には使いません。
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

**パラメーターと実行の説明:**

Mainは独立したDictionaryからItemでX/Y/Width/Heightを読み、主要モニター寸法と比較します。主要寸法は正で、全デスクトップはそれ以上であることを検査します。left/topは負の場合もあり、UO移動座標には使いません。

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


### 内部関数：呼び出しから結果まで

Windows.bas は編集可能な Basic モジュールで、プロセス情報、短い時間測定、デスクトップ寸法の6個の公開関数を提供します。全ソースとPrivate Declareを下に示します。Mainだけのコピーでは実行できません。

#### 1. ProcessId / Milliseconds

Milliseconds()は引数なしで0..4294967295のDoubleを返し、符号なし32ビットGetTickCountを表します。ネイティブ結果が負なら4294967296.0を加えます。約49.7日で一周します。暦時刻でも高精度測定器でもありません。

`GetTickCount -> signed Integer -> if negative add 4294967296.0 -> Double`

プロジェクトのソース: `src/ClassicUO.Client/Scripts/Include/Windows.bas`; 関数 `ProcessId / Milliseconds`.

#### 2. ElapsedMilliseconds

ElapsedMilliseconds(startMilliseconds)は保存したMilliseconds()のDouble値を受け取り、経過ミリ秒をDoubleで返します。0..4294967295の範囲外はエラーです。差が負なら4294967296.0を加えて1回の周回を処理します。測定間隔は一周より短くしてください。関数自体は待機しません。

`validate start -> now - start -> if negative add one wrap -> Double`

プロジェクトのソース: `src/ClassicUO.Client/Scripts/Include/Windows.bas`; 関数 `ElapsedMilliseconds`.

#### 3. ScreenWidth / ScreenHeight / DesktopBounds

DesktopBounds()は新しいDictionaryを返し、文字列キーX、Y、Width、HeightにInteger値を格納します。Item("X")などで読みます。メトリック76～79は全モニターを囲む矩形で、X/Yは負の場合もあります。辞書の変更はウィンドウに影響しません。

`metrics 0, 1: primary; 76, 77, 78, 79: desktop X, Y, Width, Height`

プロジェクトのソース: `src/ClassicUO.Client/Scripts/Include/Windows.bas`; 関数 `ScreenWidth / ScreenHeight / DesktopBounds`.

IDと画面寸法はInteger数量、時間はDoubleミリ秒数でBooleanではありません。DesktopBoundsはInteger値を持つObject（Dictionary）です。Includeと宣言は戻り値なしです。各例のMainは検査成功時に1/Trueを返します。0/Falseは検査失敗を表し、すべてのネイティブ数値が成功フラグという意味ではありません。

<!-- implementation references (not callable script procedures):
src/ClassicUO.Client/Scripts/Include/Windows.bas: all declarations and helpers
Runtime/ExternalLibraries.cs: GetCallable / Invoke / Dispose
Parsing/ScriptSourceGraph.cs: Include resolution
https://learn.microsoft.com/en-us/windows/win32/api/sysinfoapi/nf-sysinfoapi-gettickcount
https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getsystemmetrics
-->
