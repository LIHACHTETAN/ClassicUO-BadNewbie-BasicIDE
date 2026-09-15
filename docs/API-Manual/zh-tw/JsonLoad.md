# JsonLoad

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: zh-tw -->

讀取 JSON 檔案。

## 完整語法

```text
JsonLoad(fileName:String) -> Any
JsonLoad(fileName:String, defaultValue:Any) -> Any
```

## 參數

- `fileName` — 必要的檔案路徑。相對路徑以主腳本資料夾為基準，包括從 Include 呼叫時。也接受絕對路徑。
- `defaultValue` — 可選的備用值，僅在檔案或資料夾不存在時使用。經 JSON 轉換取得獨立副本；內容、編碼或存取錯誤不會被隱藏。

## 傳回值

Any，類型映射同 JsonParse。檔案不存在且未提供 defaultValue 時出錯。

## 行為

- 這些是無 UO. 前綴的本機 Basic 函式，不傳送遊戲封包。JsonParse/JsonStringify 在記憶體內運作。Basic True 儲存為數字1；JSON true 請用 JsonBoolean(True)。JsonNull() 將 null 與0 區分。
- 只接受有限數字。整數值超出 ±9007199254740991 會被拒絕；大型 ID 請存為字串。其他數字使用 Double 精度。嚴格 UTF-8：輸入接受 BOM，輸出不含 BOM。無效 Unicode 會出錯。
- 限制：1048576 個 UTF-16 編碼單元、4MiB 位元組、64 層容器、100000 個值節點。超限會出錯。解析/讀取建立新集合；儲存不複製記憶體物件。
- Save 驗證全部資料、建立父資料夾、在目的檔旁寫入唯一暫存檔、清空緩衝區後移動/取代。取代前失敗或取消會保留舊檔。系統允許時清理暫存檔。已完成的取代不會復原。
- 每256 個值、4096 位元組/字元區塊之間及取代前檢查暫停/停止。不建立額外執行緒；無法強制中斷個別系統呼叫。同時儲存時以最後成功取代為準，不是資料庫交易。

### 內部函式：從呼叫到結果

讀取 JSON 檔案。

#### 1. LoadCore

必要的檔案路徑。相對路徑以主腳本資料夾為基準，包括從 Include 呼叫時。也接受絕對路徑。 可選的備用值，僅在檔案或資料夾不存在時使用。經 JSON 轉換取得獨立副本；內容、編碼或存取錯誤不會被隱藏。

Any，類型映射同 JsonParse。檔案不存在且未提供 defaultValue 時出錯。

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; 函式 `LoadCore`.

Config.Load(fileName, defaults) 回傳新 Dictionary：儲存的頂層鍵覆寫 defaults 的深層副本；巢狀物件整個取代，不遞迴合併。Config.Save(fileName, settings) 明確儲存且無回傳值。Config.GetFlag(settings, key, fallback=False) 回傳1/True 或0/False；既存非布林值會出錯。Config.SetFlag(settings, key, value) 只變更記憶體，無回傳值。Load/Save 需要字串鍵的 Dictionary。內部 Private RequireObject 檢查外層類型；JSON 轉換檢查全部內容。


## 範例

### JsonLoad · 1

```vb
# JsonLoad · 1
#
# 讀取 JSON 檔案。
#
# Any，類型映射同 JsonParse。檔案不存在且未提供 defaultValue 時出錯。

Option Explicit On
Sub Main()
    # 執行 Main。fileName="json-demo.json"; JsonSave → file; JsonLoad → Dictionary; delay → Integer350.

    JsonSave('json-demo.json', JsonParse('{"delay":350}'))
    Dim d=JsonLoad('json-demo.json')
    Return d['delay']
End Sub
```

**參數與執行說明:**

- 執行 Main。fileName="json-demo.json"; JsonSave → file; JsonLoad → Dictionary; delay → Integer350.

### JsonLoad · 2

```vb
# JsonLoad · 2
#
# 讀取 JSON 檔案。
#
# Any，類型映射同 JsonParse。檔案不存在且未提供 defaultValue 時出錯。

Option Explicit On
Sub Main()
    # 執行 Main。fileName="missing-json-demo.json", defaultValue=defaults; missing file → independent
    # copy → "125:350".

    Dim defaults=Dictionary()
    defaults['delay']=350
    Dim loaded=JsonLoad('missing-json-demo.json', defaults)
    loaded['delay']=125
    Return CStr(loaded['delay']) & ':' & CStr(defaults['delay'])
End Sub
```

**參數與執行說明:**

- 執行 Main。fileName="missing-json-demo.json", defaultValue=defaults; missing file → independent copy → "125:350".

### JsonLoad · 3

```vb
# JsonLoad · 3
#
# 讀取 JSON 檔案。
#
# Any，類型映射同 JsonParse。檔案不存在且未提供 defaultValue 時出錯。

Option Explicit On
Sub Main()
    # 執行 Main。fileName="json-demo-list.json", defaultValue=List(); existing file [1,2,3] →
    # List.Count() → Integer3.

    JsonSave('json-demo-list.json', JsonParse('[1,2,3]'))
    Dim data=JsonLoad(fileName:='json-demo-list.json', defaultValue:=List())
    Return data.Count()
End Sub
```

**參數與執行說明:**

- 執行 Main。fileName="json-demo-list.json", defaultValue=List(); existing file [1,2,3] → List.Count() → Integer3.
