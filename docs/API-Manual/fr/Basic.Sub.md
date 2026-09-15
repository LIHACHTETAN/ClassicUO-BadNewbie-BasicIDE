# Sub / Call / Exit Sub / End Sub

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: fr -->

Sub regroupe des instructions dans une procédure nommée, utile pour traiter des objets, vérifier des données ou terminer une opération. Un appel est synchrone dans le script actuel et ne lance pas un autre script en arrière-plan.

## Syntaxe exacte

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

## Paramètres

- `name` — Identifiant insensible à la casse, sans UO. pour votre code. Un membre de module se nomme Tools.Work(...). Public/Private règlent son accès : voir Basic.Module et Basic.Visibility.
- `parameters / arguments` — Déclarez les paramètres entre parenthèses et passez les arguments dans leur ordre. ByRef est implicite ; ByVal copie la valeur, Optional fournit la valeur omise et le dernier ParamArray rassemble les arguments supplémentaires. Les cinq chapitres de paramètres précisent types, tableaux, références partagées et réécriture.
- `statements / End Sub` — Le corps peut être vide, mais End Sub est requis. Chaque appel possède ses variables locales, même en récursion. Déclarez les procédures au niveau du fichier ou du module, pas dans une autre procédure.
- `Call` — name(arguments) fonctionne sans Call. Call name arguments accepte aussi la forme sans parenthèses ; Call name invoque une procédure sans paramètres. Call ignore une valeur renvoyée. Les expressions des arguments gardent leur sens habituel.
- `Exit Sub / Return` — Exit Sub ou Return seul termine cet appel. Return expression dans Sub est une extension de compatibilité Basic, absente de Sub en VB.NET. Exit Function dans Sub est une erreur de chargement.

## Retour

End Sub, Exit Sub et Return seul donnent Unit : aucun résultat significatif, ni succès booléen ni ID. Un ancien Sub Basic peut renvoyer expression avec Return. ByRef peut modifier séparément une variable appelante. Préférez Function pour calculer un résultat.

## Comportement

- La préparation normalise les en-têtes compatibles et Call, valide le bloc et résout les noms. Les arguments sont évalués et liés avant l’entrée. Les appels réutilisent les instructions préparées, mais pas les valeurs locales.
- L’interpréteur crée la portée, exécute le corps et revient après l’appel. Une sortie normale ou Exit Sub exécute les Finally quittés avant de terminer la réécriture des paramètres. Une exception suit le gestionnaire actif ; un appel échoué ne signifie pas réussite.
- Les contrôles de pause et d’arrêt restent actifs. Aucun nouveau thread, délai ou timeout automatique n’est créé. La récursion exige un cas terminal. L’affectation au nom de Sub ne définit pas son résultat : utilisez Function.
- Les appels de procédures imbriqués sont limités à 32 cadres, callbacks et gestionnaires compris. Un dépassement provoque une erreur interceptable ; utilisez une boucle pour les traitements profonds. Un retour ou une erreur libère le cadre pour les appels suivants.

## Exemples

### 1. Trois formes d’appel

```vb
# total commence à 4. AddAmount reçoit total ByRef ; amount omis vaut 1 et les valeurs explicites 3 et 2 sont ByVal. Les trois écritures appellent le même code. Le total devient 4+1+3+2=10, que Main renvoie explicitement.
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

**Explication des paramètres et du déroulement:**

total commence à 4. AddAmount reçoit total ByRef ; amount omis vaut 1 et les valeurs explicites 3 et 2 sont ByVal. Les trois écritures appellent le même code. Le total devient 4+1+3+2=10, que Main renvoie explicitement.

### 2. Entrée publique et auxiliaire privé

```vb
# Batches.SumInto reçoit total ByRef et regroupe 3,-9,4 dans values. For Each appelle AppendAmount. Le nombre négatif déclenche Exit Sub uniquement dans cet auxiliaire ; la boucle continue. Depuis 2, le résultat est 2+3+4=9. Le code extérieur emploie le nom public qualifié.
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

**Explication des paramètres et du déroulement:**

Batches.SumInto reçoit total ByRef et regroupe 3,-9,4 dans values. For Each appelle AppendAmount. Le nombre négatif déclenche Exit Sub uniquement dans cet auxiliaire ; la boucle continue. Depuis 2, le résultat est 2+3+4=9. Le code extérieur emploie le nom public qualifié.

### 3. Sortie et nettoyage

```vb
# Finish affecte trace=1 puis quitte ; trace=99 est ignoré. Finally ajoute le chiffre 2 : trace=12 revient par ByRef. LegacyValue illustre Return 7 dans un Sub Basic. Main renvoie 12*10+7=127. Les chiffres de trace appartiennent à cet exemple, pas aux codes du jeu.
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

**Explication des paramètres et du déroulement:**

Finish affecte trace=1 puis quitte ; trace=99 est ignoré. Finally ajoute le chiffre 2 : trace=12 revient par ByRef. LegacyValue illustre Return 7 dans un Sub Basic. Main renvoie 12*10+7=127. Les chiffres de trace appartiennent à cet exemple, pas aux codes du jeu.

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
