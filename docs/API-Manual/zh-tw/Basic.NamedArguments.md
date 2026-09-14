# Named arguments / :=

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: zh-tw -->

具名引數依宣告的參數名稱傳值，書寫順序不必與宣告相同。支援腳本程序、函式、模組、已註冊的 Basic/UO 函式及原生物件方法。

## 完整語法

```text
FunctionName(parameterName:=expression, otherName:=expression)
FunctionName(positionalExpression, optionalName:=expression)
FunctionName([reservedName]:=expression)
```

## 參數

- `parameterName / [reservedName]` — 使用宣告或簽章中的名稱：name:=value，不分大小寫。保留字名稱可寫成 [to]:=100；方括號是參數名稱的跳脫形式，不是陣列索引。未知或重複名稱會報錯。
- `expression` — 每個傳入運算式依書寫順序由左至右計算一次，再放入對應參數。型別、界限、ByVal/ByRef 規則由被呼叫函式決定；具名形式不會讓一般值變成可寫回的變數。
- `positionalExpression / optionalName` — 位置引數必須在前；第一個具名引數之後只能使用具名引數。必要參數不可省略。腳本中省略的 Optional 參數採用宣告的預設運算式，在傳入運算式之後按宣告順序計算。原生多載只接受註冊的名稱與數量，不增添預設值。

## 傳回值

:= 本身不回傳獨立值。函式/API 保留自己的回傳結果；Sub 沒有隱含結果。範例回傳 Integer 129，以及 String "21:12"、"20:10:2"，不是 Boolean 成功旗標。

## 行為

- 準備階段以 SC027 和來源位置報告名稱錯誤、重複、缺少必要參數或歧義。動態物件於執行時、計算引數之前檢查。找不到原生多載時，不會改呼叫零引數版本。
- 直譯器快取靜態呼叫點的不變對應表。運算式按原始碼順序計算，參數指定及 ByRef 寫回依對應表進行。預設值與偵錯器參數對應選定的簽章。動態接收物件每次呼叫都重新擷取，不沿用前一次的物件。
- ParamArray 不能具名傳入。具名呼叫可將它留空；傳入其元素時必須完全使用位置引數。不支援逗號間的空白佔位。本子集採位置引數在前的規則，沒有新版 VB.NET 的自由混用。不增加執行緒或更動遊戲延遲。

## 範例

### 1. 省略中間的 Optional

```vb
# Encode 宣告 x、y=2、z=3。z:=9 先提供 z，x:=1 再提供 x，省略的 y 為 2。計算 1*100+2*10+9=129。等價形式為 Encode(1,2,9) 或 Encode(1,z:=9)。
Option Explicit On
Function Encode(ByVal x, Optional ByVal y=2, Optional ByVal z=3) As Integer
    Return x*100 + y*10 + z
End Function

Sub Main()
    Dim encoded = Encode(z:=9, x:=1)
    Return encoded
End Sub
```

**參數與執行說明:**

Encode 宣告 x、y=2、z=3。z:=9 先提供 z，x:=1 再提供 x，省略的 y 為 2。計算 1*100+2*10+9=129。等價形式為 Encode(1,2,9) 或 Encode(1,z:=9)。

### 2. ByRef 寫回正確變數

```vb
# Change 的參數為 ByRef left、right。right:=a 將 a=1 對應到 right；left:=b 將 b=2 對應到 left。left 加 10、right 加 20 後寫回 b=12、a=21，Main 回傳 "21:12"。:= 左邊是參數，右邊是呼叫者變數。
Option Explicit On
Sub Change(ByRef left, ByRef right)
    left += 10
    right += 20
End Sub

Sub Main()
    Dim a = 1
    Dim b = 2
    Change(right:=a, left:=b)
    Return CStr(a) & ":" & CStr(b)
End Sub
```

**參數與執行說明:**

Change 的參數為 ByRef left、right。right:=a 將 a=1 對應到 right；left:=b 將 b=2 對應到 left。left 加 10、right 加 20 後寫回 b=12、a=21，Main 回傳 "21:12"。:= 左邊是參數，右邊是呼叫者變數。

### 3. 原生清單使用具名操作數

```vb
# List() 建立清單。Add(value:=10) 加入 10，無回傳值。Insert(value:=20,index:=0) 在索引 0 插入 20，將 10 移至索引 1。Item(index:=...) 回傳元素，Count() 回傳 2。Main 產生 "20:10:2"。UO.Name(...) 使用相同規則，但依該指令註冊的名称與回傳約定。
Option Explicit On
Sub Main()
    Dim items = List()
    items.Add(value:=10)
    items.Insert(value:=20, index:=0)
    Dim first = items.Item(index:=0)
    Dim second = items.Item(index:=1)
    Return CStr(first) & ":" & CStr(second) & ":" & CStr(items.Count())
End Sub
```

**參數與執行說明:**

List() 建立清單。Add(value:=10) 加入 10，無回傳值。Insert(value:=20,index:=0) 在索引 0 插入 20，將 10 移至索引 1。Item(index:=...) 回傳元素，Count() 回傳 2。Main 產生 "20:10:2"。UO.Name(...) 使用相同規則，但依該指令註冊的名称與回傳約定。

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: argument
Runtime/NamedArgumentBinding.cs: TryCreate / TryCustom
Runtime/Interpreter.NamedArguments.cs: CallNamed
Runtime/Interpreter.cs: CallSubrutine / CreateArgumentWriter
Analysis/NamedArgumentsValidator.cs
https://learn.microsoft.com/en-us/dotnet/visual-basic/programming-guide/language-features/procedures/passing-arguments-by-position-and-by-name
-->
