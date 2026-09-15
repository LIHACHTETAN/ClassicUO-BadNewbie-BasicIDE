# Event / AddHandler / RemoveHandler / RaiseEvent

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ja -->

Event はスクリプトのイベントを宣言します。AddHandler で Sub を登録し、RemoveHandler で解除します。RaiseEvent は登録順にハンドラーを同期実行します。

## 正確な構文

```text
Event Changed(ByVal value As Integer)
Public Event Adjust(ByRef value As Integer)
Private Event Completed()
AddHandler EventName, AddressOf Handler
AddHandler Module.EventName, callback
RemoveHandler EventName, AddressOf Handler
RaiseEvent EventName(arguments)
```

## パラメーター

- `EventName / Public / Private` — ファイル直下（暗黙のスクリプトモジュール）または Module 内の、手続きの外側で単純名を宣言します。既定は Public、Private には Module が必要です。外部からの登録は Module.EventName を使います。Public でも RaiseEvent は宣言元モジュールだけが実行できます。手続き・変数との同名は禁止です。
- `Handler / callback` — Handler は一意に宣言された Sub です。AddressOf または同じ読み込み済みスクリプトのコールバック変数／ファクトリで渡します。Function、名前の文字列、別スクリプトの参照、オーバーロード群は使えません。引数の数・型・ByVal/ByRef を一致させます。通常手続きの旧来の既定値は ByRef なので、ハンドラーでは ByVal を明記してください。
- `arguments / ByVal / ByRef` — RaiseEvent はすべての位置引数を必要とします。Optional、ParamArray、既定値、イベントの名前付き引数、Safe Call は非対応です。Event 引数の既定は ByVal で、値または参照をコピーし、オブジェクト内容は複製しません。ByRef の変更は後続ハンドラーに伝わり、呼び出し元の書き込み可能な変数・添字要素へ戻ります。引数と添字は記述順に一度ずつ評価します。

## 戻り値

Event、AddHandler、RemoveHandler、RaiseEvent に戻り値はありません（Unit）。Boolean、ID、登録数でもありません。結果の受け渡しには ByRef や Module の共有状態を使用します。各例の Main は String "ready"、Integer 8、String "ABAC:handler failed" を返します。

## 動作

- 登録は各インタープリターに属し、別のスクリプトや再読み込みには引き継がれません。同じ読み込み済みインタープリターへの次の入口呼び出しでは、解除または解放まで維持します。IDE を閉じても実行中スクリプトと登録は残りますが、独立した背景イベントサービスは作成しません。
- AddHandler は末尾に追加し、重複登録は同じ Sub を繰り返し呼びます。RemoveHandler は最後の一致を削除し、一致がなければ何もしません。宣言・アクセス・シグネチャを確認し、引数を評価後、順序付きリストを固定します。ハンドラー内の登録変更は次回の RaiseEvent に反映されます。
- ハンドラーのエラーは残りの呼び出しを中止し、呼び出し元の Catch/Finally に届きます。既存の ByRef 変更は書き戻します。一時停止と緊急停止はハンドラー内でも有効で、Catch は緊急停止を吸収しません。新しいスレッドは作りません。ブロックするネイティブ呼び出しには固有の取消制限が残ります。
- 上限はイベントごとに登録 4096 件、RaiseEvent の入れ子 16 段、スクリプト手続きフレーム 32 段です。循環や深い再帰はクライアントをスタックオーバーフローさせず、捕捉可能なエラーになります。深い処理にはループを使ってください。共有スカラーは Module フィールドへ置きます。旧来のファイル直下のスカラーはコピーとして継承します。
- この構文はスクリプトから明示的に発生させるイベント用です。ゲームパケットやジャーナル変化を自動購読しません。Handles、WithEvents、Custom Event、イベントデリゲート型、クラスイベントは未実装です。Basic のキーワードは UO. なし、ゲーム API は UO. 付きです。

## 使用例

### 1. 登録と解除

```vb
# Feed.Message は text As String を ByVal で渡します。全体を掲載した Feed.Publish がイベントを発生させ、Record が共有 State.log に追記します。handler が Record を登録し、"ready" が保存されます。別行の AddressOf Record でも同じ Sub として解除できます。解除後の "ignored" は追加されず、Main は "ready" を返します。
Option Explicit On
Module Feed
    Public Event Message(ByVal text As String)
    Public Sub Publish(ByVal text As String)
        RaiseEvent Message(text)
    End Sub
End Module

Module State
    Public Dim log As String = ""
End Module

Sub Record(ByVal text As String)
    State.log = State.log & text
End Sub

Sub Main()
    Dim handler = AddressOf Record
    AddHandler Feed.Message, handler
    Feed.Publish("ready")
    RemoveHandler Feed.Message, AddressOf Record
    Feed.Publish("ignored")
    Return State.log
End Sub
```

**パラメーターと実行の説明:**

Feed.Message は text As String を ByVal で渡します。全体を掲載した Feed.Publish がイベントを発生させ、Record が共有 State.log に追記します。handler が Record を登録し、"ready" が保存されます。別行の AddressOf Record でも同じ Sub として解除できます。解除後の "ignored" は追加されず、Main は "ready" を返します。

### 2. 値を順番に変更

```vb
# Adjust と両 Sub は total As Integer ByRef を宣言します。Increment が 3 を 4 にし、DoubleValue は 4 を受けて 8 にします。RaiseEvent が Main に 8 を書き戻した後、両登録を解除します。Integer 8 は数量であり True/False ではありません。RaiseEvent 自体に戻り値はありません。
Option Explicit On
Event Adjust(ByRef total As Integer)

Sub Increment(ByRef total As Integer)
    total += 1
End Sub

Sub DoubleValue(ByRef total As Integer)
    total *= 2
End Sub

Sub Main()
    Dim total As Integer = 3
    AddHandler Adjust, AddressOf Increment
    AddHandler Adjust, AddressOf DoubleValue
    RaiseEvent Adjust(total)
    RemoveHandler Adjust, AddressOf Increment
    RemoveHandler Adjust, AddressOf DoubleValue
    Return total
End Sub
```

**パラメーターと実行の説明:**

Adjust と両 Sub は total As Integer ByRef を宣言します。Increment が 3 を 4 にし、DoubleValue は 4 を受けて 8 にします。RaiseEvent が Main に 8 を書き戻した後、両登録を解除します。Integer 8 は数量であり True/False ではありません。RaiseEvent 自体に戻り値はありません。

### 3. エラーを捕捉して続行

```vb
# Ready は引数なしです。First が A、Failing が B を追加してエラーを投げるため、この回の Last は省略します。Catch がメッセージを保存し、Finally が Failing を解除します。次回は AC を追加し、Main は "ABAC:handler failed" を返します。全ハンドラーと State を掲載しています。
Option Explicit On
Event Ready()
Module State
    Public Dim log As String = ""
End Module

Sub First()
    State.log = State.log & "A"
End Sub

Sub Failing()
    State.log = State.log & "B"
    Throw "handler failed"
End Sub

Sub Last()
    State.log = State.log & "C"
End Sub

Sub Main()
    Dim message As String = ""
    AddHandler Ready, AddressOf First
    AddHandler Ready, AddressOf Failing
    AddHandler Ready, AddressOf Last
    Try
        RaiseEvent Ready()
    Catch problem
        message = problem
    Finally
        RemoveHandler Ready, AddressOf Failing
    End Try
    RaiseEvent Ready()
    Return State.log & ":" & message
End Sub
```

**パラメーターと実行の説明:**

Ready は引数なしです。First が A、Failing が B を追加してエラーを投げるため、この回の Last は省略します。Catch がメッセージを保存し、Finally が Failing を解除します。次回は AC を追加し、Main は "ABAC:handler failed" を返します。全ハンドラーと State を掲載しています。

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: eventDeclaration / eventHandler / raiseEvent
Runtime/EventCatalog.cs: Build / TryResolve / HandlerError
Analysis/EventValidator.cs: ValidateHandler / ValidateRaise / ValidateNativeNames
Runtime/Interpreter.Events.cs: VisitEventHandler / VisitRaiseEvent
Runtime/Interpreter.cs: CallSubrutine / ExecuteSubrutine / ByRef copy-back
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/event-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/addhandler-statement
-->
