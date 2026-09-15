# AS

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: de -->

AS legt die Konvertierung einer skalaren Variablen fest. Intern gibt es Integer, Decimal, String, Array, Object und Unit (kein Wert). Boolean verwendet Integer 1/0. Die Typnamen dieses Basic-Dialekts garantieren nicht die Speicherbreiten von VB.NET.

## Genaue Syntax

```text
VAR name AS type [= value]
DIM name AS type [= value]
```

## Parameter

- `name` — Deklarierter Variablenname. Lesen liefert den aktuellen Wert; jede weitere Zuweisung wendet AS erneut an.
- `type` — Integer, Long, Short, Byte: vorzeichenbehaftete 32-Bit-Ganzzahl, -2147483648…2147483647; Short/Byte begrenzen den Bereich nicht weiter. Double, Single, Decimal: binäre 64-Bit-Gleitkommazahl, intern Decimal genannt, keine exakte Dezimalrechnung. String: Text. Boolean, Bool: Integer 1/0. Variant, Object: behalten die übergebene Wertart ohne vorgeschriebene Objektinstanz. Groß-/Kleinschreibung ist unwichtig.
- `value` — Optionaler Startwert: Zahl, Text, Variable oder Funktionsergebnis. AS gehört zur Deklaration; CInt(value), CDbl(value), CStr(value), CBool(value) sind ausdrückliche Konvertierungsausdrücke.

## Rückgabewert

AS liefert keinen Wert. Variablenlesen liefert gespeicherte Art und Wert. Logische Ergebnisse verwenden TRUE=1, FALSE=0. Die Anzahl 2 ist ungleich null, aber 2=TRUE ist falsch; vorhandene Gegenstände mit count<>0 oder CBool(count) prüfen.

## Verhalten

- Ohne Startwert liefert typisiertes VAR 0 für Ganzzahlen/Boolean, Gleitkomma-0 für Double/Single/Decimal und leeren Text für String. Untypisiertes VAR und VAR AS Variant/Object liefern Unit. Skalares DIM ergänzt leeren Text für String, sonst 0. Unit bleibt bei AS-Zuweisung Unit.
- AS Integer schneidet Nachkommastellen zulässiger Zahlen Richtung null ab. CInt/CLng runden, halbe Werte von null weg: 2.6 ergibt 3, mit AS Integer dagegen 2. Ganzzahltext muss vollständig dezimal ganzzahlig oder 0x-hexadezimal sein; "2.6" ist ungültig. Den Bereich vorher prüfen.
- AS Boolean vergleicht den ursprünglichen Wert mit numerischer null: Zahl ungleich null → 1, null → 0. Wörter werden nicht erkannt: sogar Text "false" ergibt 1. CBool konvertiert zuerst numerisch. Zahlen/logische Werte verwenden oder Text ausdrücklich mit dem erwarteten Wort vergleichen.
- AS String verwendet die Textdarstellung der Engine. AS Double/Single/Decimal liest Zahltext mit Dezimalpunkt. Numerisches AS konvertiert Array zu 0, weist aber Object und ungültigen Zahltext mit einem durch TRY/CATCH behandelbaren Fehler zurück. CInt/CLng/CDbl/CSng/CBool sind tolerant: unerkannter Text, Array, Object oder Unit werden zunächst 0. Text mit IsNumeric(value) prüfen, bevor man auf die Konvertierung vertraut.
- Die Deklaration berechnet den Startwert, wendet AS an und speichert Ergebnis und Typnamen. Jede Zuweisung wiederholt dies. Gleitkommawerte sind Näherungen, ohne Garantie exakter dezimaler Geldrechnung. Gültigkeitsbereiche stehen unter VAR / DIM, Bindungsschutz unter CONST.
- Nach As ist auch ein deklarierter Structure-Name erlaubt. VAR und DIM dieses Typs ohne Initialisierer erzeugen die Standardfelder. Nur derselbe deklarierte Strukturtyp ist kompatibel; unterschiedliche Strukturtypen werden nicht konvertiert. Verschachtelte Kopien und Referenzfelder beschreibt Structure / New.

## Beispiele

### 1. Zuweisung und Rundung

```vb
# source=2.6 ist eine Gleitkommazahl. whole AS Integer speichert 2; CInt(source) ergibt 3 in rounded. Main liefert 2*10+3=23 zur gemeinsamen Prüfung.
Option Explicit On
SUB Main()
    VAR source = 2.6
    VAR whole AS Integer = source
    VAR rounded = CInt(source)
    RETURN whole * 10 + rounded
END SUB
```

**Erläuterung der Parameter und Ausführung:**

source=2.6 ist eine Gleitkommazahl. whole AS Integer speichert 2; CInt(source) ergibt 3 in rounded. Main liefert 2*10+3=23 zur gemeinsamen Prüfung.

### 2. Anzahl und Wahrheitswert

```vb
# count=2 ist eine Anzahl. hasItems AS Boolean wird 1. count=TRUE ist falsch, da TRUE genau 1 ist; count<>0 ist wahr. Main liefert hasItems=1: Gegenstände existieren, ihre Anzahl ist damit nicht eins.
Option Explicit On
SUB Main()
    VAR count = 2
    VAR hasItems AS Boolean = count
    IF count = TRUE THEN
        RETURN -1
    END IF
    IF count <> 0 THEN
        RETURN hasItems
    END IF
    RETURN FALSE
END SUB
```

**Erläuterung der Parameter und Ausführung:**

count=2 ist eine Anzahl. hasItems AS Boolean wird 1. count=TRUE ist falsch, da TRUE genau 1 ist; count<>0 ist wahr. Main liefert hasItems=1: Gegenstände existieren, ihre Anzahl ist damit nicht eins.

### 3. Variant behält die Wertart

```vb
# value AS Variant speichert zuerst Integer 7, dann String "ore". text AS String beginnt leer. CStr(12) erzeugt "12"; Textverknüpfung ergibt "ore12", den Rückgabewert von Main. Variant erlaubt den Artwechsel.
Option Explicit On
SUB Main()
    VAR value AS Variant = 7
    value = "ore"
    VAR text AS String
    text = value + CStr(12)
    RETURN text
END SUB
```

**Erläuterung der Parameter und Ausführung:**

value AS Variant speichert zuerst Integer 7, dann String "ore". text AS String beginnt leer. CStr(12) erzeugt "12"; Textverknüpfung ergibt "ore12", den Rückgabewert von Main. Variant erlaubt den Artwechsel.

<!-- implementation references (not callable script procedures):
Runtime/InjectionValueKind.cs
Runtime/SemanticScope.cs: Coerce
Runtime/NumberConversions.cs
Runtime/Interpreter.cs: DefaultValueForType
Runtime/InjectionApi.cs: CInt / CLng / CDbl / CStr / CBool
-->
