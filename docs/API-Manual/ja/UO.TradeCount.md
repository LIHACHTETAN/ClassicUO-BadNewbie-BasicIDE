# UO.TradeCount

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: ja -->

開いている取引ウィンドウの数を返します。

## 正確な構文

```text
UO.TradeCount() -> Integer
```

## パラメーター

引数はありません。

## 戻り値

Integer：0 以上のウィンドウ数。Boolean ではありません。有無は > 0 で確認します。

## 動作

- GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade は 1 から、TradeContainer/TradeOpponent/TradeName と全 TradeCheck 形式は 0 からです。本クライアントはこの規約を維持します。外部のエンジン別資料では起点が異なる場合があります。
- ゲームスレッドで現在の World の開いたウィンドウを読み、破棄済みを除外します。読み取りはパケットも待機も発生させません。開閉や最前面への移動で UI 順序が変わるため、番号は永続IDではありません。
- ConfirmTrade と自分の TradeCheck 書き込みは同意の変更時だけ送信します。相手はサーバーが制御し、CancelTrade は一度だけ送信します。1/TRUE はローカル状態や処理を示し、転送完了ではありません。名前や両方のチェックでも品物が不変とは証明できません。

### 内部関数：呼び出しから結果まで

以下に C# の呼び出し経路、その後に実行可能な Basic 例を示します。ネットワークプロトコルをスクリプトで再実装するものではありません。

#### 1. TradeCount

登録は引数数で形式を選び、NumberConversions が数値変換します。2引数 TradeCheck は側 1/2 を検証して bridge の 0/1 に変換。従来の serial 表記は ToHex が作ります。

Integer：0 以上のウィンドウ数。Boolean ではありません。有無は > 0 で確認します。

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 関数 `TradeCount`.

#### 2. TradeCount

Invoke はスクリプト中止を考慮してゲームスレッドに読み書きを渡し、選択した TradingGump の ID1/ID2、LocalSerial、OpponentName またはチェックを読みます。

開いている取引ウィンドウの数を返します。

プロジェクトのソース: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 関数 `TradeCount`.

関数は省略せず定義し Main から呼び出しています。範囲やIDの確認は誤りを減らしますが、複数呼び出しは不可分ではなく、その間にウィンドウが変わり得ます。expectedPartner は保存したキャラクター serial で、価格や内容の検証ではありません。


## 使用例

### 直接の読み取りまたは操作

```vb
# 直接の読み取りまたは操作
#
# 開いている取引ウィンドウの数を返します。
#
# Integer：0 以上のウィンドウ数。Boolean ではありません。有無は > 0 で確認します。

SUB Main()
    # 一度呼び出し value/result に保存します。最初のインデックスは 0、最初の番号は 1（構文参照）。HEX は数値 serial、CStr は数や文字列を表示します。

    VAR value = UO.TradeCount()
    UO.Print(CStr(value))
END SUB
```

**パラメーターと実行の説明:**

- 一度呼び出し value/result に保存します。最初のインデックスは 0、最初の番号は 1（構文参照）。HEX は数値 serial、CStr は数や文字列を表示します。

### 別の場面と引数

```vb
# 別の場面と引数
#
# 開いている取引ウィンドウの数を返します。
#
# Integer：0 以上のウィンドウ数。Boolean ではありません。有無は > 0 で確認します。

SUB Main()
    # before/after は500ミリ秒間隔の別々のスナップショットです。特定の取引を待つ処理ではなく、途中の変化を見逃す場合があります。

    VAR before = UO.TradeCount()
    WAIT(500)
    VAR after = UO.TradeCount()
    UO.Print(CStr(before) + " -> " + CStr(after))
END SUB
```

**パラメーターと実行の説明:**

- before/after は500ミリ秒間隔の別々のスナップショットです。特定の取引を待つ処理ではなく、途中の変化を見逃す場合があります。

### 完全な補助関数

```vb
# 完全な補助関数
#
# 開いている取引ウィンドウの数を返します。
#
# Integer：0 以上のウィンドウ数。Boolean ではありません。有無は > 0 で確認します。

SUB Main()
    # 関数は省略せず定義し Main から呼び出しています。範囲やIDの確認は誤りを減らしますが、複数呼び出しは不可分ではなく、その間にウィンドウが変わり得ます。expectedPartner
    # は保存したキャラクター serial で、価格や内容の検証ではありません。

    VAR value = ReadTradeState()
    UO.Print(CStr(value))
END SUB

FUNCTION ReadTradeState()
    RETURN UO.TradeCount()
END FUNCTION
```

**パラメーターと実行の説明:**

- 関数は省略せず定義し Main から呼び出しています。範囲やIDの確認は誤りを減らしますが、複数呼び出しは不可分ではなく、その間にウィンドウが変わり得ます。expectedPartner は保存したキャラクター serial で、価格や内容の検証ではありません。
