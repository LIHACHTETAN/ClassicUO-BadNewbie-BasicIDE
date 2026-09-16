# UO.TradeCheck

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: ja -->

同意チェックを読みます。3引数形式では自分のチェックを変更できます。

## 正確な構文

```text
UO.TradeCheck(TradeNum:Any, Num:Any) -> Any
UO.TradeCheck(windowIndex:Any) -> Integer
UO.TradeCheck(windowIndex:Any, checkbox:Any, stateValue:Any) -> Integer
```

## パラメーター

- `windowIndex` — 現在の整数インデックス：0..TradeCount()-1。負数や存在しない指定は空の結果になります。serial ではありません。
- `TradeNum` — 現在の整数インデックス：0..TradeCount()-1。負数や存在しない指定は空の結果になります。serial ではありません。
- `Num` — 2引数形式のみ：1 は自分、2 は相手のチェック。他は 0。ここでは TradeNum は 0 からです。
- `checkbox` — 3引数形式のみ：0 は自分、1 は読み取り専用の相手のチェック。他は 0 を返します。
- `stateValue` — checkbox=0 の場合のみ：0/FALSE で解除、0 以外の数値/TRUE で設定。checkbox=1 では無視します。

## 戻り値

Integer：選んだチェックがオンなら 1 = TRUE、オフ・ウィンドウなし・側の指定が無効なら 0 = FALSE。書き込み後は状態を返し、取引成功を意味しません。解除の戻り値は 0 です。

論理的な結果です。1 = TRUE、0 = FALSE。VAR result = command(...) で保存した後は IF result = TRUE THEN または IF result = 1 THEN、否定時は IF result = FALSE THEN または IF result = 0 THEN と書けます。TRUE/FALSE に引用符は付けません。一度呼び出して保存してください。再呼び出しは動作を繰り返したり、変更後の状態を読んだりする場合があります。

## 動作

- GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade は 1 から、TradeContainer/TradeOpponent/TradeName と全 TradeCheck 形式は 0 からです。本クライアントはこの規約を維持します。外部のエンジン別資料では起点が異なる場合があります。
- ゲームスレッドで現在の World の開いたウィンドウを読み、破棄済みを除外します。読み取りはパケットも待機も発生させません。開閉や最前面への移動で UI 順序が変わるため、番号は永続IDではありません。
- ConfirmTrade と自分の TradeCheck 書き込みは同意の変更時だけ送信します。相手はサーバーが制御し、CancelTrade は一度だけ送信します。1/TRUE はローカル状態や処理を示し、転送完了ではありません。名前や両方のチェックでも品物が不変とは証明できません。

### 内部関数：呼び出しから結果まで

以下に C# の呼び出し経路、その後に実行可能な Basic 例を示します。ネットワークプロトコルをスクリプトで再実装するものではありません。

#### 1. TradeCheck

登録は引数数で形式を選び、NumberConversions が数値変換します。2引数 TradeCheck は側 1/2 を検証して bridge の 0/1 に変換。従来の serial 表記は ToHex が作ります。

Integer：選んだチェックがオンなら 1 = TRUE、オフ・ウィンドウなし・側の指定が無効なら 0 = FALSE。書き込み後は状態を返し、取引成功を意味しません。解除の戻り値は 0 です。

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 関数 `TradeCheck`.

#### 2. TradeCheck

Invoke はスクリプト中止を考慮してゲームスレッドに読み書きを渡し、選択した TradingGump の ID1/ID2、LocalSerial、OpponentName またはチェックを読みます。

同意チェックを読みます。3引数形式では自分のチェックを変更できます。

プロジェクトのソース: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 関数 `TradeCheck`.

#### 3. FindTrade

FindNumberedTrade は 1 を引く前に number>0 を検証。FindTrade は負のインデックスを拒否し、この World の未破棄 TradingGump だけを列挙します。

GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade は 1 から、TradeContainer/TradeOpponent/TradeName と全 TradeCheck 形式は 0 からです。本クライアントはこの規約を維持します。外部のエンジン別資料では起点が異なる場合があります。

プロジェクトのソース: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 関数 `FindTrade`.

#### 4. AcceptTrade

自分のチェック変更時に GameActions.AcceptTrade がコード2、ID1、状態で Send_TradeResponse を呼びます。読み取りと同じ状態の設定は送信しません。

Integer：選んだチェックがオンなら 1 = TRUE、オフ・ウィンドウなし・側の指定が無効なら 0 = FALSE。書き込み後は状態を返し、取引成功を意味しません。解除の戻り値は 0 です。

プロジェクトのソース: `src/ClassicUO.Client/Game/GameActions.cs`; 関数 `AcceptTrade`.

関数は省略せず定義し Main から呼び出しています。範囲やIDの確認は誤りを減らしますが、複数呼び出しは不可分ではなく、その間にウィンドウが変わり得ます。expectedPartner は保存したキャラクター serial で、価格や内容の検証ではありません。


## 使用例

### 直接の読み取りまたは操作

```vb
# 直接の読み取りまたは操作
#
# 同意チェックを読みます。3引数形式では自分のチェックを変更できます。
#
# Integer：選んだチェックがオンなら 1 = TRUE、オフ・ウィンドウなし・側の指定が無効なら 0 = FALSE。書き込み後は状態を返し、取引成功を意味しません。解除の戻り値は 0
# です。
#
# 論理的な結果です。1 = TRUE、0 = FALSE。VAR result = command(...) で保存した後は IF result = TRUE THEN または IF
# result = 1 THEN、否定時は IF result = FALSE THEN または IF result = 0 THEN と書けます。TRUE/FALSE
# に引用符は付けません。一度呼び出して保存してください。再呼び出しは動作を繰り返したり、変更後の状態を読んだりする場合があります。

SUB Main()
    # TradeCheck(0) と TradeCheck(0,1) は最初のウィンドウの自分、TradeCheck(0,2) は相手のチェックを読みます。書き込みや自動承認はしません。

    VAR own = UO.TradeCheck(0)
    VAR sameOwn = UO.TradeCheck(0, 1)
    VAR other = UO.TradeCheck(0, 2)
    UO.Print(CStr(own) + "/" + CStr(sameOwn) + "/" + CStr(other))
END SUB
```

**パラメーターと実行の説明:**

- TradeCheck(0) と TradeCheck(0,1) は最初のウィンドウの自分、TradeCheck(0,2) は相手のチェックを読みます。書き込みや自動承認はしません。

### 別の場面と引数

```vb
# 別の場面と引数
#
# 同意チェックを読みます。3引数形式では自分のチェックを変更できます。
#
# Integer：選んだチェックがオンなら 1 = TRUE、オフ・ウィンドウなし・側の指定が無効なら 0 = FALSE。書き込み後は状態を返し、取引成功を意味しません。解除の戻り値は 0
# です。
#
# 論理的な結果です。1 = TRUE、0 = FALSE。VAR result = command(...) で保存した後は IF result = TRUE THEN または IF
# result = 1 THEN、否定時は IF result = FALSE THEN または IF result = 0 THEN と書けます。TRUE/FALSE
# に引用符は付けません。一度呼び出して保存してください。再呼び出しは動作を繰り返したり、変更後の状態を読んだりする場合があります。

SUB Main()
    # TradeCheck(0,0,FALSE) は自分の同意を解除します。TradeCheck(0,1,FALSE) は相手を読むだけで、FALSE で相手を変更できません。解除後の 0
    # は正常です。

    VAR cleared = UO.TradeCheck(0, 0, FALSE)
    VAR other = UO.TradeCheck(0, 1, FALSE)
    UO.Print(CStr(cleared) + "/" + CStr(other))
END SUB
```

**パラメーターと実行の説明:**

- TradeCheck(0,0,FALSE) は自分の同意を解除します。TradeCheck(0,1,FALSE) は相手を読むだけで、FALSE で相手を変更できません。解除後の 0 は正常です。

### 完全な補助関数

```vb
# 完全な補助関数
#
# 同意チェックを読みます。3引数形式では自分のチェックを変更できます。
#
# Integer：選んだチェックがオンなら 1 = TRUE、オフ・ウィンドウなし・側の指定が無効なら 0 = FALSE。書き込み後は状態を返し、取引成功を意味しません。解除の戻り値は 0
# です。
#
# 論理的な結果です。1 = TRUE、0 = FALSE。VAR result = command(...) で保存した後は IF result = TRUE THEN または IF
# result = 1 THEN、否定時は IF result = FALSE THEN または IF result = 0 THEN と書けます。TRUE/FALSE
# に引用符は付けません。一度呼び出して保存してください。再呼び出しは動作を繰り返したり、変更後の状態を読んだりする場合があります。

SUB Main()
    # 関数は省略せず定義し Main から呼び出しています。範囲やIDの確認は誤りを減らしますが、複数呼び出しは不可分ではなく、その間にウィンドウが変わり得ます。expectedPartner
    # は保存したキャラクター serial で、価格や内容の検証ではありません。

    VAR accepted = BothAccepted(0)
    IF accepted = TRUE THEN
        UO.Print("Both boxes are checked; server completion is not known")
    END IF
END SUB

FUNCTION BothAccepted(index)
    IF index < 0 OR index >= UO.TradeCount() THEN
        RETURN FALSE
    END IF
    VAR own = UO.TradeCheck(index, 1)
    VAR other = UO.TradeCheck(index, 2)
    RETURN own = TRUE AND other = TRUE
END FUNCTION
```

**パラメーターと実行の説明:**

- 関数は省略せず定義し Main から呼び出しています。範囲やIDの確認は誤りを減らしますが、複数呼び出しは不可分ではなく、その間にウィンドウが変わり得ます。expectedPartner は保存したキャラクター serial で、価格や内容の検証ではありません。
