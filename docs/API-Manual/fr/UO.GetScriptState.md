# UO.GetScriptState

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: fr -->

Lit l’état d’exécution associé à un indice.

## Syntaxe exacte

```text
UO.GetScriptState(ScriptIndex:Any) -> Integer
```

## Paramètres

- `ScriptIndex` — ScriptIndex obligatoire : entier à partir de zéro issu d’un GetScriptsList récent. Un indice négatif ou absent donne le résultat vide/inconnu documenté. Ne pas fournir un serial d’objet, un nom de procédure ou un identifiant d’exécution IDE.

## Retour

Code Integer : 0 = absent/inconnu, 1 = en cours, 2 = en pause. Ce n’est pas un Boolean : comparer explicitement à 1 ou 2.

## Comportement

- Les exécutions en cours et en pause sont incluses ; celles terminées ou ayant reçu une annulation sont exclues. Le script appelant se compte normalement lui-même. Un onglet simplement chargé n’est pas une exécution.
- Les indices sont des positions actuelles, ordonnées par lancement. Démarrer/arrêter peut les déplacer. Plusieurs appels ne constituent pas un instantané atomique ; relire avant une commande de contrôle ultérieure.
- Fermer Basic IDE ne supprime pas les exécutions actives. Ces commandes concernent ce client, pas les autres clients ni les processus Windows.
- GetScriptsList donne des indices, GetScriptsCount un nombre et GetScriptState un code à trois états. Ne pas les confondre ni considérer toute valeur non nulle comme true.
- La pause manuelle/du débogueur et la pause configurée à la déconnexion sont incluses. L’état 1 ne garantit ni une activité CPU instantanée ni la réception de données serveur.

### Fonctions internes : de l’appel au résultat

Voici les véritables méthodes du client. Les exemples Basic contiennent des auxiliaires complets ; les noms internes C# ne sont pas des commandes de script supplémentaires.

#### 1. ExecuteStealthCompatibility

Le runtime appelle la commande UO enregistrée et enveloppe le résultat du pont en Integer, String ou Array.

Code Integer : 0 = absent/inconnu, 1 = en cours, 2 = en pause. Ce n’est pas un Boolean : comparer explicitement à 1 ou 2.

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; fonction `ExecuteStealthCompatibility`.

#### 2. GetScriptState

Le pont utilise le gestionnaire d’exécutions de ce client.

La pause manuelle/du débogueur et la pause configurée à la déconnexion sont incluses. L’état 1 ne garantit ni une activité CPU instantanée ni la réception de données serveur.

Source du projet: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; fonction `GetScriptState`.

#### 3. GetScriptState

`script == null ? 0 : script.IsPaused ? 2 : 1`

Les indices sont des positions actuelles, ordonnées par lancement. Démarrer/arrêter peut les déplacer. Plusieurs appels ne constituent pas un instantané atomique ; relire avant une commande de contrôle ultérieure.

Source du projet: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; fonction `GetScriptState`.

Fermer Basic IDE ne supprime pas les exécutions actives. Ces commandes concernent ce client, pas les autres clients ni les processus Windows.


## Exemples

### Premier appel et résultat

```vb
# Premier appel et résultat
#
# Lit l’état d’exécution associé à un indice.
#
# Code Integer : 0 = absent/inconnu, 1 = en cours, 2 = en pause. Ce n’est pas un Boolean :
# comparer explicitement à 1 ou 2.

SUB Main()
    # Exécuter Sub Main. Le 0 passé est un indice ; des parenthèses vides indiquent zéro argument.
    # Les textes de Print sont des messages d’exemple.
    # La pause manuelle/du débogueur et la pause configurée à la déconnexion sont incluses. L’état 1
    # ne garantit ni une activité CPU instantanée ni la réception de données serveur.
    # Code Integer : 0 = absent/inconnu, 1 = en cours, 2 = en pause. Ce n’est pas un Boolean :
    # comparer explicitement à 1 ou 2.
    # ScriptIndex obligatoire : entier à partir de zéro issu d’un GetScriptsList récent. Un indice
    # négatif ou absent donne le résultat vide/inconnu documenté. Ne pas fournir un serial d’objet,
    # un nom de procédure ou un identifiant d’exécution IDE.

    Dim state=UO.GetScriptState(0)
    Select Case state
    Case 1
        UO.Print("running")
    Case 2
        UO.Print("paused")
    Case Else
        UO.Print("unknown")
    End Select
END SUB
```

**Explication des paramètres et du déroulement:**

- Exécuter Sub Main. Le 0 passé est un indice ; des parenthèses vides indiquent zéro argument. Les textes de Print sont des messages d’exemple.
- La pause manuelle/du débogueur et la pause configurée à la déconnexion sont incluses. L’état 1 ne garantit ni une activité CPU instantanée ni la réception de données serveur.
- Code Integer : 0 = absent/inconnu, 1 = en cours, 2 = en pause. Ce n’est pas un Boolean : comparer explicitement à 1 ou 2.
- ScriptIndex obligatoire : entier à partir de zéro issu d’un GetScriptsList récent. Un indice négatif ou absent donne le résultat vide/inconnu documenté. Ne pas fournir un serial d’objet, un nom de procédure ou un identifiant d’exécution IDE.

### Utilisation dans une boucle ou condition

```vb
# Utilisation dans une boucle ou condition
#
# Lit l’état d’exécution associé à un indice.
#
# Code Integer : 0 = absent/inconnu, 1 = en cours, 2 = en pause. Ce n’est pas un Boolean :
# comparer explicitement à 1 ou 2.

SUB Main()
    # Exemple indépendant combinant plusieurs commandes. Les indices commencent à zéro ; vérifier la
    # longueur avant l’accès. Wait(250), s’il apparaît, attend 250 millisecondes.
    # La pause manuelle/du débogueur et la pause configurée à la déconnexion sont incluses. L’état 1
    # ne garantit ni une activité CPU instantanée ni la réception de données serveur.
    # Code Integer : 0 = absent/inconnu, 1 = en cours, 2 = en pause. Ce n’est pas un Boolean :
    # comparer explicitement à 1 ou 2.
    # ScriptIndex obligatoire : entier à partir de zéro issu d’un GetScriptsList récent. Un indice
    # négatif ou absent donne le résultat vide/inconnu documenté. Ne pas fournir un serial d’objet,
    # un nom de procédure ou un identifiant d’exécution IDE.

    Dim paused=0
    Dim indices=UO.GetScriptsList()
    For Each index In indices
        If UO.GetScriptState(index)=2 Then
            paused+=1
        End If
    Next
    UO.Print(CStr(paused))
END SUB
```

**Explication des paramètres et du déroulement:**

- Exemple indépendant combinant plusieurs commandes. Les indices commencent à zéro ; vérifier la longueur avant l’accès. Wait(250), s’il apparaît, attend 250 millisecondes.
- La pause manuelle/du débogueur et la pause configurée à la déconnexion sont incluses. L’état 1 ne garantit ni une activité CPU instantanée ni la réception de données serveur.
- Code Integer : 0 = absent/inconnu, 1 = en cours, 2 = en pause. Ce n’est pas un Boolean : comparer explicitement à 1 ou 2.
- ScriptIndex obligatoire : entier à partir de zéro issu d’un GetScriptsList récent. Un indice négatif ou absent donne le résultat vide/inconnu documenté. Ne pas fournir un serial d’objet, un nom de procédure ou un identifiant d’exécution IDE.

### Fonction auxiliaire complète

```vb
# Fonction auxiliaire complète
#
# Lit l’état d’exécution associé à un indice.
#
# Code Integer : 0 = absent/inconnu, 1 = en cours, 2 = en pause. Ce n’est pas un Boolean :
# comparer explicitement à 1 ou 2.

SUB Main()
    # La fonction complète figure sous Main. Ses paramètres et son résultat sont expliqués
    # séparément de la commande API utilisée.
    # IsScriptActive transforme 1 et 2 en true, et 0 en false. GetScriptState conserve son résultat
    # numérique.
    # Code Integer : 0 = absent/inconnu, 1 = en cours, 2 = en pause. Ce n’est pas un Boolean :
    # comparer explicitement à 1 ou 2.
    # ScriptIndex obligatoire : entier à partir de zéro issu d’un GetScriptsList récent. Un indice
    # négatif ou absent donne le résultat vide/inconnu documenté. Ne pas fournir un serial d’objet,
    # un nom de procédure ou un identifiant d’exécution IDE.

    If IsScriptActive(0)=True Then
        UO.Print("running or paused")
    Else
        UO.Print("not active")
    End If
END SUB

Function IsScriptActive(index) As Boolean
    Dim state=UO.GetScriptState(index)
    Return state=1 OrElse state=2
End Function
```

**Explication des paramètres et du déroulement:**

- La fonction complète figure sous Main. Ses paramètres et son résultat sont expliqués séparément de la commande API utilisée.
- IsScriptActive transforme 1 et 2 en true, et 0 en false. GetScriptState conserve son résultat numérique.
- Code Integer : 0 = absent/inconnu, 1 = en cours, 2 = en pause. Ce n’est pas un Boolean : comparer explicitement à 1 ou 2.
- ScriptIndex obligatoire : entier à partir de zéro issu d’un GetScriptsList récent. Un indice négatif ou absent donne le résultat vide/inconnu documenté. Ne pas fournir un serial d’objet, un nom de procédure ou un identifiant d’exécution IDE.
