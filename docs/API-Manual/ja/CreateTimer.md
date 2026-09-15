# CreateTimer / script timers

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ja -->

CreateTimer は停止状態のコールバックタイマーを作成します。Start は同じスクリプト実行スレッドで Sub を予約します。この独自拡張は、経過秒を読む Basic Timer() とは別です。

## 正確な構文

```text
CreateTimer(milliseconds, handler) -> Object (ScriptTimer)
CreateTimer(milliseconds, handler, repeating) -> Object (ScriptTimer)
timer.Start() -> Unit
timer.Stop() -> Unit
timer.Dispose() -> Unit
timer.Enabled() -> Integer (0/1)
timer.Interval() -> Integer (ms)
timer.SetInterval(milliseconds) -> Unit
Using timer ... End Using
```

## パラメーター

- `milliseconds` — milliseconds は 1～2147483647 の Integer（ミリ秒）です。文字列、小数、0、負数はエラーです。SetInterval も同じ規則です。Interval() は設定間隔であり残り時間ではありません。
- `handler` — 引数が一つもない一意の Sub を指す AddressOf、または現在のスクリプトのコールバック変数／ファクトリーです。Function、Optional/ParamArray、名前文字列、別スクリプトの参照は不可です。共有状態は Module フィールドへ保存します。ローカル変数のクロージャーは作りません。
- `repeating` — 省略可能な第3引数は True/1 で繰り返し、False/0 で一度だけです。既定は True。名前付き引数は repeating:= です。それ以外の数値や文字列はエラーです。一度だけのタイマーはハンドラー呼び出し前に無効になります。
- `timer / Start / Stop / Dispose / SetInterval` — メソッドは Start、Stop、Dispose、Enabled、Interval、SetInterval(milliseconds) です。有効なタイマーの Start は何もしません。Stop 後は再開可能です。SetInterval は有効なら現在から計り直し、停止中なら停止を維持します。Dispose は何度呼んでもよい永久解放で、その後の Start/SetInterval はエラーです。Using は取得したオブジェクトを終了時に解放します。

## 戻り値

CreateTimer は Object（ScriptTimer）を返し、アイテムIDやスクリプト番号ではありません。Start/Stop/Dispose/SetInterval は Unit。Enabled は Integer の 1=True、0=False で、どちらの比較も可能です。Interval はミリ秒であり Boolean ではありません。例の戻り値は String "3:0"、"ready:0"、"tick failed:0" です。

## 動作

- 単調な経過時間を文の間および Basic Wait/Sleep、Wait Until 内で確認します。有効なタイマーがある場合、Wait は最大25ミリ秒の区間に分かれます。ゲームAPIや他のブロッキング呼び出しは先に戻る必要があります。厳密な実時間精度は保証せず、新しいスレッドも作りません。
- 期限順、同じなら作成順です。1回の確認で最大64個を呼び、残りは次の確認へ回します。ハンドラー中は Wait があっても他のタイマーを再入実行しません。次の間隔は完了から計測し、逃した間隔は蓄積しません。一時停止中は呼ばず、再開後に期限超過のタイマーを一度実行します。
- ハンドラーのエラーはタイマーを無効にして呼び出し元の Catch/Finally へ伝わります。内部からの Stop/SetInterval は有効です。緊急停止は通常の Catch に吸収されません。最上位実行の終了、エラー、停止でタイマーを解放し、再実行／再読み込み時には作り直します。IDEだけを閉じても実行中スクリプトのタイマーは続きます。未解放は最大1024個で、Dispose が枠を返します。
- RunThreePulses と GetHandler は全文を示した補助関数です。内部では CreateTimer が引数と所有者を検証し、Start が期限を設定し、Pump が Sub を呼び、Fire が完了後の次期限を設定し、Release が最上位呼び出しの終了時に解放します。スクリプト終了後に独立サービスは残りません。

## 使用例

### 1. 3回の定期呼び出しと解放

```vb
# RunThreePulses は20ミリ秒、既定の repeating=True を設定します。CountPulse が State.count を増やして3で停止します。Wait Until は3000ミリ秒の制限内で状態とタイマーを確認します。Enabled()=0 なので結果は "3:0"。Return 時にも Using が解放します。
Option Explicit On
Module State
    Public Dim count As Integer = 0
    Public Dim pulse
End Module

Sub CountPulse()
    State.count += 1
    If State.count >= 3 Then
        State.pulse.Stop()
    End If
End Sub

Function RunThreePulses() As String
    State.pulse = CreateTimer(20, AddressOf CountPulse)
    Using State.pulse
        State.pulse.Start()
        Wait Until State.count >= 3 Timeout 3000
        Return CStr(State.count) & ":" & CStr(State.pulse.Enabled())
    End Using
End Function

Sub Main()
    Return RunThreePulses()
End Sub
```

**パラメーターと実行の説明:**

RunThreePulses は20ミリ秒、既定の repeating=True を設定します。CountPulse が State.count を増やして3で停止します。Wait Until は3000ミリ秒の制限内で状態とタイマーを確認します。Enabled()=0 なので結果は "3:0"。Return 時にも Using が解放します。

### 2. 一度だけの呼び出し

```vb
# GetHandler は AddressOf SetReady を返します。名前付き引数は5ミリ秒、callback、repeating=False。SetInterval は Start 前に10へ変更します。SetReady が "ready" を保存するときタイマーは無効です。Main は最大3000ミリ秒待ち、"ready:0" を返します。補助関数もすべて掲載しています。
Option Explicit On
Module State
    Public Dim message As String = ""
End Module

Sub SetReady()
    State.message = "ready"
End Sub

Function GetHandler()
    Return AddressOf SetReady
End Function

Sub Main()
    Dim callback = GetHandler()
    Dim notice = CreateTimer(repeating:=False, handler:=callback, milliseconds:=5)
    Using notice
        notice.SetInterval(10)
        notice.Start()
        Wait Until State.message = "ready" Timeout 3000
        Return State.message & ":" & CStr(notice.Enabled())
    End Using
End Sub
```

**パラメーターと実行の説明:**

GetHandler は AddressOf SetReady を返します。名前付き引数は5ミリ秒、callback、repeating=False。SetInterval は Start 前に10へ変更します。SetReady が "ready" を保存するときタイマーは無効です。Main は最大3000ミリ秒待ち、"ready:0" を返します。補助関数もすべて掲載しています。

### 3. Wait 中のエラー

```vb
# FailingPulse は "tick failed" を送出します。5ミリ秒タイマーが Wait(2000) 中に動き、無効になって待機を中断します。Catch は文字列と Enabled()=0 を保存し、Finally が解放します。"tick failed:0" はメッセージと状態です。緊急停止は実行エンジンが処理します。
Option Explicit On
Sub FailingPulse()
    Throw "tick failed"
End Sub

Sub Main()
    Dim pulse = CreateTimer(5, AddressOf FailingPulse)
    Dim problemText As String = ""
    Dim enabledAfterError As Boolean = True
    Try
        pulse.Start()
        Wait(2000)
    Catch problem
        problemText = problem
        enabledAfterError = pulse.Enabled()
    Finally
        pulse.Dispose()
    End Try
    Return problemText & ":" & CStr(enabledAfterError)
End Sub
```

**パラメーターと実行の説明:**

FailingPulse は "tick failed" を送出します。5ミリ秒タイマーが Wait(2000) 中に動き、無効になって待機を中断します。Catch は文字列と Enabled()=0 を保存し、Finally が解放します。"tick failed:0" はメッセージと状態です。緊急停止は実行エンジンが処理します。


### 内部関数：呼び出しから結果まで

RunThreePulses と GetHandler は全文を示した補助関数です。内部では CreateTimer が引数と所有者を検証し、Start が期限を設定し、Pump が Sub を呼び、Fire が完了後の次期限を設定し、Release が最上位呼び出しの終了時に解放します。スクリプト終了後に独立サービスは残りません。

#### 1. CreateTimer

milliseconds は 1～2147483647 の Integer（ミリ秒）です。文字列、小数、0、負数はエラーです。SetInterval も同じ規則です。Interval() は設定間隔であり残り時間ではありません。

引数が一つもない一意の Sub を指す AddressOf、または現在のスクリプトのコールバック変数／ファクトリーです。Function、Optional/ParamArray、名前文字列、別スクリプトの参照は不可です。共有状態は Module フィールドへ保存します。ローカル変数のクロージャーは作りません。

省略可能な第3引数は True/1 で繰り返し、False/0 で一度だけです。既定は True。名前付き引数は repeating:= です。それ以外の数値や文字列はエラーです。一度だけのタイマーはハンドラー呼び出し前に無効になります。

CreateTimer は Object（ScriptTimer）を返し、アイテムIDやスクリプト番号ではありません。Start/Stop/Dispose/SetInterval は Unit。Enabled は Integer の 1=True、0=False で、どちらの比較も可能です。Interval はミリ秒であり Boolean ではありません。例の戻り値は String "3:0"、"ready:0"、"tick failed:0" です。

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Timers.cs`; 関数 `CreateTimer`.

#### 2. Start

メソッドは Start、Stop、Dispose、Enabled、Interval、SetInterval(milliseconds) です。有効なタイマーの Start は何もしません。Stop 後は再開可能です。SetInterval は有効なら現在から計り直し、停止中なら停止を維持します。Dispose は何度呼んでもよい永久解放で、その後の Start/SetInterval はエラーです。Using は取得したオブジェクトを終了時に解放します。

`Due = now + interval; enabled = true;`

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ScriptTimerObject.cs`; 関数 `Start`.

#### 3. WaitWithTimers

単調な経過時間を文の間および Basic Wait/Sleep、Wait Until 内で確認します。有効なタイマーがある場合、Wait は最大25ミリ秒の区間に分かれます。ゲームAPIや他のブロッキング呼び出しは先に戻る必要があります。厳密な実時間精度は保証せず、新しいスレッドも作りません。

`checkpoint -> Pump -> min(remaining, nextDue, 25 ms) -> Wait`

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Timers.cs`; 関数 `WaitWithTimers`.

#### 4. Pump

期限順、同じなら作成順です。1回の確認で最大64個を呼び、残りは次の確認へ回します。ハンドラー中は Wait があっても他のタイマーを再入実行しません。次の間隔は完了から計測し、逃した間隔は蓄積しません。一時停止中は呼ばず、再開後に期限超過のタイマーを一度実行します。

`snapshot -> deadline / sequence -> checkpoint -> Fire; limit = 64`

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/ScriptTimerScheduler.cs`; 関数 `Pump`.

#### 5. Fire

ハンドラーのエラーはタイマーを無効にして呼び出し元の Catch/Finally へ伝わります。内部からの Stop/SetInterval は有効です。緊急停止は通常の Catch に吸収されません。最上位実行の終了、エラー、停止でタイマーを解放し、再実行／再読み込み時には作り直します。IDEだけを閉じても実行中スクリプトのタイマーは続きます。未解放は最大1024個で、Dispose が枠を返します。

`callback -> completion -> next Due; error -> disabled -> throw`

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ScriptTimerObject.cs`; 関数 `Fire`.

#### 6. Dispose

メソッドは Start、Stop、Dispose、Enabled、Interval、SetInterval(milliseconds) です。有効なタイマーの Start は何もしません。Stop 後は再開可能です。SetInterval は有効なら現在から計り直し、停止中なら停止を維持します。Dispose は何度呼んでもよい永久解放で、その後の Start/SetInterval はエラーです。Using は取得したオブジェクトを終了時に解放します。

`Release -> scheduler.Remove -> Changed`

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ScriptTimerObject.cs`; 関数 `Dispose`.

#### 7. Release

ハンドラーのエラーはタイマーを無効にして呼び出し元の Catch/Finally へ伝わります。内部からの Stop/SetInterval は有効です。緊急停止は通常の Catch に吸収されません。最上位実行の終了、エラー、停止でタイマーを解放し、再実行／再読み込み時には作り直します。IDEだけを閉じても実行中スクリプトのタイマーは続きます。未解放は最大1024個で、Dispose が枠を返します。

`timer.Release for each handle -> timers.Clear -> no pending deadline`

プロジェクトのソース: `external/InjectionScript/src/InjectionScript/Runtime/ScriptTimerScheduler.cs`; 関数 `Release`.

RunThreePulses は20ミリ秒、既定の repeating=True を設定します。CountPulse が State.count を増やして3で停止します。Wait Until は3000ミリ秒の制限内で状態とタイマーを確認します。Enabled()=0 なので結果は "3:0"。Return 時にも Using が解放します。

<!-- implementation references (not callable script procedures):
Runtime/InjectionApi.cs: CreateTimer / Wait
Runtime/Interpreter.Timers.cs: CreateTimer / WaitWithTimers / TimerCheckpoint
Runtime/ScriptTimerScheduler.cs: Pump / Delay / Release
Runtime/ObjectTypes/ScriptTimerObject.cs: Start / Fire / SetInterval / Dispose
Runtime/Interpreter.cs: statement checkpoints / VisitWaitUntilStatement / root-call cleanup
Runtime/RealTimeSource.cs: Stopwatch elapsed time
https://learn.microsoft.com/en-us/dotnet/api/system.diagnostics.stopwatch
https://learn.microsoft.com/en-us/dotnet/api/system.threading.timer (comparison only; this script timer does not use ThreadPool callbacks)
-->
