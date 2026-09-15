# Using / End Using

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: de -->

Using schließt eine native Ressource beim Verlassen des Blocks. Unterstützt wird eine vorhandene Variable oder ein Ausdruck, der eine Ressource liefert.

## Genaue Syntax

```text
Dim resource = MemoryStream()
Using resource
    statements
End Using
Using resourceExpression
    statements
End Using
```

## Parameter

- `resourceExpression` — Wird einmal ausgewertet. File(path), MemoryStream() und CreateTimer(...) sind geeignet; Freigabe eines Timers stoppt ihn endgültig (Basic.Timers). String, Zahl, List und Dictionary verursachen vor dem Block einen Fehler mit Quellzeile. Variablen vorher deklarieren: Deklarationen im Kopf, As New, Kommalisten und eigene Dispose-Methoden sind nicht unterstützt.
- `statements / End Using` — End Using schließt das gespeicherte Objekt. Die Variable bleibt sichtbar, die Ressource ist geschlossen. Mehrere Ressourcen durch verschachtelte Blöcke verwalten. Eine neue Zuweisung ändert nicht das ursprünglich zu schließende Objekt.

## Rückgabewert

Die Anweisung liefert keinen Wert. Return schließt die Ressource vor dem Verlassen der Prozedur. IsClosed ist eine Beispielhilfsfunktion mit 1/True oder 0/False; Main liefert Strings, keine Erfolgsflags.

## Verhalten

- File(path) erzeugt eine Hülle: Create() zum Schreiben oder Open() zum Lesen im Block aufrufen. Dispose ruft Close() auf und leert den Puffer. Nach dem Schließen eines MemoryStream schlägt Length() fehl. Die Beispiele arbeiten nur im Speicher.
- Der Compiler erzeugt einen geschützten Bereich; der Interpreter speichert das Objekt im aktuellen Aufruf. End Using, Return, Exit, Continue und Sprünge nach außen schließen von innen nach außen. Sprünge in den Block werden vor dem Start abgewiesen.
- Fehler schließen Ressourcen vor dem äußeren Catch. Ein fehlgeschlagenes Dispose wird nicht wiederholt; äußere Ressourcen werden trotzdem geschlossen. Not-Stopp überspringt Skript-Catch/Finally, gibt native Ressourcen aber frei; Schließfehler ersetzen den Abbruch nicht. Pause hält Ressourcen bis Fortsetzen oder Stopp. Kein neuer Thread; ein blockierendes Betriebssystem-Close lässt sich nicht erzwingen.
- Try/Catch innerhalb von Using kann einen Fehler bei weiterhin offener Ressource behandeln. Ein unbehandelter Fehler mit On Error Resume Next schließt die Ressource und setzt hinter dem gesamten Block fort. On Error GoTo darf kein Label innerhalb eines Using-Blocks als Ziel haben, da dies einen bereits geschlossenen Bereich erneut betreten würde.
- Nach einem Fehler beim Verlassen von Using startet Resume im äußeren On Error GoTo-Handler den gesamten Block am Kopf neu und wertet den Ressourcenausdruck erneut aus. Resume Next setzt unmittelbar nach End Using fort. Eine Variable mit einem geschlossenen Objekt öffnet es nicht erneut; verwenden Sie für Wiederholungen einen Ausdruck, der eine neue Ressource erzeugt. Bereits ausgeführte Aktionen können sich wiederholen.

## Beispiele

### 1. Speicherstrom schließen

```vb
# stream ist die Ressource; size liest vor dem Schließen Length()=0. IsClosed fängt danach den Fehler ab und liefert True=1; Main liefert "0:1". ByVal kopiert die Referenz. Die Lernfunktion wertet jeden Length-Fehler als geschlossen und gilt nur für diese Ströme.
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

**Erläuterung der Parameter und Ausführung:**

stream ist die Ressource; size liest vor dem Schließen Length()=0. IsClosed fängt danach den Fehler ab und liefert True=1; Main liefert "0:1". ByVal kopiert die Referenz. Die Lernfunktion wertet jeden Length-Fehler als geschlossen und gilt nur für diese Ströme.

### 2. Aus einer Hilfsfunktion zurückkehren

```vb
# ReadLength(stream) berechnet Integer 0. Return schließt den Strom, bevor Main size erhält. Der nächste Length-Aufruf scheitert; closed=True, Ergebnis "0:1". Keine Ressource übergeben, die der Aufrufer offen behalten muss.
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

**Erläuterung der Parameter und Ausführung:**

ReadLength(stream) berechnet Integer 0. Return schließt den Strom, bevor Main size erhält. Der nächste Length-Aufruf scheitert; closed=True, Ergebnis "0:1". Keine Ressource übergeben, die der Aufrufer offen behalten muss.

### 3. Verschachtelte Fehlerbereinigung

```vb
# outer und inner sind getrennte Ströme. Throw "demo" schließt zuerst inner, dann outer. Catch behält den Text; IsClosed liefert zweimal 1. Main liefert "demo:2". Zwei zählt geschlossene Objekte und ist kein Boolean.
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

**Erläuterung der Parameter und Ausführung:**

outer und inner sind getrennte Ströme. Throw "demo" schließt zuerst inner, dann outer. Catch behält den Text; IsClosed liefert zweimal 1. Main liefert "demo:2". Zwei zählt geschlossene Objekte und ist kein Boolean.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: usingStatement / USING / END_USING
Runtime/Instructions/Generator.cs: Generate(UsingStatementContext)
Runtime/Interpreter.cs: TryExecutionScope.DisposeResource / Transfer / DeferReturn / CallSubrutine
Runtime/ObjectTypes/FileObject.cs: Dispose / Close
Runtime/ObjectTypes/MemoryStreamObject.cs: Dispose
Analysis/TryStructureValidator.cs: Regions
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/using-statement
-->
