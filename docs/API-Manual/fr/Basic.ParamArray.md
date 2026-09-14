# ParamArray

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: fr -->

Les paramètres transmettent des données à SUB/FUNCTION. ByRef réécrit la valeur modifiée chez l’appelant ; ByVal préserve sa variable. Optional fournit un argument omis et ParamArray regroupe les arguments restants. Ce sont des modificateurs de déclaration, pas des commandes appelables.

## Syntaxe exacte

```text
Function Sum(ParamArray values())
Sum()
Sum(2, 3, 4)
Sum(existingArray)
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

### 1. Ensemble vide ou rempli

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

### 2. Transmettre un tableau existant

```vb
# values contient 2 et 5. Forward transmet ce tableau à Sum sans enveloppe supplémentaire. Sum renvoie leur somme, Integer 7.
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

**Explication des paramètres et du déroulement:**

values contient 2 et 5. Forward transmet ce tableau à Sum sans enveloppe supplémentaire. Sum renvoie leur somme, Integer 7.

### 3. Scalaires et tableau fourni

```vb
# SetFirst(first,second) modifie un nouveau tableau, préservant first=2 et second=3. SetFirst(packed) passe packed[0] partagé de 4 à 9. Main renvoie 2*100+3*10+9, Integer 239.
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

**Explication des paramètres et du déroulement:**

SetFirst(first,second) modifie un nouveau tableau, préservant first=2 et second=3. SetFirst(packed) passe packed[0] partagé de 4 à 9. Main renvoie 2*100+3*10+9, Integer 239.

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
