# JsonSave

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: zh-tw -->

將值儲存至 JSON 檔案。

## 完整語法

```text
JsonSave(fileName:String, value:Any) -> Unit
JsonSave(fileName:String, value:Any, indented:Integer) -> Unit
```

## 參數

- `fileName` — 必要的檔案路徑。相對路徑以主腳本資料夾為基準，包括從 Include 呼叫時。也接受絕對路徑。
- `value` — 數字、String、陣列、List、Dictionary、JsonBoolean 或 JsonNull。Dictionary 的鍵必須是字串。可共用參照，不可循環參照。
- `indented` — Integer 旗標：0 緊湊格式，非0 使用縮排。預設 Stringify=0、Save=1。

## 傳回值

Unit：無回傳值。正常完成表示成功；使用 Try/Catch 處理錯誤。

## 行為

- 這些是無 UO. 前綴的本機 Basic 函式，不傳送遊戲封包。JsonParse/JsonStringify 在記憶體內運作。Basic True 儲存為數字1；JSON true 請用 JsonBoolean(True)。JsonNull() 將 null 與0 區分。
- 只接受有限數字。整數值超出 ±9007199254740991 會被拒絕；大型 ID 請存為字串。其他數字使用 Double 精度。嚴格 UTF-8：輸入接受 BOM，輸出不含 BOM。無效 Unicode 會出錯。
- 限制：1048576 個 UTF-16 編碼單元、4MiB 位元組、64 層容器、100000 個值節點。超限會出錯。解析/讀取建立新集合；儲存不複製記憶體物件。
- Save 驗證全部資料、建立父資料夾、在目的檔旁寫入唯一暫存檔、清空緩衝區後移動/取代。取代前失敗或取消會保留舊檔。系統允許時清理暫存檔。已完成的取代不會復原。
- 每256 個值、4096 位元組/字元區塊之間及取代前檢查暫停/停止。不建立額外執行緒；無法強制中斷個別系統呼叫。同時儲存時以最後成功取代為準，不是資料庫交易。

### 內部函式：從呼叫到結果

將值儲存至 JSON 檔案。

#### 1. Save

必要的檔案路徑。相對路徑以主腳本資料夾為基準，包括從 Include 呼叫時。也接受絕對路徑。 數字、String、陣列、List、Dictionary、JsonBoolean 或 JsonNull。Dictionary 的鍵必須是字串。可共用參照，不可循環參照。 Integer 旗標：0 緊湊格式，非0 使用縮排。預設 Stringify=0、Save=1。

Unit：無回傳值。正常完成表示成功；使用 Try/Catch 處理錯誤。

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; 函式 `Save`.

Config.Load(fileName, defaults) 回傳新 Dictionary：儲存的頂層鍵覆寫 defaults 的深層副本；巢狀物件整個取代，不遞迴合併。Config.Save(fileName, settings) 明確儲存且無回傳值。Config.GetFlag(settings, key, fallback=False) 回傳1/True 或0/False；既存非布林值會出錯。Config.SetFlag(settings, key, value) 只變更記憶體，無回傳值。Load/Save 需要字串鍵的 Dictionary。內部 Private RequireObject 檢查外層類型；JSON 轉換檢查全部內容。


## 範例

### JsonSave · 1

```vb
# JsonSave · 1
#
# 將值儲存至 JSON 檔案。
#
# Unit：無回傳值。正常完成表示成功；使用 Try/Catch 處理錯誤。

Option Explicit On
Sub Main()
    # 執行 Main。fileName="json-save-demo.json", value=d, indented=1 → file; JsonLoad →
    # delay=Integer350.

    Dim d=JsonParse('{"delay":350}')
    JsonSave('json-save-demo.json', d)
    Dim loaded=JsonLoad('json-save-demo.json')
    Return loaded['delay']
End Sub
```

**參數與執行說明:**

- 執行 Main。fileName="json-save-demo.json", value=d, indented=1 → file; JsonLoad → delay=Integer350.

### JsonSave · 2

```vb
# JsonSave · 2
#
# 將值儲存至 JSON 檔案。
#
# Unit：無回傳值。正常完成表示成功；使用 Try/Catch 處理錯誤。

Option Explicit On
Sub Main()
    # 執行 Main。fileName="json-save-array.json", value=List, indented=False=0 → compact [true,null,7].

    JsonSave(indented:=False, value:=JsonParse('[true,null,7]'), fileName:='json-save-array.json')
    Return JsonStringify(JsonLoad('json-save-array.json'))
End Sub
```

**參數與執行說明:**

- 執行 Main。fileName="json-save-array.json", value=List, indented=False=0 → compact [true,null,7].

### JsonSave · 3

```vb
# JsonSave · 3
#
# 將值儲存至 JSON 檔案。
#
# Unit：無回傳值。正常完成表示成功；使用 Try/Catch 處理錯誤。

Option Explicit On
Sub Main()
    # 執行 Main。fileName="json-replace-demo.json", value=7; next value=cyclic List → Catch; JsonLoad →
    # original Integer7.

    JsonSave('json-replace-demo.json', 7)
    Dim cycle=List()
    cycle.Add(cycle)
    Try
    JsonSave('json-replace-demo.json', cycle)
    Catch problem
    Return JsonLoad('json-replace-demo.json')
    End Try
    Return 0
End Sub
```

**參數與執行說明:**

- 執行 Main。fileName="json-replace-demo.json", value=7; next value=cyclic List → Catch; JsonLoad → original Integer7.
