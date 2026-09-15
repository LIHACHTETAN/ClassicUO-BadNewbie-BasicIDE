# CreateTimer / script timers

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: de -->

CreateTimer erzeugt einen angehaltenen Callback-Timer. Start plant eine Sub im Ausführungsthread dieses Skripts. Diese Projekterweiterung ist unabhängig von Basic Timer(), das vergangene Sekunden liest.

## Genaue Syntax

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

## Parameter

- `milliseconds` — Integer in Millisekunden, 1..2147483647. Zeichenfolgen, Brüche, null und negative Werte sind Fehler. Dieselbe Regel gilt für SetInterval. Interval() liefert das eingestellte Intervall, nicht die Restzeit.
- `handler` — AddressOf einer eindeutig deklarierten Sub ohne Parameter oder eine Callback-Variable/Fabrik dieses Skripts. Function, Optional/ParamArray, Namenszeichenfolgen und fremde Referenzen sind unzulässig. Gemeinsame Daten in Module-Feldern speichern; keine lokale Closure entsteht.
- `repeating` — Optionaler dritter Parameter: True/1 wiederholt, False/0 löst einmal aus. Standard True; benannt repeating:=. Andere Zahlen/Zeichenfolgen sind Fehler. Ein Einmaltimer wird vor dem Handler deaktiviert.
- `timer / Start / Stop / Dispose / SetInterval` — Methoden: Start, Stop, Dispose, Enabled, Interval, SetInterval(milliseconds). Start eines aktiven Timers ändert nichts. Nach Stop ist Start möglich. SetInterval beginnt ein aktives Intervall ab jetzt; angehaltene Timer bleiben angehalten. Dispose ist wiederholbar und endgültig; danach schlagen Start/SetInterval fehl. Using gibt das erfasste Objekt beim Verlassen frei.

## Rückgabewert

CreateTimer liefert Object (ScriptTimer), keine Gegenstands-ID oder Skriptnummer. Start/Stop/Dispose/SetInterval liefern Unit. Enabled liefert Integer 1=True oder 0=False; beide Vergleichsformen funktionieren. Interval liefert Millisekunden, keinen Boolean. Beispiele: String "3:0", "ready:0", "tick failed:0".

## Verhalten

- Monotone Zeit wird zwischen Anweisungen sowie in Basic Wait/Sleep und Wait Until geprüft. Bei aktiven Timern wird Wait in Abschnitte bis 25 ms geteilt. Spiel- oder andere blockierende native Aufrufe müssen erst zurückkehren. Keine Echtzeitgarantie und keine neuen Threads.
- Reihenfolge nach Termin, bei Gleichheit nach Erzeugung; maximal 64 Handler je Prüfpunkt, übrige beim nächsten. Während eines Handlers erfolgt kein erneuter Timer-Eintritt, auch nicht bei Wait. Wiederholung beginnt nach Abschluss; versäumte Intervalle werden übersprungen. Pause hält Aufrufe an; nach Fortsetzen läuft ein überfälliger Timer einmal.
- Ein Fehler deaktiviert den Timer und erreicht Catch/Finally. Stop/SetInterval im Handler werden berücksichtigt. Notstopp wird nicht als normaler Fehler verschluckt. Ende, Fehler oder Stopp des äußersten Skriptaufrufs gibt alle Timer frei; neuer Lauf/Reload benötigt neue. Nur die IDE zu schließen lässt laufende Timer bestehen. Höchstens 1024 nicht freigegebene Timer; Dispose gibt einen Platz frei.
- RunThreePulses und GetHandler sind vollständig gezeigte Beispielhelfer. Intern prüft CreateTimer Argumente/Eigentümer, Start setzt den Termin, Pump ruft die Sub, Fire setzt den Folgetermin nach Abschluss und Release gibt beim Skriptende frei. Kein unabhängiger Dienst bleibt aktiv.

## Beispiele

### 1. Drei Aufrufe und Freigabe

```vb
# RunThreePulses erzeugt 20 ms, standardmäßig repeating=True. CountPulse erhöht State.count und stoppt bei drei. Wait Until prüft Zustand und Timer mit 3000 ms Timeout. Enabled()=0 ergibt "3:0". Using gibt auch beim Return frei.
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

**Erläuterung der Parameter und Ausführung:**

RunThreePulses erzeugt 20 ms, standardmäßig repeating=True. CountPulse erhöht State.count und stoppt bei drei. Wait Until prüft Zustand und Timer mit 3000 ms Timeout. Enabled()=0 ergibt "3:0". Using gibt auch beim Return frei.

### 2. Einmaltimer mit benannten Argumenten

```vb
# GetHandler liefert AddressOf SetReady. Benannte Argumente: 5 ms, callback, repeating=False. SetInterval ändert vor Start auf 10. SetReady speichert "ready"; der Timer ist bereits aus. Main wartet maximal 3000 ms und liefert "ready:0". Alle Helfer sind enthalten.
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

**Erläuterung der Parameter und Ausführung:**

GetHandler liefert AddressOf SetReady. Benannte Argumente: 5 ms, callback, repeating=False. SetInterval ändert vor Start auf 10. SetReady speichert "ready"; der Timer ist bereits aus. Main wartet maximal 3000 ms und liefert "ready:0". Alle Helfer sind enthalten.

### 3. Fehler während Wait

```vb
# FailingPulse wirft "tick failed". Der 5-ms-Timer läuft in Wait(2000), deaktiviert sich bei Fehler und unterbricht das Warten. Catch liest Text und Enabled()=0; Finally gibt frei. "tick failed:0" enthält Nachricht und Zustand. Notstopp bleibt Sache der Laufzeit.
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

**Erläuterung der Parameter und Ausführung:**

FailingPulse wirft "tick failed". Der 5-ms-Timer läuft in Wait(2000), deaktiviert sich bei Fehler und unterbricht das Warten. Catch liest Text und Enabled()=0; Finally gibt frei. "tick failed:0" enthält Nachricht und Zustand. Notstopp bleibt Sache der Laufzeit.


### Interne Funktionen: vom Aufruf zum Ergebnis

RunThreePulses und GetHandler sind vollständig gezeigte Beispielhelfer. Intern prüft CreateTimer Argumente/Eigentümer, Start setzt den Termin, Pump ruft die Sub, Fire setzt den Folgetermin nach Abschluss und Release gibt beim Skriptende frei. Kein unabhängiger Dienst bleibt aktiv.

#### 1. CreateTimer

Integer in Millisekunden, 1..2147483647. Zeichenfolgen, Brüche, null und negative Werte sind Fehler. Dieselbe Regel gilt für SetInterval. Interval() liefert das eingestellte Intervall, nicht die Restzeit.

AddressOf einer eindeutig deklarierten Sub ohne Parameter oder eine Callback-Variable/Fabrik dieses Skripts. Function, Optional/ParamArray, Namenszeichenfolgen und fremde Referenzen sind unzulässig. Gemeinsame Daten in Module-Feldern speichern; keine lokale Closure entsteht.

Optionaler dritter Parameter: True/1 wiederholt, False/0 löst einmal aus. Standard True; benannt repeating:=. Andere Zahlen/Zeichenfolgen sind Fehler. Ein Einmaltimer wird vor dem Handler deaktiviert.

CreateTimer liefert Object (ScriptTimer), keine Gegenstands-ID oder Skriptnummer. Start/Stop/Dispose/SetInterval liefern Unit. Enabled liefert Integer 1=True oder 0=False; beide Vergleichsformen funktionieren. Interval liefert Millisekunden, keinen Boolean. Beispiele: String "3:0", "ready:0", "tick failed:0".

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Timers.cs`; Funktion `CreateTimer`.

#### 2. Start

Methoden: Start, Stop, Dispose, Enabled, Interval, SetInterval(milliseconds). Start eines aktiven Timers ändert nichts. Nach Stop ist Start möglich. SetInterval beginnt ein aktives Intervall ab jetzt; angehaltene Timer bleiben angehalten. Dispose ist wiederholbar und endgültig; danach schlagen Start/SetInterval fehl. Using gibt das erfasste Objekt beim Verlassen frei.

`Due = now + interval; enabled = true;`

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ScriptTimerObject.cs`; Funktion `Start`.

#### 3. WaitWithTimers

Monotone Zeit wird zwischen Anweisungen sowie in Basic Wait/Sleep und Wait Until geprüft. Bei aktiven Timern wird Wait in Abschnitte bis 25 ms geteilt. Spiel- oder andere blockierende native Aufrufe müssen erst zurückkehren. Keine Echtzeitgarantie und keine neuen Threads.

`checkpoint -> Pump -> min(remaining, nextDue, 25 ms) -> Wait`

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Timers.cs`; Funktion `WaitWithTimers`.

#### 4. Pump

Reihenfolge nach Termin, bei Gleichheit nach Erzeugung; maximal 64 Handler je Prüfpunkt, übrige beim nächsten. Während eines Handlers erfolgt kein erneuter Timer-Eintritt, auch nicht bei Wait. Wiederholung beginnt nach Abschluss; versäumte Intervalle werden übersprungen. Pause hält Aufrufe an; nach Fortsetzen läuft ein überfälliger Timer einmal.

`snapshot -> deadline / sequence -> checkpoint -> Fire; limit = 64`

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/ScriptTimerScheduler.cs`; Funktion `Pump`.

#### 5. Fire

Ein Fehler deaktiviert den Timer und erreicht Catch/Finally. Stop/SetInterval im Handler werden berücksichtigt. Notstopp wird nicht als normaler Fehler verschluckt. Ende, Fehler oder Stopp des äußersten Skriptaufrufs gibt alle Timer frei; neuer Lauf/Reload benötigt neue. Nur die IDE zu schließen lässt laufende Timer bestehen. Höchstens 1024 nicht freigegebene Timer; Dispose gibt einen Platz frei.

`callback -> completion -> next Due; error -> disabled -> throw`

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ScriptTimerObject.cs`; Funktion `Fire`.

#### 6. Dispose

Methoden: Start, Stop, Dispose, Enabled, Interval, SetInterval(milliseconds). Start eines aktiven Timers ändert nichts. Nach Stop ist Start möglich. SetInterval beginnt ein aktives Intervall ab jetzt; angehaltene Timer bleiben angehalten. Dispose ist wiederholbar und endgültig; danach schlagen Start/SetInterval fehl. Using gibt das erfasste Objekt beim Verlassen frei.

`Release -> scheduler.Remove -> Changed`

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ScriptTimerObject.cs`; Funktion `Dispose`.

#### 7. Release

Ein Fehler deaktiviert den Timer und erreicht Catch/Finally. Stop/SetInterval im Handler werden berücksichtigt. Notstopp wird nicht als normaler Fehler verschluckt. Ende, Fehler oder Stopp des äußersten Skriptaufrufs gibt alle Timer frei; neuer Lauf/Reload benötigt neue. Nur die IDE zu schließen lässt laufende Timer bestehen. Höchstens 1024 nicht freigegebene Timer; Dispose gibt einen Platz frei.

`timer.Release for each handle -> timers.Clear -> no pending deadline`

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/ScriptTimerScheduler.cs`; Funktion `Release`.

RunThreePulses erzeugt 20 ms, standardmäßig repeating=True. CountPulse erhöht State.count und stoppt bei drei. Wait Until prüft Zustand und Timer mit 3000 ms Timeout. Enabled()=0 ergibt "3:0". Using gibt auch beim Return frei.

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
