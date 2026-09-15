# CreateTimer / script timers

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: zh-tw -->

CreateTimer 建立停止中的回呼計時器。Start 在同一個指令碼執行緒安排 Sub。這是專案擴充，與讀取經過秒數的 Basic Timer() 分開。

## 完整語法

```text
CreateTimer(milliseconds, handler) -> Object (ScriptTimer)
CreateTimer(milliseconds, handler, repeating) -> Object (ScriptTimer)
timer.Start() -> Unit
timer.Stop() -> Unit
timer.Dispose() -> Unit
timer.Enabled() -> Integer (0/1)
timer.Interval() -> Integer (ms)
timer.SetInterval(milliseconds) -> Unit
Using timer ... End Using
```

## 參數

- `milliseconds` — milliseconds 為 1..2147483647 的 Integer 毫秒。字串、小數、零與負數都會出錯。SetInterval 規則相同。Interval() 傳回設定間隔，不是剩餘時間。
- `handler` — 指向唯一且完全沒有參數的 Sub 的 AddressOf，或目前載入指令碼的回呼變數／工廠。拒絕 Function、Optional/ParamArray、名稱字串與其他指令碼的參照。共用資料放在 Module 欄位；不擷取區域閉包。
- `repeating` — 可省略的第三個參數：True/1 重複，False/0 執行一次；預設 True。具名參數是 repeating:=。其他數字和字串會出錯。單次計時器在呼叫處理常式之前停用。
- `timer / Start / Stop / Dispose / SetInterval` — 方法：Start、Stop、Dispose、Enabled、Interval、SetInterval(milliseconds)。已啟用時 Start 不改變任何狀態。Stop 後可再 Start。SetInterval 對啟用計時器從現在重新計時；停止中的仍停止。Dispose 可重複呼叫且永久釋放，之後 Start/SetInterval 失敗。Using 在離開時釋放擷取的物件。

## 傳回值

CreateTimer 傳回 Object（ScriptTimer），不是物品 ID 或指令碼索引。Start/Stop/Dispose/SetInterval 傳回 Unit。Enabled 傳回 Integer 1=True 或 0=False，可用兩種形式比較。Interval 是毫秒而非 Boolean。範例結果為 String "3:0"、"ready:0"、"tick failed:0"。

## 行為

- 在陳述式之間及 Basic Wait/Sleep、Wait Until 內檢查單調經過時間。有啟用計時器時，Wait 分成最多25毫秒的片段。遊戲 API 或其他阻塞原生呼叫必須先返回。沒有即時精確度保證，也不建立新執行緒。
- 依到期時間排序，相同時依建立順序；每次檢查最多64個處理常式，其他留到下一次。處理常式執行期間不重新進入其他計時器，即使它使用 Wait。重複間隔從完成後計算，錯過的次數不累積。暫停會停止呼叫；恢復時逾期計時器執行一次。
- 處理常式錯誤會停用計時器並傳到呼叫端 Catch/Finally。處理常式中的 Stop/SetInterval 會生效。緊急停止不會被一般 Catch 吞掉。最外層執行結束、錯誤或停止時釋放所有計時器；重跑／重載必須重建。只關閉 IDE 會保留執行中指令碼的計時器。最多1024個未釋放物件，Dispose 會歸還名額。
- RunThreePulses 與 GetHandler 是完整列出的範例輔助函式。內部 CreateTimer 驗證參數與擁有者，Start 記錄期限，Pump 呼叫 Sub，Fire 在完成後設定下個期限，Release 在最外層呼叫結束時釋放。指令碼結束後不留下獨立服務。

## 範例

### 1. 三次呼叫與清理

```vb
# RunThreePulses 使用20毫秒及預設 repeating=True。CountPulse 增加 State.count，到3時停止。Wait Until 在3000毫秒內檢查狀態與計時器。Enabled()=0，因此傳回 "3:0"。即使 Return，Using 仍釋放物件。
Option Explicit On
Module State
    Public Dim count As Integer = 0
    Public Dim pulse
End Module

Sub CountPulse()
    State.count += 1
    If State.count >= 3 Then
        State.pulse.Stop()
    End If
End Sub

Function RunThreePulses() As String
    State.pulse = CreateTimer(20, AddressOf CountPulse)
    Using State.pulse
        State.pulse.Start()
        Wait Until State.count >= 3 Timeout 3000
        Return CStr(State.count) & ":" & CStr(State.pulse.Enabled())
    End Using
End Function

Sub Main()
    Return RunThreePulses()
End Sub
```

**參數與執行說明:**

RunThreePulses 使用20毫秒及預設 repeating=True。CountPulse 增加 State.count，到3時停止。Wait Until 在3000毫秒內檢查狀態與計時器。Enabled()=0，因此傳回 "3:0"。即使 Return，Using 仍釋放物件。

### 2. 單次回呼與具名參數

```vb
# GetHandler 傳回 AddressOf SetReady。具名參數設定5毫秒、callback、repeating=False。SetInterval 在 Start 前改成10。SetReady 儲存 "ready" 時，計時器已停用。Main 最多等3000毫秒並傳回 "ready:0"。所有輔助函式均完整列出。
Option Explicit On
Module State
    Public Dim message As String = ""
End Module

Sub SetReady()
    State.message = "ready"
End Sub

Function GetHandler()
    Return AddressOf SetReady
End Function

Sub Main()
    Dim callback = GetHandler()
    Dim notice = CreateTimer(repeating:=False, handler:=callback, milliseconds:=5)
    Using notice
        notice.SetInterval(10)
        notice.Start()
        Wait Until State.message = "ready" Timeout 3000
        Return State.message & ":" & CStr(notice.Enabled())
    End Using
End Sub
```

**參數與執行說明:**

GetHandler 傳回 AddressOf SetReady。具名參數設定5毫秒、callback、repeating=False。SetInterval 在 Start 前改成10。SetReady 儲存 "ready" 時，計時器已停用。Main 最多等3000毫秒並傳回 "ready:0"。所有輔助函式均完整列出。

### 3. Wait 期間的錯誤

```vb
# FailingPulse 擲出 "tick failed"。5毫秒計時器在 Wait(2000) 內執行，停用並中斷等待。Catch 讀取文字與 Enabled()=0，Finally 釋放。"tick failed:0" 包含訊息與狀態。緊急停止由引擎處理。
Option Explicit On
Sub FailingPulse()
    Throw "tick failed"
End Sub

Sub Main()
    Dim pulse = CreateTimer(5, AddressOf FailingPulse)
    Dim problemText As String = ""
    Dim enabledAfterError As Boolean = True
    Try
        pulse.Start()
        Wait(2000)
    Catch problem
        problemText = problem
        enabledAfterError = pulse.Enabled()
    Finally
        pulse.Dispose()
    End Try
    Return problemText & ":" & CStr(enabledAfterError)
End Sub
```

**參數與執行說明:**

FailingPulse 擲出 "tick failed"。5毫秒計時器在 Wait(2000) 內執行，停用並中斷等待。Catch 讀取文字與 Enabled()=0，Finally 釋放。"tick failed:0" 包含訊息與狀態。緊急停止由引擎處理。


### 內部函式：從呼叫到結果

RunThreePulses 與 GetHandler 是完整列出的範例輔助函式。內部 CreateTimer 驗證參數與擁有者，Start 記錄期限，Pump 呼叫 Sub，Fire 在完成後設定下個期限，Release 在最外層呼叫結束時釋放。指令碼結束後不留下獨立服務。

#### 1. CreateTimer

milliseconds 為 1..2147483647 的 Integer 毫秒。字串、小數、零與負數都會出錯。SetInterval 規則相同。Interval() 傳回設定間隔，不是剩餘時間。

指向唯一且完全沒有參數的 Sub 的 AddressOf，或目前載入指令碼的回呼變數／工廠。拒絕 Function、Optional/ParamArray、名稱字串與其他指令碼的參照。共用資料放在 Module 欄位；不擷取區域閉包。

可省略的第三個參數：True/1 重複，False/0 執行一次；預設 True。具名參數是 repeating:=。其他數字和字串會出錯。單次計時器在呼叫處理常式之前停用。

CreateTimer 傳回 Object（ScriptTimer），不是物品 ID 或指令碼索引。Start/Stop/Dispose/SetInterval 傳回 Unit。Enabled 傳回 Integer 1=True 或 0=False，可用兩種形式比較。Interval 是毫秒而非 Boolean。範例結果為 String "3:0"、"ready:0"、"tick failed:0"。

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Timers.cs`; 函式 `CreateTimer`.

#### 2. Start

方法：Start、Stop、Dispose、Enabled、Interval、SetInterval(milliseconds)。已啟用時 Start 不改變任何狀態。Stop 後可再 Start。SetInterval 對啟用計時器從現在重新計時；停止中的仍停止。Dispose 可重複呼叫且永久釋放，之後 Start/SetInterval 失敗。Using 在離開時釋放擷取的物件。

`Due = now + interval; enabled = true;`

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ScriptTimerObject.cs`; 函式 `Start`.

#### 3. WaitWithTimers

在陳述式之間及 Basic Wait/Sleep、Wait Until 內檢查單調經過時間。有啟用計時器時，Wait 分成最多25毫秒的片段。遊戲 API 或其他阻塞原生呼叫必須先返回。沒有即時精確度保證，也不建立新執行緒。

`checkpoint -> Pump -> min(remaining, nextDue, 25 ms) -> Wait`

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Timers.cs`; 函式 `WaitWithTimers`.

#### 4. Pump

依到期時間排序，相同時依建立順序；每次檢查最多64個處理常式，其他留到下一次。處理常式執行期間不重新進入其他計時器，即使它使用 Wait。重複間隔從完成後計算，錯過的次數不累積。暫停會停止呼叫；恢復時逾期計時器執行一次。

`snapshot -> deadline / sequence -> checkpoint -> Fire; limit = 64`

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/ScriptTimerScheduler.cs`; 函式 `Pump`.

#### 5. Fire

處理常式錯誤會停用計時器並傳到呼叫端 Catch/Finally。處理常式中的 Stop/SetInterval 會生效。緊急停止不會被一般 Catch 吞掉。最外層執行結束、錯誤或停止時釋放所有計時器；重跑／重載必須重建。只關閉 IDE 會保留執行中指令碼的計時器。最多1024個未釋放物件，Dispose 會歸還名額。

`callback -> completion -> next Due; error -> disabled -> throw`

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ScriptTimerObject.cs`; 函式 `Fire`.

#### 6. Dispose

方法：Start、Stop、Dispose、Enabled、Interval、SetInterval(milliseconds)。已啟用時 Start 不改變任何狀態。Stop 後可再 Start。SetInterval 對啟用計時器從現在重新計時；停止中的仍停止。Dispose 可重複呼叫且永久釋放，之後 Start/SetInterval 失敗。Using 在離開時釋放擷取的物件。

`Release -> scheduler.Remove -> Changed`

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ScriptTimerObject.cs`; 函式 `Dispose`.

#### 7. Release

處理常式錯誤會停用計時器並傳到呼叫端 Catch/Finally。處理常式中的 Stop/SetInterval 會生效。緊急停止不會被一般 Catch 吞掉。最外層執行結束、錯誤或停止時釋放所有計時器；重跑／重載必須重建。只關閉 IDE 會保留執行中指令碼的計時器。最多1024個未釋放物件，Dispose 會歸還名額。

`timer.Release for each handle -> timers.Clear -> no pending deadline`

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/ScriptTimerScheduler.cs`; 函式 `Release`.

RunThreePulses 使用20毫秒及預設 repeating=True。CountPulse 增加 State.count，到3時停止。Wait Until 在3000毫秒內檢查狀態與計時器。Enabled()=0，因此傳回 "3:0"。即使 Return，Using 仍釋放物件。

<!-- implementation references (not callable script procedures):
Runtime/InjectionApi.cs: CreateTimer / Wait
Runtime/Interpreter.Timers.cs: CreateTimer / WaitWithTimers / TimerCheckpoint
Runtime/ScriptTimerScheduler.cs: Pump / Delay / Release
Runtime/ObjectTypes/ScriptTimerObject.cs: Start / Fire / SetInterval / Dispose
Runtime/Interpreter.cs: statement checkpoints / VisitWaitUntilStatement / root-call cleanup
Runtime/RealTimeSource.cs: Stopwatch elapsed time
https://learn.microsoft.com/en-us/dotnet/api/system.diagnostics.stopwatch
https://learn.microsoft.com/en-us/dotnet/api/system.threading.timer (comparison only; this script timer does not use ThreadPool callbacks)
-->
