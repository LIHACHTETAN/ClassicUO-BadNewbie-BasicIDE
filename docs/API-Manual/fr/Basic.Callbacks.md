# AddressOf / callbacks

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: fr -->

AddressOf conserve une référence vers une Sub ou Function du script sans l’appeler. Transmettez cette référence à une procédure, retournez-la depuis une fonction ou stockez-la dans une collection pour choisir une règle de traitement.

## Syntaxe exacte

```text
Dim callback = AddressOf ProcedureName
Dim callback As Object = AddressOf Tools.FunctionName
callback(arguments)
callback.Invoke(arguments)
Process(values, AddressOf Predicate)
```

## Paramètres

- `ProcedureName` — Nom d’une procédure déclarée, éventuellement qualifié par Module. Une seule déclaration doit correspondre. Nom inconnu, membre Private inaccessible et surcharges sont refusés avant exécution. Pour une fonction Basic native ou une commande UO, écrivez une fonction intermédiaire au nom unique. Aucune parenthèse après le nom avec AddressOf.
- `callback / arguments` — callback est un Object. callback(...) et callback.Invoke(...) exécutent la procédure de façon synchrone dans le thread du script. Les arguments nommés utilisent les vrais noms des paramètres. Affectez d’abord un élément de collection à une variable. La référence est capturée avant les expressions des arguments, même si elles modifient callback.
- `ByRef / ByVal / Optional / ParamArray` — ByVal copie la valeur ou référence ; ByRef réécrit les modifications ; Optional calcule les valeurs omises ; ParamArray rassemble les arguments positionnels. Les arguments nommés suivent les positionnels ; les valeurs ParamArray exigent un appel entièrement positionnel. Noms ou nombre incorrects échouent avant les effets des arguments.

## Retour

AddressOf renvoie une référence Object, ni ID, ni adresse mémoire, ni Boolean, ni résultat de fonction. L’appel d’une Function renvoie son résultat ; une Sub sans expression Return ne renvoie aucune valeur (Unit). IsPositive renvoie 1/True ou 0/False. Main renvoie String dans les exemples 1 et 3, Integer 15 dans le deuxième.

## Comportement

- La référence ne capture pas les variables locales de la fabrique : ce n’est ni une lambda ni une fermeture. Elle appartient au script chargé ; un autre interpréteur ou un script rechargé ne peut pas appeler un ancien objet. Une fabrique Public peut délibérément exposer son propre auxiliaire Private.
- La préparation vérifie nom et accès. L’interpréteur mémorise une référence immuable par emplacement AddressOf. Chaque appel lit la variable actuelle, valide la signature, évalue une fois les arguments dans l’ordre écrit et entre dans un cadre de procédure normal. ByRef et exceptions suivent les règles des appels directs.
- Aucun thread ni minuteur supplémentaire. Pause et annulation utilisent les points de contrôle du script, y compris dans les boucles du rappel. Les erreurs atteignent Catch/Finally de l’appelant ; Catch n’absorbe pas l’arrêt d’urgence. Les appels natifs bloquants gardent leurs propres limites d’annulation.
- Déclarations de types Delegate, lambdas, pointeurs DLL et références à des surcharges ne sont pas pris en charge ici. AddressOf est sans préfixe UO. ; les commandes de jeu dans la fonction intermédiaire gardent UO.

## Exemples

### 1. Filtrer avec un prédicat

```vb
# values est la List source ; predicate est AddressOf IsPositive. FilterValues appelle predicate(number) une fois par nombre. Seuls 4 et 7 sont positifs : selected.Count() vaut 2 et selected[0] vaut 4. Main renvoie "2:4". Les deux auxiliaires sont entièrement fournis dans le script et ne sont pas des commandes API supplémentaires.
Option Explicit On
Function IsPositive(ByVal number) As Boolean
    Return number > 0
End Function

Function FilterValues(ByVal values, ByVal predicate)
    Dim result = List()
    For Each number In values
        If predicate(number) Then
            result.Add(number)
        End If
    Next
    Return result
End Function

Sub Main()
    Dim numbers = List()
    numbers.Add(-2)
    numbers.Add(4)
    numbers.Add(7)
    Dim selected = FilterValues(numbers, AddressOf IsPositive)
    Return CStr(selected.Count()) & ":" & CStr(selected[0])
End Sub
```

**Explication des paramètres et du déroulement:**

values est la List source ; predicate est AddressOf IsPositive. FilterValues appelle predicate(number) une fois par nombre. Seuls 4 et 7 sont positifs : selected.Count() vaut 2 et selected[0] vaut 4. Main renvoie "2:4". Les deux auxiliaires sont entièrement fournis dans le script et ne sont pas des commandes API supplémentaires.

### 2. Modifier la variable appelante

```vb
# AddAmount reçoit total ByRef et amount ByVal avec défaut 1. update(total) fait passer 10 à 11 ; Invoke avec amount:=4 et total:=total associe les noms et fait passer 11 à 15. ByRef réécrit la variable initiale. La Sub ne renvoie rien ; Main renvoie Integer 15, pas Boolean.
Option Explicit On
Sub AddAmount(ByRef total As Integer, Optional ByVal amount = 1)
    total += amount
End Sub

Sub Main()
    Dim update = AddressOf AddAmount
    Dim total = 10
    update(total)
    update.Invoke(amount:=4, total:=total)
    Return total
End Sub
```

**Explication des paramètres et du déroulement:**

AddAmount reçoit total ByRef et amount ByVal avec défaut 1. update(total) fait passer 10 à 11 ; Invoke avec amount:=4 et total:=total associe les noms et fait passer 11 à 15. ByRef réécrit la variable initiale. La Sub ne renvoie rien ; Main renvoie Integer 15, pas Boolean.

### 3. Exposer une règle privée

```vb
# Rules.Create fournit une référence à Private CheckedDouble ; AddressOf Rules.CheckedDouble directement depuis l’extérieur est interdit. operation(6) renvoie 12. operation(-1) lève "negative" avant affectation : result reste 12. Catch lit le message, Finally ajoute ":done". Main renvoie "12:negative:done". Fermer l’IDE n’arrête pas le script.
Option Explicit On
Module Rules
    Private Function CheckedDouble(ByVal number) As Integer
        If number < 0 Then
            Throw "negative"
        End If
        Return number * 2
    End Function

    Public Function Create()
        Return AddressOf CheckedDouble
    End Function
End Module

Sub Main()
    Dim operation = Rules.Create()
    Dim result = operation(6)
    Dim message = ""
    Try
        result = operation(-1)
    Catch problem
        message = problem
    Finally
        message = message & ":done"
    End Try
    Return CStr(result) & ":" & message
End Sub
```

**Explication des paramètres et du déroulement:**

Rules.Create fournit une référence à Private CheckedDouble ; AddressOf Rules.CheckedDouble directement depuis l’extérieur est interdit. operation(6) renvoie 12. operation(-1) lève "negative" avant affectation : result reste 12. Catch lit le message, Finally ajoute ":done". Main renvoie "12:negative:done". Fermer l’IDE n’arrête pas le script.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: addressOf / ADDRESSOF
Runtime/Metadata.cs: TryGetCallbackTarget
Analysis/InvalidSymbolVisitor.cs: VisitAddressOf
Runtime/Interpreter.Callbacks.cs: VisitAddressOf / TryGetCallback / CallCallback
Runtime/Interpreter.cs: CreateArgumentWriter / CallSubrutine
Runtime/NamedArgumentBinding.cs: TryCreate
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/operators/addressof-operator
-->
