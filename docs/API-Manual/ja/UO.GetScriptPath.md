# UO.GetScriptPath

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: ja -->

有効な実行のソースファイルパスを読みます。

## 正確な構文

```text
UO.GetScriptPath(ScriptIndex:Any) -> String
```

## パラメーター

- `ScriptIndex` — 必須のScriptIndexは、最新のGetScriptsListから取得する0始まりの整数です。負値または存在しないインデックスは、記載の空値／不明状態になります。アイテムserial、プロシージャ名、IDE実行IDを渡さないでください。

## 戻り値

String：記録されたソースファイルパス。インデックスがなければ ""。ファイル起動では通常フルパスですが、コマンドやメモリ上のソースには通常のファイルがない場合があります。

## 動作

- 実行中と一時停止中を含み、完了済みやキャンセル要求済みは除きます。呼び出し元は通常自分自身も数えます。読み込んだだけのIDEタブは実行ではありません。
- インデックスは起動順の現在位置です。起動や停止で位置が変わります。別々の呼び出しは単一の不可分なスナップショットではありません。後で制御するときは一覧を再取得します。
- Basic IDEを閉じても有効な実行は消えません。対象はこのクライアントであり、別クライアントやWindowsプロセスではありません。
- GetScriptsListはインデックス、GetScriptsCountは個数、GetScriptStateは3状態のコードです。取り違えたり、すべての非ゼロ値をtrueと扱ったりしないでください。
- ScriptIndex=0は現在の最初の実行を選びます。取得したパスのファイルを開く、保存する、起動する操作は行いません。

### 内部関数：呼び出しから結果まで

以下はクライアントの実際のメソッドです。上のBasic例には完全な補助関数があります。内部C#メソッド名は追加のスクリプトコマンドではありません。

#### 1. ExecuteStealthCompatibility

Runtimeは登録されたUO呼び出しを実行し、ブリッジの結果をInteger、String、Arrayとして包みます。

String：記録されたソースファイルパス。インデックスがなければ ""。ファイル起動では通常フルパスですが、コマンドやメモリ上のソースには通常のファイルがない場合があります。

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 関数 `ExecuteStealthCompatibility`.

#### 2. GetScriptPath

ブリッジはこのクライアントの実行マネージャーに委譲します。

ScriptIndex=0は現在の最初の実行を選びます。取得したパスのファイルを開く、保存する、起動する操作は行いません。

プロジェクトのソース: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 関数 `GetScriptPath`.

#### 3. GetScriptPath

`ElementAt(RunningScripts(), index)?.FilePath ?? string.Empty`

インデックスは起動順の現在位置です。起動や停止で位置が変わります。別々の呼び出しは単一の不可分なスナップショットではありません。後で制御するときは一覧を再取得します。

プロジェクトのソース: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; 関数 `GetScriptPath`.

Basic IDEを閉じても有効な実行は消えません。対象はこのクライアントであり、別クライアントやWindowsプロセスではありません。


## 使用例

### 最初の呼び出しと結果

```vb
# 最初の呼び出しと結果
#
# 有効な実行のソースファイルパスを読みます。
#
# String：記録されたソースファイルパス。インデックスがなければ ""。ファイル起動では通常フルパスですが、コマンドやメモリ上のソースには通常のファイルがない場合があります。

SUB Main()
    # Sub Mainを実行します。渡す0はインデックスで、空の括弧は引数なしを表します。Printの文字列は例のメッセージです。
    # ScriptIndex=0は現在の最初の実行を選びます。取得したパスのファイルを開く、保存する、起動する操作は行いません。
    # String：記録されたソースファイルパス。インデックスがなければ ""。ファイル起動では通常フルパスですが、コマンドやメモリ上のソースには通常のファイルがない場合があります。
    # 必須のScriptIndexは、最新のGetScriptsListから取得する0始まりの整数です。負値または存在しないインデックスは、記載の空値／不明状態になります。アイテムserial、プロシージャ名、IDE実行IDを渡さないでください。

    Dim index=0
    Dim path=UO.GetScriptPath(index)
    If path<>"" Then
        UO.Print(path)
    End If
END SUB
```

**パラメーターと実行の説明:**

- Sub Mainを実行します。渡す0はインデックスで、空の括弧は引数なしを表します。Printの文字列は例のメッセージです。
- ScriptIndex=0は現在の最初の実行を選びます。取得したパスのファイルを開く、保存する、起動する操作は行いません。
- String：記録されたソースファイルパス。インデックスがなければ ""。ファイル起動では通常フルパスですが、コマンドやメモリ上のソースには通常のファイルがない場合があります。
- 必須のScriptIndexは、最新のGetScriptsListから取得する0始まりの整数です。負値または存在しないインデックスは、記載の空値／不明状態になります。アイテムserial、プロシージャ名、IDE実行IDを渡さないでください。

### ループまたは条件で使う

```vb
# ループまたは条件で使う
#
# 有効な実行のソースファイルパスを読みます。
#
# String：記録されたソースファイルパス。インデックスがなければ ""。ファイル起動では通常フルパスですが、コマンドやメモリ上のソースには通常のファイルがない場合があります。

SUB Main()
    # 複数のコマンドを組み合わせる独立した例です。配列は0始まりで、参照前に長さを確認します。Wait(250)がある場合は250ミリ秒待ちます。
    # ScriptIndex=0は現在の最初の実行を選びます。取得したパスのファイルを開く、保存する、起動する操作は行いません。
    # String：記録されたソースファイルパス。インデックスがなければ ""。ファイル起動では通常フルパスですが、コマンドやメモリ上のソースには通常のファイルがない場合があります。
    # 必須のScriptIndexは、最新のGetScriptsListから取得する0始まりの整数です。負値または存在しないインデックスは、記載の空値／不明状態になります。アイテムserial、プロシージャ名、IDE実行IDを渡さないでください。

    Dim indices=UO.GetScriptsList()
    For Each index In indices
        UO.Print(UO.GetScriptName(index) & " -> " & UO.GetScriptPath(index))
    Next
END SUB
```

**パラメーターと実行の説明:**

- 複数のコマンドを組み合わせる独立した例です。配列は0始まりで、参照前に長さを確認します。Wait(250)がある場合は250ミリ秒待ちます。
- ScriptIndex=0は現在の最初の実行を選びます。取得したパスのファイルを開く、保存する、起動する操作は行いません。
- String：記録されたソースファイルパス。インデックスがなければ ""。ファイル起動では通常フルパスですが、コマンドやメモリ上のソースには通常のファイルがない場合があります。
- 必須のScriptIndexは、最新のGetScriptsListから取得する0始まりの整数です。負値または存在しないインデックスは、記載の空値／不明状態になります。アイテムserial、プロシージャ名、IDE実行IDを渡さないでください。

### 完全な補助関数

```vb
# 完全な補助関数
#
# 有効な実行のソースファイルパスを読みます。
#
# String：記録されたソースファイルパス。インデックスがなければ ""。ファイル起動では通常フルパスですが、コマンドやメモリ上のソースには通常のファイルがない場合があります。

SUB Main()
    # Mainの下に関数全体を示します。その引数と結果は、内部のAPIコマンドとは区別して説明しています。
    # ReadScriptPathはパスが空のときだけfallbackを使います。GetScriptPathの新しいオーバーロードではありません。
    # String：記録されたソースファイルパス。インデックスがなければ ""。ファイル起動では通常フルパスですが、コマンドやメモリ上のソースには通常のファイルがない場合があります。
    # 必須のScriptIndexは、最新のGetScriptsListから取得する0始まりの整数です。負値または存在しないインデックスは、記載の空値／不明状態になります。アイテムserial、プロシージャ名、IDE実行IDを渡さないでください。

    UO.Print(ReadScriptPath(0, "path unavailable"))
END SUB

Function ReadScriptPath(index, fallback) As String
    Dim path=UO.GetScriptPath(index)
    If path="" Then
        Return fallback
    End If
    Return path
End Function
```

**パラメーターと実行の説明:**

- Mainの下に関数全体を示します。その引数と結果は、内部のAPIコマンドとは区別して説明しています。
- ReadScriptPathはパスが空のときだけfallbackを使います。GetScriptPathの新しいオーバーロードではありません。
- String：記録されたソースファイルパス。インデックスがなければ ""。ファイル起動では通常フルパスですが、コマンドやメモリ上のソースには通常のファイルがない場合があります。
- 必須のScriptIndexは、最新のGetScriptsListから取得する0始まりの整数です。負値または存在しないインデックスは、記載の空値／不明状態になります。アイテムserial、プロシージャ名、IDE実行IDを渡さないでください。
