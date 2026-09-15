# Structure / New / fields

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ja -->

Structure は X、Y、Z などの型付きフィールドを一つの値にまとめます。このエンジンでは値コピーを行うデータ構造を扱います。VB.NET の Structure 全機能を実装したものではありません。

## 正確な構文

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

## パラメーター

- `TypeName / Public / Private` — ファイル直下または Module 内で宣言する、一意の単純な型名です。既定は Public。Private は Module 内だけで使用でき、外部から型名を参照できません。公開モジュール型は ModuleName.TypeName で指定します。キーワードとフィールド名は翻訳しません。
- `field / FieldType` — 一意のフィールド名、As、対応するスカラー型・Enum・別の Structure を指定します。フィールドは公開で、Public、Dim、VAR を使用できます。型は Integer/Long/Short/Byte、Single/Double/Decimal、String、Boolean/Bool、Object/Variant。整数の別名はすべて符号付き 32 ビットです。循環する入れ子は禁止です。
- `Dim / New` — Dim value As TypeName と New TypeName() は、ユーザーコードを呼び出さずに既定値を作ります。New の括弧は空にします。X/Y/Z は引数ではなく、作成後にフィールドへ代入します。Dim copy = value は式の値を取得します。UO. 接頭辞は不要です。
- `value.field / copy` — ドットで読み書きし、route.Start.X のような入れ子も指定できます。書き込み時はフィールド型を確認し、それを含む値を置き換えます。copy = value はスカラーと入れ子の構造値をコピーするため、copy.X の変更は value.X を変えません。互換性のある構造型を代入してください。
- `ByVal / ByRef` — ByVal は値のコピーを渡します。ByRef は呼び出し時にコピーし、終了時に呼び出し元へ書き戻します。書き込み可能なフィールドも渡せます。修飾子は明示してください。省略時は既存の Basic 規則に従います。Return で構造を返し、Function で As TypeName を宣言できます。

## 戻り値

宣言と代入には結果がありません（Unit）。New と対応する関数は構造値を返し、実行観察では Object として表され、表示に宣言型名が含まれます。座標は数量であり Boolean フラグではありません。= と <> の結果は 1/True または 0/False。例の String 結果は "1445:1447:1690:0"、"10:15:24"、"2:4:2:2" です。

## 動作

- 宣言は初期化式の実行前に検査します。スクリプト当たり最大 256 型、各型に 1～256 フィールド、入れ子は 32 階層まで。重複・不明なフィールド型、循環、上限超過は SC030 です。名前の解決時に Private を検査します。
- フィールドの既定値は整数/Enum が 0、浮動小数点が 0、Boolean が 0/False、String が空文字列、Object/Variant が代入前の Unit です。入れ子もその構造の既定値です。宣言中のフィールド初期化には非対応なので、作成後に代入してください。
- Object と配列のフィールドはコピー時も参照を保持します。したがって List、Dictionary、配列を共有する場合があります。スカラーと入れ子の値は独立して変更されますが、共有コレクションの内容変更は両方に見えます。List は追加した時点の構造値を保存します。
- = は同じ宣言型と対応するフィールドを比較し、<> は逆の結果です。参照フィールドは同一性を比較します。これはエンジン独自の拡張であり、VB.NET の任意の構造が = を使えるという意味ではありません。保存済みハッシュと検査済みペアにより、共有された入れ子の反復展開を防ぎます。
- 対応範囲は公開型付きデータフィールド、Module の可視性、New()、代入、引数と戻り値です。内部メソッド、独自コンストラクター、フィールド初期化、プロパティ、継承、非公開フィールドは未対応です。WITH .field と array[index].field は使えません。要素を変数へ読み、変更後に書き戻してください。宣言を Include ファイルに置くことは可能です。

## 使用例

### 1. 座標と独立したコピー

```vb
# original は X=1445、Y=1690、Z=0。copy に値をコピーし、copy.X += 2 でコピーだけを変更します。New Position() は Z=0 の empty を作ります。結果は 1445:1447:1690:0。これは座標の保存例で、キャラクターを移動させません。
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

**パラメーターと実行の説明:**

original は X=1445、Y=1690、Z=0。copy に値をコピーし、copy.X += 2 でコピーだけを変更します。New Position() は Z=0 の empty を作ります。結果は 1445:1447:1690:0。これは座標の保存例で、キャラクターを移動させません。

### 2. 入れ子の経路、ByVal と ByRef

```vb
# Route は Position 型の Start と Finish を持ちます。Shift(point ByVal, dx ByVal) はコピーの X に dx を足し、Position を返します。point:=route.Start、dx:=5 で shifted.X=15、Start.X=10 のままです。Advance(route ByRef, dx ByVal) は Finish.X に 4 を足して Route を書き戻し、24 にします。Main の結果は 10:15:24。補助手続きもすべて掲載しています。
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

**パラメーターと実行の説明:**

Route は Position 型の Start と Finish を持ちます。Shift(point ByVal, dx ByVal) はコピーの X に dx を足し、Position を返します。point:=route.Start、dx:=5 で shifted.X=15、Start.X=10 のままです。Advance(route ByRef, dx ByVal) は Finish.X に 4 を足して Route を書き戻し、24 にします。Main の結果は 10:15:24。補助手続きもすべて掲載しています。

### 3. 保存された値と共有コレクション

```vb
# Entry は値の Point と Object の Items を持ちます。first.Point.X=2、Items は文字列一つ入りの List()。snapshots.Add(first) が値を保存します。second=first の後 second.Point.X=4 にしても保存済みの 2 は変わりません。second.Items.Add("ingot") は共有リストを変更するため first.Items.Count()=2。saved=snapshots[0] で要素のフィールドを読みます。結果は 2:4:2:2。
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

**パラメーターと実行の説明:**

Entry は値の Point と Object の Items を持ちます。first.Point.X=2、Items は文字列一つ入りの List()。snapshots.Add(first) が値を保存します。second=first の後 second.Point.X=4 にしても保存済みの 2 は変わりません。second.Items.Add("ingot") は共有リストを変更するため first.Items.Count()=2。saved=snapshots[0] で要素のフィールドを読みます。結果は 2:4:2:2。


### 内部関数：呼び出しから結果まで

Structure は X、Y、Z などの型付きフィールドを一つの値にまとめます。このエンジンでは値コピーを行うデータ構造を扱います。VB.NET の Structure 全機能を実装したものではありません。

#### 1. Build / PrepareDefault

宣言は初期化式の実行前に検査します。スクリプト当たり最大 256 型、各型に 1～256 フィールド、入れ子は 32 階層まで。重複・不明なフィールド型、循環、上限超過は SC030 です。名前の解決時に Private を検査します。

`declarations -> field types -> visibility -> cycle/depth checks -> immutable defaults`

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/StructureCatalog.cs`; 関数 `Build / PrepareDefault`.

#### 2. VisitNewStructure

Dim value As TypeName と New TypeName() は、ユーザーコードを呼び出さずに既定値を作ります。New の括弧は空にします。X/Y/Z は引数ではなく、作成後にフィールドへ代入します。Dim copy = value は式の値を取得します。UO. 接頭辞は不要です。

`resolve TypeName -> prepared default value; no procedure call`

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.cs`; 関数 `VisitNewStructure`.

#### 3. WithField / SetVar

ドットで読み書きし、route.Start.X のような入れ子も指定できます。書き込み時はフィールド型を確認し、それを含む値を置き換えます。copy = value はスカラーと入れ子の構造値をコピーするため、copy.X の変更は value.X を変えません。互換性のある構造型を代入してください。

`resolve path -> coerce field -> replace path -> assign new root value`

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/StructureObject.cs`; 関数 `WithField / SetVar`.

#### 4. CreateArgumentWriter

ByVal は値のコピーを渡します。ByRef は呼び出し時にコピーし、終了時に呼び出し元へ書き戻します。書き込み可能なフィールドも渡せます。修飾子は明示してください。省略時は既存の Basic 規則に従います。Return で構造を返し、Function で As TypeName を宣言できます。

`ByVal: value copy; ByRef: value copy -> callee -> caller slot write-back`

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.cs`; 関数 `CreateArgumentWriter`.

#### 5. ValueEquals

= は同じ宣言型と対応するフィールドを比較し、<> は逆の結果です。参照フィールドは同一性を比較します。これはエンジン独自の拡張であり、VB.NET の任意の構造が = を使えるという意味ではありません。保存済みハッシュと検査済みペアにより、共有された入れ子の反復展開を防ぎます。

`type identity -> cached hash -> distinct field pairs; reference members keep identity`

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/StructureObject.cs`; 関数 `ValueEquals`.

宣言と代入には結果がありません（Unit）。New と対応する関数は構造値を返し、実行観察では Object として表され、表示に宣言型名が含まれます。座標は数量であり Boolean フラグではありません。= と <> の結果は 1/True または 0/False。例の String 結果は "1445:1447:1690:0"、"10:15:24"、"2:4:2:2" です。

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: structureDeclaration / structureField / newStructure
Runtime/StructureCatalog.cs: Build / PrepareDefault
Runtime/ObjectTypes/StructureObject.cs: ReadField / WithField / ValueEquals
Runtime/BasicSyntaxPreprocessor.cs: NormalizeDim
Runtime/InjectionRuntime.cs: ScriptDeclarations / Load
Runtime/ScriptBindings.cs: Variable / CheckStructureType / CallName
Runtime/SemanticScope.cs: TryMemberRoot / SetVar / Coerce
Runtime/Interpreter.cs: VisitNewStructure / CreateArgumentWriter
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/structure-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/programming-guide/language-features/data-types/structure-variables
-->
