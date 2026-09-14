# Optional

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: zh-tw -->

參數將資料傳入 SUB/FUNCTION。ByRef 把修改後的值寫回呼叫方；ByVal 保留呼叫方的變數。Optional 提供省略的引數，ParamArray 收集剩餘引數。它們是宣告修飾詞，不是可單獨呼叫的命令。

## 完整語法

```text
Function Scale(ByVal value, Optional ByVal factor = 2)
Scale(3)
Scale(3, 4)
```

## 參數

- `name / As type` — name / As type: 參數名稱及選用的 As 輸入型別轉換。引數可依位置或 name:=value 對應；修飾詞寫在宣告中。請參閱 Basic.NamedArguments。
- `ByRef` — ByRef：可修改的變數或既有索引元素。本引擎未寫 ByVal 時也會回寫，與 VB.NET 預設不同。常值、常數及計算式是暫存值。
- `ByVal` — ByVal：值的區域副本。重新指定參數不會替換呼叫方變數。陣列與物件仍共用參考，不是深層複製。
- `Optional / defaultValue` — Optional / defaultValue：省略尾端引數時才計算 = 後的運算式。請明確提供預設值；否則省略的參數會取得未初始化的 Unit。
- `ParamArray` — ParamArray values()：最後一個參數接收零個或更多剩餘值。單一陣列直接沿用；純量引數建立新陣列。GetArrayLength 回傳長度。

## 傳回值

修飾詞不回傳值。RETURN 另外設定函式結果。ByRef 修改引數，不是回傳結果。沒有 RETURN 的 SUB 產生 Unit。範例數字是計算結果，不是 TRUE/FALSE 旗標。

## 行為

- 引數由左到右各計算一次。索引式 ByRef 保留容器及索引／鍵；另一個引數重新指定容器變數，不會改變回寫位置。
- 進入時建立區域參數。離開時先執行內部 FINALLY，再依參數順序回寫 ByRef，包括錯誤離開主體時。同一變數傳入兩個參數不形成即時連動：最後一次回寫生效。
- ByVal 防止替換呼叫方變數，但仍允許修改共用陣列或物件。ReDim 建立新的區域參考。獨立資料需要明確複製。
- 位置引數呼叫：Optional 只能從尾端省略；不支援逗號之間的空白引數位置。預設運算式在每次省略時執行，不必是 VB.NET 常數。 位置引數必須在前；第一個具名引數之後只能使用具名引數。必要參數不可省略。腳本中省略的 Optional 參數採用宣告的預設運算式，在傳入運算式之後按宣告順序計算。原生多載只接受註冊的名稱與數量，不增添預設值。
- ParamArray 不會將打包的純量寫回原變數。明確傳入陣列時，元素修改會影響呼叫方。再傳給另一個 ParamArray 不會增加巢狀層級。
- 請明確寫出 ByRef 與 ByVal。這些規則適用於腳本呼叫使用者程序；內建命令的參數由各自頁面說明。
- ParamArray 不能具名傳入。具名呼叫可將它留空；傳入其元素時必須完全使用位置引數。不支援逗號間的空白佔位。本子集採位置引數在前的規則，沒有新版 VB.NET 的自由混用。不增加執行緒或更動遊戲延遲。

## 範例

### 1. 省略或指定乘數

```vb
# Scale(3) 使用 factor=2，回傳 6。Scale(3,4) 使用 4，回傳 12。Main 回傳 6*100+12，即 Integer 612。
Option Explicit On
Function Scale(ByVal value, Optional ByVal factor = 2)
    Return value * factor
End Function
Sub Main()
    Return Scale(3) * 100 + Scale(3, 4)
End Sub
```

**參數與執行說明:**

Scale(3) 使用 factor=2，回傳 6。Scale(3,4) 使用 4，回傳 12。Main 回傳 6*100+12，即 Integer 612。

### 2. 預設值的計算時機

```vb
# Pick(5) 回傳 5，不呼叫 DefaultAmount。Pick() 呼叫一次：calls=1，值為 7。Main 回傳 5*100+7*10+1，即 Integer 571。
Option Explicit On
Module Counter
    Public Var calls = 0
End Module
Function DefaultAmount()
    Counter.calls += 1
    Return 7
End Function
Function Pick(Optional ByVal value = DefaultAmount())
    Return value
End Function
Sub Main()
    Var first = Pick(5)
    Var second = Pick()
    Return first * 100 + second * 10 + Counter.calls
End Sub
```

**參數與執行說明:**

Pick(5) 回傳 5，不呼叫 DefaultAmount。Pick() 呼叫一次：calls=1，值為 7。Main 回傳 5*100+7*10+1，即 Integer 571。

### 3. Optional、ByRef 與 As Integer

```vb
# value 起始為 1。Increase(value) 加上 amount=2 並存成 3；Increase(value,4) 加上 4 並存成 7。兩個參數皆為 Integer。Main 回傳 Integer 7。
Option Explicit On
Sub Increase(ByRef value As Integer, Optional ByVal amount As Integer = 2)
    value += amount
End Sub
Sub Main()
    Var value As Integer = 1
    Increase(value)
    Increase(value, 4)
    Return value
End Sub
```

**參數與執行說明:**

value 起始為 1。Increase(value) 加上 amount=2 並存成 3；Increase(value,4) 加上 4 並存成 7。兩個參數皆為 Integer。Main 回傳 Integer 7。

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: parameterName / parameterModifier / defaultValue
Runtime/SubrutineDefinition.cs: WritableParameters / RequiredArgumentCount / HasParamArray
Runtime/Interpreter.cs: VisitCall / CreateArgumentWriter / CallSubrutine / EvaluateInitializer
Runtime/IndexedValueSlot.cs: Read / Write
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/modifiers/byref
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/modifiers/byval
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/modifiers/optional
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/modifiers/paramarray
-->
