# Structure / New / fields

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: it -->

Structure riunisce campi tipizzati, come X, Y e Z, in un valore. Il motore supporta strutture dati copiate per valore; non tutte le funzionalità Structure di VB.NET.

## Sintassi esatta

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

## Parametri

- `TypeName / Public / Private` — Nome di tipo semplice e univoco, a livello di file o dentro Module. Public è predefinito. Private è ammesso solo in Module e impedisce l’accesso esterno al nome del tipo. Tipo pubblico: ModuleName.TypeName. Parole chiave e campi non vengono tradotti.
- `field / FieldType` — Nome univoco del campo, As e un tipo scalare supportato, Enum o altra Structure. Campi pubblici; forme Public, Dim e VAR ammesse. Tipi: Integer/Long/Short/Byte, Single/Double/Decimal, String, Boolean/Bool, Object/Variant. Gli alias interi usano 32 bit con segno. Le strutture annidate non possono creare cicli.
- `Dim / New` — Dim value As TypeName e New TypeName() creano il valore predefinito senza chiamate allo script. New richiede parentesi vuote: assegnare X/Y/Z in seguito. Dim copy = value prende il valore dell’espressione. Nessun prefisso UO.
- `value.field / copy` — Il punto legge e assegna campi, anche route.Start.X. La scrittura controlla il tipo e sostituisce il valore contenitore. copy = value copia scalari e strutture annidate: modificare copy.X non modifica value.X. I tipi devono essere compatibili.
- `ByVal / ByRef` — ByVal passa una copia. ByRef copia all’ingresso e riscrive il risultato nel chiamante all’uscita, anche per un argomento campo modificabile. Specificare i modificatori; altrimenti valgono le regole Basic esistenti. Return può restituire una struttura; Function può dichiarare As TypeName.

## Restituisce

Dichiarazioni e assegnazioni restituiscono Unit. New e funzioni appropriate restituiscono un valore di struttura, rappresentato come Object nelle osservazioni con il nome del tipo. Le coordinate sono numeri, non flag Boolean. = e <> restituiscono 1/True o 0/False. Risultati String: "1445:1447:1690:0", "10:15:24", "2:4:2:2".

## Comportamento

- Controllo prima degli inizializzatori: massimo 256 tipi, ciascuno con 1–256 campi, 32 livelli annidati. Duplicati, tipi sconosciuti, cicli e limiti superati producono SC030. Private viene controllato durante la risoluzione dei nomi.
- Campi predefiniti: intero/Enum 0, virgola mobile 0, Boolean 0/False, String vuota, Object/Variant Unit prima dell’assegnazione. Le strutture annidate hanno propri valori predefiniti. Inizializzatori dei campi nella dichiarazione non supportati: assegnare dopo la creazione.
- Object e array conservano riferimenti durante la copia. Le copie possono condividere List, Dictionary o array. Scalare e struttura annidata cambiano indipendentemente; modificare il contenuto della raccolta condivisa è visibile in entrambe. List conserva il valore della struttura al momento dell’aggiunta.
- = confronta lo stesso tipo dichiarato e i campi; <> restituisce l’inverso. I riferimenti si confrontano per identità. È un’estensione del motore, non una regola generale per VB.NET. Hash memorizzati e coppie già visitate evitano ripetute espansioni di valori annidati condivisi.
- Supportati: campi dati pubblici tipizzati, visibilità Module, New(), assegnazione, parametri e risultati. Non supportati metodi interni, costruttori personalizzati, inizializzatori, proprietà, ereditarietà o campi privati. WITH .field e array[index].field non sono ammessi: leggere in una variabile, modificare e riscrivere. Le dichiarazioni possono essere in Include.

## Esempi

### 1. Coordinate e copia indipendente

```vb
# original riceve X=1445 e Y=1690; Z resta 0. copy prende il valore, poi copy.X += 2 cambia solo la copia. New Position() crea empty con Z=0. Risultato: 1445:1447:1690:0. Sono coordinate memorizzate; lo script non muove il personaggio.
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

**Spiegazione dei parametri e dell’esecuzione:**

original riceve X=1445 e Y=1690; Z resta 0. copy prende il valore, poi copy.X += 2 cambia solo la copia. New Position() crea empty con Z=0. Risultato: 1445:1447:1690:0. Sono coordinate memorizzate; lo script non muove il personaggio.

### 2. Percorso annidato, ByVal e ByRef

```vb
# Route contiene Start e Finish di tipo Position. Shift(point ByVal, dx ByVal) aggiunge dx alla X della copia e restituisce Position. point:=route.Start, dx:=5 producono shifted.X=15; Start.X resta 10. Advance(route ByRef, dx ByVal) aggiunge 4 a Finish.X e riscrive Route: 24. Main restituisce 10:15:24. Tutte le procedure ausiliarie sono mostrate.
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

**Spiegazione dei parametri e dell’esecuzione:**

Route contiene Start e Finish di tipo Position. Shift(point ByVal, dx ByVal) aggiunge dx alla X della copia e restituisce Position. point:=route.Start, dx:=5 producono shifted.X=15; Start.X resta 10. Advance(route ByRef, dx ByVal) aggiunge 4 a Finish.X e riscrive Route: 24. Main restituisce 10:15:24. Tutte le procedure ausiliarie sono mostrate.

### 3. Valore salvato e raccolta condivisa

```vb
# Entry contiene Point come valore e Items come Object. first.Point.X=2; Items riceve List() con un testo. snapshots.Add(first) salva il valore. second=first e second.Point.X=4 non cambiano il 2 salvato. second.Items.Add("ingot") cambia la lista condivisa: first.Items.Count()=2. saved=snapshots[0] permette di leggere i campi dell’elemento. Risultato: 2:4:2:2.
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

**Spiegazione dei parametri e dell’esecuzione:**

Entry contiene Point come valore e Items come Object. first.Point.X=2; Items riceve List() con un testo. snapshots.Add(first) salva il valore. second=first e second.Point.X=4 non cambiano il 2 salvato. second.Items.Add("ingot") cambia la lista condivisa: first.Items.Count()=2. saved=snapshots[0] permette di leggere i campi dell’elemento. Risultato: 2:4:2:2.


### Funzioni interne: dalla chiamata al risultato

Structure riunisce campi tipizzati, come X, Y e Z, in un valore. Il motore supporta strutture dati copiate per valore; non tutte le funzionalità Structure di VB.NET.

#### 1. Build / PrepareDefault

Controllo prima degli inizializzatori: massimo 256 tipi, ciascuno con 1–256 campi, 32 livelli annidati. Duplicati, tipi sconosciuti, cicli e limiti superati producono SC030. Private viene controllato durante la risoluzione dei nomi.

`declarations -> field types -> visibility -> cycle/depth checks -> immutable defaults`

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/StructureCatalog.cs`; funzione `Build / PrepareDefault`.

#### 2. VisitNewStructure

Dim value As TypeName e New TypeName() creano il valore predefinito senza chiamate allo script. New richiede parentesi vuote: assegnare X/Y/Z in seguito. Dim copy = value prende il valore dell’espressione. Nessun prefisso UO.

`resolve TypeName -> prepared default value; no procedure call`

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.cs`; funzione `VisitNewStructure`.

#### 3. WithField / SetVar

Il punto legge e assegna campi, anche route.Start.X. La scrittura controlla il tipo e sostituisce il valore contenitore. copy = value copia scalari e strutture annidate: modificare copy.X non modifica value.X. I tipi devono essere compatibili.

`resolve path -> coerce field -> replace path -> assign new root value`

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/StructureObject.cs`; funzione `WithField / SetVar`.

#### 4. CreateArgumentWriter

ByVal passa una copia. ByRef copia all’ingresso e riscrive il risultato nel chiamante all’uscita, anche per un argomento campo modificabile. Specificare i modificatori; altrimenti valgono le regole Basic esistenti. Return può restituire una struttura; Function può dichiarare As TypeName.

`ByVal: value copy; ByRef: value copy -> callee -> caller slot write-back`

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.cs`; funzione `CreateArgumentWriter`.

#### 5. ValueEquals

= confronta lo stesso tipo dichiarato e i campi; <> restituisce l’inverso. I riferimenti si confrontano per identità. È un’estensione del motore, non una regola generale per VB.NET. Hash memorizzati e coppie già visitate evitano ripetute espansioni di valori annidati condivisi.

`type identity -> cached hash -> distinct field pairs; reference members keep identity`

Sorgente del progetto: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/StructureObject.cs`; funzione `ValueEquals`.

Dichiarazioni e assegnazioni restituiscono Unit. New e funzioni appropriate restituiscono un valore di struttura, rappresentato come Object nelle osservazioni con il nome del tipo. Le coordinate sono numeri, non flag Boolean. = e <> restituiscono 1/True o 0/False. Risultati String: "1445:1447:1690:0", "10:15:24", "2:4:2:2".

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
