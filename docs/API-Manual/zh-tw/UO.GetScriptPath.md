# UO.GetScriptPath

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: zh-tw -->

讀取某個有效執行的原始檔路徑。

## 完整語法

```text
UO.GetScriptPath(ScriptIndex:Any) -> String
```

## 參數

- `ScriptIndex` — 必填 ScriptIndex：從最新 GetScriptsList 取得、由零開始的整數索引。負值或不存在的索引會傳回上述空值／未知狀態。不可傳入物品 serial、程序名稱或 IDE 執行 ID。

## 傳回值

String：已記錄的原始檔路徑；找不到索引時為 ""。從檔案啟動通常具有完整路徑；指令或記憶體中的程式碼可能沒有一般檔案。

## 行為

- 包含執行中及暫停中的執行；排除已結束或已要求取消者。呼叫者通常也計算在內。僅載入 IDE 分頁不代表已執行。
- 索引是依啟動順序排列的目前位置。啟動／停止會使位置改變。多次呼叫不是同一個不可分割快照；之後下控制指令前應重新讀取清單。
- 關閉 Basic IDE 不會移除有效執行。這些指令僅查詢此客戶端，不涉及其他客戶端或 Windows 處理程序。
- GetScriptsList 提供索引，GetScriptsCount 提供數量，GetScriptState 提供三態狀態碼。不要混用，也不要把所有非零值視為 true。
- ScriptIndex=0 選擇目前第一個執行。此查詢只識別其原始檔，不會開啟、儲存或執行檔案。

### 內部函式：從呼叫到結果

以下列出客戶端的實際方法。Basic 範例包含完整輔助函式；內部 C# 方法名稱不是額外的腳本指令。

#### 1. ExecuteStealthCompatibility

Runtime 呼叫已註冊的 UO 指令，將橋接結果包裝為 Integer、String 或 Array。

String：已記錄的原始檔路徑；找不到索引時為 ""。從檔案啟動通常具有完整路徑；指令或記憶體中的程式碼可能沒有一般檔案。

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 函式 `ExecuteStealthCompatibility`.

#### 2. GetScriptPath

橋接層使用此客戶端的執行管理器。

ScriptIndex=0 選擇目前第一個執行。此查詢只識別其原始檔，不會開啟、儲存或執行檔案。

專案原始碼: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 函式 `GetScriptPath`.

#### 3. GetScriptPath

`ElementAt(RunningScripts(), index)?.FilePath ?? string.Empty`

索引是依啟動順序排列的目前位置。啟動／停止會使位置改變。多次呼叫不是同一個不可分割快照；之後下控制指令前應重新讀取清單。

專案原始碼: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; 函式 `GetScriptPath`.

關閉 Basic IDE 不會移除有效執行。這些指令僅查詢此客戶端，不涉及其他客戶端或 Windows 處理程序。


## 範例

### 第一次呼叫與結果

```vb
# 第一次呼叫與結果
#
# 讀取某個有效執行的原始檔路徑。
#
# String：已記錄的原始檔路徑；找不到索引時為 ""。從檔案啟動通常具有完整路徑；指令或記憶體中的程式碼可能沒有一般檔案。

SUB Main()
    # 執行 Sub Main。傳入的 0 是索引；空括號代表沒有參數。Print 文字只是範例訊息。
    # ScriptIndex=0 選擇目前第一個執行。此查詢只識別其原始檔，不會開啟、儲存或執行檔案。
    # String：已記錄的原始檔路徑；找不到索引時為 ""。從檔案啟動通常具有完整路徑；指令或記憶體中的程式碼可能沒有一般檔案。
    # 必填 ScriptIndex：從最新 GetScriptsList 取得、由零開始的整數索引。負值或不存在的索引會傳回上述空值／未知狀態。不可傳入物品 serial、程序名稱或 IDE
    # 執行 ID。

    Dim index=0
    Dim path=UO.GetScriptPath(index)
    If path<>"" Then
        UO.Print(path)
    End If
END SUB
```

**參數與執行說明:**

- 執行 Sub Main。傳入的 0 是索引；空括號代表沒有參數。Print 文字只是範例訊息。
- ScriptIndex=0 選擇目前第一個執行。此查詢只識別其原始檔，不會開啟、儲存或執行檔案。
- String：已記錄的原始檔路徑；找不到索引時為 ""。從檔案啟動通常具有完整路徑；指令或記憶體中的程式碼可能沒有一般檔案。
- 必填 ScriptIndex：從最新 GetScriptsList 取得、由零開始的整數索引。負值或不存在的索引會傳回上述空值／未知狀態。不可傳入物品 serial、程序名稱或 IDE 執行 ID。

### 在迴圈或條件中使用

```vb
# 在迴圈或條件中使用
#
# 讀取某個有效執行的原始檔路徑。
#
# String：已記錄的原始檔路徑；找不到索引時為 ""。從檔案啟動通常具有完整路徑；指令或記憶體中的程式碼可能沒有一般檔案。

SUB Main()
    # 這是結合多個指令的獨立範例。陣列索引從零開始，存取前須檢查長度。範例若使用 Wait(250)，會等待 250 毫秒。
    # ScriptIndex=0 選擇目前第一個執行。此查詢只識別其原始檔，不會開啟、儲存或執行檔案。
    # String：已記錄的原始檔路徑；找不到索引時為 ""。從檔案啟動通常具有完整路徑；指令或記憶體中的程式碼可能沒有一般檔案。
    # 必填 ScriptIndex：從最新 GetScriptsList 取得、由零開始的整數索引。負值或不存在的索引會傳回上述空值／未知狀態。不可傳入物品 serial、程序名稱或 IDE
    # 執行 ID。

    Dim indices=UO.GetScriptsList()
    For Each index In indices
        UO.Print(UO.GetScriptName(index) & " -> " & UO.GetScriptPath(index))
    Next
END SUB
```

**參數與執行說明:**

- 這是結合多個指令的獨立範例。陣列索引從零開始，存取前須檢查長度。範例若使用 Wait(250)，會等待 250 毫秒。
- ScriptIndex=0 選擇目前第一個執行。此查詢只識別其原始檔，不會開啟、儲存或執行檔案。
- String：已記錄的原始檔路徑；找不到索引時為 ""。從檔案啟動通常具有完整路徑；指令或記憶體中的程式碼可能沒有一般檔案。
- 必填 ScriptIndex：從最新 GetScriptsList 取得、由零開始的整數索引。負值或不存在的索引會傳回上述空值／未知狀態。不可傳入物品 serial、程序名稱或 IDE 執行 ID。

### 完整輔助函式

```vb
# 完整輔助函式
#
# 讀取某個有效執行的原始檔路徑。
#
# String：已記錄的原始檔路徑；找不到索引時為 ""。從檔案啟動通常具有完整路徑；指令或記憶體中的程式碼可能沒有一般檔案。

SUB Main()
    # Main 下方列出完整函式。其參數與結果應與內部呼叫的 API 指令分開理解。
    # ReadScriptPath 只在路徑為空時使用 fallback。這是另一個函式，不是 GetScriptPath 的新多載。
    # String：已記錄的原始檔路徑；找不到索引時為 ""。從檔案啟動通常具有完整路徑；指令或記憶體中的程式碼可能沒有一般檔案。
    # 必填 ScriptIndex：從最新 GetScriptsList 取得、由零開始的整數索引。負值或不存在的索引會傳回上述空值／未知狀態。不可傳入物品 serial、程序名稱或 IDE
    # 執行 ID。

    UO.Print(ReadScriptPath(0, "path unavailable"))
END SUB

Function ReadScriptPath(index, fallback) As String
    Dim path=UO.GetScriptPath(index)
    If path="" Then
        Return fallback
    End If
    Return path
End Function
```

**參數與執行說明:**

- Main 下方列出完整函式。其參數與結果應與內部呼叫的 API 指令分開理解。
- ReadScriptPath 只在路徑為空時使用 fallback。這是另一個函式，不是 GetScriptPath 的新多載。
- String：已記錄的原始檔路徑；找不到索引時為 ""。從檔案啟動通常具有完整路徑；指令或記憶體中的程式碼可能沒有一般檔案。
- 必填 ScriptIndex：從最新 GetScriptsList 取得、由零開始的整數索引。負值或不存在的索引會傳回上述空值／未知狀態。不可傳入物品 serial、程序名稱或 IDE 執行 ID。
