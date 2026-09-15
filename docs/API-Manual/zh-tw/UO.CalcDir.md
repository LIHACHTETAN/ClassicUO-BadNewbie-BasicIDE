# UO.CalcDir

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: zh-tw -->

計算兩個世界座標點之間的方向，不會移動角色。

## 完整語法

```text
UO.CalcDir(Xfrom:Any, Yfrom:Any, Xto:Any, Yto:Any) -> Integer
```

## 參數

- `Xfrom` — 起點 X。
- `Yfrom` — 起點 Y。
- `Xto` — 終點 X。
- `Yto` — 終點 Y。

## 傳回值

Integer 方向碼：0=北、1=東北、2=東、3=東南、4=南、5=西南、6=西、7=西北。相同點傳回 100。不是 Boolean：0 是北而非失敗，1 是東北而非成功。不可將 100 當成移動方向。

## 行為

- 純計算，不傳封包、不等待、不載入地圖，也不檢查障礙、Z 或世界。不是尋找可行路徑，也不保證抵達。兩點需在同一座標系；繞路可能更長。
- 四個參數都必填，請用文件範圍 0..65535 的 Integer 世界座標。Any 表示通用轉接器，並非物件 ID。沒有預設值、容器內座標、第五個 Z 或單一物件多載。
- 以終點減起點並檢查正負。Y 減少是北、X 增加是東。兩軸皆改變即選對角線，無關差值大小。兩差值皆零則傳回 100。

### 內部函式：從呼叫到結果

第三個範例用一般指令碼函式重建演算法；不表示引擎內部呼叫此範例函式。

#### 1. ExecuteStealthCompatibility

轉接器按 Xfrom,Yfrom,Xto,Yto 順序將位置 0..3 讀為整數，再呼叫純計算函式。

Integer 方向碼：0=北、1=東北、2=東、3=東南、4=南、5=西南、6=西、7=西北。相同點傳回 100。不是 Boolean：0 是北而非失敗，1 是東北而非成功。不可將 100 當成移動方向。

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 函式 `ExecuteStealthCompatibility`.

#### 2. CalculateDirection

`CalculateDirection: dx=Math.Sign(toX-fromX); dy=Math.Sign(toY-fromY); identical ->100; axis/sign branches ->0..7.`

以終點減起點並檢查正負。Y 減少是北、X 增加是東。兩軸皆改變即選對角線，無關差值大小。兩差值皆零則傳回 100。

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 函式 `CalculateDirection`.

純計算，不傳封包、不等待、不載入地圖，也不檢查障礙、Z 或世界。不是尋找可行路徑，也不保證抵達。兩點需在同一座標系；繞路可能更長。


## 範例

### 直接計算

```vb
# 直接計算
#
# 計算兩個世界座標點之間的方向，不會移動角色。
#
# Integer 方向碼：0=北、1=東北、2=東、3=東南、4=南、5=西南、6=西、7=西北。相同點傳回 100。不是 Boolean：0 是北而非失敗，1 是東北而非成功。不可將
# 100 當成移動方向。

SUB Main()
    # 由 (100,100) 到 (101,100) 僅 X 增加。Main 傳回 Integer 2，表示東，不會開始移動。
    # Integer 方向碼：0=北、1=東北、2=東、3=東南、4=南、5=西南、6=西、7=西北。相同點傳回 100。不是 Boolean：0 是北而非失敗，1 是東北而非成功。不可將
    # 100 當成移動方向。
    # 以終點減起點並檢查正負。Y 減少是北、X 增加是東。兩軸皆改變即選對角線，無關差值大小。兩差值皆零則傳回 100。

    Return UO.CalcDir(100,100,101,100)
END SUB
```

**參數與執行說明:**

- 由 (100,100) 到 (101,100) 僅 X 增加。Main 傳回 Integer 2，表示東，不會開始移動。
- Integer 方向碼：0=北、1=東北、2=東、3=東南、4=南、5=西南、6=西、7=西北。相同點傳回 100。不是 Boolean：0 是北而非失敗，1 是東北而非成功。不可將 100 當成移動方向。
- 以終點減起點並檢查正負。Y 減少是北、X 增加是東。兩軸皆改變即選對角線，無關差值大小。兩差值皆零則傳回 100。

### 正確解讀結果

```vb
# 正確解讀結果
#
# 計算兩個世界座標點之間的方向，不會移動角色。
#
# Integer 方向碼：0=北、1=東北、2=東、3=東南、4=南、5=西南、6=西、7=西北。相同點傳回 100。不是 Boolean：0 是北而非失敗，1 是東北而非成功。不可將
# 100 當成移動方向。

SUB Main()
    # 兩點同為 (100,100)，direction=100，因此 Main 傳回 "already there"。不同點走另一分支；請比較 100，不是 True。
    # Integer 方向碼：0=北、1=東北、2=東、3=東南、4=南、5=西南、6=西、7=西北。相同點傳回 100。不是 Boolean：0 是北而非失敗，1 是東北而非成功。不可將
    # 100 當成移動方向。
    # 以終點減起點並檢查正負。Y 減少是北、X 增加是東。兩軸皆改變即選對角線，無關差值大小。兩差值皆零則傳回 100。

    Dim direction=UO.CalcDir(100,100,100,100)
    If direction=100 Then
        Return "already there"
    End If
    Return "different point"
END SUB
```

**參數與執行說明:**

- 兩點同為 (100,100)，direction=100，因此 Main 傳回 "already there"。不同點走另一分支；請比較 100，不是 True。
- Integer 方向碼：0=北、1=東北、2=東、3=東南、4=南、5=西南、6=西、7=西北。相同點傳回 100。不是 Boolean：0 是北而非失敗，1 是東北而非成功。不可將 100 當成移動方向。
- 以終點減起點並檢查正負。Y 減少是北、X 增加是東。兩軸皆改變即選對角線，無關差值大小。兩差值皆零則傳回 100。

### 完整指令碼演算法

```vb
# 完整指令碼演算法
#
# 計算兩個世界座標點之間的方向，不會移動角色。
#
# Integer 方向碼：0=北、1=東北、2=東、3=東南、4=南、5=西南、6=西、7=西北。相同點傳回 100。不是 Boolean：0 是北而非失敗，1 是東北而非成功。不可將
# 100 當成移動方向。

SUB Main()
    # 由 (20,20) 到 (19,21)，X 減少、Y 增加。UO.CalcDir 與完整 RebuildDirection 都傳回 5，Main 傳回
    # "5:5"。輔助函式展示所有分支，四參數意義相同。
    # Integer 方向碼：0=北、1=東北、2=東、3=東南、4=南、5=西南、6=西、7=西北。相同點傳回 100。不是 Boolean：0 是北而非失敗，1 是東北而非成功。不可將
    # 100 當成移動方向。
    # 以終點減起點並檢查正負。Y 減少是北、X 增加是東。兩軸皆改變即選對角線，無關差值大小。兩差值皆零則傳回 100。

    Dim actual=UO.CalcDir(20,20,19,21)
    Dim rebuilt=RebuildDirection(20,20,19,21)
    Return CStr(actual) & ":" & CStr(rebuilt)
END SUB

Function RebuildDirection(Xfrom, Yfrom, Xto, Yto) As Integer
    Dim dx = Xto-Xfrom
    Dim dy = Yto-Yfrom
    If dx=0 AndAlso dy=0 Then
        Return 100
    End If
    If dx=0 Then
        If dy<0 Then
            Return 0
        End If
        Return 4
    End If
    If dy=0 Then
        If dx>0 Then
            Return 2
        End If
        Return 6
    End If
    If dx>0 Then
        If dy<0 Then
            Return 1
        End If
        Return 3
    End If
    If dy>0 Then
        Return 5
    End If
    Return 7
End Function
```

**參數與執行說明:**

- 由 (20,20) 到 (19,21)，X 減少、Y 增加。UO.CalcDir 與完整 RebuildDirection 都傳回 5，Main 傳回 "5:5"。輔助函式展示所有分支，四參數意義相同。
- Integer 方向碼：0=北、1=東北、2=東、3=東南、4=南、5=西南、6=西、7=西北。相同點傳回 100。不是 Boolean：0 是北而非失敗，1 是東北而非成功。不可將 100 當成移動方向。
- 以終點減起點並檢查正負。Y 減少是北、X 增加是東。兩軸皆改變即選對角線，無關差值大小。兩差值皆零則傳回 100。
