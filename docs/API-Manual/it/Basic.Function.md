# Function / Return / Exit Function / End Function

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: it -->

Function definisce un aiuto che restituisce quantità, testo o riferimenti List/Dictionary. Si chiama senza UO.; UO.GetType(item) resta un’API del gioco distinta da una Function GetType(value) propria.

## Sintassi esatta

```text
Function name(parameters) As type
    name = expression
End Function
Function name(parameters)
    Return expression
End Function
result = name(arguments)
Exit Function
Return
```

## Parametri

- `name` — Il nome, senza distinzione di maiuscole, è anche la variabile locale implicita del risultato nel corpo. name legge il risultato; name(arguments) chiama la funzione, anche ricorsivamente. Non ridichiarare il risultato con Dim, Var, Const o un parametro.
- `parameters / arguments` — Parametri posizionali con le regole di Sub: ByRef predefinito, ByVal, Optional e ParamArray finale. Vedere Basic.Parameters e i capitoli dedicati. Tools.Calculate(...) chiama una funzione di modulo rispettando Public/Private.
- `As type` — Tipo facoltativo: Integer/Long/Short/Byte usano Integer del motore; Double/Single/Decimal usano Double; String conserva testo; Boolean/Bool normalizza a 1/0; Object/Variant conserva il genere del valore. Non corrispondono a tutte le larghezze numeriche VB.NET. I tipi sconosciuti sono rifiutati. Senza As il risultato è Variant; i suffissi del nome non ne deducono il tipo.
- `name = expression` — Memorizza il risultato e CONTINUA con l’istruzione successiva. Si può rileggere o modificare, anche tramite +=. È la variabile locale di questa invocazione, non una globale né una chiamata.
- `Return / Exit Function / End Function` — Return expression assegna il risultato tipizzato e avvia l’uscita. Return vuoto, Exit Function ed End Function restituiscono il risultato corrente. End Function è obbligatorio; Exit Sub dentro Function è un errore di caricamento.

## Restituisce

Il risultato corrente viene restituito dopo i normali Finally. Valori iniziali: Integer 0, Double 0.0, Boolean FALSE/0, String vuota; senza tipo, Variant/Object iniziano da Unit senza valore significativo. List/Dictionary/Object mantengono riferimenti. Boolean produce 1/0 confrontabili con TRUE/FALSE; una quantità o un ID non è automaticamente un codice di successo.

## Comportamento

- La preparazione mantiene Function, controlla tipo e uscite, associa il risultato locale e prepara il corpo una volta. Ogni chiamata riceve argomenti e un nuovo risultato tipizzato. L’assegnazione usa le normali conversioni delle variabili tipizzate.
- Return memorizza il risultato e attraversa i Finally dall’interno verso l’esterno. Questi possono ancora cambiare il valore restituito. La riscrittura ByRef termina dopo una conclusione riuscita. Errori non gestiti e conversioni invalide si propagano invece di dare successo.
- La ricorsione ha parametri, locali e risultato indipendenti: Factorial(n-1) non sovrascrive il risultato del chiamante. Serve un caso finale. Nessun thread, ritardo o timeout implicito; pausa e arresto restano controllati.
- Le chiamate annidate sono limitate a 32 frame, inclusi callback e gestori di eventi. Il superamento genera un errore intercettabile; usare cicli per elaborazioni profonde. Ritorno o errore liberano il frame per le chiamate successive.

## Esempi

### 1. Assegnare e continuare

```vb
# TotalPrice riceve count e price ByVal e restituisce Integer. Un valore negativo dà subito -1. Altrimenti memorizza count*price e poi aggiunge 2. Le chiamate (3,4) e (-1,4) producono 14 e -1; Main restituisce 14:-1. Il significato di -1 è scelto dall’aiuto stesso.
Option Explicit On
Function TotalPrice(ByVal count, ByVal price) As Integer
    If count < 0 OrElse price < 0 Then
        Return -1
    End If
    TotalPrice=count*price
    TotalPrice+=2
End Function

Sub Main()
    Return CStr(TotalPrice(3, 4)) & ":" & CStr(TotalPrice(-1, 4))
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

TotalPrice riceve count e price ByVal e restituisce Integer. Un valore negativo dà subito -1. Altrimenti memorizza count*price e poi aggiunge 2. Le chiamate (3,4) e (-1,4) producono 14 e -1; Main restituisce 14:-1. Il significato di -1 è scelto dall’aiuto stesso.

### 2. Risultato indipendente nella ricorsione

```vb
# Factorial riceve n ByVal e imposta il risultato a 1. Con n<=1 Exit Function restituisce 1; altrimenti n*Factorial(n-1) usa una nuova invocazione. Per i piccoli numeri non negativi dell’esempio, 5!+3!=120+6=126. Anche i negativi entrano nel caso finale; il dominio matematico completo non viene validato.
Option Explicit On
Function Factorial(ByVal n) As Integer
    Factorial=1
    If n <= 1 Then
        Exit Function
    End If
    Factorial=n*Factorial(n-1)
End Function

Sub Main()
    Return Factorial(5)+Factorial(3)
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

Factorial riceve n ByVal e imposta il risultato a 1. Con n<=1 Exit Function restituisce 1; altrimenti n*Factorial(n-1) usa una nuova invocazione. Per i piccoli numeri non negativi dell’esempio, 5!+3!=120+6=126. Anche i negativi entrano nel caso finale; il dominio matematico completo non viene validato.

### 3. Return e due Finally

```vb
# Calculate riceve trace ByRef. Return 1 imposta il risultato e avvia l’uscita. Il Finally interno cambia risultato e trace da 1 a 12; quello esterno li porta a 123. Main riceve entrambi e restituisce 123:123. Finally modifica quindi il valore anche dopo Return expression; non viene simulato alcun movimento del gioco.
Option Explicit On
Function Calculate(ByRef trace) As Integer
    Try
        Try
            trace=1
            Return 1
        Finally
            Calculate=Calculate*10+2
            trace=trace*10+2
        End Try
    Finally
        Calculate=Calculate*10+3
        trace=trace*10+3
    End Try
End Function

Sub Main()
    Dim trace=0
    Dim result=Calculate(trace)
    Return CStr(result) & ":" & CStr(trace)
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

Calculate riceve trace ByRef. Return 1 imposta il risultato e avvia l’uscita. Il Finally interno cambia risultato e trace da 1 a 12; quello esterno li porta a 123. Main riceve entrambi e restituisce 123:123. Finally modifica quindi il valore anche dopo Return expression; non viene simulato alcun movimento del gioco.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: subrutine / parameters / returnStatement / exitProcedure
Runtime/BasicSyntaxPreprocessor.cs: Normalize / NormalizeArguments
Analysis/ProcedureStructureValidator.cs: VisitSubrutine / VisitExitProcedure / CheckName
Runtime/SubrutineDefinition.cs: IsFunction / ReturnType / ResultName
Runtime/Interpreter.cs: CallSubrutine / FunctionResult / DeferReturn / DefaultValueForType
Runtime/SemanticScope.cs: DefineVar / SetVar
Runtime/ScriptBindings.cs: Builder.VisitSubrutine
ClassicUO.Client/Game/Managers/YokoInjectionManager.cs: DiscoverProcedures / DiscoverScopedProcedures
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/function-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/return-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/exit-statement
-->
