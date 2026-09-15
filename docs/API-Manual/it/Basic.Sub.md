# Sub / Call / Exit Sub / End Sub

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: it -->

Sub raggruppa istruzioni in una procedura con nome, utile per oggetti, controlli e operazioni finali. La chiamata è sincrona nello script corrente e non avvia un altro script in background.

## Sintassi esatta

```text
Sub name(parameters)
    statements
End Sub
name(arguments)
Call name(arguments)
Call name arguments
Call name
Exit Sub
Return
Return expression
```

## Parametri

- `name` — Identificatore senza distinzione tra maiuscole e minuscole. Il codice proprio si chiama senza UO.; un membro di modulo è Tools.Work(...). Public/Private ne regolano l’accesso: vedere Basic.Module e Basic.Visibility.
- `parameters / arguments` — I parametri si dichiarano tra parentesi e gli argomenti seguono il loro ordine. ByRef è predefinito; ByVal copia il valore, Optional fornisce il valore omesso e l’ultimo ParamArray raccoglie gli argomenti aggiuntivi. I cinque capitoli sui parametri spiegano tipi, array, riferimenti condivisi e riscrittura.
- `statements / End Sub` — Il corpo può essere vuoto; End Sub è obbligatorio. Ogni invocazione possiede variabili locali proprie, anche nella ricorsione. Dichiarare procedure a livello di file o modulo, non dentro un’altra procedura.
- `Call` — Call è facoltativo in name(arguments). Call name arguments ammette argomenti senza parentesi; Call name richiama una procedura senza parametri. Call scarta un eventuale valore restituito. Gli argomenti mantengono il normale significato delle espressioni.
- `Exit Sub / Return` — Exit Sub o Return senza espressione termina questa invocazione. Return expression dentro Sub è un’estensione di compatibilità Basic, assente nel Sub di VB.NET. Exit Function dentro Sub causa un errore di caricamento.

## Restituisce

End Sub, Exit Sub e Return vuoto producono Unit: nessun valore significativo, non un successo booleano né un ID. Un Sub Basic storico può restituire expression con Return. ByRef può modificare separatamente una variabile del chiamante. Preferire Function per calcolare un risultato.

## Comportamento

- La preparazione normalizza intestazioni compatibili e Call, verifica il blocco e risolve i nomi. Gli argomenti vengono valutati e associati prima dell’ingresso. Le chiamate riutilizzano istruzioni preparate, senza condividere i valori locali.
- L’interprete crea l’ambito, esegue il corpo e riprende dopo la chiamata. L’uscita normale e Exit Sub eseguono i Finally abbandonati prima di completare la riscrittura dei parametri. Un’eccezione segue il gestore attivo; una chiamata fallita non equivale a successo.
- Restano i controlli di pausa e arresto. Non si crea un thread, un ritardo o un timeout automatico. La ricorsione richiede una condizione finale. Assegnare al nome di Sub non imposta il risultato: usare Function.
- Le chiamate annidate sono limitate a 32 frame, inclusi callback e gestori di eventi. Il superamento genera un errore intercettabile; usare cicli per elaborazioni profonde. Ritorno o errore liberano il frame per le chiamate successive.

## Esempi

### 1. Tre forme di chiamata

```vb
# total parte da 4. AddAmount riceve total ByRef; amount omesso vale 1, mentre 3 e 2 espliciti sono ByVal. Call con parentesi, senza parentesi e la chiamata normale eseguono lo stesso aiuto. Il totale è 4+1+3+2=10, restituito da Main.
Option Explicit On
Sub AddAmount(ByRef total, Optional ByVal amount=1)
    total += amount
End Sub

Sub Main()
    Dim total=4
    Call AddAmount(total)
    Call AddAmount total, 3
    AddAmount(total, 2)
    Return total
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

total parte da 4. AddAmount riceve total ByRef; amount omesso vale 1, mentre 3 e 2 espliciti sono ByVal. Call con parentesi, senza parentesi e la chiamata normale eseguono lo stesso aiuto. Il totale è 4+1+3+2=10, restituito da Main.

### 2. Ingresso pubblico e aiuto privato

```vb
# Batches.SumInto riceve total ByRef e raccoglie 3,-9,4 in values. For Each chiama AppendAmount. Il controllo negativo esce solo da questo aiuto: -9 viene saltato e il ciclo continua. Dal valore iniziale 2 si ottiene 2+3+4=9. All’esterno si usa il nome pubblico qualificato.
Option Explicit On
Module Batches
    Private Sub AppendAmount(ByRef total, ByVal value)
        If value < 0 Then
            Exit Sub
        End If
        total += value
    End Sub

    Public Sub SumInto(ByRef total, ParamArray values)
        For Each value In values
            AppendAmount(total, value)
        Next
    End Sub
End Module

Sub Main()
    Dim total=2
    Batches.SumInto(total, 3, -9, 4)
    Return total
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

Batches.SumInto riceve total ByRef e raccoglie 3,-9,4 in values. For Each chiama AppendAmount. Il controllo negativo esce solo da questo aiuto: -9 viene saltato e il ciclo continua. Dal valore iniziale 2 si ottiene 2+3+4=9. All’esterno si usa il nome pubblico qualificato.

### 3. Uscita anticipata e pulizia

```vb
# Finish imposta trace=1 ed esce; trace=99 non viene eseguito. Finally aggiunge 2, quindi trace=12 torna via ByRef. LegacyValue mostra Return 7 in un Sub Basic. Main restituisce 12*10+7=127. Le cifre di trace sono definite dall’esempio, non codici del gioco.
Option Explicit On
Sub Finish(ByRef trace)
    Try
        trace=1
        Exit Sub
        trace=99
    Finally
        trace=trace*10+2
    End Try
End Sub

Sub LegacyValue()
    Return 7
End Sub

Sub Main()
    Dim trace=0
    Call Finish(trace)
    Return trace*10+LegacyValue()
End Sub
```

**Spiegazione dei parametri e dell’esecuzione:**

Finish imposta trace=1 ed esce; trace=99 non viene eseguito. Finally aggiunge 2, quindi trace=12 torna via ByRef. LegacyValue mostra Return 7 in un Sub Basic. Main restituisce 12*10+7=127. Le cifre di trace sono definite dall’esempio, non codici del gioco.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: subrutine / parameters / returnStatement / exitProcedure
Runtime/BasicSyntaxPreprocessor.cs: Normalize / NormalizeArguments
Analysis/ProcedureStructureValidator.cs: VisitSubrutine / VisitExitProcedure / CheckName
Runtime/SubrutineDefinition.cs: IsFunction / ReturnType / ResultName
Runtime/Interpreter.cs: CallSubrutine / FunctionResult / DeferReturn / DefaultValueForType
Runtime/SemanticScope.cs: DefineVar / SetVar
Runtime/ScriptBindings.cs: Builder.VisitSubrutine
ClassicUO.Client/Game/Managers/YokoInjectionManager.cs: DiscoverProcedures / DiscoverScopedProcedures
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/sub-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/call-statement
-->
