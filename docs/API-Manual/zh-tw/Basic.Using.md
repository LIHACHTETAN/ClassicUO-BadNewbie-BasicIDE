# Using / End Using

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: zh-tw -->

Using 會在離開區塊時關閉原生資源。目前支援既有變數，或傳回資源的運算式。

## 完整語法

```text
Dim resource = MemoryStream()
Using resource
    statements
End Using
Using resourceExpression
    statements
End Using
```

## 參數

- `resourceExpression` — 進入時只計算一次。可使用 File(path)、MemoryStream() 與 CreateTimer(...)。釋放計時器會永久停止它，請參閱 Basic.Timers。String、數字、List、Dictionary 會在執行區塊前引發含來源行號的錯誤。請先宣告變數；不支援標頭內宣告、As New、逗號資源清單及使用者 Dispose 方法。
- `statements / End Using` — End Using 關閉已擷取的物件。變數仍可存取，但資源已關閉。多個資源請使用巢狀區塊。重新指派變數不會改變最後要關閉的原始物件。

## 傳回值

此陳述式沒有傳回值。區塊內的 Return 會先釋放資源再離開程序。範例 IsClosed 是自訂函式，回傳 1/True 或 0/False；Main 的最終結果是字串，不是成功旗標。

## 行為

- File(path) 建立包裝物件；在區塊內呼叫 Create() 寫入，或 Open() 讀取。Dispose 呼叫 Close()、清空緩衝區並釋放控制代碼。MemoryStream 關閉後，Length() 會出錯。範例只使用記憶體，不建立檔案。
- 編譯器建立受保護區域；直譯器在目前呼叫中保存物件。End Using、Return、Exit、Continue 或跳出會由內而外關閉資源。跳入區塊會在執行前遭拒絕。
- 一般錯誤會在外層 Catch 前關閉資源。失敗的 Dispose 不會重試，外層資源仍會釋放。緊急停止略過腳本 Catch/Finally，仍關閉原生資源；關閉錯誤不取代取消。暫停會保留資源直到繼續或停止。這不建立執行緒，也不能強制中斷作業系統阻塞中的關閉操作。
- 若需處理錯誤並保持資源開啟，請將 Try/Catch 放在 Using 內。On Error Resume Next 遇到未處理的本體錯誤時會關閉資源，從整個區塊之後繼續。On Error GoTo 不得指向 Using 內的標籤，以免重新進入已關閉的保護區域。
- 錯誤離開 Using 後，外部 On Error GoTo 處理常式的 Resume 會從標頭重新執行整個區塊，再次計算資源運算式；Resume Next 則接續 End Using 後的第一行。若變數仍指向已關閉的物件，重新進入不會重新開啟它；重試時應使用會取得新資源的運算式。先前執行過的操作可能重複。

## 範例

### 1. 關閉記憶體串流

```vb
# stream 是資源；size 在開啟時讀得 Length()=0。End Using 後，IsClosed 擷取錯誤並回傳 True=1，Main 回傳 "0:1"。ByVal 複製參考而非串流。此教學函式將任何 Length 錯誤視為關閉，只適用於這些串流。
Option Explicit On
Function IsClosed(ByVal stream) As Boolean
    Try
        Dim size = stream.Length()
        Return False
    Catch closed
        Return True
    End Try
End Function

Sub Main()
    Dim stream = MemoryStream()
    Dim size = -1
    Using stream
        size = stream.Length()
    End Using
    Return CStr(size) & ":" & CStr(IsClosed(stream))
End Sub
```

**參數與執行說明:**

stream 是資源；size 在開啟時讀得 Length()=0。End Using 後，IsClosed 擷取錯誤並回傳 True=1，Main 回傳 "0:1"。ByVal 複製參考而非串流。此教學函式將任何 Length 錯誤視為關閉，只適用於這些串流。

### 2. 從輔助函式返回

```vb
# ReadLength(stream) 算出 Integer 0。Return 在 Main 收到 size 前關閉串流。之後 Length 出錯，使 closed=True，結果為 "0:1"。若呼叫端仍需要開啟的資源，就不要傳入此函式。
Option Explicit On
Function ReadLength(ByVal stream) As Integer
    Using stream
        Return stream.Length()
    End Using
End Function

Sub Main()
    Dim stream = MemoryStream()
    Dim size = ReadLength(stream)
    Dim closed = False
    Try
        Dim after = stream.Length()
    Catch problem
        closed = True
    End Try
    Return CStr(size) & ":" & CStr(closed)
End Sub
```

**參數與執行說明:**

ReadLength(stream) 算出 Integer 0。Return 在 Main 收到 size 前關閉串流。之後 Length 出錯，使 closed=True，結果為 "0:1"。若呼叫端仍需要開啟的資源，就不要傳入此函式。

### 3. 錯誤時巢狀釋放

```vb
# outer 與 inner 是不同串流。Throw "demo" 先關閉 inner，再關閉 outer。Catch 保存原始訊息；兩次 IsClosed 各回傳 1，Main 結果為 "demo:2"。2 是關閉物件數量，並非 Boolean。
Option Explicit On
Function IsClosed(ByVal stream) As Boolean
    Try
        Dim size = stream.Length()
        Return False
    Catch closed
        Return True
    End Try
End Function

Sub Main()
    Dim outer = MemoryStream()
    Dim inner = MemoryStream()
    Dim message = ""
    Try
        Using outer
            Using inner
                Throw "demo"
            End Using
        End Using
    Catch problem
        message = problem
    End Try
    Return message & ":" & CStr(IsClosed(outer) + IsClosed(inner))
End Sub
```

**參數與執行說明:**

outer 與 inner 是不同串流。Throw "demo" 先關閉 inner，再關閉 outer。Catch 保存原始訊息；兩次 IsClosed 各回傳 1，Main 結果為 "demo:2"。2 是關閉物件數量，並非 Boolean。

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: usingStatement / USING / END_USING
Runtime/Instructions/Generator.cs: Generate(UsingStatementContext)
Runtime/Interpreter.cs: TryExecutionScope.DisposeResource / Transfer / DeferReturn / CallSubrutine
Runtime/ObjectTypes/FileObject.cs: Dispose / Close
Runtime/ObjectTypes/MemoryStreamObject.cs: Dispose
Analysis/TryStructureValidator.cs: Regions
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/using-statement
-->
