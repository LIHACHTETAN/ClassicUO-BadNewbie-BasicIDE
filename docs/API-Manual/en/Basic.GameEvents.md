# AddHandler UO.JournalEntry / client events

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: en -->

Subscribe to new journal entries, player resource changes and connection changes with AddHandler. These UO. names are events, not functions; do not call them or use RaiseEvent on them.

## Exact syntax

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

## Parameters

- `Handler / AddressOf` — Use AddressOf a Sub from this loaded script. Declare all handler parameters explicitly ByVal, with the exact types and order in the signatures. Functions, Optional, ParamArray and foreign callbacks are rejected.
- `text / serial / name / hue` — JournalEntry supplies text String, source serial Integer, speaker name String, and hue Integer. Serial is an object ID, not an item graphic; an absent source is 0. Hue is a UO hue index, not RGB. Text/name may be empty. Values are copied before journal entries are recycled. Only new entries after subscription are delivered, including local journal messages.
- `current / previous` — HitPointsChanged/ManaChanged/StaminaChanged supply current and previous absolute point counts as Integer, not percentages or logical values. The client compares player snapshots once per update; intermediate changes within one update can merge. Initial state and a different character establish a baseline without a resource-change notification.
- `online` — ConnectionChanged supplies Boolean online: True/1 means the game world has a player and map; False/0 means it does not. This is the client world state, not proof that a remote socket is healthy. No initial event is replayed.
- `RemoveHandler` — RemoveHandler removes the last matching handler occurrence. Duplicates run repeatedly in subscription order. The current message uses a handler snapshot; subscription changes affect later messages. Removing the last handler releases that event queue.

## Returns

AddHandler and RemoveHandler return Unit (no value). Handlers are Subs with no return. Receive results through shared Module fields. Only online and predicates such as IsReadyMessage are logical 1/0 = True/False; serials, hues, resource points and State.changes are identifiers or quantities.

## Behavior

- Client threads only enqueue copied data; handlers run on their owning script thread, never concurrently with that script. They run at safe statement boundaries and inside Wait, Sleep, UO.Wait and Wait Until. Queues are checked at intervals of at least 25 ms, with at most 16 messages per event per pass. Long native calls can delay delivery.
- Pause queues messages without executing handlers. Stop cancels handlers and frees subscriptions; Catch cannot swallow emergency cancellation. A returned or failed top-level procedure releases all client subscriptions. A later run starts clean. Closing IDE does not stop a still-running script. Automatic pause on disconnect delays its queued event until resumed.
- Each event queue holds 256 messages. Overflow raises a catchable error and disables that event subscription instead of silently losing messages. A handler error also disables that event; later handlers for that message are skipped. Catch/Finally can clean up and subscribe again. Avoid printing every journal message back into the same journal.
- No other game events, packet subscriptions, Handles or WithEvents are implied. All five client events require Full with Basic IDE enabled. Script-declared Event/RaiseEvent remains documented separately in Basic.Events.

## Examples

### 1. Match a new journal message

```vb
# OnJournal receives all four values. IsReadyMessage is fully defined and uses the 1-based InStr result: a value above 0 means the phrase exists. The local demo message triggers the subscription; shared State stores the String. Wait Until allows up to 5000 ms, then throws on timeout. Finally unsubscribes on success or error. Main returns "ready: ore".
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

**Parameter and execution notes:**

OnJournal receives all four values. IsReadyMessage is fully defined and uses the 1-based InStr result: a value above 0 means the phrase exists. The local demo message triggers the subscription; shared State stores the String. Wait Until allows up to 5000 ms, then throws on timeout. Finally unsubscribes on success or error. Main returns "ready: ore".

### 2. Observe resource changes

```vb
# All three two-parameter handlers forward current/previous points to the fully shown Remember helper. State.changes counts notifications; State.last records the last one, for example SP:58:60. Wait(250) yields, then Wait Until allows 5000 ms for a change. No resource change causes a timeout. Finally removes all subscriptions. Main returns a String, not a success Boolean.
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

**Parameter and execution notes:**

All three two-parameter handlers forward current/previous points to the fully shown Remember helper. State.changes counts notifications; State.last records the last one, for example SP:58:60. Wait(250) yields, then Wait Until allows 5000 ms for a change. No resource change causes a timeout. Finally removes all subscriptions. Main returns a String, not a success Boolean.

### 3. Observe connection changes and stop listening

```vb
# OnConnection receives online as Boolean and counts transitions during Wait(1000). Finally unsubscribes. Main returns the count: 0 if nothing changed, 1 for one transition, and so on; 1 here is a count, not True. State.online holds the last received connection state, not an initial query.
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

**Parameter and execution notes:**

OnConnection receives online as Boolean and counts transitions during Wait(1000). Finally unsubscribes. Main returns the count: 0 if nothing changed, 1 for one transition, and so on; 1 here is a count, not True. State.online holds the last received connection state, not an initial query.

<!-- implementation references (not callable script procedures):
Runtime/IScriptEventSource.cs: NativeScriptEvents / ScriptEventHub
Runtime/Interpreter.Events.cs: PumpClientEvents / ReleaseClientEvents
Runtime/Interpreter.Timers.cs: WaitWithTimers
Runtime/EventCatalog.cs: TryResolve / HandlerError
ClassicUO.Client/Game/Managers/YokoScriptEvents.cs: OnScriptJournalEntry / PublishScriptEvents
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/addhandler-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/removehandler-statement
-->
