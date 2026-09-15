# UO.FindDistance

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: ja -->

検索の既定の水平半径を読み取るか変更します。

## 正確な構文

```text
UO.FindDistance() -> Integer
UO.FindDistance(value:Any) -> Unit
```

## パラメーター

- `value` — 省略可能な Integer。省略すると読み取り、value を指定すると設定します。0..255 に制限され、負数は無制限ではなく 0 になります。新規 runtime の既定値は 18。復元した状態では異なる場合があります。小数はゼロ方向へ切り捨て、decimal/0x の数値文字列も受け付けます。暗黙変換を避けるには Integer を使用してください。

## 戻り値

引数なし：Integer、現在の制限（タイル単位の距離）。ID、個数、Boolean ではありません。0 は失敗ではなく範囲ゼロです。value あり：Unit、戻り値なし。TRUE/FALSE や変更前の値ではありません。設定後に FindDistance() で保存値を確認できます。

## 動作

- 距離はクライアントの現在の距離基準点から max(abs(dx), abs(dy)) で計算し、斜めも 1 タイルです。境界を含み、0 は同じ X/Y のみ許可します。移動中の Mobile はステップキューの最終位置を使います。
- 現在のスクリプト runtime に保存し、そのプロシージャで共有します。独立した runtime の設定は別です。読み書きは検索や FindItem/FindCount/GetFoundItems の消去、パケット送信、移動、遠方オブジェクトの読み込みを行いません。
- FindTypeEx と FindTypesArrayEx は地面の検索で使用し、コンテナ内には適用しません。type、hue、Ignore、読み込み済みオブジェクトの条件は有効です。FindAtCoord は両方を無視します。拡張コマンドの明示的 distance/maxZ は既定値を上書きできます。これらの引数の -1 は既定値を使い、本設定を -1 にする場合とは異なります。FindList はコンテナ内でも Z を検査し、上記の例外は適用されません。
- 一時検索の前に保存し Finally で復元してください。自動で元には戻りません。Finally は通常終了と捕捉可能なスクリプトエラーに対応します。緊急停止を後始末の手段にしないでください。
- 参照：[Stealth FindDistance](https://stealth.od.ua/api/FindDistance/)。本クライアント固有の初期値／範囲は FindDistance 18 / 0..255、FindVertical 2 / 0..120 です。上記の Basic 構文と拡張フィルターは本プロジェクトの仕様です。

### 内部関数：呼び出しから結果まで

実際の内部処理を示します。CountGroundInRange は完全なユーザー関数で、隠れた組み込みコマンドではありません。

#### 1. ExecuteStealthCompatibility

引数 0 個なら読み取り、1 個なら value を変換して書き込みます。メタデータは Integer と Unit を区別します。

引数なし：Integer、現在の制限（タイル単位の距離）。ID、個数、Boolean ではありません。0 は失敗ではなく範囲ゼロです。value あり：Unit、戻り値なし。TRUE/FALSE や変更前の値ではありません。設定後に FindDistance() で保存値を確認できます。

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 関数 `ExecuteStealthCompatibility`.

#### 2. GetFindDistance

Bridge は runtime の設定を読むか、整数を制限して保存します。ワールドは走査しません。

引数なし：Integer、現在の制限（タイル単位の距離）。ID、個数、Boolean ではありません。0 は失敗ではなく範囲ゼロです。value あり：Unit、戻り値なし。TRUE/FALSE や変更前の値ではありません。設定後に FindDistance() で保存値を確認できます。

プロジェクトのソース: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 関数 `GetFindDistance`.

#### 3. SetFindDistance

Bridge は runtime の設定を読むか、整数を制限して保存します。ワールドは走査しません。

省略可能な Integer。省略すると読み取り、value を指定すると設定します。0..255 に制限され、負数は無制限ではなく 0 になります。新規 runtime の既定値は 18。復元した状態では異なる場合があります。小数はゼロ方向へ切り捨て、decimal/0x の数値文字列も受け付けます。暗黙変換を避けるには Integer を使用してください。

プロジェクトのソース: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 関数 `SetFindDistance`.

#### 4. FindType

後続の検索は明示的な上書きがなければ設定を読みます。地面の Item と Mobile は対応する距離・高さフィルターを通ります。

FindTypeEx と FindTypesArrayEx は地面の検索で使用し、コンテナ内には適用しません。type、hue、Ignore、読み込み済みオブジェクトの条件は有効です。FindAtCoord は両方を無視します。拡張コマンドの明示的 distance/maxZ は既定値を上書きできます。これらの引数の -1 は既定値を使い、本設定を -1 にする場合とは異なります。FindList はコンテナ内でも Z を検査し、上記の例外は適用されません。

プロジェクトのソース: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 関数 `FindType`.

#### 5. FindList

後続の検索は明示的な上書きがなければ設定を読みます。地面の Item と Mobile は対応する距離・高さフィルターを通ります。

FindTypeEx と FindTypesArrayEx は地面の検索で使用し、コンテナ内には適用しません。type、hue、Ignore、読み込み済みオブジェクトの条件は有効です。FindAtCoord は両方を無視します。拡張コマンドの明示的 distance/maxZ は既定値を上書きできます。これらの引数の -1 は既定値を使い、本設定を -1 にする場合とは異なります。FindList はコンテナ内でも Z を検査し、上記の例外は適用されません。

プロジェクトのソース: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 関数 `FindList`.

現在のスクリプト runtime に保存し、そのプロシージャで共有します。独立した runtime の設定は別です。読み書きは検索や FindItem/FindCount/GetFoundItems の消去、パケット送信、移動、遠方オブジェクトの読み込みを行いません。


## 使用例

### 読み取り・設定・上限制御

```vb
# 読み取り・設定・上限制御
#
# 検索の既定の水平半径を読み取るか変更します。
#
# 引数なし：Integer、現在の制限（タイル単位の距離）。ID、個数、Boolean ではありません。0 は失敗ではなく範囲ゼロです。value
# あり：Unit、戻り値なし。TRUE/FALSE や変更前の値ではありません。設定後に FindDistance() で保存値を確認できます。

SUB Main()
    # previous に実際の設定を保存します。value:=5 は通常の制限、1000 は 255 への制限を示します。Print は別の読み取りで結果を表示します。Finally で
    # previous を復元します。

    VAR previous = UO.FindDistance()
    TRY
        UO.FindDistance(value:=5)
        UO.Print(CStr(UO.FindDistance()))
        UO.FindDistance(1000)
        UO.Print(CStr(UO.FindDistance()))
    FINALLY
        UO.FindDistance(previous)
    END TRY
END SUB
```

**パラメーターと実行の説明:**

- previous に実際の設定を保存します。value:=5 は通常の制限、1000 は 255 への制限を示します。Print は別の読み取りで結果を表示します。Finally で previous を復元します。

### 地面の一時検索

```vb
# 地面の一時検索
#
# 検索の既定の水平半径を読み取るか変更します。
#
# 引数なし：Integer、現在の制限（タイル単位の距離）。ID、個数、Boolean ではありません。0 は失敗ではなく範囲ゼロです。value
# あり：Unit、戻り値なし。TRUE/FALSE や変更前の値ではありません。設定後に FindDistance() で保存値を確認できます。

SUB Main()
    # previous は呼び出し元の設定です。5 は FindDistance のみ変更し、もう一方は保持します。0x0EED は金貨のグラフィック、-1 は全色、Container=-1
    # はワールド、FALSE はコンテナ再帰なしです。id は serial、<> 0 は存在確認です。FindCount はオブジェクト／スタック数です。Finally
    # は設定を戻し、結果リストは戻しません。

    VAR previous = UO.FindDistance()
    TRY
        UO.FindDistance(5)
        VAR id = UO.FindTypeEx(0x0EED, -1, -1, FALSE)
        IF id <> 0 THEN
            UO.Print(HEX(id) + ':' + CStr(UO.FindCount()))
        ELSE
            UO.Print('0')
        END IF
    FINALLY
        UO.FindDistance(previous)
    END TRY
END SUB
```

**パラメーターと実行の説明:**

- previous は呼び出し元の設定です。5 は FindDistance のみ変更し、もう一方は保持します。0x0EED は金貨のグラフィック、-1 は全色、Container=-1 はワールド、FALSE はコンテナ再帰なしです。id は serial、<> 0 は存在確認です。FindCount はオブジェクト／スタック数です。Finally は設定を戻し、結果リストは戻しません。

### 完全な CountGroundInRange 関数

```vb
# 完全な CountGroundInRange 関数
#
# 検索の既定の水平半径を読み取るか変更します。
#
# 引数なし：Integer、現在の制限（タイル単位の距離）。ID、個数、Boolean ではありません。0 は失敗ではなく範囲ゼロです。value
# あり：Unit、戻り値なし。TRUE/FALSE や変更前の値ではありません。設定後に FindDistance() で保存値を確認できます。

SUB Main()
    # CountGroundInRange(graphic, radius, height) は両設定を保存し、radius=5、height=10 で graphic=0x0EED を検索して
    # FindCount() を返します。1 スタックは 1 オブジェクトです。関数全体は Main の後にあります。Return で終了しても Finally
    # が両設定を復元し、検索結果は残ります。

    VAR count = CountGroundInRange(0x0EED, 5, 10)
    UO.Print(CStr(count))
END SUB

FUNCTION CountGroundInRange(graphic, radius, height)
    VAR oldDistance = UO.FindDistance()
    VAR oldVertical = UO.FindVertical()
    TRY
        UO.FindDistance(radius)
        UO.FindVertical(height)
        UO.FindTypeEx(graphic, -1, -1, FALSE)
        RETURN UO.FindCount()
    FINALLY
        UO.FindDistance(oldDistance)
        UO.FindVertical(oldVertical)
    END TRY
END FUNCTION
```

**パラメーターと実行の説明:**

- CountGroundInRange(graphic, radius, height) は両設定を保存し、radius=5、height=10 で graphic=0x0EED を検索して FindCount() を返します。1 スタックは 1 オブジェクトです。関数全体は Main の後にあります。Return で終了しても Finally が両設定を復元し、検索結果は残ります。
