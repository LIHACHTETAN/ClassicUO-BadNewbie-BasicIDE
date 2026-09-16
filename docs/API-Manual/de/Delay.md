# Async / Await / Delay

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: de -->

Async Function erzeugt eine Skriptaufgabe. Await unterbricht diese Funktion, damit andere bereite Arbeit desselben Skripts weiterläuft. Es entsteht kein neuer Thread; die vollständige VB.NET-Task-Bibliothek ist nicht verfügbar.

## Genaue Syntax

```text
Async Function Work(ByVal value As Integer) As Task(Of Integer)
    Await Delay(100)
    Return value
End Function
Async Function Work() As Task
    Await Delay(100)
End Function
Delay(milliseconds) -> Object (ScriptTask)
Await task
Dim value = Await task
value = Await task
Return Await task
task.IsCompleted() -> Integer (0/1)
task.IsFaulted() -> Integer (0/1)
task.IsCanceled() -> Integer (0/1)
task.Result() -> T / Unit
```

## Parameter

- `milliseconds` — Delay erwartet Integer 0..2147483647 Millisekunden. Null beendet sofort; negative Werte, Brüche und String lösen abfangbare Fehler aus. Die monotone Uhr setzt eine Mindestwartezeit, keine garantierte Ausführungszeit.
- `Async Function / ByVal / Task(Of T)` — As Task liefert keinen Wert, As Task(Of T) einen skalaren Basic-Wert oder Object/Variant. Parameter benötigen explizites ByVal oder ParamArray; Optional und benannte Argumente funktionieren. ByRef und Async Sub/Declare sind unzulässig. Aufgaben erst im Prozedurrumpf nach globalen Initialisierungen und Parameterstandardwerten erzeugen.
- `task / Await` — Aufgaben untypisiert oder As Object speichern. Await akzeptiert eine Aufgabe dieses Laufs: als vollständige Anweisung, gesamte rechte Seite einer einzelnen skalaren Deklaration/Zuweisung oder Return Await. Nicht in Rechenausdrücken, Bedingungen, Feld-/Indexzuweisungen, Catch/Finally oder außerhalb Async Function. Mehrere Funktionen dürfen dieselbe Aufgabe erwarten; zyklische Abhängigkeiten sind Fehler.
- `IsCompleted / IsFaulted / IsCanceled / Result` — IsCompleted ist nach Erfolg, Fehler oder Abbruch 1; IsFaulted bei Fehlern, IsCanceled bei Abbruch. Diese Integer-Prädikate lassen sich mit True/False vergleichen. Result() liefert den gespeicherten Wert; vor Abschluss wirft es einen Fehler, nach Fehlschlag denselben Fehler erneut. Aufgaben früherer Läufe sind ungültig.

## Rückgabewert

Skriptaufrufe von Async Function und Delay liefern Object (ScriptTask), nicht sofort T. Await und Result() liefern T; As Task und Delay enden mit Unit ohne Wert. Startet der Client eine Async Function als Einstieg, wartet er kooperativ auf den endgültigen Wert. Zahlen sind nicht grundsätzlich Boolean.

## Verhalten

- Die Funktion startet sofort bis zum ersten unvollständigen Await. Lokale Werte, Schleifenposition, With-Empfänger und Debuggerrahmen werden gesichert und wiederhergestellt. Bereits fertige Aufgaben unterbrechen nicht. Der Await-Operand wird genau einmal ausgewertet.
- Der Skriptthread prüft Fristen an sicheren Punkten und führt höchstens 64 Fortsetzungen pro Durchlauf aus. Keine zusätzlichen Threads. Synchrones Wait und lange Spiel-/Native-Aufrufe können andere Aufgaben verzögern; in asynchronen Hilfsfunktionen Await Delay verwenden. Grenze: 1024 offene Aufgaben oder unbeobachtete Fehler.
- Pause blockiert Fortsetzungen, nicht die Zeit. Fortsetzen verarbeitet fällige Aufgaben. Stop, Fehler oder Rückkehr der Einstiegsprozedur bricht offene Aufgaben ab und gibt Using-Ressourcen und Iteratoren frei. Notabbruch überspringt Skript-Catch/Finally. Unbeobachtete Aufgabenfehler werden beim Ende des Einstiegs gemeldet. IDE-Schließen allein stoppt kein laufendes Skript.
- Nicht unterstützt: Task.Run/WhenAll, externe .NET-Aufgaben, Async Sub, Await in Catch/Finally und lokale As-Task-Deklarationen. Main darf nicht vor benötigten Aufgaben enden. Async/Await sind reservierte Wörter.

## Beispiele

### 1. Zwei unabhängige Wartezeiten

```vb
# ValueLater erhält value und milliseconds als Werte. Beide Aufrufe starten vor dem Lesen: 22 nach 10 ms, 20 nach 30 ms. Main wartet maximal 5000 ms auf beide und addiert die Integer-Ergebnisse zu 42. Wait Until wirft bei Zeitüberschreitung einen Fehler.
Option Explicit On
Async Function ValueLater(ByVal value As Integer, ByVal milliseconds As Integer) As Task(Of Integer)
    Await Delay(milliseconds)
    Return value
End Function

Sub Main()
    Dim first = ValueLater(20, 30)
    Dim second = ValueLater(22, 10)
    Wait Until first.IsCompleted() AndAlso second.IsCompleted() Timeout 5000
    Return first.Result() + second.Result()
End Sub
```

**Erläuterung der Parameter und Ausführung:**

ValueLater erhält value und milliseconds als Werte. Beide Aufrufe starten vor dem Lesen: 22 nach 10 ms, 20 nach 30 ms. Main wartet maximal 5000 ms auf beide und addiert die Integer-Ergebnisse zu 42. Wait Until wirft bei Zeitüberschreitung einen Fehler.

### 2. Fehler abfangen

```vb
# FailLater liefert keinen Wert und wirft nach 5 ms. ReadFailure empfängt den Fehler bei Await, speichert den Text und setzt die gemeinsame Bereinigungsmarke in Finally. Main wartet höchstens 5000 ms und liefert String "failed:1"; 1 bedeutet True. Catch/Finally enthalten kein Await.
Option Explicit On
Module State
    Public Dim cleaned As Boolean = False
End Module

Async Function FailLater() As Task
    Await Delay(5)
    Throw "failed"
End Function

Async Function ReadFailure() As Task(Of String)
    Dim message As String = ""
    Try
        Await FailLater()
    Catch problem
        message = problem
    Finally
        State.cleaned = True
    End Try
    Return message & ":" & CStr(State.cleaned)
End Function

Sub Main()
    Dim task = ReadFailure()
    Wait Until task.IsCompleted() Timeout 5000
    Return task.Result()
End Sub
```

**Erläuterung der Parameter und Ausführung:**

FailLater liefert keinen Wert und wirft nach 5 ms. ReadFailure empfängt den Fehler bei Await, speichert den Text und setzt die gemeinsame Bereinigungsmarke in Finally. Main wartet höchstens 5000 ms und liefert String "failed:1"; 1 bedeutet True. Catch/Finally enthalten kein Await.

### 3. Schleife und Ergebnisweitergabe

```vb
# IncrementLater(value) wartet 5 ms und liefert value+1. SumLater erwartet nacheinander i=1..3 und behält total und i. ForwardResult reicht 9 mit Return Await weiter. Main liefert Integer 9 als Summe, nicht als Wahrheitswert.
Option Explicit On
Async Function IncrementLater(ByVal value As Integer) As Task(Of Integer)
    Await Delay(5)
    Return value + 1
End Function

Async Function SumLater() As Task(Of Integer)
    Dim total As Integer = 0
    For Var i = 1 To 3
        Dim nextValue = Await IncrementLater(i)
        total += nextValue
    Next
    Return total
End Function

Async Function ForwardResult() As Task(Of Integer)
    Return Await SumLater()
End Function

Sub Main()
    Dim task = ForwardResult()
    Wait Until task.IsCompleted() Timeout 5000
    Return task.Result()
End Sub
```

**Erläuterung der Parameter und Ausführung:**

IncrementLater(value) wartet 5 ms und liefert value+1. SumLater erwartet nacheinander i=1..3 und behält total und i. ForwardResult reicht 9 mit Return Await weiter. Main liefert Integer 9 als Summe, nicht als Wahrheitswert.


### Interne Funktionen: vom Aufruf zum Ergebnis

Die Funktion startet sofort bis zum ersten unvollständigen Await. Lokale Werte, Schleifenposition, With-Empfänger und Debuggerrahmen werden gesichert und wiederhergestellt. Bereits fertige Aufgaben unterbrechen nicht. Der Await-Operand wird genau einmal ausgewertet.

#### 1. Delay

Delay erwartet Integer 0..2147483647 Millisekunden. Null beendet sofort; negative Werte, Brüche und String lösen abfangbare Fehler aus. Die monotone Uhr setzt eine Mindestwartezeit, keine garantierte Ausführungszeit.

due = monotonicNow + milliseconds
return task

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/ScriptAsyncScheduler.cs`; Funktion `Delay`.

#### 2. ResolveAwaitTask

Aufgaben untypisiert oder As Object speichern. Await akzeptiert eine Aufgabe dieses Laufs: als vollständige Anweisung, gesamte rechte Seite einer einzelnen skalaren Deklaration/Zuweisung oder Return Await. Nicht in Rechenausdrücken, Bedingungen, Feld-/Indexzuweisungen, Catch/Finally oder außerhalb Async Function. Mehrere Funktionen dürfen dieselbe Aufgabe erwarten; zyklische Abhängigkeiten sind Fehler.

validate owner and dependency chain
evaluate operand once

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Async.cs`; Funktion `ResolveAwaitTask`.

#### 3. ExecuteSubrutine

Die Funktion startet sofort bis zum ersten unvollständigen Await. Lokale Werte, Schleifenposition, With-Empfänger und Debuggerrahmen werden gesichert und wiederhergestellt. Bereits fertige Aufgaben unterbrechen nicht. Der Await-Operand wird genau einmal ausgewertet.

save locals, With receiver, debugger frame
suspend until task completes
restore saved state

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.cs`; Funktion `ExecuteSubrutine`.

#### 4. Pump

Der Skriptthread prüft Fristen an sicheren Punkten und führt höchstens 64 Fortsetzungen pro Durchlauf aus. Keine zusätzlichen Threads. Synchrones Wait und lange Spiel-/Native-Aufrufe können andere Aufgaben verzögern; in asynchronen Hilfsfunktionen Await Delay verwenden. Grenze: 1024 offene Aufgaben oder unbeobachtete Fehler.

if earliest deadline reached: complete delays
resume at most 64 queued continuations
refresh function results

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/ScriptAsyncScheduler.cs`; Funktion `Pump`.

#### 5. GetResult

IsCompleted ist nach Erfolg, Fehler oder Abbruch 1; IsFaulted bei Fehlern, IsCanceled bei Abbruch. Diese Integer-Prädikate lassen sich mit True/False vergleichen. Result() liefert den gespeicherten Wert; vor Abschluss wirft es einen Fehler, nach Fehlschlag denselben Fehler erneut. Aufgaben früherer Läufe sind ungültig.

if pending: error
if failed: rethrow
return saved value

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ScriptTaskObject.cs`; Funktion `GetResult`.

#### 6. Release

Pause blockiert Fortsetzungen, nicht die Zeit. Fortsetzen verarbeitet fällige Aufgaben. Stop, Fehler oder Rückkehr der Einstiegsprozedur bricht offene Aufgaben ab und gibt Using-Ressourcen und Iteratoren frei. Notabbruch überspringt Skript-Catch/Finally. Unbeobachtete Aufgabenfehler werden beim Ende des Einstiegs gemeldet. IDE-Schließen allein stoppt kein laufendes Skript.

cancel pending tasks
drain cleanup continuations
release resources
report unobserved failure

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/ScriptAsyncScheduler.cs`; Funktion `Release`.

Skriptaufrufe von Async Function und Delay liefern Object (ScriptTask), nicht sofort T. Await und Result() liefern T; As Task und Delay enden mit Unit ohne Wert. Startet der Client eine Async Function als Einstieg, wartet er kooperativ auf den endgültigen Wert. Zahlen sind nicht grundsätzlich Boolean.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: ASYNC / awaitExpression / taskType
Analysis/AsyncValidator.cs: supported statement forms and signatures
Runtime/Interpreter.cs: ExecuteSubrutine / statement suspension / cleanup
Runtime/Interpreter.Async.cs: ResolveAwaitTask / ResumeAsync / WaitForTask
Runtime/ScriptAsyncScheduler.cs: Delay / Track / Pump / Release
Runtime/ObjectTypes/ScriptTaskObject.cs: GetResult / Complete / Awaiter
Runtime/SemanticScope.cs: SuspendCurrent / Resume
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/modifiers/async
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/operators/await-operator
-->
