# UO.FindTypesArrayEx

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: ja -->

複数のグラフィック、色、コンテナを一度の走査で検索し、ID を一つ返します。全件は GetFoundItems で取得します。

## 正確な構文

```text
UO.FindTypesArrayEx(ObjTypes:Any, Colors:Any, Containers:Any, InSub:Any) -> Integer
```

## パラメーター

- `ObjTypes` — Graphic/body。物体の serial ではありません。0..65534 は特定のグラフィック、-1 または 0xFFFF はすべてです。他の負の Integer もフィルターを解除します。
- `Colors` — Hue。数量ではありません。0 は未染色、-1 または 0xFFFF はすべての色です。他の負の Integer も色フィルターを解除します。
- `Containers` — 地面：UO.Ground()、0、-1、0xFFFFFFFF または文字列 ground。バックパック：文字列 backpack またはその serial。十進数／hex serial と AddObject 名を使用できます。my は装備と入れ子の袋を含む自分の全所持品です。不明な名前はスクリプトエラーになります。解決した serial を確認してください。明示的な 0 は地面です。API ごとに数値の意味が異なるため ground/backpack 名を推奨します。
- `InSub` — 必須の TRUE/FALSE（1/0）。FALSE は指定コンテナの直接内容、TRUE は読み込み済みの入れ子の袋も対象です。地面には影響しません。my は元から自分の全所持品を対象とします。

## 戻り値

Integer：ローカル走査順の最初の一致 serial。該当なしは 0。グラフィック、数量、配列、Boolean ではありません。result <> 0 で調べ、result = TRUE や result = 1 は使いません。一スタックは一物体、Mobile は一物体かつ一単位です。順序は近さを示さず、毎回の安定性も保証しません。

## 動作

- Array を渡します。単一値も一要素として使用できます。DIM values[1] は添字 0 と 1 を作るため、すべて代入してください。型と色は独立した候補で、同じ添字同士の組ではありません。どこかにワイルドカードがある場合、または型／色配列が空の場合、その制限は解除されます。空のコンテナ配列は自分の所持品を選択します。重複や重なるコンテナでも ID は重複しません。
- 四つの位置引数がすべて必須です。省略できません。
- 地面はこのスクリプトの FindDistance/FindVertical を使い、self を除外し、一致する Item と Mobile を含みます。指定コンテナには距離／高さ制限を適用しません。どちらも Ignore と破棄済み物体を除外します。
- 走査前に FindItem、FindCount、FindFullQuantity、GetFoundItems を消去します。該当なしならゼロと空配列になります。FindFullQuantity は Item の max(1, Amount) と Mobile ごとの 1 を合計します。FindQuantity は FindItem の現在数量です。後の検索に備えて必要な GetFoundItems を先に保存してください。
- Bridge は読み込み済み Item を一度走査し、地面なら続いて Mobile を走査します。型、色、一つ以上のコンテナが一致する必要があります。各物体は一度だけ登録し、組合せごとに世界全体を再走査しません。
- 受信済みデータだけを読みます。コンテナを開かず、マスを読み込まず、移動も行いません。結果なしはサーバー上の箱が空という証明にはなりません。接続が必要なら Connected を確認してください。検索自体はローカル状態を読みます。
- [Stealth FindTypesArrayEx](https://stealth.od.ua/api/FindTypesArrayEx/). 参考資料は最後の ID と無効コンテナ時のバックパックへの切替を説明しています。この実装は最初のローカル一致を保持し、不明な名前でバックパックに切り替えません。Ground は 0 も受け付けます。ローカル FindDistance の初期値は 18、上限は 255 です。

### 内部関数：呼び出しから結果まで

実際の処理段階であり、追加の公開コマンドではありません。下記の FindGoldNearSelf と SearchTypesIn は完全なスクリプト関数です。

#### 1. ExecuteStealthCompatibility

Runtime は数値フィルターを変換し、コンテナ名を別途解決します。地面の指定を bridge 内部の世界範囲へ変換します。

四つの位置引数がすべて必須です。省略できません。

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 関数 `ExecuteStealthCompatibility`.

#### 2. ConvertStealthSearchContainer

地面：UO.Ground()、0、-1、0xFFFFFFFF または文字列 ground。バックパック：文字列 backpack またはその serial。十進数／hex serial と AddObject 名を使用できます。my は装備と入れ子の袋を含む自分の全所持品です。不明な名前はスクリプトエラーになります。解決した serial を確認してください。明示的な 0 は地面です。API ごとに数値の意味が異なるため ground/backpack 名を推奨します。

Runtime は数値フィルターを変換し、コンテナ名を別途解決します。地面の指定を bridge 内部の世界範囲へ変換します。

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 関数 `ConvertStealthSearchContainer`.

#### 3. ResetFindResults

走査前に FindItem、FindCount、FindFullQuantity、GetFoundItems を消去します。該当なしならゼロと空配列になります。FindFullQuantity は Item の max(1, Amount) と Mobile ごとの 1 を合計します。FindQuantity は FindItem の現在数量です。後の検索に備えて必要な GetFoundItems を先に保存してください。

Integer：ローカル走査順の最初の一致 serial。該当なしは 0。グラフィック、数量、配列、Boolean ではありません。result <> 0 で調べ、result = TRUE や result = 1 は使いません。一スタックは一物体、Mobile は一物体かつ一単位です。順序は近さを示さず、毎回の安定性も保証しません。

プロジェクトのソース: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 関数 `ResetFindResults`.

#### 4. BuildFindIdentityMask

Array を渡します。単一値も一要素として使用できます。DIM values[1] は添字 0 と 1 を作るため、すべて代入してください。型と色は独立した候補で、同じ添字同士の組ではありません。どこかにワイルドカードがある場合、または型／色配列が空の場合、その制限は解除されます。空のコンテナ配列は自分の所持品を選択します。重複や重なるコンテナでも ID は重複しません。

Bridge は読み込み済み Item を一度走査し、地面なら続いて Mobile を走査します。型、色、一つ以上のコンテナが一致する必要があります。各物体は一度だけ登録し、組合せごとに世界全体を再走査しません。

プロジェクトのソース: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 関数 `BuildFindIdentityMask`.

#### 5. FindTypes

Bridge は読み込み済み Item を一度走査し、地面なら続いて Mobile を走査します。型、色、一つ以上のコンテナが一致する必要があります。各物体は一度だけ登録し、組合せごとに世界全体を再走査しません。

地面はこのスクリプトの FindDistance/FindVertical を使い、self を除外し、一致する Item と Mobile を含みます。指定コンテナには距離／高さ制限を適用しません。どちらも Ignore と破棄済み物体を除外します。

プロジェクトのソース: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 関数 `FindTypes`.

#### 6. MatchesFindIdentity

Graphic/body。物体の serial ではありません。0..65534 は特定のグラフィック、-1 または 0xFFFF はすべてです。他の負の Integer もフィルターを解除します。 Hue。数量ではありません。0 は未染色、-1 または 0xFFFF はすべての色です。他の負の Integer も色フィルターを解除します。

Bridge は読み込み済み Item を一度走査し、地面なら続いて Mobile を走査します。型、色、一つ以上のコンテナが一致する必要があります。各物体は一度だけ登録し、組合せごとに世界全体を再走査しません。

プロジェクトのソース: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 関数 `MatchesFindIdentity`.

#### 7. MatchesFindContainer

必須の TRUE/FALSE（1/0）。FALSE は指定コンテナの直接内容、TRUE は読み込み済みの入れ子の袋も対象です。地面には影響しません。my は元から自分の全所持品を対象とします。

地面はこのスクリプトの FindDistance/FindVertical を使い、self を除外し、一致する Item と Mobile を含みます。指定コンテナには距離／高さ制限を適用しません。どちらも Ignore と破棄済み物体を除外します。

プロジェクトのソース: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 関数 `MatchesFindContainer`.

#### 8. RegisterFound

走査前に FindItem、FindCount、FindFullQuantity、GetFoundItems を消去します。該当なしならゼロと空配列になります。FindFullQuantity は Item の max(1, Amount) と Mobile ごとの 1 を合計します。FindQuantity は FindItem の現在数量です。後の検索に備えて必要な GetFoundItems を先に保存してください。

Integer：ローカル走査順の最初の一致 serial。該当なしは 0。グラフィック、数量、配列、Boolean ではありません。result <> 0 で調べ、result = TRUE や result = 1 は使いません。一スタックは一物体、Mobile は一物体かつ一単位です。順序は近さを示さず、毎回の安定性も保証しません。

プロジェクトのソース: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 関数 `RegisterFound`.

受信済みデータだけを読みます。コンテナを開かず、マスを読み込まず、移動も行いません。結果なしはサーバー上の箱が空という証明にはなりません。接続が必要なら Connected を確認してください。検索自体はローカル状態を読みます。


## 使用例

### 地面の二種類のグラフィック

```vb
# 地面の二種類のグラフィック
#
# 複数のグラフィック、色、コンテナを一度の走査で検索し、ID を一つ返します。全件は GetFoundItems で取得します。
#
# Integer：ローカル走査順の最初の一致 serial。該当なしは 0。グラフィック、数量、配列、Boolean ではありません。result <> 0 で調べ、result =
# TRUE や result = 1 は使いません。一スタックは一物体、Mobile は一物体かつ一単位です。順序は近さを示さず、毎回の安定性も保証しません。

SUB Main()
    # types は金貨 0x0EED と黒真珠 0x0F7A。color=-1 は任意の色、Ground は世界です。FALSE
    # は地面に影響しません。現在の検索制限を使い、ID、物体数、数量を表示します。

    DIM types[1]
    types[0] = 0x0EED
    types[1] = 0x0F7A
    DIM colors[0]
    colors[0] = -1
    DIM containers[0]
    containers[0] = UO.Ground()
    VAR first = UO.FindTypesArrayEx(types, colors, containers, FALSE)
    UO.Print(Hex(first))
    UO.Print(STR(UO.FindCount()))
    UO.Print(STR(UO.FindFullQuantity()))
END SUB
```

**パラメーターと実行の説明:**

- types は金貨 0x0EED と黒真珠 0x0F7A。color=-1 は任意の色、Ground は世界です。FALSE は地面に影響しません。現在の検索制限を使い、ID、物体数、数量を表示します。

### バックパックと地面の金貨

```vb
# バックパックと地面の金貨
#
# 複数のグラフィック、色、コンテナを一度の走査で検索し、ID を一つ返します。全件は GetFoundItems で取得します。
#
# Integer：ローカル走査順の最初の一致 serial。該当なしは 0。グラフィック、数量、配列、Boolean ではありません。result <> 0 で調べ、result =
# TRUE や result = 1 は使いません。一スタックは一物体、Mobile は一物体かつ一単位です。順序は近さを示さず、毎回の安定性も保証しません。

SUB Main()
    # types は金貨のみ、colors は全色。Containers は backpack と地面で、TRUE は入れ子の袋も含みます。両範囲の物体／スタック数と単位数を重複なく表示します。

    DIM types[0]
    types[0] = 0x0EED
    DIM colors[0]
    colors[0] = -1
    DIM containers[1]
    containers[0] = 'backpack'
    containers[1] = UO.Ground()
    UO.FindTypesArrayEx(types, colors, containers, TRUE)
    UO.Print(STR(UO.FindCount()))
    UO.Print(STR(UO.FindFullQuantity()))
END SUB
```

**パラメーターと実行の説明:**

- types は金貨のみ、colors は全色。Containers は backpack と地面で、TRUE は入れ子の袋も含みます。両範囲の物体／スタック数と単位数を重複なく表示します。

### 保存した一覧を返す完全な関数

```vb
# 保存した一覧を返す完全な関数
#
# 複数のグラフィック、色、コンテナを一度の走査で検索し、ID を一つ返します。全件は GetFoundItems で取得します。
#
# Integer：ローカル走査順の最初の一致 serial。該当なしは 0。グラフィック、数量、配列、Boolean ではありません。result <> 0 で調べ、result =
# TRUE や result = 1 は使いません。一スタックは一物体、Mobile は一物体かつ一単位です。順序は近さを示さず、毎回の安定性も保証しません。

SUB Main()
    # SearchTypesIn(container,firstType,secondType) は Array<Integer> を返します。組み込みコマンドが返すのは単一の Integer
    # ID です。完全な関数が配列を埋め、再帰検索し、直ちに GetFoundItems をコピーします。Main は保存した各 ID を確認し表示します。

    VAR items = SearchTypesIn('backpack', 0x0EED, 0x0F7A)
    FOR EACH item IN items
        IF UO.IsObjectExists(item) THEN
            UO.Print(Hex(item))
        END IF
    NEXT
END SUB

FUNCTION SearchTypesIn(container, firstType, secondType)
    DIM types[1]
    types[0] = firstType
    types[1] = secondType
    DIM colors[0]
    colors[0] = -1
    DIM containers[0]
    containers[0] = container
    UO.FindTypesArrayEx(types, colors, containers, TRUE)
    RETURN UO.GetFoundItems()
END FUNCTION
```

**パラメーターと実行の説明:**

- SearchTypesIn(container,firstType,secondType) は Array<Integer> を返します。組み込みコマンドが返すのは単一の Integer ID です。完全な関数が配列を埋め、再帰検索し、直ちに GetFoundItems をコピーします。Main は保存した各 ID を確認し表示します。
