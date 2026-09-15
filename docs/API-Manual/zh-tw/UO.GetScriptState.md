# UO.GetScriptState

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: zh-tw -->

依索引讀取執行狀態。

## 完整語法

```text
UO.GetScriptState(ScriptIndex:Any) -> Integer
```

## 參數

- `ScriptIndex` — 必填 ScriptIndex：從最新 GetScriptsList 取得、由零開始的整數索引。負值或不存在的索引會傳回上述空值／未知狀態。不可傳入物品 serial、程序名稱或 IDE 執行 ID。

## 傳回值

Integer 狀態碼：0 = 不存在／未知，1 = 執行中，2 = 暫停。不是 Boolean，請明確與 1 或 2 比較。

## 行為

- 包含執行中及暫停中的執行；排除已結束或已要求取消者。呼叫者通常也計算在內。僅載入 IDE 分頁不代表已執行。
- 索引是依啟動順序排列的目前位置。啟動／停止會使位置改變。多次呼叫不是同一個不可分割快照；之後下控制指令前應重新讀取清單。
- 關閉 Basic IDE 不會移除有效執行。這些指令僅查詢此客戶端，不涉及其他客戶端或 Windows 處理程序。
- GetScriptsList 提供索引，GetScriptsCount 提供數量，GetScriptState 提供三態狀態碼。不要混用，也不要把所有非零值視為 true。
- 包含手動／偵錯暫停，以及設定的斷線暫停。狀態 1 不保證此刻正在使用 CPU 或接收伺服器資料。

### 內部函式：從呼叫到結果

以下列出客戶端的實際方法。Basic 範例包含完整輔助函式；內部 C# 方法名稱不是額外的腳本指令。

#### 1. ExecuteStealthCompatibility

Runtime 呼叫已註冊的 UO 指令，將橋接結果包裝為 Integer、String 或 Array。

Integer 狀態碼：0 = 不存在／未知，1 = 執行中，2 = 暫停。不是 Boolean，請明確與 1 或 2 比較。

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 函式 `ExecuteStealthCompatibility`.

#### 2. GetScriptState

橋接層使用此客戶端的執行管理器。

包含手動／偵錯暫停，以及設定的斷線暫停。狀態 1 不保證此刻正在使用 CPU 或接收伺服器資料。

專案原始碼: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 函式 `GetScriptState`.

#### 3. GetScriptState

`script == null ? 0 : script.IsPaused ? 2 : 1`

索引是依啟動順序排列的目前位置。啟動／停止會使位置改變。多次呼叫不是同一個不可分割快照；之後下控制指令前應重新讀取清單。

專案原始碼: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; 函式 `GetScriptState`.

關閉 Basic IDE 不會移除有效執行。這些指令僅查詢此客戶端，不涉及其他客戶端或 Windows 處理程序。


## 範例

### 第一次呼叫與結果

```vb
# 第一次呼叫與結果
#
# 依索引讀取執行狀態。
#
# Integer 狀態碼：0 = 不存在／未知，1 = 執行中，2 = 暫停。不是 Boolean，請明確與 1 或 2 比較。

SUB Main()
    # 執行 Sub Main。傳入的 0 是索引；空括號代表沒有參數。Print 文字只是範例訊息。
    # 包含手動／偵錯暫停，以及設定的斷線暫停。狀態 1 不保證此刻正在使用 CPU 或接收伺服器資料。
    # Integer 狀態碼：0 = 不存在／未知，1 = 執行中，2 = 暫停。不是 Boolean，請明確與 1 或 2 比較。
    # 必填 ScriptIndex：從最新 GetScriptsList 取得、由零開始的整數索引。負值或不存在的索引會傳回上述空值／未知狀態。不可傳入物品 serial、程序名稱或 IDE
    # 執行 ID。

    Dim state=UO.GetScriptState(0)
    Select Case state
    Case 1
        UO.Print("running")
    Case 2
        UO.Print("paused")
    Case Else
        UO.Print("unknown")
    End Select
END SUB
```

**參數與執行說明:**

- 執行 Sub Main。傳入的 0 是索引；空括號代表沒有參數。Print 文字只是範例訊息。
- 包含手動／偵錯暫停，以及設定的斷線暫停。狀態 1 不保證此刻正在使用 CPU 或接收伺服器資料。
- Integer 狀態碼：0 = 不存在／未知，1 = 執行中，2 = 暫停。不是 Boolean，請明確與 1 或 2 比較。
- 必填 ScriptIndex：從最新 GetScriptsList 取得、由零開始的整數索引。負值或不存在的索引會傳回上述空值／未知狀態。不可傳入物品 serial、程序名稱或 IDE 執行 ID。

### 在迴圈或條件中使用

```vb
# 在迴圈或條件中使用
#
# 依索引讀取執行狀態。
#
# Integer 狀態碼：0 = 不存在／未知，1 = 執行中，2 = 暫停。不是 Boolean，請明確與 1 或 2 比較。

SUB Main()
    # 這是結合多個指令的獨立範例。陣列索引從零開始，存取前須檢查長度。範例若使用 Wait(250)，會等待 250 毫秒。
    # 包含手動／偵錯暫停，以及設定的斷線暫停。狀態 1 不保證此刻正在使用 CPU 或接收伺服器資料。
    # Integer 狀態碼：0 = 不存在／未知，1 = 執行中，2 = 暫停。不是 Boolean，請明確與 1 或 2 比較。
    # 必填 ScriptIndex：從最新 GetScriptsList 取得、由零開始的整數索引。負值或不存在的索引會傳回上述空值／未知狀態。不可傳入物品 serial、程序名稱或 IDE
    # 執行 ID。

    Dim paused=0
    Dim indices=UO.GetScriptsList()
    For Each index In indices
        If UO.GetScriptState(index)=2 Then
            paused+=1
        End If
    Next
    UO.Print(CStr(paused))
END SUB
```

**參數與執行說明:**

- 這是結合多個指令的獨立範例。陣列索引從零開始，存取前須檢查長度。範例若使用 Wait(250)，會等待 250 毫秒。
- 包含手動／偵錯暫停，以及設定的斷線暫停。狀態 1 不保證此刻正在使用 CPU 或接收伺服器資料。
- Integer 狀態碼：0 = 不存在／未知，1 = 執行中，2 = 暫停。不是 Boolean，請明確與 1 或 2 比較。
- 必填 ScriptIndex：從最新 GetScriptsList 取得、由零開始的整數索引。負值或不存在的索引會傳回上述空值／未知狀態。不可傳入物品 serial、程序名稱或 IDE 執行 ID。

### 完整輔助函式

```vb
# 完整輔助函式
#
# 依索引讀取執行狀態。
#
# Integer 狀態碼：0 = 不存在／未知，1 = 執行中，2 = 暫停。不是 Boolean，請明確與 1 或 2 比較。

SUB Main()
    # Main 下方列出完整函式。其參數與結果應與內部呼叫的 API 指令分開理解。
    # IsScriptActive 將 1、2 轉為 true，0 轉為 false。GetScriptState 本身仍傳回數字狀態碼。
    # Integer 狀態碼：0 = 不存在／未知，1 = 執行中，2 = 暫停。不是 Boolean，請明確與 1 或 2 比較。
    # 必填 ScriptIndex：從最新 GetScriptsList 取得、由零開始的整數索引。負值或不存在的索引會傳回上述空值／未知狀態。不可傳入物品 serial、程序名稱或 IDE
    # 執行 ID。

    If IsScriptActive(0)=True Then
        UO.Print("running or paused")
    Else
        UO.Print("not active")
    End If
END SUB

Function IsScriptActive(index) As Boolean
    Dim state=UO.GetScriptState(index)
    Return state=1 OrElse state=2
End Function
```

**參數與執行說明:**

- Main 下方列出完整函式。其參數與結果應與內部呼叫的 API 指令分開理解。
- IsScriptActive 將 1、2 轉為 true，0 轉為 false。GetScriptState 本身仍傳回數字狀態碼。
- Integer 狀態碼：0 = 不存在／未知，1 = 執行中，2 = 暫停。不是 Boolean，請明確與 1 或 2 比較。
- 必填 ScriptIndex：從最新 GetScriptsList 取得、由零開始的整數索引。負值或不存在的索引會傳回上述空值／未知狀態。不可傳入物品 serial、程序名稱或 IDE 執行 ID。
