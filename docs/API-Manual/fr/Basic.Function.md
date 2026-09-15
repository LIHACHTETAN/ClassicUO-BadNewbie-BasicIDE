# Function / Return / Exit Function / End Function

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: fr -->

Function définit un auxiliaire qui renvoie une quantité, du texte ou une référence List/Dictionary. Votre fonction se nomme sans UO. ; UO.GetType(item) reste une API du jeu distincte de Function GetType(value).

## Syntaxe exacte

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

## Paramètres

- `name` — Nom insensible à la casse, également variable locale implicite du résultat dans son corps. name lit le résultat ; name(arguments) appelle la fonction, y compris récursivement. Ne redéclarez pas ce résultat avec Dim, Var, Const ou un paramètre.
- `parameters / arguments` — Arguments positionnels et règles de Sub : ByRef implicite, ByVal, Optional et ParamArray en dernier. Voir Basic.Parameters et ses chapitres détaillés. Tools.Calculate(...) qualifie une fonction de module ; Public/Private règlent l’accès.
- `As type` — Annotation facultative : Integer/Long/Short/Byte utilisent Integer du moteur ; Double/Single/Decimal utilisent Double ; String est du texte ; Boolean/Bool normalise en 1/0 ; Object/Variant conserve le genre de valeur. Ce ne sont pas toutes les largeurs numériques VB.NET. Un type inconnu est refusé. Sans As : Variant. Les suffixes de nom ne déduisent pas le type ici.
- `name = expression` — Mémorise le résultat et CONTINUE avec l’instruction suivante. Il peut être relu ou modifié, notamment par +=. Cette variable est locale à cet appel, et non globale ou un nouvel appel.
- `Return / Exit Function / End Function` — Return expression affecte le résultat typé et commence la sortie. Return seul, Exit Function et End Function renvoient le résultat courant. End Function est requis ; Exit Sub dans Function est une erreur de chargement.

## Retour

Le résultat courant est renvoyé après les Finally normaux. Valeurs initiales : Integer 0, Double 0.0, Boolean FALSE/0, String vide ; sans type, Variant/Object commencent avec Unit sans valeur significative. List/Dictionary/Object conservent leurs références. Boolean donne 1/0, comparables à TRUE/FALSE ; une quantité ou un ID n’est pas automatiquement un succès.

## Comportement

- La préparation conserve Function, vérifie type et sorties, lie le résultat local et prépare les instructions une fois. Chaque appel reçoit ses arguments et un résultat typé neuf. L’affectation applique les conversions ordinaires des variables typées.
- Return mémorise le résultat puis traverse les Finally de l’intérieur vers l’extérieur. Ils peuvent encore modifier le résultat. La réécriture ByRef s’achève après une fin réussie. Les erreurs non traitées et les conversions invalides se propagent au lieu de produire un succès.
- La récursion possède paramètres, variables et résultat indépendants : Factorial(n-1) ne remplace pas le résultat appelant. Prévoyez un cas terminal. Aucun thread, délai ni timeout implicite ; pause et arrêt restent contrôlés.
- Les appels de procédures imbriqués sont limités à 32 cadres, callbacks et gestionnaires compris. Un dépassement provoque une erreur interceptable ; utilisez une boucle pour les traitements profonds. Un retour ou une erreur libère le cadre pour les appels suivants.

## Exemples

### 1. Affecter puis continuer

```vb
# TotalPrice reçoit count et price ByVal, résultat Integer. Une valeur négative renvoie immédiatement -1. Sinon count*price est mémorisé puis augmenté de 2. Les appels (3,4) et (-1,4) donnent 14 et -1 ; Main renvoie 14:-1. Le code -1 est choisi par cet auxiliaire.
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

**Explication des paramètres et du déroulement:**

TotalPrice reçoit count et price ByVal, résultat Integer. Une valeur négative renvoie immédiatement -1. Sinon count*price est mémorisé puis augmenté de 2. Les appels (3,4) et (-1,4) donnent 14 et -1 ; Main renvoie 14:-1. Le code -1 est choisi par cet auxiliaire.

### 2. Résultat récursif indépendant

```vb
# Factorial reçoit n ByVal et initialise son résultat à 1. n<=1 déclenche Exit Function avec 1. Sinon le produit n*Factorial(n-1) utilise un nouvel appel. Pour les petites entrées non négatives de l’exemple, 5!+3!=120+6=126. Les valeurs négatives prennent aussi le cas terminal ; le domaine mathématique complet n’est pas validé.
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

**Explication des paramètres et du déroulement:**

Factorial reçoit n ByVal et initialise son résultat à 1. n<=1 déclenche Exit Function avec 1. Sinon le produit n*Factorial(n-1) utilise un nouvel appel. Pour les petites entrées non négatives de l’exemple, 5!+3!=120+6=126. Les valeurs négatives prennent aussi le cas terminal ; le domaine mathématique complet n’est pas validé.

### 3. Return et deux Finally

```vb
# Calculate reçoit trace ByRef. Return 1 fixe le résultat et lance la sortie. Le Finally intérieur transforme résultat et trace de 1 en 12, puis l’extérieur en 123. Main reçoit les deux 123 et renvoie 123:123. Finally modifie donc la valeur même après Return expression ; aucun mouvement de jeu n’est simulé.
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

**Explication des paramètres et du déroulement:**

Calculate reçoit trace ByRef. Return 1 fixe le résultat et lance la sortie. Le Finally intérieur transforme résultat et trace de 1 en 12, puis l’extérieur en 123. Main reçoit les deux 123 et renvoie 123:123. Finally modifie donc la valeur même après Return expression ; aucun mouvement de jeu n’est simulé.

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
