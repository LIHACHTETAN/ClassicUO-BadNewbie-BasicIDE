# UO.GetScriptsList

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: zh-tw -->

傳回目前的數字腳本索引。

## 完整語法

```text
UO.GetScriptsList() -> Array
```

## 參數

沒有參數。

## 傳回值

Integer 的 Array：索引 0..N-1，或空陣列。元素是數字，不是名稱或文字記錄。

## 行為

- 包含執行中及暫停中的執行；排除已結束或已要求取消者。呼叫者通常也計算在內。僅載入 IDE 分頁不代表已執行。
- 索引是依啟動順序排列的目前位置。啟動／停止會使位置改變。多次呼叫不是同一個不可分割快照；之後下控制指令前應重新讀取清單。
- 關閉 Basic IDE 不會移除有效執行。這些指令僅查詢此客戶端，不涉及其他客戶端或 Windows 處理程序。
- GetScriptsList 提供索引，GetScriptsCount 提供數量，GetScriptState 提供三態狀態碼。不要混用，也不要把所有非零值視為 true。
- 沒有參數。將每個數字傳給對應的名稱、路徑或狀態查詢指令。傳回的陣列是獨立快照；修改它不會控制腳本。

### 內部函式：從呼叫到結果

以下列出客戶端的實際方法。Basic 範例包含完整輔助函式；內部 C# 方法名稱不是額外的腳本指令。

#### 1. ExecuteStealthCompatibility

Runtime 呼叫已註冊的 UO 指令，將橋接結果包裝為 Integer、String 或 Array。

Integer 的 Array：索引 0..N-1，或空陣列。元素是數字，不是名稱或文字記錄。

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 函式 `ExecuteStealthCompatibility`.

#### 2. GetScriptsList

橋接層使用此客戶端的執行管理器。

沒有參數。將每個數字傳給對應的名稱、路徑或狀態查詢指令。傳回的陣列是獨立快照；修改它不會控制腳本。

專案原始碼: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 函式 `GetScriptsList`.

#### 3. GetScriptsList

`Enumerable.Range(0, GetScriptsCount()).ToArray()`

索引是依啟動順序排列的目前位置。啟動／停止會使位置改變。多次呼叫不是同一個不可分割快照；之後下控制指令前應重新讀取清單。

專案原始碼: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; 函式 `GetScriptsList`.

關閉 Basic IDE 不會移除有效執行。這些指令僅查詢此客戶端，不涉及其他客戶端或 Windows 處理程序。


## 範例

### 第一次呼叫與結果

```vb
# 第一次呼叫與結果
#
# 傳回目前的數字腳本索引。
#
# Integer 的 Array：索引 0..N-1，或空陣列。元素是數字，不是名稱或文字記錄。

SUB Main()
    # 執行 Sub Main。傳入的 0 是索引；空括號代表沒有參數。Print 文字只是範例訊息。
    # 沒有參數。將每個數字傳給對應的名稱、路徑或狀態查詢指令。傳回的陣列是獨立快照；修改它不會控制腳本。
    # Integer 的 Array：索引 0..N-1，或空陣列。元素是數字，不是名稱或文字記錄。

    Dim indices=UO.GetScriptsList()
    For Each index In indices
        UO.Print(CStr(index) & ": " & UO.GetScriptName(index))
    Next
END SUB
```

**參數與執行說明:**

- 執行 Sub Main。傳入的 0 是索引；空括號代表沒有參數。Print 文字只是範例訊息。
- 沒有參數。將每個數字傳給對應的名稱、路徑或狀態查詢指令。傳回的陣列是獨立快照；修改它不會控制腳本。
- Integer 的 Array：索引 0..N-1，或空陣列。元素是數字，不是名稱或文字記錄。

### 在迴圈或條件中使用

```vb
# 在迴圈或條件中使用
#
# 傳回目前的數字腳本索引。
#
# Integer 的 Array：索引 0..N-1，或空陣列。元素是數字，不是名稱或文字記錄。

SUB Main()
    # 這是結合多個指令的獨立範例。陣列索引從零開始，存取前須檢查長度。範例若使用 Wait(250)，會等待 250 毫秒。
    # 沒有參數。將每個數字傳給對應的名稱、路徑或狀態查詢指令。傳回的陣列是獨立快照；修改它不會控制腳本。
    # Integer 的 Array：索引 0..N-1，或空陣列。元素是數字，不是名稱或文字記錄。

    Dim indices=UO.GetScriptsList()
    If GetArrayLength(indices)>0 Then
        Dim firstIndex=indices[0]
        UO.Print(UO.GetScriptPath(firstIndex))
    End If
END SUB
```

**參數與執行說明:**

- 這是結合多個指令的獨立範例。陣列索引從零開始，存取前須檢查長度。範例若使用 Wait(250)，會等待 250 毫秒。
- 沒有參數。將每個數字傳給對應的名稱、路徑或狀態查詢指令。傳回的陣列是獨立快照；修改它不會控制腳本。
- Integer 的 Array：索引 0..N-1，或空陣列。元素是數字，不是名稱或文字記錄。

### 完整輔助函式

```vb
# 完整輔助函式
#
# 傳回目前的數字腳本索引。
#
# Integer 的 Array：索引 0..N-1，或空陣列。元素是數字，不是名稱或文字記錄。

SUB Main()
    # Main 下方列出完整函式。其參數與結果應與內部呼叫的 API 指令分開理解。
    # FindNamedScript 傳回目前第一個顯示名稱完全相符的索引，否則為 -1。名稱可能重複，索引之後也可能改變。
    # Integer 的 Array：索引 0..N-1，或空陣列。元素是數字，不是名稱或文字記錄。

    Dim index=FindNamedScript("Mining")
    If index>=0 Then
        UO.Print(CStr(index))
    Else
        UO.Print("Name not found")
    End If
END SUB

Function FindNamedScript(wanted) As Integer
    Dim indices=UO.GetScriptsList()
    For Each index In indices
        If UO.GetScriptName(index)=wanted Then
            Return index
        End If
    Next
    Return -1
End Function
```

**參數與執行說明:**

- Main 下方列出完整函式。其參數與結果應與內部呼叫的 API 指令分開理解。
- FindNamedScript 傳回目前第一個顯示名稱完全相符的索引，否則為 -1。名稱可能重複，索引之後也可能改變。
- Integer 的 Array：索引 0..N-1，或空陣列。元素是數字，不是名稱或文字記錄。
