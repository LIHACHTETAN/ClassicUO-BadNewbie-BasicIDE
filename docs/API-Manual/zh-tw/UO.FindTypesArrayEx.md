# UO.FindTypesArrayEx

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: zh-tw -->

一次走訪搜尋多種圖形、色調和容器，傳回一個 ID。完整清單請讀取 GetFoundItems。

## 完整語法

```text
UO.FindTypesArrayEx(ObjTypes:Any, Colors:Any, Containers:Any, InSub:Any) -> Integer
```

## 參數

- `ObjTypes` — Graphic/body，不是物件 serial。0..65534 指定圖形；-1 或 0xFFFF 表示任何圖形。其他負 Integer 也會取消此篩選。
- `Colors` — Hue，不是數量。0 表示未染色；-1 或 0xFFFF 接受任何色調。其他負 Integer 也會取消色調篩選。
- `Containers` — 地面：UO.Ground()、0、-1、0xFFFFFFFF 或字串 ground。背包：字串 backpack 或背包 serial。接受十進位／hex serial 及 AddObject 名稱。my 選擇角色擁有的全部物品，包括裝備和巢狀袋子。未知名稱會產生腳本錯誤。傳入解析出的 serial 前請檢查：明確的 0 會選擇地面。不同 API 的數值慣例不同，建議使用 ground/backpack 名稱。
- `InSub` — 必要的 TRUE/FALSE（1/0）。FALSE 只搜尋指定容器的直接內容；TRUE 也搜尋已載入的巢狀袋子。對地面沒有影響。my 原本就包含角色擁有的全部物品。

## 傳回值

Integer：本機走訪順序中的第一個符合 serial，沒有符合項時為 0。不是圖形、數量、陣列或 Boolean。使用 result <> 0，不要用 result = TRUE 或 result = 1。每疊物品算一個物件；Mobile 算一個物件及一個單位。順序不表示距離最近，也不保證每次固定。

## 行為

- 傳入 Array；也接受純量作為單一元素。DIM values[1] 建立索引 0 和 1，請全部賦值。類型和顏色是獨立選項，不是按索引配對。任一位置有萬用值，或類型／顏色陣列為空，都會移除該篩選。空容器陣列選擇角色擁有的物品。重複或重疊的容器不會產生重複 ID。
- 四個位置參數全部必要，不能省略。
- 地面使用此腳本的 FindDistance/FindVertical，排除 self，包含符合的 Item 和 Mobile。指定容器不套用這些距離／高度限制。兩種範圍都排除 Ignore 清單及已銷毀物件。
- 走訪前清空 FindItem、FindCount、FindFullQuantity 和 GetFoundItems。搜尋無結果時保留零值及空陣列。FindFullQuantity 對 Item 加總 max(1, Amount)，每個 Mobile 加 1。FindQuantity 讀取 FindItem 目前的數量。後續搜尋會取代結果，需要舊清單時先儲存 GetFoundItems。
- Bridge 走訪已載入的 Item 一次；選擇地面時再走訪 Mobile。類型、色調和至少一個容器都必須符合。每個物件只登記一次，不會為每個組合重新掃描整個世界。
- 只讀取客戶端已收到的資料，不開啟容器、不載入地圖格、不搬物品。空結果不能證明伺服器上的箱子是空的。需要有效連線時檢查 Connected；搜尋本身讀取本機狀態。
- [Stealth FindTypesArrayEx](https://stealth.od.ua/api/FindTypesArrayEx/). 參考文件描述最後一個 ID，以及無效容器時改用背包。本客戶端保留第一個本機結果，未知名稱不改用背包。Ground 也接受 0；本機 FindDistance 預設 18、最大 255。

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

#### 4. BuildFindIdentityMask

傳入 Array；也接受純量作為單一元素。DIM values[1] 建立索引 0 和 1，請全部賦值。類型和顏色是獨立選項，不是按索引配對。任一位置有萬用值，或類型／顏色陣列為空，都會移除該篩選。空容器陣列選擇角色擁有的物品。重複或重疊的容器不會產生重複 ID。

Bridge 走訪已載入的 Item 一次；選擇地面時再走訪 Mobile。類型、色調和至少一個容器都必須符合。每個物件只登記一次，不會為每個組合重新掃描整個世界。

專案原始碼: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 函式 `BuildFindIdentityMask`.

#### 5. FindTypes

Bridge 走訪已載入的 Item 一次；選擇地面時再走訪 Mobile。類型、色調和至少一個容器都必須符合。每個物件只登記一次，不會為每個組合重新掃描整個世界。

地面使用此腳本的 FindDistance/FindVertical，排除 self，包含符合的 Item 和 Mobile。指定容器不套用這些距離／高度限制。兩種範圍都排除 Ignore 清單及已銷毀物件。

專案原始碼: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 函式 `FindTypes`.

#### 6. MatchesFindIdentity

Graphic/body，不是物件 serial。0..65534 指定圖形；-1 或 0xFFFF 表示任何圖形。其他負 Integer 也會取消此篩選。 Hue，不是數量。0 表示未染色；-1 或 0xFFFF 接受任何色調。其他負 Integer 也會取消色調篩選。

Bridge 走訪已載入的 Item 一次；選擇地面時再走訪 Mobile。類型、色調和至少一個容器都必須符合。每個物件只登記一次，不會為每個組合重新掃描整個世界。

專案原始碼: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 函式 `MatchesFindIdentity`.

#### 7. MatchesFindContainer

必要的 TRUE/FALSE（1/0）。FALSE 只搜尋指定容器的直接內容；TRUE 也搜尋已載入的巢狀袋子。對地面沒有影響。my 原本就包含角色擁有的全部物品。

地面使用此腳本的 FindDistance/FindVertical，排除 self，包含符合的 Item 和 Mobile。指定容器不套用這些距離／高度限制。兩種範圍都排除 Ignore 清單及已銷毀物件。

專案原始碼: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 函式 `MatchesFindContainer`.

#### 8. RegisterFound

走訪前清空 FindItem、FindCount、FindFullQuantity 和 GetFoundItems。搜尋無結果時保留零值及空陣列。FindFullQuantity 對 Item 加總 max(1, Amount)，每個 Mobile 加 1。FindQuantity 讀取 FindItem 目前的數量。後續搜尋會取代結果，需要舊清單時先儲存 GetFoundItems。

Integer：本機走訪順序中的第一個符合 serial，沒有符合項時為 0。不是圖形、數量、陣列或 Boolean。使用 result <> 0，不要用 result = TRUE 或 result = 1。每疊物品算一個物件；Mobile 算一個物件及一個單位。順序不表示距離最近，也不保證每次固定。

專案原始碼: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 函式 `RegisterFound`.

只讀取客戶端已收到的資料，不開啟容器、不載入地圖格、不搬物品。空結果不能證明伺服器上的箱子是空的。需要有效連線時檢查 Connected；搜尋本身讀取本機狀態。


## 範例

### 地面上的兩種圖形

```vb
# 地面上的兩種圖形
#
# 一次走訪搜尋多種圖形、色調和容器，傳回一個 ID。完整清單請讀取 GetFoundItems。
#
# Integer：本機走訪順序中的第一個符合 serial，沒有符合項時為 0。不是圖形、數量、陣列或 Boolean。使用 result <> 0，不要用 result = TRUE 或
# result = 1。每疊物品算一個物件；Mobile 算一個物件及一個單位。順序不表示距離最近，也不保證每次固定。

SUB Main()
    # types 包含金幣 0x0EED 和黑珍珠 0x0F7A；color=-1 接受所有色調，Ground 選擇世界。FALSE 對地面無影響。使用目前搜尋限制。輸出 ID、物件數、單位數。

    DIM types[1]
    types[0] = 0x0EED
    types[1] = 0x0F7A
    DIM colors[0]
    colors[0] = -1
    DIM containers[0]
    containers[0] = UO.Ground()
    VAR first = UO.FindTypesArrayEx(types, colors, containers, FALSE)
    UO.Print(Hex(first))
    UO.Print(STR(UO.FindCount()))
    UO.Print(STR(UO.FindFullQuantity()))
END SUB
```

**參數與執行說明:**

- types 包含金幣 0x0EED 和黑珍珠 0x0F7A；color=-1 接受所有色調，Ground 選擇世界。FALSE 對地面無影響。使用目前搜尋限制。輸出 ID、物件數、單位數。

### 背包與地面的金幣

```vb
# 背包與地面的金幣
#
# 一次走訪搜尋多種圖形、色調和容器，傳回一個 ID。完整清單請讀取 GetFoundItems。
#
# Integer：本機走訪順序中的第一個符合 serial，沒有符合項時為 0。不是圖形、數量、陣列或 Boolean。使用 result <> 0，不要用 result = TRUE 或
# result = 1。每疊物品算一個物件；Mobile 算一個物件及一個單位。順序不表示距離最近，也不保證每次固定。

SUB Main()
    # types 僅金幣；colors 接受所有色調。Containers 包含 backpack 和地面；TRUE 包含巢狀袋子。輸出兩個範圍的物件／疊數及單位，不重複計算。

    DIM types[0]
    types[0] = 0x0EED
    DIM colors[0]
    colors[0] = -1
    DIM containers[1]
    containers[0] = 'backpack'
    containers[1] = UO.Ground()
    UO.FindTypesArrayEx(types, colors, containers, TRUE)
    UO.Print(STR(UO.FindCount()))
    UO.Print(STR(UO.FindFullQuantity()))
END SUB
```

**參數與執行說明:**

- types 僅金幣；colors 接受所有色調。Containers 包含 backpack 和地面；TRUE 包含巢狀袋子。輸出兩個範圍的物件／疊數及單位，不重複計算。

### 傳回已儲存清單的完整函式

```vb
# 傳回已儲存清單的完整函式
#
# 一次走訪搜尋多種圖形、色調和容器，傳回一個 ID。完整清單請讀取 GetFoundItems。
#
# Integer：本機走訪順序中的第一個符合 serial，沒有符合項時為 0。不是圖形、數量、陣列或 Boolean。使用 result <> 0，不要用 result = TRUE 或
# result = 1。每疊物品算一個物件；Mobile 算一個物件及一個單位。順序不表示距離最近，也不保證每次固定。

SUB Main()
    # SearchTypesIn(container,firstType,secondType) 傳回 Array<Integer>，內建指令則只傳回單一 Integer
    # ID。完整函式填入陣列、遞迴搜尋，立即複製 GetFoundItems。Main 檢查並顯示每個儲存的 ID。

    VAR items = SearchTypesIn('backpack', 0x0EED, 0x0F7A)
    FOR EACH item IN items
        IF UO.IsObjectExists(item) THEN
            UO.Print(Hex(item))
        END IF
    NEXT
END SUB

FUNCTION SearchTypesIn(container, firstType, secondType)
    DIM types[1]
    types[0] = firstType
    types[1] = secondType
    DIM colors[0]
    colors[0] = -1
    DIM containers[0]
    containers[0] = container
    UO.FindTypesArrayEx(types, colors, containers, TRUE)
    RETURN UO.GetFoundItems()
END FUNCTION
```

**參數與執行說明:**

- SearchTypesIn(container,firstType,secondType) 傳回 Array<Integer>，內建指令則只傳回單一 Integer ID。完整函式填入陣列、遞迴搜尋，立即複製 GetFoundItems。Main 檢查並顯示每個儲存的 ID。
