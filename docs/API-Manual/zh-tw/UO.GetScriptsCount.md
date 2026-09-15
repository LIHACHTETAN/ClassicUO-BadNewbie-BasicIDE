# UO.GetScriptsCount

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: zh-tw -->

計算此客戶端的有效執行數。

## 完整語法

```text
UO.GetScriptsCount() -> Integer
```

## 參數

沒有參數。

## 傳回值

Integer >= 0：有效執行數，包含暫停者。這是數量，不是 Boolean 或索引。

## 行為

- 包含執行中及暫停中的執行；排除已結束或已要求取消者。呼叫者通常也計算在內。僅載入 IDE 分頁不代表已執行。
- 索引是依啟動順序排列的目前位置。啟動／停止會使位置改變。多次呼叫不是同一個不可分割快照；之後下控制指令前應重新讀取清單。
- 關閉 Basic IDE 不會移除有效執行。這些指令僅查詢此客戶端，不涉及其他客戶端或 Windows 處理程序。
- GetScriptsList 提供索引，GetScriptsCount 提供數量，GetScriptState 提供三態狀態碼。不要混用，也不要把所有非零值視為 true。
- 沒有參數。計數不會排序清單，也不改變執行狀態。

### 內部函式：從呼叫到結果

以下列出客戶端的實際方法。Basic 範例包含完整輔助函式；內部 C# 方法名稱不是額外的腳本指令。

#### 1. ExecuteStealthCompatibility

Runtime 呼叫已註冊的 UO 指令，將橋接結果包裝為 Integer、String 或 Array。

Integer >= 0：有效執行數，包含暫停者。這是數量，不是 Boolean 或索引。

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 函式 `ExecuteStealthCompatibility`.

#### 2. GetScriptsCount

橋接層使用此客戶端的執行管理器。

沒有參數。計數不會排序清單，也不改變執行狀態。

專案原始碼: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 函式 `GetScriptsCount`.

#### 3. GetScriptsCount

`_running.Count(entry => !entry.Value.Cancellation.IsCancellationRequested)`

索引是依啟動順序排列的目前位置。啟動／停止會使位置改變。多次呼叫不是同一個不可分割快照；之後下控制指令前應重新讀取清單。

專案原始碼: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; 函式 `GetScriptsCount`.

關閉 Basic IDE 不會移除有效執行。這些指令僅查詢此客戶端，不涉及其他客戶端或 Windows 處理程序。


## 範例

### 第一次呼叫與結果

```vb
# 第一次呼叫與結果
#
# 計算此客戶端的有效執行數。
#
# Integer >= 0：有效執行數，包含暫停者。這是數量，不是 Boolean 或索引。

SUB Main()
    # 執行 Sub Main。傳入的 0 是索引；空括號代表沒有參數。Print 文字只是範例訊息。
    # 沒有參數。計數不會排序清單，也不改變執行狀態。
    # Integer >= 0：有效執行數，包含暫停者。這是數量，不是 Boolean 或索引。

    Dim count=UO.GetScriptsCount()
    UO.Print(CStr(count))
END SUB
```

**參數與執行說明:**

- 執行 Sub Main。傳入的 0 是索引；空括號代表沒有參數。Print 文字只是範例訊息。
- 沒有參數。計數不會排序清單，也不改變執行狀態。
- Integer >= 0：有效執行數，包含暫停者。這是數量，不是 Boolean 或索引。

### 在迴圈或條件中使用

```vb
# 在迴圈或條件中使用
#
# 計算此客戶端的有效執行數。
#
# Integer >= 0：有效執行數，包含暫停者。這是數量，不是 Boolean 或索引。

SUB Main()
    # 這是結合多個指令的獨立範例。陣列索引從零開始，存取前須檢查長度。範例若使用 Wait(250)，會等待 250 毫秒。
    # 沒有參數。計數不會排序清單，也不改變執行狀態。
    # Integer >= 0：有效執行數，包含暫停者。這是數量，不是 Boolean 或索引。

    Dim before=UO.GetScriptsCount()
    Wait(250)
    Dim after=UO.GetScriptsCount()
    UO.Print(CStr(after-before))
END SUB
```

**參數與執行說明:**

- 這是結合多個指令的獨立範例。陣列索引從零開始，存取前須檢查長度。範例若使用 Wait(250)，會等待 250 毫秒。
- 沒有參數。計數不會排序清單，也不改變執行狀態。
- Integer >= 0：有效執行數，包含暫停者。這是數量，不是 Boolean 或索引。

### 完整輔助函式

```vb
# 完整輔助函式
#
# 計算此客戶端的有效執行數。
#
# Integer >= 0：有效執行數，包含暫停者。這是數量，不是 Boolean 或索引。

SUB Main()
    # Main 下方列出完整函式。其參數與結果應與內部呼叫的 API 指令分開理解。
    # HasOtherScripts 與 1 比較，因為呼叫者通常占一筆。只有此輔助函式傳回 true/false，GetScriptsCount 仍傳回數量。
    # Integer >= 0：有效執行數，包含暫停者。這是數量，不是 Boolean 或索引。

    If HasOtherScripts() Then
        UO.Print("Other executions are active")
    Else
        UO.Print("No other active executions")
    End If
END SUB

Function HasOtherScripts() As Boolean
    Dim count=UO.GetScriptsCount()
    Return count > 1
End Function
```

**參數與執行說明:**

- Main 下方列出完整函式。其參數與結果應與內部呼叫的 API 指令分開理解。
- HasOtherScripts 與 1 比較，因為呼叫者通常占一筆。只有此輔助函式傳回 true/false，GetScriptsCount 仍傳回數量。
- Integer >= 0：有效執行數，包含暫停者。這是數量，不是 Boolean 或索引。
