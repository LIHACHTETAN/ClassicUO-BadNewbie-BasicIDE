# JsonStringify

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: ja -->

Basicの値をJSON文字列へ変換します。

## 正確な構文

```text
JsonStringify(value:Any) -> String
JsonStringify(value:Any, indented:Integer) -> String
```

## パラメーター

- `value` — 数値、String、配列、List、Dictionary、JsonBoolean、JsonNull。DictionaryのキーはStringのみ。共有参照は可能ですが循環参照はエラーです。
- `indented` — Integerフラグ：0でコンパクト、それ以外で字下げ。既定値はStringify=0、Save=1。

## 戻り値

JSONを含むString。ファイルは作成しません。

## 動作

- UO.を付けないローカルBasic関数で、ゲームパケットは送りません。JsonParse/JsonStringifyはメモリー内で動作します。Basic Trueは数値1になるため、JSON trueにはJsonBoolean(True)を使います。JsonNull()はnullと0を区別します。
- 有限数のみ。整数値が±9007199254740991を超えるとエラーです。大きなIDはStringで保存してください。他の数値はDouble精度です。厳密なUTF-8を使用し、入力BOMは許可、出力BOMはありません。不正Unicodeはエラーです。
- 上限：1048576 UTF-16コード単位、4MiB、64段のコンテナー、100000値ノード。超過はエラーです。解析・読込は新しいコレクションを作り、保存はメモリーオブジェクトを複製しません。
- Saveは全データを検証し、親フォルダーを作成し、隣接する一意の一時ファイルへ書込み、バッファーを排出して移動/置換します。置換前の失敗・取消は旧ファイルを保持します。一時ファイルはOSが許す場合に削除します。完了済みの置換は取り消しません。
- 256値ごと、4096バイト/文字のブロック間、置換前に一時停止/停止を確認します。追加スレッドは作りません。個々のOS呼出しは強制中断できません。同時保存では最後に成功した置換が残り、DBトランザクションではありません。

### 内部関数：呼び出しから結果まで

Basicの値をJSON文字列へ変換します。

#### 1. Stringify

数値、String、配列、List、Dictionary、JsonBoolean、JsonNull。DictionaryのキーはStringのみ。共有参照は可能ですが循環参照はエラーです。 Integerフラグ：0でコンパクト、それ以外で字下げ。既定値はStringify=0、Save=1。

JSONを含むString。ファイルは作成しません。

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; 関数 `Stringify`.

Config.Load(fileName, defaults)は新しいDictionaryを返します。保存済みの最上位キーでdefaultsのディープコピーを上書きし、入れ子のオブジェクトは全体を置換します。Config.Save(fileName, settings)は明示的に保存し、戻り値なし。Config.GetFlag(settings, key, fallback=False)は1/Trueまたは0/Falseを返し、既存値が真偽値以外ならエラーです。Config.SetFlag(settings, key, value)はメモリーのみ変更し、戻り値なし。Load/SaveはStringキーのDictionaryが必要です。内部Private RequireObjectは外側の型を検査し、JSON変換が全内容を検証します。


## 使用例

### JsonStringify · 1

```vb
# JsonStringify · 1
#
# Basicの値をJSON文字列へ変換します。
#
# JSONを含むString。ファイルは作成しません。

Option Explicit On
Sub Main()
    # Mainを実行します。value=Dictionary(name="ore",count=3), indented=0 → String {"name":"ore","count":3}.

    Dim d=Dictionary()
    d['name']='ore'
    d['count']=3
    Return JsonStringify(d)
End Sub
```

**パラメーターと実行の説明:**

- Mainを実行します。value=Dictionary(name="ore",count=3), indented=0 → String {"name":"ore","count":3}.

### JsonStringify · 2

```vb
# JsonStringify · 2
#
# Basicの値をJSON文字列へ変換します。
#
# JSONを含むString。ファイルは作成しません。

Option Explicit On
Sub Main()
    # Mainを実行します。value=d, indented=True=1; JsonParse(text) → independent Dictionary; JsonKind →
    # "boolean:null".

    Dim d=JsonParse('{"enabled":true,"empty":null}')
    Dim text=JsonStringify(value:=d, indented:=True)
    Dim copy=JsonParse(text)
    Return JsonKind(copy['enabled']) & ':' & JsonKind(copy['empty'])
End Sub
```

**パラメーターと実行の説明:**

- Mainを実行します。value=d, indented=True=1; JsonParse(text) → independent Dictionary; JsonKind → "boolean:null".

### JsonStringify · 3

```vb
# JsonStringify · 3
#
# Basicの値をJSON文字列へ変換します。
#
# JSONを含むString。ファイルは作成しません。

Option Explicit On
Sub Main()
    # Mainを実行します。value=List → value[0]=value → Catch → "cycle".

    Dim d=List()
    d.Add(d)
    Try
    Dim text=JsonStringify(d)
    Catch problem
    Return 'cycle'
    End Try
    Return 'unexpected'
End Sub
```

**パラメーターと実行の説明:**

- Mainを実行します。value=List → value[0]=value → Catch → "cycle".
