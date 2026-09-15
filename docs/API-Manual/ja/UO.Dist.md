# UO.Dist

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: ja -->

X と Y の絶対差の大きい方を使って、二点間のタイル数を計算します。

## 正確な構文

```text
UO.Dist(Xfrom:Any, Yfrom:Any, Xto:Any, Yto:Any) -> Integer
```

## パラメーター

- `Xfrom` — 始点の X。
- `Yfrom` — 始点の Y。
- `Xto` — 終点の X。
- `Yto` — 終点の Y。

## 戻り値

有効な座標では非負の Integer タイル数です。0 は同じ XY、1 は一タイルです。成功フラグではありません。別の比較 distance<=2 が 1/True または 0/False を返します。

## 動作

- 通信、待機、マップ読込、障害物、Z、ワールドの検査を行わない純粋な計算です。通行可能な経路の探索や到着保証ではありません。同じ座標系の点を使ってください。迂回路は長くなり得ます。
- 四つとも必須です。仕様範囲 0..65535 の Integer ワールド座標を渡してください。Any は汎用アダプターを示し、物体 ID ではありません。既定値、コンテナ内座標、第五の Z、単一物体のオーバーロードはありません。
- Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom))。始点と終点を入れ替えても同じです。ユークリッド距離、差の合計、障害物を避ける歩数ではありません。

### 内部関数：呼び出しから結果まで

第三例は通常のスクリプト関数でアルゴリズムを再現します。エンジンがこのサンプル関数を呼ぶという意味ではありません。

#### 1. ExecuteStealthCompatibility

アダプターが位置 0..3 を Xfrom,Yfrom,Xto,Yto の順に整数として読み、計算関数に渡します。

有効な座標では非負の Integer タイル数です。0 は同じ XY、1 は一タイルです。成功フラグではありません。別の比較 distance<=2 が 1/True または 0/False を返します。

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 関数 `ExecuteStealthCompatibility`.

#### 2. GetDistance

`GetDistance(int,int,int,int): dx=Math.Abs(x1-x2); dy=Math.Abs(y1-y2); return Math.Max(dx,dy).`

Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom))。始点と終点を入れ替えても同じです。ユークリッド距離、差の合計、障害物を避ける歩数ではありません。

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 関数 `GetDistance`.

通信、待機、マップ読込、障害物、Z、ワールドの検査を行わない純粋な計算です。通行可能な経路の探索や到着保証ではありません。同じ座標系の点を使ってください。迂回路は長くなり得ます。


## 使用例

### 直接計算

```vb
# 直接計算
#
# X と Y の絶対差の大きい方を使って、二点間のタイル数を計算します。
#
# 有効な座標では非負の Integer タイル数です。0 は同じ XY、1 は一タイルです。成功フラグではありません。別の比較 distance<=2 が 1/True または
# 0/False を返します。

SUB Main()
    # (100,100) と (103,104) の絶対差は 3 と 4 です。Main は大きい方の Integer 4 を返します。
    # 有効な座標では非負の Integer タイル数です。0 は同じ XY、1 は一タイルです。成功フラグではありません。別の比較 distance<=2 が 1/True または
    # 0/False を返します。
    # Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom))。始点と終点を入れ替えても同じです。ユークリッド距離、差の合計、障害物を避ける歩数ではありません。

    Return UO.Dist(100,100,103,104)
END SUB
```

**パラメーターと実行の説明:**

- (100,100) と (103,104) の絶対差は 3 と 4 です。Main は大きい方の Integer 4 を返します。
- 有効な座標では非負の Integer タイル数です。0 は同じ XY、1 は一タイルです。成功フラグではありません。別の比較 distance<=2 が 1/True または 0/False を返します。
- Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom))。始点と終点を入れ替えても同じです。ユークリッド距離、差の合計、障害物を避ける歩数ではありません。

### 結果の正しい判定

```vb
# 結果の正しい判定
#
# X と Y の絶対差の大きい方を使って、二点間のタイル数を計算します。
#
# 有効な座標では非負の Integer タイル数です。0 は同じ XY、1 は一タイルです。成功フラグではありません。別の比較 distance<=2 が 1/True または
# 0/False を返します。

SUB Main()
    # (100,100) と (101,99) の距離は 1、別の比較 distance<=2 は True=1 です。"1:1" の最初は距離、後ろは論理結果です。
    # 有効な座標では非負の Integer タイル数です。0 は同じ XY、1 は一タイルです。成功フラグではありません。別の比較 distance<=2 が 1/True または
    # 0/False を返します。
    # Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom))。始点と終点を入れ替えても同じです。ユークリッド距離、差の合計、障害物を避ける歩数ではありません。

    Dim distance=UO.Dist(100,100,101,99)
    Dim close=distance<=2
    Return CStr(distance) & ":" & CStr(close)
END SUB
```

**パラメーターと実行の説明:**

- (100,100) と (101,99) の距離は 1、別の比較 distance<=2 は True=1 です。"1:1" の最初は距離、後ろは論理結果です。
- 有効な座標では非負の Integer タイル数です。0 は同じ XY、1 は一タイルです。成功フラグではありません。別の比較 distance<=2 が 1/True または 0/False を返します。
- Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom))。始点と終点を入れ替えても同じです。ユークリッド距離、差の合計、障害物を避ける歩数ではありません。

### 完全なスクリプト再現

```vb
# 完全なスクリプト再現
#
# X と Y の絶対差の大きい方を使って、二点間のタイル数を計算します。
#
# 有効な座標では非負の Integer タイル数です。0 は同じ XY、1 は一タイルです。成功フラグではありません。別の比較 distance<=2 が 1/True または
# 0/False を返します。

SUB Main()
    # UO.Dist と RebuildTileDistance は共に 4、Main は "4:4" を返します。完全なヘルパーは Abs 差を求め、大きい方を返します。追加 API
    # ではなくサンプルコードです。
    # 有効な座標では非負の Integer タイル数です。0 は同じ XY、1 は一タイルです。成功フラグではありません。別の比較 distance<=2 が 1/True または
    # 0/False を返します。
    # Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom))。始点と終点を入れ替えても同じです。ユークリッド距離、差の合計、障害物を避ける歩数ではありません。

    Dim actual=UO.Dist(100,100,103,104)
    Dim rebuilt=RebuildTileDistance(100,100,103,104)
    Return CStr(actual) & ":" & CStr(rebuilt)
END SUB

Function RebuildTileDistance(Xfrom, Yfrom, Xto, Yto) As Integer
    Dim dx = Abs(Xto-Xfrom)
    Dim dy = Abs(Yto-Yfrom)
    If dx>dy Then
        Return dx
    End If
    Return dy
End Function
```

**パラメーターと実行の説明:**

- UO.Dist と RebuildTileDistance は共に 4、Main は "4:4" を返します。完全なヘルパーは Abs 差を求め、大きい方を返します。追加 API ではなくサンプルコードです。
- 有効な座標では非負の Integer タイル数です。0 は同じ XY、1 は一タイルです。成功フラグではありません。別の比較 distance<=2 が 1/True または 0/False を返します。
- Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom))。始点と終点を入れ替えても同じです。ユークリッド距離、差の合計、障害物を避ける歩数ではありません。
