# UO.FindAtCoord

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: ja -->

現在のマップの正確な X/Y セルにある、読み込み済みのワールドオブジェクトを検索します。

## 正確な構文

```text
UO.FindAtCoord(X:Any, Y:Any) -> Integer
```

## パラメーター

- `X` — ワールドの横座標。Integer 0..65535、必須。コンテナウィンドウ内のピクセル座標ではありません。
- `Y` — ワールドの縦座標。Integer 0..65535、必須。Z、マップ、タイプ、半径の追加引数はありません。

## 戻り値

Integer：このクライアントの結果一覧で最初に一致したオブジェクトの serial。一致なし、プレイヤー不在・削除済み、座標が 0..65535 の範囲外の場合は 0。タイプ、数量、Boolean ではなく ID です。32 ビットすべてを保持するため、= TRUE や > 0 ではなく <> 0 で確認します。同じ ID が FindItem() になります。

## 動作

- 削除されていない地面の Item と Mobile を調べます。そのセルのプレイヤーも含みます。コンテナ内容と装備品は除外します。それらの X/Y はワールド座標として使えません。Ignore に登録された serial も除外します。
- 同じ X/Y のすべての Z 高度が対象です。FindDistance と FindVertical はこの完全一致検索を制限しません。現在のワールドで読み込み済みの物体だけを調べ、地形・静的タイル・別マップは読み込みません。パケット送信、ターゲット表示、物品移動は行いません。
- 呼び出しごとに前の検索結果を消去します。FindCount() は物体数、FindFullQuantity() はスタック内の数量合計（Mobile は一つ）、GetFoundItems() は serial 一覧です。Item の後に Mobile を、それぞれ現在の列挙順で調べます。次の検索前に一覧を保存してください。
- 参照：[Stealth FindAtCoord](https://stealth.od.ua/api/FindAtCoord/)。上記の順序とフィルターはこのクライアントの実装を説明しています。

### 内部関数：呼び出しから結果まで

以下は実際の内部処理です。CountGraphicAt は完全に定義したスクリプト関数であり、追加の組み込みコマンドではありません。

#### 1. ExecuteStealthCompatibility

登録された実行経路が二つの位置引数または名前付き X/Y 引数を変換し、ブリッジの Integer を返します。

Integer：このクライアントの結果一覧で最初に一致したオブジェクトの serial。一致なし、プレイヤー不在・削除済み、座標が 0..65535 の範囲外の場合は 0。タイプ、数量、Boolean ではなく ID です。32 ビットすべてを保持するため、= TRUE や > 0 ではなく <> 0 で確認します。同じ ID が FindItem() になります。

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 関数 `ExecuteStealthCompatibility`.

#### 2. FindAtCoord

ゲームスレッドで前の結果を消去し、プレイヤーと座標範囲を確認して、一致する地面の Item と Mobile だけを走査します。コンテナ内容は一致しません。

削除されていない地面の Item と Mobile を調べます。そのセルのプレイヤーも含みます。コンテナ内容と装備品は除外します。それらの X/Y はワールド座標として使えません。Ignore に登録された serial も除外します。

プロジェクトのソース: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 関数 `FindAtCoord`.

#### 3. RegisterFound

一致するたびに数と serial 一覧を更新します。最初の serial を FindItem に保持し、Item.Amount は最低一単位、Mobile は一単位を加算します。

呼び出しごとに前の検索結果を消去します。FindCount() は物体数、FindFullQuantity() はスタック内の数量合計（Mobile は一つ）、GetFoundItems() は serial 一覧です。Item の後に Mobile を、それぞれ現在の列挙順で調べます。次の検索前に一覧を保存してください。

プロジェクトのソース: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 関数 `RegisterFound`.

同じ X/Y のすべての Z 高度が対象です。FindDistance と FindVertical はこの完全一致検索を制限しません。現在のワールドで読み込み済みの物体だけを調べ、地形・静的タイル・別マップは読み込みません。パケット送信、ターゲット表示、物品移動は行いません。


## 使用例

### 一つの ID を読む

```vb
# 一つの ID を読む
#
# 現在のマップの正確な X/Y セルにある、読み込み済みのワールドオブジェクトを検索します。
#
# Integer：このクライアントの結果一覧で最初に一致したオブジェクトの serial。一致なし、プレイヤー不在・削除済み、座標が 0..65535 の範囲外の場合は
# 0。タイプ、数量、Boolean ではなく ID です。32 ビットすべてを保持するため、= TRUE や > 0 ではなく <> 0 で確認します。同じ ID が FindItem()
# になります。

SUB Main()
    # 1445 と 1690 はワールド X/Y の例です。目的のセルに置き換えます。id は serial を保存し、HEX が整形します。<> 0 は結果の有無であり数量ではありません。

    VAR id = UO.FindAtCoord(1445, 1690)
    IF id <> 0 THEN
        UO.Print(HEX(id))
    ELSE
        UO.Print('No loaded object')
    END IF
END SUB
```

**パラメーターと実行の説明:**

- 1445 と 1690 はワールド X/Y の例です。目的のセルに置き換えます。id は serial を保存し、HEX が整形します。<> 0 は結果の有無であり数量ではありません。

### プレイヤーのセルの全物体を調べる

```vb
# プレイヤーのセルの全物体を調べる
#
# 現在のマップの正確な X/Y セルにある、読み込み済みのワールドオブジェクトを検索します。
#
# Integer：このクライアントの結果一覧で最初に一致したオブジェクトの serial。一致なし、プレイヤー不在・削除済み、座標が 0..65535 の範囲外の場合は
# 0。タイプ、数量、Boolean ではなく ID です。32 ビットすべてを保持するため、= TRUE や > 0 ではなく <> 0 で確認します。同じ ID が FindItem()
# になります。

SUB Main()
    # x/y はプレイヤーから読み、ids に一覧を保存します。各 id は一つの物体で、スタック全体も一つです。GetType(id) は graphic/body
    # を読みます。物品の選択や使用はしません。

    VAR x = UO.GetX('self')
    VAR y = UO.GetY('self')
    UO.FindAtCoord(x, y)
    VAR ids = UO.GetFoundItems()
    FOR EACH id IN ids
        UO.Print(HEX(id) + ' type=' + HEX(UO.GetType(id)))
    NEXT
END SUB
```

**パラメーターと実行の説明:**

- x/y はプレイヤーから読み、ids に一覧を保存します。各 id は一つの物体で、スタック全体も一つです。GetType(id) は graphic/body を読みます。物品の選択や使用はしません。

### 完全な CountGraphicAt 補助関数

```vb
# 完全な CountGraphicAt 補助関数
#
# 現在のマップの正確な X/Y セルにある、読み込み済みのワールドオブジェクトを検索します。
#
# Integer：このクライアントの結果一覧で最初に一致したオブジェクトの serial。一致なし、プレイヤー不在・削除済み、座標が 0..65535 の範囲外の場合は
# 0。タイプ、数量、Boolean ではなく ID です。32 ビットすべてを保持するため、= TRUE や > 0 ではなく <> 0 で確認します。同じ ID が FindItem()
# になります。

SUB Main()
    # CountGraphicAt(x, y, graphic) は一度検索し、保存した ID から指定グラフィックの物体を数えます。graphic=0x0EED
    # は金貨です。戻り値は物体・スタック数で、単位数合計でも true/false でもありません。一つのスタックは一つと数えます。Main の後に完全な定義があります。

    VAR count = CountGraphicAt(1445, 1690, 0x0EED)
    UO.Print('Objects/stacks: ' + CStr(count))
END SUB

FUNCTION CountGraphicAt(x, y, graphic)
    UO.FindAtCoord(x, y)
    VAR ids = UO.GetFoundItems()
    VAR count = 0
    FOR EACH id IN ids
        IF UO.GetType(id) = graphic THEN
            count += 1
        END IF
    NEXT
    RETURN count
END FUNCTION
```

**パラメーターと実行の説明:**

- CountGraphicAt(x, y, graphic) は一度検索し、保存した ID から指定グラフィックの物体を数えます。graphic=0x0EED は金貨です。戻り値は物体・スタック数で、単位数合計でも true/false でもありません。一つのスタックは一つと数えます。Main の後に完全な定義があります。
