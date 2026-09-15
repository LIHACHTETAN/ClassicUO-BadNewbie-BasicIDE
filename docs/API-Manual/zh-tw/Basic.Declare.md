# Declare / Lib / Alias

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: zh-tw -->

Declare 將 Basic 程序名稱連接到原生 Windows x64 DLL 的匯出函式。這個明確限定的功能集可用於編譯後的客戶端，不需執行期產生程式碼；並非完整 VB.NET 互通層。

## 完整語法

```text
[Public | Private] Declare [Ansi | Unicode | Auto] Function name Lib "library.dll" [Alias "export"]([ByVal arg As Type, ...]) As ResultType
[Public | Private] Declare [Ansi | Unicode | Auto] Sub name Lib "library.dll" [Alias "export"]([ByVal arg As Type, ...])
name(arguments)
name(argumentName:=value)
ModuleName.name(arguments)
```

## 參數

- `name / Public / Private` — 本地名稱不分大小寫，呼叫時不加 UO.。在檔案或 Module 層級宣告，沒有主體，也不寫 End Function/End Sub。預設 Public；Module 內可用 Private。不能覆蓋內建 Basic/UO 命令，請另取名稱並使用 Alias。
- `Lib / library.dll` — 必要的 .dll 檔名或路徑。單純系統檔名先查 System32；其他相對路徑以宣告所在檔案為基準，包含 Include 檔。可用絕對路徑。不搜尋程序目前目錄或 PATH。相依 DLL 可位於同一資料夾或 System32。
- `Alias / export` — 選用且區分大小寫的精確匯出名稱；省略時使用本地簡名。不支援匯出序號。必須是簽章完全相符的原生 Windows x64 函式，不是受控 .NET 方法。
- `Ansi / Unicode / Auto` — 預設 Ansi 使用 Windows ANSI 編碼複製文字，無法表示的字元可能遺失。Unicode 使用 UTF-16。兩者皆查精確名稱。Auto 使用 UTF-16，先查精確名稱，再附加 W。Auto 無法判斷匯出的實際編碼；Unicode API 建議明確使用 Unicode 與 W 匯出。
- `ByVal arg As Type` — 零到四個參數，每個均須明寫 ByVal 與 As Integer、Double、Boolean 或 String。Integer 為有號 32 位元；Double 為 64 位元；Boolean 為 32 位元 Windows BOOL，並非 C/C++ bool。String 是唯讀、暫存、NUL 結尾的輸入副本，最多 1048576 個 UTF-16 單位，不可含內嵌 NUL。DLL 不得保留指標或寫入緩衝區。具名引數使用本地參數名。不支援 ByRef、Optional、ParamArray、陣列、結構與指標。
- `As ResultType / Sub` — Function 必須指定 As Integer、Double 或 Boolean；Sub 不寫 As，結果為 Unit。Integer/Boolean 引數須已是 Integer；Double 亦接受 Integer。需要時明確使用 CInt/CDbl/CStr。字串、指標或 64 位元整數回傳需另寫符合支援簽章的原生包裝函式。

## 傳回值

Integer 回傳有號 32 位元數字，意義由原生函式定義，不一定表示成功。Double 回傳 64 位元浮點數。As Boolean 將原生零轉成 0/False，任何非零 BOOL 轉成 1/True；這些正規化旗標可等價地與 1/0 或 True/False 比較。Sub 無回傳值（Unit）。範例結果為 1、"3:8"、"missing export:1"。

## 行為

- 不支援的宣告在執行前以 SC031 拒絕。每個根腳本最多 256 個宣告、64 個已載入函式庫。解析、驗證與 IDE 補全不載入 DLL。引擎不知道實際原生簽章；宣告錯誤可能造成客戶端崩潰。
- 首次呼叫載入 DLL，後續呼叫重用函式庫與匯出位址。引數依原始順序只求值一次，再按參數名重排。載入、架構、匯出與轉換錯誤可用 Try/Catch 處理；原生記憶體違規並非一般可恢復的腳本錯誤。
- 每次呼叫後釋放暫存字串，包含轉換失敗。根腳本完成、失敗或取消時釋放函式庫控制代碼。只關閉 IDE 會保留仍在執行的腳本與函式庫。
- 在腳本工作執行緒同步呼叫；暫停與停止只在呼叫前後檢查。原生函式若永不返回，引擎無法中斷它。請使用短操作，等待請用 Basic Wait。不支援受控 DLL、回呼 Basic、可變引數匯出或任意指標 API。

## 範例

### 1. 讀取客戶端程序 ID

```vb
# ClientProcessId 無參數呼叫 kernel32.dll 的 GetCurrentProcessId。Main 將數字 Windows ID 存入 processId，再以 processId > 0 得到 1/True。ID 本身不是 Boolean，也不是 UO 序號。
Option Explicit On
Declare Function ClientProcessId Lib "kernel32.dll" Alias "GetCurrentProcessId"() As Integer

Sub Main()
    Dim processId = ClientProcessId()
    Return processId > 0
End Sub
```

**參數與執行說明:**

ClientProcessId 無參數呼叫 kernel32.dll 的 GetCurrentProcessId。Main 將數字 Windows ID 存入 processId，再以 processId > 0 得到 1/True。ID 本身不是 Boolean，也不是 UO 序號。

### 2. 文字、次方與具名引數

```vb
# TextLength(text) 將 UTF-16 傳給 lstrlenW 並回傳長度。Power(value, exponent) 以兩個 Double 呼叫 pow。Describe("ore", 2, 3) 接收三個引數，使用相反書寫順序的具名 Power 引數，回傳 "3:8"。所有輔助函式皆完整列出。
Option Explicit On
Declare Unicode Function TextLength Lib "kernel32.dll" Alias "lstrlenW"(ByVal text As String) As Integer
Declare Function Power Lib "ucrtbase.dll" Alias "pow"(ByVal value As Double, ByVal exponent As Double) As Double

Function Describe(ByVal text As String, ByVal value As Double, ByVal exponent As Double) As String
    Dim length = TextLength(text:=text)
    Dim powered = Power(exponent:=exponent, value:=value)
    Return CStr(length) & ":" & CStr(powered)
End Function

Sub Main()
    Return Describe("ore", 2, 3)
End Sub
```

**參數與執行說明:**

TextLength(text) 將 UTF-16 傳給 lstrlenW 並回傳長度。Power(value, exponent) 以兩個 Double 呼叫 pow。Describe("ore", 2, 3) 接收三個引數，使用相反書寫順序的具名 Power 引數，回傳 "3:8"。所有輔助函式皆完整列出。

### 3. 缺少匯出時

```vb
# NativeDemo.MissingExport 故意指定不存在的匯出。TryRead 捕捉錯誤，設 status="missing export"，Finally 設 finished=1，Main 回傳 "missing export:1"。Private 限制宣告在模組內。這是正常錯誤處理，不保證緊急取消後仍執行腳本清理。
Option Explicit On
Module NativeDemo
    Private Declare Function MissingExport Lib "kernel32.dll" Alias "BasicManualMissingExport_71cf"() As Integer
    Public Function TryRead() As String
        Dim status = "unexpected export"
        Dim finished = 0
        Try
            MissingExport()
        Catch problem
            status = "missing export"
        Finally
            finished = 1
        End Try
        Return status & ":" & CStr(finished)
    End Function
End Module

Sub Main()
    Return NativeDemo.TryRead()
End Sub
```

**參數與執行說明:**

NativeDemo.MissingExport 故意指定不存在的匯出。TryRead 捕捉錯誤，設 status="missing export"，Finally 設 finished=1，Main 回傳 "missing export:1"。Private 限制宣告在模組內。這是正常錯誤處理，不保證緊急取消後仍執行腳本清理。


### 內部函式：從呼叫到結果

Declare 將 Basic 程序名稱連接到原生 Windows x64 DLL 的匯出函式。這個明確限定的功能集可用於編譯後的客戶端，不需執行期產生程式碼；並非完整 VB.NET 互通層。

#### 1. ExternalDeclaration

不支援的宣告在執行前以 SC031 拒絕。每個根腳本最多 256 個宣告、64 個已載入函式庫。解析、驗證與 IDE 補全不載入 DLL。引擎不知道實際原生簽章；宣告錯誤可能造成客戶端崩潰。

`source -> typed declaration -> SC031 on unsupported ABI`

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/ExternalDeclaration.cs`; 函式 `ExternalDeclaration`.

#### 2. LibraryPath / GetCallable

必要的 .dll 檔名或路徑。單純系統檔名先查 System32；其他相對路徑以宣告所在檔案為基準，包含 Include 檔。可用絕對路徑。不搜尋程序目前目錄或 PATH。相依 DLL 可位於同一資料夾或 System32。

`first call -> absolute DLL path -> cached library -> exact export`

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/ExternalLibraries.cs`; 函式 `LibraryPath / GetCallable`.

#### 3. Invoke

零到四個參數，每個均須明寫 ByVal 與 As Integer、Double、Boolean 或 String。Integer 為有號 32 位元；Double 為 64 位元；Boolean 為 32 位元 Windows BOOL，並非 C/C++ bool。String 是唯讀、暫存、NUL 結尾的輸入副本，最多 1048576 個 UTF-16 單位，不可含內嵌 NUL。DLL 不得保留指標或寫入緩衝區。具名引數使用本地參數名。不支援 ByRef、Optional、ParamArray、陣列、結構與指標。

`evaluate arguments once -> validate kinds -> copy input strings -> select compiled call shape`

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/ExternalLibraries.cs`; 函式 `Invoke`.

#### 4. CallInteger / CallDouble / CallVoid

Function 必須指定 As Integer、Double 或 Boolean；Sub 不寫 As，結果為 Unit。Integer/Boolean 引數須已是 Integer；Double 亦接受 Integer。需要時明確使用 CInt/CDbl/CStr。字串、指標或 64 位元整數回傳需另寫符合支援簽章的原生包裝函式。

`Windows x64 argument slots -> native call -> declared result`

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/ExternalCallSites.cs`; 函式 `CallInteger / CallDouble / CallVoid`.

#### 5. Dispose

每次呼叫後釋放暫存字串，包含轉換失敗。根腳本完成、失敗或取消時釋放函式庫控制代碼。只關閉 IDE 會保留仍在執行的腳本與函式庫。

`finally: free temporary strings; root exit: release DLL handles in reverse order`

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/ExternalLibraries.cs`; 函式 `Dispose`.

Integer 回傳有號 32 位元數字，意義由原生函式定義，不一定表示成功。Double 回傳 64 位元浮點數。As Boolean 將原生零轉成 0/False，任何非零 BOOL 轉成 1/True；這些正規化旗標可等價地與 1/0 或 True/False 比較。Sub 無回傳值（Unit）。範例結果為 1、"3:8"、"missing export:1"。

<!-- implementation references (not callable script procedures):
Runtime/ExternalDeclaration.cs: type and declaration validation
Analysis/ExternalDeclarationValidator.cs: SC031
Runtime/ExternalLibraries.cs: LibraryPath / GetCallable / Invoke / Dispose
Runtime/ExternalCallSites.cs: CallInteger / CallDouble / CallVoid
Runtime/Interpreter.cs: CallSubrutine / CallObserved
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/declare-statement
https://learn.microsoft.com/en-us/cpp/build/x64-calling-convention?view=msvc-170
https://learn.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-loadlibraryexw
-->
