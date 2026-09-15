# Class / New / Me / Property

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: it -->

Class riunisce stato e metodi di ogni oggetto. New crea un riferimento: assegnarlo a un’altra variabile conserva lo stesso oggetto, diversamente dalla copia di valore Structure. Gli esempi includono tutti i costruttori, metodi e accessori usati.

## Sintassi esatta

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

## Parametri

- `TypeName / Public / Private` — TypeName è un nome semplice univoco a livello file o Module; fuori dal modulo usare ModuleName.TypeName. Class è Public per impostazione predefinita; Private Class è visibile solo nel proprio Module. Non sono implementati ereditarietà, interfacce, generici, classi annidate, Shared, overload, distruttori ed Event di istanza.
- `field As FieldType / Me` — I campi richiedono As Integer, Double, Boolean, String, Object oppure Enum, Structure, Class dichiarati; valgono anche gli alias Basic esistenti. I campi sono Private per impostazione predefinita: indicare Public per l’accesso esterno. Valori iniziali: numeri/Boolean 0, String vuota, Structure con campi zero, Object/Class Nothing (Unit). Altre inizializzazioni vanno in Sub New. Me identifica l’istanza e non può essere riassegnato/ridichiarato; i nomi locali possono nascondere altri membri.
- `New / Sub New` — New TypeName(arguments) crea campi separati ed esegue Public Sub New una volta. Senza costruttore è valido solo New TypeName(). È ammesso un costruttore; Optional, valori predefiniti e argomenti nominati seguono le regole normali. Gli argomenti vengono valutati una volta nell’ordine scritto; un errore impedisce di restituire l’oggetto costruito. As TypeName senza New resta Nothing.
- `Sub / Function / arguments` — Sub/Function si chiamano con instance.Method(...), oppure Method(...)/Me.Method(...) nella classe. Private è accessibile solo dalla stessa Class, anche su un’altra istanza dello stesso tipo. Sono supportati tipi, ByVal/ByRef, Optional, ParamArray e argomenti nominati, tranne elementi ParamArray nominati. Function restituisce il tipo dichiarato; Sub Unit. TypeName.Method(...) e instance.New(...) non sono validi; AddressOf richiede una procedura wrapper di file/modulo.
- `Property / Get / Set` — Property Name[()] As ValueType non accetta indici. Leggere instance.Name senza parentesi di chiamata. Get restituisce Return o l’assegnazione a Name; Exit Property restituisce tale risultato/valore predefinito. L’assegnazione chiama Set(ByVal value As ValueType) senza leggere il Get finale. Una proprietà normale richiede un Get e un Set. La visibilità appartiene a Property; Set deve avere un parametro ByVal esplicito dello stesso tipo.
- `ReadOnly / WriteOnly / auto Property` — ReadOnly con corpo contiene solo Get, WriteOnly solo Set; l’accesso vietato causa un errore intercettabile. La proprietà automatica conserva direttamente il valore senza Get/Set né End Property. ReadOnly automatico può essere assegnato solo nel Sub New di quell’istanza; WriteOnly senza Set non è valido. Un riferimento Class restituito da ReadOnly può avere membri modificabili.
- `ByVal / ByRef / With` — ByVal copia il riferimento: cambiare membri modifica l’originale, sostituire il parametro non sostituisce la variabile chiamante. ByRef riporta anche un riferimento sostitutivo secondo copy-in/copy-out. L’uguaglianza verifica l’identità. With instance acquisisce l’oggetto una volta e supporta campi, proprietà e metodi. Class non implementa automaticamente IDisposable; Using va applicato alle risorse supportate.

## Restituisce

New restituisce Object con riferimento Class, non ID/grafica UO. Get e Function restituiscono il loro tipo; Set, Sub e dichiarazioni Unit. Senza New si ottiene Nothing. Uguaglianza dei riferimenti e As Boolean usano 1/True o 0/False; una quantità Integer non è automaticamente successo. Main restituisce "5:2:1", "1:0:6", "ore:1:replacement:0".

## Comportamento

- SC032 rifiuta dichiarazioni errate prima dell’esecuzione anche senza Option Explicit. Limiti: 256 classi, 256 campi/proprietà e 256 metodi per classe; 32 chiamate annidate includendo New/Get/Set. Percorsi di assegnazione/ByRef: 64 componenti. Sono ammessi cicli di riferimenti; metadati/default sono preparati e ogni New ha celle mutabili separate.
- Il percorso del destinatario viene acquisito prima del lato destro/argomenti; ciascun Get del percorso viene valutato una volta. La riscrittura mantiene il destinatario originale anche se una procedura sostituisce una variabile intermedia. Il valore viene convertito al tipo dichiarato. Try/Catch gestisce gli errori di costruttori, metodi e accessori senza annullare modifiche precedenti.
- Pausa, arresto, righe e protezione della profondità usano normali frame dello script. Chiudere IDE non arresta lo script. L’ispettore mostra tipo/numero di membri senza Get né attraversamento dei cicli. Watch legge campi/proprietà automatiche ma non esegue Get personalizzati, metodi o costruttori. È il sottoinsieme descritto, non classi .NET arbitrarie.

## Esempi

### 1. Oggetti indipendenti e riferimento condiviso

```vb
# New Counter(label:="ore", start:=2) riceve String label e Integer start, impostando Label/stored. second ha campi indipendenti; alias=first copia il riferimento. Add(amount:=3) scrive tramite Value.Set, controlla i negativi e restituisce Integer da Value.Get. first diventa 5, second resta 2 e alias=first vale 1/True. Il codice include tutti i metodi.
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

**Spiegazione dei parametri e dell’esecuzione:**

New Counter(label:="ore", start:=2) riceve String label e Integer start, impostando Label/stored. second ha campi indipendenti; alias=first copia il riferimento. Add(amount:=3) scrive tramite Value.Set, controlla i negativi e restituisce Integer da Value.Get. first diventa 5, second resta 2 e alias=first vale 1/True. Il codice include tutti i metodi.

### 2. Lettura, scrittura e Boolean

```vb
# Limit=10 chiama Set con value=10. Remaining.Get assegna il risultato e usa Exit Property. TrySpend(cost:=4) sottrae quattro e restituisce 1/True; cost=9 supera i sei rimasti e restituisce 0/False. Limit=-3 genera errore prima della scrittura; Catch legge Remaining=6. Main produce "1:0:6" senza azioni sul server.
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

**Spiegazione dei parametri e dell’esecuzione:**

Limit=10 chiama Set con value=10. Remaining.Get assegna il risultato e usa Exit Property. TrySpend(cost:=4) sottrae quattro e restituisce 1/True; cost=9 supera i sei rimasti e restituisce 0/False. Limit=-3 genera errore prima della scrittura; Catch legge Remaining=6. Main produce "1:0:6" senza azioni sul server.

### 3. Module, ByVal e sostituzione ByRef

```vb
# Jobs.WorkItem(name) conserva String Name; Done parte da zero. Tick(ByVal job) porta il Done condiviso a 1, poi sostituisce solo il proprio parametro con "local". Replace(ByRef job, ByVal name) crea "replacement" e riporta il riferimento al chiamante; gli argomenti nominati sono volutamente invertiti. original resta "ore"/1, job diventa "replacement"/0. Module Jobs è completo.
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

**Spiegazione dei parametri e dell’esecuzione:**

Jobs.WorkItem(name) conserva String Name; Done parte da zero. Tick(ByVal job) porta il Done condiviso a 1, poi sostituisce solo il proprio parametro con "local". Replace(ByRef job, ByVal name) crea "replacement" e riporta il riferimento al chiamante; gli argomenti nominati sono volutamente invertiti. original resta "ore"/1, job diventa "replacement"/0. Module Jobs è completo.


### Funzioni interne: dalla chiamata al risultato

Class riunisce stato e metodi di ogni oggetto. New crea un riferimento: assegnarlo a un’altra variabile conserva lo stesso oggetto, diversamente dalla copia di valore Structure. Gli esempi includono tutti i costruttori, metodi e accessori usati.

#### 1. ClassCatalog.Build / Complete

SC032 rifiuta dichiarazioni errate prima dell’esecuzione anche senza Option Explicit. Limiti: 256 classi, 256 campi/proprietà e 256 metodi per classe; 32 chiamate annidate includendo New/Get/Set. Percorsi di assegnazione/ByRef: 64 componenti. Sono ammessi cicli di riferimenti; metadati/default sono preparati e ogni New ha celle mutabili separate.

`declarations -> unique typed members -> accessor validation -> prepared metadata; SC032 on invalid Class`

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/ClassCatalog.cs`; funzione `ClassCatalog.Build / Complete`.

#### 2. ConstructClass

New TypeName(arguments) crea campi separati ed esegue Public Sub New una volta. Senza costruttore è valido solo New TypeName(). È ammesso un costruttore; Optional, valori predefiniti e argomenti nominati seguono le regole normali. Gli argomenti vengono valutati una volta nell’ordine scritto; un errore impedisce di restituire l’oggetto costruito. As TypeName senza New resta Nothing.

`new instance -> independent field slots -> bind constructor arguments -> Sub New -> Object reference`

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Classes.cs`; funzione `ConstructClass`.

#### 3. ClassObject.Member / Read

Property Name[()] As ValueType non accetta indici. Leggere instance.Name senza parentesi di chiamata. Get restituisce Return o l’assegnazione a Name; Exit Property restituisce tale risultato/valore predefinito. L’assegnazione chiama Set(ByVal value As ValueType) senza leggere il Get finale. Una proprietà normale richiede un Get e un Set. La visibilità appartiene a Property; Set deve avere un parametro ByVal esplicito dello stesso tipo.

`check member visibility -> stored value OR Get frame -> declared value type`

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ClassObject.cs`; funzione `ClassObject.Member / Read`.

#### 4. MemberAccess.Resolve / ClassObject.Write

Il percorso del destinatario viene acquisito prima del lato destro/argomenti; ciascun Get del percorso viene valutato una volta. La riscrittura mantiene il destinatario originale anche se una procedura sostituisce una variabile intermedia. Il valore viene convertito al tipo dichiarato. Try/Catch gestisce gli errori di costruttori, metodi e accessori senza annullare modifiche precedenti.

`capture receiver once -> evaluate RHS/arguments -> coerce value -> Set OR stored slot`

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/MemberAccess.cs`; funzione `MemberAccess.Resolve / ClassObject.Write`.

#### 5. CallClassMethod / CallSubrutine

Sub/Function si chiamano con instance.Method(...), oppure Method(...)/Me.Method(...) nella classe. Private è accessibile solo dalla stessa Class, anche su un’altra istanza dello stesso tipo. Sono supportati tipi, ByVal/ByRef, Optional, ParamArray e argomenti nominati, tranne elementi ParamArray nominati. Function restituisce il tipo dichiarato; Sub Unit. TypeName.Method(...) e instance.New(...) non sono validi; AddressOf richiede una procedura wrapper di file/modulo.

`check method visibility -> bind named/positional arguments -> Me frame -> return -> ByRef copy-out`

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Classes.cs`; funzione `CallClassMethod / CallSubrutine`.

#### 6. ClassObject.DisplayValue

Pausa, arresto, righe e protezione della profondità usano normali frame dello script. Chiudere IDE non arresta lo script. L’ispettore mostra tipo/numero di membri senza Get né attraversamento dei cicli. Watch legge campi/proprietà automatiche ma non esegue Get personalizzati, metodi o costruttori. È il sottoinsieme descritto, non classi .NET arbitrarie.

`debugger: type + member count; no getter calls and no traversal of reference cycles`

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ClassObject.cs`; funzione `ClassObject.DisplayValue`.

New restituisce Object con riferimento Class, non ID/grafica UO. Get e Function restituiscono il loro tipo; Set, Sub e dichiarazioni Unit. Senza New si ottiene Nothing. Uguaglianza dei riferimenti e As Boolean usano 1/True o 0/False; una quantità Integer non è automaticamente successo. Main restituisce "5:2:1", "1:0:6", "ore:1:replacement:0".

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
