# JsonBoolean

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: ja -->

明示的なJSON真偽値を作成します。

## 正確な構文

```text
JsonBoolean(value:Any) -> Object
```

## パラメーター

- `value` — 数値または数値String：0はfalse、非0はtrue。Basic True/Falseは1/0です。JSON真偽値はflag.Value()で読みます。

## 戻り値

JsonBooleanオブジェクト。true/falseとして保存されます。Value()はIf用にInteger1/Trueまたは0/Falseを返します。オブジェクト自体は数値フラグではありません。

## 動作

- UO.を付けないローカルBasic関数で、ゲームパケットは送りません。JsonParse/JsonStringifyはメモリー内で動作します。Basic Trueは数値1になるため、JSON trueにはJsonBoolean(True)を使います。JsonNull()はnullと0を区別します。
- 有限数のみ。整数値が±9007199254740991を超えるとエラーです。大きなIDはStringで保存してください。他の数値はDouble精度です。厳密なUTF-8を使用し、入力BOMは許可、出力BOMはありません。不正Unicodeはエラーです。
- 上限：1048576 UTF-16コード単位、4MiB、64段のコンテナー、100000値ノード。超過はエラーです。解析・読込は新しいコレクションを作り、保存はメモリーオブジェクトを複製しません。
- Saveは全データを検証し、親フォルダーを作成し、隣接する一意の一時ファイルへ書込み、バッファーを排出して移動/置換します。置換前の失敗・取消は旧ファイルを保持します。一時ファイルはOSが許す場合に削除します。完了済みの置換は取り消しません。
- 256値ごと、4096バイト/文字のブロック間、置換前に一時停止/停止を確認します。追加スレッドは作りません。個々のOS呼出しは強制中断できません。同時保存では最後に成功した置換が残り、DBトランザクションではありません。

### 内部関数：呼び出しから結果まで

明示的なJSON真偽値を作成します。

#### 1. BasicJsonBoolean

数値または数値String：0はfalse、非0はtrue。Basic True/Falseは1/0です。JSON真偽値はflag.Value()で読みます。

JsonBooleanオブジェクト。true/falseとして保存されます。Value()はIf用にInteger1/Trueまたは0/Falseを返します。オブジェクト自体は数値フラグではありません。

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApi.cs`; 関数 `BasicJsonBoolean`.

Config.Load(fileName, defaults)は新しいDictionaryを返します。保存済みの最上位キーでdefaultsのディープコピーを上書きし、入れ子のオブジェクトは全体を置換します。Config.Save(fileName, settings)は明示的に保存し、戻り値なし。Config.GetFlag(settings, key, fallback=False)は1/Trueまたは0/Falseを返し、既存値が真偽値以外ならエラーです。Config.SetFlag(settings, key, value)はメモリーのみ変更し、戻り値なし。Load/SaveはStringキーのDictionaryが必要です。内部Private RequireObjectは外側の型を検査し、JSON変換が全内容を検証します。


## 使用例

### JsonBoolean · 1

```vb
# JsonBoolean · 1
#
# 明示的なJSON真偽値を作成します。
#
# JsonBooleanオブジェクト。true/falseとして保存されます。Value()はIf用にInteger1/Trueまたは0/Falseを返します。オブジェクト自体は数値フラグではありません。

Option Explicit On
Sub Main()
    # Mainを実行します。value=True=1 → JSON true; flag.Value()=1 → If → "enabled".

    Dim flag=JsonBoolean(True)
    If flag.Value() Then
    Return 'enabled'
    End If
    Return 'disabled'
End Sub
```

**パラメーターと実行の説明:**

- Mainを実行します。value=True=1 → JSON true; flag.Value()=1 → If → "enabled".

### JsonBoolean · 2

```vb
# JsonBoolean · 2
#
# 明示的なJSON真偽値を作成します。
#
# JsonBooleanオブジェクト。true/falseとして保存されます。Value()はIf用にInteger1/Trueまたは0/Falseを返します。オブジェクト自体は数値フラグではありません。

Option Explicit On
Sub Main()
    # Mainを実行します。value=0 → JSON false; Value() → Integer0/False; Main → "false:0".

    Dim flag=JsonBoolean(value:=0)
    Return JsonStringify(flag) & ':' & CStr(flag.Value())
End Sub
```

**パラメーターと実行の説明:**

- Mainを実行します。value=0 → JSON false; Value() → Integer0/False; Main → "false:0".

### JsonBoolean · 3

```vb
# JsonBoolean · 3
#
# 明示的なJSON真偽値を作成します。
#
# JsonBooleanオブジェクト。true/falseとして保存されます。Value()はIf用にInteger1/Trueまたは0/Falseを返します。オブジェクト自体は数値フラグではありません。

Option Explicit On
Sub Main()
    # Mainを実行します。value=-2 → JSON true; Basic True → number1; Main → String [true,1].

    Dim values=List()
    values.Add(JsonBoolean(-2))
    values.Add(True)
    Return JsonStringify(values)
End Sub
```

**パラメーターと実行の説明:**

- Mainを実行します。value=-2 → JSON true; Basic True → number1; Main → String [true,1].
