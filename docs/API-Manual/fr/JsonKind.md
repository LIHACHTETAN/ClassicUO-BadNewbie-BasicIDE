# JsonKind

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: fr -->

Identifie la catégorie compatible JSON.

## Syntaxe exacte

```text
JsonKind(value:Any) -> String
```

## Paramètres

- `value` — Nombre, String, tableau, List, Dictionary, JsonBoolean ou JsonNull. Clés de Dictionary obligatoirement String. Références partagées acceptées, cycles refusés.

## Retour

String:number, string, array, object, boolean, null ou unsupported. Vérifie seulement la catégorie extérieure.

## Comportement

- Fonctions locales Basic sans UO., sans paquets de jeu. JsonParse/JsonStringify travaillent en mémoire. Basic True devient le nombre1; JsonBoolean(True) produit JSON true. JsonNull() distingue null de0.
- Nombres finis seulement. Valeurs entières hors ±9007199254740991 refusées; stocker les grands ID en Strings. Autres nombres: précision Double. UTF-8 strict: BOM accepté en entrée, absent en sortie. Unicode incorrect: erreur.
- Limites:1048576 unités UTF-16,4Mio de données,64 conteneurs imbriqués,100000 nœuds. Dépassement: erreur. Lecture/analyse crée de nouvelles collections; sauvegarder ne clone pas les objets mémoire.
- Save valide tout, crée les dossiers, écrit un fichier temporaire voisin, vide le tampon puis déplace/remplace. Échec/annulation avant remplacement préserve le fichier précédent. Nettoyage du temporaire si le système le permet. Un remplacement terminé ne peut pas être annulé.
- Pause/arrêt vérifiés tous les256 éléments, entre blocs de4096 octets/caractères et avant remplacement. Aucun thread supplémentaire; appels système non interruptibles de force. Écritures concurrentes: dernier remplacement réussi conservé; aucune transaction de base de données.

### Fonctions internes : de l’appel au résultat

Identifie la catégorie compatible JSON.

#### 1. Kind

Nombre, String, tableau, List, Dictionary, JsonBoolean ou JsonNull. Clés de Dictionary obligatoirement String. Références partagées acceptées, cycles refusés.

String:number, string, array, object, boolean, null ou unsupported. Vérifie seulement la catégorie extérieure.

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; fonction `Kind`.

Config.Load(fileName, defaults) renvoie un nouveau Dictionary: les clés sauvegardées de premier niveau remplacent une copie profonde des défauts. Les objets imbriqués sont remplacés entièrement. Config.Save(fileName, settings) enregistre explicitement sans résultat. Config.GetFlag(settings, key, fallback=False) renvoie1/True ou0/False; une valeur existante non booléenne provoque une erreur. Config.SetFlag(settings, key, value) modifie seulement la mémoire et ne renvoie rien. Load/Save nécessitent des Dictionaries à clés String. Private RequireObject vérifie la catégorie extérieure, JSON valide tout le contenu.


## Exemples

### JsonKind · 1

```vb
# JsonKind · 1
#
# Identifie la catégorie compatible JSON.
#
# String:number, string, array, object, boolean, null ou unsupported. Vérifie seulement la
# catégorie extérieure.

Option Explicit On
Sub Main()
    # Exécuter Main. value=12 → "number"; value="12" → "string".

    Return JsonKind(12) & ':' & JsonKind('12')
End Sub
```

**Explication des paramètres et du déroulement:**

- Exécuter Main. value=12 → "number"; value="12" → "string".

### JsonKind · 2

```vb
# JsonKind · 2
#
# Identifie la catégorie compatible JSON.
#
# String:number, string, array, object, boolean, null ou unsupported. Vérifie seulement la
# catégorie extérieure.

Option Explicit On
Sub Main()
    # Exécuter Main. value=JsonParse("[1]") → "array"; value=Dictionary() → "object".

    Return JsonKind(JsonParse('[1]')) & ':' & JsonKind(Dictionary())
End Sub
```

**Explication des paramètres et du déroulement:**

- Exécuter Main. value=JsonParse("[1]") → "array"; value=Dictionary() → "object".

### JsonKind · 3

```vb
# JsonKind · 3
#
# Identifie la catégorie compatible JSON.
#
# String:number, string, array, object, boolean, null ou unsupported. Vérifie seulement la
# catégorie extérieure.

Option Explicit On
Sub Main()
    # Exécuter Main. value=JsonBoolean(False) → "boolean"; value=JsonNull() → "null".

    Return JsonKind(JsonBoolean(False)) & ':' & JsonKind(JsonNull())
End Sub
```

**Explication des paramètres et du déroulement:**

- Exécuter Main. value=JsonBoolean(False) → "boolean"; value=JsonNull() → "null".
