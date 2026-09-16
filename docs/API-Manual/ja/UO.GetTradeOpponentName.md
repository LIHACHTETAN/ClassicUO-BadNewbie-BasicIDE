# UO.GetTradeOpponentName

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: ja -->

取引開始時に受信した相手の名前を読みます。

## 正確な構文

```text
UO.GetTradeOpponentName(TradeNum:Any) -> Any
```

## パラメーター

- `TradeNum` — 現在の整数番号：1..TradeCount()。0 と負数は無効です。serial ではありません。

## 戻り値

String：開始パケットで受信した名前。ウィンドウや名前がなければ空文字列。名前の再取得はしません。

## 動作

- GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade は 1 から、TradeContainer/TradeOpponent/TradeName と全 TradeCheck 形式は 0 からです。本クライアントはこの規約を維持します。外部のエンジン別資料では起点が異なる場合があります。
- ゲームスレッドで現在の World の開いたウィンドウを読み、破棄済みを除外します。読み取りはパケットも待機も発生させません。開閉や最前面への移動で UI 順序が変わるため、番号は永続IDではありません。
- ConfirmTrade と自分の TradeCheck 書き込みは同意の変更時だけ送信します。相手はサーバーが制御し、CancelTrade は一度だけ送信します。1/TRUE はローカル状態や処理を示し、転送完了ではありません。名前や両方のチェックでも品物が不変とは証明できません。

### 内部関数：呼び出しから結果まで

以下に C# の呼び出し経路、その後に実行可能な Basic 例を示します。ネットワークプロトコルをスクリプトで再実装するものではありません。

#### 1. ExecuteStealthCompatibility

登録は引数数で形式を選び、NumberConversions が数値変換します。2引数 TradeCheck は側 1/2 を検証して bridge の 0/1 に変換。従来の serial 表記は ToHex が作ります。

String：開始パケットで受信した名前。ウィンドウや名前がなければ空文字列。名前の再取得はしません。

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 関数 `ExecuteStealthCompatibility`.

#### 2. GetTradeOpponentName

Invoke はスクリプト中止を考慮してゲームスレッドに読み書きを渡し、選択した TradingGump の ID1/ID2、LocalSerial、OpponentName またはチェックを読みます。

取引開始時に受信した相手の名前を読みます。

プロジェクトのソース: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 関数 `GetTradeOpponentName`.

#### 3. FindNumberedTrade

FindNumberedTrade は 1 を引く前に number>0 を検証。FindTrade は負のインデックスを拒否し、この World の未破棄 TradingGump だけを列挙します。

GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade は 1 から、TradeContainer/TradeOpponent/TradeName と全 TradeCheck 形式は 0 からです。本クライアントはこの規約を維持します。外部のエンジン別資料では起点が異なる場合があります。

プロジェクトのソース: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 関数 `FindNumberedTrade`.

関数は省略せず定義し Main から呼び出しています。範囲やIDの確認は誤りを減らしますが、複数呼び出しは不可分ではなく、その間にウィンドウが変わり得ます。expectedPartner は保存したキャラクター serial で、価格や内容の検証ではありません。


## 使用例

### 直接の読み取りまたは操作

```vb
# 直接の読み取りまたは操作
#
# 取引開始時に受信した相手の名前を読みます。
#
# String：開始パケットで受信した名前。ウィンドウや名前がなければ空文字列。名前の再取得はしません。

SUB Main()
    # 一度呼び出し value/result に保存します。最初のインデックスは 0、最初の番号は 1（構文参照）。HEX は数値 serial、CStr は数や文字列を表示します。

    VAR value = UO.GetTradeOpponentName(1)
    UO.Print(CStr(value))
END SUB
```

**パラメーターと実行の説明:**

- 一度呼び出し value/result に保存します。最初のインデックスは 0、最初の番号は 1（構文参照）。HEX は数値 serial、CStr は数や文字列を表示します。

### 別の場面と引数

```vb
# 別の場面と引数
#
# 取引開始時に受信した相手の名前を読みます。
#
# String：開始パケットで受信した名前。ウィンドウや名前がなければ空文字列。名前の再取得はしません。

SUB Main()
    # total はウィンドウ数の保存値、index は現在の番号です。列挙は取引を承認しません。GetTradeContainer 例ではウィンドウ1の自分 (1) と相手 (2)
    # のコンテナを読みます。

    VAR total = UO.TradeCount()
    FOR VAR index = 1 TO total - 0
        VAR value = UO.GetTradeOpponentName(index)
        UO.Print(CStr(index) + ": " + CStr(value))
    NEXT
END SUB
```

**パラメーターと実行の説明:**

- total はウィンドウ数の保存値、index は現在の番号です。列挙は取引を承認しません。GetTradeContainer 例ではウィンドウ1の自分 (1) と相手 (2) のコンテナを読みます。

### 完全な補助関数

```vb
# 完全な補助関数
#
# 取引開始時に受信した相手の名前を読みます。
#
# String：開始パケットで受信した名前。ウィンドウや名前がなければ空文字列。名前の再取得はしません。

SUB Main()
    # 関数は省略せず定義し Main から呼び出しています。範囲やIDの確認は誤りを減らしますが、複数呼び出しは不可分ではなく、その間にウィンドウが変わり得ます。expectedPartner
    # は保存したキャラクター serial で、価格や内容の検証ではありません。

    VAR value = ReadTradeValue(1)
    UO.Print(CStr(value))
END SUB

FUNCTION ReadTradeValue(index)
    VAR total = UO.TradeCount()
    IF index < 1 OR index >= total + 1 THEN
        RETURN ""
    END IF
    RETURN UO.GetTradeOpponentName(index)
END FUNCTION
```

**パラメーターと実行の説明:**

- 関数は省略せず定義し Main から呼び出しています。範囲やIDの確認は誤りを減らしますが、複数呼び出しは不可分ではなく、その間にウィンドウが変わり得ます。expectedPartner は保存したキャラクター serial で、価格や内容の検証ではありません。
