# Async / Await / Delay

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: zh-tw -->

Async Function 建立指令碼工作。Await 暫停該函式，讓同一指令碼中其他已就緒的工作繼續執行。這是協作執行，不會建立新執行緒，也不提供完整的 VB.NET Task 程式庫。

## 完整語法

```text
Async Function Work(ByVal value As Integer) As Task(Of Integer)
    Await Delay(100)
    Return value
End Function
Async Function Work() As Task
    Await Delay(100)
End Function
Delay(milliseconds) -> Object (ScriptTask)
Await task
Dim value = Await task
value = Await task
Return Await task
task.IsCompleted() -> Integer (0/1)
task.IsFaulted() -> Integer (0/1)
task.IsCanceled() -> Integer (0/1)
task.Result() -> T / Unit
```

## 參數

- `milliseconds` — Delay 接受 0..2147483647 毫秒的 Integer。0 立即完成；負數、小數及 String 會引發可攔截錯誤。使用單調時鐘，期限代表最短等待時間，不保證精確執行時刻。
- `Async Function / ByVal / Task(Of T)` — As Task 沒有回傳值；As Task(Of T) 回傳 Basic 純量或 Object/Variant。參數須明確使用 ByVal 或 ParamArray；支援 Optional 與具名引數。不支援 ByRef、Async Sub/Declare。請在程序本體建立工作，不要在全域欄位或參數預設值的初始化中建立。
- `task / Await` — 工作變數不宣告型別或使用 As Object。Await 接受本次執行的工作，可獨立成句、作為單一純量宣告/指派的完整右側，或用於 Return Await。不能嵌入算術、條件、欄位/索引指派、Catch/Finally，也不能用於 Async Function 之外。多個函式可以等候同一工作；循環相依會報錯。
- `IsCompleted / IsFaulted / IsCanceled / Result` — IsCompleted 在成功、失敗或取消後為 1；IsFaulted 在失敗時為 1；IsCanceled 在取消時為 1。這些 Integer 判斷可與 True/False 比較。Result() 回傳儲存的值；未完成時報錯，失敗後重新擲回原錯誤。不能重用上一次執行的工作。

## 傳回值

指令碼呼叫 Async Function 和 Delay 時得到 Object (ScriptTask)，不是立即得到 T。Await 和 Result() 回傳 T；As Task 和 Delay 以 Unit 完成，沒有值。用戶端直接啟動 Async Function 作為進入點時，會協作等候並取得最終結果。數值資料不一定是 Boolean。

## 行為

- 函式立即執行到第一個尚未完成的 Await。區域變數、迴圈位置、With 物件和偵錯框架會儲存，繼續時還原。已完成的工作不會暫停；Await 運算元只計算一次。
- 指令碼所屬執行緒在安全檢查點檢查期限，每輪恢復最多 64 個待執行的接續步驟，不建立額外執行緒。同步 Wait 或耗時遊戲/原生呼叫可能延遲其他工作；請使用 Await Delay。最多保留 1024 個未完成工作或尚未讀取的失敗工作。
- 暫停會阻止繼續執行，但時間仍前進；恢復後處理到期工作。Stop、錯誤或進入點返回會取消剩餘工作並釋放 Using 資源和迭代器。緊急取消會跳過指令碼 Catch/Finally。未讀取的工作錯誤在進入點結束時回報。單獨關閉 IDE 不會停止執行中的指令碼。
- 不支援 Task.Run/WhenAll、外部 .NET 工作、Async Sub、Catch/Finally 內的 Await 和區域 As Task 宣告。不要讓 Main 在必要工作完成前返回。Async/Await 是保留字。

## 範例

### 1. 兩個獨立等待

```vb
# ValueLater 以傳值接收 value 和 milliseconds。兩次呼叫均在讀取結果前啟動：10 毫秒後取得 22，30 毫秒後取得 20。Main 最多等 5000 毫秒，再用 Result() 取得 Integer 相加，回傳 42。Wait Until 逾時會報錯。
Option Explicit On
Async Function ValueLater(ByVal value As Integer, ByVal milliseconds As Integer) As Task(Of Integer)
    Await Delay(milliseconds)
    Return value
End Function

Sub Main()
    Dim first = ValueLater(20, 30)
    Dim second = ValueLater(22, 10)
    Wait Until first.IsCompleted() AndAlso second.IsCompleted() Timeout 5000
    Return first.Result() + second.Result()
End Sub
```

**參數與執行說明:**

ValueLater 以傳值接收 value 和 milliseconds。兩次呼叫均在讀取結果前啟動：10 毫秒後取得 22，30 毫秒後取得 20。Main 最多等 5000 毫秒，再用 Result() 取得 Integer 相加，回傳 42。Wait Until 逾時會報錯。

### 2. 攔截等候中的錯誤

```vb
# FailLater 沒有回傳值，5 毫秒後擲出錯誤。ReadFailure 在 Await 處接收，儲存文字並在 Finally 設定共用清理旗標。Main 最多等 5000 毫秒，回傳 String "failed:1"；1 代表 True。Catch/Finally 內沒有 Await。
Option Explicit On
Module State
    Public Dim cleaned As Boolean = False
End Module

Async Function FailLater() As Task
    Await Delay(5)
    Throw "failed"
End Function

Async Function ReadFailure() As Task(Of String)
    Dim message As String = ""
    Try
        Await FailLater()
    Catch problem
        message = problem
    Finally
        State.cleaned = True
    End Try
    Return message & ":" & CStr(State.cleaned)
End Function

Sub Main()
    Dim task = ReadFailure()
    Wait Until task.IsCompleted() Timeout 5000
    Return task.Result()
End Sub
```

**參數與執行說明:**

FailLater 沒有回傳值，5 毫秒後擲出錯誤。ReadFailure 在 Await 處接收，儲存文字並在 Finally 設定共用清理旗標。Main 最多等 5000 毫秒，回傳 String "failed:1"；1 代表 True。Catch/Finally 內沒有 Await。

### 3. 迴圈與結果傳遞

```vb
# IncrementLater(value) 等 5 毫秒後回傳 value+1。SumLater 對 i=1..3 依次等候並保留 total 與 i。ForwardResult 用 Return Await 傳遞 9。Main 回傳 Integer 9，是總和而非邏輯值。
Option Explicit On
Async Function IncrementLater(ByVal value As Integer) As Task(Of Integer)
    Await Delay(5)
    Return value + 1
End Function

Async Function SumLater() As Task(Of Integer)
    Dim total As Integer = 0
    For Var i = 1 To 3
        Dim nextValue = Await IncrementLater(i)
        total += nextValue
    Next
    Return total
End Function

Async Function ForwardResult() As Task(Of Integer)
    Return Await SumLater()
End Function

Sub Main()
    Dim task = ForwardResult()
    Wait Until task.IsCompleted() Timeout 5000
    Return task.Result()
End Sub
```

**參數與執行說明:**

IncrementLater(value) 等 5 毫秒後回傳 value+1。SumLater 對 i=1..3 依次等候並保留 total 與 i。ForwardResult 用 Return Await 傳遞 9。Main 回傳 Integer 9，是總和而非邏輯值。


### 內部函式：從呼叫到結果

函式立即執行到第一個尚未完成的 Await。區域變數、迴圈位置、With 物件和偵錯框架會儲存，繼續時還原。已完成的工作不會暫停；Await 運算元只計算一次。

#### 1. Delay

Delay 接受 0..2147483647 毫秒的 Integer。0 立即完成；負數、小數及 String 會引發可攔截錯誤。使用單調時鐘，期限代表最短等待時間，不保證精確執行時刻。

due = monotonicNow + milliseconds
return task

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/ScriptAsyncScheduler.cs`; 函式 `Delay`.

#### 2. ResolveAwaitTask

工作變數不宣告型別或使用 As Object。Await 接受本次執行的工作，可獨立成句、作為單一純量宣告/指派的完整右側，或用於 Return Await。不能嵌入算術、條件、欄位/索引指派、Catch/Finally，也不能用於 Async Function 之外。多個函式可以等候同一工作；循環相依會報錯。

validate owner and dependency chain
evaluate operand once

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Async.cs`; 函式 `ResolveAwaitTask`.

#### 3. ExecuteSubrutine

函式立即執行到第一個尚未完成的 Await。區域變數、迴圈位置、With 物件和偵錯框架會儲存，繼續時還原。已完成的工作不會暫停；Await 運算元只計算一次。

save locals, With receiver, debugger frame
suspend until task completes
restore saved state

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.cs`; 函式 `ExecuteSubrutine`.

#### 4. Pump

指令碼所屬執行緒在安全檢查點檢查期限，每輪恢復最多 64 個待執行的接續步驟，不建立額外執行緒。同步 Wait 或耗時遊戲/原生呼叫可能延遲其他工作；請使用 Await Delay。最多保留 1024 個未完成工作或尚未讀取的失敗工作。

if earliest deadline reached: complete delays
resume at most 64 queued continuations
refresh function results

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/ScriptAsyncScheduler.cs`; 函式 `Pump`.

#### 5. GetResult

IsCompleted 在成功、失敗或取消後為 1；IsFaulted 在失敗時為 1；IsCanceled 在取消時為 1。這些 Integer 判斷可與 True/False 比較。Result() 回傳儲存的值；未完成時報錯，失敗後重新擲回原錯誤。不能重用上一次執行的工作。

if pending: error
if failed: rethrow
return saved value

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ScriptTaskObject.cs`; 函式 `GetResult`.

#### 6. Release

暫停會阻止繼續執行，但時間仍前進；恢復後處理到期工作。Stop、錯誤或進入點返回會取消剩餘工作並釋放 Using 資源和迭代器。緊急取消會跳過指令碼 Catch/Finally。未讀取的工作錯誤在進入點結束時回報。單獨關閉 IDE 不會停止執行中的指令碼。

cancel pending tasks
drain cleanup continuations
release resources
report unobserved failure

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/ScriptAsyncScheduler.cs`; 函式 `Release`.

指令碼呼叫 Async Function 和 Delay 時得到 Object (ScriptTask)，不是立即得到 T。Await 和 Result() 回傳 T；As Task 和 Delay 以 Unit 完成，沒有值。用戶端直接啟動 Async Function 作為進入點時，會協作等候並取得最終結果。數值資料不一定是 Boolean。

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: ASYNC / awaitExpression / taskType
Analysis/AsyncValidator.cs: supported statement forms and signatures
Runtime/Interpreter.cs: ExecuteSubrutine / statement suspension / cleanup
Runtime/Interpreter.Async.cs: ResolveAwaitTask / ResumeAsync / WaitForTask
Runtime/ScriptAsyncScheduler.cs: Delay / Track / Pump / Release
Runtime/ObjectTypes/ScriptTaskObject.cs: GetResult / Complete / Awaiter
Runtime/SemanticScope.cs: SuspendCurrent / Resume
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/modifiers/async
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/operators/await-operator
-->
