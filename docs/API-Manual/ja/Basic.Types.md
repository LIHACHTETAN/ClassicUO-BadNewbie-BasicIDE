# AS

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ja -->

AS はスカラー変数の変換規則を指定します。内部の値種別は Integer、Decimal、String、Array、Object、Unit（値なし）です。Boolean は Integer の 1/0 を使います。この Basic の別名は VB.NET の同名型と同じビット幅を保証しません。

## 正確な構文

```text
VAR name AS type [= value]
DIM name AS type [= value]
```

## パラメーター

- `name` — 宣言する変数名。読むと現在値を取得し、その後の代入でも毎回 AS 変換が適用されます。
- `type` — Integer、Long、Short、Byte：符号付き32ビット整数、範囲 -2147483648…2147483647。Short/Byte による範囲の縮小はありません。Double、Single、Decimal：内部名 Decimal の64ビット2進浮動小数点で、厳密な10進計算ではありません。String：文字列。Boolean、Bool：Integer 1/0。Variant、Object：入力の値種別を保持し、オブジェクト実体を要求しません。型名の大文字小文字は区別しません。
- `value` — 省略可能な初期値。数値、文字列、変数、関数結果を指定します。AS は宣言の一部です。式で明示的に変換する場合は CInt(value)、CDbl(value)、CStr(value)、CBool(value) を使います。

## 戻り値

AS 自体は値を返しません。変数の読み取りは保存済みの種別と値を返します。論理数値は TRUE=1、FALSE=0 です。個数2は非ゼロですが 2=TRUE は偽です。存在の確認には count<>0 または CBool(count) を使います。

## 動作

- 初期値なしの型付き VAR は整数/Boolean に0、Double/Single/Decimal に浮動小数点0、String に空文字列を設定します。型なし VAR と VAR AS Variant/Object は Unit です。スカラー DIM は String に空文字列、それ以外に0を補います。Unit を AS 経由で代入しても Unit のままです。
- AS Integer は範囲内の小数をゼロ方向に切り捨てます。CInt/CLng は丸め、ちょうど半分ならゼロから遠ざけます。2.6 は CInt で3、AS Integer で2です。整数文字列は全体が10進整数または0xの16進数である必要があり、"2.6" は無効です。先に範囲を確認してください。
- AS Boolean は元の値を数値ゼロと比較します。非ゼロ数値は1、ゼロは0です。単語は解析せず、文字列 "false" でも1になります。CBool は先に数値変換します。数値/論理値を使うか、文字列を期待する単語と明示的に比較してください。
- AS String はエンジンの文字列表現を使います。AS Double/Single/Decimal は小数点を使う数値文字列を解析します。数値 AS は Array を0に変換しますが、Object と不正な数値文字列には TRY/CATCH で処理できるエラーを発生させます。一方 CInt/CLng/CDbl/CSng/CBool は寛容で、認識できない文字列、Array、Object、Unit をまず0とします。文字列変換を使う前に IsNumeric(value) で確認してください。
- 宣言は初期式の評価、AS 変換、結果と型名の保存を行います。後の代入でも変換を繰り返します。浮動小数点は近似値で、厳密な10進金額計算は保証しません。スコープは VAR / DIM、名前の保護は CONST を参照してください。
- As の後には宣言済みの Structure 名も指定できます。その型の VAR と DIM は初期化式を省略すると既定のフィールド値を作ります。同じ宣言型のみ互換で、別の構造型へは変換しません。入れ子のコピーと参照フィールドは Structure / New を参照してください。

## 使用例

### 1. 代入変換と丸め

```vb
# source=2.6 は浮動小数点です。whole AS Integer は2を保存し、CInt(source) は rounded に3を返します。Main は2*10+3=23を返し、両方を確認できます。
Option Explicit On
SUB Main()
    VAR source = 2.6
    VAR whole AS Integer = source
    VAR rounded = CInt(source)
    RETURN whole * 10 + rounded
END SUB
```

**パラメーターと実行の説明:**

source=2.6 は浮動小数点です。whole AS Integer は2を保存し、CInt(source) は rounded に3を返します。Main は2*10+3=23を返し、両方を確認できます。

### 2. 個数と論理値の違い

```vb
# count=2 はアイテム数です。hasItems AS Boolean は1になります。TRUE は正確に1なので count=TRUE は偽、count<>0 は真です。Main の hasItems=1 は存在を表し、個数が1であることは表しません。
Option Explicit On
SUB Main()
    VAR count = 2
    VAR hasItems AS Boolean = count
    IF count = TRUE THEN
        RETURN -1
    END IF
    IF count <> 0 THEN
        RETURN hasItems
    END IF
    RETURN FALSE
END SUB
```

**パラメーターと実行の説明:**

count=2 はアイテム数です。hasItems AS Boolean は1になります。TRUE は正確に1なので count=TRUE は偽、count<>0 は真です。Main の hasItems=1 は存在を表し、個数が1であることは表しません。

### 3. Variant は値種別を保持

```vb
# value AS Variant は最初に Integer 7、その後 String "ore" を保存します。text AS String は空で始まります。CStr(12) は文字列 "12" を作り、文字列同士をつなぐと Main の戻り値 "ore12" になります。Variant では種別を変更できます。
Option Explicit On
SUB Main()
    VAR value AS Variant = 7
    value = "ore"
    VAR text AS String
    text = value + CStr(12)
    RETURN text
END SUB
```

**パラメーターと実行の説明:**

value AS Variant は最初に Integer 7、その後 String "ore" を保存します。text AS String は空で始まります。CStr(12) は文字列 "12" を作り、文字列同士をつなぐと Main の戻り値 "ore12" になります。Variant では種別を変更できます。

<!-- implementation references (not callable script procedures):
Runtime/InjectionValueKind.cs
Runtime/SemanticScope.cs: Coerce
Runtime/NumberConversions.cs
Runtime/Interpreter.cs: DefaultValueForType
Runtime/InjectionApi.cs: CInt / CLng / CDbl / CStr / CBool
-->
