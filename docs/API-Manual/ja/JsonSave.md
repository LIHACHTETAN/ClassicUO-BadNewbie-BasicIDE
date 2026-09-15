# JsonSave

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: ja -->

値をJSONファイルへ保存します。

## 正確な構文

```text
JsonSave(fileName:String, value:Any) -> Unit
JsonSave(fileName:String, value:Any, indented:Integer) -> Unit
```

## パラメーター

- `fileName` — 必須のファイルパス。相対パスはInclude内からの呼び出しでもメインスクリプトのフォルダー基準です。絶対パスも可能です。
- `value` — 数値、String、配列、List、Dictionary、JsonBoolean、JsonNull。DictionaryのキーはStringのみ。共有参照は可能ですが循環参照はエラーです。
- `indented` — Integerフラグ：0でコンパクト、それ以外で字下げ。既定値はStringify=0、Save=1。

## 戻り値

Unit：戻り値なし。正常終了が成功を示し、エラーはTry/Catchで処理します。

## 動作

- UO.を付けないローカルBasic関数で、ゲームパケットは送りません。JsonParse/JsonStringifyはメモリー内で動作します。Basic Trueは数値1になるため、JSON trueにはJsonBoolean(True)を使います。JsonNull()はnullと0を区別します。
- 有限数のみ。整数値が±9007199254740991を超えるとエラーです。大きなIDはStringで保存してください。他の数値はDouble精度です。厳密なUTF-8を使用し、入力BOMは許可、出力BOMはありません。不正Unicodeはエラーです。
- 上限：1048576 UTF-16コード単位、4MiB、64段のコンテナー、100000値ノード。超過はエラーです。解析・読込は新しいコレクションを作り、保存はメモリーオブジェクトを複製しません。
- Saveは全データを検証し、親フォルダーを作成し、隣接する一意の一時ファイルへ書込み、バッファーを排出して移動/置換します。置換前の失敗・取消は旧ファイルを保持します。一時ファイルはOSが許す場合に削除します。完了済みの置換は取り消しません。
- 256値ごと、4096バイト/文字のブロック間、置換前に一時停止/停止を確認します。追加スレッドは作りません。個々のOS呼出しは強制中断できません。同時保存では最後に成功した置換が残り、DBトランザクションではありません。

### 内部関数：呼び出しから結果まで

値をJSONファイルへ保存します。

#### 1. Save

必須のファイルパス。相対パスはInclude内からの呼び出しでもメインスクリプトのフォルダー基準です。絶対パスも可能です。 数値、String、配列、List、Dictionary、JsonBoolean、JsonNull。DictionaryのキーはStringのみ。共有参照は可能ですが循環参照はエラーです。 Integerフラグ：0でコンパクト、それ以外で字下げ。既定値はStringify=0、Save=1。

Unit：戻り値なし。正常終了が成功を示し、エラーはTry/Catchで処理します。

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; 関数 `Save`.

Config.Load(fileName, defaults)は新しいDictionaryを返します。保存済みの最上位キーでdefaultsのディープコピーを上書きし、入れ子のオブジェクトは全体を置換します。Config.Save(fileName, settings)は明示的に保存し、戻り値なし。Config.GetFlag(settings, key, fallback=False)は1/Trueまたは0/Falseを返し、既存値が真偽値以外ならエラーです。Config.SetFlag(settings, key, value)はメモリーのみ変更し、戻り値なし。Load/SaveはStringキーのDictionaryが必要です。内部Private RequireObjectは外側の型を検査し、JSON変換が全内容を検証します。


## 使用例

### JsonSave · 1

```vb
# JsonSave · 1
#
# 値をJSONファイルへ保存します。
#
# Unit：戻り値なし。正常終了が成功を示し、エラーはTry/Catchで処理します。

Option Explicit On
Sub Main()
    # Mainを実行します。fileName="json-save-demo.json", value=d, indented=1 → file; JsonLoad →
    # delay=Integer350.

    Dim d=JsonParse('{"delay":350}')
    JsonSave('json-save-demo.json', d)
    Dim loaded=JsonLoad('json-save-demo.json')
    Return loaded['delay']
End Sub
```

**パラメーターと実行の説明:**

- Mainを実行します。fileName="json-save-demo.json", value=d, indented=1 → file; JsonLoad → delay=Integer350.

### JsonSave · 2

```vb
# JsonSave · 2
#
# 値をJSONファイルへ保存します。
#
# Unit：戻り値なし。正常終了が成功を示し、エラーはTry/Catchで処理します。

Option Explicit On
Sub Main()
    # Mainを実行します。fileName="json-save-array.json", value=List, indented=False=0 → compact
    # [true,null,7].

    JsonSave(indented:=False, value:=JsonParse('[true,null,7]'), fileName:='json-save-array.json')
    Return JsonStringify(JsonLoad('json-save-array.json'))
End Sub
```

**パラメーターと実行の説明:**

- Mainを実行します。fileName="json-save-array.json", value=List, indented=False=0 → compact [true,null,7].

### JsonSave · 3

```vb
# JsonSave · 3
#
# 値をJSONファイルへ保存します。
#
# Unit：戻り値なし。正常終了が成功を示し、エラーはTry/Catchで処理します。

Option Explicit On
Sub Main()
    # Mainを実行します。fileName="json-replace-demo.json", value=7; next value=cyclic List → Catch;
    # JsonLoad → original Integer7.

    JsonSave('json-replace-demo.json', 7)
    Dim cycle=List()
    cycle.Add(cycle)
    Try
    JsonSave('json-replace-demo.json', cycle)
    Catch problem
    Return JsonLoad('json-replace-demo.json')
    End Try
    Return 0
End Sub
```

**パラメーターと実行の説明:**

- Mainを実行します。fileName="json-replace-demo.json", value=7; next value=cyclic List → Catch; JsonLoad → original Integer7.
