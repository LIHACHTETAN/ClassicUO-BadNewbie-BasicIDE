# JsonParse

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: ja -->

JSON文字列をBasicの値へ解析します。

## 正確な構文

```text
JsonParse(text:String) -> Any
```

## パラメーター

- `text` — 必須のJSON String。完全な値を1つ指定します。キーは大文字小文字を区別し、重複不可。コメントと末尾カンマはエラーです。

## 戻り値

Any：オブジェクト→Dictionary、配列→List、文字列→String、数値→IntegerまたはDecimal(Double)、true/false→JsonBoolean、null→JsonNull。成功フラグではありません。

## 動作

- UO.を付けないローカルBasic関数で、ゲームパケットは送りません。JsonParse/JsonStringifyはメモリー内で動作します。Basic Trueは数値1になるため、JSON trueにはJsonBoolean(True)を使います。JsonNull()はnullと0を区別します。
- 有限数のみ。整数値が±9007199254740991を超えるとエラーです。大きなIDはStringで保存してください。他の数値はDouble精度です。厳密なUTF-8を使用し、入力BOMは許可、出力BOMはありません。不正Unicodeはエラーです。
- 上限：1048576 UTF-16コード単位、4MiB、64段のコンテナー、100000値ノード。超過はエラーです。解析・読込は新しいコレクションを作り、保存はメモリーオブジェクトを複製しません。
- Saveは全データを検証し、親フォルダーを作成し、隣接する一意の一時ファイルへ書込み、バッファーを排出して移動/置換します。置換前の失敗・取消は旧ファイルを保持します。一時ファイルはOSが許す場合に削除します。完了済みの置換は取り消しません。
- 256値ごと、4096バイト/文字のブロック間、置換前に一時停止/停止を確認します。追加スレッドは作りません。個々のOS呼出しは強制中断できません。同時保存では最後に成功した置換が残り、DBトランザクションではありません。

### 内部関数：呼び出しから結果まで

JSON文字列をBasicの値へ解析します。

#### 1. Parse

必須のJSON String。完全な値を1つ指定します。キーは大文字小文字を区別し、重複不可。コメントと末尾カンマはエラーです。

Any：オブジェクト→Dictionary、配列→List、文字列→String、数値→IntegerまたはDecimal(Double)、true/false→JsonBoolean、null→JsonNull。成功フラグではありません。

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; 関数 `Parse`.

Config.Load(fileName, defaults)は新しいDictionaryを返します。保存済みの最上位キーでdefaultsのディープコピーを上書きし、入れ子のオブジェクトは全体を置換します。Config.Save(fileName, settings)は明示的に保存し、戻り値なし。Config.GetFlag(settings, key, fallback=False)は1/Trueまたは0/Falseを返し、既存値が真偽値以外ならエラーです。Config.SetFlag(settings, key, value)はメモリーのみ変更し、戻り値なし。Load/SaveはStringキーのDictionaryが必要です。内部Private RequireObjectは外側の型を検査し、JSON変換が全内容を検証します。


## 使用例

### JsonParse · 1

```vb
# JsonParse · 1
#
# JSON文字列をBasicの値へ解析します。
#
# Any：オブジェクト→Dictionary、配列→List、文字列→String、数値→IntegerまたはDecimal(Double)、true/false→JsonBoolean、null→JsonNull。成功フラグではありません。

Option Explicit On
Sub Main()
    # Mainを実行します。text={"delay":350} → Dictionary; d["delay"] → Integer350.

    Dim d=JsonParse('{"delay":350}')
    Return d['delay']
End Sub
```

**パラメーターと実行の説明:**

- Mainを実行します。text={"delay":350} → Dictionary; d["delay"] → Integer350.

### JsonParse · 2

```vb
# JsonParse · 2
#
# JSON文字列をBasicの値へ解析します。
#
# Any：オブジェクト→Dictionary、配列→List、文字列→String、数値→IntegerまたはDecimal(Double)、true/false→JsonBoolean、null→JsonNull。成功フラグではありません。

Option Explicit On
Sub Main()
    # Mainを実行します。text=[true,null,12] → List; index0 → JsonBoolean.Value()=1; index1 → null; index2 →
    # Integer12.

    Dim a=JsonParse('[true,null,12]')
    Dim flag=a[0]
    Return CStr(flag.Value()) & ':' & JsonKind(a[1]) & ':' & CStr(a[2])
End Sub
```

**パラメーターと実行の説明:**

- Mainを実行します。text=[true,null,12] → List; index0 → JsonBoolean.Value()=1; index1 → null; index2 → Integer12.

### JsonParse · 3

```vb
# JsonParse · 3
#
# JSON文字列をBasicの値へ解析します。
#
# Any：オブジェクト→Dictionary、配列→List、文字列→String、数値→IntegerまたはDecimal(Double)、true/false→JsonBoolean、null→JsonNull。成功フラグではありません。

Option Explicit On
Sub Main()
    # Mainを実行します。text={"x":1,"x":2} → Catch → "duplicate key".

    Try
    Dim bad=JsonParse('{"x":1,"x":2}')
    Catch problem
    Return 'duplicate key'
    End Try
    Return 'unexpected'
End Sub
```

**パラメーターと実行の説明:**

- Mainを実行します。text={"x":1,"x":2} → Catch → "duplicate key".
