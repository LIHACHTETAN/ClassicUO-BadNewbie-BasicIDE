# Class / New / Me / Property

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: de -->

Class bündelt Zustand und Skriptmethoden eines Objekts. New erzeugt ein Referenzobjekt; eine Zuweisung teilt dieses Objekt, während Structure einen Wert kopiert. Alle verwendeten Konstruktoren, Methoden und Eigenschaftsblöcke stehen vollständig in den Beispielen.

## Genaue Syntax

```text
[Public | Private] Class TypeName
    [Public | Private | Dim] field As FieldType
    Public Sub New([parameters]) ... End Sub
    [Public | Private] Sub Method([parameters]) ... End Sub
    [Public | Private] Function Method([parameters]) As ResultType ... End Function
    [Public | Private] [ReadOnly | WriteOnly] Property Name[()] As ValueType
        Get ... Return value / Name = value / Exit Property ... End Get
        Set(ByVal value As ValueType) ... End Set
    End Property
    Public Property AutoName As ValueType
End Class
Dim instance [As TypeName] = New TypeName(arguments)
instance.Property = expression
value = instance.Property
instance.Method(arguments)
With instance ... End With
```

## Parameter

- `TypeName / Public / Private` — TypeName ist ein eindeutiger einfacher Name auf Datei- oder Module-Ebene; außerhalb des Moduls gilt ModuleName.TypeName. Class ist standardmäßig Public, Private Class nur im eigenen Module sichtbar. Vererbung, Interfaces, Generics, verschachtelte Klassen, Shared, Überladungen, Destruktoren und instanzbezogene Event-Deklarationen sind nicht implementiert.
- `field As FieldType / Me` — Felder benötigen As Integer, Double, Boolean, String, Object oder einen deklarierten Enum-, Structure- oder Class-Typ; vorhandene Basic-Typaliase gelten ebenfalls. Standardzugriff ist Private, äußerer Zugriff erfordert Public. Anfangswerte: Zahlen/Boolean 0, String leer, Structure Nullfelder, Object/Class Nothing (Unit). Andere Werte setzt Sub New. Me bezeichnet die aktuelle Instanz und darf nicht neu deklariert/zugewiesen werden; lokale Namen können andere Mitglieder verdecken.
- `New / Sub New` — New TypeName(arguments) reserviert eigene Felder und ruft Public Sub New einmal auf. Ohne Konstruktor ist nur New TypeName() erlaubt. Es gibt einen Konstruktor; Optional, Vorgabewerte und benannte Argumente folgen den normalen Regeln. Argumente werden einmal in Schreibreihenfolge ausgewertet; bei Fehler wird kein fertiges Objekt zurückgegeben. As TypeName allein bleibt Nothing.
- `Sub / Function / arguments` — Sub/Function werden über instance.Method(...) aufgerufen; innerhalb der Klasse auch Method(...) oder Me.Method(...). Private gilt nur innerhalb derselben Class, auch für andere Instanzen dieses Typs. Typen, ByVal/ByRef, Optional, ParamArray und benannte Argumente funktionieren; benannte ParamArray-Elemente nicht. Function liefert den deklarierten Typ, Sub Unit. TypeName.Method(...) und instance.New(...) sind ungültig; AddressOf benötigt für Instanzmethoden einen Datei-/Modul-Wrapper.
- `Property / Get / Set` — Property Name[()] As ValueType hat keine Indexparameter. Lesen erfolgt als instance.Name ohne Aufrufklammern. Get liefert Return oder den Wert einer Zuweisung an Name; Exit Property liefert diesen Wert/Standardwert. Zuweisen ruft Set(ByVal value As ValueType) auf, ohne den letzten Getter zu lesen. Eine normale Eigenschaft braucht je einen Get- und Set-Block. Zugriff auf Property deklarieren; Set braucht genau einen ausdrücklich als ByVal deklarierten Parameter desselben Typs.
- `ReadOnly / WriteOnly / auto Property` — ReadOnly mit Körper besitzt nur Get, WriteOnly nur Set; unzulässiger Zugriff erzeugt einen abfangbaren Fehler. Eine automatische Eigenschaft hat weder Get/Set noch End Property und speichert direkt. ReadOnly-Autoeigenschaften sind nur im eigenen Sub New beschreibbar; WriteOnly ohne Set ist ungültig. Ein ReadOnly-Ergebnis vom Typ Class kann dennoch veränderliche Mitglieder besitzen.
- `ByVal / ByRef / With` — ByVal kopiert die Referenz: Mitgliederänderungen betreffen das Original, eine Parameterersetzung nicht die Variable des Aufrufers. ByRef schreibt nach den Copy-in/Copy-out-Regeln auch Ersatzreferenzen zurück. Gleichheit prüft Objektidentität. With instance hält das Objekt einmal fest und unterstützt Felder, Eigenschaften und Methoden. Class implementiert nicht automatisch IDisposable; Using gilt für die unterstützten Ressourcenobjekte.

## Rückgabewert

New liefert Object mit Class-Referenz, keine UO-ID/Grafik. Get und Function liefern ihren Typ; Set, Sub und Deklarationen Unit. Ohne New ist die Variable Nothing. Referenzgleichheit und As Boolean verwenden 1/True bzw. 0/False; Integer-Mengen sind keine automatischen Erfolgsflags. Main liefert "5:2:1", "1:0:6", "ore:1:replacement:0".

## Verhalten

- SC032 weist ungültige Deklarationen vor Ausführung zurück, auch ohne Option Explicit. Grenzen: 256 Klassen, je 256 Felder/Eigenschaften und Methoden, 32 verschachtelte Skriptaufrufe einschließlich New/Get/Set. Zuweisungs-/ByRef-Pfade: 64 Komponenten. Referenzzyklen sind erlaubt; Metadaten/Standardwerte sind vorbereitet, veränderliche Speicherplätze pro New getrennt.
- Empfängerpfade werden vor rechter Seite/Argumenten erfasst; jeder Getter im Pfad läuft einmal. Rückschreiben bleibt beim ursprünglichen Ziel, auch nach Variablenersetzung im Unterprogramm. Werte werden typgerecht konvertiert. Try/Catch fängt Fehler aus Methoden, Eigenschaften und Konstruktoren; bereits ausgeführte Änderungen werden nicht rückgängig gemacht.
- Pause, Stopp, Quellzeilen und Tiefenschutz verwenden normale Skriptframes. Schließen der IDE stoppt das Skript nicht. Der Inspektor zeigt Typ/Mitgliederzahl ohne Getter oder Zyklusverfolgung. Watch darf gespeicherte Felder/Autoeigenschaften lesen, aber keine eigenen Getter, Methoden oder Konstruktoren ausführen. Dies ist der beschriebene Basic-Umfang, kein beliebiges .NET.

## Beispiele

### 1. Getrennte Objekte und geteilte Referenz

```vb
# New Counter(label:="ore", start:=2) übergibt String label und Integer start; New setzt Label/stored. second besitzt eigene Felder, alias=first teilt die Referenz. Add(amount:=3) schreibt über Value.Set mit Negativprüfung und liefert Integer aus Value.Get. first wird 5, second bleibt 2; alias=first ist 1/True. Alle Hilfsmethoden stehen im Skript.
Option Explicit On
Class Counter
    Private stored As Integer
    Public Property Label As String
    Public Sub New(ByVal label As String, ByVal start As Integer)
        Me.Label = label
        stored = start
    End Sub
    Public Property Value As Integer
        Get
            Return stored
        End Get
        Set(ByVal value As Integer)
            If value < 0 Then
                Throw "Value must be non-negative"
            End If
            stored = value
        End Set
    End Property
    Public Function Add(ByVal amount As Integer) As Integer
        Me.Value = stored + amount
        Return Me.Value
    End Function
End Class

Sub Main()
    Dim first = New Counter(label:="ore", start:=2)
    Dim second = New Counter("wood", 2)
    Dim alias = first
    alias.Add(amount:=3)
    Return CStr(first.Value) & ":" & CStr(second.Value) & ":" & CStr(alias = first)
End Sub
```

**Erläuterung der Parameter und Ausführung:**

New Counter(label:="ore", start:=2) übergibt String label und Integer start; New setzt Label/stored. second besitzt eigene Felder, alias=first teilt die Referenz. Add(amount:=3) schreibt über Value.Set mit Negativprüfung und liefert Integer aus Value.Get. first wird 5, second bleibt 2; alias=first ist 1/True. Alle Hilfsmethoden stehen im Skript.

### 2. Lese-/Schreibzugriff und Boolean

```vb
# Limit=10 ruft Set mit value=10 auf. Remaining.Get weist den Ergebnisnamen zu und verlässt ihn per Exit Property. TrySpend(cost:=4) zieht vier ab und liefert 1/True; cost=9 übersteigt die übrigen sechs und liefert 0/False. Limit=-3 wirft vor der Speicherung; Catch liest Remaining=6. Main ergibt "1:0:6", ohne Serveraktion.
Option Explicit On
Class Budget
    Private amount As Integer
    Public ReadOnly Property Remaining() As Integer
        Get
            Remaining = amount
            Exit Property
        End Get
    End Property
    Public WriteOnly Property Limit As Integer
        Set(ByVal value As Integer)
            If value < 0 Then
                Throw "Limit must be non-negative"
            End If
            amount = value
        End Set
    End Property
    Public Function TrySpend(ByVal cost As Integer) As Boolean
        If cost < 0 Then
            Throw "cost must be non-negative"
        End If
        If cost > amount Then
            Return False
        End If
        amount -= cost
        Return True
    End Function
End Class

Sub Main()
    Dim budget = New Budget()
    budget.Limit = 10
    Dim paid = budget.TrySpend(4)
    Dim refused = budget.TrySpend(9)
    Try
        budget.Limit = -3
    Catch problem
        Return CStr(paid) & ":" & CStr(refused) & ":" & CStr(budget.Remaining)
    End Try
    Return "unexpected"
End Sub
```

**Erläuterung der Parameter und Ausführung:**

Limit=10 ruft Set mit value=10 auf. Remaining.Get weist den Ergebnisnamen zu und verlässt ihn per Exit Property. TrySpend(cost:=4) zieht vier ab und liefert 1/True; cost=9 übersteigt die übrigen sechs und liefert 0/False. Limit=-3 wirft vor der Speicherung; Catch liest Remaining=6. Main ergibt "1:0:6", ohne Serveraktion.

### 3. Module, ByVal und ByRef

```vb
# Jobs.WorkItem(name) speichert String Name, Done startet bei null. Tick(ByVal job) erhöht das gemeinsame Done auf 1; die folgende Ersetzung durch "local" bleibt lokal. Replace(ByRef job, ByVal name) erstellt "replacement" und schreibt die Referenz zurück; die benannten Argumente stehen absichtlich umgekehrt. original bleibt "ore"/1, job wird "replacement"/0. Der gesamte Module-Code ist enthalten.
Option Explicit On
Module Jobs
    Public Class WorkItem
        Public Property Name As String
        Public Done As Integer
        Public Sub New(ByVal name As String)
            Me.Name = name
        End Sub
    End Class
    Public Sub Tick(ByVal job As WorkItem)
        job.Done += 1
        job = New WorkItem("local")
    End Sub
    Public Sub Replace(ByRef job As WorkItem, ByVal name As String)
        job = New WorkItem(name)
    End Sub
End Module

Sub Main()
    Dim job As Jobs.WorkItem = New Jobs.WorkItem("ore")
    Dim original = job
    Jobs.Tick(job)
    Jobs.Replace(name:="replacement", job:=job)
    Return original.Name & ":" & CStr(original.Done) & ":" & job.Name & ":" & CStr(job.Done)
End Sub
```

**Erläuterung der Parameter und Ausführung:**

Jobs.WorkItem(name) speichert String Name, Done startet bei null. Tick(ByVal job) erhöht das gemeinsame Done auf 1; die folgende Ersetzung durch "local" bleibt lokal. Replace(ByRef job, ByVal name) erstellt "replacement" und schreibt die Referenz zurück; die benannten Argumente stehen absichtlich umgekehrt. original bleibt "ore"/1, job wird "replacement"/0. Der gesamte Module-Code ist enthalten.


### Interne Funktionen: vom Aufruf zum Ergebnis

Class bündelt Zustand und Skriptmethoden eines Objekts. New erzeugt ein Referenzobjekt; eine Zuweisung teilt dieses Objekt, während Structure einen Wert kopiert. Alle verwendeten Konstruktoren, Methoden und Eigenschaftsblöcke stehen vollständig in den Beispielen.

#### 1. ClassCatalog.Build / Complete

SC032 weist ungültige Deklarationen vor Ausführung zurück, auch ohne Option Explicit. Grenzen: 256 Klassen, je 256 Felder/Eigenschaften und Methoden, 32 verschachtelte Skriptaufrufe einschließlich New/Get/Set. Zuweisungs-/ByRef-Pfade: 64 Komponenten. Referenzzyklen sind erlaubt; Metadaten/Standardwerte sind vorbereitet, veränderliche Speicherplätze pro New getrennt.

`declarations -> unique typed members -> accessor validation -> prepared metadata; SC032 on invalid Class`

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/ClassCatalog.cs`; Funktion `ClassCatalog.Build / Complete`.

#### 2. ConstructClass

New TypeName(arguments) reserviert eigene Felder und ruft Public Sub New einmal auf. Ohne Konstruktor ist nur New TypeName() erlaubt. Es gibt einen Konstruktor; Optional, Vorgabewerte und benannte Argumente folgen den normalen Regeln. Argumente werden einmal in Schreibreihenfolge ausgewertet; bei Fehler wird kein fertiges Objekt zurückgegeben. As TypeName allein bleibt Nothing.

`new instance -> independent field slots -> bind constructor arguments -> Sub New -> Object reference`

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Classes.cs`; Funktion `ConstructClass`.

#### 3. ClassObject.Member / Read

Property Name[()] As ValueType hat keine Indexparameter. Lesen erfolgt als instance.Name ohne Aufrufklammern. Get liefert Return oder den Wert einer Zuweisung an Name; Exit Property liefert diesen Wert/Standardwert. Zuweisen ruft Set(ByVal value As ValueType) auf, ohne den letzten Getter zu lesen. Eine normale Eigenschaft braucht je einen Get- und Set-Block. Zugriff auf Property deklarieren; Set braucht genau einen ausdrücklich als ByVal deklarierten Parameter desselben Typs.

`check member visibility -> stored value OR Get frame -> declared value type`

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ClassObject.cs`; Funktion `ClassObject.Member / Read`.

#### 4. MemberAccess.Resolve / ClassObject.Write

Empfängerpfade werden vor rechter Seite/Argumenten erfasst; jeder Getter im Pfad läuft einmal. Rückschreiben bleibt beim ursprünglichen Ziel, auch nach Variablenersetzung im Unterprogramm. Werte werden typgerecht konvertiert. Try/Catch fängt Fehler aus Methoden, Eigenschaften und Konstruktoren; bereits ausgeführte Änderungen werden nicht rückgängig gemacht.

`capture receiver once -> evaluate RHS/arguments -> coerce value -> Set OR stored slot`

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/MemberAccess.cs`; Funktion `MemberAccess.Resolve / ClassObject.Write`.

#### 5. CallClassMethod / CallSubrutine

Sub/Function werden über instance.Method(...) aufgerufen; innerhalb der Klasse auch Method(...) oder Me.Method(...). Private gilt nur innerhalb derselben Class, auch für andere Instanzen dieses Typs. Typen, ByVal/ByRef, Optional, ParamArray und benannte Argumente funktionieren; benannte ParamArray-Elemente nicht. Function liefert den deklarierten Typ, Sub Unit. TypeName.Method(...) und instance.New(...) sind ungültig; AddressOf benötigt für Instanzmethoden einen Datei-/Modul-Wrapper.

`check method visibility -> bind named/positional arguments -> Me frame -> return -> ByRef copy-out`

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Classes.cs`; Funktion `CallClassMethod / CallSubrutine`.

#### 6. ClassObject.DisplayValue

Pause, Stopp, Quellzeilen und Tiefenschutz verwenden normale Skriptframes. Schließen der IDE stoppt das Skript nicht. Der Inspektor zeigt Typ/Mitgliederzahl ohne Getter oder Zyklusverfolgung. Watch darf gespeicherte Felder/Autoeigenschaften lesen, aber keine eigenen Getter, Methoden oder Konstruktoren ausführen. Dies ist der beschriebene Basic-Umfang, kein beliebiges .NET.

`debugger: type + member count; no getter calls and no traversal of reference cycles`

Projektquelle: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ClassObject.cs`; Funktion `ClassObject.DisplayValue`.

New liefert Object mit Class-Referenz, keine UO-ID/Grafik. Get und Function liefern ihren Typ; Set, Sub und Deklarationen Unit. Ohne New ist die Variable Nothing. Referenzgleichheit und As Boolean verwenden 1/True bzw. 0/False; Integer-Mengen sind keine automatischen Erfolgsflags. Main liefert "5:2:1", "1:0:6", "ore:1:replacement:0".

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: classDeclaration / classProperty / subrutine / newStructure
Runtime/ClassCatalog.cs: Build / Complete
Runtime/ObjectTypes/ClassObject.cs: Member / Read / Write
Runtime/Interpreter.Classes.cs: ConstructClass / CallClassMethod / InvokeAccessor
Runtime/MemberAccess.cs: Resolve / Read / Write
Runtime/SemanticScope.cs: TryMemberSlot / Coerce
Runtime/Interpreter.cs: CallSubrutine / CreateArgumentWriter
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/class-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/property-statement
-->
