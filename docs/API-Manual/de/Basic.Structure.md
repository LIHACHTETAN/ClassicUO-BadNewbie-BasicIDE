# Structure / New / fields

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: de -->

Structure fasst typisierte Felder wie X, Y und Z zu einem Wert zusammen. Unterstützt werden Datenstrukturen mit Wertkopien; der gesamte VB.NET-Sprachumfang ist damit nicht gemeint.

## Genaue Syntax

```text
[Public | Private] Structure TypeName
    [Public | Dim | VAR] field As FieldType
End Structure
Dim value As TypeName
Dim value = New TypeName()
copy = value
value.field = expression
Sub Change(ByRef value As TypeName)
Function Copy(ByVal value As TypeName) As TypeName
```

## Parameter

- `TypeName / Public / Private` — Eindeutiger einfacher Typname auf Datei- oder Module-Ebene. Standard: Public. Private ist nur innerhalb eines Module erlaubt; außerhalb ist dieser Typname nicht zugänglich. Öffentlicher Modultyp: ModuleName.TypeName. Schlüsselwörter und Feldnamen werden nicht übersetzt.
- `field / FieldType` — Eindeutiger Feldname, As und ein unterstützter skalarer Typ, Enum oder eine andere Structure. Felder sind öffentlich; Public, Dim und VAR sind möglich. Typen: Integer/Long/Short/Byte, Single/Double/Decimal, String, Boolean/Bool, Object/Variant. Ganzzahl-Aliase verwenden vorzeichenbehaftete 32 Bit. Keine zyklischen Strukturfelder.
- `Dim / New` — Dim value As TypeName und New TypeName() erzeugen den Standardwert ohne Skriptaufruf. New verlangt leere Klammern: X/Y/Z werden danach zugewiesen. Dim copy = value übernimmt den Ausdruckswert. Kein UO.-Präfix.
- `value.field / copy` — Punktzugriff liest und schreibt Felder, auch route.Start.X. Schreiben prüft den Feldtyp und ersetzt den umgebenden Wert. copy = value kopiert skalare und verschachtelte Strukturwerte; copy.X verändert value.X nicht. Strukturtypen müssen kompatibel sein.
- `ByVal / ByRef` — ByVal übergibt eine Wertkopie. ByRef kopiert beim Eintritt und schreibt beim Verlassen zum Aufrufer zurück, auch in ein beschreibbares Feldargument. Modifier ausdrücklich angeben; ohne sie gelten die bisherigen Basic-Regeln. Return kann eine Struktur zurückgeben; Function kann As TypeName deklarieren.

## Rückgabewert

Deklaration und Zuweisung liefern Unit. New und entsprechende Funktionen liefern einen Strukturwert, in Laufzeitbeobachtungen als Object mit dem deklarierten Typnamen dargestellt. Koordinaten sind Zahlenwerte, keine Boolean-Flags. = und <> liefern 1/True oder 0/False. Die Beispielergebnisse sind Strings: "1445:1447:1690:0", "10:15:24", "2:4:2:2".

## Verhalten

- Prüfung vor Initialisierern: maximal 256 Strukturtypen, je 1–256 Felder und 32 Verschachtelungsebenen. Doppelte/unbekannte Feldtypen, Zyklen und überschrittene Grenzen erzeugen SC030. Private-Zugriffe werden bei der Namensbindung geprüft.
- Standardfelder: Ganzzahl/Enum 0, Gleitkomma 0, Boolean 0/False, String leer, Object/Variant Unit bis zur Zuweisung. Verschachtelte Felder haben eigene Strukturstandardwerte. Feldinitialisierer in der Deklaration sind nicht unterstützt; Werte danach setzen.
- Object- und Array-Felder behalten Referenzen beim Kopieren. Kopien können denselben List-, Dictionary- oder Array-Inhalt teilen. Skalare und verschachtelte Werte ändern sich unabhängig; Änderungen an einer gemeinsamen Sammlung sind gemeinsam sichtbar. List speichert den Strukturwert zum Zeitpunkt des Hinzufügens.
- = vergleicht denselben deklarierten Typ und die Felder, <> liefert das Gegenteil. Referenzfelder vergleichen Identität. Dies ist eine Engine-Erweiterung, keine allgemeine Aussage über VB.NET-Strukturen. Gespeicherte Hashwerte und bereits geprüfte Paare begrenzen die Arbeit bei gemeinsam genutzten verschachtelten Werten.
- Unterstützt: öffentliche typisierte Datenfelder, Module-Sichtbarkeit, New(), Zuweisung, Parameter und Rückgabe. Keine Strukturmethoden, eigenen Konstruktoren, Feldinitialisierer, Eigenschaften, Vererbung oder privaten Felder. WITH .field und array[index].field werden nicht unterstützt: Element in eine Variable lesen, ändern und zurückschreiben. Deklarationen können in Include-Dateien liegen.

## Beispiele

### 1. Koordinaten und unabhängige Kopie

```vb
# original bekommt X=1445, Y=1690; Z bleibt 0. copy übernimmt den Wert; copy.X += 2 ändert nur die Kopie. New Position() erzeugt empty mit Z=0. Rückgabe: 1445:1447:1690:0. Das Skript speichert Koordinaten und bewegt keinen Charakter.
Option Explicit On
Structure Position
    Public X As Integer
    Public Y As Integer
    Public Z As Integer
End Structure

Sub Main()
    Dim original As Position
    original.X = 1445
    original.Y = 1690
    Dim copy = original
    copy.X += 2
    Dim empty = New Position()
    Return CStr(original.X) & ":" & CStr(copy.X) & ":" & CStr(copy.Y) & ":" & CStr(empty.Z)
End Sub
```

**Erläuterung der Parameter und Ausführung:**

original bekommt X=1445, Y=1690; Z bleibt 0. copy übernimmt den Wert; copy.X += 2 ändert nur die Kopie. New Position() erzeugt empty mit Z=0. Rückgabe: 1445:1447:1690:0. Das Skript speichert Koordinaten und bewegt keinen Charakter.

### 2. Verschachtelte Route, ByVal und ByRef

```vb
# Route enthält Start und Finish vom Typ Position. Shift(point ByVal, dx ByVal) addiert dx zum X der Kopie und gibt Position zurück. point:=route.Start, dx:=5 ergibt shifted.X=15; Start.X bleibt 10. Advance(route ByRef, dx ByVal) addiert 4 zu Finish.X und schreibt Route zurück: 24. Main liefert 10:15:24. Alle Hilfsprozeduren sind enthalten.
Option Explicit On
Structure Position
    Public X As Integer
    Public Y As Integer
End Structure
Structure Route
    Public Start As Position
    Public Finish As Position
End Structure

Function Shift(ByVal point As Position, ByVal dx As Integer) As Position
    point.X += dx
    Return point
End Function

Sub Advance(ByRef route As Route, ByVal dx As Integer)
    route.Finish.X += dx
End Sub

Sub Main()
    Dim route As Route
    route.Start.X = 10
    route.Finish.X = 20
    Dim shifted = Shift(point:=route.Start, dx:=5)
    Advance(route:=route, dx:=4)
    Return CStr(route.Start.X) & ":" & CStr(shifted.X) & ":" & CStr(route.Finish.X)
End Sub
```

**Erläuterung der Parameter und Ausführung:**

Route enthält Start und Finish vom Typ Position. Shift(point ByVal, dx ByVal) addiert dx zum X der Kopie und gibt Position zurück. point:=route.Start, dx:=5 ergibt shifted.X=15; Start.X bleibt 10. Advance(route ByRef, dx ByVal) addiert 4 zu Finish.X und schreibt Route zurück: 24. Main liefert 10:15:24. Alle Hilfsprozeduren sind enthalten.

### 3. Gespeicherter Wert und gemeinsame Sammlung

```vb
# Entry enthält Point als Wert und Items als Object. first.Point.X=2, Items erhält List() mit einem Text. snapshots.Add(first) speichert den Wert. second=first und second.Point.X=4 ändern das gespeicherte 2 nicht. second.Items.Add("ingot") ändert die gemeinsame Liste: first.Items.Count()=2. saved=snapshots[0] ermöglicht den Feldzugriff. Ergebnis: 2:4:2:2.
Option Explicit On
Structure Position
    Public X As Integer
End Structure
Structure Entry
    Public Point As Position
    Public Items As Object
End Structure

Sub Main()
    Dim first As Entry
    first.Point.X = 2
    first.Items = List()
    first.Items.Add("ore")
    Dim snapshots = List()
    snapshots.Add(first)

    Dim second = first
    second.Point.X = 4
    second.Items.Add("ingot")
    Dim saved = snapshots[0]
    Return CStr(first.Point.X) & ":" & CStr(second.Point.X) & ":" & CStr(saved.Point.X) & ":" & CStr(first.Items.Count())
End Sub
```

**Erläuterung der Parameter und Ausführung:**

Entry enthält Point als Wert und Items als Object. first.Point.X=2, Items erhält List() mit einem Text. snapshots.Add(first) speichert den Wert. second=first und second.Point.X=4 ändern das gespeicherte 2 nicht. second.Items.Add("ingot") ändert die gemeinsame Liste: first.Items.Count()=2. saved=snapshots[0] ermöglicht den Feldzugriff. Ergebnis: 2:4:2:2.


### Interne Funktionen: vom Aufruf zum Ergebnis

Structure fasst typisierte Felder wie X, Y und Z zu einem Wert zusammen. Unterstützt werden Datenstrukturen mit Wertkopien; der gesamte VB.NET-Sprachumfang ist damit nicht gemeint.

#### 1. Build / PrepareDefault

Prüfung vor Initialisierern: maximal 256 Strukturtypen, je 1–256 Felder und 32 Verschachtelungsebenen. Doppelte/unbekannte Feldtypen, Zyklen und überschrittene Grenzen erzeugen SC030. Private-Zugriffe werden bei der Namensbindung geprüft.

`declarations -> field types -> visibility -> cycle/depth checks -> immutable defaults`

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/StructureCatalog.cs`; Funktion `Build / PrepareDefault`.

#### 2. VisitNewStructure

Dim value As TypeName und New TypeName() erzeugen den Standardwert ohne Skriptaufruf. New verlangt leere Klammern: X/Y/Z werden danach zugewiesen. Dim copy = value übernimmt den Ausdruckswert. Kein UO.-Präfix.

`resolve TypeName -> prepared default value; no procedure call`

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.cs`; Funktion `VisitNewStructure`.

#### 3. WithField / SetVar

Punktzugriff liest und schreibt Felder, auch route.Start.X. Schreiben prüft den Feldtyp und ersetzt den umgebenden Wert. copy = value kopiert skalare und verschachtelte Strukturwerte; copy.X verändert value.X nicht. Strukturtypen müssen kompatibel sein.

`resolve path -> coerce field -> replace path -> assign new root value`

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/StructureObject.cs`; Funktion `WithField / SetVar`.

#### 4. CreateArgumentWriter

ByVal übergibt eine Wertkopie. ByRef kopiert beim Eintritt und schreibt beim Verlassen zum Aufrufer zurück, auch in ein beschreibbares Feldargument. Modifier ausdrücklich angeben; ohne sie gelten die bisherigen Basic-Regeln. Return kann eine Struktur zurückgeben; Function kann As TypeName deklarieren.

`ByVal: value copy; ByRef: value copy -> callee -> caller slot write-back`

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.cs`; Funktion `CreateArgumentWriter`.

#### 5. ValueEquals

= vergleicht denselben deklarierten Typ und die Felder, <> liefert das Gegenteil. Referenzfelder vergleichen Identität. Dies ist eine Engine-Erweiterung, keine allgemeine Aussage über VB.NET-Strukturen. Gespeicherte Hashwerte und bereits geprüfte Paare begrenzen die Arbeit bei gemeinsam genutzten verschachtelten Werten.

`type identity -> cached hash -> distinct field pairs; reference members keep identity`

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/StructureObject.cs`; Funktion `ValueEquals`.

Deklaration und Zuweisung liefern Unit. New und entsprechende Funktionen liefern einen Strukturwert, in Laufzeitbeobachtungen als Object mit dem deklarierten Typnamen dargestellt. Koordinaten sind Zahlenwerte, keine Boolean-Flags. = und <> liefern 1/True oder 0/False. Die Beispielergebnisse sind Strings: "1445:1447:1690:0", "10:15:24", "2:4:2:2".

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: structureDeclaration / structureField / newStructure
Runtime/StructureCatalog.cs: Build / PrepareDefault
Runtime/ObjectTypes/StructureObject.cs: ReadField / WithField / ValueEquals
Runtime/BasicSyntaxPreprocessor.cs: NormalizeDim
Runtime/InjectionRuntime.cs: ScriptDeclarations / Load
Runtime/ScriptBindings.cs: Variable / CheckStructureType / CallName
Runtime/SemanticScope.cs: TryStructureRoot / SetVar / Coerce
Runtime/Interpreter.cs: VisitNewStructure / CreateArgumentWriter
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/structure-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/programming-guide/language-features/data-types/structure-variables
-->
