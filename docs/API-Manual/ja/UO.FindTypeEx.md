# UO.FindTypeEx

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: ja -->

指定したグラフィックと色をコンテナまたは地面から検索し、一致した ID を一つ返します。

## 正確な構文

```text
UO.FindTypeEx(ObjType:Any, Color:Any, Container:Any, InSub:Any) -> Integer
```

## パラメーター

- `ObjType` — Graphic/body。物体の serial ではありません。0..65534 は特定のグラフィック、-1 または 0xFFFF はすべてです。他の負の Integer もフィルターを解除します。
- `Color` — Hue。数量ではありません。0 は未染色、-1 または 0xFFFF はすべての色です。他の負の Integer も色フィルターを解除します。
- `Container` — 地面：UO.Ground()、0、-1、0xFFFFFFFF または文字列 ground。バックパック：文字列 backpack またはその serial。十進数／hex serial と AddObject 名を使用できます。my は装備と入れ子の袋を含む自分の全所持品です。不明な名前はスクリプトエラーになります。解決した serial を確認してください。明示的な 0 は地面です。API ごとに数値の意味が異なるため ground/backpack 名を推奨します。
- `InSub` — 必須の TRUE/FALSE（1/0）。FALSE は指定コンテナの直接内容、TRUE は読み込み済みの入れ子の袋も対象です。地面には影響しません。my は元から自分の全所持品を対象とします。

## 戻り値

Integer：ローカル走査順の最初の一致 serial。該当なしは 0。グラフィック、数量、配列、Boolean ではありません。result <> 0 で調べ、result = TRUE や result = 1 は使いません。一スタックは一物体、Mobile は一物体かつ一単位です。順序は近さを示さず、毎回の安定性も保証しません。

## 動作

- 四つの位置引数がすべて必須です。省略できません。
- 地面はこのスクリプトの FindDistance/FindVertical を使い、self を除外し、一致する Item と Mobile を含みます。指定コンテナには距離／高さ制限を適用しません。どちらも Ignore と破棄済み物体を除外します。
- 走査前に FindItem、FindCount、FindFullQuantity、GetFoundItems を消去します。該当なしならゼロと空配列になります。FindFullQuantity は Item の max(1, Amount) と Mobile ごとの 1 を合計します。FindQuantity は FindItem の現在数量です。後の検索に備えて必要な GetFoundItems を先に保存してください。
- Bridge は読み込み済み Item を一度走査し、地面なら続いて Mobile を走査します。型、色、一つ以上のコンテナが一致する必要があります。各物体は一度だけ登録し、組合せごとに世界全体を再走査しません。
- 受信済みデータだけを読みます。コンテナを開かず、マスを読み込まず、移動も行いません。結果なしはサーバー上の箱が空という証明にはなりません。接続が必要なら Connected を確認してください。検索自体はローカル状態を読みます。
- [Stealth FindTypeEx](https://stealth.od.ua/api/FindTypeEx/). 参考資料は最後の ID と無効コンテナ時のバックパックへの切替を説明しています。この実装は最初のローカル一致を保持し、不明な名前でバックパックに切り替えません。Ground は 0 も受け付けます。ローカル FindDistance の初期値は 18、上限は 255 です。

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

#### 4. FindType

Bridge は読み込み済み Item を一度走査し、地面なら続いて Mobile を走査します。型、色、一つ以上のコンテナが一致する必要があります。各物体は一度だけ登録し、組合せごとに世界全体を再走査しません。

地面はこのスクリプトの FindDistance/FindVertical を使い、self を除外し、一致する Item と Mobile を含みます。指定コンテナには距離／高さ制限を適用しません。どちらも Ignore と破棄済み物体を除外します。

プロジェクトのソース: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 関数 `FindType`.

#### 5. MatchesFindIdentity

Graphic/body。物体の serial ではありません。0..65534 は特定のグラフィック、-1 または 0xFFFF はすべてです。他の負の Integer もフィルターを解除します。 Hue。数量ではありません。0 は未染色、-1 または 0xFFFF はすべての色です。他の負の Integer も色フィルターを解除します。

Bridge は読み込み済み Item を一度走査し、地面なら続いて Mobile を走査します。型、色、一つ以上のコンテナが一致する必要があります。各物体は一度だけ登録し、組合せごとに世界全体を再走査しません。

プロジェクトのソース: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 関数 `MatchesFindIdentity`.

#### 6. MatchesFindContainer

必須の TRUE/FALSE（1/0）。FALSE は指定コンテナの直接内容、TRUE は読み込み済みの入れ子の袋も対象です。地面には影響しません。my は元から自分の全所持品を対象とします。

地面はこのスクリプトの FindDistance/FindVertical を使い、self を除外し、一致する Item と Mobile を含みます。指定コンテナには距離／高さ制限を適用しません。どちらも Ignore と破棄済み物体を除外します。

プロジェクトのソース: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 関数 `MatchesFindContainer`.

#### 7. RegisterFound

走査前に FindItem、FindCount、FindFullQuantity、GetFoundItems を消去します。該当なしならゼロと空配列になります。FindFullQuantity は Item の max(1, Amount) と Mobile ごとの 1 を合計します。FindQuantity は FindItem の現在数量です。後の検索に備えて必要な GetFoundItems を先に保存してください。

Integer：ローカル走査順の最初の一致 serial。該当なしは 0。グラフィック、数量、配列、Boolean ではありません。result <> 0 で調べ、result = TRUE や result = 1 は使いません。一スタックは一物体、Mobile は一物体かつ一単位です。順序は近さを示さず、毎回の安定性も保証しません。

プロジェクトのソース: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 関数 `RegisterFound`.

受信済みデータだけを読みます。コンテナを開かず、マスを読み込まず、移動も行いません。結果なしはサーバー上の箱が空という証明にはなりません。接続が必要なら Connected を確認してください。検索自体はローカル状態を読みます。


## 使用例

### バックパックの直接内容

```vb
# バックパックの直接内容
#
# 指定したグラフィックと色をコンテナまたは地面から検索し、一致した ID を一つ返します。
#
# Integer：ローカル走査順の最初の一致 serial。該当なしは 0。グラフィック、数量、配列、Boolean ではありません。result <> 0 で調べ、result =
# TRUE や result = 1 は使いません。一スタックは一物体、Mobile は一物体かつ一単位です。順序は近さを示さず、毎回の安定性も保証しません。

SUB Main()
    # 0x0EED は金貨、-1 は任意の hue。backpack/FALSE は入れ子を除外します。最初の hex ID（0x なし）、物体数、総数量を表示します。20 と 50
    # の二スタックなら 2 物体、70 単位です。

    VAR item = UO.FindTypeEx(0x0EED, -1, 'backpack', FALSE)
    UO.Print(Hex(item))
    UO.Print(STR(UO.FindCount()))
    UO.Print(STR(UO.FindFullQuantity()))
END SUB
```

**パラメーターと実行の説明:**

- 0x0EED は金貨、-1 は任意の hue。backpack/FALSE は入れ子を除外します。最初の hex ID（0x なし）、物体数、総数量を表示します。20 と 50 の二スタックなら 2 物体、70 単位です。

### 一時的な地面検索の完全な関数

```vb
# 一時的な地面検索の完全な関数
#
# 指定したグラフィックと色をコンテナまたは地面から検索し、一致した ID を一つ返します。
#
# Integer：ローカル走査順の最初の一致 serial。該当なしは 0。グラフィック、数量、配列、Boolean ではありません。result <> 0 で調べ、result =
# TRUE や result = 1 は使いません。一スタックは一物体、Mobile は一物体かつ一単位です。順序は近さを示さず、毎回の安定性も保証しません。

SUB Main()
    # radius=5、height=10 は FindGoldNearSelf 内だけで使います。Finally は Return やエラー時にも両設定を復元します。金貨 serial または
    # 0 を返し、Main は <> 0 で確認します。

    VAR item = FindGoldNearSelf(5, 10)
    IF item <> 0 THEN
        UO.Print(Hex(item))
    ELSE
        UO.Print('Empty')
    END IF
END SUB

FUNCTION FindGoldNearSelf(radius, height)
    VAR oldDistance = UO.FindDistance()
    VAR oldVertical = UO.FindVertical()
    TRY
        UO.FindDistance(radius)
        UO.FindVertical(height)
        RETURN UO.FindTypeEx(0x0EED, -1, UO.Ground(), FALSE)
    FINALLY
        UO.FindDistance(oldDistance)
        UO.FindVertical(oldVertical)
    END TRY
END FUNCTION
```

**パラメーターと実行の説明:**

- radius=5、height=10 は FindGoldNearSelf 内だけで使います。Finally は Return やエラー時にも両設定を復元します。金貨 serial または 0 を返し、Main は <> 0 で確認します。

### 名前付きコンテナと入れ子の袋

```vb
# 名前付きコンテナと入れ子の袋
#
# 指定したグラフィックと色をコンテナまたは地面から検索し、一致した ID を一つ返します。
#
# Integer：ローカル走査順の最初の一致 serial。該当なしは 0。グラフィック、数量、配列、Boolean ではありません。result <> 0 で調べ、result =
# TRUE や result = 1 は使いません。一スタックは一物体、Mobile は一物体かつ一単位です。順序は近さを示さず、毎回の安定性も保証しません。

SUB Main()
    # GetSerial で backpack を解決し、ゼロ確認で意図しない地面選択を防ぎます。AddObject は search_bag を保存します。TRUE
    # は入れ子を含み、GetFoundItems は一覧をコピーし、IsObjectExists は各 ID を再確認します。

    VAR bag = UO.GetSerial('backpack')
    IF bag <> 0 THEN
        UO.AddObject('search_bag', bag)
        UO.FindTypeEx(0x0EED, -1, 'search_bag', TRUE)
        VAR items = UO.GetFoundItems()
        FOR EACH item IN items
            IF UO.IsObjectExists(item) THEN
                UO.Print(Hex(item))
            END IF
        NEXT
    END IF
END SUB
```

**パラメーターと実行の説明:**

- GetSerial で backpack を解決し、ゼロ確認で意図しない地面選択を防ぎます。AddObject は search_bag を保存します。TRUE は入れ子を含み、GetFoundItems は一覧をコピーし、IsObjectExists は各 ID を再確認します。
