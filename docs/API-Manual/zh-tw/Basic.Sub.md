# Sub / Call / Exit Sub / End Sub

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: zh-tw -->

Sub 將多個指令整理為具名程序，適用於物品處理、檢查及收尾工作。呼叫會在目前腳本中依序執行，不會另開背景腳本。

## 完整語法

```text
Sub name(parameters)
    statements
End Sub
name(arguments)
Call name(arguments)
Call name arguments
Call name
Exit Sub
Return
Return expression
```

## 參數

- `name` — 程序識別名稱不分大小寫。自己的程序不加 UO.；模組成員使用 Tools.Work(...)。Public/Private 控制模組存取，詳見 Basic.Module 與 Basic.Visibility。
- `parameters / arguments` — 參數宣告在括號內，引數依宣告順序傳入。預設為 ByRef；ByVal 複製值，Optional 提供省略時的值，最後的 ParamArray 收集額外引數。型別、陣列、共享參照與回寫規則請參閱五個參數章節。
- `statements / End Sub` — 內容可以為空，但必須以 End Sub 結束。每次呼叫都有自己的區域變數，遞迴也一樣。程序宣告位於檔案或模組層級，不能巢狀宣告於其他程序內。
- `Call` — name(arguments) 可省略 Call。Call name arguments 也允許不加括號；Call name 呼叫無參數程序。Call 會丟棄回傳值。引數運算式保留原有意義，自己的程序不會自動加上 UO.。
- `Exit Sub / Return` — Exit Sub 或不帶運算式的 Return 結束目前這次呼叫。在 Sub 內使用 Return expression 是 Basic 相容性擴充，普通 VB.NET Sub 沒有這種形式。Sub 內的 Exit Function 會造成載入錯誤。

## 傳回值

End Sub、Exit Sub 及空 Return 產生 Unit，表示沒有有意義的結果，不是成功旗標或 ID。舊式 Basic Sub 可用 Return expression 回傳運算式。ByRef 還能另外改變呼叫端變數。以回傳結果為主要用途時，建議使用 Function。

## 行為

- 準備階段會正規化相容的宣告與 Call 寫法、驗證區塊並解析呼叫名稱。進入程序前先計算並繫結引數。重複呼叫共用已準備的指令，不共用區域變數值。
- 直譯器建立呼叫範圍，執行內容後回到呼叫後的指令。正常結束及 Exit Sub 會先執行離開範圍的 Finally，再完成參數回寫。例外由目前錯誤處理器接手；呼叫失敗不能視為成功。
- 執行引擎仍檢查暫停與停止。輔助程序不會新增執行緒、自動延遲或逾時。遞迴需要終止條件。對 Sub 名稱賦值不會設定回傳結果；這種寫法應使用 Function。
- 巢狀腳本程序呼叫上限為 32 個框架，包含回呼及事件處理程序。超過時產生可攔截的腳本錯誤；深度處理請用迴圈。返回或出錯會釋放框架，後續呼叫仍可執行。

## 範例

### 1. 三種呼叫形式

```vb
# total 從 4 開始。AddAmount 以 ByRef 接收 total；省略的 amount 為 1，明確傳入的 3 和 2 使用 ByVal。帶括號的 Call、不帶括號的 Call 及一般呼叫執行相同內容。Main 明確回傳 4+1+3+2=10。
Option Explicit On
Sub AddAmount(ByRef total, Optional ByVal amount=1)
    total += amount
End Sub

Sub Main()
    Dim total=4
    Call AddAmount(total)
    Call AddAmount total, 3
    AddAmount(total, 2)
    Return total
End Sub
```

**參數與執行說明:**

total 從 4 開始。AddAmount 以 ByRef 接收 total；省略的 amount 為 1，明確傳入的 3 和 2 使用 ByVal。帶括號的 Call、不帶括號的 Call 及一般呼叫執行相同內容。Main 明確回傳 4+1+3+2=10。

### 2. 公開入口與私有輔助程序

```vb
# Batches.SumInto 以 ByRef 接收 total，將 3,-9,4 收集到 values。For Each 呼叫私有 AppendAmount。負數檢查只離開該輔助程序，因此跳過 -9 後迴圈繼續。由初值 2 得到 2+3+4=9；外部使用公開的完整模組名稱。
Option Explicit On
Module Batches
    Private Sub AppendAmount(ByRef total, ByVal value)
        If value < 0 Then
            Exit Sub
        End If
        total += value
    End Sub

    Public Sub SumInto(ByRef total, ParamArray values)
        For Each value In values
            AppendAmount(total, value)
        Next
    End Sub
End Module

Sub Main()
    Dim total=2
    Batches.SumInto(total, 3, -9, 4)
    Return total
End Sub
```

**參數與執行說明:**

Batches.SumInto 以 ByRef 接收 total，將 3,-9,4 收集到 values。For Each 呼叫私有 AppendAmount。負數檢查只離開該輔助程序，因此跳過 -9 後迴圈繼續。由初值 2 得到 2+3+4=9；外部使用公開的完整模組名稱。

### 3. 提早結束與收尾

```vb
# Finish 設定 trace=1 後離開，trace=99 不執行。Finally 附加數字 2，透過 ByRef 將 trace=12 回寫。LegacyValue 示範 Basic Sub 中的 Return 7。Main 回傳 12*10+7=127。trace 的數字由範例自行定義，不是遊戲結果代碼。
Option Explicit On
Sub Finish(ByRef trace)
    Try
        trace=1
        Exit Sub
        trace=99
    Finally
        trace=trace*10+2
    End Try
End Sub

Sub LegacyValue()
    Return 7
End Sub

Sub Main()
    Dim trace=0
    Call Finish(trace)
    Return trace*10+LegacyValue()
End Sub
```

**參數與執行說明:**

Finish 設定 trace=1 後離開，trace=99 不執行。Finally 附加數字 2，透過 ByRef 將 trace=12 回寫。LegacyValue 示範 Basic Sub 中的 Return 7。Main 回傳 12*10+7=127。trace 的數字由範例自行定義，不是遊戲結果代碼。

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: subrutine / parameters / returnStatement / exitProcedure
Runtime/BasicSyntaxPreprocessor.cs: Normalize / NormalizeArguments
Analysis/ProcedureStructureValidator.cs: VisitSubrutine / VisitExitProcedure / CheckName
Runtime/SubrutineDefinition.cs: IsFunction / ReturnType / ResultName
Runtime/Interpreter.cs: CallSubrutine / FunctionResult / DeferReturn / DefaultValueForType
Runtime/SemanticScope.cs: DefineVar / SetVar
Runtime/ScriptBindings.cs: Builder.VisitSubrutine
ClassicUO.Client/Game/Managers/YokoInjectionManager.cs: DiscoverProcedures / DiscoverScopedProcedures
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/sub-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/call-statement
-->
