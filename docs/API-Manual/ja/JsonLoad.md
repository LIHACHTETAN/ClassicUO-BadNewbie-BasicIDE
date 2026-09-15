# JsonLoad

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: ja -->

JSONファイルを読み込みます。

## 正確な構文

```text
JsonLoad(fileName:String) -> Any
JsonLoad(fileName:String, defaultValue:Any) -> Any
```

## パラメーター

- `fileName` — 必須のファイルパス。相対パスはInclude内からの呼び出しでもメインスクリプトのフォルダー基準です。絶対パスも可能です。
- `defaultValue` — 省略可能な代替値。ファイルまたはフォルダーが存在しない場合のみ、JSON変換による独立コピーを返します。内容・文字コード・アクセスのエラーは隠しません。

## 戻り値

Any、型の対応はJsonParseと同じ。ファイル不在でdefaultValueがない場合はエラー。

## 動作

- UO.を付けないローカルBasic関数で、ゲームパケットは送りません。JsonParse/JsonStringifyはメモリー内で動作します。Basic Trueは数値1になるため、JSON trueにはJsonBoolean(True)を使います。JsonNull()はnullと0を区別します。
- 有限数のみ。整数値が±9007199254740991を超えるとエラーです。大きなIDはStringで保存してください。他の数値はDouble精度です。厳密なUTF-8を使用し、入力BOMは許可、出力BOMはありません。不正Unicodeはエラーです。
- 上限：1048576 UTF-16コード単位、4MiB、64段のコンテナー、100000値ノード。超過はエラーです。解析・読込は新しいコレクションを作り、保存はメモリーオブジェクトを複製しません。
- Saveは全データを検証し、親フォルダーを作成し、隣接する一意の一時ファイルへ書込み、バッファーを排出して移動/置換します。置換前の失敗・取消は旧ファイルを保持します。一時ファイルはOSが許す場合に削除します。完了済みの置換は取り消しません。
- 256値ごと、4096バイト/文字のブロック間、置換前に一時停止/停止を確認します。追加スレッドは作りません。個々のOS呼出しは強制中断できません。同時保存では最後に成功した置換が残り、DBトランザクションではありません。

### 内部関数：呼び出しから結果まで

JSONファイルを読み込みます。

#### 1. LoadCore

必須のファイルパス。相対パスはInclude内からの呼び出しでもメインスクリプトのフォルダー基準です。絶対パスも可能です。 省略可能な代替値。ファイルまたはフォルダーが存在しない場合のみ、JSON変換による独立コピーを返します。内容・文字コード・アクセスのエラーは隠しません。

Any、型の対応はJsonParseと同じ。ファイル不在でdefaultValueがない場合はエラー。

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; 関数 `LoadCore`.

Config.Load(fileName, defaults)は新しいDictionaryを返します。保存済みの最上位キーでdefaultsのディープコピーを上書きし、入れ子のオブジェクトは全体を置換します。Config.Save(fileName, settings)は明示的に保存し、戻り値なし。Config.GetFlag(settings, key, fallback=False)は1/Trueまたは0/Falseを返し、既存値が真偽値以外ならエラーです。Config.SetFlag(settings, key, value)はメモリーのみ変更し、戻り値なし。Load/SaveはStringキーのDictionaryが必要です。内部Private RequireObjectは外側の型を検査し、JSON変換が全内容を検証します。


## 使用例

### JsonLoad · 1

```vb
# JsonLoad · 1
#
# JSONファイルを読み込みます。
#
# Any、型の対応はJsonParseと同じ。ファイル不在でdefaultValueがない場合はエラー。

Option Explicit On
Sub Main()
    # Mainを実行します。fileName="json-demo.json"; JsonSave → file; JsonLoad → Dictionary; delay →
    # Integer350.

    JsonSave('json-demo.json', JsonParse('{"delay":350}'))
    Dim d=JsonLoad('json-demo.json')
    Return d['delay']
End Sub
```

**パラメーターと実行の説明:**

- Mainを実行します。fileName="json-demo.json"; JsonSave → file; JsonLoad → Dictionary; delay → Integer350.

### JsonLoad · 2

```vb
# JsonLoad · 2
#
# JSONファイルを読み込みます。
#
# Any、型の対応はJsonParseと同じ。ファイル不在でdefaultValueがない場合はエラー。

Option Explicit On
Sub Main()
    # Mainを実行します。fileName="missing-json-demo.json", defaultValue=defaults; missing file →
    # independent copy → "125:350".

    Dim defaults=Dictionary()
    defaults['delay']=350
    Dim loaded=JsonLoad('missing-json-demo.json', defaults)
    loaded['delay']=125
    Return CStr(loaded['delay']) & ':' & CStr(defaults['delay'])
End Sub
```

**パラメーターと実行の説明:**

- Mainを実行します。fileName="missing-json-demo.json", defaultValue=defaults; missing file → independent copy → "125:350".

### JsonLoad · 3

```vb
# JsonLoad · 3
#
# JSONファイルを読み込みます。
#
# Any、型の対応はJsonParseと同じ。ファイル不在でdefaultValueがない場合はエラー。

Option Explicit On
Sub Main()
    # Mainを実行します。fileName="json-demo-list.json", defaultValue=List(); existing file [1,2,3] →
    # List.Count() → Integer3.

    JsonSave('json-demo-list.json', JsonParse('[1,2,3]'))
    Dim data=JsonLoad(fileName:='json-demo-list.json', defaultValue:=List())
    Return data.Count()
End Sub
```

**パラメーターと実行の説明:**

- Mainを実行します。fileName="json-demo-list.json", defaultValue=List(); existing file [1,2,3] → List.Count() → Integer3.
