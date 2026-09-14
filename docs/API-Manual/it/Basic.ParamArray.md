# ParamArray

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: it -->

I parametri passano dati a SUB/FUNCTION. ByRef riscrive il valore modificato nel chiamante; ByVal ne conserva la variabile. Optional fornisce un argomento omesso e ParamArray raccoglie gli argomenti rimanenti. Sono modificatori della dichiarazione, non comandi richiamabili.

## Sintassi esatta

```text
Function Sum(ParamArray values())
Sum()
Sum(2, 3, 4)
Sum(existingArray)
```

## Parametri

- `name / As type` — name / As type: Nome del parametro e conversione facoltativa in ingresso con As. Argomenti per posizione o name:=value; i modificatori appartengono alla dichiarazione. Vedere Basic.NamedArguments.
- `ByRef` — ByRef: variabile modificabile o elemento indicizzato esistente. Senza ByVal questo motore riscrive comunque il valore, diversamente dal comportamento predefinito VB.NET. Letterali, costanti ed espressioni calcolate sono temporanei.
- `ByVal` — ByVal: copia locale del valore. Assegnare il parametro non sostituisce la variabile chiamante. Array e oggetti condividono ancora i riferimenti: non è una copia profonda.
- `Optional / defaultValue` — Optional / defaultValue: omettere un argomento finale valuta la sua espressione dopo =. Specificare un valore esplicito; senza di esso il parametro omesso riceve Unit non inizializzato.
- `ParamArray` — ParamArray values(): ultimo parametro per zero o più valori restanti. Un singolo array viene riutilizzato; gli scalari creano un nuovo array. GetArrayLength ne restituisce la lunghezza.

## Restituisce

I modificatori non restituiscono valori. RETURN imposta separatamente il risultato. ByRef cambia un argomento, non il risultato. SUB senza RETURN produce Unit. I numeri degli esempi sono calcoli, non indicatori TRUE/FALSE.

## Comportamento

- Gli argomenti vengono valutati una volta da sinistra a destra. ByRef indicizzato conserva contenitore e indice/chiave; riassegnare il contenitore in un altro argomento non reindirizza la scrittura.
- All’ingresso si creano parametri locali. All’uscita, dopo i FINALLY interni, ByRef riscrive i valori nell’ordine dei parametri, anche per errori che escono dal corpo. Due parametri della stessa variabile non sono collegati in tempo reale: prevale l’ultima scrittura.
- ByVal impedisce di sostituire la variabile chiamante ma consente modifiche nell’array o oggetto condiviso. ReDim crea un nuovo riferimento locale. Dati indipendenti richiedono una copia esplicita.
- Per le chiamate posizionali: Omettere Optional dalla fine; le posizioni vuote tra virgole non sono supportate. Le espressioni predefinite vengono eseguite a ogni omissione e non devono essere costanti VB.NET. Prima gli argomenti posizionali, poi soltanto quelli nominati. Non omettere parametri obbligatori. Gli Optional omessi nello script usano i valori dichiarati, valutati in ordine di dichiarazione dopo le espressioni fornite. I metodi nativi usano solo nomi e numero registrati, senza nuovi valori predefiniti.
- ParamArray non riscrive gli scalari raggruppati. Le modifiche a un array fornito esplicitamente sono visibili al chiamante. Passarlo a un altro ParamArray non aggiunge annidamenti.
- Scrivere ByRef e ByVal esplicitamente. Queste regole riguardano le procedure utente chiamate dallo script; i comandi integrati hanno schede proprie.
- ParamArray non si passa per nome. Con argomenti nominati può restare vuoto; per passarne i valori serve una chiamata solo posizionale. Non sono supportati posti vuoti fra virgole. Vale la regola posizionali prima, non la combinazione libera dei VB.NET recenti. Nessun thread o ritardo di gioco aggiuntivo.

## Esempi

### 1. Argomenti vuoti o presenti

```vb
# Sum() riceve un array vuoto e restituisce 0. Sum(2,3,4) riceve tre valori e restituisce 9. For Each li visita. Main restituisce Integer 9.
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

**Spiegazione dei parametri e dell’esecuzione:**

Sum() riceve un array vuoto e restituisce 0. Sum(2,3,4) riceve tre valori e restituisce 9. For Each li visita. Main restituisce Integer 9.

### 2. Inoltrare un array esistente

```vb
# values contiene 2 e 5. Forward passa l’array a Sum senza ulteriore involucro. Sum restituisce la somma Integer 7.
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

**Spiegazione dei parametri e dell’esecuzione:**

values contiene 2 e 5. Forward passa l’array a Sum senza ulteriore involucro. Sum restituisce la somma Integer 7.

### 3. Scalari e array fornito

```vb
# SetFirst(first,second) modifica un nuovo array, conservando first=2 e second=3. SetFirst(packed) cambia packed[0] condiviso da 4 a 9. Main restituisce 2*100+3*10+9, Integer 239.
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

**Spiegazione dei parametri e dell’esecuzione:**

SetFirst(first,second) modifica un nuovo array, conservando first=2 e second=3. SetFirst(packed) cambia packed[0] condiviso da 4 a 9. Main restituisce 2*100+3*10+9, Integer 239.

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
