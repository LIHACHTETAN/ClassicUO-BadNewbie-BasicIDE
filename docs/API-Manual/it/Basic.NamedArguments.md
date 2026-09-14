# Named arguments / :=

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: it -->

Gli argomenti nominati associano valori ai nomi dichiarati, indipendentemente dall’ordine. Sono supportati per procedure e funzioni dello script, moduli, funzioni Basic/UO registrate e metodi nativi.

## Sintassi esatta

```text
FunctionName(parameterName:=expression, otherName:=expression)
FunctionName(positionalExpression, optionalName:=expression)
FunctionName([reservedName]:=expression)
```

## Parametri

- `parameterName / [reservedName]` — Scrivere name:=valore usando il nome della dichiarazione o firma, senza distinzione fra maiuscole e minuscole. Racchiudere i nomi riservati: [to]:=100. Le parentesi indicano il nome, non un indice. Nomi sconosciuti o duplicati causano errore.
- `expression` — Ogni espressione fornita viene valutata una volta da sinistra a destra, poi assegnata al relativo parametro. Tipi, limiti e ByVal/ByRef restano quelli della funzione. La sintassi non trasforma un valore in variabile modificabile.
- `positionalExpression / optionalName` — Prima gli argomenti posizionali, poi soltanto quelli nominati. Non omettere parametri obbligatori. Gli Optional omessi nello script usano i valori dichiarati, valutati in ordine di dichiarazione dopo le espressioni fornite. I metodi nativi usano solo nomi e numero registrati, senza nuovi valori predefiniti.

## Restituisce

:= non restituisce un valore autonomo. La funzione/API mantiene il proprio risultato; Sub non ha risultato implicito. Gli esempi restituiscono Integer 129 e String "21:12", "20:10:2", non Boolean.

## Comportamento

- La preparazione segnala SC027 con posizione sorgente per nomi errati, duplicati, obbligatori mancanti o ambiguità. Gli oggetti dinamici vengono verificati durante l’esecuzione prima di valutare gli argomenti. Una firma nativa mancante non viene sostituita da un richiamo senza argomenti.
- Le mappe immutabili dei punti di chiamata statici vengono memorizzate. Valutazione in ordine sorgente, assegnazione e scrittura ByRef secondo i parametri. Valori predefiniti e informazioni del debugger seguono la firma scelta. Il ricevitore dinamico appartiene alla chiamata corrente, non alla precedente.
- ParamArray non si passa per nome. Con argomenti nominati può restare vuoto; per passarne i valori serve una chiamata solo posizionale. Non sono supportati posti vuoti fra virgole. Vale la regola posizionali prima, non la combinazione libera dei VB.NET recenti. Nessun thread o ritardo di gioco aggiuntivo.

## Esempi

### 1. Omettere l’Optional centrale

```vb
# Encode dichiara x, y=2, z=3. z:=9 e x:=1 forniscono z e x; y mantiene 2. Il risultato è 1*100+2*10+9=129. Equivalenti: Encode(1,2,9) e Encode(1,z:=9).
Option Explicit On
Function Encode(ByVal x, Optional ByVal y=2, Optional ByVal z=3) As Integer
    Return x*100 + y*10 + z
End Function

Sub Main()
    Dim encoded = Encode(z:=9, x:=1)
    Return encoded
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

Encode dichiara x, y=2, z=3. z:=9 e x:=1 forniscono z e x; y mantiene 2. Il risultato è 1*100+2*10+9=129. Equivalenti: Encode(1,2,9) e Encode(1,z:=9).

### 2. Scrivere nelle variabili ByRef corrette

```vb
# Change dichiara ByRef left e right. right:=a collega a=1 a right, left:=b collega b=2 a left. Sommando 10 a left e 20 a right si riscrivono b=12 e a=21. Main restituisce "21:12". A sinistra di := c’è il parametro, a destra la variabile chiamante.
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

**Spiegazione dei parametri e dell’esecuzione:**

Change dichiara ByRef left e right. right:=a collega a=1 a right, left:=b collega b=2 a left. Sommando 10 a left e 20 a right si riscrivono b=12 e a=21. Main restituisce "21:12". A sinistra di := c’è il parametro, a destra la variabile chiamante.

### 3. Usare una lista nativa

```vb
# List() crea la lista. Add(value:=10) aggiunge 10 senza risultato. Insert(value:=20,index:=0) inserisce 20 all’indice 0 e sposta 10 all’indice 1. Item(index:=...) restituisce l’elemento, Count() restituisce 2. Main restituisce "20:10:2". Per UO.Name(...) valgono i nomi registrati e il risultato specifico del comando.
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

**Spiegazione dei parametri e dell’esecuzione:**

List() crea la lista. Add(value:=10) aggiunge 10 senza risultato. Insert(value:=20,index:=0) inserisce 20 all’indice 0 e sposta 10 all’indice 1. Item(index:=...) restituisce l’elemento, Count() restituisce 2. Main restituisce "20:10:2". Per UO.Name(...) valgono i nomi registrati e il risultato specifico del comando.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: argument
Runtime/NamedArgumentBinding.cs: TryCreate / TryCustom
Runtime/Interpreter.NamedArguments.cs: CallNamed
Runtime/Interpreter.cs: CallSubrutine / CreateArgumentWriter
Analysis/NamedArgumentsValidator.cs
https://learn.microsoft.com/en-us/dotnet/visual-basic/programming-guide/language-features/procedures/passing-arguments-by-position-and-by-name
-->
