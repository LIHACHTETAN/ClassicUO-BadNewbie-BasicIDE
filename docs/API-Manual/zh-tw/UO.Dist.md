# UO.Dist

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: zh-tw -->

以 X、Y 絕對差值中的較大者，計算兩點相隔的格數。

## 完整語法

```text
UO.Dist(Xfrom:Any, Yfrom:Any, Xto:Any, Yto:Any) -> Integer
```

## 參數

- `Xfrom` — 起點 X。
- `Yfrom` — 起點 Y。
- `Xto` — 終點 X。
- `Yto` — 終點 Y。

## 傳回值

有效座標傳回非負 Integer 格數。0 表示 XY 相同，1 表示一格，不是成功旗標。另行比較 distance<=2 才會得到 1/True 或 0/False。

## 行為

- 純計算，不傳封包、不等待、不載入地圖，也不檢查障礙、Z 或世界。不是尋找可行路徑，也不保證抵達。兩點需在同一座標系；繞路可能更長。
- 四個參數都必填，請用文件範圍 0..65535 的 Integer 世界座標。Any 表示通用轉接器，並非物件 ID。沒有預設值、容器內座標、第五個 Z 或單一物件多載。
- Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom))。交換兩點不改變結果。不是歐氏距離、兩差值相加或避障步數。

### 內部函式：從呼叫到結果

第三個範例用一般指令碼函式重建演算法；不表示引擎內部呼叫此範例函式。

#### 1. ExecuteStealthCompatibility

轉接器按 Xfrom,Yfrom,Xto,Yto 順序將位置 0..3 讀為整數，再呼叫純計算函式。

有效座標傳回非負 Integer 格數。0 表示 XY 相同，1 表示一格，不是成功旗標。另行比較 distance<=2 才會得到 1/True 或 0/False。

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 函式 `ExecuteStealthCompatibility`.

#### 2. GetDistance

`GetDistance(int,int,int,int): dx=Math.Abs(x1-x2); dy=Math.Abs(y1-y2); return Math.Max(dx,dy).`

Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom))。交換兩點不改變結果。不是歐氏距離、兩差值相加或避障步數。

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 函式 `GetDistance`.

純計算，不傳封包、不等待、不載入地圖，也不檢查障礙、Z 或世界。不是尋找可行路徑，也不保證抵達。兩點需在同一座標系；繞路可能更長。


## 範例

### 直接計算

```vb
# 直接計算
#
# 以 X、Y 絕對差值中的較大者，計算兩點相隔的格數。
#
# 有效座標傳回非負 Integer 格數。0 表示 XY 相同，1 表示一格，不是成功旗標。另行比較 distance<=2 才會得到 1/True 或 0/False。

SUB Main()
    # (100,100) 到 (103,104) 的絕對差值為 3、4。Main 傳回較大的 Integer 4。
    # 有效座標傳回非負 Integer 格數。0 表示 XY 相同，1 表示一格，不是成功旗標。另行比較 distance<=2 才會得到 1/True 或 0/False。
    # Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom))。交換兩點不改變結果。不是歐氏距離、兩差值相加或避障步數。

    Return UO.Dist(100,100,103,104)
END SUB
```

**參數與執行說明:**

- (100,100) 到 (103,104) 的絕對差值為 3、4。Main 傳回較大的 Integer 4。
- 有效座標傳回非負 Integer 格數。0 表示 XY 相同，1 表示一格，不是成功旗標。另行比較 distance<=2 才會得到 1/True 或 0/False。
- Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom))。交換兩點不改變結果。不是歐氏距離、兩差值相加或避障步數。

### 正確解讀結果

```vb
# 正確解讀結果
#
# 以 X、Y 絕對差值中的較大者，計算兩點相隔的格數。
#
# 有效座標傳回非負 Integer 格數。0 表示 XY 相同，1 表示一格，不是成功旗標。另行比較 distance<=2 才會得到 1/True 或 0/False。

SUB Main()
    # (100,100) 到 (101,99) 的距離為 1；另行比較 distance<=2 得到 True=1。"1:1" 第一個 1 是距離，第二個才是邏輯結果。
    # 有效座標傳回非負 Integer 格數。0 表示 XY 相同，1 表示一格，不是成功旗標。另行比較 distance<=2 才會得到 1/True 或 0/False。
    # Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom))。交換兩點不改變結果。不是歐氏距離、兩差值相加或避障步數。

    Dim distance=UO.Dist(100,100,101,99)
    Dim close=distance<=2
    Return CStr(distance) & ":" & CStr(close)
END SUB
```

**參數與執行說明:**

- (100,100) 到 (101,99) 的距離為 1；另行比較 distance<=2 得到 True=1。"1:1" 第一個 1 是距離，第二個才是邏輯結果。
- 有效座標傳回非負 Integer 格數。0 表示 XY 相同，1 表示一格，不是成功旗標。另行比較 distance<=2 才會得到 1/True 或 0/False。
- Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom))。交換兩點不改變結果。不是歐氏距離、兩差值相加或避障步數。

### 完整指令碼演算法

```vb
# 完整指令碼演算法
#
# 以 X、Y 絕對差值中的較大者，計算兩點相隔的格數。
#
# 有效座標傳回非負 Integer 格數。0 表示 XY 相同，1 表示一格，不是成功旗標。另行比較 distance<=2 才會得到 1/True 或 0/False。

SUB Main()
    # UO.Dist 與 RebuildTileDistance 都得到 4，Main 傳回 "4:4"。完整輔助函式計算 Abs 差值並傳回較大者；它是範例程式，不是新增 API 指令。
    # 有效座標傳回非負 Integer 格數。0 表示 XY 相同，1 表示一格，不是成功旗標。另行比較 distance<=2 才會得到 1/True 或 0/False。
    # Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom))。交換兩點不改變結果。不是歐氏距離、兩差值相加或避障步數。

    Dim actual=UO.Dist(100,100,103,104)
    Dim rebuilt=RebuildTileDistance(100,100,103,104)
    Return CStr(actual) & ":" & CStr(rebuilt)
END SUB

Function RebuildTileDistance(Xfrom, Yfrom, Xto, Yto) As Integer
    Dim dx = Abs(Xto-Xfrom)
    Dim dy = Abs(Yto-Yfrom)
    If dx>dy Then
        Return dx
    End If
    Return dy
End Function
```

**參數與執行說明:**

- UO.Dist 與 RebuildTileDistance 都得到 4，Main 傳回 "4:4"。完整輔助函式計算 Abs 差值並傳回較大者；它是範例程式，不是新增 API 指令。
- 有效座標傳回非負 Integer 格數。0 表示 XY 相同，1 表示一格，不是成功旗標。另行比較 distance<=2 才會得到 1/True 或 0/False。
- Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom))。交換兩點不改變結果。不是歐氏距離、兩差值相加或避障步數。
