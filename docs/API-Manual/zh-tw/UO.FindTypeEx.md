# UO.FindTypeEx

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: zh-tw -->

在容器或地面搜尋指定圖形及色調，傳回一個符合條件的 ID。

## 完整語法

```text
UO.FindTypeEx(ObjType:Any, Color:Any, Container:Any, InSub:Any) -> Integer
```

## 參數

- `ObjType` — Graphic/body，不是物件 serial。0..65534 指定圖形；-1 或 0xFFFF 表示任何圖形。其他負 Integer 也會取消此篩選。
- `Color` — Hue，不是數量。0 表示未染色；-1 或 0xFFFF 接受任何色調。其他負 Integer 也會取消色調篩選。
- `Container` — 地面：UO.Ground()、0、-1、0xFFFFFFFF 或字串 ground。背包：字串 backpack 或背包 serial。接受十進位／hex serial 及 AddObject 名稱。my 選擇角色擁有的全部物品，包括裝備和巢狀袋子。未知名稱會產生腳本錯誤。傳入解析出的 serial 前請檢查：明確的 0 會選擇地面。不同 API 的數值慣例不同，建議使用 ground/backpack 名稱。
- `InSub` — 必要的 TRUE/FALSE（1/0）。FALSE 只搜尋指定容器的直接內容；TRUE 也搜尋已載入的巢狀袋子。對地面沒有影響。my 原本就包含角色擁有的全部物品。

## 傳回值

Integer：本機走訪順序中的第一個符合 serial，沒有符合項時為 0。不是圖形、數量、陣列或 Boolean。使用 result <> 0，不要用 result = TRUE 或 result = 1。每疊物品算一個物件；Mobile 算一個物件及一個單位。順序不表示距離最近，也不保證每次固定。

## 行為

- 四個位置參數全部必要，不能省略。
- 地面使用此腳本的 FindDistance/FindVertical，排除 self，包含符合的 Item 和 Mobile。指定容器不套用這些距離／高度限制。兩種範圍都排除 Ignore 清單及已銷毀物件。
- 走訪前清空 FindItem、FindCount、FindFullQuantity 和 GetFoundItems。搜尋無結果時保留零值及空陣列。FindFullQuantity 對 Item 加總 max(1, Amount)，每個 Mobile 加 1。FindQuantity 讀取 FindItem 目前的數量。後續搜尋會取代結果，需要舊清單時先儲存 GetFoundItems。
- Bridge 走訪已載入的 Item 一次；選擇地面時再走訪 Mobile。類型、色調和至少一個容器都必須符合。每個物件只登記一次，不會為每個組合重新掃描整個世界。
- 只讀取客戶端已收到的資料，不開啟容器、不載入地圖格、不搬物品。空結果不能證明伺服器上的箱子是空的。需要有效連線時檢查 Connected；搜尋本身讀取本機狀態。
- [Stealth FindTypeEx](https://stealth.od.ua/api/FindTypeEx/). 參考文件描述最後一個 ID，以及無效容器時改用背包。本客戶端保留第一個本機結果，未知名稱不改用背包。Ground 也接受 0；本機 FindDistance 預設 18、最大 255。

### 內部函式：從呼叫到結果

以下為實際實作步驟，不是額外公開指令。FindGoldNearSelf 和 SearchTypesIn 是下方完整定義的腳本函式。

#### 1. ExecuteStealthCompatibility

Runtime 轉換數值篩選並個別解析容器名稱；地面選擇值轉成 bridge 的內部世界範圍。

四個位置參數全部必要，不能省略。

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 函式 `ExecuteStealthCompatibility`.

#### 2. ConvertStealthSearchContainer

地面：UO.Ground()、0、-1、0xFFFFFFFF 或字串 ground。背包：字串 backpack 或背包 serial。接受十進位／hex serial 及 AddObject 名稱。my 選擇角色擁有的全部物品，包括裝備和巢狀袋子。未知名稱會產生腳本錯誤。傳入解析出的 serial 前請檢查：明確的 0 會選擇地面。不同 API 的數值慣例不同，建議使用 ground/backpack 名稱。

Runtime 轉換數值篩選並個別解析容器名稱；地面選擇值轉成 bridge 的內部世界範圍。

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 函式 `ConvertStealthSearchContainer`.

#### 3. ResetFindResults

走訪前清空 FindItem、FindCount、FindFullQuantity 和 GetFoundItems。搜尋無結果時保留零值及空陣列。FindFullQuantity 對 Item 加總 max(1, Amount)，每個 Mobile 加 1。FindQuantity 讀取 FindItem 目前的數量。後續搜尋會取代結果，需要舊清單時先儲存 GetFoundItems。

Integer：本機走訪順序中的第一個符合 serial，沒有符合項時為 0。不是圖形、數量、陣列或 Boolean。使用 result <> 0，不要用 result = TRUE 或 result = 1。每疊物品算一個物件；Mobile 算一個物件及一個單位。順序不表示距離最近，也不保證每次固定。

專案原始碼: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 函式 `ResetFindResults`.

#### 4. FindType

Bridge 走訪已載入的 Item 一次；選擇地面時再走訪 Mobile。類型、色調和至少一個容器都必須符合。每個物件只登記一次，不會為每個組合重新掃描整個世界。

地面使用此腳本的 FindDistance/FindVertical，排除 self，包含符合的 Item 和 Mobile。指定容器不套用這些距離／高度限制。兩種範圍都排除 Ignore 清單及已銷毀物件。

專案原始碼: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 函式 `FindType`.

#### 5. MatchesFindIdentity

Graphic/body，不是物件 serial。0..65534 指定圖形；-1 或 0xFFFF 表示任何圖形。其他負 Integer 也會取消此篩選。 Hue，不是數量。0 表示未染色；-1 或 0xFFFF 接受任何色調。其他負 Integer 也會取消色調篩選。

Bridge 走訪已載入的 Item 一次；選擇地面時再走訪 Mobile。類型、色調和至少一個容器都必須符合。每個物件只登記一次，不會為每個組合重新掃描整個世界。

專案原始碼: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 函式 `MatchesFindIdentity`.

#### 6. MatchesFindContainer

必要的 TRUE/FALSE（1/0）。FALSE 只搜尋指定容器的直接內容；TRUE 也搜尋已載入的巢狀袋子。對地面沒有影響。my 原本就包含角色擁有的全部物品。

地面使用此腳本的 FindDistance/FindVertical，排除 self，包含符合的 Item 和 Mobile。指定容器不套用這些距離／高度限制。兩種範圍都排除 Ignore 清單及已銷毀物件。

專案原始碼: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 函式 `MatchesFindContainer`.

#### 7. RegisterFound

走訪前清空 FindItem、FindCount、FindFullQuantity 和 GetFoundItems。搜尋無結果時保留零值及空陣列。FindFullQuantity 對 Item 加總 max(1, Amount)，每個 Mobile 加 1。FindQuantity 讀取 FindItem 目前的數量。後續搜尋會取代結果，需要舊清單時先儲存 GetFoundItems。

Integer：本機走訪順序中的第一個符合 serial，沒有符合項時為 0。不是圖形、數量、陣列或 Boolean。使用 result <> 0，不要用 result = TRUE 或 result = 1。每疊物品算一個物件；Mobile 算一個物件及一個單位。順序不表示距離最近，也不保證每次固定。

專案原始碼: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 函式 `RegisterFound`.

只讀取客戶端已收到的資料，不開啟容器、不載入地圖格、不搬物品。空結果不能證明伺服器上的箱子是空的。需要有效連線時檢查 Connected；搜尋本身讀取本機狀態。


## 範例

### 背包的直接內容

```vb
# 背包的直接內容
#
# 在容器或地面搜尋指定圖形及色調，傳回一個符合條件的 ID。
#
# Integer：本機走訪順序中的第一個符合 serial，沒有符合項時為 0。不是圖形、數量、陣列或 Boolean。使用 result <> 0，不要用 result = TRUE 或
# result = 1。每疊物品算一個物件；Mobile 算一個物件及一個單位。順序不表示距離最近，也不保證每次固定。

SUB Main()
    # 0x0EED 是金幣；-1 接受任何 hue；backpack/FALSE 排除巢狀袋子。輸出第一個 hex ID（不含 0x）、物件數、單位總數。20 和 50 兩疊得到 2 個物件及
    # 70 個單位。

    VAR item = UO.FindTypeEx(0x0EED, -1, 'backpack', FALSE)
    UO.Print(Hex(item))
    UO.Print(STR(UO.FindCount()))
    UO.Print(STR(UO.FindFullQuantity()))
END SUB
```

**參數與執行說明:**

- 0x0EED 是金幣；-1 接受任何 hue；backpack/FALSE 排除巢狀袋子。輸出第一個 hex ID（不含 0x）、物件數、單位總數。20 和 50 兩疊得到 2 個物件及 70 個單位。

### 完整的暫時地面搜尋函式

```vb
# 完整的暫時地面搜尋函式
#
# 在容器或地面搜尋指定圖形及色調，傳回一個符合條件的 ID。
#
# Integer：本機走訪順序中的第一個符合 serial，沒有符合項時為 0。不是圖形、數量、陣列或 Boolean。使用 result <> 0，不要用 result = TRUE 或
# result = 1。每疊物品算一個物件；Mobile 算一個物件及一個單位。順序不表示距離最近，也不保證每次固定。

SUB Main()
    # radius=5、height=10 在 FindGoldNearSelf 內暫時使用。Finally 在 Return 或錯誤時也還原兩個限制。函式傳回金幣 serial 或
    # 0；Main 以 <> 0 檢查後顯示。

    VAR item = FindGoldNearSelf(5, 10)
    IF item <> 0 THEN
        UO.Print(Hex(item))
    ELSE
        UO.Print('Empty')
    END IF
END SUB

FUNCTION FindGoldNearSelf(radius, height)
    VAR oldDistance = UO.FindDistance()
    VAR oldVertical = UO.FindVertical()
    TRY
        UO.FindDistance(radius)
        UO.FindVertical(height)
        RETURN UO.FindTypeEx(0x0EED, -1, UO.Ground(), FALSE)
    FINALLY
        UO.FindDistance(oldDistance)
        UO.FindVertical(oldVertical)
    END TRY
END FUNCTION
```

**參數與執行說明:**

- radius=5、height=10 在 FindGoldNearSelf 內暫時使用。Finally 在 Return 或錯誤時也還原兩個限制。函式傳回金幣 serial 或 0；Main 以 <> 0 檢查後顯示。

### 命名容器與巢狀袋子

```vb
# 命名容器與巢狀袋子
#
# 在容器或地面搜尋指定圖形及色調，傳回一個符合條件的 ID。
#
# Integer：本機走訪順序中的第一個符合 serial，沒有符合項時為 0。不是圖形、數量、陣列或 Boolean。使用 result <> 0，不要用 result = TRUE 或
# result = 1。每疊物品算一個物件；Mobile 算一個物件及一個單位。順序不表示距離最近，也不保證每次固定。

SUB Main()
    # GetSerial 解析 backpack；零值檢查避免誤選地面。AddObject 儲存 search_bag；TRUE 包含巢狀袋子。GetFoundItems
    # 複製清單，IsObjectExists 再次檢查每個 ID。

    VAR bag = UO.GetSerial('backpack')
    IF bag <> 0 THEN
        UO.AddObject('search_bag', bag)
        UO.FindTypeEx(0x0EED, -1, 'search_bag', TRUE)
        VAR items = UO.GetFoundItems()
        FOR EACH item IN items
            IF UO.IsObjectExists(item) THEN
                UO.Print(Hex(item))
            END IF
        NEXT
    END IF
END SUB
```

**參數與執行說明:**

- GetSerial 解析 backpack；零值檢查避免誤選地面。AddObject 儲存 search_bag；TRUE 包含巢狀袋子。GetFoundItems 複製清單，IsObjectExists 再次檢查每個 ID。
