# Parameters / ByRef / ByVal / Optional / ParamArray

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: fr -->

Les paramètres transmettent des données à SUB/FUNCTION. ByRef réécrit la valeur modifiée chez l’appelant ; ByVal préserve sa variable. Optional fournit un argument omis et ParamArray regroupe les arguments restants. Ce sont des modificateurs de déclaration, pas des commandes appelables.

## Syntaxe exacte

```text
Sub name(ByRef target, ByVal value, Optional ByVal amount = 2, ParamArray rest())
Function name(parameters) As type
name(arguments)
```

## Paramètres

- `name / As type` — name / As type: Nom du paramètre et conversion facultative du type entrant avec As. Association par position ou name:=value ; les modificateurs appartiennent à la déclaration. Voir Basic.NamedArguments.
- `ByRef` — ByRef : variable modifiable ou élément indexé existant. Sans ByVal, ce moteur effectue aussi une réécriture, contrairement au défaut VB.NET. Littéraux, constantes et expressions calculées sont temporaires.
- `ByVal` — ByVal : copie locale de la valeur. Affecter le paramètre ne remplace pas la variable appelante. Tableaux et objets partagent toujours leurs références, sans copie profonde.
- `Optional / defaultValue` — Optional / defaultValue : omettre un argument final évalue son expression après =. Fournissez une valeur explicite ; sans elle, le paramètre omis reçoit Unit non initialisé.
- `ParamArray` — ParamArray values() : dernier paramètre recevant zéro ou plusieurs valeurs restantes. Un seul tableau est réutilisé ; les scalaires créent un nouveau tableau. GetArrayLength renvoie sa longueur.

## Retour

Les modificateurs ne renvoient rien. RETURN fixe séparément le résultat. ByRef modifie un argument, pas ce résultat. SUB sans RETURN produit Unit. Les nombres des exemples sont des calculs, pas des indicateurs TRUE/FALSE.

## Comportement

- Les arguments sont évalués une fois, de gauche à droite. ByRef indexé capture conteneur et index/clé ; réaffecter la variable du conteneur dans un autre argument ne redirige pas la réécriture.
- Les paramètres locaux sont créés à l’entrée. À la sortie, après les FINALLY internes, ByRef est réécrit dans l’ordre des paramètres, même lorsqu’une erreur quitte le corps. Deux paramètres recevant la même variable ne sont pas liés en direct : la dernière réécriture gagne.
- ByVal empêche de remplacer la variable appelante mais autorise la mutation du tableau ou objet partagé. ReDim crée une nouvelle référence locale. Des données indépendantes exigent une copie explicite.
- Pour les appels positionnels : Omettez les arguments Optional à partir de la fin ; les positions vides entre virgules sont interdites. Les valeurs par défaut peuvent être des expressions du moteur, évaluées à chaque omission, sans être des constantes VB.NET. Placez les arguments positionnels avant les nommés ; après le premier nommé, tous doivent être nommés. Aucun paramètre obligatoire ne peut manquer. Les Optional omis du script prennent leurs valeurs déclarées, évaluées dans l’ordre de déclaration après les expressions fournies. Les surcharges natives gardent leurs noms et arités enregistrés, sans valeurs par défaut inventées.
- ParamArray ne réécrit pas les scalaires regroupés. Modifier un tableau fourni explicitement est visible chez l’appelant. Le transmettre à un autre ParamArray ne rajoute pas de niveau.
- Écrivez ByRef et ByVal explicitement. Ces règles concernent les procédures utilisateur appelées par le script ; les commandes intégrées ont leurs propres fiches.
- ParamArray ne peut être fourni par nom. Il peut rester vide avec des arguments nommés ; ses valeurs demandent un appel entièrement positionnel. Les emplacements vides entre virgules ne sont pas pris en charge. Ce sous-ensemble exige les positionnels d’abord, sans mélange libre des VB.NET récents. Aucun thread ni délai de jeu ajouté.

## Exemples

### 1. Modifier une variable

```vb
# Adjust reçoit amount=5 par ByRef et increment=3 par ByVal. amount devient 8 puis est réécrit. Main renvoie Integer 8 ; Adjust ne renvoie rien.
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

**Explication des paramètres et du déroulement:**

Adjust reçoit amount=5 par ByRef et increment=3 par ByVal. amount devient 8 puis est réécrit. Main renvoie Integer 8 ; Adjust ne renvoie rien.

### 2. Facteur omis ou fourni

```vb
# Scale(3) utilise factor=2 et renvoie 6. Scale(3,4) utilise 4 et renvoie 12. Main renvoie 6*100+12, Integer 612.
Option Explicit On
Function Scale(ByVal value, Optional ByVal factor = 2)
    Return value * factor
End Function
Sub Main()
    Return Scale(3) * 100 + Scale(3, 4)
End Sub
```

**Explication des paramètres et du déroulement:**

Scale(3) utilise factor=2 et renvoie 6. Scale(3,4) utilise 4 et renvoie 12. Main renvoie 6*100+12, Integer 612.

### 3. Ensemble vide ou rempli

```vb
# Sum() reçoit un tableau vide et renvoie 0. Sum(2,3,4) reçoit trois valeurs et renvoie 9. For Each les parcourt. Main renvoie Integer 9.
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

**Explication des paramètres et du déroulement:**

Sum() reçoit un tableau vide et renvoie 0. Sum(2,3,4) reçoit trois valeurs et renvoie 9. For Each les parcourt. Main renvoie Integer 9.

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
