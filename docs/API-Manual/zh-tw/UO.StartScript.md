# UO.StartScript

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: zh-tw -->

載入 Basic 檔案並要求執行其公開 Sub Main。

## 完整語法

```text
UO.StartScript(ScriptPath:Any) -> Integer
```

## 參數

- `ScriptPath` — 必填 String ScriptPath。相對路徑以此客戶端的 AutoLoad 資料夾為起點，也可使用絕對路徑。含空格的路徑必須放在引號內。檔案須使用支援的 Basic，並含有無必要參數的公開 Sub Main。

## 傳回值

Integer：接受啟動後的有效執行數；65535 (0xFFFF) 表示啟動失敗。不是新腳本索引、Boolean 或完成結果。

## 行為

- 包含執行中及暫停中的執行；排除已結束或已要求取消者。呼叫者通常也計算在內。僅載入 IDE 分頁不代表已執行。
- 索引是依啟動順序排列的目前位置。啟動／停止會使位置改變。多次呼叫不是同一個不可分割快照；之後下控制指令前應重新讀取清單。
- 關閉 Basic IDE 不會移除有效執行。這些指令僅查詢此客戶端，不涉及其他客戶端或 Windows 處理程序。
- GetScriptsList 提供索引，GetScriptsCount 提供數量，GetScriptState 提供三態狀態碼。不要混用，也不要把所有非零值視為 true。
- 執行範例前請另行建立指定的 Worker.bas 檔案。無效／不可讀的路徑、不適用的 Main、停用 Basic 或拒絕並行啟動會失敗。前次執行仍在停止時可能延後重試；接受啟動不等於完成。短腳本可能在讀到數量前已結束。

### 內部函式：從呼叫到結果

以下列出客戶端的實際方法。Basic 範例包含完整輔助函式；內部 C# 方法名稱不是額外的腳本指令。

#### 1. ExecuteStealthCompatibility

Runtime 呼叫已註冊的 UO 指令，將橋接結果包裝為 Integer、String 或 Array。

Integer：接受啟動後的有效執行數；65535 (0xFFFF) 表示啟動失敗。不是新腳本索引、Boolean 或完成結果。

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 函式 `ExecuteStealthCompatibility`.

#### 2. StartScript

橋接層使用此客戶端的執行管理器。

執行範例前請另行建立指定的 Worker.bas 檔案。無效／不可讀的路徑、不適用的 Main、停用 Basic 或拒絕並行啟動會失敗。前次執行仍在停止時可能延後重試；接受啟動不等於完成。短腳本可能在讀到數量前已結束。

專案原始碼: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 函式 `StartScript`.

#### 3. StartScript

`Path.GetFullPath -> File.ReadAllText -> DiscoverProcedures -> SelectFileEntryPoint -> RunProcedure -> GetScriptsCount`

索引是依啟動順序排列的目前位置。啟動／停止會使位置改變。多次呼叫不是同一個不可分割快照；之後下控制指令前應重新讀取清單。

專案原始碼: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; 函式 `StartScript`.

關閉 Basic IDE 不會移除有效執行。這些指令僅查詢此客戶端，不涉及其他客戶端或 Windows 處理程序。


## 範例

### 第一次呼叫與結果

```vb
# 第一次呼叫與結果
#
# 載入 Basic 檔案並要求執行其公開 Sub Main。
#
# Integer：接受啟動後的有效執行數；65535 (0xFFFF) 表示啟動失敗。不是新腳本索引、Boolean 或完成結果。

SUB Main()
    # 執行 Sub Main。傳入的 0 是索引；空括號代表沒有參數。Print 文字只是範例訊息。
    # 執行範例前請另行建立指定的 Worker.bas 檔案。無效／不可讀的路徑、不適用的 Main、停用 Basic
    # 或拒絕並行啟動會失敗。前次執行仍在停止時可能延後重試；接受啟動不等於完成。短腳本可能在讀到數量前已結束。
    # Integer：接受啟動後的有效執行數；65535 (0xFFFF) 表示啟動失敗。不是新腳本索引、Boolean 或完成結果。
    # 必填 String ScriptPath。相對路徑以此客戶端的 AutoLoad 資料夾為起點，也可使用絕對路徑。含空格的路徑必須放在引號內。檔案須使用支援的
    # Basic，並含有無必要參數的公開 Sub Main。

    Dim count=UO.StartScript("Scripts/Worker.bas")
    If count=65535 Then
        UO.Print("launch failed")
    Else
        UO.Print("Active executions: " & CStr(count))
    End If
END SUB
```

**參數與執行說明:**

- 執行 Sub Main。傳入的 0 是索引；空括號代表沒有參數。Print 文字只是範例訊息。
- 執行範例前請另行建立指定的 Worker.bas 檔案。無效／不可讀的路徑、不適用的 Main、停用 Basic 或拒絕並行啟動會失敗。前次執行仍在停止時可能延後重試；接受啟動不等於完成。短腳本可能在讀到數量前已結束。
- Integer：接受啟動後的有效執行數；65535 (0xFFFF) 表示啟動失敗。不是新腳本索引、Boolean 或完成結果。
- 必填 String ScriptPath。相對路徑以此客戶端的 AutoLoad 資料夾為起點，也可使用絕對路徑。含空格的路徑必須放在引號內。檔案須使用支援的 Basic，並含有無必要參數的公開 Sub Main。

### 在迴圈或條件中使用

```vb
# 在迴圈或條件中使用
#
# 載入 Basic 檔案並要求執行其公開 Sub Main。
#
# Integer：接受啟動後的有效執行數；65535 (0xFFFF) 表示啟動失敗。不是新腳本索引、Boolean 或完成結果。

SUB Main()
    # 這是結合多個指令的獨立範例。陣列索引從零開始，存取前須檢查長度。範例若使用 Wait(250)，會等待 250 毫秒。
    # 執行範例前請另行建立指定的 Worker.bas 檔案。無效／不可讀的路徑、不適用的 Main、停用 Basic
    # 或拒絕並行啟動會失敗。前次執行仍在停止時可能延後重試；接受啟動不等於完成。短腳本可能在讀到數量前已結束。
    # Integer：接受啟動後的有效執行數；65535 (0xFFFF) 表示啟動失敗。不是新腳本索引、Boolean 或完成結果。
    # 必填 String ScriptPath。相對路徑以此客戶端的 AutoLoad 資料夾為起點，也可使用絕對路徑。含空格的路徑必須放在引號內。檔案須使用支援的
    # Basic，並含有無必要參數的公開 Sub Main。

    Dim count=UO.StartScript("Scripts/My Worker.bas")
    If count<>65535 Then
        Dim indices=UO.GetScriptsList()
        For Each index In indices
            UO.Print(CStr(index) & ": " & UO.GetScriptPath(index))
        Next
    End If
END SUB
```

**參數與執行說明:**

- 這是結合多個指令的獨立範例。陣列索引從零開始，存取前須檢查長度。範例若使用 Wait(250)，會等待 250 毫秒。
- 執行範例前請另行建立指定的 Worker.bas 檔案。無效／不可讀的路徑、不適用的 Main、停用 Basic 或拒絕並行啟動會失敗。前次執行仍在停止時可能延後重試；接受啟動不等於完成。短腳本可能在讀到數量前已結束。
- Integer：接受啟動後的有效執行數；65535 (0xFFFF) 表示啟動失敗。不是新腳本索引、Boolean 或完成結果。
- 必填 String ScriptPath。相對路徑以此客戶端的 AutoLoad 資料夾為起點，也可使用絕對路徑。含空格的路徑必須放在引號內。檔案須使用支援的 Basic，並含有無必要參數的公開 Sub Main。

### 完整輔助函式

```vb
# 完整輔助函式
#
# 載入 Basic 檔案並要求執行其公開 Sub Main。
#
# Integer：接受啟動後的有效執行數；65535 (0xFFFF) 表示啟動失敗。不是新腳本索引、Boolean 或完成結果。

SUB Main()
    # Main 下方列出完整函式。其參數與結果應與內部呼叫的 API 指令分開理解。
    # TryStartBasic 與 65535 比較並傳回 true/false。它不等待結束，也不將數量轉成索引。
    # Integer：接受啟動後的有效執行數；65535 (0xFFFF) 表示啟動失敗。不是新腳本索引、Boolean 或完成結果。
    # 必填 String ScriptPath。相對路徑以此客戶端的 AutoLoad 資料夾為起點，也可使用絕對路徑。含空格的路徑必須放在引號內。檔案須使用支援的
    # Basic，並含有無必要參數的公開 Sub Main。

    If TryStartBasic("Scripts/Worker.bas") Then
        UO.Print("launch accepted")
    Else
        UO.Print("check file, Main and execution settings")
    End If
END SUB

Function TryStartBasic(fileName) As Boolean
    Dim count=UO.StartScript(fileName)
    Return count<>65535
End Function
```

**參數與執行說明:**

- Main 下方列出完整函式。其參數與結果應與內部呼叫的 API 指令分開理解。
- TryStartBasic 與 65535 比較並傳回 true/false。它不等待結束，也不將數量轉成索引。
- Integer：接受啟動後的有效執行數；65535 (0xFFFF) 表示啟動失敗。不是新腳本索引、Boolean 或完成結果。
- 必填 String ScriptPath。相對路徑以此客戶端的 AutoLoad 資料夾為起點，也可使用絕對路徑。含空格的路徑必須放在引號內。檔案須使用支援的 Basic，並含有無必要參數的公開 Sub Main。
