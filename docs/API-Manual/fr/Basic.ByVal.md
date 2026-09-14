# ByVal

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: fr -->

Les paramètres transmettent des données à SUB/FUNCTION. ByRef réécrit la valeur modifiée chez l’appelant ; ByVal préserve sa variable. Optional fournit un argument omis et ParamArray regroupe les arguments restants. Ce sont des modificateurs de déclaration, pas des commandes appelables.

## Syntaxe exacte

```text
Sub Change(ByVal value)
Function Increment(ByVal value)
Increment(expression)
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

### 1. Préserver un scalaire

```vb
# Change reçoit une copie de amount=5. L’affectation locale 99 ne modifie pas la variable extérieure. Main renvoie Integer 5.
Option Explicit On
Sub Change(ByVal amount)
    amount = 99
End Sub
Sub Main()
    Var amount = 5
    Change(amount)
    Return amount
End Sub
```

**Explication des paramètres et du déroulement:**

Change reçoit une copie de amount=5. L’affectation locale 99 ne modifie pas la variable extérieure. Main renvoie Integer 5.

### 2. Tableau partagé et ReDim local

```vb
# ByVal partage encore l’élément, qui devient 9. ReDim crée un autre tableau local où seul 20 est écrit. Le tableau extérieur conserve longueur 1 et valeur 9. Main renvoie Integer 91.
Option Explicit On
Sub Change(ByVal items)
    items[0] = 9
    ReDim items[1]
    items[0] = 20
End Sub
Sub Main()
    Dim items[0]
    items[0] = 4
    Change(items)
    Return items[0] * 10 + GetArrayLength(items)
End Sub
```

**Explication des paramètres et du déroulement:**

ByVal partage encore l’élément, qui devient 9. ReDim crée un autre tableau local où seul 20 est écrit. Le tableau extérieur conserve longueur 1 et valeur 9. Main renvoie Integer 91.

### 3. Expression et résultat distinct

```vb
# amount+3 vaut 7. Increment passe sa valeur locale à 8 et la renvoie. amount extérieur reste 4. Main renvoie 4*10+8, Integer 48.
Option Explicit On
Function Increment(ByVal value)
    value += 1
    Return value
End Function
Sub Main()
    Var amount = 4
    Var result = Increment(amount + 3)
    Return amount * 10 + result
End Sub
```

**Explication des paramètres et du déroulement:**

amount+3 vaut 7. Increment passe sa valeur locale à 8 et la renvoie. amount extérieur reste 4. Main renvoie 4*10+8, Integer 48.

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
