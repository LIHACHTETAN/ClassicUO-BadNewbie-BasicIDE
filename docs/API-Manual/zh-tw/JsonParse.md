# JsonParse

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: zh-tw -->

將 JSON 文字解析為 Basic 值。

## 完整語法

```text
JsonParse(text:String) -> Any
```

## 參數

- `text` — 必要的 JSON 字串，僅含一個完整值。物件鍵區分大小寫且不可重複；註解和尾端逗號會產生錯誤。

## 傳回值

Any：物件→Dictionary、陣列→List、文字→String、數字→Integer 或 Decimal(Double)、true/false→JsonBoolean、null→JsonNull。不是成功旗標。

## 行為

- 這些是無 UO. 前綴的本機 Basic 函式，不傳送遊戲封包。JsonParse/JsonStringify 在記憶體內運作。Basic True 儲存為數字1；JSON true 請用 JsonBoolean(True)。JsonNull() 將 null 與0 區分。
- 只接受有限數字。整數值超出 ±9007199254740991 會被拒絕；大型 ID 請存為字串。其他數字使用 Double 精度。嚴格 UTF-8：輸入接受 BOM，輸出不含 BOM。無效 Unicode 會出錯。
- 限制：1048576 個 UTF-16 編碼單元、4MiB 位元組、64 層容器、100000 個值節點。超限會出錯。解析/讀取建立新集合；儲存不複製記憶體物件。
- Save 驗證全部資料、建立父資料夾、在目的檔旁寫入唯一暫存檔、清空緩衝區後移動/取代。取代前失敗或取消會保留舊檔。系統允許時清理暫存檔。已完成的取代不會復原。
- 每256 個值、4096 位元組/字元區塊之間及取代前檢查暫停/停止。不建立額外執行緒；無法強制中斷個別系統呼叫。同時儲存時以最後成功取代為準，不是資料庫交易。

### 內部函式：從呼叫到結果

將 JSON 文字解析為 Basic 值。

#### 1. Parse

必要的 JSON 字串，僅含一個完整值。物件鍵區分大小寫且不可重複；註解和尾端逗號會產生錯誤。

Any：物件→Dictionary、陣列→List、文字→String、數字→Integer 或 Decimal(Double)、true/false→JsonBoolean、null→JsonNull。不是成功旗標。

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; 函式 `Parse`.

Config.Load(fileName, defaults) 回傳新 Dictionary：儲存的頂層鍵覆寫 defaults 的深層副本；巢狀物件整個取代，不遞迴合併。Config.Save(fileName, settings) 明確儲存且無回傳值。Config.GetFlag(settings, key, fallback=False) 回傳1/True 或0/False；既存非布林值會出錯。Config.SetFlag(settings, key, value) 只變更記憶體，無回傳值。Load/Save 需要字串鍵的 Dictionary。內部 Private RequireObject 檢查外層類型；JSON 轉換檢查全部內容。


## 範例

### JsonParse · 1

```vb
# JsonParse · 1
#
# 將 JSON 文字解析為 Basic 值。
#
# Any：物件→Dictionary、陣列→List、文字→String、數字→Integer 或
# Decimal(Double)、true/false→JsonBoolean、null→JsonNull。不是成功旗標。

Option Explicit On
Sub Main()
    # 執行 Main。text={"delay":350} → Dictionary; d["delay"] → Integer350.

    Dim d=JsonParse('{"delay":350}')
    Return d['delay']
End Sub
```

**參數與執行說明:**

- 執行 Main。text={"delay":350} → Dictionary; d["delay"] → Integer350.

### JsonParse · 2

```vb
# JsonParse · 2
#
# 將 JSON 文字解析為 Basic 值。
#
# Any：物件→Dictionary、陣列→List、文字→String、數字→Integer 或
# Decimal(Double)、true/false→JsonBoolean、null→JsonNull。不是成功旗標。

Option Explicit On
Sub Main()
    # 執行 Main。text=[true,null,12] → List; index0 → JsonBoolean.Value()=1; index1 → null; index2 →
    # Integer12.

    Dim a=JsonParse('[true,null,12]')
    Dim flag=a[0]
    Return CStr(flag.Value()) & ':' & JsonKind(a[1]) & ':' & CStr(a[2])
End Sub
```

**參數與執行說明:**

- 執行 Main。text=[true,null,12] → List; index0 → JsonBoolean.Value()=1; index1 → null; index2 → Integer12.

### JsonParse · 3

```vb
# JsonParse · 3
#
# 將 JSON 文字解析為 Basic 值。
#
# Any：物件→Dictionary、陣列→List、文字→String、數字→Integer 或
# Decimal(Double)、true/false→JsonBoolean、null→JsonNull。不是成功旗標。

Option Explicit On
Sub Main()
    # 執行 Main。text={"x":1,"x":2} → Catch → "duplicate key".

    Try
    Dim bad=JsonParse('{"x":1,"x":2}')
    Catch problem
    Return 'duplicate key'
    End Try
    Return 'unexpected'
End Sub
```

**參數與執行說明:**

- 執行 Main。text={"x":1,"x":2} → Catch → "duplicate key".
