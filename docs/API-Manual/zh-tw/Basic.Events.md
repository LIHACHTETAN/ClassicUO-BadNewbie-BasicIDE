# Event / AddHandler / RemoveHandler / RaiseEvent

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: zh-tw -->

Event 宣告腳本事件。AddHandler 註冊 Sub，RemoveHandler 取消註冊，RaiseEvent 依註冊順序同步呼叫處理程序。

## 完整語法

```text
Event Changed(ByVal value As Integer)
Public Event Adjust(ByRef value As Integer)
Private Event Completed()
AddHandler EventName, AddressOf Handler
AddHandler Module.EventName, callback
RemoveHandler EventName, AddressOf Handler
RaiseEvent EventName(arguments)
```

## 參數

- `EventName / Public / Private` — 在檔案層級（腳本的隱含模組）或 Module 內、程序外宣告簡單名稱。預設為 Public；Private 必須位於 Module。外部以 Module.EventName 註冊。只有宣告事件的模組可執行 RaiseEvent，即使事件是 Public。名稱不得與程序或變數衝突。
- `Handler / callback` — Handler 必須是唯一的 Sub，可使用 AddressOf 或目前載入腳本的回呼變數／工廠函式。不可使用 Function、名稱字串、其他腳本的參考或多載群組。參數數量、型別及 ByVal/ByRef 模式必須完全相同。處理程序請明寫 ByVal，因為一般程序仍保留舊版預設 ByRef。
- `arguments / ByVal / ByRef` — RaiseEvent 必須按位置提供全部引數。不支援 Optional、ParamArray、預設值、具名事件引數或 Safe Call。Event 參數預設 ByVal：複製純量或參考，不複製物件內容。ByRef 變更會傳給後續處理程序，再寫回呼叫端可寫入的變數或索引元素。引數及索引依書寫順序各求值一次。

## 傳回值

Event、AddHandler、RemoveHandler、RaiseEvent 不回傳值（Unit），不是 Boolean、ID 或訂閱數量。使用 ByRef 或 Module 共用狀態傳回結果。三個範例的 Main 分別回傳 String "ready"、Integer 8、String "ABAC:handler failed"。

## 行為

- 每個直譯器各自保存訂閱，其他腳本及重新載入後不會繼承。同一已載入直譯器的後續入口呼叫會保留訂閱，直到取消或釋放直譯器。關閉 IDE 會保留執行中的腳本及訂閱，但不會建立獨立背景事件服務。
- AddHandler 附加於尾端；重複註冊會重複呼叫同一 Sub。RemoveHandler 刪除最後一個相符 Sub，沒有相符項目則不變。引擎先檢查宣告、存取及簽章，再求值引數並固定有序處理程序清單。處理中修改訂閱只影響下一次 RaiseEvent。
- 處理程序出錯會停止本次其餘呼叫，錯誤傳至呼叫端 Catch/Finally；已發生的 ByRef 變更仍寫回。暫停及緊急停止在處理程序內同樣有效，Catch 不會吞掉緊急停止。不建立新執行緒；阻塞的原生呼叫仍受其自身取消限制。
- 限制：每個事件 4096 個訂閱、16 層 RaiseEvent、32 層腳本程序框架。事件循環或過深遞迴產生可攔截的腳本錯誤，不讓用戶端堆疊溢位；深度處理請用迴圈。共用純量放在 Module 欄位；舊版檔案層級純量仍以複本繼承。
- 腳本宣告的事件仍需明確 RaiseEvent。自動日誌、資源與連線訂閱使用 Basic.GameEvents 說明的客戶端 UO. 事件。仍不支援 Handles、WithEvents、Custom Event、事件委派型別及類別事件。

## 範例

### 1. 註冊與取消

```vb
# Feed.Message 以 ByVal 傳遞 text As String。完整顯示的 Feed.Publish 觸發事件，Record 加入共用 State.log。handler 註冊 Record，發送 "ready" 後保存文字。不同位置的 AddressOf Record 仍能由 RemoveHandler 找到同一 Sub。取消後 "ignored" 不會加入；Main 回傳 "ready"。
Option Explicit On
Module Feed
    Public Event Message(ByVal text As String)
    Public Sub Publish(ByVal text As String)
        RaiseEvent Message(text)
    End Sub
End Module

Module State
    Public Dim log As String = ""
End Module

Sub Record(ByVal text As String)
    State.log = State.log & text
End Sub

Sub Main()
    Dim handler = AddressOf Record
    AddHandler Feed.Message, handler
    Feed.Publish("ready")
    RemoveHandler Feed.Message, AddressOf Record
    Feed.Publish("ignored")
    Return State.log
End Sub
```

**參數與執行說明:**

Feed.Message 以 ByVal 傳遞 text As String。完整顯示的 Feed.Publish 觸發事件，Record 加入共用 State.log。handler 註冊 Record，發送 "ready" 後保存文字。不同位置的 AddressOf Record 仍能由 RemoveHandler 找到同一 Sub。取消後 "ignored" 不會加入；Main 回傳 "ready"。

### 2. 依序修改數值

```vb
# Adjust 及兩個 Sub 都宣告 total As Integer ByRef。Increment 將 3 改為 4；DoubleValue 收到 4 並改為 8。RaiseEvent 將 8 寫回 Main，接著取消兩個訂閱。Integer 8 是數量，不是 True/False；RaiseEvent 本身無回傳值。
Option Explicit On
Event Adjust(ByRef total As Integer)

Sub Increment(ByRef total As Integer)
    total += 1
End Sub

Sub DoubleValue(ByRef total As Integer)
    total *= 2
End Sub

Sub Main()
    Dim total As Integer = 3
    AddHandler Adjust, AddressOf Increment
    AddHandler Adjust, AddressOf DoubleValue
    RaiseEvent Adjust(total)
    RemoveHandler Adjust, AddressOf Increment
    RemoveHandler Adjust, AddressOf DoubleValue
    Return total
End Sub
```

**參數與執行說明:**

Adjust 及兩個 Sub 都宣告 total As Integer ByRef。Increment 將 3 改為 4；DoubleValue 收到 4 並改為 8。RaiseEvent 將 8 寫回 Main，接著取消兩個訂閱。Integer 8 是數量，不是 True/False；RaiseEvent 本身無回傳值。

### 3. 處理錯誤並繼續

```vb
# Ready 沒有參數。First 加入 A，Failing 加入 B 並拋錯，所以這次跳過 Last。Catch 保存訊息，Finally 取消 Failing；下一次呼叫加入 AC。Main 回傳 "ABAC:handler failed"。全部處理程序及 State 模組均完整列出。
Option Explicit On
Event Ready()
Module State
    Public Dim log As String = ""
End Module

Sub First()
    State.log = State.log & "A"
End Sub

Sub Failing()
    State.log = State.log & "B"
    Throw "handler failed"
End Sub

Sub Last()
    State.log = State.log & "C"
End Sub

Sub Main()
    Dim message As String = ""
    AddHandler Ready, AddressOf First
    AddHandler Ready, AddressOf Failing
    AddHandler Ready, AddressOf Last
    Try
        RaiseEvent Ready()
    Catch problem
        message = problem
    Finally
        RemoveHandler Ready, AddressOf Failing
    End Try
    RaiseEvent Ready()
    Return State.log & ":" & message
End Sub
```

**參數與執行說明:**

Ready 沒有參數。First 加入 A，Failing 加入 B 並拋錯，所以這次跳過 Last。Catch 保存訊息，Finally 取消 Failing；下一次呼叫加入 AC。Main 回傳 "ABAC:handler failed"。全部處理程序及 State 模組均完整列出。

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: eventDeclaration / eventHandler / raiseEvent
Runtime/EventCatalog.cs: Build / TryResolve / HandlerError
Analysis/EventValidator.cs: ValidateHandler / ValidateRaise / ValidateNativeNames
Runtime/Interpreter.Events.cs: VisitEventHandler / VisitRaiseEvent
Runtime/Interpreter.cs: CallSubrutine / ExecuteSubrutine / ByRef copy-back
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/event-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/addhandler-statement
-->
