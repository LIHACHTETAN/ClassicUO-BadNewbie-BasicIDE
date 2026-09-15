# UO.GetScriptName

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: ja -->

有効な実行の表示名を読みます。

## 正確な構文

```text
UO.GetScriptName(ScriptIndex:Any) -> String
```

## パラメーター

- `ScriptIndex` — 必須のScriptIndexは、最新のGetScriptsListから取得する0始まりの整数です。負値または存在しないインデックスは、記載の空値／不明状態になります。アイテムserial、プロシージャ名、IDE実行IDを渡さないでください。

## 戻り値

String：表示名。インデックスがなければ ""。存在する実行にも明示的に空の名前を設定できます。

## 動作

- 実行中と一時停止中を含み、完了済みやキャンセル要求済みは除きます。呼び出し元は通常自分自身も数えます。読み込んだだけのIDEタブは実行ではありません。
- インデックスは起動順の現在位置です。起動や停止で位置が変わります。別々の呼び出しは単一の不可分なスナップショットではありません。後で制御するときは一覧を再取得します。
- Basic IDEを閉じても有効な実行は消えません。対象はこのクライアントであり、別クライアントやWindowsプロセスではありません。
- GetScriptsListはインデックス、GetScriptsCountは個数、GetScriptStateは3状態のコードです。取り違えたり、すべての非ゼロ値をtrueと扱ったりしないでください。
- ScriptIndex=0は現在の最初の実行であり、必ずしも呼び出し元ではありません。SetScriptNameは表示名のみを変更し、ファイル名は変更しません。

### 内部関数：呼び出しから結果まで

以下はクライアントの実際のメソッドです。上のBasic例には完全な補助関数があります。内部C#メソッド名は追加のスクリプトコマンドではありません。

#### 1. ExecuteStealthCompatibility

Runtimeは登録されたUO呼び出しを実行し、ブリッジの結果をInteger、String、Arrayとして包みます。

String：表示名。インデックスがなければ ""。存在する実行にも明示的に空の名前を設定できます。

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 関数 `ExecuteStealthCompatibility`.

#### 2. GetScriptName

ブリッジはこのクライアントの実行マネージャーに委譲します。

ScriptIndex=0は現在の最初の実行であり、必ずしも呼び出し元ではありません。SetScriptNameは表示名のみを変更し、ファイル名は変更しません。

プロジェクトのソース: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 関数 `GetScriptName`.

#### 3. GetScriptName

`ElementAt(RunningScripts(), index)?.Name ?? string.Empty`

インデックスは起動順の現在位置です。起動や停止で位置が変わります。別々の呼び出しは単一の不可分なスナップショットではありません。後で制御するときは一覧を再取得します。

プロジェクトのソース: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; 関数 `GetScriptName`.

Basic IDEを閉じても有効な実行は消えません。対象はこのクライアントであり、別クライアントやWindowsプロセスではありません。


## 使用例

### 最初の呼び出しと結果

```vb
# 最初の呼び出しと結果
#
# 有効な実行の表示名を読みます。
#
# String：表示名。インデックスがなければ ""。存在する実行にも明示的に空の名前を設定できます。

SUB Main()
    # Sub Mainを実行します。渡す0はインデックスで、空の括弧は引数なしを表します。Printの文字列は例のメッセージです。
    # ScriptIndex=0は現在の最初の実行であり、必ずしも呼び出し元ではありません。SetScriptNameは表示名のみを変更し、ファイル名は変更しません。
    # String：表示名。インデックスがなければ ""。存在する実行にも明示的に空の名前を設定できます。
    # 必須のScriptIndexは、最新のGetScriptsListから取得する0始まりの整数です。負値または存在しないインデックスは、記載の空値／不明状態になります。アイテムserial、プロシージャ名、IDE実行IDを渡さないでください。

    Dim index=0
    Dim name=UO.GetScriptName(index)
    UO.Print(name)
END SUB
```

**パラメーターと実行の説明:**

- Sub Mainを実行します。渡す0はインデックスで、空の括弧は引数なしを表します。Printの文字列は例のメッセージです。
- ScriptIndex=0は現在の最初の実行であり、必ずしも呼び出し元ではありません。SetScriptNameは表示名のみを変更し、ファイル名は変更しません。
- String：表示名。インデックスがなければ ""。存在する実行にも明示的に空の名前を設定できます。
- 必須のScriptIndexは、最新のGetScriptsListから取得する0始まりの整数です。負値または存在しないインデックスは、記載の空値／不明状態になります。アイテムserial、プロシージャ名、IDE実行IDを渡さないでください。

### ループまたは条件で使う

```vb
# ループまたは条件で使う
#
# 有効な実行の表示名を読みます。
#
# String：表示名。インデックスがなければ ""。存在する実行にも明示的に空の名前を設定できます。

SUB Main()
    # 複数のコマンドを組み合わせる独立した例です。配列は0始まりで、参照前に長さを確認します。Wait(250)がある場合は250ミリ秒待ちます。
    # ScriptIndex=0は現在の最初の実行であり、必ずしも呼び出し元ではありません。SetScriptNameは表示名のみを変更し、ファイル名は変更しません。
    # String：表示名。インデックスがなければ ""。存在する実行にも明示的に空の名前を設定できます。
    # 必須のScriptIndexは、最新のGetScriptsListから取得する0始まりの整数です。負値または存在しないインデックスは、記載の空値／不明状態になります。アイテムserial、プロシージャ名、IDE実行IDを渡さないでください。

    Dim indices=UO.GetScriptsList()
    For Each index In indices
        Dim name=UO.GetScriptName(index)
        UO.Print(CStr(index) & " = " & name)
    Next
END SUB
```

**パラメーターと実行の説明:**

- 複数のコマンドを組み合わせる独立した例です。配列は0始まりで、参照前に長さを確認します。Wait(250)がある場合は250ミリ秒待ちます。
- ScriptIndex=0は現在の最初の実行であり、必ずしも呼び出し元ではありません。SetScriptNameは表示名のみを変更し、ファイル名は変更しません。
- String：表示名。インデックスがなければ ""。存在する実行にも明示的に空の名前を設定できます。
- 必須のScriptIndexは、最新のGetScriptsListから取得する0始まりの整数です。負値または存在しないインデックスは、記載の空値／不明状態になります。アイテムserial、プロシージャ名、IDE実行IDを渡さないでください。

### 完全な補助関数

```vb
# 完全な補助関数
#
# 有効な実行の表示名を読みます。
#
# String：表示名。インデックスがなければ ""。存在する実行にも明示的に空の名前を設定できます。

SUB Main()
    # Mainの下に関数全体を示します。その引数と結果は、内部のAPIコマンドとは区別して説明しています。
    # DescribeScriptは状態を確認して名前とパスを結合します。呼び出し間に停止が起こり得ます。"missing" は補助関数の値で、GetScriptNameの戻り値ではありません。
    # String：表示名。インデックスがなければ ""。存在する実行にも明示的に空の名前を設定できます。
    # 必須のScriptIndexは、最新のGetScriptsListから取得する0始まりの整数です。負値または存在しないインデックスは、記載の空値／不明状態になります。アイテムserial、プロシージャ名、IDE実行IDを渡さないでください。

    UO.Print(DescribeScript(0))
END SUB

Function DescribeScript(index) As String
    If UO.GetScriptState(index)=0 Then
        Return "missing"
    End If
    Return UO.GetScriptName(index) & " | " & UO.GetScriptPath(index)
End Function
```

**パラメーターと実行の説明:**

- Mainの下に関数全体を示します。その引数と結果は、内部のAPIコマンドとは区別して説明しています。
- DescribeScriptは状態を確認して名前とパスを結合します。呼び出し間に停止が起こり得ます。"missing" は補助関数の値で、GetScriptNameの戻り値ではありません。
- String：表示名。インデックスがなければ ""。存在する実行にも明示的に空の名前を設定できます。
- 必須のScriptIndexは、最新のGetScriptsListから取得する0始まりの整数です。負値または存在しないインデックスは、記載の空値／不明状態になります。アイテムserial、プロシージャ名、IDE実行IDを渡さないでください。
