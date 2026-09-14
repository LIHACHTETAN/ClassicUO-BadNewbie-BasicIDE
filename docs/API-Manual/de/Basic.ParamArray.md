# ParamArray

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: de -->

Parameter übergeben Daten an SUB/FUNCTION. ByRef schreibt den geänderten Wert zurück; ByVal bewahrt die Variable des Aufrufers. Optional ergänzt ausgelassene Argumente, ParamArray sammelt übrige Argumente. Dies sind Deklarationsmodifizierer, keine aufrufbaren Befehle.

## Genaue Syntax

```text
Function Sum(ParamArray values())
Sum()
Sum(2, 3, 4)
Sum(existingArray)
```

## Parameter

- `name / As type` — name / As type: Parametername und optionale Eingabekonvertierung mit As. Argumente binden nach Position oder name:=value; Modifizierer gehören in die Deklaration. Siehe Basic.NamedArguments.
- `ByRef` — ByRef: beschreibbare Variable oder vorhandenes indiziertes Element. Ohne ByVal schreibt diese Engine ebenfalls zurück, anders als der VB.NET-Standard. Literale, Konstanten und berechnete Ausdrücke sind temporär.
- `ByVal` — ByVal: lokale Wertkopie. Zuweisung an den Parameter ersetzt die Aufrufervariable nicht. Arrays und Objekte teilen weiterhin Referenzen; es erfolgt keine tiefe Kopie.
- `Optional / defaultValue` — Optional / defaultValue: ein ausgelassenes letztes Argument wertet den Ausdruck nach = aus. Einen ausdrücklichen Standardwert angeben; andernfalls erhält der ausgelassene Parameter nicht initialisiertes Unit.
- `ParamArray` — ParamArray values(): letzter Parameter für null oder mehr übrige Werte. Ein einzelnes Array wird direkt verwendet; Skalare werden in ein neues Array gepackt. GetArrayLength liefert die Länge.

## Rückgabewert

Modifizierer geben keinen Wert zurück. RETURN legt das Funktionsergebnis separat fest. ByRef verändert ein Argument, nicht das Ergebnis. SUB ohne RETURN liefert Unit. Beispielzahlen sind Rechenergebnisse, keine TRUE/FALSE-Kennzeichen.

## Verhalten

- Argumente werden einmal von links nach rechts ausgewertet. Indiziertes ByRef erfasst Container und Index/Schlüssel; ein anderes Argument kann die Rückschreibstelle nicht durch Neuzuweisung der Containervariablen umleiten.
- Beim Eintritt entstehen lokale Parameter. Beim Verlassen werden ByRef-Werte nach inneren FINALLY-Blöcken in Parameterreihenfolge zurückgeschrieben, auch bei Fehlern im Rumpf. Zwei Parameter derselben Variablen sind nicht unmittelbar gekoppelt: die letzte Rückschreibung gewinnt.
- ByVal verhindert den Austausch der Aufrufervariablen, aber keine Änderungen im gemeinsamen Array oder Objekt. ReDim erzeugt eine neue lokale Referenz. Unabhängige Daten erfordern eine ausdrückliche Kopie.
- Bei positionalen Aufrufen: Optional-Argumente vom Ende her auslassen; leere Positionen zwischen Kommas sind nicht unterstützt. Standardausdrücke werden bei jeder Auslassung ausgewertet und müssen keine VB.NET-Konstanten sein. Positionale Argumente stehen zuerst, danach ausschließlich benannte. Pflichtparameter dürfen nicht fehlen. Ausgelassene Optional-Parameter einer Skriptprozedur erhalten ihre deklarierten Vorgaben, ausgewertet in Deklarationsreihenfolge nach den übergebenen Ausdrücken. Native Überladungen haben nur registrierte Namen und Anzahlen, keine hinzugefügten Vorgaben.
- ParamArray schreibt gepackte Skalare nicht zurück. Änderungen an einem ausdrücklich übergebenen Array sind beim Aufrufer sichtbar. Weitergabe an ein weiteres ParamArray fügt keine Verschachtelung hinzu.
- ByRef und ByVal ausdrücklich angeben. Diese Regeln gelten für Skriptaufrufe eigener Prozeduren; integrierte Befehle sind separat beschrieben.
- ParamArray kann nicht benannt belegt werden. Bei benannten Aufrufen darf es leer bleiben; seine Werte erfordern rein positionale Aufrufe. Leere Kommapositionen werden nicht unterstützt. Es gilt die Regel positional zuerst, nicht die freiere Mischung neuer VB.NET-Versionen. Keine zusätzlichen Threads oder geänderten Spielverzögerungen.

## Beispiele

### 1. Leere und gefüllte Argumentliste

```vb
# Sum() erhält ein leeres Array und liefert 0. Sum(2,3,4) erhält drei Werte und liefert 9. For Each besucht jeden Wert. Main liefert Integer 9.
Option Explicit On
Function Sum(ParamArray values())
    Var total = 0
    For Each value In values
        total += value
    Next
    Return total
End Function
Sub Main()
    Return Sum() + Sum(2, 3, 4)
End Sub
```

**Erläuterung der Parameter und Ausführung:**

Sum() erhält ein leeres Array und liefert 0. Sum(2,3,4) erhält drei Werte und liefert 9. For Each besucht jeden Wert. Main liefert Integer 9.

### 2. Vorhandenes Array weitergeben

```vb
# values enthält 2 und 5. Forward gibt das Array ohne zusätzliche Hülle an Sum weiter. Sum liefert die Summe Integer 7.
Option Explicit On
Function Sum(ParamArray values())
    Var total = 0
    For Each value In values
        total += value
    Next
    Return total
End Function
Function Forward(ParamArray values())
    Return Sum(values)
End Function
Sub Main()
    Dim values[1]
    values[0] = 2
    values[1] = 5
    Return Forward(values)
End Sub
```

**Erläuterung der Parameter und Ausführung:**

values enthält 2 und 5. Forward gibt das Array ohne zusätzliche Hülle an Sum weiter. Sum liefert die Summe Integer 7.

### 3. Skalare gegenüber vorhandenem Array

```vb
# SetFirst(first,second) ändert ein neues Array; first=2 und second=3 bleiben erhalten. SetFirst(packed) ändert das gemeinsame packed[0] von 4 auf 9. Main liefert 2*100+3*10+9, Integer 239.
Option Explicit On
Sub SetFirst(ParamArray values())
    If GetArrayLength(values) > 0 Then
        values[0] = 9
    End If
End Sub
Sub Main()
    Var first = 2
    Var second = 3
    SetFirst(first, second)
    Dim packed[0]
    packed[0] = 4
    SetFirst(packed)
    Return first * 100 + second * 10 + packed[0]
End Sub
```

**Erläuterung der Parameter und Ausführung:**

SetFirst(first,second) ändert ein neues Array; first=2 und second=3 bleiben erhalten. SetFirst(packed) ändert das gemeinsame packed[0] von 4 auf 9. Main liefert 2*100+3*10+9, Integer 239.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: parameterName / parameterModifier / defaultValue
Runtime/SubrutineDefinition.cs: WritableParameters / RequiredArgumentCount / HasParamArray
Runtime/Interpreter.cs: VisitCall / CreateArgumentWriter / CallSubrutine / EvaluateInitializer
Runtime/IndexedValueSlot.cs: Read / Write
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/modifiers/byref
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/modifiers/byval
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/modifiers/optional
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/modifiers/paramarray
-->
