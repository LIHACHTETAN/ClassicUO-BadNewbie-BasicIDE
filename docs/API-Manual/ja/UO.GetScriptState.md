# UO.GetScriptState

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: ja -->

インデックスに対応する実行状態を読みます。

## 正確な構文

```text
UO.GetScriptState(ScriptIndex:Any) -> Integer
```

## パラメーター

- `ScriptIndex` — 必須のScriptIndexは、最新のGetScriptsListから取得する0始まりの整数です。負値または存在しないインデックスは、記載の空値／不明状態になります。アイテムserial、プロシージャ名、IDE実行IDを渡さないでください。

## 戻り値

Integer状態コード：0＝存在しない／不明、1＝実行中、2＝一時停止。Booleanではないので、1や2と明示的に比較します。

## 動作

- 実行中と一時停止中を含み、完了済みやキャンセル要求済みは除きます。呼び出し元は通常自分自身も数えます。読み込んだだけのIDEタブは実行ではありません。
- インデックスは起動順の現在位置です。起動や停止で位置が変わります。別々の呼び出しは単一の不可分なスナップショットではありません。後で制御するときは一覧を再取得します。
- Basic IDEを閉じても有効な実行は消えません。対象はこのクライアントであり、別クライアントやWindowsプロセスではありません。
- GetScriptsListはインデックス、GetScriptsCountは個数、GetScriptStateは3状態のコードです。取り違えたり、すべての非ゼロ値をtrueと扱ったりしないでください。
- 手動／デバッガー停止と設定された切断時の停止を含みます。状態1は、その瞬間のCPU使用やサーバーデータ受信を保証しません。

### 内部関数：呼び出しから結果まで

以下はクライアントの実際のメソッドです。上のBasic例には完全な補助関数があります。内部C#メソッド名は追加のスクリプトコマンドではありません。

#### 1. ExecuteStealthCompatibility

Runtimeは登録されたUO呼び出しを実行し、ブリッジの結果をInteger、String、Arrayとして包みます。

Integer状態コード：0＝存在しない／不明、1＝実行中、2＝一時停止。Booleanではないので、1や2と明示的に比較します。

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 関数 `ExecuteStealthCompatibility`.

#### 2. GetScriptState

ブリッジはこのクライアントの実行マネージャーに委譲します。

手動／デバッガー停止と設定された切断時の停止を含みます。状態1は、その瞬間のCPU使用やサーバーデータ受信を保証しません。

プロジェクトのソース: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 関数 `GetScriptState`.

#### 3. GetScriptState

`script == null ? 0 : script.IsPaused ? 2 : 1`

インデックスは起動順の現在位置です。起動や停止で位置が変わります。別々の呼び出しは単一の不可分なスナップショットではありません。後で制御するときは一覧を再取得します。

プロジェクトのソース: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; 関数 `GetScriptState`.

Basic IDEを閉じても有効な実行は消えません。対象はこのクライアントであり、別クライアントやWindowsプロセスではありません。


## 使用例

### 最初の呼び出しと結果

```vb
# 最初の呼び出しと結果
#
# インデックスに対応する実行状態を読みます。
#
# Integer状態コード：0＝存在しない／不明、1＝実行中、2＝一時停止。Booleanではないので、1や2と明示的に比較します。

SUB Main()
    # Sub Mainを実行します。渡す0はインデックスで、空の括弧は引数なしを表します。Printの文字列は例のメッセージです。
    # 手動／デバッガー停止と設定された切断時の停止を含みます。状態1は、その瞬間のCPU使用やサーバーデータ受信を保証しません。
    # Integer状態コード：0＝存在しない／不明、1＝実行中、2＝一時停止。Booleanではないので、1や2と明示的に比較します。
    # 必須のScriptIndexは、最新のGetScriptsListから取得する0始まりの整数です。負値または存在しないインデックスは、記載の空値／不明状態になります。アイテムserial、プロシージャ名、IDE実行IDを渡さないでください。

    Dim state=UO.GetScriptState(0)
    Select Case state
    Case 1
        UO.Print("running")
    Case 2
        UO.Print("paused")
    Case Else
        UO.Print("unknown")
    End Select
END SUB
```

**パラメーターと実行の説明:**

- Sub Mainを実行します。渡す0はインデックスで、空の括弧は引数なしを表します。Printの文字列は例のメッセージです。
- 手動／デバッガー停止と設定された切断時の停止を含みます。状態1は、その瞬間のCPU使用やサーバーデータ受信を保証しません。
- Integer状態コード：0＝存在しない／不明、1＝実行中、2＝一時停止。Booleanではないので、1や2と明示的に比較します。
- 必須のScriptIndexは、最新のGetScriptsListから取得する0始まりの整数です。負値または存在しないインデックスは、記載の空値／不明状態になります。アイテムserial、プロシージャ名、IDE実行IDを渡さないでください。

### ループまたは条件で使う

```vb
# ループまたは条件で使う
#
# インデックスに対応する実行状態を読みます。
#
# Integer状態コード：0＝存在しない／不明、1＝実行中、2＝一時停止。Booleanではないので、1や2と明示的に比較します。

SUB Main()
    # 複数のコマンドを組み合わせる独立した例です。配列は0始まりで、参照前に長さを確認します。Wait(250)がある場合は250ミリ秒待ちます。
    # 手動／デバッガー停止と設定された切断時の停止を含みます。状態1は、その瞬間のCPU使用やサーバーデータ受信を保証しません。
    # Integer状態コード：0＝存在しない／不明、1＝実行中、2＝一時停止。Booleanではないので、1や2と明示的に比較します。
    # 必須のScriptIndexは、最新のGetScriptsListから取得する0始まりの整数です。負値または存在しないインデックスは、記載の空値／不明状態になります。アイテムserial、プロシージャ名、IDE実行IDを渡さないでください。

    Dim paused=0
    Dim indices=UO.GetScriptsList()
    For Each index In indices
        If UO.GetScriptState(index)=2 Then
            paused+=1
        End If
    Next
    UO.Print(CStr(paused))
END SUB
```

**パラメーターと実行の説明:**

- 複数のコマンドを組み合わせる独立した例です。配列は0始まりで、参照前に長さを確認します。Wait(250)がある場合は250ミリ秒待ちます。
- 手動／デバッガー停止と設定された切断時の停止を含みます。状態1は、その瞬間のCPU使用やサーバーデータ受信を保証しません。
- Integer状態コード：0＝存在しない／不明、1＝実行中、2＝一時停止。Booleanではないので、1や2と明示的に比較します。
- 必須のScriptIndexは、最新のGetScriptsListから取得する0始まりの整数です。負値または存在しないインデックスは、記載の空値／不明状態になります。アイテムserial、プロシージャ名、IDE実行IDを渡さないでください。

### 完全な補助関数

```vb
# 完全な補助関数
#
# インデックスに対応する実行状態を読みます。
#
# Integer状態コード：0＝存在しない／不明、1＝実行中、2＝一時停止。Booleanではないので、1や2と明示的に比較します。

SUB Main()
    # Mainの下に関数全体を示します。その引数と結果は、内部のAPIコマンドとは区別して説明しています。
    # IsScriptActiveは1と2をtrue、0をfalseに変換します。GetScriptState自体は数値状態コードを返します。
    # Integer状態コード：0＝存在しない／不明、1＝実行中、2＝一時停止。Booleanではないので、1や2と明示的に比較します。
    # 必須のScriptIndexは、最新のGetScriptsListから取得する0始まりの整数です。負値または存在しないインデックスは、記載の空値／不明状態になります。アイテムserial、プロシージャ名、IDE実行IDを渡さないでください。

    If IsScriptActive(0)=True Then
        UO.Print("running or paused")
    Else
        UO.Print("not active")
    End If
END SUB

Function IsScriptActive(index) As Boolean
    Dim state=UO.GetScriptState(index)
    Return state=1 OrElse state=2
End Function
```

**パラメーターと実行の説明:**

- Mainの下に関数全体を示します。その引数と結果は、内部のAPIコマンドとは区別して説明しています。
- IsScriptActiveは1と2をtrue、0をfalseに変換します。GetScriptState自体は数値状態コードを返します。
- Integer状態コード：0＝存在しない／不明、1＝実行中、2＝一時停止。Booleanではないので、1や2と明示的に比較します。
- 必須のScriptIndexは、最新のGetScriptsListから取得する0始まりの整数です。負値または存在しないインデックスは、記載の空値／不明状態になります。アイテムserial、プロシージャ名、IDE実行IDを渡さないでください。
