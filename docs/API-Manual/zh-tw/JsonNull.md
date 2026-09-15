# JsonNull

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: zh-tw -->

建立明確的 JSON null 值。

## 完整語法

```text
JsonNull() -> Object
```

## 參數

沒有參數。

## 傳回值

JsonNull 物件，序列化為 null，不等於0 或空字串。檢查方式：JsonKind(value)="null"。

## 行為

- 這些是無 UO. 前綴的本機 Basic 函式，不傳送遊戲封包。JsonParse/JsonStringify 在記憶體內運作。Basic True 儲存為數字1；JSON true 請用 JsonBoolean(True)。JsonNull() 將 null 與0 區分。
- 只接受有限數字。整數值超出 ±9007199254740991 會被拒絕；大型 ID 請存為字串。其他數字使用 Double 精度。嚴格 UTF-8：輸入接受 BOM，輸出不含 BOM。無效 Unicode 會出錯。
- 限制：1048576 個 UTF-16 編碼單元、4MiB 位元組、64 層容器、100000 個值節點。超限會出錯。解析/讀取建立新集合；儲存不複製記憶體物件。
- Save 驗證全部資料、建立父資料夾、在目的檔旁寫入唯一暫存檔、清空緩衝區後移動/取代。取代前失敗或取消會保留舊檔。系統允許時清理暫存檔。已完成的取代不會復原。
- 每256 個值、4096 位元組/字元區塊之間及取代前檢查暫停/停止。不建立額外執行緒；無法強制中斷個別系統呼叫。同時儲存時以最後成功取代為準，不是資料庫交易。

### 內部函式：從呼叫到結果

建立明確的 JSON null 值。

#### 1. JsonNullObject



JsonNull 物件，序列化為 null，不等於0 或空字串。檢查方式：JsonKind(value)="null"。

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/JsonPrimitiveObjects.cs`; 函式 `JsonNullObject`.

Config.Load(fileName, defaults) 回傳新 Dictionary：儲存的頂層鍵覆寫 defaults 的深層副本；巢狀物件整個取代，不遞迴合併。Config.Save(fileName, settings) 明確儲存且無回傳值。Config.GetFlag(settings, key, fallback=False) 回傳1/True 或0/False；既存非布林值會出錯。Config.SetFlag(settings, key, value) 只變更記憶體，無回傳值。Load/Save 需要字串鍵的 Dictionary。內部 Private RequireObject 檢查外層類型；JSON 轉換檢查全部內容。


## 範例

### JsonNull · 1

```vb
# JsonNull · 1
#
# 建立明確的 JSON null 值。
#
# JsonNull 物件，序列化為 null，不等於0 或空字串。檢查方式：JsonKind(value)="null"。

Option Explicit On
Sub Main()
    # 執行 Main。JsonNull() → Object; JsonStringify → String "null".

    Return JsonStringify(JsonNull())
End Sub
```

**參數與執行說明:**

- 執行 Main。JsonNull() → Object; JsonStringify → String "null".

### JsonNull · 2

```vb
# JsonNull · 2
#
# 建立明確的 JSON null 值。
#
# JsonNull 物件，序列化為 null，不等於0 或空字串。檢查方式：JsonKind(value)="null"。

Option Explicit On
Sub Main()
    # 執行 Main。JsonNull() → d["selected"]; JsonKind comparison → Integer1/True.

    Dim d=Dictionary()
    d['selected']=JsonNull()
    Return JsonKind(d['selected'])='null'
End Sub
```

**參數與執行說明:**

- 執行 Main。JsonNull() → d["selected"]; JsonKind comparison → Integer1/True.

### JsonNull · 3

```vb
# JsonNull · 3
#
# 建立明確的 JSON null 值。
#
# JsonNull 物件，序列化為 null，不等於0 或空字串。檢查方式：JsonKind(value)="null"。

Option Explicit On
Sub Main()
    # 執行 Main。JsonNull(),0,"" → three distinct values → String [null,0,""] .

    Dim a=List()
    a.Add(JsonNull())
    a.Add(0)
    a.Add('')
    Return JsonStringify(a)
End Sub
```

**參數與執行說明:**

- 執行 Main。JsonNull(),0,"" → three distinct values → String [null,0,""] .
