# ByVal

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: de -->

Parameter übergeben Daten an SUB/FUNCTION. ByRef schreibt den geänderten Wert zurück; ByVal bewahrt die Variable des Aufrufers. Optional ergänzt ausgelassene Argumente, ParamArray sammelt übrige Argumente. Dies sind Deklarationsmodifizierer, keine aufrufbaren Befehle.

## Genaue Syntax

```text
Sub Change(ByVal value)
Function Increment(ByVal value)
Increment(expression)
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

### 1. Skalar bewahren

```vb
# Change erhält eine Kopie von amount=5. Die lokale Zuweisung 99 verändert die äußere Variable nicht. Main liefert Integer 5.
Option Explicit On
Sub Change(ByVal amount)
    amount = 99
End Sub
Sub Main()
    Var amount = 5
    Change(amount)
    Return amount
End Sub
```

**Erläuterung der Parameter und Ausführung:**

Change erhält eine Kopie von amount=5. Die lokale Zuweisung 99 verändert die äußere Variable nicht. Main liefert Integer 5.

### 2. Gemeinsames Array und lokales ReDim

```vb
# ByVal teilt das Element weiterhin, daher wird es 9. ReDim erzeugt ein anderes lokales Array, nur dort wird 20 gespeichert. Außen bleiben Länge 1 und Wert 9. Main liefert Integer 91.
Option Explicit On
Sub Change(ByVal items)
    items[0] = 9
    ReDim items[1]
    items[0] = 20
End Sub
Sub Main()
    Dim items[0]
    items[0] = 4
    Change(items)
    Return items[0] * 10 + GetArrayLength(items)
End Sub
```

**Erläuterung der Parameter und Ausführung:**

ByVal teilt das Element weiterhin, daher wird es 9. ReDim erzeugt ein anderes lokales Array, nur dort wird 20 gespeichert. Außen bleiben Länge 1 und Wert 9. Main liefert Integer 91.

### 3. Ausdruck und eigenes Ergebnis

```vb
# amount+3 ergibt 7. Increment erhöht den lokalen Wert auf 8 und gibt ihn zurück. Außen bleibt amount=4. Main liefert 4*10+8, Integer 48.
Option Explicit On
Function Increment(ByVal value)
    value += 1
    Return value
End Function
Sub Main()
    Var amount = 4
    Var result = Increment(amount + 3)
    Return amount * 10 + result
End Sub
```

**Erläuterung der Parameter und Ausführung:**

amount+3 ergibt 7. Increment erhöht den lokalen Wert auf 8 und gibt ihn zurück. Außen bleibt amount=4. Main liefert 4*10+8, Integer 48.

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
