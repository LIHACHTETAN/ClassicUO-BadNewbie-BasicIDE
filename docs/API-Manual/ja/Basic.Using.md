# Using / End Using

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ja -->

Using はブロックを離れるときにネイティブリソースを閉じます。既存の変数、またはリソースを返す式を受け取る形式をサポートします。

## 正確な構文

```text
Dim resource = MemoryStream()
Using resource
    statements
End Using
Using resourceExpression
    statements
End Using
```

## パラメーター

- `resourceExpression` — 開始時に一度だけ評価します。File(path)、MemoryStream()、CreateTimer(...) が対象です。タイマーの解放は永久停止です。Basic.Timers を参照してください。String、数値、List、Dictionary は本体の実行前にソース行付きエラーになります。変数は先に宣言してください。ヘッダー内の宣言、As New、カンマ区切りの資源、ユーザー定義 Dispose は未対応です。
- `statements / End Using` — End Using は取得済みのオブジェクトを閉じます。変数は残りますがリソースは閉じています。複数のリソースはブロックを入れ子にします。変数を再代入しても閉じる元のオブジェクトは変わりません。

## 戻り値

文自体に戻り値はありません。本体の Return はリソースを解放してから手続きを離れます。例の IsClosed は 1/True または 0/False を返す自作関数です。Main の結果は文字列であり、成功フラグではありません。

## 動作

- File(path) はラッパーを作成します。ブロック内で書き込みは Create()、読み込みは Open() を呼びます。Dispose は Close() によりバッファーとハンドルを解放します。MemoryStream を閉じると Length() はエラーになります。例はメモリだけを使い、ファイルを作りません。
- コンパイラーは保護領域を作り、インタープリターは現在の呼び出しでオブジェクトを保持します。End Using、Return、Exit、Continue、外へのジャンプは内側から外側の順で閉じます。本体へのジャンプは実行前に拒否されます。
- 通常のエラーでは外側の Catch 前に解放します。失敗した Dispose は再試行せず、外側の資源も閉じます。緊急停止はスクリプトの Catch/Finally を省略しますが、ネイティブ資源は解放します。終了エラーはキャンセルを置き換えません。一時停止中は再開か停止まで保持します。スレッドは追加せず、OS の停止中のクローズ処理を強制中断する機能ではありません。
- 資源を開いたままエラーを回復するには、Using 内に Try/Catch を置きます。On Error Resume Next で本体の未処理エラーが発生すると資源を閉じ、ブロック全体の後から続行します。On Error GoTo は Using 内のラベルを指定できません。すでに閉じた保護領域へ再び入ることになるためです。
- エラーで Using を離れた後、外側の On Error GoTo ハンドラーの Resume はブロックの先頭から再実行し、資源の式を再評価します。Resume Next は End Using の直後へ進みます。閉じたオブジェクトを指す変数では再び開きません。再試行には新しい資源を取得する式を使います。実行済みの処理が繰り返されることがあります。

## 使用例

### 1. メモリストリームを閉じる

```vb
# stream が資源、size は開いている間の Length()=0 です。終了後 IsClosed がエラーを捕捉して True=1 を返し、Main は "0:1" を返します。ByVal は参照をコピーします。この学習用関数は Length のあらゆるエラーを閉鎖とみなすため、これらのストリーム専用です。
Option Explicit On
Function IsClosed(ByVal stream) As Boolean
    Try
        Dim size = stream.Length()
        Return False
    Catch closed
        Return True
    End Try
End Function

Sub Main()
    Dim stream = MemoryStream()
    Dim size = -1
    Using stream
        size = stream.Length()
    End Using
    Return CStr(size) & ":" & CStr(IsClosed(stream))
End Sub
```

**パラメーターと実行の説明:**

stream が資源、size は開いている間の Length()=0 です。終了後 IsClosed がエラーを捕捉して True=1 を返し、Main は "0:1" を返します。ByVal は参照をコピーします。この学習用関数は Length のあらゆるエラーを閉鎖とみなすため、これらのストリーム専用です。

### 2. 補助関数から戻る

```vb
# ReadLength(stream) は Integer 0 を計算します。Return は Main が size を受け取る前にストリームを閉じます。次の Length は失敗し、closed=True、結果は "0:1" です。呼び出し側で開いたまま必要な資源は渡さないでください。
Option Explicit On
Function ReadLength(ByVal stream) As Integer
    Using stream
        Return stream.Length()
    End Using
End Function

Sub Main()
    Dim stream = MemoryStream()
    Dim size = ReadLength(stream)
    Dim closed = False
    Try
        Dim after = stream.Length()
    Catch problem
        closed = True
    End Try
    Return CStr(size) & ":" & CStr(closed)
End Sub
```

**パラメーターと実行の説明:**

ReadLength(stream) は Integer 0 を計算します。Return は Main が size を受け取る前にストリームを閉じます。次の Length は失敗し、closed=True、結果は "0:1" です。呼び出し側で開いたまま必要な資源は渡さないでください。

### 3. エラー時の入れ子解放

```vb
# outer と inner は別のストリームです。Throw "demo" は inner、outer の順に閉じます。Catch は元のメッセージを保持し、IsClosed は各 1 を返します。Main は "demo:2"。2 は閉じたオブジェクトの数で、Boolean ではありません。
Option Explicit On
Function IsClosed(ByVal stream) As Boolean
    Try
        Dim size = stream.Length()
        Return False
    Catch closed
        Return True
    End Try
End Function

Sub Main()
    Dim outer = MemoryStream()
    Dim inner = MemoryStream()
    Dim message = ""
    Try
        Using outer
            Using inner
                Throw "demo"
            End Using
        End Using
    Catch problem
        message = problem
    End Try
    Return message & ":" & CStr(IsClosed(outer) + IsClosed(inner))
End Sub
```

**パラメーターと実行の説明:**

outer と inner は別のストリームです。Throw "demo" は inner、outer の順に閉じます。Catch は元のメッセージを保持し、IsClosed は各 1 を返します。Main は "demo:2"。2 は閉じたオブジェクトの数で、Boolean ではありません。

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: usingStatement / USING / END_USING
Runtime/Instructions/Generator.cs: Generate(UsingStatementContext)
Runtime/Interpreter.cs: TryExecutionScope.DisposeResource / Transfer / DeferReturn / CallSubrutine
Runtime/ObjectTypes/FileObject.cs: Dispose / Close
Runtime/ObjectTypes/MemoryStreamObject.cs: Dispose
Analysis/TryStructureValidator.cs: Regions
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/using-statement
-->
