# Class / New / Me / Property

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: zh-tw -->

Class 將各物件的狀態與指令碼方法放在一起。New 建立參考物件；指定給另一個變數仍指向同一物件，與 Structure 的值複製不同。範例包含所有使用的建構函式、方法及屬性存取程序。

## 完整語法

```text
[Public | Private] Class TypeName
    [Public | Private | Dim] field As FieldType
    Public Sub New([parameters]) ... End Sub
    [Public | Private] Sub Method([parameters]) ... End Sub
    [Public | Private] Function Method([parameters]) As ResultType ... End Function
    [Public | Private] [ReadOnly | WriteOnly] Property Name[()] As ValueType
        Get ... Return value / Name = value / Exit Property ... End Get
        Set(ByVal value As ValueType) ... End Set
    End Property
    Public Property AutoName As ValueType
End Class
Dim instance [As TypeName] = New TypeName(arguments)
instance.Property = expression
value = instance.Property
instance.Method(arguments)
With instance ... End With
```

## 參數

- `TypeName / Public / Private` — TypeName 是檔案或 Module 層級的唯一簡單名稱；模組外使用 ModuleName.TypeName。Class 預設 Public，Private Class 僅供自己的 Module 使用。尚未實作繼承、介面、泛型、巢狀類別、Shared、多載、解構函式及執行個體 Event 宣告。
- `field As FieldType / Me` — 欄位必須指定 As Integer、Double、Boolean、String、Object 或已宣告的 Enum/Structure/Class，也支援現有 Basic 型別別名。欄位預設 Private，外部存取須明確指定 Public。初值：數字/Boolean 為 0、String 為空、Structure 為零值欄位、Object/Class 為 Nothing(Unit)。其他初始化請在 Sub New 進行。Me 代表目前執行個體，不可重新宣告或指定；參數及區域變數可遮蔽其他成員名稱。
- `New / Sub New` — New TypeName(arguments) 建立獨立欄位並執行一次 Public Sub New。沒有建構函式時僅允許 New TypeName()。支援一個建構函式，依一般 Optional、預設值與具名引數規則運作。引數依書寫順序各計算一次；失敗時不傳回建構完成的物件。僅宣告 As TypeName 的變數仍為 Nothing。
- `Sub / Function / arguments` — Sub/Function 以 instance.Method(...) 呼叫；類別內也可用 Method(...)/Me.Method(...)。Private 只允許同一 Class 的程式碼存取，包括同型別的另一物件。支援型別、ByVal/ByRef、Optional、ParamArray 與具名引數，但不支援具名 ParamArray 元素。Function 傳回宣告型別，Sub 為 Unit。TypeName.Method(...) 與 instance.New(...) 無效；對執行個體方法使用 AddressOf 須透過檔案/模組層級的包裝程序。
- `Property / Get / Set` — Property Name[()] As ValueType 不支援索引參數。讀取時用 instance.Name，不加呼叫括號。Get 以 Return 或指定給 Name 傳回；Exit Property 傳回該結果或預設值。指定值會呼叫 Set(ByVal value As ValueType)，不讀取最後的 Get。一般屬性必須各有一個 Get 與 Set。存取層級設定在 Property；Set 須明確宣告一個相同型別的 ByVal 參數。
- `ReadOnly / WriteOnly / auto Property` — 含程序內容的 ReadOnly 只有 Get，WriteOnly 只有 Set；禁止的存取會產生可攔截錯誤。自動屬性不含 Get/Set 或 End Property，直接儲存值。自動 ReadOnly 只能在該執行個體的 Sub New 指定；沒有 Set 的 WriteOnly 無效。ReadOnly 若傳回 Class 參考，仍可修改該物件可變的成員。
- `ByVal / ByRef / With` — ByVal 複製參考：修改成員會影響原物件，替換參數本身不會替換呼叫端變數。ByRef 依引擎 copy-in/copy-out 規則寫回，也包含替換後的新參考。相等比較檢查物件身分。With instance 一次擷取物件，支援欄位、屬性及方法。Class 不會自動實作 IDisposable；Using 請用於支援的資源物件。

## 傳回值

New 傳回包含 Class 參考的 Object，不是 UO ID 或圖形。Get/Function 傳回宣告型別；Set、Sub、宣告為 Unit。沒有 New 則為 Nothing。參考相等與 As Boolean 使用 1/True 或 0/False；Integer 數量不是自動成功旗標。Main 結果為 "5:2:1"、"1:0:6"、"ore:1:replacement:0"。

## 行為

- SC032 會在執行前拒絕無效宣告，即使未使用 Option Explicit。限制：256 個類別，每類別 256 個欄位/屬性與 256 個方法；包含 New/Get/Set 的呼叫深度為 32。指定值/ByRef 路徑最多 64 個部分。允許循環參考；中繼資料與預設值預先準備，每次 New 各有獨立可變儲存空間。
- 接收物件路徑在右側運算式/引數的副作用之前擷取，路徑中的每個 Get 僅執行一次。即使程序替換了中間變數，寫回仍指向原始目標。值會轉成宣告型別。建構函式、方法及存取程序的錯誤可由 Try/Catch 處理，但已完成的變更不會回復。
- 暫停、停止、來源行號與深度保護使用一般指令碼框架。只關閉 IDE 不會停止指令碼。檢查器顯示型別/成員數，不執行 Get 或追蹤循環。Watch 可讀儲存欄位/自動屬性，不可執行自訂 Get、方法或建構函式。這是已說明的 Basic 功能範圍，不代表任意 .NET 類別。

## 範例

### 1. 獨立物件與共用參考

```vb
# New Counter(label:="ore", start:=2) 傳入 String label 及 Integer start，設定 Label/stored。second 有獨立欄位，alias=first 複製參考。Add(amount:=3) 透過 Value.Set 檢查負值並儲存，再以 Value.Get 傳回 Integer。first 為 5，second 為 2，alias=first 為 1/True。所有輔助方法完整列出。
Option Explicit On
Class Counter
    Private stored As Integer
    Public Property Label As String
    Public Sub New(ByVal label As String, ByVal start As Integer)
        Me.Label = label
        stored = start
    End Sub
    Public Property Value As Integer
        Get
            Return stored
        End Get
        Set(ByVal value As Integer)
            If value < 0 Then
                Throw "Value must be non-negative"
            End If
            stored = value
        End Set
    End Property
    Public Function Add(ByVal amount As Integer) As Integer
        Me.Value = stored + amount
        Return Me.Value
    End Function
End Class

Sub Main()
    Dim first = New Counter(label:="ore", start:=2)
    Dim second = New Counter("wood", 2)
    Dim alias = first
    alias.Add(amount:=3)
    Return CStr(first.Value) & ":" & CStr(second.Value) & ":" & CStr(alias = first)
End Sub
```

**參數與執行說明:**

New Counter(label:="ore", start:=2) 傳入 String label 及 Integer start，設定 Label/stored。second 有獨立欄位，alias=first 複製參考。Add(amount:=3) 透過 Value.Set 檢查負值並儲存，再以 Value.Get 傳回 Integer。first 為 5，second 為 2，alias=first 為 1/True。所有輔助方法完整列出。

### 2. 讀取、寫入與 Boolean

```vb
# Limit=10 以 value=10 呼叫 Set。Remaining.Get 指定結果名稱再以 Exit Property 離開。TrySpend(cost:=4) 扣除四並傳回 1/True；cost=9 超過剩下的六，傳回 0/False。Limit=-3 在儲存前擲出錯誤，Catch 讀到 Remaining=6。Main 為 "1:0:6"，不執行伺服器操作。
Option Explicit On
Class Budget
    Private amount As Integer
    Public ReadOnly Property Remaining() As Integer
        Get
            Remaining = amount
            Exit Property
        End Get
    End Property
    Public WriteOnly Property Limit As Integer
        Set(ByVal value As Integer)
            If value < 0 Then
                Throw "Limit must be non-negative"
            End If
            amount = value
        End Set
    End Property
    Public Function TrySpend(ByVal cost As Integer) As Boolean
        If cost < 0 Then
            Throw "cost must be non-negative"
        End If
        If cost > amount Then
            Return False
        End If
        amount -= cost
        Return True
    End Function
End Class

Sub Main()
    Dim budget = New Budget()
    budget.Limit = 10
    Dim paid = budget.TrySpend(4)
    Dim refused = budget.TrySpend(9)
    Try
        budget.Limit = -3
    Catch problem
        Return CStr(paid) & ":" & CStr(refused) & ":" & CStr(budget.Remaining)
    End Try
    Return "unexpected"
End Sub
```

**參數與執行說明:**

Limit=10 以 value=10 呼叫 Set。Remaining.Get 指定結果名稱再以 Exit Property 離開。TrySpend(cost:=4) 扣除四並傳回 1/True；cost=9 超過剩下的六，傳回 0/False。Limit=-3 在儲存前擲出錯誤，Catch 讀到 Remaining=6。Main 為 "1:0:6"，不執行伺服器操作。

### 3. Module、ByVal 與 ByRef 替換

```vb
# Jobs.WorkItem(name) 儲存 String Name，Done 初始為 0。Tick(ByVal job) 將共用 Done 增為 1，接著替換成 "local" 只改變區域參數。Replace(ByRef job, ByVal name) 建立 "replacement" 並寫回呼叫端參考；具名引數特意反序書寫。original 仍為 "ore"/1，job 是新的 "replacement"/0。已列出完整 Module Jobs。
Option Explicit On
Module Jobs
    Public Class WorkItem
        Public Property Name As String
        Public Done As Integer
        Public Sub New(ByVal name As String)
            Me.Name = name
        End Sub
    End Class
    Public Sub Tick(ByVal job As WorkItem)
        job.Done += 1
        job = New WorkItem("local")
    End Sub
    Public Sub Replace(ByRef job As WorkItem, ByVal name As String)
        job = New WorkItem(name)
    End Sub
End Module

Sub Main()
    Dim job As Jobs.WorkItem = New Jobs.WorkItem("ore")
    Dim original = job
    Jobs.Tick(job)
    Jobs.Replace(name:="replacement", job:=job)
    Return original.Name & ":" & CStr(original.Done) & ":" & job.Name & ":" & CStr(job.Done)
End Sub
```

**參數與執行說明:**

Jobs.WorkItem(name) 儲存 String Name，Done 初始為 0。Tick(ByVal job) 將共用 Done 增為 1，接著替換成 "local" 只改變區域參數。Replace(ByRef job, ByVal name) 建立 "replacement" 並寫回呼叫端參考；具名引數特意反序書寫。original 仍為 "ore"/1，job 是新的 "replacement"/0。已列出完整 Module Jobs。


### 內部函式：從呼叫到結果

Class 將各物件的狀態與指令碼方法放在一起。New 建立參考物件；指定給另一個變數仍指向同一物件，與 Structure 的值複製不同。範例包含所有使用的建構函式、方法及屬性存取程序。

#### 1. ClassCatalog.Build / Complete

SC032 會在執行前拒絕無效宣告，即使未使用 Option Explicit。限制：256 個類別，每類別 256 個欄位/屬性與 256 個方法；包含 New/Get/Set 的呼叫深度為 32。指定值/ByRef 路徑最多 64 個部分。允許循環參考；中繼資料與預設值預先準備，每次 New 各有獨立可變儲存空間。

`declarations -> unique typed members -> accessor validation -> prepared metadata; SC032 on invalid Class`

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/ClassCatalog.cs`; 函式 `ClassCatalog.Build / Complete`.

#### 2. ConstructClass

New TypeName(arguments) 建立獨立欄位並執行一次 Public Sub New。沒有建構函式時僅允許 New TypeName()。支援一個建構函式，依一般 Optional、預設值與具名引數規則運作。引數依書寫順序各計算一次；失敗時不傳回建構完成的物件。僅宣告 As TypeName 的變數仍為 Nothing。

`new instance -> independent field slots -> bind constructor arguments -> Sub New -> Object reference`

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Classes.cs`; 函式 `ConstructClass`.

#### 3. ClassObject.Member / Read

Property Name[()] As ValueType 不支援索引參數。讀取時用 instance.Name，不加呼叫括號。Get 以 Return 或指定給 Name 傳回；Exit Property 傳回該結果或預設值。指定值會呼叫 Set(ByVal value As ValueType)，不讀取最後的 Get。一般屬性必須各有一個 Get 與 Set。存取層級設定在 Property；Set 須明確宣告一個相同型別的 ByVal 參數。

`check member visibility -> stored value OR Get frame -> declared value type`

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ClassObject.cs`; 函式 `ClassObject.Member / Read`.

#### 4. MemberAccess.Resolve / ClassObject.Write

接收物件路徑在右側運算式/引數的副作用之前擷取，路徑中的每個 Get 僅執行一次。即使程序替換了中間變數，寫回仍指向原始目標。值會轉成宣告型別。建構函式、方法及存取程序的錯誤可由 Try/Catch 處理，但已完成的變更不會回復。

`capture receiver once -> evaluate RHS/arguments -> coerce value -> Set OR stored slot`

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/MemberAccess.cs`; 函式 `MemberAccess.Resolve / ClassObject.Write`.

#### 5. CallClassMethod / CallSubrutine

Sub/Function 以 instance.Method(...) 呼叫；類別內也可用 Method(...)/Me.Method(...)。Private 只允許同一 Class 的程式碼存取，包括同型別的另一物件。支援型別、ByVal/ByRef、Optional、ParamArray 與具名引數，但不支援具名 ParamArray 元素。Function 傳回宣告型別，Sub 為 Unit。TypeName.Method(...) 與 instance.New(...) 無效；對執行個體方法使用 AddressOf 須透過檔案/模組層級的包裝程序。

`check method visibility -> bind named/positional arguments -> Me frame -> return -> ByRef copy-out`

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Classes.cs`; 函式 `CallClassMethod / CallSubrutine`.

#### 6. ClassObject.DisplayValue

暫停、停止、來源行號與深度保護使用一般指令碼框架。只關閉 IDE 不會停止指令碼。檢查器顯示型別/成員數，不執行 Get 或追蹤循環。Watch 可讀儲存欄位/自動屬性，不可執行自訂 Get、方法或建構函式。這是已說明的 Basic 功能範圍，不代表任意 .NET 類別。

`debugger: type + member count; no getter calls and no traversal of reference cycles`

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ClassObject.cs`; 函式 `ClassObject.DisplayValue`.

New 傳回包含 Class 參考的 Object，不是 UO ID 或圖形。Get/Function 傳回宣告型別；Set、Sub、宣告為 Unit。沒有 New 則為 Nothing。參考相等與 As Boolean 使用 1/True 或 0/False；Integer 數量不是自動成功旗標。Main 結果為 "5:2:1"、"1:0:6"、"ore:1:replacement:0"。

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: classDeclaration / classProperty / subrutine / newStructure
Runtime/ClassCatalog.cs: Build / Complete
Runtime/ObjectTypes/ClassObject.cs: Member / Read / Write
Runtime/Interpreter.Classes.cs: ConstructClass / CallClassMethod / InvokeAccessor
Runtime/MemberAccess.cs: Resolve / Read / Write
Runtime/SemanticScope.cs: TryMemberSlot / Coerce
Runtime/Interpreter.cs: CallSubrutine / CreateArgumentWriter
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/class-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/property-statement
-->
