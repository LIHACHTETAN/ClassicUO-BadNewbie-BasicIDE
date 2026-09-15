# JSON / Config.bas

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ja -->

Config.basはScripts/Includeに含まれます。メインスクリプトの隣にInclude/Config.basを置き、Include "Config.bas"を記述します。永続JSONと独立した既定値を組み合わせます。

## 正確な構文

```text
Include "Config.bas"
settings = Config.Load(fileName, defaults)
Config.Save(fileName, settings)
enabled = Config.GetFlag(settings, key, fallback=False)
Config.SetFlag(settings, key, value)
JsonParse(text) / JsonStringify(value[, indented=0])
JsonLoad(fileName[, defaultValue]) / JsonSave(fileName, value[, indented=1])
JsonKind(value) / JsonBoolean(value) / JsonNull() / flag.Value()
```

## パラメーター

- `fileName` — 必須のファイルパス。相対パスはInclude内からの呼び出しでもメインスクリプトのフォルダー基準です。絶対パスも可能です。
- `defaults (Config.Load)` — Config.Loadに必須の既定値Dictionaryです。ディープJSONコピーへ保存済みの最上位キーを統合し、元の値は変更しません。defaultsは省略できません。
- `defaultValue (JsonLoad)` — 省略可能な代替値。ファイルまたはフォルダーが存在しない場合のみ、JSON変換による独立コピーを返します。内容・文字コード・アクセスのエラーは隠しません。
- `settings / value` — 数値、String、配列、List、Dictionary、JsonBoolean、JsonNull。DictionaryのキーはStringのみ。共有参照は可能ですが循環参照はエラーです。
- `indented` — Integerフラグ：0でコンパクト、それ以外で字下げ。既定値はStringify=0、Save=1。
- `key / fallback` — Config.Load(fileName, defaults)は新しいDictionaryを返します。保存済みの最上位キーでdefaultsのディープコピーを上書きし、入れ子のオブジェクトは全体を置換します。Config.Save(fileName, settings)は明示的に保存し、戻り値なし。Config.GetFlag(settings, key, fallback=False)は1/Trueまたは0/Falseを返し、既存値が真偽値以外ならエラーです。Config.SetFlag(settings, key, value)はメモリーのみ変更し、戻り値なし。Load/SaveはStringキーのDictionaryが必要です。内部Private RequireObjectは外側の型を検査し、JSON変換が全内容を検証します。

## 戻り値

Config.Load(fileName, defaults)は新しいDictionaryを返します。保存済みの最上位キーでdefaultsのディープコピーを上書きし、入れ子のオブジェクトは全体を置換します。Config.Save(fileName, settings)は明示的に保存し、戻り値なし。Config.GetFlag(settings, key, fallback=False)は1/Trueまたは0/Falseを返し、既存値が真偽値以外ならエラーです。Config.SetFlag(settings, key, value)はメモリーのみ変更し、戻り値なし。Load/SaveはStringキーのDictionaryが必要です。内部Private RequireObjectは外側の型を検査し、JSON変換が全内容を検証します。

## 動作

- UO.を付けないローカルBasic関数で、ゲームパケットは送りません。JsonParse/JsonStringifyはメモリー内で動作します。Basic Trueは数値1になるため、JSON trueにはJsonBoolean(True)を使います。JsonNull()はnullと0を区別します。
- 有限数のみ。整数値が±9007199254740991を超えるとエラーです。大きなIDはStringで保存してください。他の数値はDouble精度です。厳密なUTF-8を使用し、入力BOMは許可、出力BOMはありません。不正Unicodeはエラーです。
- 上限：1048576 UTF-16コード単位、4MiB、64段のコンテナー、100000値ノード。超過はエラーです。解析・読込は新しいコレクションを作り、保存はメモリーオブジェクトを複製しません。
- Saveは全データを検証し、親フォルダーを作成し、隣接する一意の一時ファイルへ書込み、バッファーを排出して移動/置換します。置換前の失敗・取消は旧ファイルを保持します。一時ファイルはOSが許す場合に削除します。完了済みの置換は取り消しません。
- 256値ごと、4096バイト/文字のブロック間、置換前に一時停止/停止を確認します。追加スレッドは作りません。個々のOS呼出しは強制中断できません。同時保存では最後に成功した置換が残り、DBトランザクションではありません。

## 使用例

### 1. 独立した既定値

```vb
# fileName=missing-settings.json、defaultsのdelay=350。ファイル不在ならLoadはdefaultsをコピーします。結果を125に変えても元の350は変化せず、結果は"125:350"です。不在テスト前に既存のサンプルファイルを移動または削除してください。
Option Explicit On
Include "Config.bas"
Sub Main()
    Dim defaults=Dictionary()
    defaults["delay"]=350
    Dim settings=Config.Load("missing-settings.json", defaults)
    settings["delay"]=125
    Return CStr(settings["delay"]) & ":" & CStr(defaults["delay"])
End Sub
```

**パラメーターと実行の説明:**

fileName=missing-settings.json、defaultsのdelay=350。ファイル不在ならLoadはdefaultsをコピーします。結果を125に変えても元の350は変化せず、結果は"125:350"です。不在テスト前に既存のサンプルファイルを移動または削除してください。

**Include/Config.bas**

```vbnet
Option Explicit On

' Copy Include/Config.bas beside your main script, then Include "Config.bas".
' Relative JSON paths are based on the main script's folder, not this module.
Module Config
    Private Sub RequireObject(ByVal value)
        If JsonKind(value) <> "object" Then
            Throw "Config requires a Dictionary with string keys."
        End If
    End Sub

    ' Returns a new Dictionary. Saved top-level keys override independent defaults.
    ' Missing files use defaults; invalid files raise an error and remain unchanged.
    Public Function Load(ByVal fileName, ByVal defaults)
        RequireObject(defaults)
        Dim result = JsonParse(JsonStringify(defaults))
        Dim saved = JsonLoad(fileName, Dictionary())
        RequireObject(saved)
        For Each entry In saved
            result.Set(entry.Key(), entry.Value())
        Next
        Return result
    End Function

    ' No return value. Validates and writes UTF-8 using same-directory replacement.
    Public Sub Save(ByVal fileName, ByVal settings)
        RequireObject(settings)
        JsonSave(fileName, settings)
    End Sub

    ' A JSON Boolean is distinct from a Basic numeric flag. Convert explicitly.
    ' Returns 1/True or 0/False; non-Boolean saved values raise an error.
    Public Function GetFlag(ByVal settings, ByVal key, Optional ByVal fallback=False)
        RequireObject(settings)
        Dim flag = settings.Get(key, JsonBoolean(fallback))
        If JsonKind(flag) <> "boolean" Then
            Throw "Config.GetFlag expects a JSON Boolean for key: " & CStr(key)
        End If
        Return flag.Value()
    End Function

    ' Changes the Dictionary in memory; call Save to persist it.
    Public Sub SetFlag(ByVal settings, ByVal key, ByVal value)
        RequireObject(settings)
        settings.Set(key, JsonBoolean(value))
    End Sub
End Module
```

### 2. 保存して再読込

```vb
# SetFlagはJSON真偽値を作ります。Saveはdemo-settings.jsonを作成/置換し、Loadで再読込します。GetFlagはInteger1、delay=350なので結果は"1:350"です。
Option Explicit On
Include "Config.bas"
Sub Main()
    Dim settings=Dictionary()
    settings["delay"]=350
    Config.SetFlag(settings, "enabled", True)
    Config.Save("demo-settings.json", settings)
    Dim loaded=Config.Load("demo-settings.json", Dictionary())
    Return CStr(Config.GetFlag(loaded, "enabled")) & ":" & CStr(loaded["delay"])
End Sub
```

**パラメーターと実行の説明:**

SetFlagはJSON真偽値を作ります。Saveはdemo-settings.jsonを作成/置換し、Loadで再読込します。GetFlagはInteger1、delay=350なので結果は"1:350"です。

**Include/Config.bas**

```vbnet
Option Explicit On

' Copy Include/Config.bas beside your main script, then Include "Config.bas".
' Relative JSON paths are based on the main script's folder, not this module.
Module Config
    Private Sub RequireObject(ByVal value)
        If JsonKind(value) <> "object" Then
            Throw "Config requires a Dictionary with string keys."
        End If
    End Sub

    ' Returns a new Dictionary. Saved top-level keys override independent defaults.
    ' Missing files use defaults; invalid files raise an error and remain unchanged.
    Public Function Load(ByVal fileName, ByVal defaults)
        RequireObject(defaults)
        Dim result = JsonParse(JsonStringify(defaults))
        Dim saved = JsonLoad(fileName, Dictionary())
        RequireObject(saved)
        For Each entry In saved
            result.Set(entry.Key(), entry.Value())
        Next
        Return result
    End Function

    ' No return value. Validates and writes UTF-8 using same-directory replacement.
    Public Sub Save(ByVal fileName, ByVal settings)
        RequireObject(settings)
        JsonSave(fileName, settings)
    End Sub

    ' A JSON Boolean is distinct from a Basic numeric flag. Convert explicitly.
    ' Returns 1/True or 0/False; non-Boolean saved values raise an error.
    Public Function GetFlag(ByVal settings, ByVal key, Optional ByVal fallback=False)
        RequireObject(settings)
        Dim flag = settings.Get(key, JsonBoolean(fallback))
        If JsonKind(flag) <> "boolean" Then
            Throw "Config.GetFlag expects a JSON Boolean for key: " & CStr(key)
        End If
        Return flag.Value()
    End Function

    ' Changes the Dictionary in memory; call Save to persist it.
    Public Sub SetFlag(ByVal settings, ByVal key, ByVal value)
        RequireObject(settings)
        settings.Set(key, JsonBoolean(value))
    End Sub
End Module
```

### 3. フラグの型を検査

```vb
# enabled=1は数値でありJSON trueではありません。GetFlagは拒否し、Catchが"invalid flag"を返します。SetFlag(settings,"enabled",True)なら正しい型になります。ファイル変更はありません。
Option Explicit On
Include "Config.bas"
Sub Main()
    Dim settings=Dictionary()
    settings["enabled"]=1
    Try
        Dim enabled=Config.GetFlag(settings, "enabled")
    Catch problem
        Return "invalid flag"
    End Try
    Return "unexpected"
End Sub
```

**パラメーターと実行の説明:**

enabled=1は数値でありJSON trueではありません。GetFlagは拒否し、Catchが"invalid flag"を返します。SetFlag(settings,"enabled",True)なら正しい型になります。ファイル変更はありません。

**Include/Config.bas**

```vbnet
Option Explicit On

' Copy Include/Config.bas beside your main script, then Include "Config.bas".
' Relative JSON paths are based on the main script's folder, not this module.
Module Config
    Private Sub RequireObject(ByVal value)
        If JsonKind(value) <> "object" Then
            Throw "Config requires a Dictionary with string keys."
        End If
    End Sub

    ' Returns a new Dictionary. Saved top-level keys override independent defaults.
    ' Missing files use defaults; invalid files raise an error and remain unchanged.
    Public Function Load(ByVal fileName, ByVal defaults)
        RequireObject(defaults)
        Dim result = JsonParse(JsonStringify(defaults))
        Dim saved = JsonLoad(fileName, Dictionary())
        RequireObject(saved)
        For Each entry In saved
            result.Set(entry.Key(), entry.Value())
        Next
        Return result
    End Function

    ' No return value. Validates and writes UTF-8 using same-directory replacement.
    Public Sub Save(ByVal fileName, ByVal settings)
        RequireObject(settings)
        JsonSave(fileName, settings)
    End Sub

    ' A JSON Boolean is distinct from a Basic numeric flag. Convert explicitly.
    ' Returns 1/True or 0/False; non-Boolean saved values raise an error.
    Public Function GetFlag(ByVal settings, ByVal key, Optional ByVal fallback=False)
        RequireObject(settings)
        Dim flag = settings.Get(key, JsonBoolean(fallback))
        If JsonKind(flag) <> "boolean" Then
            Throw "Config.GetFlag expects a JSON Boolean for key: " & CStr(key)
        End If
        Return flag.Value()
    End Function

    ' Changes the Dictionary in memory; call Save to persist it.
    Public Sub SetFlag(ByVal settings, ByVal key, ByVal value)
        RequireObject(settings)
        settings.Set(key, JsonBoolean(value))
    End Sub
End Module
```

<!-- implementation references (not callable script procedures):
Runtime/BasicJson.cs: Parse / Read / Stringify / Write / LoadCore / Save / Resolve / Budget
Runtime/ObjectTypes/JsonPrimitiveObjects.cs: Value
src/ClassicUO.Client/Scripts/Include/Config.bas: RequireObject / Load / Save / GetFlag / SetFlag
https://learn.microsoft.com/en-us/dotnet/standard/serialization/system-text-json/use-dom
-->
