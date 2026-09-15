# UO.FindAtCoord

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: zh-tw -->

尋找目前地圖上精確 X/Y 格子內已載入的世界物件。

## 完整語法

```text
UO.FindAtCoord(X:Any, Y:Any) -> Integer
```

## 參數

- `X` — 世界水平座標，Integer 0..65535，必填；不是容器視窗中的像素位置。
- `Y` — 世界垂直座標，Integer 0..65535，必填。沒有額外的 Z、地圖、類型或半徑參數。

## 傳回值

Integer：此客戶端結果清單中第一個符合物件的 serial。找不到、角色不存在或已移除、座標超出 0..65535 時回傳 0。這是物件 ID，不是類型、數量或 Boolean。保留完整 32 位元；請以 <> 0 檢查，不要用 = TRUE 或 > 0。相同 ID 會成為 FindItem()。

## 行為

- 檢查未移除的地面 Item 與 Mobile，也包含位於該格的玩家。排除容器內容及已裝備物品：它們儲存的 X/Y 不能當作世界座標。Ignore 清單中的 serial 也會被排除。
- 精確 X/Y 上所有 Z 高度都符合。FindDistance 和 FindVertical 不限制此查詢。只讀取目前世界已載入的物件，不載入地形、靜態圖塊或其他地圖。不送出封包、不開啟目標游標、不移動物品。
- 每次呼叫先清除上次搜尋。FindCount() 計算物件數，FindFullQuantity() 加總堆疊單位數（Mobile 加一），GetFoundItems() 提供符合的 serial。先查 Item，再查 Mobile；各集合使用目前列舉順序。下次搜尋會取代結果，請先儲存清單。
- 參考：[Stealth FindAtCoord](https://stealth.od.ua/api/FindAtCoord/)。上述順序與篩選規則說明的是此客戶端的實作。

### 內部函式：從呼叫到結果

以下是實際內部步驟。CountGraphicAt 是完整定義的腳本輔助函式，不是額外內建指令。

#### 1. ExecuteStealthCompatibility

已註冊的執行路徑轉換兩個位置或具名 X/Y 引數，將橋接層的 Integer 作為結果。

Integer：此客戶端結果清單中第一個符合物件的 serial。找不到、角色不存在或已移除、座標超出 0..65535 時回傳 0。這是物件 ID，不是類型、數量或 Boolean。保留完整 32 位元；請以 <> 0 檢查，不要用 = TRUE 或 > 0。相同 ID 會成為 FindItem()。

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 函式 `ExecuteStealthCompatibility`.

#### 2. FindAtCoord

在遊戲執行緒清除舊結果、檢查角色及座標範圍，再巡覽符合 X/Y 的地面 Item 和 Mobile。容器內容不會符合。

檢查未移除的地面 Item 與 Mobile，也包含位於該格的玩家。排除容器內容及已裝備物品：它們儲存的 X/Y 不能當作世界座標。Ignore 清單中的 serial 也會被排除。

專案原始碼: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 函式 `FindAtCoord`.

#### 3. RegisterFound

每個符合物件增加計數並加入 serial。第一個 serial 保留為 FindItem；Item.Amount 至少加一個單位，Mobile 加一。

每次呼叫先清除上次搜尋。FindCount() 計算物件數，FindFullQuantity() 加總堆疊單位數（Mobile 加一），GetFoundItems() 提供符合的 serial。先查 Item，再查 Mobile；各集合使用目前列舉順序。下次搜尋會取代結果，請先儲存清單。

專案原始碼: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 函式 `RegisterFound`.

精確 X/Y 上所有 Z 高度都符合。FindDistance 和 FindVertical 不限制此查詢。只讀取目前世界已載入的物件，不載入地形、靜態圖塊或其他地圖。不送出封包、不開啟目標游標、不移動物品。


## 範例

### 讀取一個物件 ID

```vb
# 讀取一個物件 ID
#
# 尋找目前地圖上精確 X/Y 格子內已載入的世界物件。
#
# Integer：此客戶端結果清單中第一個符合物件的 serial。找不到、角色不存在或已移除、座標超出 0..65535 時回傳 0。這是物件 ID，不是類型、數量或
# Boolean。保留完整 32 位元；請以 <> 0 檢查，不要用 = TRUE 或 > 0。相同 ID 會成為 FindItem()。

SUB Main()
    # 1445、1690 是世界 X/Y 範例，請換成所需格子。id 儲存 serial，HEX 將其格式化。<> 0 檢查是否找到物件，不是數量。

    VAR id = UO.FindAtCoord(1445, 1690)
    IF id <> 0 THEN
        UO.Print(HEX(id))
    ELSE
        UO.Print('No loaded object')
    END IF
END SUB
```

**參數與執行說明:**

- 1445、1690 是世界 X/Y 範例，請換成所需格子。id 儲存 serial，HEX 將其格式化。<> 0 檢查是否找到物件，不是數量。

### 查看角色格子內的全部物件

```vb
# 查看角色格子內的全部物件
#
# 尋找目前地圖上精確 X/Y 格子內已載入的世界物件。
#
# Integer：此客戶端結果清單中第一個符合物件的 serial。找不到、角色不存在或已移除、座標超出 0..65535 時回傳 0。這是物件 ID，不是類型、數量或
# Boolean。保留完整 32 位元；請以 <> 0 檢查，不要用 = TRUE 或 > 0。相同 ID 會成為 FindItem()。

SUB Main()
    # x/y 取自角色，ids 儲存搜尋清單。每個 id 代表一個物件，也包括整個堆疊。GetType(id) 讀取 graphic/body。不選取或使用物品。

    VAR x = UO.GetX('self')
    VAR y = UO.GetY('self')
    UO.FindAtCoord(x, y)
    VAR ids = UO.GetFoundItems()
    FOR EACH id IN ids
        UO.Print(HEX(id) + ' type=' + HEX(UO.GetType(id)))
    NEXT
END SUB
```

**參數與執行說明:**

- x/y 取自角色，ids 儲存搜尋清單。每個 id 代表一個物件，也包括整個堆疊。GetType(id) 讀取 graphic/body。不選取或使用物品。

### 完整 CountGraphicAt 輔助函式

```vb
# 完整 CountGraphicAt 輔助函式
#
# 尋找目前地圖上精確 X/Y 格子內已載入的世界物件。
#
# Integer：此客戶端結果清單中第一個符合物件的 serial。找不到、角色不存在或已移除、座標超出 0..65535 時回傳 0。這是物件 ID，不是類型、數量或
# Boolean。保留完整 32 位元；請以 <> 0 檢查，不要用 = TRUE 或 > 0。相同 ID 會成為 FindItem()。

SUB Main()
    # CountGraphicAt(x, y, graphic) 搜尋一次，巡覽儲存的 ID，計算圖形相符的物件。graphic=0x0EED 代表金幣。回傳物件/堆疊數，不是單位總數或
    # true/false；一個堆疊計一。Main 後方提供完整函式。

    VAR count = CountGraphicAt(1445, 1690, 0x0EED)
    UO.Print('Objects/stacks: ' + CStr(count))
END SUB

FUNCTION CountGraphicAt(x, y, graphic)
    UO.FindAtCoord(x, y)
    VAR ids = UO.GetFoundItems()
    VAR count = 0
    FOR EACH id IN ids
        IF UO.GetType(id) = graphic THEN
            count += 1
        END IF
    NEXT
    RETURN count
END FUNCTION
```

**參數與執行說明:**

- CountGraphicAt(x, y, graphic) 搜尋一次，巡覽儲存的 ID，計算圖形相符的物件。graphic=0x0EED 代表金幣。回傳物件/堆疊數，不是單位總數或 true/false；一個堆疊計一。Main 後方提供完整函式。
