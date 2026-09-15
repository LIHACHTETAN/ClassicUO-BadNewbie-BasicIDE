# Sub / Call / Exit Sub / End Sub

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ja -->

Sub は複数の文を名前付き手続きにまとめます。アイテム処理、検証、後処理の共通化に使えます。呼び出しは現在のスクリプト内で同期的に実行され、別のバックグラウンドスクリプトを開始しません。

## 正確な構文

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

## パラメーター

- `name` — 名前の大文字と小文字は区別されません。自作手続きには UO. を付けず、モジュールのメンバーには Tools.Work(...) を使います。Public/Private のアクセス規則は Basic.Module と Basic.Visibility を参照してください。
- `parameters / arguments` — 仮引数は括弧内に宣言し、実引数をその順序で渡します。既定は ByRef、ByVal は値のコピー、Optional は省略時の値、最後の ParamArray は追加引数をまとめます。型、配列、共有参照、書き戻しは五つの引数章で説明します。
- `statements / End Sub` — 本体は空でも構いませんが、End Sub が必要です。再帰を含め、各呼び出しは独自のローカル変数を持ちます。宣言はファイルまたはモジュールの直下に置き、別の手続き内には置けません。
- `Call` — name(arguments) の Call は省略可能です。Call name arguments は括弧なしの引数も受け付け、Call name は引数なしで呼び出します。Call は戻り値を捨てます。引数式は通常どおり評価され、自作名に UO. は追加されません。
- `Exit Sub / Return` — Exit Sub または式のない Return は現在の呼び出しを終了します。Sub 内の Return expression は Basic の互換拡張で、通常の VB.NET Sub にはありません。Sub 内の Exit Function は読み込みエラーです。

## 戻り値

End Sub、Exit Sub、空の Return は Unit を返します。意味のある結果がないということで、成功フラグや ID ではありません。従来の Basic Sub は Return expression で値を返せます。ByRef は別途呼び出し元の変数を変更できます。結果を計算する補助処理には Function を推奨します。

## 動作

- 準備時に互換ヘッダーと Call 形式を正規化し、ブロックを検証して名前を解決します。入る前に引数を評価・束縛します。呼び出し間で準備済み命令を再利用しますが、ローカル値は共有しません。
- インタープリターは呼び出しスコープを作り、本体の実行後に呼び出しの次へ戻ります。通常終了と Exit Sub は離脱する Finally を実行してから引数の書き戻しを完了します。例外は有効なハンドラーへ進み、失敗は成功を意味しません。
- 一時停止・停止の確認は続きます。スレッド、自動待機、タイムアウトは追加されません。再帰には終了条件が必要です。Sub 名への代入は結果を設定しません。この用途には Function を使います。
- スクリプト手続きの入れ子は、コールバックとイベントハンドラーを含めて 32 フレームまでです。超過すると捕捉可能なエラーになります。深い処理にはループを使用してください。復帰・エラー時にフレームを解放し、次の呼び出しを可能にします。

## 使用例

### 1. 三つの呼び出し形式

```vb
# total は 4 から始まります。AddAmount は total を ByRef で受け取り、省略した amount は 1、明示した 3 と 2 は ByVal です。括弧付き Call、括弧なし Call、通常呼び出しが同じ処理を実行し、Main は 4+1+3+2=10 を返します。
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

**パラメーターと実行の説明:**

total は 4 から始まります。AddAmount は total を ByRef で受け取り、省略した amount は 1、明示した 3 と 2 は ByVal です。括弧付き Call、括弧なし Call、通常呼び出しが同じ処理を実行し、Main は 4+1+3+2=10 を返します。

### 2. 公開入口と非公開の補助処理

```vb
# Batches.SumInto は total を ByRef で受け取り、3,-9,4 を values にまとめます。For Each が AppendAmount を呼びます。負数ならその補助処理だけを終了するので、-9 を飛ばしてループは続きます。初期値 2 から 2+3+4=9 となり、外部は公開された修飾名で呼びます。
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

**パラメーターと実行の説明:**

Batches.SumInto は total を ByRef で受け取り、3,-9,4 を values にまとめます。For Each が AppendAmount を呼びます。負数ならその補助処理だけを終了するので、-9 を飛ばしてループは続きます。初期値 2 から 2+3+4=9 となり、外部は公開された修飾名で呼びます。

### 3. 早期終了と後処理

```vb
# Finish は trace=1 として終了し、trace=99 は実行しません。Finally が 2 を付け加え、ByRef で trace=12 を書き戻します。LegacyValue は Basic Sub の Return 7 を示します。Main は 12*10+7=127 を返します。trace の数字は例独自の値で、ゲームの結果コードではありません。
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

**パラメーターと実行の説明:**

Finish は trace=1 として終了し、trace=99 は実行しません。Finally が 2 を付け加え、ByRef で trace=12 を書き戻します。LegacyValue は Basic Sub の Return 7 を示します。Main は 12*10+7=127 を返します。trace の数字は例独自の値で、ゲームの結果コードではありません。

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
