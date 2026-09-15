# AddressOf / callbacks

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: zh-tw -->

AddressOf 取得指令碼 Sub 或 Function 的參照，不會立即呼叫。可將參照傳入其他程序、從函式傳回或放進集合，以選擇自己的處理規則。

## 完整語法

```text
Dim callback = AddressOf ProcedureName
Dim callback As Object = AddressOf Tools.FunctionName
callback(arguments)
callback.Invoke(arguments)
Process(values, AddressOf Predicate)
```

## 參數

- `ProcedureName` — 已宣告的程序名稱，可加上 Module 名稱。必須只有一個符合的宣告。不存在、無權存取的 Private 或多載名稱會在執行前被拒絕。Basic 內建函式或 UO 指令請先寫成名稱唯一的指令碼包裝函式，再取其 AddressOf。名稱後面不加括號。
- `callback / arguments` — callback 是 Object。callback(...) 與 callback.Invoke(...) 在目前指令碼執行緒同步呼叫目標。具名引數必須使用實際參數名稱。集合元素先存入變數再呼叫。參照會在引數求值前固定，即使引數會改寫 callback 也不影響這一次呼叫。
- `ByRef / ByVal / Optional / ParamArray` — ByVal 複製值或參照；ByRef 將修改寫回；Optional 計算省略的預設值；ParamArray 收集位置引數。具名引數放在位置引數之後；ParamArray 值只能用純位置呼叫。參數名稱或數量錯誤會在引數副作用前報錯。

## 傳回值

AddressOf 傳回 Object 參照，不是 ID、記憶體位址、Boolean 或函式結果。呼叫 Function 取得其結果；Sub 若沒有 Return 運算式則無回傳值（Unit）。IsPositive 傳回 1/True 或 0/False。範例 1、3 的 Main 傳回 String，範例 2 傳回 Integer 15。

## 行為

- 參照不會擷取建立它的函式之區域變數，不是 lambda 或閉包。它屬於目前載入的指令碼；其他執行個體或重新載入後不能呼叫舊參照。Public 工廠函式可以刻意傳回自己 Private 輔助函式的參照。
- 準備階段檢查名稱與存取權。直譯器為每個 AddressOf 位置快取不可變參照；每次呼叫讀取目前變數、檢查簽章、按書寫順序各求值一次，再進入一般程序框架。ByRef 寫回與例外處理和直接呼叫相同。
- 不會建立執行緒或計時器。暫停與取消使用一般指令碼檢查點，也涵蓋回呼內的迴圈。錯誤交由呼叫者的 Catch/Finally 處理；Catch 不會吞掉緊急停止。阻塞的原生呼叫仍有自身取消限制。
- 此功能不包含 Delegate 型別宣告、lambda、DLL 函式指標或多載程序參照。AddressOf 不加 UO.；包裝函式中的遊戲指令仍使用 UO.。

## 範例

### 1. 用述詞篩選集合

```vb
# values 是輸入 List；predicate 是 AddressOf IsPositive。FilterValues 對每個數字呼叫一次 predicate(number)。IsPositive 只接受正數，留下 4、7；selected.Count()=2，selected[0]=4，因此 Main 傳回 "2:4"。兩個輔助函式已完整列在指令碼內，不是額外 API 指令。
Option Explicit On
Function IsPositive(ByVal number) As Boolean
    Return number > 0
End Function

Function FilterValues(ByVal values, ByVal predicate)
    Dim result = List()
    For Each number In values
        If predicate(number) Then
            result.Add(number)
        End If
    Next
    Return result
End Function

Sub Main()
    Dim numbers = List()
    numbers.Add(-2)
    numbers.Add(4)
    numbers.Add(7)
    Dim selected = FilterValues(numbers, AddressOf IsPositive)
    Return CStr(selected.Count()) & ":" & CStr(selected[0])
End Sub
```

**參數與執行說明:**

values 是輸入 List；predicate 是 AddressOf IsPositive。FilterValues 對每個數字呼叫一次 predicate(number)。IsPositive 只接受正數，留下 4、7；selected.Count()=2，selected[0]=4，因此 Main 傳回 "2:4"。兩個輔助函式已完整列在指令碼內，不是額外 API 指令。

### 2. 修改呼叫者的變數

```vb
# AddAmount 的 total 使用 ByRef；amount 使用 ByVal，預設 1。update(total) 把 10 改成 11；Invoke(amount:=4, total:=total) 按名稱綁定後把 11 改成 15。ByRef 寫回原始變數。Sub 不傳回值；Main 傳回 Integer 15，不是 Boolean。
Option Explicit On
Sub AddAmount(ByRef total As Integer, Optional ByVal amount = 1)
    total += amount
End Sub

Sub Main()
    Dim update = AddressOf AddAmount
    Dim total = 10
    update(total)
    update.Invoke(amount:=4, total:=total)
    Return total
End Sub
```

**參數與執行說明:**

AddAmount 的 total 使用 ByRef；amount 使用 ByVal，預設 1。update(total) 把 10 改成 11；Invoke(amount:=4, total:=total) 按名稱綁定後把 11 改成 15。ByRef 寫回原始變數。Sub 不傳回值；Main 傳回 Integer 15，不是 Boolean。

### 3. 傳回私有規則並處理錯誤

```vb
# Rules.Create 傳回 Private CheckedDouble 參照；外部不能直接使用 AddressOf Rules.CheckedDouble。operation(6) 得到 12；operation(-1) 在賦值前拋出 "negative"，result 因而仍為 12。Catch 接收文字，Finally 加上 ":done"；Main 傳回 "12:negative:done"。關閉 IDE 本身不會停止執行中的指令碼。
Option Explicit On
Module Rules
    Private Function CheckedDouble(ByVal number) As Integer
        If number < 0 Then
            Throw "negative"
        End If
        Return number * 2
    End Function

    Public Function Create()
        Return AddressOf CheckedDouble
    End Function
End Module

Sub Main()
    Dim operation = Rules.Create()
    Dim result = operation(6)
    Dim message = ""
    Try
        result = operation(-1)
    Catch problem
        message = problem
    Finally
        message = message & ":done"
    End Try
    Return CStr(result) & ":" & message
End Sub
```

**參數與執行說明:**

Rules.Create 傳回 Private CheckedDouble 參照；外部不能直接使用 AddressOf Rules.CheckedDouble。operation(6) 得到 12；operation(-1) 在賦值前拋出 "negative"，result 因而仍為 12。Catch 接收文字，Finally 加上 ":done"；Main 傳回 "12:negative:done"。關閉 IDE 本身不會停止執行中的指令碼。

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: addressOf / ADDRESSOF
Runtime/Metadata.cs: TryGetCallbackTarget
Analysis/InvalidSymbolVisitor.cs: VisitAddressOf
Runtime/Interpreter.Callbacks.cs: VisitAddressOf / TryGetCallback / CallCallback
Runtime/Interpreter.cs: CreateArgumentWriter / CallSubrutine
Runtime/NamedArgumentBinding.cs: TryCreate
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/operators/addressof-operator
-->
