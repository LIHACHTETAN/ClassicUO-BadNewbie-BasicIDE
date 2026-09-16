# AddHandler UO.JournalEntry / client events

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ja -->

AddHandler で新しいジャーナル行、キャラクターの資源、接続状態の変化を購読します。これらの UO. 名はイベントであり関数ではありません。括弧で呼び出したり RaiseEvent で発生させたりできません。

## 正確な構文

```text
AddHandler UO.JournalEntry, AddressOf OnJournal
Sub OnJournal(ByVal text As String, ByVal serial As Integer, ByVal name As String, ByVal hue As Integer)
AddHandler UO.HitPointsChanged, AddressOf OnHits
AddHandler UO.ManaChanged, AddressOf OnMana
AddHandler UO.StaminaChanged, AddressOf OnStamina
Sub OnHits(ByVal current As Integer, ByVal previous As Integer)
Sub OnMana(ByVal current As Integer, ByVal previous As Integer)
Sub OnStamina(ByVal current As Integer, ByVal previous As Integer)
AddHandler UO.ConnectionChanged, AddressOf OnConnection
Sub OnConnection(ByVal online As Boolean)
RemoveHandler UO.JournalEntry, AddressOf OnJournal
```

## パラメーター

- `Handler / AddressOf` — 現在読み込まれているスクリプトの Sub を AddressOf で渡します。全引数に ByVal を明記し、型と順序をシグネチャに合わせます。Function、Optional、ParamArray、別スクリプトのコールバックは使用できません。
- `text / serial / name / hue` — JournalEntry は text String、serial Integer（発信元 ID、存在しない場合 0）、name String、hue Integer（UO 色番号、RGB ではない）を渡します。Serial はアイテムの画像/type ではありません。文字列は空の場合があります。行の再利用前に値をコピーし、購読後の新しい行だけを配信します。ローカルメッセージも対象です。
- `current / previous` — HitPointsChanged/ManaChanged/StaminaChanged の current、previous は現在と直前の絶対ポイント数を示す Integer です。割合や Boolean ではありません。更新単位で比較するため途中の変化はまとまる場合があります。初期状態やキャラクター変更は新しい基準になり、資源変更イベントは出しません。
- `online` — ConnectionChanged の online は Boolean です。True/1 はクライアントの世界にプレイヤーとマップが存在、False/0 は不在を示します。ソケットの健全性確認ではありません。初期イベントは再送しません。
- `RemoveHandler` — RemoveHandler は一致する最後の登録を削除します。重複登録は登録順に複数回呼ばれます。現在のメッセージには固定した一覧を使い、変更は次のメッセージに反映します。最後のハンドラーを削除するとキューを解放します。

## 戻り値

AddHandler、RemoveHandler、Sub は値を返しません（Unit）。結果は共有 Module フィールドに保存します。online と論理判定だけが 1/0 = True/False を使います。serial、hue、ポイント数、State.changes は ID または数量です。

## 動作

- クライアントは値のコピーをキューに入れるだけです。ハンドラーは所有スクリプトのスレッドで、文の間と Wait、Sleep、UO.Wait、Wait Until の中で実行されます。同時実行しません。確認間隔は最短 25 ms、1 回につき各イベント最大 16 件です。長いネイティブ呼び出しは配信を遅らせます。
- 一時停止中はメッセージを蓄積し実行しません。Stop はキャンセルして購読を解放し、Catch で緊急停止を抑止できません。最上位手続きの終了・エラーでクライアント購読を削除し、次の実行へ持ち越しません。IDE を閉じても実行中のスクリプトは継続します。切断時の自動停止は通知を再開まで遅らせます。
- 各キューの上限は 256 件です。超過は捕捉可能なエラーとなり該当購読を無効化します。ハンドラーのエラーも無効化し、そのメッセージの後続ハンドラーを省略します。Catch/Finally 後に再登録できます。各ジャーナル行を同じジャーナルへ書き戻すことは避けてください。
- この 5 イベントは Basic IDE が有効な Full で利用できます。他のイベント、パケット購読、Handles、WithEvents は含みません。スクリプト宣言イベントは Basic.Events を参照してください。

## 使用例

### 1. 新しい行を判定

```vb
# OnJournal は 4 引数を受け取ります。完全な IsReadyMessage は InStr > 0 で文字列の存在を判定します。ローカルメッセージを State.message に保存し、Wait Until は最大 5000 ms 待ち、超過でエラーになります。Finally で解除します。Main は "ready: ore" を返します。
Option Explicit On
Module State
    Public Dim matched As Boolean = False
    Public Dim message As String = ""
End Module

Function IsReadyMessage(ByVal text As String) As Boolean
    Return InStr(text, "ready: ore") > 0
End Function

Sub OnJournal(ByVal text As String, ByVal serial As Integer, ByVal name As String, ByVal hue As Integer)
    If IsReadyMessage(text) Then
        State.message = text
        State.matched = True
    End If
End Sub

Sub Main()
    AddHandler UO.JournalEntry, AddressOf OnJournal
    Try
        UO.AddToJournal("ready: ore")
        Wait Until State.matched Timeout 5000
    Finally
        RemoveHandler UO.JournalEntry, AddressOf OnJournal
    End Try
    Return State.message
End Sub
```

**パラメーターと実行の説明:**

OnJournal は 4 引数を受け取ります。完全な IsReadyMessage は InStr > 0 で文字列の存在を判定します。ローカルメッセージを State.message に保存し、Wait Until は最大 5000 ms 待ち、超過でエラーになります。Finally で解除します。Main は "ready: ore" を返します。

### 2. 資源を監視

```vb
# 3 ハンドラーが current/previous を完全な Remember に渡します。State.changes は通知数、State.last は SP:58:60 などの文字列です。Wait(250) 後、最大 5000 ms 変化を待ち、なければタイムアウトします。Finally は 3 購読を解除します。戻り値は String で Boolean ではありません。
Option Explicit On
Module State
    Public Dim changes As Integer = 0
    Public Dim last As String = ""
End Module

Sub Remember(ByVal label As String, ByVal current As Integer, ByVal previous As Integer)
    State.changes += 1
    State.last = label & ":" & CStr(current) & ":" & CStr(previous)
End Sub

Sub OnHits(ByVal current As Integer, ByVal previous As Integer)
    Remember("HP", current, previous)
End Sub

Sub OnMana(ByVal current As Integer, ByVal previous As Integer)
    Remember("MP", current, previous)
End Sub

Sub OnStamina(ByVal current As Integer, ByVal previous As Integer)
    Remember("SP", current, previous)
End Sub

Sub Main()
    AddHandler UO.HitPointsChanged, AddressOf OnHits
    AddHandler UO.ManaChanged, AddressOf OnMana
    AddHandler UO.StaminaChanged, AddressOf OnStamina
    Try
        Wait(250)
        Wait Until State.changes > 0 Timeout 5000
    Finally
        RemoveHandler UO.HitPointsChanged, AddressOf OnHits
        RemoveHandler UO.ManaChanged, AddressOf OnMana
        RemoveHandler UO.StaminaChanged, AddressOf OnStamina
    End Try
    Return State.last
End Sub
```

**パラメーターと実行の説明:**

3 ハンドラーが current/previous を完全な Remember に渡します。State.changes は通知数、State.last は SP:58:60 などの文字列です。Wait(250) 後、最大 5000 ms 変化を待ち、なければタイムアウトします。Finally は 3 購読を解除します。戻り値は String で Boolean ではありません。

### 3. 接続を監視

```vb
# OnConnection は Boolean online を受け、Wait(1000) 中の遷移を数えます。Finally で解除し Main は回数を返します。0 は変化なし、1 は 1 回で True ではありません。State.online は最後に受け取った状態で、初期問い合わせではありません。
Option Explicit On
Module State
    Public Dim changes As Integer = 0
    Public Dim online As Boolean = False
End Module

Sub OnConnection(ByVal online As Boolean)
    State.online = online
    State.changes += 1
End Sub

Sub Main()
    AddHandler UO.ConnectionChanged, AddressOf OnConnection
    Try
        Wait(1000)
    Finally
        RemoveHandler UO.ConnectionChanged, AddressOf OnConnection
    End Try
    Return State.changes
End Sub
```

**パラメーターと実行の説明:**

OnConnection は Boolean online を受け、Wait(1000) 中の遷移を数えます。Finally で解除し Main は回数を返します。0 は変化なし、1 は 1 回で True ではありません。State.online は最後に受け取った状態で、初期問い合わせではありません。

<!-- implementation references (not callable script procedures):
Runtime/IScriptEventSource.cs: NativeScriptEvents / ScriptEventHub
Runtime/Interpreter.Events.cs: PumpClientEvents / ReleaseClientEvents
Runtime/Interpreter.Timers.cs: WaitWithTimers
Runtime/EventCatalog.cs: TryResolve / HandlerError
ClassicUO.Client/Game/Managers/YokoScriptEvents.cs: OnScriptJournalEntry / PublishScriptEvents
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/addhandler-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/removehandler-statement
-->
