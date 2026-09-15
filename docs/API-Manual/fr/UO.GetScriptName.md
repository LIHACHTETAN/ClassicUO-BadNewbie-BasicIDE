# UO.GetScriptName

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: fr -->

Lit le nom affiché d’une exécution active.

## Syntaxe exacte

```text
UO.GetScriptName(ScriptIndex:Any) -> String
```

## Paramètres

- `ScriptIndex` — ScriptIndex obligatoire : entier à partir de zéro issu d’un GetScriptsList récent. Un indice négatif ou absent donne le résultat vide/inconnu documenté. Ne pas fournir un serial d’objet, un nom de procédure ou un identifiant d’exécution IDE.

## Retour

String : nom affiché, ou "" si l’indice manque. Une exécution existante peut aussi avoir un nom explicitement vide.

## Comportement

- Les exécutions en cours et en pause sont incluses ; celles terminées ou ayant reçu une annulation sont exclues. Le script appelant se compte normalement lui-même. Un onglet simplement chargé n’est pas une exécution.
- Les indices sont des positions actuelles, ordonnées par lancement. Démarrer/arrêter peut les déplacer. Plusieurs appels ne constituent pas un instantané atomique ; relire avant une commande de contrôle ultérieure.
- Fermer Basic IDE ne supprime pas les exécutions actives. Ces commandes concernent ce client, pas les autres clients ni les processus Windows.
- GetScriptsList donne des indices, GetScriptsCount un nombre et GetScriptState un code à trois états. Ne pas les confondre ni considérer toute valeur non nulle comme true.
- ScriptIndex=0 désigne la première exécution actuelle, pas nécessairement l’appelant. SetScriptName change le nom affiché sans renommer le fichier.

### Fonctions internes : de l’appel au résultat

Voici les véritables méthodes du client. Les exemples Basic contiennent des auxiliaires complets ; les noms internes C# ne sont pas des commandes de script supplémentaires.

#### 1. ExecuteStealthCompatibility

Le runtime appelle la commande UO enregistrée et enveloppe le résultat du pont en Integer, String ou Array.

String : nom affiché, ou "" si l’indice manque. Une exécution existante peut aussi avoir un nom explicitement vide.

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; fonction `ExecuteStealthCompatibility`.

#### 2. GetScriptName

Le pont utilise le gestionnaire d’exécutions de ce client.

ScriptIndex=0 désigne la première exécution actuelle, pas nécessairement l’appelant. SetScriptName change le nom affiché sans renommer le fichier.

Source du projet: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; fonction `GetScriptName`.

#### 3. GetScriptName

`ElementAt(RunningScripts(), index)?.Name ?? string.Empty`

Les indices sont des positions actuelles, ordonnées par lancement. Démarrer/arrêter peut les déplacer. Plusieurs appels ne constituent pas un instantané atomique ; relire avant une commande de contrôle ultérieure.

Source du projet: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; fonction `GetScriptName`.

Fermer Basic IDE ne supprime pas les exécutions actives. Ces commandes concernent ce client, pas les autres clients ni les processus Windows.


## Exemples

### Premier appel et résultat

```vb
# Premier appel et résultat
#
# Lit le nom affiché d’une exécution active.
#
# String : nom affiché, ou "" si l’indice manque. Une exécution existante peut aussi avoir un
# nom explicitement vide.

SUB Main()
    # Exécuter Sub Main. Le 0 passé est un indice ; des parenthèses vides indiquent zéro argument.
    # Les textes de Print sont des messages d’exemple.
    # ScriptIndex=0 désigne la première exécution actuelle, pas nécessairement l’appelant.
    # SetScriptName change le nom affiché sans renommer le fichier.
    # String : nom affiché, ou "" si l’indice manque. Une exécution existante peut aussi avoir un
    # nom explicitement vide.
    # ScriptIndex obligatoire : entier à partir de zéro issu d’un GetScriptsList récent. Un indice
    # négatif ou absent donne le résultat vide/inconnu documenté. Ne pas fournir un serial d’objet,
    # un nom de procédure ou un identifiant d’exécution IDE.

    Dim index=0
    Dim name=UO.GetScriptName(index)
    UO.Print(name)
END SUB
```

**Explication des paramètres et du déroulement:**

- Exécuter Sub Main. Le 0 passé est un indice ; des parenthèses vides indiquent zéro argument. Les textes de Print sont des messages d’exemple.
- ScriptIndex=0 désigne la première exécution actuelle, pas nécessairement l’appelant. SetScriptName change le nom affiché sans renommer le fichier.
- String : nom affiché, ou "" si l’indice manque. Une exécution existante peut aussi avoir un nom explicitement vide.
- ScriptIndex obligatoire : entier à partir de zéro issu d’un GetScriptsList récent. Un indice négatif ou absent donne le résultat vide/inconnu documenté. Ne pas fournir un serial d’objet, un nom de procédure ou un identifiant d’exécution IDE.

### Utilisation dans une boucle ou condition

```vb
# Utilisation dans une boucle ou condition
#
# Lit le nom affiché d’une exécution active.
#
# String : nom affiché, ou "" si l’indice manque. Une exécution existante peut aussi avoir un
# nom explicitement vide.

SUB Main()
    # Exemple indépendant combinant plusieurs commandes. Les indices commencent à zéro ; vérifier la
    # longueur avant l’accès. Wait(250), s’il apparaît, attend 250 millisecondes.
    # ScriptIndex=0 désigne la première exécution actuelle, pas nécessairement l’appelant.
    # SetScriptName change le nom affiché sans renommer le fichier.
    # String : nom affiché, ou "" si l’indice manque. Une exécution existante peut aussi avoir un
    # nom explicitement vide.
    # ScriptIndex obligatoire : entier à partir de zéro issu d’un GetScriptsList récent. Un indice
    # négatif ou absent donne le résultat vide/inconnu documenté. Ne pas fournir un serial d’objet,
    # un nom de procédure ou un identifiant d’exécution IDE.

    Dim indices=UO.GetScriptsList()
    For Each index In indices
        Dim name=UO.GetScriptName(index)
        UO.Print(CStr(index) & " = " & name)
    Next
END SUB
```

**Explication des paramètres et du déroulement:**

- Exemple indépendant combinant plusieurs commandes. Les indices commencent à zéro ; vérifier la longueur avant l’accès. Wait(250), s’il apparaît, attend 250 millisecondes.
- ScriptIndex=0 désigne la première exécution actuelle, pas nécessairement l’appelant. SetScriptName change le nom affiché sans renommer le fichier.
- String : nom affiché, ou "" si l’indice manque. Une exécution existante peut aussi avoir un nom explicitement vide.
- ScriptIndex obligatoire : entier à partir de zéro issu d’un GetScriptsList récent. Un indice négatif ou absent donne le résultat vide/inconnu documenté. Ne pas fournir un serial d’objet, un nom de procédure ou un identifiant d’exécution IDE.

### Fonction auxiliaire complète

```vb
# Fonction auxiliaire complète
#
# Lit le nom affiché d’une exécution active.
#
# String : nom affiché, ou "" si l’indice manque. Une exécution existante peut aussi avoir un
# nom explicitement vide.

SUB Main()
    # La fonction complète figure sous Main. Ses paramètres et son résultat sont expliqués
    # séparément de la commande API utilisée.
    # DescribeScript vérifie l’état puis joint nom et chemin. Un arrêt peut intervenir entre les
    # appels ; "missing" vient de l’auxiliaire, pas de GetScriptName.
    # String : nom affiché, ou "" si l’indice manque. Une exécution existante peut aussi avoir un
    # nom explicitement vide.
    # ScriptIndex obligatoire : entier à partir de zéro issu d’un GetScriptsList récent. Un indice
    # négatif ou absent donne le résultat vide/inconnu documenté. Ne pas fournir un serial d’objet,
    # un nom de procédure ou un identifiant d’exécution IDE.

    UO.Print(DescribeScript(0))
END SUB

Function DescribeScript(index) As String
    If UO.GetScriptState(index)=0 Then
        Return "missing"
    End If
    Return UO.GetScriptName(index) & " | " & UO.GetScriptPath(index)
End Function
```

**Explication des paramètres et du déroulement:**

- La fonction complète figure sous Main. Ses paramètres et son résultat sont expliqués séparément de la commande API utilisée.
- DescribeScript vérifie l’état puis joint nom et chemin. Un arrêt peut intervenir entre les appels ; "missing" vient de l’auxiliaire, pas de GetScriptName.
- String : nom affiché, ou "" si l’indice manque. Une exécution existante peut aussi avoir un nom explicitement vide.
- ScriptIndex obligatoire : entier à partir de zéro issu d’un GetScriptsList récent. Un indice négatif ou absent donne le résultat vide/inconnu documenté. Ne pas fournir un serial d’objet, un nom de procédure ou un identifiant d’exécution IDE.
