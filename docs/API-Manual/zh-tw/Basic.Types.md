# AS

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: zh-tw -->

AS 設定純量變數的轉換規則。執行時的值種類為 Integer、Decimal、String、Array、Object 和 Unit（沒有值）。Boolean 使用 Integer 1/0。此 Basic 方言有自己的儲存規則；別名不代表 VB.NET 中相同名稱的位元寬度。

## 完整語法

```text
VAR name AS type [= value]
DIM name AS type [= value]
```

## 參數

- `name` — 宣告的變數名稱。讀取時取得目前值；每次後續指定都會再次套用 AS 轉換。
- `type` — Integer、Long、Short、Byte：有號 32 位元整數，範圍 -2147483648…2147483647；Short 和 Byte 不會縮小範圍。Double、Single、Decimal：二進位 64 位元浮點數，內部稱為 Decimal，並非精確十進位運算。String：文字。Boolean、Bool：Integer 1/0。Variant、Object：保留輸入值種類，不要求一定是物件實例。名稱不區分大小寫。
- `value` — 可省略的初始值：數字、文字、變數或函式結果。AS 屬於宣告語法；若需要轉換運算式，使用 CInt(value)、CDbl(value)、CStr(value)、CBool(value)。

## 傳回值

AS 本身不回傳值。讀取變數會取得所儲存的種類和值。邏輯數值結果使用 TRUE=1、FALSE=0。數量 2 非零，但 2=TRUE 為假；判斷是否有物品時，使用 count<>0 或 CBool(count)。

## 行為

- 省略初始值時，有型別的 VAR 對整數/Boolean 產生 0，對 Double/Single/Decimal 產生浮點 0，對 String 產生空文字。無型別 VAR 和 VAR AS Variant/Object 產生 Unit。純量 DIM 會補上初始值：String 為空文字，其他為 0。Unit 經 AS 指定後仍為 Unit。
- AS Integer 將範圍內小數向零截斷。CInt/CLng 則取整，正好一半時遠離零：2.6 變成 3，而 AS Integer 儲存 2。整數文字必須完全是十進位整數或 0x 十六進位數；"2.6" 不符合。轉換前請確認範圍。
- AS Boolean 將原值與數值零比較：非零數字變 1，零變 0。不會辨識單字，連文字 "false" 都變 1。CBool 會先轉成數字。請使用數值/邏輯值，或明確將文字與預期單字比較。
- AS String 使用引擎的文字表示。AS Double/Single/Decimal 以小數點解析數值文字。數值 AS 把 Array 轉成 0，但對 Object 和無效數值文字產生可由 TRY/CATCH 處理的錯誤。CInt/CLng/CDbl/CSng/CBool 則採用寬鬆讀取：無法辨識的文字、Array、Object 或 Unit 先變成 0。依賴文字轉換前，請先檢查 IsNumeric(value)。
- 宣告先計算初始值，再套用 AS，最後儲存結果與型別名稱。後續指定重複轉換。浮點值是近似值，不保證精確的十進位金額運算。作用域請見 VAR / DIM，名稱綁定保護請見 CONST。
- As 也支援已宣告的 Structure 名稱。該型別的 VAR 與 DIM 若無初始設定式，會建立預設欄位。只接受同一宣告型別，不會在不同結構型別間轉換。巢狀值複製與參考欄位詳見 Structure / New。

## 範例

### 1. 指定轉換與取整

```vb
# source=2.6 是浮點數。whole AS Integer 儲存 2；CInt(source) 將 3 存入 rounded。Main 回傳 2*10+3=23，讓兩種轉換可以一起檢查。
Option Explicit On
SUB Main()
    VAR source = 2.6
    VAR whole AS Integer = source
    VAR rounded = CInt(source)
    RETURN whole * 10 + rounded
END SUB
```

**參數與執行說明:**

source=2.6 是浮點數。whole AS Integer 儲存 2；CInt(source) 將 3 存入 rounded。Main 回傳 2*10+3=23，讓兩種轉換可以一起檢查。

### 2. 數量與邏輯值不同

```vb
# count=2 是物品數量。hasItems AS Boolean 變成 1。count=TRUE 為假，因為 TRUE 恰好等於 1；count<>0 為真。Main 回傳 hasItems=1，表示有物品，不表示只有一個。
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

**參數與執行說明:**

count=2 是物品數量。hasItems AS Boolean 變成 1。count=TRUE 為假，因為 TRUE 恰好等於 1；count<>0 為真。Main 回傳 hasItems=1，表示有物品，不表示只有一個。

### 3. Variant 保留值種類

```vb
# value AS Variant 先存 Integer 7，再存 String "ore"。text AS String 一開始為空。CStr(12) 產生文字 "12"；兩段文字相接得到 "ore12"，由 Main 回傳。Variant 允許改變值種類。
Option Explicit On
SUB Main()
    VAR value AS Variant = 7
    value = "ore"
    VAR text AS String
    text = value + CStr(12)
    RETURN text
END SUB
```

**參數與執行說明:**

value AS Variant 先存 Integer 7，再存 String "ore"。text AS String 一開始為空。CStr(12) 產生文字 "12"；兩段文字相接得到 "ore12"，由 Main 回傳。Variant 允許改變值種類。

<!-- implementation references (not callable script procedures):
Runtime/InjectionValueKind.cs
Runtime/SemanticScope.cs: Coerce
Runtime/NumberConversions.cs
Runtime/Interpreter.cs: DefaultValueForType
Runtime/InjectionApi.cs: CInt / CLng / CDbl / CStr / CBool
-->
