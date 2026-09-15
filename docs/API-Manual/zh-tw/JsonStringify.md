# JsonStringify

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: zh-tw -->

將 Basic 值轉成 JSON 文字。

## 完整語法

```text
JsonStringify(value:Any) -> String
JsonStringify(value:Any, indented:Integer) -> String
```

## 參數

- `value` — 數字、String、陣列、List、Dictionary、JsonBoolean 或 JsonNull。Dictionary 的鍵必須是字串。可共用參照，不可循環參照。
- `indented` — Integer 旗標：0 緊湊格式，非0 使用縮排。預設 Stringify=0、Save=1。

## 傳回值

含 JSON 的 String，不建立檔案。

## 行為

- 這些是無 UO. 前綴的本機 Basic 函式，不傳送遊戲封包。JsonParse/JsonStringify 在記憶體內運作。Basic True 儲存為數字1；JSON true 請用 JsonBoolean(True)。JsonNull() 將 null 與0 區分。
- 只接受有限數字。整數值超出 ±9007199254740991 會被拒絕；大型 ID 請存為字串。其他數字使用 Double 精度。嚴格 UTF-8：輸入接受 BOM，輸出不含 BOM。無效 Unicode 會出錯。
- 限制：1048576 個 UTF-16 編碼單元、4MiB 位元組、64 層容器、100000 個值節點。超限會出錯。解析/讀取建立新集合；儲存不複製記憶體物件。
- Save 驗證全部資料、建立父資料夾、在目的檔旁寫入唯一暫存檔、清空緩衝區後移動/取代。取代前失敗或取消會保留舊檔。系統允許時清理暫存檔。已完成的取代不會復原。
- 每256 個值、4096 位元組/字元區塊之間及取代前檢查暫停/停止。不建立額外執行緒；無法強制中斷個別系統呼叫。同時儲存時以最後成功取代為準，不是資料庫交易。

### 內部函式：從呼叫到結果

將 Basic 值轉成 JSON 文字。

#### 1. Stringify

數字、String、陣列、List、Dictionary、JsonBoolean 或 JsonNull。Dictionary 的鍵必須是字串。可共用參照，不可循環參照。 Integer 旗標：0 緊湊格式，非0 使用縮排。預設 Stringify=0、Save=1。

含 JSON 的 String，不建立檔案。

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; 函式 `Stringify`.

Config.Load(fileName, defaults) 回傳新 Dictionary：儲存的頂層鍵覆寫 defaults 的深層副本；巢狀物件整個取代，不遞迴合併。Config.Save(fileName, settings) 明確儲存且無回傳值。Config.GetFlag(settings, key, fallback=False) 回傳1/True 或0/False；既存非布林值會出錯。Config.SetFlag(settings, key, value) 只變更記憶體，無回傳值。Load/Save 需要字串鍵的 Dictionary。內部 Private RequireObject 檢查外層類型；JSON 轉換檢查全部內容。


## 範例

### JsonStringify · 1

```vb
# JsonStringify · 1
#
# 將 Basic 值轉成 JSON 文字。
#
# 含 JSON 的 String，不建立檔案。

Option Explicit On
Sub Main()
    # 執行 Main。value=Dictionary(name="ore",count=3), indented=0 → String {"name":"ore","count":3}.

    Dim d=Dictionary()
    d['name']='ore'
    d['count']=3
    Return JsonStringify(d)
End Sub
```

**參數與執行說明:**

- 執行 Main。value=Dictionary(name="ore",count=3), indented=0 → String {"name":"ore","count":3}.

### JsonStringify · 2

```vb
# JsonStringify · 2
#
# 將 Basic 值轉成 JSON 文字。
#
# 含 JSON 的 String，不建立檔案。

Option Explicit On
Sub Main()
    # 執行 Main。value=d, indented=True=1; JsonParse(text) → independent Dictionary; JsonKind →
    # "boolean:null".

    Dim d=JsonParse('{"enabled":true,"empty":null}')
    Dim text=JsonStringify(value:=d, indented:=True)
    Dim copy=JsonParse(text)
    Return JsonKind(copy['enabled']) & ':' & JsonKind(copy['empty'])
End Sub
```

**參數與執行說明:**

- 執行 Main。value=d, indented=True=1; JsonParse(text) → independent Dictionary; JsonKind → "boolean:null".

### JsonStringify · 3

```vb
# JsonStringify · 3
#
# 將 Basic 值轉成 JSON 文字。
#
# 含 JSON 的 String，不建立檔案。

Option Explicit On
Sub Main()
    # 執行 Main。value=List → value[0]=value → Catch → "cycle".

    Dim d=List()
    d.Add(d)
    Try
    Dim text=JsonStringify(d)
    Catch problem
    Return 'cycle'
    End Try
    Return 'unexpected'
End Sub
```

**參數與執行說明:**

- 執行 Main。value=List → value[0]=value → Catch → "cycle".
