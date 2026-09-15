# UO.GetScriptsList

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: ja -->

現在の数値スクリプトインデックスを返します。

## 正確な構文

```text
UO.GetScriptsList() -> Array
```

## パラメーター

引数はありません。

## 戻り値

IntegerのArray：インデックス0..N-1、または空配列です。要素は数値であり、名前やテキストレコードではありません。

## 動作

- 実行中と一時停止中を含み、完了済みやキャンセル要求済みは除きます。呼び出し元は通常自分自身も数えます。読み込んだだけのIDEタブは実行ではありません。
- インデックスは起動順の現在位置です。起動や停止で位置が変わります。別々の呼び出しは単一の不可分なスナップショットではありません。後で制御するときは一覧を再取得します。
- Basic IDEを閉じても有効な実行は消えません。対象はこのクライアントであり、別クライアントやWindowsプロセスではありません。
- GetScriptsListはインデックス、GetScriptsCountは個数、GetScriptStateは3状態のコードです。取り違えたり、すべての非ゼロ値をtrueと扱ったりしないでください。
- 引数はありません。各数値を名前・パス・状態の取得関数へ渡します。返された配列は独立したスナップショットで、編集してもスクリプトの制御にはなりません。

### 内部関数：呼び出しから結果まで

以下はクライアントの実際のメソッドです。上のBasic例には完全な補助関数があります。内部C#メソッド名は追加のスクリプトコマンドではありません。

#### 1. ExecuteStealthCompatibility

Runtimeは登録されたUO呼び出しを実行し、ブリッジの結果をInteger、String、Arrayとして包みます。

IntegerのArray：インデックス0..N-1、または空配列です。要素は数値であり、名前やテキストレコードではありません。

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 関数 `ExecuteStealthCompatibility`.

#### 2. GetScriptsList

ブリッジはこのクライアントの実行マネージャーに委譲します。

引数はありません。各数値を名前・パス・状態の取得関数へ渡します。返された配列は独立したスナップショットで、編集してもスクリプトの制御にはなりません。

プロジェクトのソース: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 関数 `GetScriptsList`.

#### 3. GetScriptsList

`Enumerable.Range(0, GetScriptsCount()).ToArray()`

インデックスは起動順の現在位置です。起動や停止で位置が変わります。別々の呼び出しは単一の不可分なスナップショットではありません。後で制御するときは一覧を再取得します。

プロジェクトのソース: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; 関数 `GetScriptsList`.

Basic IDEを閉じても有効な実行は消えません。対象はこのクライアントであり、別クライアントやWindowsプロセスではありません。


## 使用例

### 最初の呼び出しと結果

```vb
# 最初の呼び出しと結果
#
# 現在の数値スクリプトインデックスを返します。
#
# IntegerのArray：インデックス0..N-1、または空配列です。要素は数値であり、名前やテキストレコードではありません。

SUB Main()
    # Sub Mainを実行します。渡す0はインデックスで、空の括弧は引数なしを表します。Printの文字列は例のメッセージです。
    # 引数はありません。各数値を名前・パス・状態の取得関数へ渡します。返された配列は独立したスナップショットで、編集してもスクリプトの制御にはなりません。
    # IntegerのArray：インデックス0..N-1、または空配列です。要素は数値であり、名前やテキストレコードではありません。

    Dim indices=UO.GetScriptsList()
    For Each index In indices
        UO.Print(CStr(index) & ": " & UO.GetScriptName(index))
    Next
END SUB
```

**パラメーターと実行の説明:**

- Sub Mainを実行します。渡す0はインデックスで、空の括弧は引数なしを表します。Printの文字列は例のメッセージです。
- 引数はありません。各数値を名前・パス・状態の取得関数へ渡します。返された配列は独立したスナップショットで、編集してもスクリプトの制御にはなりません。
- IntegerのArray：インデックス0..N-1、または空配列です。要素は数値であり、名前やテキストレコードではありません。

### ループまたは条件で使う

```vb
# ループまたは条件で使う
#
# 現在の数値スクリプトインデックスを返します。
#
# IntegerのArray：インデックス0..N-1、または空配列です。要素は数値であり、名前やテキストレコードではありません。

SUB Main()
    # 複数のコマンドを組み合わせる独立した例です。配列は0始まりで、参照前に長さを確認します。Wait(250)がある場合は250ミリ秒待ちます。
    # 引数はありません。各数値を名前・パス・状態の取得関数へ渡します。返された配列は独立したスナップショットで、編集してもスクリプトの制御にはなりません。
    # IntegerのArray：インデックス0..N-1、または空配列です。要素は数値であり、名前やテキストレコードではありません。

    Dim indices=UO.GetScriptsList()
    If GetArrayLength(indices)>0 Then
        Dim firstIndex=indices[0]
        UO.Print(UO.GetScriptPath(firstIndex))
    End If
END SUB
```

**パラメーターと実行の説明:**

- 複数のコマンドを組み合わせる独立した例です。配列は0始まりで、参照前に長さを確認します。Wait(250)がある場合は250ミリ秒待ちます。
- 引数はありません。各数値を名前・パス・状態の取得関数へ渡します。返された配列は独立したスナップショットで、編集してもスクリプトの制御にはなりません。
- IntegerのArray：インデックス0..N-1、または空配列です。要素は数値であり、名前やテキストレコードではありません。

### 完全な補助関数

```vb
# 完全な補助関数
#
# 現在の数値スクリプトインデックスを返します。
#
# IntegerのArray：インデックス0..N-1、または空配列です。要素は数値であり、名前やテキストレコードではありません。

SUB Main()
    # Mainの下に関数全体を示します。その引数と結果は、内部のAPIコマンドとは区別して説明しています。
    # FindNamedScriptは表示名が完全一致する最初の現在インデックス、なければ-1を返します。名前は重複し、インデックスは後で変わり得ます。
    # IntegerのArray：インデックス0..N-1、または空配列です。要素は数値であり、名前やテキストレコードではありません。

    Dim index=FindNamedScript("Mining")
    If index>=0 Then
        UO.Print(CStr(index))
    Else
        UO.Print("Name not found")
    End If
END SUB

Function FindNamedScript(wanted) As Integer
    Dim indices=UO.GetScriptsList()
    For Each index In indices
        If UO.GetScriptName(index)=wanted Then
            Return index
        End If
    Next
    Return -1
End Function
```

**パラメーターと実行の説明:**

- Mainの下に関数全体を示します。その引数と結果は、内部のAPIコマンドとは区別して説明しています。
- FindNamedScriptは表示名が完全一致する最初の現在インデックス、なければ-1を返します。名前は重複し、インデックスは後で変わり得ます。
- IntegerのArray：インデックス0..N-1、または空配列です。要素は数値であり、名前やテキストレコードではありません。
