# UO.FindVertical

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: zh-tw -->

讀取或設定搜尋時預設允許的高度差。

## 完整語法

```text
UO.FindVertical() -> Integer
UO.FindVertical(value:Any) -> Unit
```

## 參數

- `value` — 選用的 Integer。省略參數時讀取；value 用來設定。儲存範圍為 0..120；負數變成 0，不代表無限。新 runtime 的預設值為 2；還原的狀態可能不同。小數朝零截斷，也接受 decimal/0x 數字字串。建議使用 Integer，避免隱含轉換。

## 傳回值

無參數：Integer，目前的限制（以世界 Z 單位表示的高度差），不是物件 ID、數量或 Boolean。0 代表零範圍，不代表失敗。有 value：Unit，沒有回傳值，也不是 TRUE/FALSE 或舊設定。設定後可呼叫 FindVertical() 讀取儲存值。

## 行為

- 高度為 abs(object.Z - player.Z)，上下兩個方向皆適用且包含邊界。0 只接受相同 Z。這不是樓層編號，也不是水平格數。
- 儲存在目前腳本的 runtime，其程序共用此值；獨立 runtime 各有設定。讀寫不執行搜尋、不清除 FindItem/FindCount/GetFoundItems、不傳送封包、不移動角色，也不載入遠方物件。
- FindTypeEx 與 FindTypesArrayEx 只在地面搜尋套用這些限制，容器內容不受影響。type、hue、Ignore 與已載入物件仍決定結果。FindAtCoord 忽略兩個限制。延伸指令的明確 distance/maxZ 可以覆寫預設值；其中 -1 表示使用預設，與把本設定設為 -1 不同。FindList 在容器搜尋也套用 Z 篩選，不適用上述容器例外。
- 暫時搜尋前儲存原值，在 Finally 還原；設定不會自動回復。Finally 適用正常結束與可攔截的腳本錯誤，緊急停止不能作為清理機制。
- 參考：[Stealth FindVertical](https://stealth.od.ua/api/FindVertical/)。此客戶端保留自己的初始值與範圍：FindDistance 18 / 0..255；FindVertical 2 / 0..120。以上 Basic 語法與延伸篩選描述本專案。

### 內部函式：從呼叫到結果

以下是真正的內部步驟。CountGroundInRange 是完整定義的使用者函式，不是隱藏的內建指令。

#### 1. ExecuteStealthCompatibility

零參數選擇讀取；一個參數轉換 value 後寫入。中繼資料區分 Integer 與 Unit。

無參數：Integer，目前的限制（以世界 Z 單位表示的高度差），不是物件 ID、數量或 Boolean。0 代表零範圍，不代表失敗。有 value：Unit，沒有回傳值，也不是 TRUE/FALSE 或舊設定。設定後可呼叫 FindVertical() 讀取儲存值。

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 函式 `ExecuteStealthCompatibility`.

#### 2. GetFindVertical

Bridge 讀取 runtime 設定，或限制並儲存整數，不掃描世界。

無參數：Integer，目前的限制（以世界 Z 單位表示的高度差），不是物件 ID、數量或 Boolean。0 代表零範圍，不代表失敗。有 value：Unit，沒有回傳值，也不是 TRUE/FALSE 或舊設定。設定後可呼叫 FindVertical() 讀取儲存值。

專案原始碼: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 函式 `GetFindVertical`.

#### 3. SetFindVertical

Bridge 讀取 runtime 設定，或限制並儲存整數，不掃描世界。

選用的 Integer。省略參數時讀取；value 用來設定。儲存範圍為 0..120；負數變成 0，不代表無限。新 runtime 的預設值為 2；還原的狀態可能不同。小數朝零截斷，也接受 decimal/0x 數字字串。建議使用 Integer，避免隱含轉換。

專案原始碼: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 函式 `SetFindVertical`.

#### 4. FindType

後續搜尋未指定覆寫值時讀取設定。地面 Item 與 Mobile 使用對應的距離及高度篩選。

FindTypeEx 與 FindTypesArrayEx 只在地面搜尋套用這些限制，容器內容不受影響。type、hue、Ignore 與已載入物件仍決定結果。FindAtCoord 忽略兩個限制。延伸指令的明確 distance/maxZ 可以覆寫預設值；其中 -1 表示使用預設，與把本設定設為 -1 不同。FindList 在容器搜尋也套用 Z 篩選，不適用上述容器例外。

專案原始碼: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 函式 `FindType`.

#### 5. FindList

後續搜尋未指定覆寫值時讀取設定。地面 Item 與 Mobile 使用對應的距離及高度篩選。

FindTypeEx 與 FindTypesArrayEx 只在地面搜尋套用這些限制，容器內容不受影響。type、hue、Ignore 與已載入物件仍決定結果。FindAtCoord 忽略兩個限制。延伸指令的明確 distance/maxZ 可以覆寫預設值；其中 -1 表示使用預設，與把本設定設為 -1 不同。FindList 在容器搜尋也套用 Z 篩選，不適用上述容器例外。

專案原始碼: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 函式 `FindList`.

儲存在目前腳本的 runtime，其程序共用此值；獨立 runtime 各有設定。讀寫不執行搜尋、不清除 FindItem/FindCount/GetFoundItems、不傳送封包、不移動角色，也不載入遠方物件。


## 範例

### 讀取、設定及觀察範圍限制

```vb
# 讀取、設定及觀察範圍限制
#
# 讀取或設定搜尋時預設允許的高度差。
#
# 無參數：Integer，目前的限制（以世界 Z 單位表示的高度差），不是物件 ID、數量或 Boolean。0 代表零範圍，不代表失敗。有 value：Unit，沒有回傳值，也不是
# TRUE/FALSE 或舊設定。設定後可呼叫 FindVertical() 讀取儲存值。

SUB Main()
    # previous 儲存實際設定。value:=10 設定一般限制；1000 示範被限制為 120。Print 透過另一次讀取輸出結果。Finally 還原 previous。

    VAR previous = UO.FindVertical()
    TRY
        UO.FindVertical(value:=10)
        UO.Print(CStr(UO.FindVertical()))
        UO.FindVertical(1000)
        UO.Print(CStr(UO.FindVertical()))
    FINALLY
        UO.FindVertical(previous)
    END TRY
END SUB
```

**參數與執行說明:**

- previous 儲存實際設定。value:=10 設定一般限制；1000 示範被限制為 120。Print 透過另一次讀取輸出結果。Finally 還原 previous。

### 暫時搜尋地面

```vb
# 暫時搜尋地面
#
# 讀取或設定搜尋時預設允許的高度差。
#
# 無參數：Integer，目前的限制（以世界 Z 單位表示的高度差），不是物件 ID、數量或 Boolean。0 代表零範圍，不代表失敗。有 value：Unit，沒有回傳值，也不是
# TRUE/FALSE 或舊設定。設定後可呼叫 FindVertical() 讀取儲存值。

SUB Main()
    # previous 保留呼叫端設定。10 只改變 FindVertical，另一限制不變。0x0EED 是金幣圖形，-1 為任何色彩，Container=-1 為世界，FALSE
    # 停用容器遞迴。id 是 serial；<> 0 檢查是否找到。FindCount 計算完整物件／堆疊。Finally 還原設定，不還原搜尋清單。

    VAR previous = UO.FindVertical()
    TRY
        UO.FindVertical(10)
        VAR id = UO.FindTypeEx(0x0EED, -1, -1, FALSE)
        IF id <> 0 THEN
            UO.Print(HEX(id) + ':' + CStr(UO.FindCount()))
        ELSE
            UO.Print('0')
        END IF
    FINALLY
        UO.FindVertical(previous)
    END TRY
END SUB
```

**參數與執行說明:**

- previous 保留呼叫端設定。10 只改變 FindVertical，另一限制不變。0x0EED 是金幣圖形，-1 為任何色彩，Container=-1 為世界，FALSE 停用容器遞迴。id 是 serial；<> 0 檢查是否找到。FindCount 計算完整物件／堆疊。Finally 還原設定，不還原搜尋清單。

### 完整 CountGroundInRange 函式

```vb
# 完整 CountGroundInRange 函式
#
# 讀取或設定搜尋時預設允許的高度差。
#
# 無參數：Integer，目前的限制（以世界 Z 單位表示的高度差），不是物件 ID、數量或 Boolean。0 代表零範圍，不代表失敗。有 value：Unit，沒有回傳值，也不是
# TRUE/FALSE 或舊設定。設定後可呼叫 FindVertical() 讀取儲存值。

SUB Main()
    # CountGroundInRange(graphic, radius, height) 儲存兩個限制，套用 radius=5、height=10，搜尋 graphic=0x0EED 並回傳
    # FindCount()。一堆算一個物件。完整函式位於 Main 後面；即使 Return 離開，Finally 仍還原兩個限制。搜尋結果繼續保留。

    VAR count = CountGroundInRange(0x0EED, 5, 10)
    UO.Print(CStr(count))
END SUB

FUNCTION CountGroundInRange(graphic, radius, height)
    VAR oldDistance = UO.FindDistance()
    VAR oldVertical = UO.FindVertical()
    TRY
        UO.FindDistance(radius)
        UO.FindVertical(height)
        UO.FindTypeEx(graphic, -1, -1, FALSE)
        RETURN UO.FindCount()
    FINALLY
        UO.FindDistance(oldDistance)
        UO.FindVertical(oldVertical)
    END TRY
END FUNCTION
```

**參數與執行說明:**

- CountGroundInRange(graphic, radius, height) 儲存兩個限制，套用 radius=5、height=10，搜尋 graphic=0x0EED 並回傳 FindCount()。一堆算一個物件。完整函式位於 Main 後面；即使 Return 離開，Finally 仍還原兩個限制。搜尋結果繼續保留。
