# Named arguments / :=

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ja -->

名前付き引数は宣言されたパラメーター名に値を対応させるため、宣言と異なる順序で記述できます。スクリプトの手続き、関数、モジュール、登録済み Basic/UO 関数、ネイティブオブジェクトのメソッドに対応します。

## 正確な構文

```text
FunctionName(parameterName:=expression, otherName:=expression)
FunctionName(positionalExpression, optionalName:=expression)
FunctionName([reservedName]:=expression)
```

## パラメーター

- `parameterName / [reservedName]` — 宣言やシグネチャの名前を name:=value と書きます。大文字小文字は区別しません。予約語の名前は [to]:=100 のように囲みます。角括弧は名前のエスケープで、配列添字ではありません。不明または重複した名前はエラーです。
- `expression` — 渡す式は記述順に左から右へ一度ずつ評価され、対応するパラメーターへ割り当てられます。型、範囲、ByVal/ByRef の規則は呼び出す関数に従います。名前付き表記で普通の値が書き戻し可能な変数に変わることはありません。
- `positionalExpression / optionalName` — 位置指定を先に書き、最初の名前付き引数以降はすべて名前付きにします。必須引数は省略できません。スクリプトで省略した Optional は、渡した式の後に宣言順で既定式を評価します。ネイティブのオーバーロードは登録済みの名前と個数だけを使い、既定値を追加しません。

## 戻り値

:= 自体は値を返しません。関数/API の戻り値はそのままで、Sub に暗黙の結果はありません。例は Integer 129 と String "21:12"、"20:10:2" を返し、Boolean の成功フラグではありません。

## 動作

- 準備段階では不正な名前、重複、必須引数の不足、曖昧さをソース位置付き SC027 で報告します。動的オブジェクトは実行時に引数式の評価前に検証します。対応するネイティブ呼び出しがない場合、引数なしの版へ切り替えません。
- 静的な呼び出し位置の不変な対応表をキャッシュします。式の評価は記述順で、パラメーター代入と ByRef 書き戻しは対応表に従います。既定値とデバッガーの引数は選択したシグネチャに対応します。動的な対象は呼び出しごとに取得し、前のオブジェクトを再利用しません。
- ParamArray は名前で指定できません。名前付き呼び出しでは空のままにでき、要素を渡すには完全な位置指定呼び出しを使います。空のカンマ枠は未対応です。位置指定を先にする部分仕様で、新しい VB.NET の自由な混在ではありません。スレッドやゲーム待機時間は増やしません。

## 使用例

### 1. 中央の Optional を省略する

```vb
# Encode は x、y=2、z=3 を宣言します。z:=9 を先に、x:=1 を後に渡し、y は 2 になります。計算は 1*100+2*10+9=129。Encode(1,2,9) または Encode(1,z:=9) と同じです。
Option Explicit On
Function Encode(ByVal x, Optional ByVal y=2, Optional ByVal z=3) As Integer
    Return x*100 + y*10 + z
End Function

Sub Main()
    Dim encoded = Encode(z:=9, x:=1)
    Return encoded
End Sub
```

**パラメーターと実行の説明:**

Encode は x、y=2、z=3 を宣言します。z:=9 を先に、x:=1 を後に渡し、y は 2 になります。計算は 1*100+2*10+9=129。Encode(1,2,9) または Encode(1,z:=9) と同じです。

### 2. ByRef で目的の変数へ書き戻す

```vb
# Change の引数は ByRef left と right。right:=a は a=1 を right に、left:=b は b=2 を left に対応させます。left に 10、right に 20 を加え、b=12、a=21 を書き戻します。Main は "21:12"。:= の左がパラメーター、右が呼び出し側の変数です。
Option Explicit On
Sub Change(ByRef left, ByRef right)
    left += 10
    right += 20
End Sub

Sub Main()
    Dim a = 1
    Dim b = 2
    Change(right:=a, left:=b)
    Return CStr(a) & ":" & CStr(b)
End Sub
```

**パラメーターと実行の説明:**

Change の引数は ByRef left と right。right:=a は a=1 を right に、left:=b は b=2 を left に対応させます。left に 10、right に 20 を加え、b=12、a=21 を書き戻します。Main は "21:12"。:= の左がパラメーター、右が呼び出し側の変数です。

### 3. ネイティブリストを操作する

```vb
# List() はリストを作ります。Add(value:=10) は 10 を追加し戻り値なし。Insert(value:=20,index:=0) は添字 0 に 20 を入れ、10 を添字 1 へ移します。Item(index:=...) は要素を、Count() は 2 を返します。Main は "20:10:2"。UO.Name(...) も同じ規則で、その指令の登録名と戻り値に従います。
Option Explicit On
Sub Main()
    Dim items = List()
    items.Add(value:=10)
    items.Insert(value:=20, index:=0)
    Dim first = items.Item(index:=0)
    Dim second = items.Item(index:=1)
    Return CStr(first) & ":" & CStr(second) & ":" & CStr(items.Count())
End Sub
```

**パラメーターと実行の説明:**

List() はリストを作ります。Add(value:=10) は 10 を追加し戻り値なし。Insert(value:=20,index:=0) は添字 0 に 20 を入れ、10 を添字 1 へ移します。Item(index:=...) は要素を、Count() は 2 を返します。Main は "20:10:2"。UO.Name(...) も同じ規則で、その指令の登録名と戻り値に従います。

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: argument
Runtime/NamedArgumentBinding.cs: TryCreate / TryCustom
Runtime/Interpreter.NamedArguments.cs: CallNamed
Runtime/Interpreter.cs: CallSubrutine / CreateArgumentWriter
Analysis/NamedArgumentsValidator.cs
https://learn.microsoft.com/en-us/dotnet/visual-basic/programming-guide/language-features/procedures/passing-arguments-by-position-and-by-name
-->
