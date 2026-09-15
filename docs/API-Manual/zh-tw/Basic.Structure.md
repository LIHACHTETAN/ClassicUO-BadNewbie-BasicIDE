# Structure / New / fields

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: zh-tw -->

Structure 將 X、Y、Z 等具型別的欄位組成一個值。本引擎支援以值複製的資料結構，並非完整實作 VB.NET 的所有 Structure 功能。

## 完整語法

```text
[Public | Private] Structure TypeName
    [Public | Dim | VAR] field As FieldType
End Structure
Dim value As TypeName
Dim value = New TypeName()
copy = value
value.field = expression
Sub Change(ByRef value As TypeName)
Function Copy(ByVal value As TypeName) As TypeName
```

## 參數

- `TypeName / Public / Private` — 在檔案層級或 Module 內宣告唯一的簡單型別名稱。預設 Public。Private 僅能用於 Module 內，外部不能使用該型別名稱。模組的公開型別使用 ModuleName.TypeName。關鍵字與欄位名稱不翻譯。
- `field / FieldType` — 唯一欄位名稱、As，以及支援的純量型別、Enum 或其他 Structure。欄位為公開，可用 Public、Dim、VAR。型別包括 Integer/Long/Short/Byte、Single/Double/Decimal、String、Boolean/Bool、Object/Variant。整數別名均使用有號 32 位元。巢狀結構不可形成循環。
- `Dim / New` — Dim value As TypeName 與 New TypeName() 建立預設值，不呼叫使用者程式。New 必須使用空括號，不接收 X/Y/Z 參數；建立後再指定欄位。Dim copy = value 取得運算式的值。不加 UO. 前綴。
- `value.field / copy` — 用點號讀寫欄位，包括 route.Start.X。寫入會檢查欄位型別並替換包含它的值。copy = value 複製純量與巢狀結構值；修改 copy.X 不會改變 value.X。只能指派相容的結構型別。
- `ByVal / ByRef` — ByVal 傳入值的副本。ByRef 在進入時複製、離開時寫回呼叫端，也支援可寫入的欄位參數。請明確指定修飾詞；省略時沿用既有 Basic 規則。Return 可傳回結構，Function 可宣告 As TypeName。

## 傳回值

宣告與指派沒有結果（Unit）。New 與相應函式傳回結構值；執行觀察中以 Object 儲存，顯示內容包含宣告的型別名稱。座標是數量，不是 Boolean 旗標。結構比較 = 與 <> 傳回 1/True 或 0/False。範例的 String 結果為 "1445:1447:1690:0"、"10:15:24"、"2:4:2:2"。

## 行為

- 宣告在初始設定式執行前檢查。每個腳本最多 256 個結構型別，每個 1–256 個欄位，最多巢狀 32 層。重複或未知型別、循環與超出限制會產生 SC030。名稱繫結時檢查 Private 存取。
- 欄位預設值：整數/Enum 為 0，浮點為 0，Boolean 為 0/False，String 為空字串，Object/Variant 在指派前為 Unit。巢狀結構有自己的預設值。不支援在欄位宣告中初始化，請在建立後指派。
- 複製結構時，Object 與陣列欄位保留參考，因此兩份結構可能共用 List、Dictionary 或陣列。純量及巢狀值獨立變更；共用集合的內容修改會在兩份結構中反映。List 保存加入當時的結構值。
- = 比較同一宣告型別及其對應欄位，<> 為相反結果；參考欄位按身分比較。這是引擎擴充，並非所有 VB.NET 結構都支援 =。快取雜湊及已比較配對可避免重複展開共用的巢狀值。
- 支援公開具型別資料欄位、Module 可見性、New()、指派、參數及回傳值。不支援結構內方法、自訂建構函式、欄位初始化、屬性、繼承或私有欄位。不支援 WITH .field 與 array[index].field：先把元素讀入變數，修改後再寫回。宣告可放在 Include 檔案。

## 範例

### 1. 座標與獨立副本

```vb
# original.X=1445、Y=1690，Z 保持 0。copy 取得值後，copy.X += 2 只改變副本。New Position() 建立 Z=0 的 empty。四個欄位組成 1445:1447:1690:0。此腳本僅儲存座標，不移動角色。
Option Explicit On
Structure Position
    Public X As Integer
    Public Y As Integer
    Public Z As Integer
End Structure

Sub Main()
    Dim original As Position
    original.X = 1445
    original.Y = 1690
    Dim copy = original
    copy.X += 2
    Dim empty = New Position()
    Return CStr(original.X) & ":" & CStr(copy.X) & ":" & CStr(copy.Y) & ":" & CStr(empty.Z)
End Sub
```

**參數與執行說明:**

original.X=1445、Y=1690，Z 保持 0。copy 取得值後，copy.X += 2 只改變副本。New Position() 建立 Z=0 的 empty。四個欄位組成 1445:1447:1690:0。此腳本僅儲存座標，不移動角色。

### 2. 巢狀路線、ByVal 與 ByRef

```vb
# Route 的 Start、Finish 都是 Position。Shift(point ByVal, dx ByVal) 將 dx 加到副本的 X，傳回 Position。point:=route.Start、dx:=5 得到 shifted.X=15，而 Start.X 仍是 10。Advance(route ByRef, dx ByVal) 將 Finish.X 加 4，再寫回 Route，得到 24。Main 傳回 10:15:24；所有輔助程序都完整列出。
Option Explicit On
Structure Position
    Public X As Integer
    Public Y As Integer
End Structure
Structure Route
    Public Start As Position
    Public Finish As Position
End Structure

Function Shift(ByVal point As Position, ByVal dx As Integer) As Position
    point.X += dx
    Return point
End Function

Sub Advance(ByRef route As Route, ByVal dx As Integer)
    route.Finish.X += dx
End Sub

Sub Main()
    Dim route As Route
    route.Start.X = 10
    route.Finish.X = 20
    Dim shifted = Shift(point:=route.Start, dx:=5)
    Advance(route:=route, dx:=4)
    Return CStr(route.Start.X) & ":" & CStr(shifted.X) & ":" & CStr(route.Finish.X)
End Sub
```

**參數與執行說明:**

Route 的 Start、Finish 都是 Position。Shift(point ByVal, dx ByVal) 將 dx 加到副本的 X，傳回 Position。point:=route.Start、dx:=5 得到 shifted.X=15，而 Start.X 仍是 10。Advance(route ByRef, dx ByVal) 將 Finish.X 加 4，再寫回 Route，得到 24。Main 傳回 10:15:24；所有輔助程序都完整列出。

### 3. 保存的值與共用集合

```vb
# Entry 含值型欄位 Point 及 Object 欄位 Items。first.Point.X=2，Items 是含一個字串的 List()。snapshots.Add(first) 保存值。second=first 後設 second.Point.X=4，不改變已保存的 2。second.Items.Add("ingot") 修改共用 List，所以 first.Items.Count()=2。saved=snapshots[0] 是讀取元素欄位的支援方式。結果：2:4:2:2。
Option Explicit On
Structure Position
    Public X As Integer
End Structure
Structure Entry
    Public Point As Position
    Public Items As Object
End Structure

Sub Main()
    Dim first As Entry
    first.Point.X = 2
    first.Items = List()
    first.Items.Add("ore")
    Dim snapshots = List()
    snapshots.Add(first)

    Dim second = first
    second.Point.X = 4
    second.Items.Add("ingot")
    Dim saved = snapshots[0]
    Return CStr(first.Point.X) & ":" & CStr(second.Point.X) & ":" & CStr(saved.Point.X) & ":" & CStr(first.Items.Count())
End Sub
```

**參數與執行說明:**

Entry 含值型欄位 Point 及 Object 欄位 Items。first.Point.X=2，Items 是含一個字串的 List()。snapshots.Add(first) 保存值。second=first 後設 second.Point.X=4，不改變已保存的 2。second.Items.Add("ingot") 修改共用 List，所以 first.Items.Count()=2。saved=snapshots[0] 是讀取元素欄位的支援方式。結果：2:4:2:2。


### 內部函式：從呼叫到結果

Structure 將 X、Y、Z 等具型別的欄位組成一個值。本引擎支援以值複製的資料結構，並非完整實作 VB.NET 的所有 Structure 功能。

#### 1. Build / PrepareDefault

宣告在初始設定式執行前檢查。每個腳本最多 256 個結構型別，每個 1–256 個欄位，最多巢狀 32 層。重複或未知型別、循環與超出限制會產生 SC030。名稱繫結時檢查 Private 存取。

`declarations -> field types -> visibility -> cycle/depth checks -> immutable defaults`

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/StructureCatalog.cs`; 函式 `Build / PrepareDefault`.

#### 2. VisitNewStructure

Dim value As TypeName 與 New TypeName() 建立預設值，不呼叫使用者程式。New 必須使用空括號，不接收 X/Y/Z 參數；建立後再指定欄位。Dim copy = value 取得運算式的值。不加 UO. 前綴。

`resolve TypeName -> prepared default value; no procedure call`

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.cs`; 函式 `VisitNewStructure`.

#### 3. WithField / SetVar

用點號讀寫欄位，包括 route.Start.X。寫入會檢查欄位型別並替換包含它的值。copy = value 複製純量與巢狀結構值；修改 copy.X 不會改變 value.X。只能指派相容的結構型別。

`resolve path -> coerce field -> replace path -> assign new root value`

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/StructureObject.cs`; 函式 `WithField / SetVar`.

#### 4. CreateArgumentWriter

ByVal 傳入值的副本。ByRef 在進入時複製、離開時寫回呼叫端，也支援可寫入的欄位參數。請明確指定修飾詞；省略時沿用既有 Basic 規則。Return 可傳回結構，Function 可宣告 As TypeName。

`ByVal: value copy; ByRef: value copy -> callee -> caller slot write-back`

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.cs`; 函式 `CreateArgumentWriter`.

#### 5. ValueEquals

= 比較同一宣告型別及其對應欄位，<> 為相反結果；參考欄位按身分比較。這是引擎擴充，並非所有 VB.NET 結構都支援 =。快取雜湊及已比較配對可避免重複展開共用的巢狀值。

`type identity -> cached hash -> distinct field pairs; reference members keep identity`

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/StructureObject.cs`; 函式 `ValueEquals`.

宣告與指派沒有結果（Unit）。New 與相應函式傳回結構值；執行觀察中以 Object 儲存，顯示內容包含宣告的型別名稱。座標是數量，不是 Boolean 旗標。結構比較 = 與 <> 傳回 1/True 或 0/False。範例的 String 結果為 "1445:1447:1690:0"、"10:15:24"、"2:4:2:2"。

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: structureDeclaration / structureField / newStructure
Runtime/StructureCatalog.cs: Build / PrepareDefault
Runtime/ObjectTypes/StructureObject.cs: ReadField / WithField / ValueEquals
Runtime/BasicSyntaxPreprocessor.cs: NormalizeDim
Runtime/InjectionRuntime.cs: ScriptDeclarations / Load
Runtime/ScriptBindings.cs: Variable / CheckStructureType / CallName
Runtime/SemanticScope.cs: TryStructureRoot / SetVar / Coerce
Runtime/Interpreter.cs: VisitNewStructure / CreateArgumentWriter
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/structure-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/programming-guide/language-features/data-types/structure-variables
-->
