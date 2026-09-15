# Sub / Call / Exit Sub / End Sub

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: de -->

Sub fasst Anweisungen in einer benannten Prozedur zusammen, etwa für Gegenstände, Prüfungen oder Abschlussarbeiten. Ein Aufruf läuft synchron im aktuellen Skript und startet kein weiteres Hintergrundskript.

## Genaue Syntax

```text
Sub name(parameters)
    statements
End Sub
name(arguments)
Call name(arguments)
Call name arguments
Call name
Exit Sub
Return
Return expression
```

## Parameter

- `name` — Name ohne Beachtung der Großschreibung. Eigener Code wird ohne UO. aufgerufen; ein Modulmitglied heißt Tools.Work(...). Public/Private regeln den Zugriff: siehe Basic.Module und Basic.Visibility.
- `parameters / arguments` — Parameter stehen in Klammern, Argumente folgen ihrer Reihenfolge. ByRef gilt standardmäßig; ByVal kopiert den Wert, Optional liefert einen ausgelassenen Wert, das letzte ParamArray sammelt zusätzliche Argumente. Die fünf Parameterkapitel erläutern Typen, Arrays, gemeinsame Referenzen und Rückschreiben.
- `statements / End Sub` — Der Rumpf darf leer sein; End Sub ist erforderlich. Jeder Aufruf besitzt eigene lokale Variablen, auch bei Rekursion. Prozeduren stehen auf Datei- oder Modulebene, nicht innerhalb anderer Prozeduren.
- `Call` — Bei name(arguments) ist Call optional. Call name arguments erlaubt Argumente ohne Klammern; Call name ruft eine parameterlose Prozedur auf. Call verwirft einen Rückgabewert. Argumentausdrücke behalten ihre gewöhnliche Bedeutung.
- `Exit Sub / Return` — Exit Sub oder Return ohne Ausdruck beendet diesen Aufruf. Return expression in Sub ist eine Basic-Kompatibilitätserweiterung, die VB.NET-Sub nicht bietet. Exit Function innerhalb von Sub ist ein Ladefehler.

## Rückgabewert

End Sub, Exit Sub und leeres Return liefern Unit, also keinen aussagekräftigen Wert, keinen Erfolgsschalter und keine ID. Ein älteres Basic-Sub kann mit Return expression einen Wert liefern. ByRef kann zusätzlich die Variable des Aufrufers ändern. Für Ergebnisberechnungen ist Function vorzuziehen.

## Verhalten

- Die Vorbereitung normalisiert kompatible Köpfe und Call-Formen, prüft den Block und löst Namen auf. Vor Eintritt werden Argumente ausgewertet und gebunden. Aufrufe verwenden vorbereitete Anweisungen wieder, teilen aber keine lokalen Werte.
- Der Interpreter erzeugt den Aufrufbereich, führt den Rumpf aus und setzt hinter dem Aufruf fort. Normales Ende und Exit Sub führen verlassene Finally-Blöcke vor dem abgeschlossenen Rückschreiben aus. Ausnahmen gehen an den aktiven Fehlerbehandler; ein fehlgeschlagener Aufruf bedeutet keinen Erfolg.
- Pause- und Stoppprüfungen bleiben aktiv. Es entstehen kein neuer Thread, keine automatische Wartezeit und kein Timeout. Rekursion benötigt einen Endfall. Eine Zuweisung an den Namen eines Sub definiert kein Ergebnis: dafür Function verwenden.
- Verschachtelte Skriptprozeduraufrufe sind einschließlich Callbacks und Ereignishandlern auf 32 Rahmen begrenzt. Überschreitung erzeugt einen abfangbaren Skriptfehler; für tiefe Verarbeitung Schleifen verwenden. Rückkehr oder Fehler gibt den Rahmen für spätere Aufrufe frei.

## Beispiele

### 1. Drei Aufrufformen

```vb
# total beginnt bei 4. AddAmount erhält total ByRef; ausgelassenes amount ist 1, ausdrückliche 3 und 2 werden ByVal übergeben. Call mit Klammern, ohne Klammern und der normale Aufruf führen denselben Helfer aus. Main liefert 4+1+3+2=10.
Option Explicit On
Sub AddAmount(ByRef total, Optional ByVal amount=1)
    total += amount
End Sub

Sub Main()
    Dim total=4
    Call AddAmount(total)
    Call AddAmount total, 3
    AddAmount(total, 2)
    Return total
End Sub
```

**Erläuterung der Parameter und Ausführung:**

total beginnt bei 4. AddAmount erhält total ByRef; ausgelassenes amount ist 1, ausdrückliche 3 und 2 werden ByVal übergeben. Call mit Klammern, ohne Klammern und der normale Aufruf führen denselben Helfer aus. Main liefert 4+1+3+2=10.

### 2. Öffentlicher Einstieg und privater Helfer

```vb
# Batches.SumInto erhält total ByRef und sammelt 3,-9,4 in values. For Each ruft AppendAmount auf. Bei -9 verlässt Exit Sub nur den Helfer, sodass die Schleife fortsetzt. Beginnend bei 2 ergibt sich 2+3+4=9. Von außen wird der öffentliche Modulname verwendet.
Option Explicit On
Module Batches
    Private Sub AppendAmount(ByRef total, ByVal value)
        If value < 0 Then
            Exit Sub
        End If
        total += value
    End Sub

    Public Sub SumInto(ByRef total, ParamArray values)
        For Each value In values
            AppendAmount(total, value)
        Next
    End Sub
End Module

Sub Main()
    Dim total=2
    Batches.SumInto(total, 3, -9, 4)
    Return total
End Sub
```

**Erläuterung der Parameter und Ausführung:**

Batches.SumInto erhält total ByRef und sammelt 3,-9,4 in values. For Each ruft AppendAmount auf. Bei -9 verlässt Exit Sub nur den Helfer, sodass die Schleife fortsetzt. Beginnend bei 2 ergibt sich 2+3+4=9. Von außen wird der öffentliche Modulname verwendet.

### 3. Frühes Ende und Abschluss

```vb
# Finish setzt trace=1 und endet; trace=99 entfällt. Finally hängt 2 an, wodurch trace=12 per ByRef zurückkommt. LegacyValue zeigt Return 7 im Basic-Sub. Main liefert 12*10+7=127. Diese Ziffern sind selbst definierte Ablaufwerte, keine Spielcodes.
Option Explicit On
Sub Finish(ByRef trace)
    Try
        trace=1
        Exit Sub
        trace=99
    Finally
        trace=trace*10+2
    End Try
End Sub

Sub LegacyValue()
    Return 7
End Sub

Sub Main()
    Dim trace=0
    Call Finish(trace)
    Return trace*10+LegacyValue()
End Sub
```

**Erläuterung der Parameter und Ausführung:**

Finish setzt trace=1 und endet; trace=99 entfällt. Finally hängt 2 an, wodurch trace=12 per ByRef zurückkommt. LegacyValue zeigt Return 7 im Basic-Sub. Main liefert 12*10+7=127. Diese Ziffern sind selbst definierte Ablaufwerte, keine Spielcodes.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: subrutine / parameters / returnStatement / exitProcedure
Runtime/BasicSyntaxPreprocessor.cs: Normalize / NormalizeArguments
Analysis/ProcedureStructureValidator.cs: VisitSubrutine / VisitExitProcedure / CheckName
Runtime/SubrutineDefinition.cs: IsFunction / ReturnType / ResultName
Runtime/Interpreter.cs: CallSubrutine / FunctionResult / DeferReturn / DefaultValueForType
Runtime/SemanticScope.cs: DefineVar / SetVar
Runtime/ScriptBindings.cs: Builder.VisitSubrutine
ClassicUO.Client/Game/Managers/YokoInjectionManager.cs: DiscoverProcedures / DiscoverScopedProcedures
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/sub-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/call-statement
-->
