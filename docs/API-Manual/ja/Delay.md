# Async / Await / Delay

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ja -->

Async Function はスクリプトのタスクを作成します。Await はその関数を中断し、同じスクリプト内の準備できた別の処理を進めます。新しいスレッドや VB.NET の完全な Task ライブラリではありません。

## 正確な構文

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

## パラメーター

- `milliseconds` — Delay は 0..2147483647 ミリ秒の Integer を受け取ります。0 は即時完了し、負数、小数、String は捕捉可能なエラーです。単調時計を使用し、期限は最小待機時間であって正確な実行時刻の保証ではありません。
- `Async Function / ByVal / Task(Of T)` — As Task は値なし、As Task(Of T) は Basic のスカラーまたは Object/Variant を返します。引数は明示的な ByVal または ParamArray が必要で、Optional と名前付き引数を使えます。ByRef と Async Sub/Declare は拒否します。タスクはグローバル変数や既定引数の初期化中ではなく、プロシージャ本体で作成してください。
- `task / Await` — タスク変数は型指定なし、または As Object とします。Await は現在の実行のタスクを、独立した文、単一スカラー宣言/代入の右辺全体、Return Await として受け取ります。算術、条件、フィールド/添字代入、Catch/Finally、および Async Function の外では使えません。複数の関数が同じタスクを待てますが、循環依存はエラーです。
- `IsCompleted / IsFaulted / IsCanceled / Result` — IsCompleted は成功・失敗・取消後に 1、IsFaulted は失敗時に 1、IsCanceled は取消時に 1 です。これらの Integer 判定は True/False と比較できます。Result() は保存した値を返し、未完了ならエラー、失敗済みなら元のエラーを再送出します。前回の実行のタスクは再利用できません。

## 戻り値

スクリプトから Async Function または Delay を呼ぶと、すぐに T ではなく Object (ScriptTask) が返ります。Await と Result() は T を返し、As Task と Delay は値のない Unit で完了します。クライアントが Async Function を開始点として起動すると協調的に待って最終結果を受け取ります。数値データは必ずしも Boolean ではありません。

## 動作

- 関数は最初の未完了 Await まで直ちに実行されます。ローカル変数、ループ位置、With 対象、デバッガーフレームを保存し、再開時に復元します。完了済みタスクは中断せず、Await のオペランドは一度だけ評価されます。
- スクリプト所有スレッドは安全な確認点で期限を調べ、1 回に最大 64 個の継続処理を再開します。追加スレッドはありません。同期 Wait や長いゲーム/ネイティブ呼び出しは他のタスクを遅らせるため、Await Delay を使ってください。未完了またはエラー未確認のタスクは最大 1024 個です。
- 一時停止中は継続処理を止めますが時間は進み、再開後に期限到来分を処理します。Stop、エラー、開始点の終了は残りのタスクを取り消し、Using リソースとイテレーターを解放します。緊急取消はスクリプトの Catch/Finally を実行しません。未確認のタスクエラーは開始点終了時に報告します。IDE を閉じるだけでは動作中のスクリプトは停止しません。
- Task.Run/WhenAll、外部 .NET タスク、Async Sub、Catch/Finally 内の Await、ローカル As Task 宣言は未対応です。必要なタスクより先に Main を終了しないでください。Async/Await は予約語です。

## 使用例

### 1. 独立した二つの待機

```vb
# ValueLater は value と milliseconds を値渡しで受け取ります。結果を読む前に両方を開始し、10ms 後に 22、30ms 後に 20 が準備できます。Main は最大 5000ms 待ち、Result() の Integer を足して 42 を返します。Wait Until の時間切れはエラーです。
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

**パラメーターと実行の説明:**

ValueLater は value と milliseconds を値渡しで受け取ります。結果を読む前に両方を開始し、10ms 後に 22、30ms 後に 20 が準備できます。Main は最大 5000ms 待ち、Result() の Integer を足して 42 を返します。Wait Until の時間切れはエラーです。

### 2. 待機中のエラーを捕捉

```vb
# FailLater は値を返さず、5ms 後にエラーを発生させます。ReadFailure は Await で受け取り、本文を保存して Finally で共有フラグを設定します。Main は最大 5000ms 待ち、String "failed:1" を返します。1 は True です。Catch/Finally に Await はありません。
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

**パラメーターと実行の説明:**

FailLater は値を返さず、5ms 後にエラーを発生させます。ReadFailure は Await で受け取り、本文を保存して Finally で共有フラグを設定します。Main は最大 5000ms 待ち、String "failed:1" を返します。1 は True です。Catch/Finally に Await はありません。

### 3. ループと結果の転送

```vb
# IncrementLater(value) は 5ms 待ち value+1 を返します。SumLater は total と i を保持して i=1..3 を順に待ちます。ForwardResult は Return Await で 9 を転送します。Main の Integer 9 は合計で、論理値ではありません。
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

**パラメーターと実行の説明:**

IncrementLater(value) は 5ms 待ち value+1 を返します。SumLater は total と i を保持して i=1..3 を順に待ちます。ForwardResult は Return Await で 9 を転送します。Main の Integer 9 は合計で、論理値ではありません。


### 内部関数：呼び出しから結果まで

関数は最初の未完了 Await まで直ちに実行されます。ローカル変数、ループ位置、With 対象、デバッガーフレームを保存し、再開時に復元します。完了済みタスクは中断せず、Await のオペランドは一度だけ評価されます。

#### 1. Delay

Delay は 0..2147483647 ミリ秒の Integer を受け取ります。0 は即時完了し、負数、小数、String は捕捉可能なエラーです。単調時計を使用し、期限は最小待機時間であって正確な実行時刻の保証ではありません。

due = monotonicNow + milliseconds
return task

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/ScriptAsyncScheduler.cs`; 関数 `Delay`.

#### 2. ResolveAwaitTask

タスク変数は型指定なし、または As Object とします。Await は現在の実行のタスクを、独立した文、単一スカラー宣言/代入の右辺全体、Return Await として受け取ります。算術、条件、フィールド/添字代入、Catch/Finally、および Async Function の外では使えません。複数の関数が同じタスクを待てますが、循環依存はエラーです。

validate owner and dependency chain
evaluate operand once

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Async.cs`; 関数 `ResolveAwaitTask`.

#### 3. ExecuteSubrutine

関数は最初の未完了 Await まで直ちに実行されます。ローカル変数、ループ位置、With 対象、デバッガーフレームを保存し、再開時に復元します。完了済みタスクは中断せず、Await のオペランドは一度だけ評価されます。

save locals, With receiver, debugger frame
suspend until task completes
restore saved state

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.cs`; 関数 `ExecuteSubrutine`.

#### 4. Pump

スクリプト所有スレッドは安全な確認点で期限を調べ、1 回に最大 64 個の継続処理を再開します。追加スレッドはありません。同期 Wait や長いゲーム/ネイティブ呼び出しは他のタスクを遅らせるため、Await Delay を使ってください。未完了またはエラー未確認のタスクは最大 1024 個です。

if earliest deadline reached: complete delays
resume at most 64 queued continuations
refresh function results

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/ScriptAsyncScheduler.cs`; 関数 `Pump`.

#### 5. GetResult

IsCompleted は成功・失敗・取消後に 1、IsFaulted は失敗時に 1、IsCanceled は取消時に 1 です。これらの Integer 判定は True/False と比較できます。Result() は保存した値を返し、未完了ならエラー、失敗済みなら元のエラーを再送出します。前回の実行のタスクは再利用できません。

if pending: error
if failed: rethrow
return saved value

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ScriptTaskObject.cs`; 関数 `GetResult`.

#### 6. Release

一時停止中は継続処理を止めますが時間は進み、再開後に期限到来分を処理します。Stop、エラー、開始点の終了は残りのタスクを取り消し、Using リソースとイテレーターを解放します。緊急取消はスクリプトの Catch/Finally を実行しません。未確認のタスクエラーは開始点終了時に報告します。IDE を閉じるだけでは動作中のスクリプトは停止しません。

cancel pending tasks
drain cleanup continuations
release resources
report unobserved failure

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/ScriptAsyncScheduler.cs`; 関数 `Release`.

スクリプトから Async Function または Delay を呼ぶと、すぐに T ではなく Object (ScriptTask) が返ります。Await と Result() は T を返し、As Task と Delay は値のない Unit で完了します。クライアントが Async Function を開始点として起動すると協調的に待って最終結果を受け取ります。数値データは必ずしも Boolean ではありません。

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
