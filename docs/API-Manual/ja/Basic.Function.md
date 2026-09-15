# Function / Return / Exit Function / End Function

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ja -->

Function は数量、文字列、List/Dictionary の参照などを返す補助関数です。自作名に UO. は不要です。Function GetType(value) を宣言しても、UO.GetType(item) は別のゲーム API のままです。

## 正確な構文

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

## パラメーター

- `name` — 大文字小文字を区別しない名前は、呼び出し名と本体内の暗黙のローカル結果変数を兼ねます。name は現在の結果を読み、name(arguments) は再帰を含む関数呼び出しです。Dim、Var、Const、仮引数で結果を再宣言しないでください。
- `parameters / arguments` — 位置引数は Sub と同じく、既定の ByRef、ByVal、Optional、末尾の ParamArray に従います。Basic.Parameters と個別章を参照してください。モジュール関数 Tools.Calculate(...) には Public/Private の規則が適用されます。
- `As type` — 省略可能な結果型です。Integer/Long/Short/Byte はエンジンの Integer、Double/Single/Decimal は Double、String は文字列、Boolean/Bool は 1/0 への正規化、Object/Variant は値の種類を保持します。VB.NET の全数値幅を実装するものではありません。未知の型はエラーです。As なしでは Variant、名前の接尾辞から結果型は推論しません。
- `name = expression` — 結果を保存し、次の文の実行を続けます。終了はしません。再読込や += などによる更新が可能です。これは今回の呼び出しのローカル変数で、グローバル値や新しい呼び出しではありません。
- `Return / Exit Function / End Function` — Return expression は型付き結果を代入して終了を開始します。空の Return、Exit Function、End Function への到達は現在の結果を返します。End Function は必須で、Function 内の Exit Sub は読み込みエラーです。

## 戻り値

通常の Finally 後の現在値を返します。初期値は Integer 0、Double 0.0、Boolean FALSE/0、String 空文字列です。型省略・Variant/Object は意味のある値がない Unit で始まります。List/Dictionary/Object は参照を保持します。Boolean は数値 1/0 なので TRUE/FALSE と比較できますが、任意の数量や ID は自動的な成功コードではありません。

## 動作

- 準備時に実際の Function 定義を保持し、型と終了文を検証し、ローカル結果を束縛して命令を一度準備します。呼び出すたびに引数と新しい型付き結果を作ります。名前への代入は通常の型付き変数の変換規則を使います。
- Return が結果を設定した後、離脱する Finally を内側から外側へ実行します。Finally は呼び出し元へ戻る前の結果を更新できます。成功終了後に ByRef の書き戻しを完了します。未処理例外や不正な変換はエラーとして伝わり、成功値を返しません。
- 再帰には独立した引数、ローカル値、結果があります。Factorial(n-1) は呼び出し元の結果を上書きしません。無限再帰を防ぐ終了条件が必要です。スレッド、待機、タイムアウトは自動追加されず、一時停止・停止の確認は続きます。
- スクリプト手続きの入れ子は、コールバックとイベントハンドラーを含めて 32 フレームまでです。超過すると捕捉可能なエラーになります。深い処理にはループを使用してください。復帰・エラー時にフレームを解放し、次の呼び出しを可能にします。

## 使用例

### 1. 代入して続行する

```vb
# TotalPrice は count と price を ByVal で受け取り Integer を返します。負数なら直ちに -1、そうでなければ count*price を保存し次の文で固定値 2 を加えます。(3,4) は 14、(-1,4) は -1 となり、Main は 14:-1 を返します。-1 は補助関数が定めた規則です。
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

**パラメーターと実行の説明:**

TotalPrice は count と price を ByVal で受け取り Integer を返します。負数なら直ちに -1、そうでなければ count*price を保存し次の文で固定値 2 を加えます。(3,4) は 14、(-1,4) は -1 となり、Main は 14:-1 を返します。-1 は補助関数が定めた規則です。

### 2. 再帰の独立した結果

```vb
# Factorial は n を ByVal で受け取り結果を 1 にします。n<=1 なら Exit Function で 1 を返し、それ以外は新しい呼び出しで n*Factorial(n-1) を計算します。小さな非負入力では 5!+3!=120+6=126 です。負数も基底分岐へ入るため、数学的な定義域全体を検証する例ではありません。
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

**パラメーターと実行の説明:**

Factorial は n を ByVal で受け取り結果を 1 にします。n<=1 なら Exit Function で 1 を返し、それ以外は新しい呼び出しで n*Factorial(n-1) を計算します。小さな非負入力では 5!+3!=120+6=126 です。負数も基底分岐へ入るため、数学的な定義域全体を検証する例ではありません。

### 3. Return、二つの Finally、ByRef

```vb
# Calculate は trace を ByRef で受け取ります。Return 1 が結果を設定し終了を開始します。内側 Finally が結果と trace を 1 から 12、外側が 123 に変えます。Main は両方の 123 を受け取り 123:123 を返します。Return expression 後も Finally は結果を変更できます。ゲームの移動や待ち時間は模擬していません。
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

**パラメーターと実行の説明:**

Calculate は trace を ByRef で受け取ります。Return 1 が結果を設定し終了を開始します。内側 Finally が結果と trace を 1 から 12、外側が 123 に変えます。Main は両方の 123 を受け取り 123:123 を返します。Return expression 後も Finally は結果を変更できます。ゲームの移動や待ち時間は模擬していません。

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
