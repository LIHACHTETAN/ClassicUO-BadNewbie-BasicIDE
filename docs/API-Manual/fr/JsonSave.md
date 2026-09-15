# JsonSave

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: fr -->

Enregistre une valeur dans un fichier JSON.

## Syntaxe exacte

```text
JsonSave(fileName:String, value:Any) -> Unit
JsonSave(fileName:String, value:Any, indented:Integer) -> Unit
```

## Paramètres

- `fileName` — Chemin obligatoire. Les chemins relatifs partent du dossier du script principal, même depuis Include. Chemins absolus acceptés.
- `value` — Nombre, String, tableau, List, Dictionary, JsonBoolean ou JsonNull. Clés de Dictionary obligatoirement String. Références partagées acceptées, cycles refusés.
- `indented` — Indicateur Integer:0 compact, autre valeur avec indentation. Défaut:Stringify=0, Save=1.

## Retour

Unit: aucun résultat. Une fin normale signifie réussite; erreurs avec Try/Catch.

## Comportement

- Fonctions locales Basic sans UO., sans paquets de jeu. JsonParse/JsonStringify travaillent en mémoire. Basic True devient le nombre1; JsonBoolean(True) produit JSON true. JsonNull() distingue null de0.
- Nombres finis seulement. Valeurs entières hors ±9007199254740991 refusées; stocker les grands ID en Strings. Autres nombres: précision Double. UTF-8 strict: BOM accepté en entrée, absent en sortie. Unicode incorrect: erreur.
- Limites:1048576 unités UTF-16,4Mio de données,64 conteneurs imbriqués,100000 nœuds. Dépassement: erreur. Lecture/analyse crée de nouvelles collections; sauvegarder ne clone pas les objets mémoire.
- Save valide tout, crée les dossiers, écrit un fichier temporaire voisin, vide le tampon puis déplace/remplace. Échec/annulation avant remplacement préserve le fichier précédent. Nettoyage du temporaire si le système le permet. Un remplacement terminé ne peut pas être annulé.
- Pause/arrêt vérifiés tous les256 éléments, entre blocs de4096 octets/caractères et avant remplacement. Aucun thread supplémentaire; appels système non interruptibles de force. Écritures concurrentes: dernier remplacement réussi conservé; aucune transaction de base de données.

### Fonctions internes : de l’appel au résultat

Enregistre une valeur dans un fichier JSON.

#### 1. Save

Chemin obligatoire. Les chemins relatifs partent du dossier du script principal, même depuis Include. Chemins absolus acceptés. Nombre, String, tableau, List, Dictionary, JsonBoolean ou JsonNull. Clés de Dictionary obligatoirement String. Références partagées acceptées, cycles refusés. Indicateur Integer:0 compact, autre valeur avec indentation. Défaut:Stringify=0, Save=1.

Unit: aucun résultat. Une fin normale signifie réussite; erreurs avec Try/Catch.

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; fonction `Save`.

Config.Load(fileName, defaults) renvoie un nouveau Dictionary: les clés sauvegardées de premier niveau remplacent une copie profonde des défauts. Les objets imbriqués sont remplacés entièrement. Config.Save(fileName, settings) enregistre explicitement sans résultat. Config.GetFlag(settings, key, fallback=False) renvoie1/True ou0/False; une valeur existante non booléenne provoque une erreur. Config.SetFlag(settings, key, value) modifie seulement la mémoire et ne renvoie rien. Load/Save nécessitent des Dictionaries à clés String. Private RequireObject vérifie la catégorie extérieure, JSON valide tout le contenu.


## Exemples

### JsonSave · 1

```vb
# JsonSave · 1
#
# Enregistre une valeur dans un fichier JSON.
#
# Unit: aucun résultat. Une fin normale signifie réussite; erreurs avec Try/Catch.

Option Explicit On
Sub Main()
    # Exécuter Main. fileName="json-save-demo.json", value=d, indented=1 → file; JsonLoad →
    # delay=Integer350.

    Dim d=JsonParse('{"delay":350}')
    JsonSave('json-save-demo.json', d)
    Dim loaded=JsonLoad('json-save-demo.json')
    Return loaded['delay']
End Sub
```

**Explication des paramètres et du déroulement:**

- Exécuter Main. fileName="json-save-demo.json", value=d, indented=1 → file; JsonLoad → delay=Integer350.

### JsonSave · 2

```vb
# JsonSave · 2
#
# Enregistre une valeur dans un fichier JSON.
#
# Unit: aucun résultat. Une fin normale signifie réussite; erreurs avec Try/Catch.

Option Explicit On
Sub Main()
    # Exécuter Main. fileName="json-save-array.json", value=List, indented=False=0 → compact
    # [true,null,7].

    JsonSave(indented:=False, value:=JsonParse('[true,null,7]'), fileName:='json-save-array.json')
    Return JsonStringify(JsonLoad('json-save-array.json'))
End Sub
```

**Explication des paramètres et du déroulement:**

- Exécuter Main. fileName="json-save-array.json", value=List, indented=False=0 → compact [true,null,7].

### JsonSave · 3

```vb
# JsonSave · 3
#
# Enregistre une valeur dans un fichier JSON.
#
# Unit: aucun résultat. Une fin normale signifie réussite; erreurs avec Try/Catch.

Option Explicit On
Sub Main()
    # Exécuter Main. fileName="json-replace-demo.json", value=7; next value=cyclic List → Catch;
    # JsonLoad → original Integer7.

    JsonSave('json-replace-demo.json', 7)
    Dim cycle=List()
    cycle.Add(cycle)
    Try
    JsonSave('json-replace-demo.json', cycle)
    Catch problem
    Return JsonLoad('json-replace-demo.json')
    End Try
    Return 0
End Sub
```

**Explication des paramètres et du déroulement:**

- Exécuter Main. fileName="json-replace-demo.json", value=7; next value=cyclic List → Catch; JsonLoad → original Integer7.
