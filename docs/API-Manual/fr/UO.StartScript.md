# UO.StartScript

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: fr -->

Charge un fichier Basic et demande sa procédure publique Sub Main.

## Syntaxe exacte

```text
UO.StartScript(ScriptPath:Any) -> Integer
```

## Paramètres

- `ScriptPath` — ScriptPath obligatoire : String. Un chemin relatif part du dossier AutoLoad de ce client ; un chemin absolu est permis. Mettre entre guillemets les chemins contenant des espaces. Le fichier doit utiliser le Basic pris en charge et définir une Sub Main publique sans argument obligatoire.

## Retour

Integer : nombre d’exécutions actives après acceptation du lancement ; 65535 (0xFFFF) = échec. Ce n’est ni le nouvel indice, ni un Boolean, ni un résultat de fin.

## Comportement

- Les exécutions en cours et en pause sont incluses ; celles terminées ou ayant reçu une annulation sont exclues. Le script appelant se compte normalement lui-même. Un onglet simplement chargé n’est pas une exécution.
- Les indices sont des positions actuelles, ordonnées par lancement. Démarrer/arrêter peut les déplacer. Plusieurs appels ne constituent pas un instantané atomique ; relire avant une commande de contrôle ultérieure.
- Fermer Basic IDE ne supprime pas les exécutions actives. Ces commandes concernent ce client, pas les autres clients ni les processus Windows.
- GetScriptsList donne des indices, GetScriptsCount un nombre et GetScriptState un code à trois états. Ne pas les confondre ni considérer toute valeur non nulle comme true.
- Créer séparément les fichiers Worker.bas indiqués avant les exemples. Chemin invalide/illisible, Main inadaptée, Basic désactivé ou parallélisme refusé entraînent un échec. Un arrêt encore en cours peut entraîner une relance différée ; acceptation ne signifie pas fin. Un script bref peut finir avant la lecture du nombre.

### Fonctions internes : de l’appel au résultat

Voici les véritables méthodes du client. Les exemples Basic contiennent des auxiliaires complets ; les noms internes C# ne sont pas des commandes de script supplémentaires.

#### 1. ExecuteStealthCompatibility

Le runtime appelle la commande UO enregistrée et enveloppe le résultat du pont en Integer, String ou Array.

Integer : nombre d’exécutions actives après acceptation du lancement ; 65535 (0xFFFF) = échec. Ce n’est ni le nouvel indice, ni un Boolean, ni un résultat de fin.

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; fonction `ExecuteStealthCompatibility`.

#### 2. StartScript

Le pont utilise le gestionnaire d’exécutions de ce client.

Créer séparément les fichiers Worker.bas indiqués avant les exemples. Chemin invalide/illisible, Main inadaptée, Basic désactivé ou parallélisme refusé entraînent un échec. Un arrêt encore en cours peut entraîner une relance différée ; acceptation ne signifie pas fin. Un script bref peut finir avant la lecture du nombre.

Source du projet: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; fonction `StartScript`.

#### 3. StartScript

`Path.GetFullPath -> File.ReadAllText -> DiscoverProcedures -> SelectFileEntryPoint -> RunProcedure -> GetScriptsCount`

Les indices sont des positions actuelles, ordonnées par lancement. Démarrer/arrêter peut les déplacer. Plusieurs appels ne constituent pas un instantané atomique ; relire avant une commande de contrôle ultérieure.

Source du projet: `src/ClassicUO.Client/Game/Managers/YokoInjectionManager.cs`; fonction `StartScript`.

Fermer Basic IDE ne supprime pas les exécutions actives. Ces commandes concernent ce client, pas les autres clients ni les processus Windows.


## Exemples

### Premier appel et résultat

```vb
# Premier appel et résultat
#
# Charge un fichier Basic et demande sa procédure publique Sub Main.
#
# Integer : nombre d’exécutions actives après acceptation du lancement ; 65535 (0xFFFF) = échec.
# Ce n’est ni le nouvel indice, ni un Boolean, ni un résultat de fin.

SUB Main()
    # Exécuter Sub Main. Le 0 passé est un indice ; des parenthèses vides indiquent zéro argument.
    # Les textes de Print sont des messages d’exemple.
    # Créer séparément les fichiers Worker.bas indiqués avant les exemples. Chemin
    # invalide/illisible, Main inadaptée, Basic désactivé ou parallélisme refusé entraînent un
    # échec. Un arrêt encore en cours peut entraîner une relance différée ; acceptation ne signifie
    # pas fin. Un script bref peut finir avant la lecture du nombre.
    # Integer : nombre d’exécutions actives après acceptation du lancement ; 65535 (0xFFFF) = échec.
    # Ce n’est ni le nouvel indice, ni un Boolean, ni un résultat de fin.
    # ScriptPath obligatoire : String. Un chemin relatif part du dossier AutoLoad de ce client ; un
    # chemin absolu est permis. Mettre entre guillemets les chemins contenant des espaces. Le
    # fichier doit utiliser le Basic pris en charge et définir une Sub Main publique sans argument
    # obligatoire.

    Dim count=UO.StartScript("Scripts/Worker.bas")
    If count=65535 Then
        UO.Print("launch failed")
    Else
        UO.Print("Active executions: " & CStr(count))
    End If
END SUB
```

**Explication des paramètres et du déroulement:**

- Exécuter Sub Main. Le 0 passé est un indice ; des parenthèses vides indiquent zéro argument. Les textes de Print sont des messages d’exemple.
- Créer séparément les fichiers Worker.bas indiqués avant les exemples. Chemin invalide/illisible, Main inadaptée, Basic désactivé ou parallélisme refusé entraînent un échec. Un arrêt encore en cours peut entraîner une relance différée ; acceptation ne signifie pas fin. Un script bref peut finir avant la lecture du nombre.
- Integer : nombre d’exécutions actives après acceptation du lancement ; 65535 (0xFFFF) = échec. Ce n’est ni le nouvel indice, ni un Boolean, ni un résultat de fin.
- ScriptPath obligatoire : String. Un chemin relatif part du dossier AutoLoad de ce client ; un chemin absolu est permis. Mettre entre guillemets les chemins contenant des espaces. Le fichier doit utiliser le Basic pris en charge et définir une Sub Main publique sans argument obligatoire.

### Utilisation dans une boucle ou condition

```vb
# Utilisation dans une boucle ou condition
#
# Charge un fichier Basic et demande sa procédure publique Sub Main.
#
# Integer : nombre d’exécutions actives après acceptation du lancement ; 65535 (0xFFFF) = échec.
# Ce n’est ni le nouvel indice, ni un Boolean, ni un résultat de fin.

SUB Main()
    # Exemple indépendant combinant plusieurs commandes. Les indices commencent à zéro ; vérifier la
    # longueur avant l’accès. Wait(250), s’il apparaît, attend 250 millisecondes.
    # Créer séparément les fichiers Worker.bas indiqués avant les exemples. Chemin
    # invalide/illisible, Main inadaptée, Basic désactivé ou parallélisme refusé entraînent un
    # échec. Un arrêt encore en cours peut entraîner une relance différée ; acceptation ne signifie
    # pas fin. Un script bref peut finir avant la lecture du nombre.
    # Integer : nombre d’exécutions actives après acceptation du lancement ; 65535 (0xFFFF) = échec.
    # Ce n’est ni le nouvel indice, ni un Boolean, ni un résultat de fin.
    # ScriptPath obligatoire : String. Un chemin relatif part du dossier AutoLoad de ce client ; un
    # chemin absolu est permis. Mettre entre guillemets les chemins contenant des espaces. Le
    # fichier doit utiliser le Basic pris en charge et définir une Sub Main publique sans argument
    # obligatoire.

    Dim count=UO.StartScript("Scripts/My Worker.bas")
    If count<>65535 Then
        Dim indices=UO.GetScriptsList()
        For Each index In indices
            UO.Print(CStr(index) & ": " & UO.GetScriptPath(index))
        Next
    End If
END SUB
```

**Explication des paramètres et du déroulement:**

- Exemple indépendant combinant plusieurs commandes. Les indices commencent à zéro ; vérifier la longueur avant l’accès. Wait(250), s’il apparaît, attend 250 millisecondes.
- Créer séparément les fichiers Worker.bas indiqués avant les exemples. Chemin invalide/illisible, Main inadaptée, Basic désactivé ou parallélisme refusé entraînent un échec. Un arrêt encore en cours peut entraîner une relance différée ; acceptation ne signifie pas fin. Un script bref peut finir avant la lecture du nombre.
- Integer : nombre d’exécutions actives après acceptation du lancement ; 65535 (0xFFFF) = échec. Ce n’est ni le nouvel indice, ni un Boolean, ni un résultat de fin.
- ScriptPath obligatoire : String. Un chemin relatif part du dossier AutoLoad de ce client ; un chemin absolu est permis. Mettre entre guillemets les chemins contenant des espaces. Le fichier doit utiliser le Basic pris en charge et définir une Sub Main publique sans argument obligatoire.

### Fonction auxiliaire complète

```vb
# Fonction auxiliaire complète
#
# Charge un fichier Basic et demande sa procédure publique Sub Main.
#
# Integer : nombre d’exécutions actives après acceptation du lancement ; 65535 (0xFFFF) = échec.
# Ce n’est ni le nouvel indice, ni un Boolean, ni un résultat de fin.

SUB Main()
    # La fonction complète figure sous Main. Ses paramètres et son résultat sont expliqués
    # séparément de la commande API utilisée.
    # TryStartBasic compare à 65535 et renvoie true/false. Elle n’attend pas la fin et ne transforme
    # pas le nombre en indice.
    # Integer : nombre d’exécutions actives après acceptation du lancement ; 65535 (0xFFFF) = échec.
    # Ce n’est ni le nouvel indice, ni un Boolean, ni un résultat de fin.
    # ScriptPath obligatoire : String. Un chemin relatif part du dossier AutoLoad de ce client ; un
    # chemin absolu est permis. Mettre entre guillemets les chemins contenant des espaces. Le
    # fichier doit utiliser le Basic pris en charge et définir une Sub Main publique sans argument
    # obligatoire.

    If TryStartBasic("Scripts/Worker.bas") Then
        UO.Print("launch accepted")
    Else
        UO.Print("check file, Main and execution settings")
    End If
END SUB

Function TryStartBasic(fileName) As Boolean
    Dim count=UO.StartScript(fileName)
    Return count<>65535
End Function
```

**Explication des paramètres et du déroulement:**

- La fonction complète figure sous Main. Ses paramètres et son résultat sont expliqués séparément de la commande API utilisée.
- TryStartBasic compare à 65535 et renvoie true/false. Elle n’attend pas la fin et ne transforme pas le nombre en indice.
- Integer : nombre d’exécutions actives après acceptation du lancement ; 65535 (0xFFFF) = échec. Ce n’est ni le nouvel indice, ni un Boolean, ni un résultat de fin.
- ScriptPath obligatoire : String. Un chemin relatif part du dossier AutoLoad de ce client ; un chemin absolu est permis. Mettre entre guillemets les chemins contenant des espaces. Le fichier doit utiliser le Basic pris en charge et définir une Sub Main publique sans argument obligatoire.
