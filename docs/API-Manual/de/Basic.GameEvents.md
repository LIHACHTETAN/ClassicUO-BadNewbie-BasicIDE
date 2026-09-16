# AddHandler UO.JournalEntry / client events

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: de -->

AddHandler abonniert neue Journaleinträge, Ressourcenänderungen des Spielers und Verbindungsänderungen. Die UO.-Namen sind Ereignisse, keine aufrufbaren Funktionen. RaiseEvent ist dafür unzulässig.

## Genaue Syntax

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

## Parameter

- `Handler / AddressOf` — AddressOf muss auf eine Sub dieses geladenen Skripts zeigen. Alle Parameter ausdrücklich ByVal mit genau den angegebenen Typen und derselben Reihenfolge deklarieren. Function, Optional, ParamArray und fremde Callbacks werden abgewiesen.
- `text / serial / name / hue` — JournalEntry liefert text String, serial Integer als Quell-ID (0 ohne Quelle), name String und hue Integer als UO-Farbindex, nicht RGB. Serial ist keine Item-Grafik. Text und Name dürfen leer sein. Werte werden vor Wiederverwendung des Journaleintrags kopiert. Nur neue Einträge nach dem Abonnieren, auch lokale Nachrichten, werden geliefert.
- `current / previous` — HitPointsChanged/ManaChanged/StaminaChanged liefern current und previous als absolute Integer-Punkte, weder Prozentwerte noch Boolean. Der Client vergleicht Spielerzustände pro Update; Zwischenänderungen können zusammengefasst werden. Anfangszustand und Charakterwechsel setzen die Vergleichsbasis ohne Ressourcenereignis.
- `online` — ConnectionChanged liefert online Boolean: True/1 bedeutet Spieler und Karte im Client-Weltzustand, False/0 deren Fehlen. Es prüft nicht die Funktionsfähigkeit des Sockets. Kein Anfangsereignis wird nachgeliefert.
- `RemoveHandler` — RemoveHandler entfernt das letzte passende Vorkommen. Doppelte Abonnements laufen mehrfach in Eintragungsreihenfolge. Die aktuelle Nachricht verwendet eine feste Handlerliste; Änderungen gelten für spätere Nachrichten. Der letzte entfernte Handler gibt die Warteschlange frei.

## Rückgabewert

AddHandler/RemoveHandler und Handler-Subs liefern keinen Wert (Unit). Ergebnisse in gemeinsamen Module-Feldern speichern. Nur online und logische Prüfungen verwenden 1/0 = True/False. Serial, hue, Ressourcenpunkte und State.changes sind IDs oder Anzahlen.

## Verhalten

- Der Client stellt Datenkopien in Warteschlangen. Handler laufen ausschließlich im eigenen Skriptthread, zwischen Anweisungen und während Wait, Sleep, UO.Wait und Wait Until. Prüfung frühestens alle 25 ms; höchstens 16 Nachrichten pro Ereignis und Durchlauf. Lange native Aufrufe verzögern die Zustellung.
- Pause sammelt Nachrichten ohne Handleraufrufe. Stop bricht Handler ab und gibt Abonnements frei; Catch verschluckt den Notabbruch nicht. Rückkehr oder Fehler der obersten Prozedur entfernt alle Client-Abonnements. Ein neuer Lauf beginnt ohne sie. IDE-Schließen stoppt laufende Skripte nicht. Automatische Trennungspause verzögert das Ereignis bis zum Fortsetzen.
- Jede Ereigniswarteschlange fasst 256 Nachrichten. Überlauf erzeugt einen abfangbaren Fehler und deaktiviert das Abonnement. Ein Handlerfehler deaktiviert es ebenfalls und überspringt spätere Handler dieser Nachricht. Nach Catch/Finally erneut abonnieren. Nicht jede Journalnachricht ins gleiche Journal zurückschreiben.
- Nur diese fünf Ereignisse sind in Full mit aktivierter Basic IDE verfügbar. Andere Ereignisse, Paketabonnements, Handles und WithEvents sind nicht enthalten. Skripteigene Ereignisse stehen unter Basic.Events.

## Beispiele

### 1. Neue Nachricht erkennen

```vb
# OnJournal empfängt vier Parameter. Die vollständig gezeigte Funktion IsReadyMessage prüft InStr > 0. Die lokale Testnachricht setzt State.message. Wait Until erlaubt 5000 ms, danach folgt ein Timeoutfehler. Finally entfernt das Abonnement. Main liefert "ready: ore".
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

**Erläuterung der Parameter und Ausführung:**

OnJournal empfängt vier Parameter. Die vollständig gezeigte Funktion IsReadyMessage prüft InStr > 0. Die lokale Testnachricht setzt State.message. Wait Until erlaubt 5000 ms, danach folgt ein Timeoutfehler. Finally entfernt das Abonnement. Main liefert "ready: ore".

### 2. Ressourcen beobachten

```vb
# Drei Handler übergeben current/previous an die vollständige Hilfsprozedur Remember. State.changes zählt Ereignisse; State.last enthält beispielsweise SP:58:60. Nach Wait(250) wartet Wait Until bis zu 5000 ms auf eine Änderung, sonst Timeout. Finally entfernt alle drei Abonnements. Das Ergebnis ist String, nicht Boolean.
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

**Erläuterung der Parameter und Ausführung:**

Drei Handler übergeben current/previous an die vollständige Hilfsprozedur Remember. State.changes zählt Ereignisse; State.last enthält beispielsweise SP:58:60. Nach Wait(250) wartet Wait Until bis zu 5000 ms auf eine Änderung, sonst Timeout. Finally entfernt alle drei Abonnements. Das Ergebnis ist String, nicht Boolean.

### 3. Verbindung beobachten

```vb
# OnConnection empfängt Boolean online und zählt Übergänge während Wait(1000). Finally entfernt das Abonnement. Main liefert die Anzahl: 0 ohne Änderung, 1 für einen Übergang; 1 bedeutet hier nicht True. State.online enthält nur den zuletzt empfangenen Zustand.
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

**Erläuterung der Parameter und Ausführung:**

OnConnection empfängt Boolean online und zählt Übergänge während Wait(1000). Finally entfernt das Abonnement. Main liefert die Anzahl: 0 ohne Änderung, 1 für einen Übergang; 1 bedeutet hier nicht True. State.online enthält nur den zuletzt empfangenen Zustand.

<!-- implementation references (not callable script procedures):
Runtime/IScriptEventSource.cs: NativeScriptEvents / ScriptEventHub
Runtime/Interpreter.Events.cs: PumpClientEvents / ReleaseClientEvents
Runtime/Interpreter.Timers.cs: WaitWithTimers
Runtime/EventCatalog.cs: TryResolve / HandlerError
ClassicUO.Client/Game/Managers/YokoScriptEvents.cs: OnScriptJournalEntry / PublishScriptEvents
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/addhandler-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/removehandler-statement
-->
