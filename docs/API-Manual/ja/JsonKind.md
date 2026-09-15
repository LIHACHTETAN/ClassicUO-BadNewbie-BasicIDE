# JsonKind

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: ja -->

JSONに対応する値の種類を調べます。

## 正確な構文

```text
JsonKind(value:Any) -> String
```

## パラメーター

- `value` — 数値、String、配列、List、Dictionary、JsonBoolean、JsonNull。DictionaryのキーはStringのみ。共有参照は可能ですが循環参照はエラーです。

## 戻り値

String：number、string、array、object、boolean、null、unsupported。最外層の種類のみ検査します。

## 動作

- UO.を付けないローカルBasic関数で、ゲームパケットは送りません。JsonParse/JsonStringifyはメモリー内で動作します。Basic Trueは数値1になるため、JSON trueにはJsonBoolean(True)を使います。JsonNull()はnullと0を区別します。
- 有限数のみ。整数値が±9007199254740991を超えるとエラーです。大きなIDはStringで保存してください。他の数値はDouble精度です。厳密なUTF-8を使用し、入力BOMは許可、出力BOMはありません。不正Unicodeはエラーです。
- 上限：1048576 UTF-16コード単位、4MiB、64段のコンテナー、100000値ノード。超過はエラーです。解析・読込は新しいコレクションを作り、保存はメモリーオブジェクトを複製しません。
- Saveは全データを検証し、親フォルダーを作成し、隣接する一意の一時ファイルへ書込み、バッファーを排出して移動/置換します。置換前の失敗・取消は旧ファイルを保持します。一時ファイルはOSが許す場合に削除します。完了済みの置換は取り消しません。
- 256値ごと、4096バイト/文字のブロック間、置換前に一時停止/停止を確認します。追加スレッドは作りません。個々のOS呼出しは強制中断できません。同時保存では最後に成功した置換が残り、DBトランザクションではありません。

### 内部関数：呼び出しから結果まで

JSONに対応する値の種類を調べます。

#### 1. Kind

数値、String、配列、List、Dictionary、JsonBoolean、JsonNull。DictionaryのキーはStringのみ。共有参照は可能ですが循環参照はエラーです。

String：number、string、array、object、boolean、null、unsupported。最外層の種類のみ検査します。

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; 関数 `Kind`.

Config.Load(fileName, defaults)は新しいDictionaryを返します。保存済みの最上位キーでdefaultsのディープコピーを上書きし、入れ子のオブジェクトは全体を置換します。Config.Save(fileName, settings)は明示的に保存し、戻り値なし。Config.GetFlag(settings, key, fallback=False)は1/Trueまたは0/Falseを返し、既存値が真偽値以外ならエラーです。Config.SetFlag(settings, key, value)はメモリーのみ変更し、戻り値なし。Load/SaveはStringキーのDictionaryが必要です。内部Private RequireObjectは外側の型を検査し、JSON変換が全内容を検証します。


## 使用例

### JsonKind · 1

```vb
# JsonKind · 1
#
# JSONに対応する値の種類を調べます。
#
# String：number、string、array、object、boolean、null、unsupported。最外層の種類のみ検査します。

Option Explicit On
Sub Main()
    # Mainを実行します。value=12 → "number"; value="12" → "string".

    Return JsonKind(12) & ':' & JsonKind('12')
End Sub
```

**パラメーターと実行の説明:**

- Mainを実行します。value=12 → "number"; value="12" → "string".

### JsonKind · 2

```vb
# JsonKind · 2
#
# JSONに対応する値の種類を調べます。
#
# String：number、string、array、object、boolean、null、unsupported。最外層の種類のみ検査します。

Option Explicit On
Sub Main()
    # Mainを実行します。value=JsonParse("[1]") → "array"; value=Dictionary() → "object".

    Return JsonKind(JsonParse('[1]')) & ':' & JsonKind(Dictionary())
End Sub
```

**パラメーターと実行の説明:**

- Mainを実行します。value=JsonParse("[1]") → "array"; value=Dictionary() → "object".

### JsonKind · 3

```vb
# JsonKind · 3
#
# JSONに対応する値の種類を調べます。
#
# String：number、string、array、object、boolean、null、unsupported。最外層の種類のみ検査します。

Option Explicit On
Sub Main()
    # Mainを実行します。value=JsonBoolean(False) → "boolean"; value=JsonNull() → "null".

    Return JsonKind(JsonBoolean(False)) & ':' & JsonKind(JsonNull())
End Sub
```

**パラメーターと実行の説明:**

- Mainを実行します。value=JsonBoolean(False) → "boolean"; value=JsonNull() → "null".
