# Class / New / Me / Property

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ja -->

Class は各オブジェクトの状態とスクリプトのメソッドをまとめます。New が作るのは参照オブジェクトです。別の変数への代入は同じオブジェクトを参照し、Structure の値コピーとは異なります。使用するコンストラクター、メソッド、プロパティの全コードを例に示します。

## 正確な構文

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

## パラメーター

- `TypeName / Public / Private` — TypeName はファイルまたは Module レベルの一意な単純名です。モジュール外では ModuleName.TypeName を使います。Class の既定は Public、Private Class は同じ Module 内専用です。継承、インターフェイス、ジェネリック、入れ子クラス、Shared、オーバーロード、デストラクター、インスタンス Event 宣言は未実装です。
- `field As FieldType / Me` — フィールドには As Integer、Double、Boolean、String、Object、宣言済み Enum/Structure/Class の型を指定します。既存の Basic 型別名も有効です。フィールドの既定は Private、外部公開には Public が必要です。初期値は数値/Boolean が 0、String が空、Structure がゼロ値、Object/Class が Nothing (Unit) です。他の初期化は Sub New で行います。Me は現在のインスタンスで再宣言・再代入できません。引数やローカル変数は他のメンバー名を隠せます。
- `New / Sub New` — New TypeName(arguments) は独立したフィールドを作り、Public Sub New を一度実行します。コンストラクターがなければ New TypeName() のみ有効です。コンストラクターは一つで、通常の Optional、既定引数、名前付き引数の規則を使えます。引数は記述順に一度評価され、失敗時には構築済みオブジェクトを返しません。As TypeName だけの変数は Nothing のままです。
- `Sub / Function / arguments` — Sub/Function は instance.Method(...)、クラス内では Method(...) または Me.Method(...) で呼びます。Private は同じ Class のコードからのみ呼べ、同型の別インスタンスにも適用されます。型、ByVal/ByRef、Optional、ParamArray、名前付き引数を利用できますが、ParamArray 要素の名前付き指定は不可です。Function は宣言型、Sub は Unit を返します。TypeName.Method(...) と instance.New(...) は無効です。インスタンスメソッドの AddressOf にはファイル/モジュールのラッパー手続きが必要です。
- `Property / Get / Set` — Property Name[()] As ValueType はインデックス引数を持ちません。読み取りは呼び出し括弧なしの instance.Name です。Get は Return または Name への代入で返し、Exit Property はその値または型の既定値を返します。代入は Set(ByVal value As ValueType) を呼び、末尾の Get は読みません。通常のプロパティは Get と Set が一つずつ必要です。公開範囲は Property に指定し、Set には同型の明示的な ByVal 引数を一つ指定します。
- `ReadOnly / WriteOnly / auto Property` — 本体付き ReadOnly は Get のみ、WriteOnly は Set のみです。禁止された読み書きは捕捉可能なエラーです。自動プロパティは Get/Set と End Property を持たず値を直接保存します。自動 ReadOnly への代入はそのインスタンスの Sub New 内だけです。Set のない WriteOnly は無効です。ReadOnly が Class 参照を返す場合、その参照先の変更可能なメンバーは変更できます。
- `ByVal / ByRef / With` — ByVal は参照をコピーします。メンバー変更は元のオブジェクトに反映されますが、引数自体の置換は呼び出し元変数を置換しません。ByRef はエンジンの copy-in/copy-out 規則で新しい参照も書き戻します。等価比較はオブジェクトの同一性です。With instance は対象を一度保持してフィールド、プロパティ、メソッドを扱います。Class は自動的に IDisposable にはなりません。Using は対応するリソースオブジェクトに使ってください。

## 戻り値

New は Class 参照を含む Object を返し、UO の ID/グラフィックではありません。Get と Function は宣言型、Set・Sub・宣言は Unit です。New なしの変数は Nothing です。参照比較と As Boolean は 1/True または 0/False、Integer の数量は自動的な成功フラグではありません。Main の結果は "5:2:1"、"1:0:6"、"ore:1:replacement:0" です。

## 動作

- SC032 は Option Explicit がなくても不正な宣言を実行前に拒否します。上限は 256 クラス、各 256 フィールド/プロパティと 256 メソッド、New/Get/Set を含む 32 段の呼び出しです。代入/ByRef のメンバーパスは 64 要素まで。循環参照は可能です。メタデータと既定値は事前準備し、可変の格納場所は New ごとに独立します。
- 対象パスは右辺や引数の副作用より先に確定し、パス中の各 Get は一度だけ評価します。手続きが途中の変数を置換しても書き戻し先は元の対象です。値は宣言型に変換されます。コンストラクター、メソッド、アクセサーのエラーは Try/Catch で扱い、すでに行った変更は取り消しません。
- 一時停止、停止、ソース位置、深さ制限は通常のスクリプトフレームを利用します。IDE を閉じるだけでは停止しません。インスペクターは Get や循環参照の追跡なしで型とメンバー数を表示します。Watch は保存フィールド/自動プロパティを読めますが、独自 Get、メソッド、New は実行できません。任意の .NET クラスではなく、ここに記載した機能範囲です。

## 使用例

### 1. 独立オブジェクトと参照共有

```vb
# New Counter(label:="ore", start:=2) は String label と Integer start を渡し、Label/stored を設定します。second は独立したフィールドを持ち、alias=first は参照コピーです。Add(amount:=3) は Value.Set で負数を検査して書き、Value.Get の Integer を返します。first は 5、second は 2、alias=first は 1/True です。補助メソッドもすべて掲載しています。
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

**パラメーターと実行の説明:**

New Counter(label:="ore", start:=2) は String label と Integer start を渡し、Label/stored を設定します。second は独立したフィールドを持ち、alias=first は参照コピーです。Add(amount:=3) は Value.Set で負数を検査して書き、Value.Get の Integer を返します。first は 5、second は 2、alias=first は 1/True です。補助メソッドもすべて掲載しています。

### 2. 読み取り・書き込みと Boolean

```vb
# Limit=10 は value=10 で Set を実行します。Remaining.Get は結果名へ代入して Exit Property で戻ります。TrySpend(cost:=4) は四つ減らし 1/True、cost=9 は残り六つを超えるので 0/False です。Limit=-3 は書き込み前に失敗し、Catch は Remaining=6 を読みます。Main は "1:0:6"。サーバー操作はありません。
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

**パラメーターと実行の説明:**

Limit=10 は value=10 で Set を実行します。Remaining.Get は結果名へ代入して Exit Property で戻ります。TrySpend(cost:=4) は四つ減らし 1/True、cost=9 は残り六つを超えるので 0/False です。Limit=-3 は書き込み前に失敗し、Catch は Remaining=6 を読みます。Main は "1:0:6"。サーバー操作はありません。

### 3. Module、ByVal、ByRef の置換

```vb
# Jobs.WorkItem(name) は String Name を保存し、Done の初期値は 0 です。Tick(ByVal job) は共有オブジェクトの Done を 1 にし、次の "local" への置換はローカル引数だけです。Replace(ByRef job, ByVal name) は "replacement" を作り呼び出し元へ参照を書き戻します。名前付き引数は意図的に逆順です。original は "ore"/1、job は新しい "replacement"/0。Module Jobs 全体を示しています。
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

**パラメーターと実行の説明:**

Jobs.WorkItem(name) は String Name を保存し、Done の初期値は 0 です。Tick(ByVal job) は共有オブジェクトの Done を 1 にし、次の "local" への置換はローカル引数だけです。Replace(ByRef job, ByVal name) は "replacement" を作り呼び出し元へ参照を書き戻します。名前付き引数は意図的に逆順です。original は "ore"/1、job は新しい "replacement"/0。Module Jobs 全体を示しています。


### 内部関数：呼び出しから結果まで

Class は各オブジェクトの状態とスクリプトのメソッドをまとめます。New が作るのは参照オブジェクトです。別の変数への代入は同じオブジェクトを参照し、Structure の値コピーとは異なります。使用するコンストラクター、メソッド、プロパティの全コードを例に示します。

#### 1. ClassCatalog.Build / Complete

SC032 は Option Explicit がなくても不正な宣言を実行前に拒否します。上限は 256 クラス、各 256 フィールド/プロパティと 256 メソッド、New/Get/Set を含む 32 段の呼び出しです。代入/ByRef のメンバーパスは 64 要素まで。循環参照は可能です。メタデータと既定値は事前準備し、可変の格納場所は New ごとに独立します。

`declarations -> unique typed members -> accessor validation -> prepared metadata; SC032 on invalid Class`

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/ClassCatalog.cs`; 関数 `ClassCatalog.Build / Complete`.

#### 2. ConstructClass

New TypeName(arguments) は独立したフィールドを作り、Public Sub New を一度実行します。コンストラクターがなければ New TypeName() のみ有効です。コンストラクターは一つで、通常の Optional、既定引数、名前付き引数の規則を使えます。引数は記述順に一度評価され、失敗時には構築済みオブジェクトを返しません。As TypeName だけの変数は Nothing のままです。

`new instance -> independent field slots -> bind constructor arguments -> Sub New -> Object reference`

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Classes.cs`; 関数 `ConstructClass`.

#### 3. ClassObject.Member / Read

Property Name[()] As ValueType はインデックス引数を持ちません。読み取りは呼び出し括弧なしの instance.Name です。Get は Return または Name への代入で返し、Exit Property はその値または型の既定値を返します。代入は Set(ByVal value As ValueType) を呼び、末尾の Get は読みません。通常のプロパティは Get と Set が一つずつ必要です。公開範囲は Property に指定し、Set には同型の明示的な ByVal 引数を一つ指定します。

`check member visibility -> stored value OR Get frame -> declared value type`

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ClassObject.cs`; 関数 `ClassObject.Member / Read`.

#### 4. MemberAccess.Resolve / ClassObject.Write

対象パスは右辺や引数の副作用より先に確定し、パス中の各 Get は一度だけ評価します。手続きが途中の変数を置換しても書き戻し先は元の対象です。値は宣言型に変換されます。コンストラクター、メソッド、アクセサーのエラーは Try/Catch で扱い、すでに行った変更は取り消しません。

`capture receiver once -> evaluate RHS/arguments -> coerce value -> Set OR stored slot`

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/MemberAccess.cs`; 関数 `MemberAccess.Resolve / ClassObject.Write`.

#### 5. CallClassMethod / CallSubrutine

Sub/Function は instance.Method(...)、クラス内では Method(...) または Me.Method(...) で呼びます。Private は同じ Class のコードからのみ呼べ、同型の別インスタンスにも適用されます。型、ByVal/ByRef、Optional、ParamArray、名前付き引数を利用できますが、ParamArray 要素の名前付き指定は不可です。Function は宣言型、Sub は Unit を返します。TypeName.Method(...) と instance.New(...) は無効です。インスタンスメソッドの AddressOf にはファイル/モジュールのラッパー手続きが必要です。

`check method visibility -> bind named/positional arguments -> Me frame -> return -> ByRef copy-out`

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Classes.cs`; 関数 `CallClassMethod / CallSubrutine`.

#### 6. ClassObject.DisplayValue

一時停止、停止、ソース位置、深さ制限は通常のスクリプトフレームを利用します。IDE を閉じるだけでは停止しません。インスペクターは Get や循環参照の追跡なしで型とメンバー数を表示します。Watch は保存フィールド/自動プロパティを読めますが、独自 Get、メソッド、New は実行できません。任意の .NET クラスではなく、ここに記載した機能範囲です。

`debugger: type + member count; no getter calls and no traversal of reference cycles`

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ClassObject.cs`; 関数 `ClassObject.DisplayValue`.

New は Class 参照を含む Object を返し、UO の ID/グラフィックではありません。Get と Function は宣言型、Set・Sub・宣言は Unit です。New なしの変数は Nothing です。参照比較と As Boolean は 1/True または 0/False、Integer の数量は自動的な成功フラグではありません。Main の結果は "5:2:1"、"1:0:6"、"ore:1:replacement:0" です。

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
