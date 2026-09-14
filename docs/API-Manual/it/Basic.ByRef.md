# ByRef

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: it -->

I parametri passano dati a SUB/FUNCTION. ByRef riscrive il valore modificato nel chiamante; ByVal ne conserva la variabile. Optional fornisce un argomento omesso e ParamArray raccoglie gli argomenti rimanenti. Sono modificatori della dichiarazione, non comandi richiamabili.

## Sintassi esatta

```text
Sub Adjust(ByRef amount, ByVal increment)
Adjust(amount, 3)
Bump(items[index])
Function name(ByRef value As type)
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

### 1. Modificare una variabile

```vb
# Adjust riceve amount=5 con ByRef e increment=3 con ByVal. amount diventa 8 e viene riscritto. Main restituisce Integer 8; Adjust non ha risultato.
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

**Spiegazione dei parametri e dell’esecuzione:**

Adjust riceve amount=5 con ByRef e increment=3 con ByVal. amount diventa 8 e viene riscritto. Main restituisce Integer 8; Adjust non ha risultato.

### 2. Calcolare l’indice una volta

```vb
# items[0]=5. NextIndex incrementa calls e restituisce 0; Bump porta quell’elemento a 6. Nessun secondo calcolo: calls=1. Main restituisce 6*100+1, Integer 601.
Option Explicit On
Function NextIndex(ByRef calls)
    calls += 1
    Return 0
End Function
Sub Bump(ByRef amount)
    amount += 1
End Sub
Sub Main()
    Dim items[0]
    items[0] = 5
    Var calls = 0
    Bump(items[NextIndex(calls)])
    Return items[0] * 100 + calls
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

items[0]=5. NextIndex incrementa calls e restituisce 0; Bump porta quell’elemento a 6. Nessun secondo calcolo: calls=1. Main restituisce 6*100+1, Integer 601.

### 3. Una variabile in due parametri

```vb
# Entrambi ricevono 5. first diventa 6, second 7. All’uscita si scrive 6, poi 7 in value. Main restituisce Integer 7, non 8.
Option Explicit On
Sub Change(ByRef first, ByRef second)
    first += 1
    second += 2
End Sub
Sub Main()
    Var value = 5
    Change(value, value)
    Return value
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

Entrambi ricevono 5. first diventa 6, second 7. All’uscita si scrive 6, poi 7 in value. Main restituisce Integer 7, non 8.

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
