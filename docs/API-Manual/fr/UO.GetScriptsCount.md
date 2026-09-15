# UO.GetScriptsCount

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: fr -->

Compte les exécutions actives de ce client.

## Syntaxe exacte

```text
UO.GetScriptsCount() -> Integer
```

## Paramètres

Aucun paramètre.

## Retour

Integer >= 0 : nombre d’exécutions actives, pauses comprises. Un nombre, pas un Boolean ni un indice.

## Comportement

- Les exécutions en cours et en pause sont incluses ; celles terminées ou ayant reçu une annulation sont exclues. Le script appelant se compte normalement lui-même. Un onglet simplement chargé n’est pas une exécution.
- Les indices sont des positions actuelles, ordonnées par lancement. Démarrer/arrêter peut les déplacer. Plusieurs appels ne constituent pas un instantané atomique ; relire avant une commande de contrôle ultérieure.
- Fermer Basic IDE ne supprime pas les exécutions actives. Ces commandes concernent ce client, pas les autres clients ni les processus Windows.
- GetScriptsList donne des indices, GetScriptsCount un nombre et GetScriptState un code à trois états. Ne pas les confondre ni considérer toute valeur non nulle comme true.
- Aucun argument. Le comptage ne trie pas la liste et ne modifie aucun état.

### Fonctions internes : de l’appel au résultat

Voici les véritables méthodes du client. Les exemples Basic contiennent des auxiliaires complets ; les noms internes C# ne sont pas des commandes de script supplémentaires.

#### 1. ExecuteStealthCompatibility

Le runtime appelle la commande UO enregistrée et enveloppe le résultat du pont en Integer, String ou Array.

Integer >= 0 : nombre d’exécutions actives, pauses comprises. Un nombre, pas un Boolean ni un indice.

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; fonction `ExecuteStealthCompatibility`.

#### 2. GetScriptsCount

Le pont utilise le gestionnaire d’exécutions de ce client.

Aucun argument. Le comptage ne trie pas la liste et ne modifie aucun état.

Source du projet: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; fonction `GetScriptsCount`.

#### 3. GetScriptsCount

`_running.Count(entry => !entry.Value.Cancellation.IsCancellationRequested)`

Les indices sont des positions actuelles, ordonnées par lancement. Démarrer/arrêter peut les déplacer. Plusieurs appels ne constituent pas un instantané atomique ; relire avant une commande de contrôle ultérieure.

Source du projet: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; fonction `GetScriptsCount`.

Fermer Basic IDE ne supprime pas les exécutions actives. Ces commandes concernent ce client, pas les autres clients ni les processus Windows.


## Exemples

### Premier appel et résultat

```vb
# Premier appel et résultat
#
# Compte les exécutions actives de ce client.
#
# Integer >= 0 : nombre d’exécutions actives, pauses comprises. Un nombre, pas un Boolean ni un
# indice.

SUB Main()
    # Exécuter Sub Main. Le 0 passé est un indice ; des parenthèses vides indiquent zéro argument.
    # Les textes de Print sont des messages d’exemple.
    # Aucun argument. Le comptage ne trie pas la liste et ne modifie aucun état.
    # Integer >= 0 : nombre d’exécutions actives, pauses comprises. Un nombre, pas un Boolean ni un
    # indice.

    Dim count=UO.GetScriptsCount()
    UO.Print(CStr(count))
END SUB
```

**Explication des paramètres et du déroulement:**

- Exécuter Sub Main. Le 0 passé est un indice ; des parenthèses vides indiquent zéro argument. Les textes de Print sont des messages d’exemple.
- Aucun argument. Le comptage ne trie pas la liste et ne modifie aucun état.
- Integer >= 0 : nombre d’exécutions actives, pauses comprises. Un nombre, pas un Boolean ni un indice.

### Utilisation dans une boucle ou condition

```vb
# Utilisation dans une boucle ou condition
#
# Compte les exécutions actives de ce client.
#
# Integer >= 0 : nombre d’exécutions actives, pauses comprises. Un nombre, pas un Boolean ni un
# indice.

SUB Main()
    # Exemple indépendant combinant plusieurs commandes. Les indices commencent à zéro ; vérifier la
    # longueur avant l’accès. Wait(250), s’il apparaît, attend 250 millisecondes.
    # Aucun argument. Le comptage ne trie pas la liste et ne modifie aucun état.
    # Integer >= 0 : nombre d’exécutions actives, pauses comprises. Un nombre, pas un Boolean ni un
    # indice.

    Dim before=UO.GetScriptsCount()
    Wait(250)
    Dim after=UO.GetScriptsCount()
    UO.Print(CStr(after-before))
END SUB
```

**Explication des paramètres et du déroulement:**

- Exemple indépendant combinant plusieurs commandes. Les indices commencent à zéro ; vérifier la longueur avant l’accès. Wait(250), s’il apparaît, attend 250 millisecondes.
- Aucun argument. Le comptage ne trie pas la liste et ne modifie aucun état.
- Integer >= 0 : nombre d’exécutions actives, pauses comprises. Un nombre, pas un Boolean ni un indice.

### Fonction auxiliaire complète

```vb
# Fonction auxiliaire complète
#
# Compte les exécutions actives de ce client.
#
# Integer >= 0 : nombre d’exécutions actives, pauses comprises. Un nombre, pas un Boolean ni un
# indice.

SUB Main()
    # La fonction complète figure sous Main. Ses paramètres et son résultat sont expliqués
    # séparément de la commande API utilisée.
    # HasOtherScripts compare à 1 car l’appelant occupe normalement une entrée. Seule cette fonction
    # auxiliaire renvoie true/false.
    # Integer >= 0 : nombre d’exécutions actives, pauses comprises. Un nombre, pas un Boolean ni un
    # indice.

    If HasOtherScripts() Then
        UO.Print("Other executions are active")
    Else
        UO.Print("No other active executions")
    End If
END SUB

Function HasOtherScripts() As Boolean
    Dim count=UO.GetScriptsCount()
    Return count > 1
End Function
```

**Explication des paramètres et du déroulement:**

- La fonction complète figure sous Main. Ses paramètres et son résultat sont expliqués séparément de la commande API utilisée.
- HasOtherScripts compare à 1 car l’appelant occupe normalement une entrée. Seule cette fonction auxiliaire renvoie true/false.
- Integer >= 0 : nombre d’exécutions actives, pauses comprises. Un nombre, pas un Boolean ni un indice.
