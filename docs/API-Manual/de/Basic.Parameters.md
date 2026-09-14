# Parameters / ByRef / ByVal / Optional / ParamArray

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: de -->

Parameter übergeben Daten an SUB/FUNCTION. ByRef schreibt den geänderten Wert zurück; ByVal bewahrt die Variable des Aufrufers. Optional ergänzt ausgelassene Argumente, ParamArray sammelt übrige Argumente. Dies sind Deklarationsmodifizierer, keine aufrufbaren Befehle.

## Genaue Syntax

```text
Sub name(ByRef target, ByVal value, Optional ByVal amount = 2, ParamArray rest())
Function name(parameters) As type
name(arguments)
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

### 1. Variable ändern

```vb
# Adjust erhält amount=5 per ByRef und increment=3 per ByVal. amount wird 8 und zurückgeschrieben. Main liefert Integer 8; Adjust hat kein Ergebnis.
Option Explicit On
Sub Adjust(ByRef amount, ByVal increment)
    amount += increment
End Sub
Sub Main()
    Var amount = 5
    Adjust(amount, 3)
    Return amount
End Sub
```

**Erläuterung der Parameter und Ausführung:**

Adjust erhält amount=5 per ByRef und increment=3 per ByVal. amount wird 8 und zurückgeschrieben. Main liefert Integer 8; Adjust hat kein Ergebnis.

### 2. Standardfaktor oder eigener Faktor

```vb
# Scale(3) nutzt factor=2 und liefert 6. Scale(3,4) nutzt 4 und liefert 12. Main liefert 6*100+12, Integer 612.
Option Explicit On
Function Scale(ByVal value, Optional ByVal factor = 2)
    Return value * factor
End Function
Sub Main()
    Return Scale(3) * 100 + Scale(3, 4)
End Sub
```

**Erläuterung der Parameter und Ausführung:**

Scale(3) nutzt factor=2 und liefert 6. Scale(3,4) nutzt 4 und liefert 12. Main liefert 6*100+12, Integer 612.

### 3. Leere und gefüllte Argumentliste

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
