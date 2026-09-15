# =, ==, <>, <, >, <=, >=

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ja -->

比較演算子は2つの値を調べ、IF、変数への代入、補助関数の RETURN に使える論理結果を生成します。

## 正確な構文

```text
left = right
left == right
left <> right
left < right
left > right
left <= right
left >= right
```

## パラメーター

- `left` — 左の値。リテラル、宣言済み変数、式、関数の結果を指定します。
- `right` — 右の値。大小比較には Integer または Decimal が必要です。等値比較は他の値の種類にも対応します。
- `operator` — 式の = と == は等しい、<> は等しくない、< と > は厳密な大小、<= と >= は等号を含む大小を調べます。単独の name = expression 文は代入です。

## 戻り値

比較が成立すると Integer 1（TRUE）、それ以外は Integer 0（FALSE）。この結果では result=1 と result=TRUE、result=0 と result=FALSE は同じです。個数や ID は意味が異なります。2 は非ゼロでも 2=TRUE は偽です。非ゼロの個数は count<>0 で調べます。

## 動作

- Integer と Decimal は数値として比較され、5=5.0 は真です。文字列は変換されず、"5"=5 は偽です。文字列の等値比較は序数比較で大文字小文字を区別します。"Ore"<>"ore" は真です。文字列、配列、オブジェクト、Unit の <、>、<=、>= はエラーです。
- 配列とネイティブオブジェクトの等値比較は内容ではなく参照の同一性を調べます。Unit 同士は等しいものの、Unit は数値ゼロとは異なります。異なる種類は Integer/Decimal の数値ペア以外では不等です。NaN は自身とも等しくなく、NaN を含む数値の大小比較はすべて偽です。
- 算術を先に計算し、比較の連鎖は左から右に評価します。1<3<2 は (1<3)<2 で真です。範囲は (low<=value) AND (value<=high) と書き、括弧でグループを明示します。
- 二進浮動小数点には丸めがあります。近似測定値は適切な非負の許容差で Abs(actual-expected)<=tolerance と比較します。許容差はスクリプトの規則であり、演算子に自動適用されません。
- = は同じ宣言型と対応するフィールドを比較し、<> は逆の結果です。参照フィールドは同一性を比較します。これはエンジン独自の拡張であり、VB.NET の任意の構造が = を使えるという意味ではありません。保存済みハッシュと検査済みペアにより、共有された入れ子の反復展開を防ぎます。

## 使用例

### 1. 境界を含む範囲と TRUE

```vb
# InRange は value=4、low=2、high=5 を受け取ります。両比較は1で、AND の結果も1です。Main は accepted=TRUE を調べ1を返します。補助関数と呼び出し側を全文掲載しています。
Option Explicit On
FUNCTION InRange(value, low, high)
    RETURN (low <= value) AND (value <= high)
END FUNCTION
SUB Main()
    VAR accepted = InRange(4, 2, 5)
    IF accepted = TRUE THEN
        RETURN 1
    END IF
    RETURN 0
END SUB
```

**パラメーターと実行の説明:**

InRange は value=4、low=2、high=5 を受け取ります。両比較は1で、AND の結果も1です。Main は accepted=TRUE を調べ1を返します。補助関数と呼び出し側を全文掲載しています。

### 2. 文字列、数値、大文字小文字

```vb
# sameCase は "Ore" と "ore" を比較して0です。sameKind は "5" と Integer 5 を比較して0です。converted は明示的に CDbl("5") を使い1です。CStr で診断文字列 "0:0:1" を返します。
Option Explicit On
SUB Main()
    VAR sameCase = ("Ore" = "ore")
    VAR sameKind = ("5" == 5)
    VAR converted = (CDbl("5") = 5)
    RETURN CStr(sameCase) + ":" + CStr(sameKind) + ":" + CStr(converted)
END SUB
```

**パラメーターと実行の説明:**

sameCase は "Ore" と "ore" を比較して0です。sameKind は "5" と Integer 5 を比較して0です。converted は明示的に CDbl("5") を使い1です。CStr で診断文字列 "0:0:1" を返します。

### 3. 小数の近似等値

```vb
# NearlyEqual は 0.1+0.2、expected=0.3、tolerance=0.000001 を受け取ります。負の許容差は拒否します。Abs は差の大きさを求め、<= は許容差以内を受け入れます。Main は1を返します。すべての補助関数引数を明示しています。
Option Explicit On
FUNCTION NearlyEqual(actual, expected, tolerance)
    IF tolerance < 0 THEN
        RETURN FALSE
    END IF
    RETURN Abs(actual - expected) <= tolerance
END FUNCTION
SUB Main()
    RETURN NearlyEqual(0.1 + 0.2, 0.3, 0.000001)
END SUB
```

**パラメーターと実行の説明:**

NearlyEqual は 0.1+0.2、expected=0.3、tolerance=0.000001 を受け取ります。負の許容差は拒否します。Abs は差の大きさを求め、<= は許容差以内を受け入れます。Main は1を返します。すべての補助関数引数を明示しています。

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: logicalOperand / comparativeOperation
Runtime/Interpreter.cs: VisitLogicalOperand
Runtime/InjectionValue.cs: Equals / comparison operators
-->
