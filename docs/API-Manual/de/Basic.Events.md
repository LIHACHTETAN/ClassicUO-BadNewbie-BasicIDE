# Event / AddHandler / RemoveHandler / RaiseEvent

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: de -->

Event deklariert ein Skriptereignis. AddHandler verbindet eine Sub, RemoveHandler trennt sie, und RaiseEvent ruft die Handler synchron in Anmeldereihenfolge auf.

## Genaue Syntax

```text
Event Changed(ByVal value As Integer)
Public Event Adjust(ByRef value As Integer)
Private Event Completed()
AddHandler EventName, AddressOf Handler
AddHandler Module.EventName, callback
RemoveHandler EventName, AddressOf Handler
RaiseEvent EventName(arguments)
```

## Parameter

- `EventName / Public / Private` — Ein einfacher Name auf Dateiebene (implizites Skriptmodul) oder in Module, außerhalb von Prozeduren. Standard ist Public; Private benötigt Module. Externe Anmeldung: Module.EventName. Auch ein Public-Ereignis darf nur sein deklarierendes Modul auslösen. Der Name darf keiner Prozedur oder Variablen entsprechen.
- `Handler / callback` — Handler ist eine eindeutig deklarierte Sub, über AddressOf oder eine Callback-Variable/Fabrik dieses geladenen Skripts. Function, Namenszeichenfolgen, fremde Referenzen und Überladungsgruppen sind unzulässig. Anzahl, Typen und ByVal/ByRef müssen genau übereinstimmen. In Handlern ByVal ausdrücklich angeben; normale Prozeduren behalten ihren älteren ByRef-Standard.
- `arguments / ByVal / ByRef` — RaiseEvent benötigt sämtliche Positionsargumente. Optional, ParamArray, Standardwerte, benannte Ereignisargumente und Safe Call werden nicht unterstützt. Ereignisparameter sind standardmäßig ByVal: Skalar oder Referenz werden kopiert, nicht der Objektinhalt. ByRef-Änderungen erreichen folgende Handler und die beschreibbare Variable bzw. das indizierte Element des Aufrufers. Argumente und Indizes werden einmal in Schreibreihenfolge ausgewertet.

## Rückgabewert

Event, AddHandler, RemoveHandler und RaiseEvent liefern keinen Wert (Unit), weder Boolean noch ID oder Teilnehmerzahl. Ergebnisse über ByRef oder gemeinsamen Modulzustand übertragen. Main liefert String "ready", Integer 8 bzw. String "ABAC:handler failed".

## Verhalten

- Anmeldungen gehören einem Interpreter. Andere Skripte und erneutes Laden beginnen ohne sie. Weitere Einsprünge in denselben geladenen Interpreter behalten sie bis zum Entfernen oder Freigeben des Interpreters. Schließen der IDE lässt laufende Skripte samt Anmeldungen bestehen; es erzeugt keinen unabhängigen Ereignisdienst.
- AddHandler hängt an; doppelte Anmeldung ruft dieselbe Sub mehrfach auf. RemoveHandler entfernt ihr letztes Vorkommen, bei fehlendem Treffer passiert nichts. Nach Prüfung von Deklaration, Zugriff und Signatur werden Argumente ausgewertet und die geordnete Handlerliste fixiert. Änderungen während eines Aufrufs gelten beim nächsten RaiseEvent.
- Ein Handlerfehler beendet die aktuelle Folge und erreicht Catch/Finally des Aufrufers. Vorherige ByRef-Änderungen werden zurückgeschrieben. Pause und Notstopp gelten im Handler; Catch verschluckt den Notstopp nicht. Kein neuer Thread entsteht. Blockierende native Aufrufe behalten ihre Abbruchbeschränkungen.
- Grenzen: 4096 Anmeldungen pro Ereignis, 16 verschachtelte RaiseEvent-Aufrufe, 32 Skriptprozedurrahmen. Zyklen/tiefe Rekursion erzeugen einen abfangbaren Skriptfehler statt eines Client-Stacküberlaufs. Für tiefe Verarbeitung Schleifen verwenden. Gemeinsame Skalare in Module-Feldern speichern; ältere Dateiskalare werden weiterhin als Kopien geerbt.
- Dies sind ausdrücklich vom Skript ausgelöste Ereignisse. Keine automatische Anmeldung an Spielpakete oder Journaländerungen. Handles, WithEvents, Custom Event, Ereignisdelegattypen und Klassenereignisse sind hier nicht implementiert. Basic-Schlüsselwörter ohne UO.; Spielbefehle mit UO.

## Beispiele

### 1. Anmelden und abmelden

```vb
# Feed.Message überträgt text As String ByVal. Die vollständig gezeigte Feed.Publish löst es aus, Record ergänzt State.log. handler meldet Record an; "ready" wird gespeichert. RemoveHandler erkennt dieselbe Sub trotz anderer AddressOf-Zeile. "ignored" nach Abmeldung ändert nichts. Main liefert "ready".
Option Explicit On
Module Feed
    Public Event Message(ByVal text As String)
    Public Sub Publish(ByVal text As String)
        RaiseEvent Message(text)
    End Sub
End Module

Module State
    Public Dim log As String = ""
End Module

Sub Record(ByVal text As String)
    State.log = State.log & text
End Sub

Sub Main()
    Dim handler = AddressOf Record
    AddHandler Feed.Message, handler
    Feed.Publish("ready")
    RemoveHandler Feed.Message, AddressOf Record
    Feed.Publish("ignored")
    Return State.log
End Sub
```

**Erläuterung der Parameter und Ausführung:**

Feed.Message überträgt text As String ByVal. Die vollständig gezeigte Feed.Publish löst es aus, Record ergänzt State.log. handler meldet Record an; "ready" wird gespeichert. RemoveHandler erkennt dieselbe Sub trotz anderer AddressOf-Zeile. "ignored" nach Abmeldung ändert nichts. Main liefert "ready".

### 2. Einen Wert durch Handler verändern

```vb
# Adjust und beide Subs verwenden total As Integer ByRef. Increment macht aus 3 eine 4; DoubleValue erhält 4 und macht 8 daraus. RaiseEvent schreibt 8 nach Main zurück. Beide Handler werden entfernt. Integer 8 ist eine Menge, kein True/False; RaiseEvent liefert keinen Wert.
Option Explicit On
Event Adjust(ByRef total As Integer)

Sub Increment(ByRef total As Integer)
    total += 1
End Sub

Sub DoubleValue(ByRef total As Integer)
    total *= 2
End Sub

Sub Main()
    Dim total As Integer = 3
    AddHandler Adjust, AddressOf Increment
    AddHandler Adjust, AddressOf DoubleValue
    RaiseEvent Adjust(total)
    RemoveHandler Adjust, AddressOf Increment
    RemoveHandler Adjust, AddressOf DoubleValue
    Return total
End Sub
```

**Erläuterung der Parameter und Ausführung:**

Adjust und beide Subs verwenden total As Integer ByRef. Increment macht aus 3 eine 4; DoubleValue erhält 4 und macht 8 daraus. RaiseEvent schreibt 8 nach Main zurück. Beide Handler werden entfernt. Integer 8 ist eine Menge, kein True/False; RaiseEvent liefert keinen Wert.

### 3. Fehler behandeln und fortsetzen

```vb
# Ready hat keine Parameter. First ergänzt A, Failing ergänzt B und löst einen Fehler aus; Last entfällt diesmal. Catch speichert die Meldung, Finally entfernt Failing. Der nächste Aufruf ergänzt AC. Main liefert "ABAC:handler failed". Sämtliche Handler und State sind vollständig enthalten.
Option Explicit On
Event Ready()
Module State
    Public Dim log As String = ""
End Module

Sub First()
    State.log = State.log & "A"
End Sub

Sub Failing()
    State.log = State.log & "B"
    Throw "handler failed"
End Sub

Sub Last()
    State.log = State.log & "C"
End Sub

Sub Main()
    Dim message As String = ""
    AddHandler Ready, AddressOf First
    AddHandler Ready, AddressOf Failing
    AddHandler Ready, AddressOf Last
    Try
        RaiseEvent Ready()
    Catch problem
        message = problem
    Finally
        RemoveHandler Ready, AddressOf Failing
    End Try
    RaiseEvent Ready()
    Return State.log & ":" & message
End Sub
```

**Erläuterung der Parameter und Ausführung:**

Ready hat keine Parameter. First ergänzt A, Failing ergänzt B und löst einen Fehler aus; Last entfällt diesmal. Catch speichert die Meldung, Finally entfernt Failing. Der nächste Aufruf ergänzt AC. Main liefert "ABAC:handler failed". Sämtliche Handler und State sind vollständig enthalten.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: eventDeclaration / eventHandler / raiseEvent
Runtime/EventCatalog.cs: Build / TryResolve / HandlerError
Analysis/EventValidator.cs: ValidateHandler / ValidateRaise / ValidateNativeNames
Runtime/Interpreter.Events.cs: VisitEventHandler / VisitRaiseEvent
Runtime/Interpreter.cs: CallSubrutine / ExecuteSubrutine / ByRef copy-back
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/event-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/addhandler-statement
-->
