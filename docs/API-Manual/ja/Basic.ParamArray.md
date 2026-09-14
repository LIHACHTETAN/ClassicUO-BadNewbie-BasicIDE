# ParamArray

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ja -->

パラメーターは SUB/FUNCTION にデータを渡します。ByRef は変更値を呼び出し元へ書き戻し、ByVal は呼び出し元の変数を保ちます。Optional は省略引数を補い、ParamArray は残りの引数を集めます。呼び出す命令ではなく宣言の修飾子です。

## 正確な構文

```text
Function Sum(ParamArray values())
Sum()
Sum(2, 3, 4)
Sum(existingArray)
```

## パラメーター

- `name / As type` — name / As type: パラメーター名と任意の As 入力型変換。位置または name:=value で引数を対応させ、修飾子は宣言に記述します。Basic.NamedArguments を参照。
- `ByRef` — ByRef：書き込み可能な変数または既存の添字要素です。このエンジンは ByVal を省略した場合も書き戻し、VB.NET の既定とは異なります。リテラル、定数、計算式は一時値です。
- `ByVal` — ByVal：値のローカルコピーです。パラメーターの再代入は呼び出し元の変数を置換しません。配列とオブジェクトは参照を共有し、深いコピーではありません。
- `Optional / defaultValue` — Optional / defaultValue：末尾の引数を省略した場合に = 後の式を評価します。既定値を明示してください。ない場合は未初期化の Unit になります。
- `ParamArray` — ParamArray values()：最後のパラメーターが残りの値をゼロ個以上受け取ります。配列一つなら直接再使用し、スカラーなら新しい配列を作ります。GetArrayLength が長さを返します。

## 戻り値

修飾子は値を返しません。RETURN が結果を別に設定します。ByRef は引数の変更であり戻り値ではありません。RETURN のない SUB は Unit を返します。例の数値は計算結果で、TRUE/FALSE のフラグではありません。

## 動作

- 引数は左から右へ一度ずつ評価します。添字付き ByRef はコンテナーと添字／キーを保持し、別の引数がコンテナー変数を再代入しても書き戻し先は変わりません。
- 入口でローカルパラメーターを作ります。終了時は内部 FINALLY の後、パラメーター順に ByRef を書き戻します。本文からエラーで抜ける場合も同様です。同じ変数を二度渡しても二つのローカル値は即時連動せず、最後の書き戻しが残ります。
- ByVal は呼び出し元の変数の置換を防ぎますが、共有する配列やオブジェクト内部は変更できます。ReDim は新しいローカル参照を作ります。独立したデータには明示的なコピーが必要です。
- 位置指定の呼び出しでは：Optional は末尾から省略し、コンマ間の空引数は使えません。既定値は省略ごとに評価するエンジンの式でよく、VB.NET の定数である必要はありません。 位置指定を先に書き、最初の名前付き引数以降はすべて名前付きにします。必須引数は省略できません。スクリプトで省略した Optional は、渡した式の後に宣言順で既定式を評価します。ネイティブのオーバーロードは登録済みの名前と個数だけを使い、既定値を追加しません。
- ParamArray はまとめたスカラーを元の変数へ書き戻しません。配列を明示して渡した場合、要素変更は呼び出し元にも見えます。別の ParamArray に渡しても入れ子は増えません。
- 意図を示すため ByRef と ByVal を明示してください。ユーザー手続きのスクリプト呼び出しの規則であり、組み込み命令の引数は各ページに説明があります。
- ParamArray は名前で指定できません。名前付き呼び出しでは空のままにでき、要素を渡すには完全な位置指定呼び出しを使います。空のカンマ枠は未対応です。位置指定を先にする部分仕様で、新しい VB.NET の自由な混在ではありません。スレッドやゲーム待機時間は増やしません。

## 使用例

### 1. 空の引数列と値のある引数列

```vb
# Sum() は空配列で 0、Sum(2,3,4) は三つの値で 9 を返します。For Each が各値を処理し、Main は Integer 9 を返します。
Option Explicit On
Function Sum(ParamArray values())
    Var total = 0
    For Each value In values
        total += value
    Next
    Return total
End Function
Sub Main()
    Return Sum() + Sum(2, 3, 4)
End Sub
```

**パラメーターと実行の説明:**

Sum() は空配列で 0、Sum(2,3,4) は三つの値で 9 を返します。For Each が各値を処理し、Main は Integer 9 を返します。

### 2. 既存配列を転送する

```vb
# values は 2 と 5 を持ちます。Forward は余分な包みなしで Sum に渡し、Sum は合計 Integer 7 を返します。
Option Explicit On
Function Sum(ParamArray values())
    Var total = 0
    For Each value In values
        total += value
    Next
    Return total
End Function
Function Forward(ParamArray values())
    Return Sum(values)
End Function
Sub Main()
    Dim values[1]
    values[0] = 2
    values[1] = 5
    Return Forward(values)
End Sub
```

**パラメーターと実行の説明:**

values は 2 と 5 を持ちます。Forward は余分な包みなしで Sum に渡し、Sum は合計 Integer 7 を返します。

### 3. スカラーと明示配列

```vb
# SetFirst(first,second) は新しい配列を変更し、first=2、second=3 は保たれます。SetFirst(packed) は共有 packed[0] を 4 から 9 に変えます。Main は 2*100+3*10+9、Integer 239 を返します。
Option Explicit On
Sub SetFirst(ParamArray values())
    If GetArrayLength(values) > 0 Then
        values[0] = 9
    End If
End Sub
Sub Main()
    Var first = 2
    Var second = 3
    SetFirst(first, second)
    Dim packed[0]
    packed[0] = 4
    SetFirst(packed)
    Return first * 100 + second * 10 + packed[0]
End Sub
```

**パラメーターと実行の説明:**

SetFirst(first,second) は新しい配列を変更し、first=2、second=3 は保たれます。SetFirst(packed) は共有 packed[0] を 4 から 9 に変えます。Main は 2*100+3*10+9、Integer 239 を返します。

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: parameterName / parameterModifier / defaultValue
Runtime/SubrutineDefinition.cs: WritableParameters / RequiredArgumentCount / HasParamArray
Runtime/Interpreter.cs: VisitCall / CreateArgumentWriter / CallSubrutine / EvaluateInitializer
Runtime/IndexedValueSlot.cs: Read / Write
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/modifiers/byref
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/modifiers/byval
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/modifiers/optional
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/modifiers/paramarray
-->
