# Optional

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: fr -->

Les paramètres transmettent des données à SUB/FUNCTION. ByRef réécrit la valeur modifiée chez l’appelant ; ByVal préserve sa variable. Optional fournit un argument omis et ParamArray regroupe les arguments restants. Ce sont des modificateurs de déclaration, pas des commandes appelables.

## Syntaxe exacte

```text
Function Scale(ByVal value, Optional ByVal factor = 2)
Scale(3)
Scale(3, 4)
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

### 1. Facteur omis ou fourni

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

### 2. Moment du calcul par défaut

```vb
# Pick(5) renvoie 5 sans appeler DefaultAmount. Pick() l’appelle une fois : calls=1, valeur 7. Main renvoie 5*100+7*10+1, Integer 571.
Option Explicit On
Module Counter
    Public Var calls = 0
End Module
Function DefaultAmount()
    Counter.calls += 1
    Return 7
End Function
Function Pick(Optional ByVal value = DefaultAmount())
    Return value
End Function
Sub Main()
    Var first = Pick(5)
    Var second = Pick()
    Return first * 100 + second * 10 + Counter.calls
End Sub
```

**Explication des paramètres et du déroulement:**

Pick(5) renvoie 5 sans appeler DefaultAmount. Pick() l’appelle une fois : calls=1, valeur 7. Main renvoie 5*100+7*10+1, Integer 571.

### 3. Optional, ByRef et As Integer

```vb
# value commence à 1. Increase(value) ajoute amount=2 et stocke 3 ; Increase(value,4) ajoute 4 et stocke 7. Les deux paramètres sont Integer. Main renvoie Integer 7.
Option Explicit On
Sub Increase(ByRef value As Integer, Optional ByVal amount As Integer = 2)
    value += amount
End Sub
Sub Main()
    Var value As Integer = 1
    Increase(value)
    Increase(value, 4)
    Return value
End Sub
```

**Explication des paramètres et du déroulement:**

value commence à 1. Increase(value) ajoute amount=2 et stocke 3 ; Increase(value,4) ajoute 4 et stocke 7. Les deux paramètres sont Integer. Main renvoie Integer 7.

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
