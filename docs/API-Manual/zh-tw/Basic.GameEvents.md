# AddHandler UO.JournalEntry / client events

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: zh-tw -->

AddHandler 可訂閱新的日誌訊息、角色資源與連線狀態變化。這些 UO. 名稱是事件而不是函式，不可加括號呼叫或使用 RaiseEvent 觸發。

## 完整語法

```text
AddHandler UO.JournalEntry, AddressOf OnJournal
Sub OnJournal(ByVal text As String, ByVal serial As Integer, ByVal name As String, ByVal hue As Integer)
AddHandler UO.HitPointsChanged, AddressOf OnHits
AddHandler UO.ManaChanged, AddressOf OnMana
AddHandler UO.StaminaChanged, AddressOf OnStamina
Sub OnHits(ByVal current As Integer, ByVal previous As Integer)
Sub OnMana(ByVal current As Integer, ByVal previous As Integer)
Sub OnStamina(ByVal current As Integer, ByVal previous As Integer)
AddHandler UO.ConnectionChanged, AddressOf OnConnection
Sub OnConnection(ByVal online As Boolean)
RemoveHandler UO.JournalEntry, AddressOf OnJournal
```

## 參數

- `Handler / AddressOf` — 使用目前載入腳本中 Sub 的 AddressOf。全部參數都必須明確宣告 ByVal，型別及順序與簽章一致。不接受 Function、Optional、ParamArray 或其他腳本的回呼。
- `text / serial / name / hue` — JournalEntry 傳入 text String、serial Integer（來源 ID，無來源為 0）、name String 及 hue Integer（UO 色調索引，不是 RGB）。Serial 不是物品圖形/type。文字和名稱可能為空。日誌項目重用前會複製資料；只傳送訂閱後的新項目，也包含本機訊息。
- `current / previous` — HitPointsChanged/ManaChanged/StaminaChanged 的 current、previous 是 Integer，表示目前及先前的絕對點數，不是百分比或 Boolean。每次客戶端更新比較狀態，中間多次變化可能合併。初始狀態或更換角色會建立新基準，不發出資源變化事件。
- `online` — ConnectionChanged 的 online 是 Boolean：True/1 表示客戶端世界有角色與地圖，False/0 表示沒有。這不是遠端 socket 健康檢查。訂閱時不補送初始事件。
- `RemoveHandler` — RemoveHandler 移除最後一個符合的訂閱。重複訂閱會按順序重複執行。目前訊息使用固定處理程序清單，訂閱變更影響後續訊息。最後一個處理程序移除後會釋放佇列。

## 傳回值

AddHandler、RemoveHandler 和 Sub 不傳回值（Unit）。結果請存入共用 Module 欄位。只有 online 及邏輯判斷使用 1/0 = True/False；serial、hue、資源點數與 State.changes 是 ID 或數量。

## 行為

- 客戶端只將資料副本排入佇列。處理程序在所屬腳本執行緒執行，不並行；在陳述式之間及 Wait、Sleep、UO.Wait、Wait Until 中派送。檢查間隔至少 25 毫秒，每輪每事件最多 16 則訊息。耗時原生呼叫會延遲派送。
- 暫停時只累積訊息。Stop 取消執行並釋放訂閱，Catch 無法吞掉緊急停止。最外層程序返回或出錯會清除客戶端訂閱，下次執行重新開始。關閉 IDE 不會停止運行中的腳本。斷線自動暫停會將通知延後到恢復執行。
- 每個事件佇列最多 256 則訊息。溢位會產生可攔截錯誤並停用該訂閱，不會無聲丟棄。處理程序出錯也會停用事件並略過該訊息剩餘的處理程序；Catch/Finally 後可重新訂閱。避免將每則日誌訊息再印回同一本日誌。
- 僅 Full 且啟用 Basic IDE 時提供這五個事件。不包含其他事件、封包訂閱、Handles 或 WithEvents。腳本自行宣告的事件請見 Basic.Events。

## 範例

### 1. 比對新日誌

```vb
# OnJournal 接收四個參數。完整的 IsReadyMessage 使用 InStr > 0 判斷字串是否存在。本機示範訊息寫入 State.message。Wait Until 最多等 5000 毫秒，超時出錯。Finally 移除訂閱。Main 傳回 "ready: ore"。
Option Explicit On
Module State
    Public Dim matched As Boolean = False
    Public Dim message As String = ""
End Module

Function IsReadyMessage(ByVal text As String) As Boolean
    Return InStr(text, "ready: ore") > 0
End Function

Sub OnJournal(ByVal text As String, ByVal serial As Integer, ByVal name As String, ByVal hue As Integer)
    If IsReadyMessage(text) Then
        State.message = text
        State.matched = True
    End If
End Sub

Sub Main()
    AddHandler UO.JournalEntry, AddressOf OnJournal
    Try
        UO.AddToJournal("ready: ore")
        Wait Until State.matched Timeout 5000
    Finally
        RemoveHandler UO.JournalEntry, AddressOf OnJournal
    End Try
    Return State.message
End Sub
```

**參數與執行說明:**

OnJournal 接收四個參數。完整的 IsReadyMessage 使用 InStr > 0 判斷字串是否存在。本機示範訊息寫入 State.message。Wait Until 最多等 5000 毫秒，超時出錯。Finally 移除訂閱。Main 傳回 "ready: ore"。

### 2. 觀察資源

```vb
# 三個處理程序把 current/previous 傳給完整的 Remember。State.changes 計算通知，State.last 例如為 SP:58:60。Wait(250) 後，Wait Until 最多等待 5000 毫秒；沒有變化就超時。Finally 移除三個訂閱。結果是 String，不是 Boolean。
Option Explicit On
Module State
    Public Dim changes As Integer = 0
    Public Dim last As String = ""
End Module

Sub Remember(ByVal label As String, ByVal current As Integer, ByVal previous As Integer)
    State.changes += 1
    State.last = label & ":" & CStr(current) & ":" & CStr(previous)
End Sub

Sub OnHits(ByVal current As Integer, ByVal previous As Integer)
    Remember("HP", current, previous)
End Sub

Sub OnMana(ByVal current As Integer, ByVal previous As Integer)
    Remember("MP", current, previous)
End Sub

Sub OnStamina(ByVal current As Integer, ByVal previous As Integer)
    Remember("SP", current, previous)
End Sub

Sub Main()
    AddHandler UO.HitPointsChanged, AddressOf OnHits
    AddHandler UO.ManaChanged, AddressOf OnMana
    AddHandler UO.StaminaChanged, AddressOf OnStamina
    Try
        Wait(250)
        Wait Until State.changes > 0 Timeout 5000
    Finally
        RemoveHandler UO.HitPointsChanged, AddressOf OnHits
        RemoveHandler UO.ManaChanged, AddressOf OnMana
        RemoveHandler UO.StaminaChanged, AddressOf OnStamina
    End Try
    Return State.last
End Sub
```

**參數與執行說明:**

三個處理程序把 current/previous 傳給完整的 Remember。State.changes 計算通知，State.last 例如為 SP:58:60。Wait(250) 後，Wait Until 最多等待 5000 毫秒；沒有變化就超時。Finally 移除三個訂閱。結果是 String，不是 Boolean。

### 3. 觀察連線

```vb
# OnConnection 接收 Boolean online，計算 Wait(1000) 期間的狀態轉換。Finally 取消訂閱。Main 傳回數量：0 表示無變化，1 表示一次，並非 True。State.online 是最後收到的狀態，不是初始查詢。
Option Explicit On
Module State
    Public Dim changes As Integer = 0
    Public Dim online As Boolean = False
End Module

Sub OnConnection(ByVal online As Boolean)
    State.online = online
    State.changes += 1
End Sub

Sub Main()
    AddHandler UO.ConnectionChanged, AddressOf OnConnection
    Try
        Wait(1000)
    Finally
        RemoveHandler UO.ConnectionChanged, AddressOf OnConnection
    End Try
    Return State.changes
End Sub
```

**參數與執行說明:**

OnConnection 接收 Boolean online，計算 Wait(1000) 期間的狀態轉換。Finally 取消訂閱。Main 傳回數量：0 表示無變化，1 表示一次，並非 True。State.online 是最後收到的狀態，不是初始查詢。

<!-- implementation references (not callable script procedures):
Runtime/IScriptEventSource.cs: NativeScriptEvents / ScriptEventHub
Runtime/Interpreter.Events.cs: PumpClientEvents / ReleaseClientEvents
Runtime/Interpreter.Timers.cs: WaitWithTimers
Runtime/EventCatalog.cs: TryResolve / HandlerError
ClassicUO.Client/Game/Managers/YokoScriptEvents.cs: OnScriptJournalEntry / PublishScriptEvents
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/addhandler-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/removehandler-statement
-->
