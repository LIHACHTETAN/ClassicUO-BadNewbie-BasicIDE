# Async / Await / Delay

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: fr -->

Async Function crée une tâche du script. Await suspend cette fonction pour laisser progresser les autres travaux prêts du même script. Aucun nouveau thread ni bibliothèque Task complète de VB.NET n’est créé.

## Syntaxe exacte

```text
Async Function Work(ByVal value As Integer) As Task(Of Integer)
    Await Delay(100)
    Return value
End Function
Async Function Work() As Task
    Await Delay(100)
End Function
Delay(milliseconds) -> Object (ScriptTask)
Await task
Dim value = Await task
value = Await task
Return Await task
task.IsCompleted() -> Integer (0/1)
task.IsFaulted() -> Integer (0/1)
task.IsCanceled() -> Integer (0/1)
task.Result() -> T / Unit
```

## Paramètres

- `milliseconds` — Delay prend un Integer de 0 à 2147483647 millisecondes. Zéro termine immédiatement ; valeurs négatives, fractions et String déclenchent une erreur interceptable. L’horloge monotone fixe un délai minimal, pas une garantie d’exécution exacte.
- `Async Function / ByVal / Task(Of T)` — As Task ne fournit aucune valeur ; As Task(Of T) fournit un scalaire Basic ou Object/Variant. Les paramètres exigent ByVal explicite ou ParamArray ; Optional et arguments nommés fonctionnent. ByRef et Async Sub/Declare sont refusés. Créez les tâches dans le corps des procédures, après l’initialisation globale et les valeurs de paramètres par défaut.
- `task / Await` — Stockez la tâche sans type déclaré ou As Object. Await accepte une tâche de cette exécution : instruction entière, totalité du membre droit d’une déclaration/affectation scalaire ou Return Await. Interdit dans les calculs, conditions, affectations champ/index, Catch/Finally et hors Async Function. Plusieurs consommateurs peuvent attendre la même tâche ; les dépendances cycliques échouent.
- `IsCompleted / IsFaulted / IsCanceled / Result` — IsCompleted vaut 1 après réussite, échec ou annulation ; IsFaulted après échec ; IsCanceled après annulation. Ces prédicats Integer acceptent True/False. Result() rend la valeur enregistrée, échoue avant la fin et relance l’erreur d’une tâche échouée. Les tâches d’une exécution précédente sont invalides.

## Retour

Un appel du script à Async Function et Delay rend Object (ScriptTask), pas immédiatement T. Await et Result() rendent T ; As Task et Delay terminent avec Unit, sans valeur. Si le client lance une Async Function comme point d’entrée, il attend de façon coopérative et reçoit le résultat final. Une donnée numérique n’est pas forcément Boolean.

## Comportement

- La fonction démarre immédiatement jusqu’au premier Await inachevé. Variables locales, position de boucle, objet With et cadre du débogueur sont conservés puis restaurés. Une tâche déjà terminée ne suspend pas. L’opérande Await est évalué une seule fois.
- Le thread du script contrôle les échéances aux points sûrs et reprend au plus 64 continuations par passage. Aucun thread supplémentaire. Wait synchrone ou un long appel natif/du jeu peut retarder les autres tâches ; préférez Await Delay. Limite : 1024 tâches inachevées ou erreurs non observées.
- Pause bloque les continuations, mais le temps avance ; reprendre traite celles arrivées à échéance. Stop, erreur ou retour du point d’entrée annule les tâches restantes et libère ressources Using et itérateurs. L’arrêt d’urgence ignore les Catch/Finally du script. Une erreur non observée est signalée à la fin du point d’entrée. Fermer IDE seul n’arrête pas un script actif.
- Absents : Task.Run/WhenAll, tâches .NET externes, Async Sub, Await dans Catch/Finally et déclarations locales As Task. Ne laissez pas de tâche nécessaire après le retour de Main. Async/Await sont réservés.

## Exemples

### 1. Deux attentes indépendantes

```vb
# ValueLater reçoit value et milliseconds par valeur. Les deux appels démarrent avant lecture : 22 après 10 ms, 20 après 30 ms. Main attend les deux au maximum 5000 ms puis additionne leurs Integer : 42. Wait Until échoue si le délai expire.
Option Explicit On
Async Function ValueLater(ByVal value As Integer, ByVal milliseconds As Integer) As Task(Of Integer)
    Await Delay(milliseconds)
    Return value
End Function

Sub Main()
    Dim first = ValueLater(20, 30)
    Dim second = ValueLater(22, 10)
    Wait Until first.IsCompleted() AndAlso second.IsCompleted() Timeout 5000
    Return first.Result() + second.Result()
End Sub
```

**Explication des paramètres et du déroulement:**

ValueLater reçoit value et milliseconds par valeur. Les deux appels démarrent avant lecture : 22 après 10 ms, 20 après 30 ms. Main attend les deux au maximum 5000 ms puis additionne leurs Integer : 42. Wait Until échoue si le délai expire.

### 2. Intercepter une erreur

```vb
# FailLater ne rend aucune valeur et échoue après 5 ms. ReadFailure reçoit l’erreur sur Await, garde le texte et active le drapeau partagé dans Finally. Main attend au plus 5000 ms et rend String "failed:1" ; 1 signifie True. Catch/Finally ne contiennent aucun Await.
Option Explicit On
Module State
    Public Dim cleaned As Boolean = False
End Module

Async Function FailLater() As Task
    Await Delay(5)
    Throw "failed"
End Function

Async Function ReadFailure() As Task(Of String)
    Dim message As String = ""
    Try
        Await FailLater()
    Catch problem
        message = problem
    Finally
        State.cleaned = True
    End Try
    Return message & ":" & CStr(State.cleaned)
End Function

Sub Main()
    Dim task = ReadFailure()
    Wait Until task.IsCompleted() Timeout 5000
    Return task.Result()
End Sub
```

**Explication des paramètres et du déroulement:**

FailLater ne rend aucune valeur et échoue après 5 ms. ReadFailure reçoit l’erreur sur Await, garde le texte et active le drapeau partagé dans Finally. Main attend au plus 5000 ms et rend String "failed:1" ; 1 signifie True. Catch/Finally ne contiennent aucun Await.

### 3. Boucle et transmission du résultat

```vb
# IncrementLater(value) attend 5 ms et rend value+1. SumLater attend séquentiellement i=1..3 en conservant total et i. ForwardResult transmet 9 avec Return Await. Main rend Integer 9, une somme et non un booléen.
Option Explicit On
Async Function IncrementLater(ByVal value As Integer) As Task(Of Integer)
    Await Delay(5)
    Return value + 1
End Function

Async Function SumLater() As Task(Of Integer)
    Dim total As Integer = 0
    For Var i = 1 To 3
        Dim nextValue = Await IncrementLater(i)
        total += nextValue
    Next
    Return total
End Function

Async Function ForwardResult() As Task(Of Integer)
    Return Await SumLater()
End Function

Sub Main()
    Dim task = ForwardResult()
    Wait Until task.IsCompleted() Timeout 5000
    Return task.Result()
End Sub
```

**Explication des paramètres et du déroulement:**

IncrementLater(value) attend 5 ms et rend value+1. SumLater attend séquentiellement i=1..3 en conservant total et i. ForwardResult transmet 9 avec Return Await. Main rend Integer 9, une somme et non un booléen.


### Fonctions internes : de l’appel au résultat

La fonction démarre immédiatement jusqu’au premier Await inachevé. Variables locales, position de boucle, objet With et cadre du débogueur sont conservés puis restaurés. Une tâche déjà terminée ne suspend pas. L’opérande Await est évalué une seule fois.

#### 1. Delay

Delay prend un Integer de 0 à 2147483647 millisecondes. Zéro termine immédiatement ; valeurs négatives, fractions et String déclenchent une erreur interceptable. L’horloge monotone fixe un délai minimal, pas une garantie d’exécution exacte.

due = monotonicNow + milliseconds
return task

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/ScriptAsyncScheduler.cs`; fonction `Delay`.

#### 2. ResolveAwaitTask

Stockez la tâche sans type déclaré ou As Object. Await accepte une tâche de cette exécution : instruction entière, totalité du membre droit d’une déclaration/affectation scalaire ou Return Await. Interdit dans les calculs, conditions, affectations champ/index, Catch/Finally et hors Async Function. Plusieurs consommateurs peuvent attendre la même tâche ; les dépendances cycliques échouent.

validate owner and dependency chain
evaluate operand once

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Async.cs`; fonction `ResolveAwaitTask`.

#### 3. ExecuteSubrutine

La fonction démarre immédiatement jusqu’au premier Await inachevé. Variables locales, position de boucle, objet With et cadre du débogueur sont conservés puis restaurés. Une tâche déjà terminée ne suspend pas. L’opérande Await est évalué une seule fois.

save locals, With receiver, debugger frame
suspend until task completes
restore saved state

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.cs`; fonction `ExecuteSubrutine`.

#### 4. Pump

Le thread du script contrôle les échéances aux points sûrs et reprend au plus 64 continuations par passage. Aucun thread supplémentaire. Wait synchrone ou un long appel natif/du jeu peut retarder les autres tâches ; préférez Await Delay. Limite : 1024 tâches inachevées ou erreurs non observées.

if earliest deadline reached: complete delays
resume at most 64 queued continuations
refresh function results

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/ScriptAsyncScheduler.cs`; fonction `Pump`.

#### 5. GetResult

IsCompleted vaut 1 après réussite, échec ou annulation ; IsFaulted après échec ; IsCanceled après annulation. Ces prédicats Integer acceptent True/False. Result() rend la valeur enregistrée, échoue avant la fin et relance l’erreur d’une tâche échouée. Les tâches d’une exécution précédente sont invalides.

if pending: error
if failed: rethrow
return saved value

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ScriptTaskObject.cs`; fonction `GetResult`.

#### 6. Release

Pause bloque les continuations, mais le temps avance ; reprendre traite celles arrivées à échéance. Stop, erreur ou retour du point d’entrée annule les tâches restantes et libère ressources Using et itérateurs. L’arrêt d’urgence ignore les Catch/Finally du script. Une erreur non observée est signalée à la fin du point d’entrée. Fermer IDE seul n’arrête pas un script actif.

cancel pending tasks
drain cleanup continuations
release resources
report unobserved failure

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/ScriptAsyncScheduler.cs`; fonction `Release`.

Un appel du script à Async Function et Delay rend Object (ScriptTask), pas immédiatement T. Await et Result() rendent T ; As Task et Delay terminent avec Unit, sans valeur. Si le client lance une Async Function comme point d’entrée, il attend de façon coopérative et reçoit le résultat final. Une donnée numérique n’est pas forcément Boolean.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: ASYNC / awaitExpression / taskType
Analysis/AsyncValidator.cs: supported statement forms and signatures
Runtime/Interpreter.cs: ExecuteSubrutine / statement suspension / cleanup
Runtime/Interpreter.Async.cs: ResolveAwaitTask / ResumeAsync / WaitForTask
Runtime/ScriptAsyncScheduler.cs: Delay / Track / Pump / Release
Runtime/ObjectTypes/ScriptTaskObject.cs: GetResult / Complete / Awaiter
Runtime/SemanticScope.cs: SuspendCurrent / Resume
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/modifiers/async
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/operators/await-operator
-->
