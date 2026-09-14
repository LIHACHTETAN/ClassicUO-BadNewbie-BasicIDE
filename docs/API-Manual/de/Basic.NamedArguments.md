# Named arguments / :=

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: de -->

Benannte Argumente ordnen Werte deklarierten Parametern zu, unabhängig von deren Reihenfolge. Unterstützt werden Skriptprozeduren, Funktionen, Module, registrierte Basic/UO-Funktionen und native Objektmethoden.

## Genaue Syntax

```text
FunctionName(parameterName:=expression, otherName:=expression)
FunctionName(positionalExpression, optionalName:=expression)
FunctionName([reservedName]:=expression)
```

## Parameter

- `parameterName / [reservedName]` — Schreiben Sie name:=wert mit dem Namen aus der Deklaration oder Signatur, ohne Beachtung der Großschreibung. Reservierte Namen werden geklammert: [to]:=100. Das ist kein Arrayindex. Unbekannte oder doppelte Namen sind Fehler.
- `expression` — Übergebene Ausdrücke werden genau einmal von links nach rechts ausgewertet und danach den Parameterslots zugeordnet. Typen, Grenzen und ByVal/ByRef gelten unverändert; eine benannte Konstante wird dadurch nicht zu einer beschreibbaren Variablen.
- `positionalExpression / optionalName` — Positionale Argumente stehen zuerst, danach ausschließlich benannte. Pflichtparameter dürfen nicht fehlen. Ausgelassene Optional-Parameter einer Skriptprozedur erhalten ihre deklarierten Vorgaben, ausgewertet in Deklarationsreihenfolge nach den übergebenen Ausdrücken. Native Überladungen haben nur registrierte Namen und Anzahlen, keine hinzugefügten Vorgaben.

## Rückgabewert

:= liefert keinen eigenen Wert. Die aufgerufene Funktion/API behält ihren Rückgabewert; Sub hat kein implizites Ergebnis. Beispiele: Integer 129 sowie Strings "21:12" und "20:10:2", keine Boolean-Erfolgswerte.

## Verhalten

- Vorbereitung meldet SC027 mit Quellposition für falsche Namen, doppelte Belegung, fehlende Pflichtparameter oder Mehrdeutigkeit. Dynamische Objekte werden zur Laufzeit vor Auswertung ihrer Argumente geprüft. Keine passende native Überladung bedeutet keinen Rückfall auf einen parameterlosen Aufruf.
- Unveränderliche Zuordnungen statischer Aufrufstellen werden zwischengespeichert. Auswertung folgt der Quellreihenfolge; Zuweisung und ByRef-Rückschreiben folgen den Parametern. Vorgaben und Debuggerwerte gehören zur gewählten Signatur. Dynamische Empfänger werden pro Aufruf erfasst, nicht vom vorherigen Objekt übernommen.
- ParamArray kann nicht benannt belegt werden. Bei benannten Aufrufen darf es leer bleiben; seine Werte erfordern rein positionale Aufrufe. Leere Kommapositionen werden nicht unterstützt. Es gilt die Regel positional zuerst, nicht die freiere Mischung neuer VB.NET-Versionen. Keine zusätzlichen Threads oder geänderten Spielverzögerungen.

## Beispiele

### 1. Mittleren Optional-Parameter auslassen

```vb
# Encode hat x, y=2, z=3. z:=9 und x:=1 übergeben die äußeren Parameter; y bleibt 2. Ergebnis: 1*100+2*10+9=129. Gleichwertig sind Encode(1,2,9) und Encode(1,z:=9).
Option Explicit On
Function Encode(ByVal x, Optional ByVal y=2, Optional ByVal z=3) As Integer
    Return x*100 + y*10 + z
End Function

Sub Main()
    Dim encoded = Encode(z:=9, x:=1)
    Return encoded
End Sub
```

**Erläuterung der Parameter und Ausführung:**

Encode hat x, y=2, z=3. z:=9 und x:=1 übergeben die äußeren Parameter; y bleibt 2. Ergebnis: 1*100+2*10+9=129. Gleichwertig sind Encode(1,2,9) und Encode(1,z:=9).

### 2. Gezieltes ByRef-Rückschreiben

```vb
# Change hat ByRef left und right. right:=a bindet a=1 an right, left:=b bindet b=2 an left. Nach +10 auf left und +20 auf right werden b=12 und a=21 zurückgeschrieben. Main liefert "21:12". Links von := steht der Parameter, rechts die Variable des Aufrufers.
Option Explicit On
Sub Change(ByRef left, ByRef right)
    left += 10
    right += 20
End Sub

Sub Main()
    Dim a = 1
    Dim b = 2
    Change(right:=a, left:=b)
    Return CStr(a) & ":" & CStr(b)
End Sub
```

**Erläuterung der Parameter und Ausführung:**

Change hat ByRef left und right. right:=a bindet a=1 an right, left:=b bindet b=2 an left. Nach +10 auf left und +20 auf right werden b=12 und a=21 zurückgeschrieben. Main liefert "21:12". Links von := steht der Parameter, rechts die Variable des Aufrufers.

### 3. Native Liste mit benannten Operanden

```vb
# List() erzeugt die Liste. Add(value:=10) hängt 10 ohne Rückgabewert an. Insert(value:=20,index:=0) setzt 20 an Index 0 und verschiebt 10 auf Index 1. Item(index:=...) liefert ein Element, Count() die Anzahl 2. Main liefert "20:10:2". Für UO.Name(...) gelten die registrierten Namen und der jeweilige Rückgabevertrag.
Option Explicit On
Sub Main()
    Dim items = List()
    items.Add(value:=10)
    items.Insert(value:=20, index:=0)
    Dim first = items.Item(index:=0)
    Dim second = items.Item(index:=1)
    Return CStr(first) & ":" & CStr(second) & ":" & CStr(items.Count())
End Sub
```

**Erläuterung der Parameter und Ausführung:**

List() erzeugt die Liste. Add(value:=10) hängt 10 ohne Rückgabewert an. Insert(value:=20,index:=0) setzt 20 an Index 0 und verschiebt 10 auf Index 1. Item(index:=...) liefert ein Element, Count() die Anzahl 2. Main liefert "20:10:2". Für UO.Name(...) gelten die registrierten Namen und der jeweilige Rückgabevertrag.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: argument
Runtime/NamedArgumentBinding.cs: TryCreate / TryCustom
Runtime/Interpreter.NamedArguments.cs: CallNamed
Runtime/Interpreter.cs: CallSubrutine / CreateArgumentWriter
Analysis/NamedArgumentsValidator.cs
https://learn.microsoft.com/en-us/dotnet/visual-basic/programming-guide/language-features/procedures/passing-arguments-by-position-and-by-name
-->
