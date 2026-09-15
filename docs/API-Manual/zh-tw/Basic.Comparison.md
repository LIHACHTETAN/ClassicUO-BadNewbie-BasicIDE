# =, ==, <>, <, >, <=, >=

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: zh-tw -->

比較運算子檢查兩個值並產生邏輯結果，可用於 IF、存入變數或由輔助函式 RETURN 傳回。

## 完整語法

```text
left = right
left == right
left <> right
left < right
left > right
left <= right
left >= right
```

## 參數

- `left` — 左值：常值、已宣告變數、運算式或函式結果。
- `right` — 右值。大小比較需要 Integer 或 Decimal；相等比較也支援其他值種類。
- `operator` — 運算式中的 = 與 == 檢查相等，<> 檢查不相等，< 與 > 為嚴格大小比較，<= 與 >= 包含相等。獨立的 name = expression 陳述式則是指定值。

## 傳回值

比較成立時為 Integer 1（TRUE），否則為 Integer 0（FALSE）。對此結果，result=1 等同 result=TRUE，result=0 等同 result=FALSE。數量或 ID 意義不同：2 非零，但 2=TRUE 為假。請以 count<>0 檢查數量是否非零。

## 行為

- Integer 與 Decimal 依數值跨種類比較：5=5.0 為真。文字不會自動轉換："5"=5 為假。字串使用區分大小寫的序位比較："Ore"<>"ore"。以 <、>、<=、>= 比較文字、陣列、物件或 Unit 的大小會發生錯誤。
- 陣列和原生物件的相等比較檢查是否同一參考，不比較內容。兩個 Unit 相等，但 Unit 不是數值零。不同種類不相等，Integer/Decimal 數值配對例外。NaN 甚至不等於自身；所有含 NaN 的數值大小比較都為假。
- 算術先於比較計算。連續比較由左至右：1<3<2 是 (1<3)<2，結果為真。要測試範圍，請寫 (low<=value) AND (value<=high)。括號明確標示分組。
- 二進位浮點計算可能捨入。近似測量請用 Abs(actual-expected)<=tolerance，並提供合適的非負容差。容差由腳本指定，運算子不會自動套用。
- = 比較同一宣告型別及其對應欄位，<> 為相反結果；參考欄位按身分比較。這是引擎擴充，並非所有 VB.NET 結構都支援 =。快取雜湊及已比較配對可避免重複展開共用的巢狀值。

## 範例

### 1. 包含邊界的範圍與 TRUE

```vb
# InRange 接收 value=4、low=2、high=5。兩項比較都得到 1，AND 合併為 1，Main 檢查 accepted=TRUE 並傳回 1。輔助函式與呼叫程式均完整列出。
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

**參數與執行說明:**

InRange 接收 value=4、low=2、high=5。兩項比較都得到 1，AND 合併為 1，Main 檢查 accepted=TRUE 並傳回 1。輔助函式與呼叫程式均完整列出。

### 2. 文字、數值與大小寫

```vb
# sameCase 比較 "Ore" 和 "ore"，得到 0。sameKind 比較 "5" 和 Integer 5，得到 0。converted 明確使用 CDbl("5")，得到 1。CStr 組成傳回的診斷字串 "0:0:1"。
Option Explicit On
SUB Main()
    VAR sameCase = ("Ore" = "ore")
    VAR sameKind = ("5" == 5)
    VAR converted = (CDbl("5") = 5)
    RETURN CStr(sameCase) + ":" + CStr(sameKind) + ":" + CStr(converted)
END SUB
```

**參數與執行說明:**

sameCase 比較 "Ore" 和 "ore"，得到 0。sameKind 比較 "5" 和 Integer 5，得到 0。converted 明確使用 CDbl("5")，得到 1。CStr 組成傳回的診斷字串 "0:0:1"。

### 3. 小數的近似相等

```vb
# NearlyEqual 接收 0.1+0.2、expected=0.3、tolerance=0.000001。負容差會被拒絕。Abs 計算差值大小；<= 接受容差範圍內的偏差。Main 傳回 1。輔助函式所有參數都明確提供。
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

**參數與執行說明:**

NearlyEqual 接收 0.1+0.2、expected=0.3、tolerance=0.000001。負容差會被拒絕。Abs 計算差值大小；<= 接受容差範圍內的偏差。Main 傳回 1。輔助函式所有參數都明確提供。

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: logicalOperand / comparativeOperation
Runtime/Interpreter.cs: VisitLogicalOperand
Runtime/InjectionValue.cs: Equals / comparison operators
-->
