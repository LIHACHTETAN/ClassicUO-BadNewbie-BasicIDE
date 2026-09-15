# AddressOf / callbacks

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: de -->

AddressOf speichert einen Verweis auf eine Sub oder Function des Skripts, ohne sie aufzurufen. Der Verweis kann als Parameter übergeben, zurückgegeben oder in einer Sammlung gespeichert werden.

## Genaue Syntax

```text
Dim callback = AddressOf ProcedureName
Dim callback As Object = AddressOf Tools.FunctionName
callback(arguments)
callback.Invoke(arguments)
Process(values, AddressOf Predicate)
```

## Parameter

- `ProcedureName` — Name einer deklarierten Prozedur, gegebenenfalls mit Module-Präfix. Genau eine Deklaration muss passen. Unbekannte Namen, fremde Private-Mitglieder und Überladungen werden vor dem Start abgewiesen. Für Basic-Funktionen oder UO-Befehle eine eindeutig benannte Skriptfunktion als Hülle schreiben. Hinter AddressOf stehen keine Aufrufklammern.
- `callback / arguments` — callback ist ein Object. callback(...) und callback.Invoke(...) laufen synchron im Skriptthread. Benannte Argumente verwenden die tatsächlichen Parameternamen. Ein Sammlungselement zuerst einer Variablen zuweisen. Der Verweis wird vor Argumentauswertung erfasst, auch wenn diese callback verändert.
- `ByRef / ByVal / Optional / ParamArray` — ByVal kopiert Wert oder Referenz; ByRef schreibt Änderungen zurück; Optional berechnet fehlende Vorgaben; ParamArray sammelt positionale Werte. Benannte Argumente folgen positionalen; ParamArray-Werte benötigen rein positionale Aufrufe. Falsche Namen oder Anzahl scheitern vor Argumentnebenwirkungen.

## Rückgabewert

AddressOf liefert einen Object-Verweis, keine ID, Speicheradresse, Boolean oder Funktionsantwort. Function-Aufrufe liefern ihren Rückgabewert; Sub ohne Return-Ausdruck liefert keinen Wert (Unit). IsPositive liefert 1/True oder 0/False. Main liefert in Beispiel 1 und 3 String, in Beispiel 2 Integer 15.

## Verhalten

- Der Verweis erfasst keine lokalen Variablen der erzeugenden Funktion: keine Lambda-Funktion oder Closure. Er gehört zum geladenen Skript; ein anderer Interpreter oder ein neu geladenes Skript kann ihn nicht aufrufen. Eine öffentliche Fabrik darf ihren eigenen privaten Helfer gezielt herausgeben.
- Die Vorbereitung prüft Name und Zugriff. Der Interpreter speichert pro AddressOf-Stelle einen unveränderlichen Verweis. Jeder Aufruf liest die aktuelle Variable, prüft die Signatur, wertet Argumente einmal in Quellreihenfolge aus und erzeugt einen normalen Prozedurrahmen. ByRef und Fehlerbehandlung entsprechen direkten Aufrufen.
- Es entsteht kein Thread oder Timer. Pause und Abbruch greifen an normalen Skriptprüfpunkten, auch in Callback-Schleifen. Fehler erreichen Catch/Finally des Aufrufers; Not-Stopp wird nicht durch Catch verschluckt. Blockierende native Aufrufe behalten ihre Abbruchgrenzen.
- Delegate-Typdeklarationen, Lambdas, DLL-Funktionszeiger und Verweise auf Überladungen sind hier nicht unterstützt. AddressOf hat kein UO.-Präfix; Spielbefehle in der Hülle behalten UO.
- Verschachtelte Skriptprozeduraufrufe sind einschließlich Callbacks und Ereignishandlern auf 32 Rahmen begrenzt. Überschreitung erzeugt einen abfangbaren Skriptfehler; für tiefe Verarbeitung Schleifen verwenden. Rückkehr oder Fehler gibt den Rahmen für spätere Aufrufe frei.

## Beispiele

### 1. Mit einem Prädikat filtern

```vb
# values ist die Eingabeliste; predicate verweist auf IsPositive. FilterValues ruft predicate(number) einmal pro Zahl auf. IsPositive akzeptiert nur positive Zahlen: 4 und 7 bleiben. selected.Count()=2 und selected[0]=4; Main liefert "2:4". Beide Helfer sind vollständig gezeigter Skriptcode, keine zusätzlichen API-Befehle.
Option Explicit On
Function IsPositive(ByVal number) As Boolean
    Return number > 0
End Function

Function FilterValues(ByVal values, ByVal predicate)
    Dim result = List()
    For Each number In values
        If predicate(number) Then
            result.Add(number)
        End If
    Next
    Return result
End Function

Sub Main()
    Dim numbers = List()
    numbers.Add(-2)
    numbers.Add(4)
    numbers.Add(7)
    Dim selected = FilterValues(numbers, AddressOf IsPositive)
    Return CStr(selected.Count()) & ":" & CStr(selected[0])
End Sub
```

**Erläuterung der Parameter und Ausführung:**

values ist die Eingabeliste; predicate verweist auf IsPositive. FilterValues ruft predicate(number) einmal pro Zahl auf. IsPositive akzeptiert nur positive Zahlen: 4 und 7 bleiben. selected.Count()=2 und selected[0]=4; Main liefert "2:4". Beide Helfer sind vollständig gezeigter Skriptcode, keine zusätzlichen API-Befehle.

### 2. Variable des Aufrufers ändern

```vb
# AddAmount erhält total ByRef und amount ByVal mit Vorgabe 1. update(total) ändert 10 zu 11; der benannte Invoke-Aufruf mit amount:=4 ändert 11 zu 15. ByRef schreibt in die ursprüngliche Variable. Die Sub liefert keinen Wert; Main liefert Integer 15, kein Boolean.
Option Explicit On
Sub AddAmount(ByRef total As Integer, Optional ByVal amount = 1)
    total += amount
End Sub

Sub Main()
    Dim update = AddressOf AddAmount
    Dim total = 10
    update(total)
    update.Invoke(amount:=4, total:=total)
    Return total
End Sub
```

**Erläuterung der Parameter und Ausführung:**

AddAmount erhält total ByRef und amount ByVal mit Vorgabe 1. update(total) ändert 10 zu 11; der benannte Invoke-Aufruf mit amount:=4 ändert 11 zu 15. ByRef schreibt in die ursprüngliche Variable. Die Sub liefert keinen Wert; Main liefert Integer 15, kein Boolean.

### 3. Privaten Helfer freigeben

```vb
# Rules.Create gibt einen Verweis auf Private CheckedDouble zurück. Direktes AddressOf Rules.CheckedDouble von außen ist verboten. operation(6) liefert 12; operation(-1) wirft "negative" vor der Zuweisung, result bleibt 12. Catch übernimmt den Text, Finally ergänzt ":done". Main liefert "12:negative:done". Schließen der IDE beendet das laufende Skript nicht.
Option Explicit On
Module Rules
    Private Function CheckedDouble(ByVal number) As Integer
        If number < 0 Then
            Throw "negative"
        End If
        Return number * 2
    End Function

    Public Function Create()
        Return AddressOf CheckedDouble
    End Function
End Module

Sub Main()
    Dim operation = Rules.Create()
    Dim result = operation(6)
    Dim message = ""
    Try
        result = operation(-1)
    Catch problem
        message = problem
    Finally
        message = message & ":done"
    End Try
    Return CStr(result) & ":" & message
End Sub
```

**Erläuterung der Parameter und Ausführung:**

Rules.Create gibt einen Verweis auf Private CheckedDouble zurück. Direktes AddressOf Rules.CheckedDouble von außen ist verboten. operation(6) liefert 12; operation(-1) wirft "negative" vor der Zuweisung, result bleibt 12. Catch übernimmt den Text, Finally ergänzt ":done". Main liefert "12:negative:done". Schließen der IDE beendet das laufende Skript nicht.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: addressOf / ADDRESSOF
Runtime/Metadata.cs: TryGetCallbackTarget
Analysis/InvalidSymbolVisitor.cs: VisitAddressOf
Runtime/Interpreter.Callbacks.cs: VisitAddressOf / TryGetCallback / CallCallback
Runtime/Interpreter.cs: CreateArgumentWriter / CallSubrutine
Runtime/NamedArgumentBinding.cs: TryCreate
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/operators/addressof-operator
-->
