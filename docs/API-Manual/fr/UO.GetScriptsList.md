# UO.GetScriptsList

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: fr -->

Renvoie les indices numériques actuels des scripts.

## Syntaxe exacte

```text
UO.GetScriptsList() -> Array
```

## Paramètres

Aucun paramètre.

## Retour

Array de Integer : indices 0..N-1, ou tableau vide. Les éléments sont numériques, pas des noms ou des enregistrements textuels.

## Comportement

- Les exécutions en cours et en pause sont incluses ; celles terminées ou ayant reçu une annulation sont exclues. Le script appelant se compte normalement lui-même. Un onglet simplement chargé n’est pas une exécution.
- Les indices sont des positions actuelles, ordonnées par lancement. Démarrer/arrêter peut les déplacer. Plusieurs appels ne constituent pas un instantané atomique ; relire avant une commande de contrôle ultérieure.
- Fermer Basic IDE ne supprime pas les exécutions actives. Ces commandes concernent ce client, pas les autres clients ni les processus Windows.
- GetScriptsList donne des indices, GetScriptsCount un nombre et GetScriptState un code à trois états. Ne pas les confondre ni considérer toute valeur non nulle comme true.
- Aucun argument. Passer chaque élément numérique au getter de nom, chemin ou état. Modifier le tableau renvoyé ne contrôle pas les scripts.

### Fonctions internes : de l’appel au résultat

Voici les véritables méthodes du client. Les exemples Basic contiennent des auxiliaires complets ; les noms internes C# ne sont pas des commandes de script supplémentaires.

#### 1. ExecuteStealthCompatibility

Le runtime appelle la commande UO enregistrée et enveloppe le résultat du pont en Integer, String ou Array.

Array de Integer : indices 0..N-1, ou tableau vide. Les éléments sont numériques, pas des noms ou des enregistrements textuels.

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; fonction `ExecuteStealthCompatibility`.

#### 2. GetScriptsList

Le pont utilise le gestionnaire d’exécutions de ce client.

Aucun argument. Passer chaque élément numérique au getter de nom, chemin ou état. Modifier le tableau renvoyé ne contrôle pas les scripts.

Source du projet: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; fonction `GetScriptsList`.

#### 3. GetScriptsList

`Enumerable.Range(0, GetScriptsCount()).ToArray()`

Les indices sont des positions actuelles, ordonnées par lancement. Démarrer/arrêter peut les déplacer. Plusieurs appels ne constituent pas un instantané atomique ; relire avant une commande de contrôle ultérieure.

Source du projet: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; fonction `GetScriptsList`.

Fermer Basic IDE ne supprime pas les exécutions actives. Ces commandes concernent ce client, pas les autres clients ni les processus Windows.


## Exemples

### Premier appel et résultat

```vb
# Premier appel et résultat
#
# Renvoie les indices numériques actuels des scripts.
#
# Array de Integer : indices 0..N-1, ou tableau vide. Les éléments sont numériques, pas des noms
# ou des enregistrements textuels.

SUB Main()
    # Exécuter Sub Main. Le 0 passé est un indice ; des parenthèses vides indiquent zéro argument.
    # Les textes de Print sont des messages d’exemple.
    # Aucun argument. Passer chaque élément numérique au getter de nom, chemin ou état. Modifier le
    # tableau renvoyé ne contrôle pas les scripts.
    # Array de Integer : indices 0..N-1, ou tableau vide. Les éléments sont numériques, pas des noms
    # ou des enregistrements textuels.

    Dim indices=UO.GetScriptsList()
    For Each index In indices
        UO.Print(CStr(index) & ": " & UO.GetScriptName(index))
    Next
END SUB
```

**Explication des paramètres et du déroulement:**

- Exécuter Sub Main. Le 0 passé est un indice ; des parenthèses vides indiquent zéro argument. Les textes de Print sont des messages d’exemple.
- Aucun argument. Passer chaque élément numérique au getter de nom, chemin ou état. Modifier le tableau renvoyé ne contrôle pas les scripts.
- Array de Integer : indices 0..N-1, ou tableau vide. Les éléments sont numériques, pas des noms ou des enregistrements textuels.

### Utilisation dans une boucle ou condition

```vb
# Utilisation dans une boucle ou condition
#
# Renvoie les indices numériques actuels des scripts.
#
# Array de Integer : indices 0..N-1, ou tableau vide. Les éléments sont numériques, pas des noms
# ou des enregistrements textuels.

SUB Main()
    # Exemple indépendant combinant plusieurs commandes. Les indices commencent à zéro ; vérifier la
    # longueur avant l’accès. Wait(250), s’il apparaît, attend 250 millisecondes.
    # Aucun argument. Passer chaque élément numérique au getter de nom, chemin ou état. Modifier le
    # tableau renvoyé ne contrôle pas les scripts.
    # Array de Integer : indices 0..N-1, ou tableau vide. Les éléments sont numériques, pas des noms
    # ou des enregistrements textuels.

    Dim indices=UO.GetScriptsList()
    If GetArrayLength(indices)>0 Then
        Dim firstIndex=indices[0]
        UO.Print(UO.GetScriptPath(firstIndex))
    End If
END SUB
```

**Explication des paramètres et du déroulement:**

- Exemple indépendant combinant plusieurs commandes. Les indices commencent à zéro ; vérifier la longueur avant l’accès. Wait(250), s’il apparaît, attend 250 millisecondes.
- Aucun argument. Passer chaque élément numérique au getter de nom, chemin ou état. Modifier le tableau renvoyé ne contrôle pas les scripts.
- Array de Integer : indices 0..N-1, ou tableau vide. Les éléments sont numériques, pas des noms ou des enregistrements textuels.

### Fonction auxiliaire complète

```vb
# Fonction auxiliaire complète
#
# Renvoie les indices numériques actuels des scripts.
#
# Array de Integer : indices 0..N-1, ou tableau vide. Les éléments sont numériques, pas des noms
# ou des enregistrements textuels.

SUB Main()
    # La fonction complète figure sous Main. Ses paramètres et son résultat sont expliqués
    # séparément de la commande API utilisée.
    # FindNamedScript renvoie le premier indice actuel au nom affiché exactement égal, ou -1. Les
    # noms peuvent être identiques et les indices changer ensuite.
    # Array de Integer : indices 0..N-1, ou tableau vide. Les éléments sont numériques, pas des noms
    # ou des enregistrements textuels.

    Dim index=FindNamedScript("Mining")
    If index>=0 Then
        UO.Print(CStr(index))
    Else
        UO.Print("Name not found")
    End If
END SUB

Function FindNamedScript(wanted) As Integer
    Dim indices=UO.GetScriptsList()
    For Each index In indices
        If UO.GetScriptName(index)=wanted Then
            Return index
        End If
    Next
    Return -1
End Function
```

**Explication des paramètres et du déroulement:**

- La fonction complète figure sous Main. Ses paramètres et son résultat sont expliqués séparément de la commande API utilisée.
- FindNamedScript renvoie le premier indice actuel au nom affiché exactement égal, ou -1. Les noms peuvent être identiques et les indices changer ensuite.
- Array de Integer : indices 0..N-1, ou tableau vide. Les éléments sont numériques, pas des noms ou des enregistrements textuels.
