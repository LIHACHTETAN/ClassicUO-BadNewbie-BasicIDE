# Function / Return / Exit Function / End Function

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: de -->

Function definiert einen Helfer mit Rückgabewert: Menge, Text oder List/Dictionary-Referenz. Eigene Funktionen benötigen kein UO.; UO.GetType(item) bleibt getrennt von einer selbst definierten Function GetType(value).

## Genaue Syntax

```text
Function name(parameters) As type
    name = expression
End Function
Function name(parameters)
    Return expression
End Function
result = name(arguments)
Exit Function
Return
```

## Parameter

- `name` — Der Name ist zugleich Aufrufname und implizite lokale Ergebnisvariable im eigenen Rumpf, unabhängig von Großschreibung. name liest das Ergebnis, name(arguments) ruft auf, auch rekursiv. Das Ergebnis nicht erneut mit Dim, Var, Const oder als Parameter deklarieren.
- `parameters / arguments` — Positionsargumente folgen den Sub-Regeln: standardmäßig ByRef, außerdem ByVal, Optional und abschließendes ParamArray. Siehe Basic.Parameters und Einzelkapitel. Tools.Calculate(...) ruft eine Modulfunktion mit den Public/Private-Zugriffsregeln auf.
- `As type` — Optionale Typangabe: Integer/Long/Short/Byte verwenden Integer des Motors; Double/Single/Decimal verwenden Double; String speichert Text; Boolean/Bool normalisiert auf 1/0; Object/Variant bewahrt die Wertart. Dies sind nicht alle VB.NET-Zahlenbreiten. Unbekannte Typen sind unzulässig. Ohne As gilt Variant; Namenssuffixe bestimmen hier keinen Rückgabetyp.
- `name = expression` — Speichert das Ergebnis und SETZT mit der nächsten Anweisung FORT. Erneutes Lesen oder Ändern, etwa mit +=, ist möglich. Es handelt sich um die lokale Variable dieses Aufrufs, nicht um einen neuen Aufruf oder globalen Wert.
- `Return / Exit Function / End Function` — Return expression weist das typisierte Ergebnis zu und beginnt den Austritt. Leeres Return, Exit Function und End Function liefern den aktuellen Wert. End Function ist erforderlich; Exit Sub in Function ist ein Ladefehler.

## Rückgabewert

Der aktuelle Wert wird nach den normalen Finally-Blöcken geliefert. Anfangswerte: Integer 0, Double 0.0, Boolean FALSE/0, String leer; ohne Typ sowie bei Variant/Object zunächst Unit ohne aussagekräftigen Wert. List/Dictionary/Object behalten Referenzen. Boolean liefert 1/0 für TRUE/FALSE-Vergleiche; eine Menge oder ID ist nicht automatisch ein Erfolgscode.

## Verhalten

- Die Vorbereitung bewahrt Function, prüft Typ und Austritte, bindet das lokale Ergebnis und erstellt die Anweisungen einmal. Jeder Aufruf erhält Argumente und ein frisches typisiertes Ergebnis. Zuweisungen verwenden die üblichen Regeln typisierter Variablen.
- Return speichert das Ergebnis und durchläuft aktive Finally-Blöcke von innen nach außen. Diese dürfen den Rückgabewert noch ändern. ByRef wird nach erfolgreichem Ende zurückgeschrieben. Unbehandelte Fehler und ungültige Konvertierungen werden weitergegeben, nicht als Erfolg dargestellt.
- Rekursion hat unabhängige Parameter, lokale Werte und Ergebnisse. Factorial(n-1) überschreibt nicht das Ergebnis des Aufrufers. Ein Endfall ist nötig. Kein automatischer Thread, keine Verzögerung oder Zeitgrenze; Pause/Stopp bleiben wirksam.
- Verschachtelte Skriptprozeduraufrufe sind einschließlich Callbacks und Ereignishandlern auf 32 Rahmen begrenzt. Überschreitung erzeugt einen abfangbaren Skriptfehler; für tiefe Verarbeitung Schleifen verwenden. Rückkehr oder Fehler gibt den Rahmen für spätere Aufrufe frei.

## Beispiele

### 1. Zuweisen und fortsetzen

```vb
# TotalPrice erhält count und price ByVal und liefert Integer. Negative Werte liefern sofort -1. Sonst wird count*price gespeichert und anschließend 2 addiert. Die Aufrufe (3,4) und (-1,4) ergeben 14 und -1; Main liefert 14:-1. Der Helfer selbst legt die Bedeutung von -1 fest.
Option Explicit On
Function TotalPrice(ByVal count, ByVal price) As Integer
    If count < 0 OrElse price < 0 Then
        Return -1
    End If
    TotalPrice=count*price
    TotalPrice+=2
End Function

Sub Main()
    Return CStr(TotalPrice(3, 4)) & ":" & CStr(TotalPrice(-1, 4))
End Sub
```

**Erläuterung der Parameter und Ausführung:**

TotalPrice erhält count und price ByVal und liefert Integer. Negative Werte liefern sofort -1. Sonst wird count*price gespeichert und anschließend 2 addiert. Die Aufrufe (3,4) und (-1,4) ergeben 14 und -1; Main liefert 14:-1. Der Helfer selbst legt die Bedeutung von -1 fest.

### 2. Eigenes Ergebnis bei Rekursion

```vb
# Factorial erhält n ByVal und setzt sein Ergebnis auf 1. Bei n<=1 liefert Exit Function diese 1. Sonst verwendet n*Factorial(n-1) einen neuen Aufruf. Für die kleinen nichtnegativen Eingaben gilt 5!+3!=120+6=126. Negative Werte erreichen ebenfalls den Endfall; das Beispiel validiert nicht den gesamten mathematischen Definitionsbereich.
Option Explicit On
Function Factorial(ByVal n) As Integer
    Factorial=1
    If n <= 1 Then
        Exit Function
    End If
    Factorial=n*Factorial(n-1)
End Function

Sub Main()
    Return Factorial(5)+Factorial(3)
End Sub
```

**Erläuterung der Parameter und Ausführung:**

Factorial erhält n ByVal und setzt sein Ergebnis auf 1. Bei n<=1 liefert Exit Function diese 1. Sonst verwendet n*Factorial(n-1) einen neuen Aufruf. Für die kleinen nichtnegativen Eingaben gilt 5!+3!=120+6=126. Negative Werte erreichen ebenfalls den Endfall; das Beispiel validiert nicht den gesamten mathematischen Definitionsbereich.

### 3. Return und zwei Finally-Blöcke

```vb
# Calculate erhält trace ByRef. Return 1 setzt das Ergebnis und beginnt das Ende. Der innere Finally-Block macht aus Ergebnis und trace zunächst 12, der äußere daraus 123. Main erhält beide Werte 123 und liefert 123:123. Finally ändert also den Wert auch nach Return expression; Spielbewegungen werden nicht simuliert.
Option Explicit On
Function Calculate(ByRef trace) As Integer
    Try
        Try
            trace=1
            Return 1
        Finally
            Calculate=Calculate*10+2
            trace=trace*10+2
        End Try
    Finally
        Calculate=Calculate*10+3
        trace=trace*10+3
    End Try
End Function

Sub Main()
    Dim trace=0
    Dim result=Calculate(trace)
    Return CStr(result) & ":" & CStr(trace)
End Sub
```

**Erläuterung der Parameter und Ausführung:**

Calculate erhält trace ByRef. Return 1 setzt das Ergebnis und beginnt das Ende. Der innere Finally-Block macht aus Ergebnis und trace zunächst 12, der äußere daraus 123. Main erhält beide Werte 123 und liefert 123:123. Finally ändert also den Wert auch nach Return expression; Spielbewegungen werden nicht simuliert.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: subrutine / parameters / returnStatement / exitProcedure
Runtime/BasicSyntaxPreprocessor.cs: Normalize / NormalizeArguments
Analysis/ProcedureStructureValidator.cs: VisitSubrutine / VisitExitProcedure / CheckName
Runtime/SubrutineDefinition.cs: IsFunction / ReturnType / ResultName
Runtime/Interpreter.cs: CallSubrutine / FunctionResult / DeferReturn / DefaultValueForType
Runtime/SemanticScope.cs: DefineVar / SetVar
Runtime/ScriptBindings.cs: Builder.VisitSubrutine
ClassicUO.Client/Game/Managers/YokoInjectionManager.cs: DiscoverProcedures / DiscoverScopedProcedures
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/function-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/return-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/exit-statement
-->
