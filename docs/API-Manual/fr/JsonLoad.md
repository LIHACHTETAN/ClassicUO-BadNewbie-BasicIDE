# JsonLoad

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: fr -->

Lit un fichier JSON.

## Syntaxe exacte

```text
JsonLoad(fileName:String) -> Any
JsonLoad(fileName:String, defaultValue:Any) -> Any
```

## Paramètres

- `fileName` — Chemin obligatoire. Les chemins relatifs partent du dossier du script principal, même depuis Include. Chemins absolus acceptés.
- `defaultValue` — Repli facultatif uniquement si le fichier ou son dossier manque. Copie indépendante via JSON; les erreurs de contenu, encodage et accès restent visibles.

## Retour

Any, comme JsonParse. Fichier absent sans defaultValue: erreur.

## Comportement

- Fonctions locales Basic sans UO., sans paquets de jeu. JsonParse/JsonStringify travaillent en mémoire. Basic True devient le nombre1; JsonBoolean(True) produit JSON true. JsonNull() distingue null de0.
- Nombres finis seulement. Valeurs entières hors ±9007199254740991 refusées; stocker les grands ID en Strings. Autres nombres: précision Double. UTF-8 strict: BOM accepté en entrée, absent en sortie. Unicode incorrect: erreur.
- Limites:1048576 unités UTF-16,4Mio de données,64 conteneurs imbriqués,100000 nœuds. Dépassement: erreur. Lecture/analyse crée de nouvelles collections; sauvegarder ne clone pas les objets mémoire.
- Save valide tout, crée les dossiers, écrit un fichier temporaire voisin, vide le tampon puis déplace/remplace. Échec/annulation avant remplacement préserve le fichier précédent. Nettoyage du temporaire si le système le permet. Un remplacement terminé ne peut pas être annulé.
- Pause/arrêt vérifiés tous les256 éléments, entre blocs de4096 octets/caractères et avant remplacement. Aucun thread supplémentaire; appels système non interruptibles de force. Écritures concurrentes: dernier remplacement réussi conservé; aucune transaction de base de données.

### Fonctions internes : de l’appel au résultat

Lit un fichier JSON.

#### 1. LoadCore

Chemin obligatoire. Les chemins relatifs partent du dossier du script principal, même depuis Include. Chemins absolus acceptés. Repli facultatif uniquement si le fichier ou son dossier manque. Copie indépendante via JSON; les erreurs de contenu, encodage et accès restent visibles.

Any, comme JsonParse. Fichier absent sans defaultValue: erreur.

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; fonction `LoadCore`.

Config.Load(fileName, defaults) renvoie un nouveau Dictionary: les clés sauvegardées de premier niveau remplacent une copie profonde des défauts. Les objets imbriqués sont remplacés entièrement. Config.Save(fileName, settings) enregistre explicitement sans résultat. Config.GetFlag(settings, key, fallback=False) renvoie1/True ou0/False; une valeur existante non booléenne provoque une erreur. Config.SetFlag(settings, key, value) modifie seulement la mémoire et ne renvoie rien. Load/Save nécessitent des Dictionaries à clés String. Private RequireObject vérifie la catégorie extérieure, JSON valide tout le contenu.


## Exemples

### JsonLoad · 1

```vb
# JsonLoad · 1
#
# Lit un fichier JSON.
#
# Any, comme JsonParse. Fichier absent sans defaultValue: erreur.

Option Explicit On
Sub Main()
    # Exécuter Main. fileName="json-demo.json"; JsonSave → file; JsonLoad → Dictionary; delay →
    # Integer350.

    JsonSave('json-demo.json', JsonParse('{"delay":350}'))
    Dim d=JsonLoad('json-demo.json')
    Return d['delay']
End Sub
```

**Explication des paramètres et du déroulement:**

- Exécuter Main. fileName="json-demo.json"; JsonSave → file; JsonLoad → Dictionary; delay → Integer350.

### JsonLoad · 2

```vb
# JsonLoad · 2
#
# Lit un fichier JSON.
#
# Any, comme JsonParse. Fichier absent sans defaultValue: erreur.

Option Explicit On
Sub Main()
    # Exécuter Main. fileName="missing-json-demo.json", defaultValue=defaults; missing file →
    # independent copy → "125:350".

    Dim defaults=Dictionary()
    defaults['delay']=350
    Dim loaded=JsonLoad('missing-json-demo.json', defaults)
    loaded['delay']=125
    Return CStr(loaded['delay']) & ':' & CStr(defaults['delay'])
End Sub
```

**Explication des paramètres et du déroulement:**

- Exécuter Main. fileName="missing-json-demo.json", defaultValue=defaults; missing file → independent copy → "125:350".

### JsonLoad · 3

```vb
# JsonLoad · 3
#
# Lit un fichier JSON.
#
# Any, comme JsonParse. Fichier absent sans defaultValue: erreur.

Option Explicit On
Sub Main()
    # Exécuter Main. fileName="json-demo-list.json", defaultValue=List(); existing file [1,2,3] →
    # List.Count() → Integer3.

    JsonSave('json-demo-list.json', JsonParse('[1,2,3]'))
    Dim data=JsonLoad(fileName:='json-demo-list.json', defaultValue:=List())
    Return data.Count()
End Sub
```

**Explication des paramètres et du déroulement:**

- Exécuter Main. fileName="json-demo-list.json", defaultValue=List(); existing file [1,2,3] → List.Count() → Integer3.
