# UO.StartScript

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: ja -->

Basicファイルを読み込み、公開Sub Mainの起動を要求します。

## 正確な構文

```text
UO.StartScript(ScriptPath:Any) -> Integer
```

## パラメーター

- `ScriptPath` — 必須のString ScriptPath。相対パスの基点はこのクライアントのAutoLoadフォルダーで、絶対パスも使えます。空白を含むパスは引用符で囲みます。対応するBasicソースと、必須引数のない公開Sub Mainが必要です。

## 戻り値

Integer：起動要求受理後の有効な実行数。65535 (0xFFFF) は起動失敗です。新しいインデックス、Boolean、完了結果ではありません。

## 動作

- 実行中と一時停止中を含み、完了済みやキャンセル要求済みは除きます。呼び出し元は通常自分自身も数えます。読み込んだだけのIDEタブは実行ではありません。
- インデックスは起動順の現在位置です。起動や停止で位置が変わります。別々の呼び出しは単一の不可分なスナップショットではありません。後で制御するときは一覧を再取得します。
- Basic IDEを閉じても有効な実行は消えません。対象はこのクライアントであり、別クライアントやWindowsプロセスではありません。
- GetScriptsListはインデックス、GetScriptsCountは個数、GetScriptStateは3状態のコードです。取り違えたり、すべての非ゼロ値をtrueと扱ったりしないでください。
- 例を実行する前に指定のWorker.basを別途作成してください。不正／読めないパス、不適切なMain、Basic無効、並列起動の拒否は失敗になります。前回の実行が停止処理中なら再試行が遅延する場合があります。受理は完了ではなく、短いスクリプトは個数を読む前に終了し得ます。

### 内部関数：呼び出しから結果まで

以下はクライアントの実際のメソッドです。上のBasic例には完全な補助関数があります。内部C#メソッド名は追加のスクリプトコマンドではありません。

#### 1. ExecuteStealthCompatibility

Runtimeは登録されたUO呼び出しを実行し、ブリッジの結果をInteger、String、Arrayとして包みます。

Integer：起動要求受理後の有効な実行数。65535 (0xFFFF) は起動失敗です。新しいインデックス、Boolean、完了結果ではありません。

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 関数 `ExecuteStealthCompatibility`.

#### 2. StartScript

ブリッジはこのクライアントの実行マネージャーに委譲します。

例を実行する前に指定のWorker.basを別途作成してください。不正／読めないパス、不適切なMain、Basic無効、並列起動の拒否は失敗になります。前回の実行が停止処理中なら再試行が遅延する場合があります。受理は完了ではなく、短いスクリプトは個数を読む前に終了し得ます。

プロジェクトのソース: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 関数 `StartScript`.

#### 3. StartScript

`Path.GetFullPath -> File.ReadAllText -> DiscoverProcedures -> SelectFileEntryPoint -> RunProcedure -> GetScriptsCount`

インデックスは起動順の現在位置です。起動や停止で位置が変わります。別々の呼び出しは単一の不可分なスナップショットではありません。後で制御するときは一覧を再取得します。

プロジェクトのソース: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; 関数 `StartScript`.

Basic IDEを閉じても有効な実行は消えません。対象はこのクライアントであり、別クライアントやWindowsプロセスではありません。


## 使用例

### 最初の呼び出しと結果

```vb
# 最初の呼び出しと結果
#
# Basicファイルを読み込み、公開Sub Mainの起動を要求します。
#
# Integer：起動要求受理後の有効な実行数。65535 (0xFFFF) は起動失敗です。新しいインデックス、Boolean、完了結果ではありません。

SUB Main()
    # Sub Mainを実行します。渡す0はインデックスで、空の括弧は引数なしを表します。Printの文字列は例のメッセージです。
    # 例を実行する前に指定のWorker.basを別途作成してください。不正／読めないパス、不適切なMain、Basic無効、並列起動の拒否は失敗になります。前回の実行が停止処理中なら再試行が遅延する場合があります。受理は完了ではなく、短いスクリプトは個数を読む前に終了し得ます。
    # Integer：起動要求受理後の有効な実行数。65535 (0xFFFF) は起動失敗です。新しいインデックス、Boolean、完了結果ではありません。
    # 必須のString
    # ScriptPath。相対パスの基点はこのクライアントのAutoLoadフォルダーで、絶対パスも使えます。空白を含むパスは引用符で囲みます。対応するBasicソースと、必須引数のない公開Sub
    # Mainが必要です。

    Dim count=UO.StartScript("Scripts/Worker.bas")
    If count=65535 Then
        UO.Print("launch failed")
    Else
        UO.Print("Active executions: " & CStr(count))
    End If
END SUB
```

**パラメーターと実行の説明:**

- Sub Mainを実行します。渡す0はインデックスで、空の括弧は引数なしを表します。Printの文字列は例のメッセージです。
- 例を実行する前に指定のWorker.basを別途作成してください。不正／読めないパス、不適切なMain、Basic無効、並列起動の拒否は失敗になります。前回の実行が停止処理中なら再試行が遅延する場合があります。受理は完了ではなく、短いスクリプトは個数を読む前に終了し得ます。
- Integer：起動要求受理後の有効な実行数。65535 (0xFFFF) は起動失敗です。新しいインデックス、Boolean、完了結果ではありません。
- 必須のString ScriptPath。相対パスの基点はこのクライアントのAutoLoadフォルダーで、絶対パスも使えます。空白を含むパスは引用符で囲みます。対応するBasicソースと、必須引数のない公開Sub Mainが必要です。

### ループまたは条件で使う

```vb
# ループまたは条件で使う
#
# Basicファイルを読み込み、公開Sub Mainの起動を要求します。
#
# Integer：起動要求受理後の有効な実行数。65535 (0xFFFF) は起動失敗です。新しいインデックス、Boolean、完了結果ではありません。

SUB Main()
    # 複数のコマンドを組み合わせる独立した例です。配列は0始まりで、参照前に長さを確認します。Wait(250)がある場合は250ミリ秒待ちます。
    # 例を実行する前に指定のWorker.basを別途作成してください。不正／読めないパス、不適切なMain、Basic無効、並列起動の拒否は失敗になります。前回の実行が停止処理中なら再試行が遅延する場合があります。受理は完了ではなく、短いスクリプトは個数を読む前に終了し得ます。
    # Integer：起動要求受理後の有効な実行数。65535 (0xFFFF) は起動失敗です。新しいインデックス、Boolean、完了結果ではありません。
    # 必須のString
    # ScriptPath。相対パスの基点はこのクライアントのAutoLoadフォルダーで、絶対パスも使えます。空白を含むパスは引用符で囲みます。対応するBasicソースと、必須引数のない公開Sub
    # Mainが必要です。

    Dim count=UO.StartScript("Scripts/My Worker.bas")
    If count<>65535 Then
        Dim indices=UO.GetScriptsList()
        For Each index In indices
            UO.Print(CStr(index) & ": " & UO.GetScriptPath(index))
        Next
    End If
END SUB
```

**パラメーターと実行の説明:**

- 複数のコマンドを組み合わせる独立した例です。配列は0始まりで、参照前に長さを確認します。Wait(250)がある場合は250ミリ秒待ちます。
- 例を実行する前に指定のWorker.basを別途作成してください。不正／読めないパス、不適切なMain、Basic無効、並列起動の拒否は失敗になります。前回の実行が停止処理中なら再試行が遅延する場合があります。受理は完了ではなく、短いスクリプトは個数を読む前に終了し得ます。
- Integer：起動要求受理後の有効な実行数。65535 (0xFFFF) は起動失敗です。新しいインデックス、Boolean、完了結果ではありません。
- 必須のString ScriptPath。相対パスの基点はこのクライアントのAutoLoadフォルダーで、絶対パスも使えます。空白を含むパスは引用符で囲みます。対応するBasicソースと、必須引数のない公開Sub Mainが必要です。

### 完全な補助関数

```vb
# 完全な補助関数
#
# Basicファイルを読み込み、公開Sub Mainの起動を要求します。
#
# Integer：起動要求受理後の有効な実行数。65535 (0xFFFF) は起動失敗です。新しいインデックス、Boolean、完了結果ではありません。

SUB Main()
    # Mainの下に関数全体を示します。その引数と結果は、内部のAPIコマンドとは区別して説明しています。
    # TryStartBasicは65535と比較してtrue/falseを返します。完了を待たず、個数をインデックスに変換もしません。
    # Integer：起動要求受理後の有効な実行数。65535 (0xFFFF) は起動失敗です。新しいインデックス、Boolean、完了結果ではありません。
    # 必須のString
    # ScriptPath。相対パスの基点はこのクライアントのAutoLoadフォルダーで、絶対パスも使えます。空白を含むパスは引用符で囲みます。対応するBasicソースと、必須引数のない公開Sub
    # Mainが必要です。

    If TryStartBasic("Scripts/Worker.bas") Then
        UO.Print("launch accepted")
    Else
        UO.Print("check file, Main and execution settings")
    End If
END SUB

Function TryStartBasic(fileName) As Boolean
    Dim count=UO.StartScript(fileName)
    Return count<>65535
End Function
```

**パラメーターと実行の説明:**

- Mainの下に関数全体を示します。その引数と結果は、内部のAPIコマンドとは区別して説明しています。
- TryStartBasicは65535と比較してtrue/falseを返します。完了を待たず、個数をインデックスに変換もしません。
- Integer：起動要求受理後の有効な実行数。65535 (0xFFFF) は起動失敗です。新しいインデックス、Boolean、完了結果ではありません。
- 必須のString ScriptPath。相対パスの基点はこのクライアントのAutoLoadフォルダーで、絶対パスも使えます。空白を含むパスは引用符で囲みます。対応するBasicソースと、必須引数のない公開Sub Mainが必要です。
