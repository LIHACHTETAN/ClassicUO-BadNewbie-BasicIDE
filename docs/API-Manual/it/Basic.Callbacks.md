# AddressOf / callbacks

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: it -->

AddressOf conserva un riferimento a una Sub o Function dello script senza chiamarla. Il riferimento può essere passato, restituito o conservato in una raccolta per scegliere una regola di elaborazione.

## Sintassi esatta

```text
Dim callback = AddressOf ProcedureName
Dim callback As Object = AddressOf Tools.FunctionName
callback(arguments)
callback.Invoke(arguments)
Process(values, AddressOf Predicate)
```

## Parametri

- `ProcedureName` — Nome di una procedura dichiarata, eventualmente qualificato con Module. Deve corrispondere a una sola dichiarazione. Nomi sconosciuti, membri Private non accessibili e overload sono respinti prima dell’esecuzione. Per funzioni native Basic o comandi UO scrivere una funzione intermedia con nome univoco. Nessuna parentesi dopo AddressOf nome.
- `callback / arguments` — callback è un Object. callback(...) e callback.Invoke(...) chiamano in modo sincrono nel thread dello script. Gli argomenti nominati usano i veri nomi dei parametri. Assegnare prima un elemento di raccolta a una variabile. Il riferimento viene acquisito prima degli argomenti, anche se questi cambiano callback.
- `ByRef / ByVal / Optional / ParamArray` — ByVal copia valore o riferimento; ByRef riscrive le modifiche; Optional calcola i valori omessi; ParamArray raccoglie valori posizionali. Gli argomenti nominati seguono quelli posizionali; i valori ParamArray richiedono chiamate solo posizionali. Nomi o numero errati falliscono prima degli effetti degli argomenti.

## Restituisce

AddressOf restituisce un riferimento Object, non un ID, un indirizzo, un Boolean o il risultato della funzione. Function restituisce il proprio risultato; Sub senza espressione Return non restituisce valore (Unit). IsPositive restituisce 1/True o 0/False. Main restituisce String negli esempi 1 e 3 e Integer 15 nel secondo.

## Comportamento

- Il riferimento non cattura le variabili locali della funzione creatrice: non è una lambda o chiusura. Appartiene allo script caricato; un altro interprete o uno script ricaricato non può invocarlo. Una fabbrica Public può esporre deliberatamente il proprio aiutante Private.
- La preparazione controlla nome e accesso. L’interprete conserva un riferimento immutabile per posizione AddressOf. Ogni chiamata legge la variabile attuale, controlla la firma, valuta una volta gli argomenti nell’ordine scritto ed entra in un normale contesto di procedura. ByRef ed eccezioni seguono le chiamate dirette.
- Non crea thread o timer. Pausa e annullamento usano i normali punti di controllo, anche nei cicli del callback. Gli errori raggiungono Catch/Finally del chiamante; Catch non assorbe l’arresto d’emergenza. Le chiamate native bloccanti mantengono i propri limiti di annullamento.
- Qui non sono supportati dichiarazioni Delegate, lambda, puntatori DLL o riferimenti a overload. AddressOf non usa UO.; i comandi di gioco nella funzione intermedia conservano UO.
- Le chiamate annidate sono limitate a 32 frame, inclusi callback e gestori di eventi. Il superamento genera un errore intercettabile; usare cicli per elaborazioni profonde. Ritorno o errore liberano il frame per le chiamate successive.

## Esempi

### 1. Filtrare con un predicato

```vb
# values è la List iniziale; predicate è AddressOf IsPositive. FilterValues chiama predicate(number) una volta per numero. Rimangono i positivi 4 e 7: selected.Count()=2 e selected[0]=4. Main restituisce "2:4". I due aiutanti sono codice completo dello script, non ulteriori comandi API.
Option Explicit On
Function IsPositive(ByVal number) As Boolean
    Return number > 0
End Function

Function FilterValues(ByVal values, ByVal predicate)
    Dim result = List()
    For Each number In values
        If predicate(number) Then
            result.Add(number)
        End If
    Next
    Return result
End Function

Sub Main()
    Dim numbers = List()
    numbers.Add(-2)
    numbers.Add(4)
    numbers.Add(7)
    Dim selected = FilterValues(numbers, AddressOf IsPositive)
    Return CStr(selected.Count()) & ":" & CStr(selected[0])
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

values è la List iniziale; predicate è AddressOf IsPositive. FilterValues chiama predicate(number) una volta per numero. Rimangono i positivi 4 e 7: selected.Count()=2 e selected[0]=4. Main restituisce "2:4". I due aiutanti sono codice completo dello script, non ulteriori comandi API.

### 2. Modificare una variabile esterna

```vb
# AddAmount riceve total ByRef e amount ByVal, predefinito 1. update(total) cambia 10 in 11; Invoke con amount:=4 e total:=total associa i nomi e cambia 11 in 15. ByRef riscrive la variabile originale. Sub non restituisce nulla; Main restituisce Integer 15, non Boolean.
Option Explicit On
Sub AddAmount(ByRef total As Integer, Optional ByVal amount = 1)
    total += amount
End Sub

Sub Main()
    Dim update = AddressOf AddAmount
    Dim total = 10
    update(total)
    update.Invoke(amount:=4, total:=total)
    Return total
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

AddAmount riceve total ByRef e amount ByVal, predefinito 1. update(total) cambia 10 in 11; Invoke con amount:=4 e total:=total associa i nomi e cambia 11 in 15. ByRef riscrive la variabile originale. Sub non restituisce nulla; Main restituisce Integer 15, non Boolean.

### 3. Regola privata ed errore

```vb
# Rules.Create restituisce un riferimento a Private CheckedDouble. AddressOf Rules.CheckedDouble diretto dall’esterno è vietato. operation(6) restituisce 12; operation(-1) solleva "negative" prima dell’assegnazione, lasciando result=12. Catch legge il messaggio e Finally aggiunge ":done". Main restituisce "12:negative:done". Chiudere l’IDE non ferma lo script.
Option Explicit On
Module Rules
    Private Function CheckedDouble(ByVal number) As Integer
        If number < 0 Then
            Throw "negative"
        End If
        Return number * 2
    End Function

    Public Function Create()
        Return AddressOf CheckedDouble
    End Function
End Module

Sub Main()
    Dim operation = Rules.Create()
    Dim result = operation(6)
    Dim message = ""
    Try
        result = operation(-1)
    Catch problem
        message = problem
    Finally
        message = message & ":done"
    End Try
    Return CStr(result) & ":" & message
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

Rules.Create restituisce un riferimento a Private CheckedDouble. AddressOf Rules.CheckedDouble diretto dall’esterno è vietato. operation(6) restituisce 12; operation(-1) solleva "negative" prima dell’assegnazione, lasciando result=12. Catch legge il messaggio e Finally aggiunge ":done". Main restituisce "12:negative:done". Chiudere l’IDE non ferma lo script.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: addressOf / ADDRESSOF
Runtime/Metadata.cs: TryGetCallbackTarget
Analysis/InvalidSymbolVisitor.cs: VisitAddressOf
Runtime/Interpreter.Callbacks.cs: VisitAddressOf / TryGetCallback / CallCallback
Runtime/Interpreter.cs: CreateArgumentWriter / CallSubrutine
Runtime/NamedArgumentBinding.cs: TryCreate
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/operators/addressof-operator
-->
