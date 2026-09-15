# Declare / Lib / Alias

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ja -->

Declare は Basic の手続き名をネイティブ Windows x64 DLL のエクスポート関数に接続します。対応範囲は以下のとおりで、コンパイル済みクライアントでも実行時コード生成を使いません。VB.NET 相互運用全体には相当しません。

## 正確な構文

```text
[Public | Private] Declare [Ansi | Unicode | Auto] Function name Lib "library.dll" [Alias "export"]([ByVal arg As Type, ...]) As ResultType
[Public | Private] Declare [Ansi | Unicode | Auto] Sub name Lib "library.dll" [Alias "export"]([ByVal arg As Type, ...])
name(arguments)
name(argumentName:=value)
ModuleName.name(arguments)
```

## パラメーター

- `name / Public / Private` — ローカル名は大文字小文字を区別せず、UO. なしで呼び出します。ファイルまたは Module レベルに宣言し、本体や End Function/End Sub は書きません。既定は Public、Module 内では Private が可能です。組み込み Basic/UO 名を上書きせず、別名と Alias を使います。
- `Lib / library.dll` — 必須の .dll 名またはパス。単純なシステム名は先に System32 を検索し、それ以外の相対パスは Include を含む宣言元ファイルが基準です。絶対パスも可能です。現在の作業ディレクトリや PATH は検索しません。依存 DLL は隣接フォルダーまたは System32 に置けます。
- `Alias / export` — 省略可能な、大文字小文字を区別する正確なエクスポート名。省略時はローカル簡易名です。序数による指定は非対応です。宣言と完全に一致するネイティブ Windows x64 関数が必要で、管理された .NET メソッドではありません。
- `Ansi / Unicode / Auto` — 既定の Ansi は Windows ANSI 文字コードにコピーするため表せない文字が失われる場合があります。Unicode は UTF-16 です。両方とも正確な名前を検索します。Auto は UTF-16 で、正確な名前、次に W を付けた名前を検索します。実際のエクスポートの文字コードは推測できないので、Unicode API には Unicode と明示的な W 名を推奨します。
- `ByVal arg As Type` — 引数は 0～4 個。各パラメーターに ByVal と As Integer、Double、Boolean、String のいずれかを明記します。Integer は符号付き32ビット、Double は64ビット、Boolean は32ビット Windows BOOL で、C/C++ bool ではありません。String は読み取り専用の一時的な NUL 終端入力コピーで、最大1048576 UTF-16単位、内部NUL不可です。DLL はポインターを保持・書き込みしてはいけません。名前付き引数はローカル名を使用します。ByRef、Optional、ParamArray、配列、構造体、ポインターは非対応です。
- `As ResultType / Sub` — Function は As Integer、Double または Boolean が必須です。Sub に As はなく Unit になります。Integer/Boolean 引数は Integer 値に限り、Double は Integer も受け取れます。必要なら CInt/CDbl/CStr で明示変換します。文字列、ポインター、64ビット整数の戻り値には対応署名のネイティブラッパーが必要です。

## 戻り値

Integer は符号付き32ビット数で、意味はネイティブ関数によります。必ずしも成功フラグではありません。Double は64ビット浮動小数点数です。As Boolean はゼロを0/False、非ゼロBOOLを1/Trueに正規化します。このフラグでは1/0とTrue/Falseの比較は同等です。Sub は値を返しません（Unit）。例の結果は1、"3:8"、"missing export:1"です。

## 動作

- 非対応宣言は実行前に SC031 で拒否します。ルートスクリプトごとに宣言256個、ロード済みDLL64個までです。解析やIDE補完はDLLをロードしません。実際の署名は判別できず、誤った宣言でクライアントがクラッシュする可能性があります。
- 初回呼び出しでDLLをロードし、以後はライブラリとアドレスを再利用します。引数は記述順に一度だけ評価し、その後名前順に配置します。ロード、アーキテクチャ、エクスポート、変換の失敗はTry/Catchで捕捉できますが、ネイティブメモリ違反は通常の回復可能なスクリプトエラーではありません。
- 変換失敗を含め、呼び出しごとに一時文字列を解放します。ルートスクリプト終了・失敗・キャンセル時にライブラリを解放します。IDEを閉じるだけでは実行中のスクリプトとDLLは維持されます。
- スクリプトワーカーで同期実行します。停止・一時停止は呼び出し前後で検査し、戻らないネイティブ関数は中断できません。短い操作を使い、待機にはBasic Waitを使ってください。管理DLL、Basicへのコールバック、可変引数エクスポート、任意ポインターAPIは非対応です。

## 使用例

### 1. クライアントのプロセスID

```vb
# ClientProcessIdはkernel32.dllのGetCurrentProcessIdを引数なしで呼びます。MainはWindowsの数値IDをprocessIdに保存し、processId > 0で1/Trueを返します。ID自体はBooleanでもUOシリアルでもありません。
Option Explicit On
Declare Function ClientProcessId Lib "kernel32.dll" Alias "GetCurrentProcessId"() As Integer

Sub Main()
    Dim processId = ClientProcessId()
    Return processId > 0
End Sub
```

**パラメーターと実行の説明:**

ClientProcessIdはkernel32.dllのGetCurrentProcessIdを引数なしで呼びます。MainはWindowsの数値IDをprocessIdに保存し、processId > 0で1/Trueを返します。ID自体はBooleanでもUOシリアルでもありません。

### 2. 文字列、べき乗、名前付き引数

```vb
# TextLength(text)はUTF-16をlstrlenWへ渡し長さを返します。Power(value, exponent)は2個のDoubleでpowを呼びます。Describe("ore", 2, 3)は3引数を受け取り、Powerの名前付き引数を逆順に記述して"3:8"を返します。補助関数も完全に示しています。
Option Explicit On
Declare Unicode Function TextLength Lib "kernel32.dll" Alias "lstrlenW"(ByVal text As String) As Integer
Declare Function Power Lib "ucrtbase.dll" Alias "pow"(ByVal value As Double, ByVal exponent As Double) As Double

Function Describe(ByVal text As String, ByVal value As Double, ByVal exponent As Double) As String
    Dim length = TextLength(text:=text)
    Dim powered = Power(exponent:=exponent, value:=value)
    Return CStr(length) & ":" & CStr(powered)
End Function

Sub Main()
    Return Describe("ore", 2, 3)
End Sub
```

**パラメーターと実行の説明:**

TextLength(text)はUTF-16をlstrlenWへ渡し長さを返します。Power(value, exponent)は2個のDoubleでpowを呼びます。Describe("ore", 2, 3)は3引数を受け取り、Powerの名前付き引数を逆順に記述して"3:8"を返します。補助関数も完全に示しています。

### 3. エクスポートがない場合

```vb
# NativeDemo.MissingExportは意図的に存在しない名前です。TryReadがエラーを捕捉してstatus="missing export"、Finallyがfinished=1にし、Mainは"missing export:1"を返します。Privateは宣言をモジュール内に限定します。通常のエラー処理の例であり、緊急キャンセル後のスクリプト後処理を保証しません。
Option Explicit On
Module NativeDemo
    Private Declare Function MissingExport Lib "kernel32.dll" Alias "BasicManualMissingExport_71cf"() As Integer
    Public Function TryRead() As String
        Dim status = "unexpected export"
        Dim finished = 0
        Try
            MissingExport()
        Catch problem
            status = "missing export"
        Finally
            finished = 1
        End Try
        Return status & ":" & CStr(finished)
    End Function
End Module

Sub Main()
    Return NativeDemo.TryRead()
End Sub
```

**パラメーターと実行の説明:**

NativeDemo.MissingExportは意図的に存在しない名前です。TryReadがエラーを捕捉してstatus="missing export"、Finallyがfinished=1にし、Mainは"missing export:1"を返します。Privateは宣言をモジュール内に限定します。通常のエラー処理の例であり、緊急キャンセル後のスクリプト後処理を保証しません。


### 内部関数：呼び出しから結果まで

Declare は Basic の手続き名をネイティブ Windows x64 DLL のエクスポート関数に接続します。対応範囲は以下のとおりで、コンパイル済みクライアントでも実行時コード生成を使いません。VB.NET 相互運用全体には相当しません。

#### 1. ExternalDeclaration

非対応宣言は実行前に SC031 で拒否します。ルートスクリプトごとに宣言256個、ロード済みDLL64個までです。解析やIDE補完はDLLをロードしません。実際の署名は判別できず、誤った宣言でクライアントがクラッシュする可能性があります。

`source -> typed declaration -> SC031 on unsupported ABI`

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/ExternalDeclaration.cs`; 関数 `ExternalDeclaration`.

#### 2. LibraryPath / GetCallable

必須の .dll 名またはパス。単純なシステム名は先に System32 を検索し、それ以外の相対パスは Include を含む宣言元ファイルが基準です。絶対パスも可能です。現在の作業ディレクトリや PATH は検索しません。依存 DLL は隣接フォルダーまたは System32 に置けます。

`first call -> absolute DLL path -> cached library -> exact export`

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/ExternalLibraries.cs`; 関数 `LibraryPath / GetCallable`.

#### 3. Invoke

引数は 0～4 個。各パラメーターに ByVal と As Integer、Double、Boolean、String のいずれかを明記します。Integer は符号付き32ビット、Double は64ビット、Boolean は32ビット Windows BOOL で、C/C++ bool ではありません。String は読み取り専用の一時的な NUL 終端入力コピーで、最大1048576 UTF-16単位、内部NUL不可です。DLL はポインターを保持・書き込みしてはいけません。名前付き引数はローカル名を使用します。ByRef、Optional、ParamArray、配列、構造体、ポインターは非対応です。

`evaluate arguments once -> validate kinds -> copy input strings -> select compiled call shape`

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/ExternalLibraries.cs`; 関数 `Invoke`.

#### 4. CallInteger / CallDouble / CallVoid

Function は As Integer、Double または Boolean が必須です。Sub に As はなく Unit になります。Integer/Boolean 引数は Integer 値に限り、Double は Integer も受け取れます。必要なら CInt/CDbl/CStr で明示変換します。文字列、ポインター、64ビット整数の戻り値には対応署名のネイティブラッパーが必要です。

`Windows x64 argument slots -> native call -> declared result`

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/ExternalCallSites.cs`; 関数 `CallInteger / CallDouble / CallVoid`.

#### 5. Dispose

変換失敗を含め、呼び出しごとに一時文字列を解放します。ルートスクリプト終了・失敗・キャンセル時にライブラリを解放します。IDEを閉じるだけでは実行中のスクリプトとDLLは維持されます。

`finally: free temporary strings; root exit: release DLL handles in reverse order`

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/ExternalLibraries.cs`; 関数 `Dispose`.

Integer は符号付き32ビット数で、意味はネイティブ関数によります。必ずしも成功フラグではありません。Double は64ビット浮動小数点数です。As Boolean はゼロを0/False、非ゼロBOOLを1/Trueに正規化します。このフラグでは1/0とTrue/Falseの比較は同等です。Sub は値を返しません（Unit）。例の結果は1、"3:8"、"missing export:1"です。

<!-- implementation references (not callable script procedures):
Runtime/ExternalDeclaration.cs: type and declaration validation
Analysis/ExternalDeclarationValidator.cs: SC031
Runtime/ExternalLibraries.cs: LibraryPath / GetCallable / Invoke / Dispose
Runtime/ExternalCallSites.cs: CallInteger / CallDouble / CallVoid
Runtime/Interpreter.cs: CallSubrutine / CallObserved
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/declare-statement
https://learn.microsoft.com/en-us/cpp/build/x64-calling-convention?view=msvc-170
https://learn.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-loadlibraryexw
-->
