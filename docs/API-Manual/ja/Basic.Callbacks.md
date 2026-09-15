# AddressOf / callbacks

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ja -->

AddressOf はスクリプトの Sub または Function への参照を取得します。この時点では呼び出しません。参照を引数として渡す、関数から返す、コレクションに保存することで処理規則を選べます。

## 正確な構文

```text
Dim callback = AddressOf ProcedureName
Dim callback As Object = AddressOf Tools.FunctionName
callback(arguments)
callback.Invoke(arguments)
Process(values, AddressOf Predicate)
```

## パラメーター

- `ProcedureName` — 宣言済みの手続き名です。必要なら Module 名を付けます。一致する宣言は一つだけ必要です。未定義名、アクセスできない Private、多重定義の名前は実行前に拒否します。Basic 組み込み関数や UO コマンドには一意の名前を持つスクリプトのラッパーを作り、その AddressOf を使います。名前の後に括弧は付けません。
- `callback / arguments` — callback は Object 値です。callback(...) と callback.Invoke(...) は現在のスクリプトスレッドで同期実行します。名前付き引数には実際の仮引数名を使います。コレクション要素はまず変数へ代入してください。参照は引数の評価前に確定するため、引数が callback を書き換えても対象は変わりません。
- `ByRef / ByVal / Optional / ParamArray` — ByVal は値または参照をコピーし、ByRef は変更を書き戻します。Optional は省略値を計算し、ParamArray は位置引数をまとめます。名前付き引数は位置引数の後に置きます。ParamArray の値には位置引数のみの呼び出しが必要です。名前や個数の誤りは引数の副作用より前に検出します。

## 戻り値

AddressOf は Object 参照を返します。ID、メモリアドレス、Boolean、関数の実行結果ではありません。Function の呼び出しはその結果を返し、Return 式がない Sub は値を返しません（Unit）。IsPositive は 1/True または 0/False を返します。例 1 と 3 の Main は String、例 2 は Integer 15 を返します。

## 動作

- 参照は生成元関数のローカル変数を捕捉しません。ラムダやクロージャではありません。参照はロード済みスクリプトに属し、別の実行環境や再ロード後には古い参照を呼び出せません。Public のファクトリは自身の Private ヘルパーへの参照を明示的に公開できます。
- 準備段階で名前とアクセスを検査します。インタープリターは AddressOf の位置ごとに不変参照を保存します。各呼び出しで現在の変数を読み、シグネチャを確認し、引数を記述順に一度ずつ評価して通常の手続きフレームに入ります。ByRef と例外処理は直接呼び出す場合と同じです。
- 新しいスレッドやタイマーは作りません。一時停止とキャンセルは通常のチェックポイントを使い、コールバック内のループにも適用します。エラーは呼び出し元の Catch/Finally に届きます。緊急停止は Catch で無視できません。ブロックするネイティブ呼び出しには固有のキャンセル制限があります。
- この機能では Delegate 型宣言、ラムダ、DLL 関数ポインター、オーバーロードへの参照は未対応です。AddressOf に UO. は付けません。ラッパー内のゲームコマンドには UO. を付けます。
- スクリプト手続きの入れ子は、コールバックとイベントハンドラーを含めて 32 フレームまでです。超過すると捕捉可能なエラーになります。深い処理にはループを使用してください。復帰・エラー時にフレームを解放し、次の呼び出しを可能にします。

## 使用例

### 1. 述語でリストを絞る

```vb
# values は入力 List、predicate は AddressOf IsPositive です。FilterValues は各数値で predicate(number) を一度呼びます。正数の 4 と 7 が残り、selected.Count()=2、selected[0]=4 なので Main は "2:4" を返します。二つのヘルパーはコード内に全文があり、追加の API コマンドではありません。
Option Explicit On
Function IsPositive(ByVal number) As Boolean
    Return number > 0
End Function

Function FilterValues(ByVal values, ByVal predicate)
    Dim result = List()
    For Each number In values
        If predicate(number) Then
            result.Add(number)
        End If
    Next
    Return result
End Function

Sub Main()
    Dim numbers = List()
    numbers.Add(-2)
    numbers.Add(4)
    numbers.Add(7)
    Dim selected = FilterValues(numbers, AddressOf IsPositive)
    Return CStr(selected.Count()) & ":" & CStr(selected[0])
End Sub
```

**パラメーターと実行の説明:**

values は入力 List、predicate は AddressOf IsPositive です。FilterValues は各数値で predicate(number) を一度呼びます。正数の 4 と 7 が残り、selected.Count()=2、selected[0]=4 なので Main は "2:4" を返します。二つのヘルパーはコード内に全文があり、追加の API コマンドではありません。

### 2. 呼び出し元の変数を変更

```vb
# AddAmount の total は ByRef、amount は ByVal で既定値 1 です。update(total) は 10 を 11 にします。Invoke(amount:=4, total:=total) は名前で引数を対応させ、11 を 15 にします。ByRef が元の変数へ書き戻します。Sub は値を返さず、Main は Boolean ではなく Integer 15 を返します。
Option Explicit On
Sub AddAmount(ByRef total As Integer, Optional ByVal amount = 1)
    total += amount
End Sub

Sub Main()
    Dim update = AddressOf AddAmount
    Dim total = 10
    update(total)
    update.Invoke(amount:=4, total:=total)
    Return total
End Sub
```

**パラメーターと実行の説明:**

AddAmount の total は ByRef、amount は ByVal で既定値 1 です。update(total) は 10 を 11 にします。Invoke(amount:=4, total:=total) は名前で引数を対応させ、11 を 15 にします。ByRef が元の変数へ書き戻します。Sub は値を返さず、Main は Boolean ではなく Integer 15 を返します。

### 3. 非公開の規則とエラー処理

```vb
# Rules.Create は Private CheckedDouble への参照を返します。外部から AddressOf Rules.CheckedDouble を直接使うことはできません。operation(6) は 12 を返し、operation(-1) は代入前に "negative" を投げるため result は 12 のままです。Catch が文字列を受け、Finally が ":done" を追加し、Main は "12:negative:done" を返します。IDE を閉じてもスクリプトは停止しません。
Option Explicit On
Module Rules
    Private Function CheckedDouble(ByVal number) As Integer
        If number < 0 Then
            Throw "negative"
        End If
        Return number * 2
    End Function

    Public Function Create()
        Return AddressOf CheckedDouble
    End Function
End Module

Sub Main()
    Dim operation = Rules.Create()
    Dim result = operation(6)
    Dim message = ""
    Try
        result = operation(-1)
    Catch problem
        message = problem
    Finally
        message = message & ":done"
    End Try
    Return CStr(result) & ":" & message
End Sub
```

**パラメーターと実行の説明:**

Rules.Create は Private CheckedDouble への参照を返します。外部から AddressOf Rules.CheckedDouble を直接使うことはできません。operation(6) は 12 を返し、operation(-1) は代入前に "negative" を投げるため result は 12 のままです。Catch が文字列を受け、Finally が ":done" を追加し、Main は "12:negative:done" を返します。IDE を閉じてもスクリプトは停止しません。

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: addressOf / ADDRESSOF
Runtime/Metadata.cs: TryGetCallbackTarget
Analysis/InvalidSymbolVisitor.cs: VisitAddressOf
Runtime/Interpreter.Callbacks.cs: VisitAddressOf / TryGetCallback / CallCallback
Runtime/Interpreter.cs: CreateArgumentWriter / CallSubrutine
Runtime/NamedArgumentBinding.cs: TryCreate
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/operators/addressof-operator
-->
