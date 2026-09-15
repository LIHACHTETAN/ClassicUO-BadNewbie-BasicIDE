# JsonStringify

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: fr -->

Convertit des valeurs Basic en texte JSON.

## Syntaxe exacte

```text
JsonStringify(value:Any) -> String
JsonStringify(value:Any, indented:Integer) -> String
```

## Paramètres

- `value` — Nombre, String, tableau, List, Dictionary, JsonBoolean ou JsonNull. Clés de Dictionary obligatoirement String. Références partagées acceptées, cycles refusés.
- `indented` — Indicateur Integer:0 compact, autre valeur avec indentation. Défaut:Stringify=0, Save=1.

## Retour

String JSON; aucun fichier créé.

## Comportement

- Fonctions locales Basic sans UO., sans paquets de jeu. JsonParse/JsonStringify travaillent en mémoire. Basic True devient le nombre1; JsonBoolean(True) produit JSON true. JsonNull() distingue null de0.
- Nombres finis seulement. Valeurs entières hors ±9007199254740991 refusées; stocker les grands ID en Strings. Autres nombres: précision Double. UTF-8 strict: BOM accepté en entrée, absent en sortie. Unicode incorrect: erreur.
- Limites:1048576 unités UTF-16,4Mio de données,64 conteneurs imbriqués,100000 nœuds. Dépassement: erreur. Lecture/analyse crée de nouvelles collections; sauvegarder ne clone pas les objets mémoire.
- Save valide tout, crée les dossiers, écrit un fichier temporaire voisin, vide le tampon puis déplace/remplace. Échec/annulation avant remplacement préserve le fichier précédent. Nettoyage du temporaire si le système le permet. Un remplacement terminé ne peut pas être annulé.
- Pause/arrêt vérifiés tous les256 éléments, entre blocs de4096 octets/caractères et avant remplacement. Aucun thread supplémentaire; appels système non interruptibles de force. Écritures concurrentes: dernier remplacement réussi conservé; aucune transaction de base de données.

### Fonctions internes : de l’appel au résultat

Convertit des valeurs Basic en texte JSON.

#### 1. Stringify

Nombre, String, tableau, List, Dictionary, JsonBoolean ou JsonNull. Clés de Dictionary obligatoirement String. Références partagées acceptées, cycles refusés. Indicateur Integer:0 compact, autre valeur avec indentation. Défaut:Stringify=0, Save=1.

String JSON; aucun fichier créé.

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; fonction `Stringify`.

Config.Load(fileName, defaults) renvoie un nouveau Dictionary: les clés sauvegardées de premier niveau remplacent une copie profonde des défauts. Les objets imbriqués sont remplacés entièrement. Config.Save(fileName, settings) enregistre explicitement sans résultat. Config.GetFlag(settings, key, fallback=False) renvoie1/True ou0/False; une valeur existante non booléenne provoque une erreur. Config.SetFlag(settings, key, value) modifie seulement la mémoire et ne renvoie rien. Load/Save nécessitent des Dictionaries à clés String. Private RequireObject vérifie la catégorie extérieure, JSON valide tout le contenu.


## Exemples

### JsonStringify · 1

```vb
# JsonStringify · 1
#
# Convertit des valeurs Basic en texte JSON.
#
# String JSON; aucun fichier créé.

Option Explicit On
Sub Main()
    # Exécuter Main. value=Dictionary(name="ore",count=3), indented=0 → String
    # {"name":"ore","count":3}.

    Dim d=Dictionary()
    d['name']='ore'
    d['count']=3
    Return JsonStringify(d)
End Sub
```

**Explication des paramètres et du déroulement:**

- Exécuter Main. value=Dictionary(name="ore",count=3), indented=0 → String {"name":"ore","count":3}.

### JsonStringify · 2

```vb
# JsonStringify · 2
#
# Convertit des valeurs Basic en texte JSON.
#
# String JSON; aucun fichier créé.

Option Explicit On
Sub Main()
    # Exécuter Main. value=d, indented=True=1; JsonParse(text) → independent Dictionary; JsonKind →
    # "boolean:null".

    Dim d=JsonParse('{"enabled":true,"empty":null}')
    Dim text=JsonStringify(value:=d, indented:=True)
    Dim copy=JsonParse(text)
    Return JsonKind(copy['enabled']) & ':' & JsonKind(copy['empty'])
End Sub
```

**Explication des paramètres et du déroulement:**

- Exécuter Main. value=d, indented=True=1; JsonParse(text) → independent Dictionary; JsonKind → "boolean:null".

### JsonStringify · 3

```vb
# JsonStringify · 3
#
# Convertit des valeurs Basic en texte JSON.
#
# String JSON; aucun fichier créé.

Option Explicit On
Sub Main()
    # Exécuter Main. value=List → value[0]=value → Catch → "cycle".

    Dim d=List()
    d.Add(d)
    Try
    Dim text=JsonStringify(d)
    Catch problem
    Return 'cycle'
    End Try
    Return 'unexpected'
End Sub
```

**Explication des paramètres et du déroulement:**

- Exécuter Main. value=List → value[0]=value → Catch → "cycle".
