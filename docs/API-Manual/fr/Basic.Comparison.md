# =, ==, <>, <, >, <=, >=

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: fr -->

Les opérateurs de comparaison testent deux valeurs et produisent un résultat logique, utilisable dans IF, une variable ou le RETURN d’une fonction auxiliaire.

## Syntaxe exacte

```text
left = right
left == right
left <> right
left < right
left > right
left <= right
left >= right
```

## Paramètres

- `left` — Valeur gauche : littéral, variable déclarée, expression ou résultat de fonction.
- `right` — Valeur droite. L’ordre exige des nombres Integer ou Decimal ; l’égalité accepte aussi les autres types de valeurs.
- `operator` — = et == testent l’égalité dans une expression ; <> l’inégalité ; < et > l’ordre strict ; <= et >= incluent l’égalité. Une instruction séparée name = expression effectue une affectation.

## Retour

Integer 1 (TRUE) si la comparaison est vraie, sinon Integer 0 (FALSE). Pour ce résultat, result=1 équivaut à result=TRUE et result=0 à result=FALSE. Une quantité ou un ID a un autre sens : 2 est non nul, mais 2=TRUE est faux. Utilisez count<>0 pour tester une quantité non nulle.

## Comportement

- Integer et Decimal se comparent numériquement : 5=5.0 est vrai. Le texte ne se convertit pas : "5"=5 est faux. L’égalité des chaînes est ordinale et sensible à la casse : "Ore"<>"ore". Ordonner du texte, des tableaux, des objets ou Unit avec <, >, <=, >= provoque une erreur.
- L’égalité des tableaux et objets natifs compare leur identité, pas leur contenu. Deux Unit sont égaux, mais Unit n’est pas le zéro numérique. Les types différents sont inégaux sauf la paire numérique Integer/Decimal. NaN est inégal à lui-même et toutes ses comparaisons numériques d’ordre sont fausses.
- L’arithmétique précède la comparaison. Les chaînes sont évaluées de gauche à droite : 1<3<2 signifie (1<3)<2 et est vrai. Pour un intervalle, écrire (low<=value) AND (value<=high). Les parenthèses rendent le groupement explicite.
- La virgule flottante binaire peut arrondir. Pour des mesures approchées, utiliser Abs(actual-expected)<=tolerance avec une tolérance non négative appropriée. La tolérance appartient au script, elle n’est pas intégrée aux opérateurs.
- = compare le même type déclaré et ses champs ; <> donne l’inverse. Les références sont comparées par identité. Il s’agit d’une extension du moteur, pas d’une règle universelle de VB.NET. Les hachages conservés et les paires déjà visitées évitent de développer plusieurs fois les mêmes valeurs imbriquées.

## Exemples

### 1. Intervalle inclusif et TRUE

```vb
# InRange reçoit value=4, low=2, high=5. Les deux comparaisons valent 1 ; AND les combine en 1 ; Main teste accepted=TRUE et renvoie 1. La fonction et son appel sont complets.
Option Explicit On
FUNCTION InRange(value, low, high)
    RETURN (low <= value) AND (value <= high)
END FUNCTION
SUB Main()
    VAR accepted = InRange(4, 2, 5)
    IF accepted = TRUE THEN
        RETURN 1
    END IF
    RETURN 0
END SUB
```

**Explication des paramètres et du déroulement:**

InRange reçoit value=4, low=2, high=5. Les deux comparaisons valent 1 ; AND les combine en 1 ; Main teste accepted=TRUE et renvoie 1. La fonction et son appel sont complets.

### 2. Texte, nombres et casse

```vb
# sameCase compare "Ore" à "ore" et vaut 0. sameKind compare "5" à Integer 5 et vaut 0. converted appelle explicitement CDbl("5") et vaut 1. CStr forme le diagnostic renvoyé "0:0:1".
Option Explicit On
SUB Main()
    VAR sameCase = ("Ore" = "ore")
    VAR sameKind = ("5" == 5)
    VAR converted = (CDbl("5") = 5)
    RETURN CStr(sameCase) + ":" + CStr(sameKind) + ":" + CStr(converted)
END SUB
```

**Explication des paramètres et du déroulement:**

sameCase compare "Ore" à "ore" et vaut 0. sameKind compare "5" à Integer 5 et vaut 0. converted appelle explicitement CDbl("5") et vaut 1. CStr forme le diagnostic renvoyé "0:0:1".

### 3. Égalité décimale approchée

```vb
# NearlyEqual reçoit 0.1+0.2, expected=0.3, tolerance=0.000001. Une tolérance négative est rejetée. Abs mesure la différence ; <= accepte un écart dans la tolérance. Main renvoie 1. Tous les paramètres de la fonction sont explicites.
Option Explicit On
FUNCTION NearlyEqual(actual, expected, tolerance)
    IF tolerance < 0 THEN
        RETURN FALSE
    END IF
    RETURN Abs(actual - expected) <= tolerance
END FUNCTION
SUB Main()
    RETURN NearlyEqual(0.1 + 0.2, 0.3, 0.000001)
END SUB
```

**Explication des paramètres et du déroulement:**

NearlyEqual reçoit 0.1+0.2, expected=0.3, tolerance=0.000001. Une tolérance négative est rejetée. Abs mesure la différence ; <= accepte un écart dans la tolérance. Main renvoie 1. Tous les paramètres de la fonction sont explicites.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: logicalOperand / comparativeOperation
Runtime/Interpreter.cs: VisitLogicalOperand
Runtime/InjectionValue.cs: Equals / comparison operators
-->
