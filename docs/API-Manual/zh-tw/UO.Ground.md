# UO.Ground

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: zh-tw -->

回傳代表地面的特殊選擇值，供搜尋容器或移動目的地參數使用。

## 完整語法

```text
UO.Ground() -> Integer
```

## 參數

沒有參數。

## 傳回值

Integer，永遠為 0。這是有效的地面選擇值，不是 FALSE、搜尋失敗、物件 ID、圖形、地圖編號或座標。請檢查使用它的搜尋或移動結果，不要把 Ground() 當成成功旗標。

## 行為

- 沒有參數。單獨呼叫 Ground() 不搜尋、不移動、不開啟目標、不傳送封包，也不改變既有搜尋結果。登入前同樣回傳 0。
- 放在 FindType、FindList、Count、FindTypeEx、FindTypesArrayEx、CountEx 或 MoveItem 的 container/destination 位置。搜尋只讀取已載入物件，不載入遠方格子。地面的 X/Y/Z 是世界座標，不是容器視窗像素。
- FindType(type, color) 仍搜尋物品欄：第二參數是顏色。地面需寫 FindType(type, color, UO.Ground())。舊式精簡 FindType/MoveItem 以 -1 表示物品欄；相容 FindTypeEx/FindTypesArrayEx/CountEx 也接受 -1 表示地面。建議用 UO.Ground() 或名稱 ground，避免在不同指令間直接搬用數字。
- 原始參考：[Stealth Ground](https://stealth.od.ua/api/Ground/)。上述指令慣例及範例描述此客戶端。

### 內部函式：從呼叫到結果

以下為實際內部步驟。FindGroundTypes 是完整使用者函式，不是額外的內建指令。

#### 1. ExecuteStealthCompatibility

無參數的 runtime 分支直接回傳 Integer 0，不呼叫遊戲 bridge。

Integer，永遠為 0。這是有效的地面選擇值，不是 FALSE、搜尋失敗、物件 ID、圖形、地圖編號或座標。請檢查使用它的搜尋或移動結果，不要把 Ground() 當成成功旗標。

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 函式 `ExecuteStealthCompatibility`.

#### 2. ConvertContainer

精簡搜尋將明確的 0 轉成內部地面範圍，並保留 -1 作為物品欄預設值。相容搜尋接受 0 與舊的 -1 表示地面；容器名稱另行解析。

FindType(type, color) 仍搜尋物品欄：第二參數是顏色。地面需寫 FindType(type, color, UO.Ground())。舊式精簡 FindType/MoveItem 以 -1 表示物品欄；相容 FindTypeEx/FindTypesArrayEx/CountEx 也接受 -1 表示地面。建議用 UO.Ground() 或名稱 ground，避免在不同指令間直接搬用數字。

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 函式 `ConvertContainer`.

#### 3. ConvertStealthSearchContainer

精簡搜尋將明確的 0 轉成內部地面範圍，並保留 -1 作為物品欄預設值。相容搜尋接受 0 與舊的 -1 表示地面；容器名稱另行解析。

FindType(type, color) 仍搜尋物品欄：第二參數是顏色。地面需寫 FindType(type, color, UO.Ground())。舊式精簡 FindType/MoveItem 以 -1 表示物品欄；相容 FindTypeEx/FindTypesArrayEx/CountEx 也接受 -1 表示地面。建議用 UO.Ground() 或名稱 ground，避免在不同指令間直接搬用數字。

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 函式 `ConvertStealthSearchContainer`.

#### 4. ResolveTransferDestination

目的地解析保留地面值 0。客戶端 bridge 使用世界座標，放下封包的容器欄位則為 0xFFFFFFFF。API 選擇值與封包欄位採用不同表示法。

將 0x40001001 改成可存取物品的 serial。IsObjectExists 先檢查已載入物件。MoveItem(item, amount, destination, X, Y, Z)：amount=0 為整堆，Ground() 選地面，GetX/GetY/GetZ 讀取角色世界座標。result=1 表示客戶端接受移動請求，否則 0；這不是 Ground() 的結果，也不是伺服器收件確認。

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 函式 `ResolveTransferDestination`.

#### 5. MoveItem

目的地解析保留地面值 0。客戶端 bridge 使用世界座標，放下封包的容器欄位則為 0xFFFFFFFF。API 選擇值與封包欄位採用不同表示法。

將 0x40001001 改成可存取物品的 serial。IsObjectExists 先檢查已載入物件。MoveItem(item, amount, destination, X, Y, Z)：amount=0 為整堆，Ground() 選地面，GetX/GetY/GetZ 讀取角色世界座標。result=1 表示客戶端接受移動請求，否則 0；這不是 Ground() 的結果，也不是伺服器收件確認。

專案原始碼: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 函式 `MoveItem`.

沒有參數。單獨呼叫 Ground() 不搜尋、不移動、不開啟目標、不傳送封包，也不改變既有搜尋結果。登入前同樣回傳 0。


## 範例

### 讀取選擇值

```vb
# 讀取選擇值
#
# 回傳代表地面的特殊選擇值，供搜尋容器或移動目的地參數使用。
#
# Integer，永遠為 0。這是有效的地面選擇值，不是 FALSE、搜尋失敗、物件 ID、圖形、地圖編號或座標。請檢查使用它的搜尋或移動結果，不要把 Ground() 當成成功旗標。

SUB Main()
    # destination 得到 Integer 0，Print 顯示它。這不會放下任何物品。

    VAR destination = UO.Ground()
    UO.Print(CStr(destination))
END SUB
```

**參數與執行說明:**

- destination 得到 Integer 0，Print 顯示它。這不會放下任何物品。

### 搜尋地面的金幣堆

```vb
# 搜尋地面的金幣堆
#
# 回傳代表地面的特殊選擇值，供搜尋容器或移動目的地參數使用。
#
# Integer，永遠為 0。這是有效的地面選擇值，不是 FALSE、搜尋失敗、物件 ID、圖形、地圖編號或座標。請檢查使用它的搜尋或移動結果，不要把 Ground() 當成成功旗標。

SUB Main()
    # 0x0EED 是金幣圖形；第二個 -1 代表任何色彩。Ground() 選取世界，FALSE 停用容器遞迴。FindTypeEx 回傳 serial 或 0，<> 0 檢查該
    # serial。適用 FindDistance/FindVertical 與 Ignore。

    VAR id = UO.FindTypeEx(0x0EED, -1, UO.Ground(), FALSE)
    IF id <> 0 THEN
        UO.Print(HEX(id))
    ELSE
        UO.Print('0')
    END IF
END SUB
```

**參數與執行說明:**

- 0x0EED 是金幣圖形；第二個 -1 代表任何色彩。Ground() 選取世界，FALSE 停用容器遞迴。FindTypeEx 回傳 serial 或 0，<> 0 檢查該 serial。適用 FindDistance/FindVertical 與 Ignore。

### 搜尋兩種圖形的完整函式

```vb
# 搜尋兩種圖形的完整函式
#
# 回傳代表地面的特殊選擇值，供搜尋容器或移動目的地參數使用。
#
# Integer，永遠為 0。這是有效的地面選擇值，不是 FALSE、搜尋失敗、物件 ID、圖形、地圖編號或座標。請檢查使用它的搜尋或移動結果，不要把 Ground() 當成成功旗標。

SUB Main()
    # FindGroundTypes(firstType, secondType, radius, height) 搜尋金幣 0x0EED 和黑珍珠
    # 0x0F7A，radius=5、height=10。DIM types[1] 建立兩格，colors[0] 和 containers[0]
    # 各一格。一堆算一個物件；類型／色彩是可選條件，重疊容器不會重複 ID。函式回傳保存的 serial 陣列，Finally 還原兩個限制，Main 印出每個 ID。完整函式如下。

    VAR ids = FindGroundTypes(0x0EED, 0x0F7A, 5, 10)
    FOR EACH id IN ids
        UO.Print(HEX(id))
    NEXT
END SUB

FUNCTION FindGroundTypes(firstType, secondType, radius, height)
    VAR oldDistance = UO.FindDistance()
    VAR oldVertical = UO.FindVertical()
    DIM types[1]
    types[0] = firstType
    types[1] = secondType
    DIM colors[0]
    colors[0] = -1
    DIM containers[0]
    containers[0] = UO.Ground()
    TRY
        UO.FindDistance(radius)
        UO.FindVertical(height)
        UO.FindTypesArrayEx(types, colors, containers, FALSE)
        RETURN UO.GetFoundItems()
    FINALLY
        UO.FindDistance(oldDistance)
        UO.FindVertical(oldVertical)
    END TRY
END FUNCTION
```

**參數與執行說明:**

- FindGroundTypes(firstType, secondType, radius, height) 搜尋金幣 0x0EED 和黑珍珠 0x0F7A，radius=5、height=10。DIM types[1] 建立兩格，colors[0] 和 containers[0] 各一格。一堆算一個物件；類型／色彩是可選條件，重疊容器不會重複 ID。函式回傳保存的 serial 陣列，Finally 還原兩個限制，Main 印出每個 ID。完整函式如下。

### 把已知物品放到角色所在格子

```vb
# 把已知物品放到角色所在格子
#
# 回傳代表地面的特殊選擇值，供搜尋容器或移動目的地參數使用。
#
# Integer，永遠為 0。這是有效的地面選擇值，不是 FALSE、搜尋失敗、物件 ID、圖形、地圖編號或座標。請檢查使用它的搜尋或移動結果，不要把 Ground() 當成成功旗標。

SUB Main()
    # 將 0x40001001 改成可存取物品的 serial。IsObjectExists 先檢查已載入物件。MoveItem(item, amount, destination, X, Y,
    # Z)：amount=0 為整堆，Ground() 選地面，GetX/GetY/GetZ 讀取角色世界座標。result=1 表示客戶端接受移動請求，否則 0；這不是 Ground()
    # 的結果，也不是伺服器收件確認。

    VAR item = 0x40001001
    IF UO.IsObjectExists(item) THEN
        VAR result = UO.MoveItem(item, 0, UO.Ground(), UO.GetX('self'), UO.GetY('self'), UO.GetZ('self'))
    END IF
END SUB
```

**參數與執行說明:**

- 將 0x40001001 改成可存取物品的 serial。IsObjectExists 先檢查已載入物件。MoveItem(item, amount, destination, X, Y, Z)：amount=0 為整堆，Ground() 選地面，GetX/GetY/GetZ 讀取角色世界座標。result=1 表示客戶端接受移動請求，否則 0；這不是 Ground() 的結果，也不是伺服器收件確認。
