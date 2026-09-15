# Function / Return / Exit Function / End Function

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: zh-tw -->

Function 宣告會回傳數量、文字或 List/Dictionary 參照的輔助函式。自己的函式不加 UO.；即使宣告 Function GetType(value)，UO.GetType(item) 仍是獨立的遊戲 API。

## 完整語法

```text
Function name(parameters) As type
    name = expression
End Function
Function name(parameters)
    Return expression
End Function
result = name(arguments)
Exit Function
Return
```

## 參數

- `name` — 名称不分大小寫，既是呼叫名稱，也是函式內隱含的區域結果變數。name 不加括號會讀取結果；name(arguments) 會呼叫函式，包括遞迴。不要再用 Dim、Var、Const 或參數重新宣告結果。
- `parameters / arguments` — 位置參數使用 Sub 的規則：預設 ByRef、ByVal、Optional 及最後的 ParamArray。詳見 Basic.Parameters 與各參數章節。模組函式使用 Tools.Calculate(...)，並遵守 Public/Private 存取規則。
- `As type` — 可省略的結果型別：Integer/Long/Short/Byte 使用本引擎的 Integer；Double/Single/Decimal 使用 Double；String 儲存文字；Boolean/Bool 正規化為 1/0；Object/Variant 保留值的種類。這不代表完整 VB.NET 數值位寬。未知型別會被拒絕。沒有 As 時為 Variant；名稱字尾不會推斷結果型別。
- `name = expression` — 保存結果後會繼續執行下一個指令，不會離開函式。可以再次讀取或修改，包括 +=。這是本次呼叫的區域變數，不是全域變數或新呼叫。
- `Return / Exit Function / End Function` — Return expression 指派有型別的結果並開始離開。空 Return、Exit Function 與到達 End Function 都回傳目前結果。End Function 必須存在；Function 內的 Exit Sub 是載入錯誤。

## 傳回值

正常 Finally 執行完畢後回傳目前結果。初值為 Integer 0、Double 0.0、Boolean FALSE/0、String 空字串；未指定型別及 Variant/Object 初值為 Unit，沒有有意義的值。List/Dictionary/Object 保留參照。Boolean 回傳數字 1/0，可與 TRUE/FALSE 比較；任意數量或 ID 不會自動代表成功。

## 行為

- 準備階段保留真正的 Function，驗證結果型別與離開方式，繫結區域結果並一次準備指令。每次呼叫都取得引數與全新的型別化結果。對名稱賦值採用普通型別化變數的轉換規則。
- Return 保存結果後，由內而外執行離開的 Finally。Finally 仍能在回到呼叫端前改變結果。成功結束後完成 ByRef 回寫。未處理的例外或不合法的結果轉換會傳播錯誤，不會產生成功值。
- 遞迴有独立的參數、區域值與結果；Factorial(n-1) 不會覆蓋呼叫端的 Factorial。需要基本情況避免無限遞迴。不會自動新增執行緒、延遲或逾時，暫停及停止檢查仍有效。
- 巢狀腳本程序呼叫上限為 32 個框架，包含回呼及事件處理程序。超過時產生可攔截的腳本錯誤；深度處理請用迴圈。返回或出錯會釋放框架，後續呼叫仍可執行。

## 範例

### 1. 保存後繼續執行

```vb
# TotalPrice 以 ByVal 接收 count 與 price，回傳 Integer。任一負數立即回傳 -1；否則先保存 count*price，再加固定的 2。(3,4) 得到 14，(-1,4) 得到 -1，Main 合併為 14:-1。-1 是此函式自行定義的規則，不是引擎自動錯誤碼。
Option Explicit On
Function TotalPrice(ByVal count, ByVal price) As Integer
    If count < 0 OrElse price < 0 Then
        Return -1
    End If
    TotalPrice=count*price
    TotalPrice+=2
End Function

Sub Main()
    Return CStr(TotalPrice(3, 4)) & ":" & CStr(TotalPrice(-1, 4))
End Sub
```

**參數與執行說明:**

TotalPrice 以 ByVal 接收 count 與 price，回傳 Integer。任一負數立即回傳 -1；否則先保存 count*price，再加固定的 2。(3,4) 得到 14，(-1,4) 得到 -1，Main 合併為 14:-1。-1 是此函式自行定義的規則，不是引擎自動錯誤碼。

### 2. 獨立的遞迴結果

```vb
# Factorial 以 ByVal 接收 n，將自己的結果設為 1。n<=1 時 Exit Function 回傳 1；否則 n*Factorial(n-1) 使用新呼叫。本例的小型非負輸入得到 5!+3!=120+6=126。負數也會走基本分支；本例未檢查完整的階乘數學定義域。
Option Explicit On
Function Factorial(ByVal n) As Integer
    Factorial=1
    If n <= 1 Then
        Exit Function
    End If
    Factorial=n*Factorial(n-1)
End Function

Sub Main()
    Return Factorial(5)+Factorial(3)
End Sub
```

**參數與執行說明:**

Factorial 以 ByVal 接收 n，將自己的結果設為 1。n<=1 時 Exit Function 回傳 1；否則 n*Factorial(n-1) 使用新呼叫。本例的小型非負輸入得到 5!+3!=120+6=126。負數也會走基本分支；本例未檢查完整的階乘數學定義域。

### 3. Return、兩層 Finally 與 ByRef

```vb
# Calculate 以 ByRef 接收 trace。Return 1 保存結果並開始離開。內層 Finally 將結果與 trace 從 1 改為 12，外層再改成 123。Main 得到 result=123、trace=123，回傳 123:123。即使已執行 Return expression，Finally 仍可更改結果；此例沒有模擬遊戲移動或時間。
Option Explicit On
Function Calculate(ByRef trace) As Integer
    Try
        Try
            trace=1
            Return 1
        Finally
            Calculate=Calculate*10+2
            trace=trace*10+2
        End Try
    Finally
        Calculate=Calculate*10+3
        trace=trace*10+3
    End Try
End Function

Sub Main()
    Dim trace=0
    Dim result=Calculate(trace)
    Return CStr(result) & ":" & CStr(trace)
End Sub
```

**參數與執行說明:**

Calculate 以 ByRef 接收 trace。Return 1 保存結果並開始離開。內層 Finally 將結果與 trace 從 1 改為 12，外層再改成 123。Main 得到 result=123、trace=123，回傳 123:123。即使已執行 Return expression，Finally 仍可更改結果；此例沒有模擬遊戲移動或時間。

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: subrutine / parameters / returnStatement / exitProcedure
Runtime/BasicSyntaxPreprocessor.cs: Normalize / NormalizeArguments
Analysis/ProcedureStructureValidator.cs: VisitSubrutine / VisitExitProcedure / CheckName
Runtime/SubrutineDefinition.cs: IsFunction / ReturnType / ResultName
Runtime/Interpreter.cs: CallSubrutine / FunctionResult / DeferReturn / DefaultValueForType
Runtime/SemanticScope.cs: DefineVar / SetVar
Runtime/ScriptBindings.cs: Builder.VisitSubrutine
ClassicUO.Client/Game/Managers/YokoInjectionManager.cs: DiscoverProcedures / DiscoverScopedProcedures
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/function-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/return-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/exit-statement
-->
