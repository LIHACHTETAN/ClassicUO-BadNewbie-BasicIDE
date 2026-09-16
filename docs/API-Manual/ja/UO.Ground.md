# UO.Ground

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: ja -->

検索先コンテナや移動先の引数に渡す、地面を表す特別な値を返します。

## 正確な構文

```text
UO.Ground() -> Integer
```

## パラメーター

引数はありません。

## 戻り値

Integer、常に 0。このゼロは有効な地面指定値であり、FALSE、検索失敗、ID、グラフィック、マップ番号、座標ではありません。成功判定には Ground() 自体ではなく、それを使った検索や移動の結果を使います。

## 動作

- 引数はありません。Ground() 単体は検索、移動、ターゲット表示、パケット送信、検索結果の変更を行いません。ログイン前も 0 を返します。
- FindType、FindList、Count、FindTypeEx、FindTypesArrayEx、CountEx、MoveItem の container/destination に渡します。検索対象は読み込み済みオブジェクトで、遠方のセルは読み込みません。地面の X/Y/Z はワールド座標であり、コンテナ画面のピクセルではありません。
- FindType(type, color) は引き続き所持品を検索します。第 2 引数は色です。地面は FindType(type, color, UO.Ground()) と指定します。従来の簡略 FindType/MoveItem の -1 は所持品、互換 FindTypeEx/FindTypesArrayEx/CountEx の -1 は地面にも使用できます。コマンド間で数値を流用せず UO.Ground() または名前 ground を推奨します。
- 一次資料：[Stealth Ground](https://stealth.od.ua/api/Ground/)。上記の規則と例は本クライアントの仕様です。

### 内部関数：呼び出しから結果まで

実際の内部処理です。FindGroundTypes は完全なユーザー関数で、追加の組み込みコマンドではありません。

#### 1. ExecuteStealthCompatibility

引数なしの runtime 分岐はゲーム bridge を呼ばず Integer 0 を返します。

Integer、常に 0。このゼロは有効な地面指定値であり、FALSE、検索失敗、ID、グラフィック、マップ番号、座標ではありません。成功判定には Ground() 自体ではなく、それを使った検索や移動の結果を使います。

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 関数 `ExecuteStealthCompatibility`.

#### 2. ConvertContainer

簡略検索は明示的な 0 を内部の地面指定へ変換し、-1 は所持品の既定値として残します。互換検索は 0 と従来の -1 を地面として受け付け、名前付きコンテナは別に解決します。

FindType(type, color) は引き続き所持品を検索します。第 2 引数は色です。地面は FindType(type, color, UO.Ground()) と指定します。従来の簡略 FindType/MoveItem の -1 は所持品、互換 FindTypeEx/FindTypesArrayEx/CountEx の -1 は地面にも使用できます。コマンド間で数値を流用せず UO.Ground() または名前 ground を推奨します。

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 関数 `ConvertContainer`.

#### 3. ConvertStealthSearchContainer

簡略検索は明示的な 0 を内部の地面指定へ変換し、-1 は所持品の既定値として残します。互換検索は 0 と従来の -1 を地面として受け付け、名前付きコンテナは別に解決します。

FindType(type, color) は引き続き所持品を検索します。第 2 引数は色です。地面は FindType(type, color, UO.Ground()) と指定します。従来の簡略 FindType/MoveItem の -1 は所持品、互換 FindTypeEx/FindTypesArrayEx/CountEx の -1 は地面にも使用できます。コマンド間で数値を流用せず UO.Ground() または名前 ground を推奨します。

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 関数 `ConvertStealthSearchContainer`.

#### 4. ResolveTransferDestination

移動先の解析では地面を 0 として保持します。bridge はワールド座標を使用し、ドロップパケットのコンテナ欄は 0xFFFFFFFF となります。API 値とパケット欄は表現が異なります。

0x40001001 を操作可能なアイテムの serial に変更します。IsObjectExists は読み込み済みの存在を検査します。MoveItem(item, amount, destination, X, Y, Z)：amount=0 は全スタック、Ground() は地面、GetX/GetY/GetZ はプレイヤーのワールド位置です。result=1 はクライアントが要求を受け付けたこと、0 は不成立です。Ground() の戻り値でもサーバーの完了応答でもありません。

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 関数 `ResolveTransferDestination`.

#### 5. MoveItem

移動先の解析では地面を 0 として保持します。bridge はワールド座標を使用し、ドロップパケットのコンテナ欄は 0xFFFFFFFF となります。API 値とパケット欄は表現が異なります。

0x40001001 を操作可能なアイテムの serial に変更します。IsObjectExists は読み込み済みの存在を検査します。MoveItem(item, amount, destination, X, Y, Z)：amount=0 は全スタック、Ground() は地面、GetX/GetY/GetZ はプレイヤーのワールド位置です。result=1 はクライアントが要求を受け付けたこと、0 は不成立です。Ground() の戻り値でもサーバーの完了応答でもありません。

プロジェクトのソース: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 関数 `MoveItem`.

引数はありません。Ground() 単体は検索、移動、ターゲット表示、パケット送信、検索結果の変更を行いません。ログイン前も 0 を返します。


## 使用例

### 指定値を読む

```vb
# 指定値を読む
#
# 検索先コンテナや移動先の引数に渡す、地面を表す特別な値を返します。
#
# Integer、常に 0。このゼロは有効な地面指定値であり、FALSE、検索失敗、ID、グラフィック、マップ番号、座標ではありません。成功判定には Ground()
# 自体ではなく、それを使った検索や移動の結果を使います。

SUB Main()
    # destination は Integer 0 を受け取り、Print が表示します。何も置きません。

    VAR destination = UO.Ground()
    UO.Print(CStr(destination))
END SUB
```

**パラメーターと実行の説明:**

- destination は Integer 0 を受け取り、Print が表示します。何も置きません。

### 地面の金貨スタックを探す

```vb
# 地面の金貨スタックを探す
#
# 検索先コンテナや移動先の引数に渡す、地面を表す特別な値を返します。
#
# Integer、常に 0。このゼロは有効な地面指定値であり、FALSE、検索失敗、ID、グラフィック、マップ番号、座標ではありません。成功判定には Ground()
# 自体ではなく、それを使った検索や移動の結果を使います。

SUB Main()
    # 0x0EED は金貨のグラフィック、第 2 引数の -1 は全色です。Ground() はワールド、FALSE はコンテナ再帰なしです。FindTypeEx は serial または 0
    # を返し、<> 0 はその serial を検査します。FindDistance/FindVertical と Ignore が適用されます。

    VAR id = UO.FindTypeEx(0x0EED, -1, UO.Ground(), FALSE)
    IF id <> 0 THEN
        UO.Print(HEX(id))
    ELSE
        UO.Print('0')
    END IF
END SUB
```

**パラメーターと実行の説明:**

- 0x0EED は金貨のグラフィック、第 2 引数の -1 は全色です。Ground() はワールド、FALSE はコンテナ再帰なしです。FindTypeEx は serial または 0 を返し、<> 0 はその serial を検査します。FindDistance/FindVertical と Ignore が適用されます。

### 2 種類のグラフィックを探す完全な関数

```vb
# 2 種類のグラフィックを探す完全な関数
#
# 検索先コンテナや移動先の引数に渡す、地面を表す特別な値を返します。
#
# Integer、常に 0。このゼロは有効な地面指定値であり、FALSE、検索失敗、ID、グラフィック、マップ番号、座標ではありません。成功判定には Ground()
# 自体ではなく、それを使った検索や移動の結果を使います。

SUB Main()
    # FindGroundTypes(firstType, secondType, radius, height) は金貨 0x0EED と黒真珠 0x0F7A を
    # radius=5、height=10 で探します。DIM types[1] は 2 要素、colors[0] と containers[0] は各 1 要素です。スタックは 1
    # オブジェクトで、型／色は候補のいずれか、コンテナの重複による ID 重複はありません。保存した serial 配列を返し、Finally が両設定を復元、Main が ID
    # を表示します。関数全体を記載しています。

    VAR ids = FindGroundTypes(0x0EED, 0x0F7A, 5, 10)
    FOR EACH id IN ids
        UO.Print(HEX(id))
    NEXT
END SUB

FUNCTION FindGroundTypes(firstType, secondType, radius, height)
    VAR oldDistance = UO.FindDistance()
    VAR oldVertical = UO.FindVertical()
    DIM types[1]
    types[0] = firstType
    types[1] = secondType
    DIM colors[0]
    colors[0] = -1
    DIM containers[0]
    containers[0] = UO.Ground()
    TRY
        UO.FindDistance(radius)
        UO.FindVertical(height)
        UO.FindTypesArrayEx(types, colors, containers, FALSE)
        RETURN UO.GetFoundItems()
    FINALLY
        UO.FindDistance(oldDistance)
        UO.FindVertical(oldVertical)
    END TRY
END FUNCTION
```

**パラメーターと実行の説明:**

- FindGroundTypes(firstType, secondType, radius, height) は金貨 0x0EED と黒真珠 0x0F7A を radius=5、height=10 で探します。DIM types[1] は 2 要素、colors[0] と containers[0] は各 1 要素です。スタックは 1 オブジェクトで、型／色は候補のいずれか、コンテナの重複による ID 重複はありません。保存した serial 配列を返し、Finally が両設定を復元、Main が ID を表示します。関数全体を記載しています。

### 既知のアイテムをプレイヤーのセルへ置く

```vb
# 既知のアイテムをプレイヤーのセルへ置く
#
# 検索先コンテナや移動先の引数に渡す、地面を表す特別な値を返します。
#
# Integer、常に 0。このゼロは有効な地面指定値であり、FALSE、検索失敗、ID、グラフィック、マップ番号、座標ではありません。成功判定には Ground()
# 自体ではなく、それを使った検索や移動の結果を使います。

SUB Main()
    # 0x40001001 を操作可能なアイテムの serial に変更します。IsObjectExists は読み込み済みの存在を検査します。MoveItem(item, amount,
    # destination, X, Y, Z)：amount=0 は全スタック、Ground() は地面、GetX/GetY/GetZ はプレイヤーのワールド位置です。result=1
    # はクライアントが要求を受け付けたこと、0 は不成立です。Ground() の戻り値でもサーバーの完了応答でもありません。

    VAR item = 0x40001001
    IF UO.IsObjectExists(item) THEN
        VAR result = UO.MoveItem(item, 0, UO.Ground(), UO.GetX('self'), UO.GetY('self'), UO.GetZ('self'))
    END IF
END SUB
```

**パラメーターと実行の説明:**

- 0x40001001 を操作可能なアイテムの serial に変更します。IsObjectExists は読み込み済みの存在を検査します。MoveItem(item, amount, destination, X, Y, Z)：amount=0 は全スタック、Ground() は地面、GetX/GetY/GetZ はプレイヤーのワールド位置です。result=1 はクライアントが要求を受け付けたこと、0 は不成立です。Ground() の戻り値でもサーバーの完了応答でもありません。
