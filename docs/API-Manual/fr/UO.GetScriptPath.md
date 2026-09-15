# UO.GetScriptPath

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: fr -->

Lit le chemin du fichier source d’une exécution active.

## Syntaxe exacte

```text
UO.GetScriptPath(ScriptIndex:Any) -> String
```

## Paramètres

- `ScriptIndex` — ScriptIndex obligatoire : entier à partir de zéro issu d’un GetScriptsList récent. Un indice négatif ou absent donne le résultat vide/inconnu documenté. Ne pas fournir un serial d’objet, un nom de procédure ou un identifiant d’exécution IDE.

## Retour

String : chemin source enregistré, ou "" si l’indice manque. Un lancement de fichier possède normalement un chemin complet ; une commande ou un texte en mémoire peut ne pas avoir de fichier ordinaire.

## Comportement

- Les exécutions en cours et en pause sont incluses ; celles terminées ou ayant reçu une annulation sont exclues. Le script appelant se compte normalement lui-même. Un onglet simplement chargé n’est pas une exécution.
- Les indices sont des positions actuelles, ordonnées par lancement. Démarrer/arrêter peut les déplacer. Plusieurs appels ne constituent pas un instantané atomique ; relire avant une commande de contrôle ultérieure.
- Fermer Basic IDE ne supprime pas les exécutions actives. Ces commandes concernent ce client, pas les autres clients ni les processus Windows.
- GetScriptsList donne des indices, GetScriptsCount un nombre et GetScriptState un code à trois états. Ne pas les confondre ni considérer toute valeur non nulle comme true.
- ScriptIndex=0 sélectionne la première exécution actuelle. Le getter identifie la source ; il ne l’ouvre, ne l’enregistre et ne l’exécute pas.

### Fonctions internes : de l’appel au résultat

Voici les véritables méthodes du client. Les exemples Basic contiennent des auxiliaires complets ; les noms internes C# ne sont pas des commandes de script supplémentaires.

#### 1. ExecuteStealthCompatibility

Le runtime appelle la commande UO enregistrée et enveloppe le résultat du pont en Integer, String ou Array.

String : chemin source enregistré, ou "" si l’indice manque. Un lancement de fichier possède normalement un chemin complet ; une commande ou un texte en mémoire peut ne pas avoir de fichier ordinaire.

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; fonction `ExecuteStealthCompatibility`.

#### 2. GetScriptPath

Le pont utilise le gestionnaire d’exécutions de ce client.

ScriptIndex=0 sélectionne la première exécution actuelle. Le getter identifie la source ; il ne l’ouvre, ne l’enregistre et ne l’exécute pas.

Source du projet: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; fonction `GetScriptPath`.

#### 3. GetScriptPath

`ElementAt(RunningScripts(), index)?.FilePath ?? string.Empty`

Les indices sont des positions actuelles, ordonnées par lancement. Démarrer/arrêter peut les déplacer. Plusieurs appels ne constituent pas un instantané atomique ; relire avant une commande de contrôle ultérieure.

Source du projet: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; fonction `GetScriptPath`.

Fermer Basic IDE ne supprime pas les exécutions actives. Ces commandes concernent ce client, pas les autres clients ni les processus Windows.


## Exemples

### Premier appel et résultat

```vb
# Premier appel et résultat
#
# Lit le chemin du fichier source d’une exécution active.
#
# String : chemin source enregistré, ou "" si l’indice manque. Un lancement de fichier possède
# normalement un chemin complet ; une commande ou un texte en mémoire peut ne pas avoir de
# fichier ordinaire.

SUB Main()
    # Exécuter Sub Main. Le 0 passé est un indice ; des parenthèses vides indiquent zéro argument.
    # Les textes de Print sont des messages d’exemple.
    # ScriptIndex=0 sélectionne la première exécution actuelle. Le getter identifie la source ; il
    # ne l’ouvre, ne l’enregistre et ne l’exécute pas.
    # String : chemin source enregistré, ou "" si l’indice manque. Un lancement de fichier possède
    # normalement un chemin complet ; une commande ou un texte en mémoire peut ne pas avoir de
    # fichier ordinaire.
    # ScriptIndex obligatoire : entier à partir de zéro issu d’un GetScriptsList récent. Un indice
    # négatif ou absent donne le résultat vide/inconnu documenté. Ne pas fournir un serial d’objet,
    # un nom de procédure ou un identifiant d’exécution IDE.

    Dim index=0
    Dim path=UO.GetScriptPath(index)
    If path<>"" Then
        UO.Print(path)
    End If
END SUB
```

**Explication des paramètres et du déroulement:**

- Exécuter Sub Main. Le 0 passé est un indice ; des parenthèses vides indiquent zéro argument. Les textes de Print sont des messages d’exemple.
- ScriptIndex=0 sélectionne la première exécution actuelle. Le getter identifie la source ; il ne l’ouvre, ne l’enregistre et ne l’exécute pas.
- String : chemin source enregistré, ou "" si l’indice manque. Un lancement de fichier possède normalement un chemin complet ; une commande ou un texte en mémoire peut ne pas avoir de fichier ordinaire.
- ScriptIndex obligatoire : entier à partir de zéro issu d’un GetScriptsList récent. Un indice négatif ou absent donne le résultat vide/inconnu documenté. Ne pas fournir un serial d’objet, un nom de procédure ou un identifiant d’exécution IDE.

### Utilisation dans une boucle ou condition

```vb
# Utilisation dans une boucle ou condition
#
# Lit le chemin du fichier source d’une exécution active.
#
# String : chemin source enregistré, ou "" si l’indice manque. Un lancement de fichier possède
# normalement un chemin complet ; une commande ou un texte en mémoire peut ne pas avoir de
# fichier ordinaire.

SUB Main()
    # Exemple indépendant combinant plusieurs commandes. Les indices commencent à zéro ; vérifier la
    # longueur avant l’accès. Wait(250), s’il apparaît, attend 250 millisecondes.
    # ScriptIndex=0 sélectionne la première exécution actuelle. Le getter identifie la source ; il
    # ne l’ouvre, ne l’enregistre et ne l’exécute pas.
    # String : chemin source enregistré, ou "" si l’indice manque. Un lancement de fichier possède
    # normalement un chemin complet ; une commande ou un texte en mémoire peut ne pas avoir de
    # fichier ordinaire.
    # ScriptIndex obligatoire : entier à partir de zéro issu d’un GetScriptsList récent. Un indice
    # négatif ou absent donne le résultat vide/inconnu documenté. Ne pas fournir un serial d’objet,
    # un nom de procédure ou un identifiant d’exécution IDE.

    Dim indices=UO.GetScriptsList()
    For Each index In indices
        UO.Print(UO.GetScriptName(index) & " -> " & UO.GetScriptPath(index))
    Next
END SUB
```

**Explication des paramètres et du déroulement:**

- Exemple indépendant combinant plusieurs commandes. Les indices commencent à zéro ; vérifier la longueur avant l’accès. Wait(250), s’il apparaît, attend 250 millisecondes.
- ScriptIndex=0 sélectionne la première exécution actuelle. Le getter identifie la source ; il ne l’ouvre, ne l’enregistre et ne l’exécute pas.
- String : chemin source enregistré, ou "" si l’indice manque. Un lancement de fichier possède normalement un chemin complet ; une commande ou un texte en mémoire peut ne pas avoir de fichier ordinaire.
- ScriptIndex obligatoire : entier à partir de zéro issu d’un GetScriptsList récent. Un indice négatif ou absent donne le résultat vide/inconnu documenté. Ne pas fournir un serial d’objet, un nom de procédure ou un identifiant d’exécution IDE.

### Fonction auxiliaire complète

```vb
# Fonction auxiliaire complète
#
# Lit le chemin du fichier source d’une exécution active.
#
# String : chemin source enregistré, ou "" si l’indice manque. Un lancement de fichier possède
# normalement un chemin complet ; une commande ou un texte en mémoire peut ne pas avoir de
# fichier ordinaire.

SUB Main()
    # La fonction complète figure sous Main. Ses paramètres et son résultat sont expliqués
    # séparément de la commande API utilisée.
    # ReadScriptPath utilise fallback seulement si le chemin est vide. Ce n’est pas une nouvelle
    # surcharge de GetScriptPath.
    # String : chemin source enregistré, ou "" si l’indice manque. Un lancement de fichier possède
    # normalement un chemin complet ; une commande ou un texte en mémoire peut ne pas avoir de
    # fichier ordinaire.
    # ScriptIndex obligatoire : entier à partir de zéro issu d’un GetScriptsList récent. Un indice
    # négatif ou absent donne le résultat vide/inconnu documenté. Ne pas fournir un serial d’objet,
    # un nom de procédure ou un identifiant d’exécution IDE.

    UO.Print(ReadScriptPath(0, "path unavailable"))
END SUB

Function ReadScriptPath(index, fallback) As String
    Dim path=UO.GetScriptPath(index)
    If path="" Then
        Return fallback
    End If
    Return path
End Function
```

**Explication des paramètres et du déroulement:**

- La fonction complète figure sous Main. Ses paramètres et son résultat sont expliqués séparément de la commande API utilisée.
- ReadScriptPath utilise fallback seulement si le chemin est vide. Ce n’est pas une nouvelle surcharge de GetScriptPath.
- String : chemin source enregistré, ou "" si l’indice manque. Un lancement de fichier possède normalement un chemin complet ; une commande ou un texte en mémoire peut ne pas avoir de fichier ordinaire.
- ScriptIndex obligatoire : entier à partir de zéro issu d’un GetScriptsList récent. Un indice négatif ou absent donne le résultat vide/inconnu documenté. Ne pas fournir un serial d’objet, un nom de procédure ou un identifiant d’exécution IDE.
