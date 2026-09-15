# =, ==, <>, <, >, <=, >=

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: de -->

Vergleichsoperatoren prüfen zwei Werte und liefern ein logisches Ergebnis für IF, eine Variable oder RETURN in einer Hilfsfunktion.

## Genaue Syntax

```text
left = right
left == right
left <> right
left < right
left > right
left <= right
left >= right
```

## Parameter

- `left` — Linker Wert: Literal, deklarierte Variable, Ausdruck oder Funktionsergebnis.
- `right` — Rechter Wert. Größenvergleiche benötigen Integer oder Decimal; Gleichheit unterstützt auch andere Wertarten.
- `operator` — = und == prüfen im Ausdruck Gleichheit; <> Ungleichheit; < und > strikte Ordnung; <= und >= schließen Gleichheit ein. Eine eigenständige Anweisung name = expression weist einen Wert zu.

## Rückgabewert

Integer 1 (TRUE) bei erfülltem Vergleich, sonst Integer 0 (FALSE). Hier ist result=1 gleichbedeutend mit result=TRUE, result=0 mit result=FALSE. Eine Anzahl oder ID bedeutet etwas anderes: 2 ist ungleich null, aber 2=TRUE ist falsch. Eine von null verschiedene Anzahl mit count<>0 prüfen.

## Verhalten

- Integer und Decimal werden numerisch verglichen: 5=5.0 ist wahr. Text wird nicht umgewandelt: "5"=5 ist falsch. Zeichenketten werden ordinal unter Beachtung der Großschreibung verglichen: "Ore"<>"ore". Größenvergleiche von Text, Arrays, Objekten oder Unit mit <, >, <=, >= schlagen fehl.
- Gleichheit von Arrays und nativen Objekten prüft Identität, nicht Inhalt. Zwei Unit-Werte sind gleich, Unit ist aber nicht die numerische Null. Verschiedene Wertarten sind ungleich außer Integer/Decimal. NaN ist sogar sich selbst ungleich; alle numerischen Größenvergleiche mit NaN sind falsch.
- Arithmetik wird vor Vergleichen ausgewertet. Vergleichsketten laufen von links nach rechts: 1<3<2 bedeutet (1<3)<2 und ist wahr. Einen Bereich als (low<=value) AND (value<=high) prüfen. Klammern verdeutlichen die Gruppierung.
- Binäre Gleitkommarechnungen können runden. Für Näherungswerte Abs(actual-expected)<=tolerance mit passender nichtnegativer Toleranz verwenden. Diese Regel legt das Skript fest; die Operatoren haben keine eingebaute Toleranz.
- = vergleicht denselben deklarierten Typ und die Felder, <> liefert das Gegenteil. Referenzfelder vergleichen Identität. Dies ist eine Engine-Erweiterung, keine allgemeine Aussage über VB.NET-Strukturen. Gespeicherte Hashwerte und bereits geprüfte Paare begrenzen die Arbeit bei gemeinsam genutzten verschachtelten Werten.

## Beispiele

### 1. Inklusiver Bereich und TRUE

```vb
# InRange erhält value=4, low=2, high=5. Beide Vergleiche ergeben 1, AND kombiniert sie zu 1, Main prüft accepted=TRUE und gibt 1 zurück. Hilfsfunktion und Aufruf sind vollständig.
Option Explicit On
FUNCTION InRange(value, low, high)
    RETURN (low <= value) AND (value <= high)
END FUNCTION
SUB Main()
    VAR accepted = InRange(4, 2, 5)
    IF accepted = TRUE THEN
        RETURN 1
    END IF
    RETURN 0
END SUB
```

**Erläuterung der Parameter und Ausführung:**

InRange erhält value=4, low=2, high=5. Beide Vergleiche ergeben 1, AND kombiniert sie zu 1, Main prüft accepted=TRUE und gibt 1 zurück. Hilfsfunktion und Aufruf sind vollständig.

### 2. Text, Zahlen und Großschreibung

```vb
# sameCase vergleicht "Ore" mit "ore" und wird 0. sameKind vergleicht "5" mit Integer 5 und wird 0. converted verwendet ausdrücklich CDbl("5") und wird 1. CStr erzeugt die zurückgegebene Diagnose "0:0:1".
Option Explicit On
SUB Main()
    VAR sameCase = ("Ore" = "ore")
    VAR sameKind = ("5" == 5)
    VAR converted = (CDbl("5") = 5)
    RETURN CStr(sameCase) + ":" + CStr(sameKind) + ":" + CStr(converted)
END SUB
```

**Erläuterung der Parameter und Ausführung:**

sameCase vergleicht "Ore" mit "ore" und wird 0. sameKind vergleicht "5" mit Integer 5 und wird 0. converted verwendet ausdrücklich CDbl("5") und wird 1. CStr erzeugt die zurückgegebene Diagnose "0:0:1".

### 3. Ungefähre Dezimalgleichheit

```vb
# NearlyEqual erhält 0.1+0.2, expected=0.3, tolerance=0.000001. Negative Toleranz wird abgelehnt. Abs ermittelt den Betrag der Differenz; <= akzeptiert die Abweichung innerhalb der Toleranz. Main gibt 1 zurück. Alle Hilfsparameter sind ausdrücklich angegeben.
Option Explicit On
FUNCTION NearlyEqual(actual, expected, tolerance)
    IF tolerance < 0 THEN
        RETURN FALSE
    END IF
    RETURN Abs(actual - expected) <= tolerance
END FUNCTION
SUB Main()
    RETURN NearlyEqual(0.1 + 0.2, 0.3, 0.000001)
END SUB
```

**Erläuterung der Parameter und Ausführung:**

NearlyEqual erhält 0.1+0.2, expected=0.3, tolerance=0.000001. Negative Toleranz wird abgelehnt. Abs ermittelt den Betrag der Differenz; <= akzeptiert die Abweichung innerhalb der Toleranz. Main gibt 1 zurück. Alle Hilfsparameter sind ausdrücklich angegeben.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: logicalOperand / comparativeOperation
Runtime/Interpreter.cs: VisitLogicalOperand
Runtime/InjectionValue.cs: Equals / comparison operators
-->
