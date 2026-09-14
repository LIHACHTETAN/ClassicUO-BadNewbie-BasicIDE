# Named arguments / :=

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: fr -->

Les arguments nommés associent les valeurs aux paramètres déclarés, indépendamment de leur ordre. Ils fonctionnent avec les procédures et fonctions du script, les modules, les fonctions Basic/UO enregistrées et les méthodes natives.

## Syntaxe exacte

```text
FunctionName(parameterName:=expression, otherName:=expression)
FunctionName(positionalExpression, optionalName:=expression)
FunctionName([reservedName]:=expression)
```

## Paramètres

- `parameterName / [reservedName]` — Utilisez name:=valeur avec le nom de la déclaration ou signature, sans distinction de casse. Encadrez un nom réservé : [to]:=100. Ces crochets ne sont pas un indice de tableau. Les noms inconnus ou répétés sont des erreurs.
- `expression` — Chaque expression fournie est évaluée une fois, de gauche à droite, puis affectée au paramètre correspondant. Types, limites et règles ByVal/ByRef restent ceux de la fonction. La notation ne transforme pas une valeur en variable modifiable.
- `positionalExpression / optionalName` — Placez les arguments positionnels avant les nommés ; après le premier nommé, tous doivent être nommés. Aucun paramètre obligatoire ne peut manquer. Les Optional omis du script prennent leurs valeurs déclarées, évaluées dans l’ordre de déclaration après les expressions fournies. Les surcharges natives gardent leurs noms et arités enregistrés, sans valeurs par défaut inventées.

## Retour

:= ne renvoie rien séparément. La fonction/API conserve son propre résultat ; Sub n’a pas de résultat implicite. Les exemples renvoient Integer 129 et les Strings "21:12", "20:10:2", pas des indicateurs Boolean.

## Comportement

- La préparation signale SC027 avec la position source pour un nom invalide, un doublon, un paramètre obligatoire absent ou une ambiguïté. Les objets dynamiques sont vérifiés à l’exécution avant leurs expressions d’arguments. Aucune surcharge native correspondante ne signifie pas un repli vers un appel sans argument.
- Les associations immuables des sites statiques sont mises en cache. Évaluation dans l’ordre écrit, affectation et retour ByRef par paramètre. Valeurs par défaut et paramètres du débogueur correspondent à la signature retenue. Chaque appel capture son objet dynamique, sans réutiliser l’objet précédent.
- ParamArray ne peut être fourni par nom. Il peut rester vide avec des arguments nommés ; ses valeurs demandent un appel entièrement positionnel. Les emplacements vides entre virgules ne sont pas pris en charge. Ce sous-ensemble exige les positionnels d’abord, sans mélange libre des VB.NET récents. Aucun thread ni délai de jeu ajouté.

## Exemples

### 1. Omettre un Optional central

```vb
# Encode déclare x, y=2, z=3. z:=9 puis x:=1 fournissent les paramètres extérieurs ; y garde 2. Calcul : 1*100+2*10+9=129. Équivalents : Encode(1,2,9) et Encode(1,z:=9).
Option Explicit On
Function Encode(ByVal x, Optional ByVal y=2, Optional ByVal z=3) As Integer
    Return x*100 + y*10 + z
End Function

Sub Main()
    Dim encoded = Encode(z:=9, x:=1)
    Return encoded
End Sub
```

**Explication des paramètres et du déroulement:**

Encode déclare x, y=2, z=3. z:=9 puis x:=1 fournissent les paramètres extérieurs ; y garde 2. Calcul : 1*100+2*10+9=129. Équivalents : Encode(1,2,9) et Encode(1,z:=9).

### 2. Modifier les bonnes variables ByRef

```vb
# Change déclare ByRef left et right. right:=a associe a=1 à right ; left:=b associe b=2 à left. Les additions de 10 à left et 20 à right réécrivent b=12 et a=21. Main renvoie "21:12". À gauche de :=, le paramètre ; à droite, la variable appelante.
Option Explicit On
Sub Change(ByRef left, ByRef right)
    left += 10
    right += 20
End Sub

Sub Main()
    Dim a = 1
    Dim b = 2
    Change(right:=a, left:=b)
    Return CStr(a) & ":" & CStr(b)
End Sub
```

**Explication des paramètres et du déroulement:**

Change déclare ByRef left et right. right:=a associe a=1 à right ; left:=b associe b=2 à left. Les additions de 10 à left et 20 à right réécrivent b=12 et a=21. Main renvoie "21:12". À gauche de :=, le paramètre ; à droite, la variable appelante.

### 3. Collection native et opérandes nommés

```vb
# List() crée la liste. Add(value:=10) ajoute 10 sans résultat. Insert(value:=20,index:=0) insère 20 à l’indice 0 et déplace 10 à l’indice 1. Item(index:=...) renvoie l’élément, Count() renvoie 2. Main produit "20:10:2". UO.Name(...) emploie les mêmes règles avec ses noms enregistrés et son résultat propre.
Option Explicit On
Sub Main()
    Dim items = List()
    items.Add(value:=10)
    items.Insert(value:=20, index:=0)
    Dim first = items.Item(index:=0)
    Dim second = items.Item(index:=1)
    Return CStr(first) & ":" & CStr(second) & ":" & CStr(items.Count())
End Sub
```

**Explication des paramètres et du déroulement:**

List() crée la liste. Add(value:=10) ajoute 10 sans résultat. Insert(value:=20,index:=0) insère 20 à l’indice 0 et déplace 10 à l’indice 1. Item(index:=...) renvoie l’élément, Count() renvoie 2. Main produit "20:10:2". UO.Name(...) emploie les mêmes règles avec ses noms enregistrés et son résultat propre.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: argument
Runtime/NamedArgumentBinding.cs: TryCreate / TryCustom
Runtime/Interpreter.NamedArguments.cs: CallNamed
Runtime/Interpreter.cs: CallSubrutine / CreateArgumentWriter
Analysis/NamedArgumentsValidator.cs
https://learn.microsoft.com/en-us/dotnet/visual-basic/programming-guide/language-features/procedures/passing-arguments-by-position-and-by-name
-->
