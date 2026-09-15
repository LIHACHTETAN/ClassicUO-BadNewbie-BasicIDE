# JsonBoolean

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: fr -->

Crée un booléen JSON explicite.

## Syntaxe exacte

```text
JsonBoolean(value:Any) -> Object
```

## Paramètres

- `value` — Nombre ou String numérique:0=false, sinon true. Basic True/False vaut1/0. Lire un booléen JSON avec flag.Value().

## Retour

Objet JsonBoolean sérialisé en true/false. Value() renvoie Integer1/True ou0/False pour If. Ne pas utiliser directement cet objet comme indicateur numérique.

## Comportement

- Fonctions locales Basic sans UO., sans paquets de jeu. JsonParse/JsonStringify travaillent en mémoire. Basic True devient le nombre1; JsonBoolean(True) produit JSON true. JsonNull() distingue null de0.
- Nombres finis seulement. Valeurs entières hors ±9007199254740991 refusées; stocker les grands ID en Strings. Autres nombres: précision Double. UTF-8 strict: BOM accepté en entrée, absent en sortie. Unicode incorrect: erreur.
- Limites:1048576 unités UTF-16,4Mio de données,64 conteneurs imbriqués,100000 nœuds. Dépassement: erreur. Lecture/analyse crée de nouvelles collections; sauvegarder ne clone pas les objets mémoire.
- Save valide tout, crée les dossiers, écrit un fichier temporaire voisin, vide le tampon puis déplace/remplace. Échec/annulation avant remplacement préserve le fichier précédent. Nettoyage du temporaire si le système le permet. Un remplacement terminé ne peut pas être annulé.
- Pause/arrêt vérifiés tous les256 éléments, entre blocs de4096 octets/caractères et avant remplacement. Aucun thread supplémentaire; appels système non interruptibles de force. Écritures concurrentes: dernier remplacement réussi conservé; aucune transaction de base de données.

### Fonctions internes : de l’appel au résultat

Crée un booléen JSON explicite.

#### 1. BasicJsonBoolean

Nombre ou String numérique:0=false, sinon true. Basic True/False vaut1/0. Lire un booléen JSON avec flag.Value().

Objet JsonBoolean sérialisé en true/false. Value() renvoie Integer1/True ou0/False pour If. Ne pas utiliser directement cet objet comme indicateur numérique.

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApi.cs`; fonction `BasicJsonBoolean`.

Config.Load(fileName, defaults) renvoie un nouveau Dictionary: les clés sauvegardées de premier niveau remplacent une copie profonde des défauts. Les objets imbriqués sont remplacés entièrement. Config.Save(fileName, settings) enregistre explicitement sans résultat. Config.GetFlag(settings, key, fallback=False) renvoie1/True ou0/False; une valeur existante non booléenne provoque une erreur. Config.SetFlag(settings, key, value) modifie seulement la mémoire et ne renvoie rien. Load/Save nécessitent des Dictionaries à clés String. Private RequireObject vérifie la catégorie extérieure, JSON valide tout le contenu.


## Exemples

### JsonBoolean · 1

```vb
# JsonBoolean · 1
#
# Crée un booléen JSON explicite.
#
# Objet JsonBoolean sérialisé en true/false. Value() renvoie Integer1/True ou0/False pour If. Ne
# pas utiliser directement cet objet comme indicateur numérique.

Option Explicit On
Sub Main()
    # Exécuter Main. value=True=1 → JSON true; flag.Value()=1 → If → "enabled".

    Dim flag=JsonBoolean(True)
    If flag.Value() Then
    Return 'enabled'
    End If
    Return 'disabled'
End Sub
```

**Explication des paramètres et du déroulement:**

- Exécuter Main. value=True=1 → JSON true; flag.Value()=1 → If → "enabled".

### JsonBoolean · 2

```vb
# JsonBoolean · 2
#
# Crée un booléen JSON explicite.
#
# Objet JsonBoolean sérialisé en true/false. Value() renvoie Integer1/True ou0/False pour If. Ne
# pas utiliser directement cet objet comme indicateur numérique.

Option Explicit On
Sub Main()
    # Exécuter Main. value=0 → JSON false; Value() → Integer0/False; Main → "false:0".

    Dim flag=JsonBoolean(value:=0)
    Return JsonStringify(flag) & ':' & CStr(flag.Value())
End Sub
```

**Explication des paramètres et du déroulement:**

- Exécuter Main. value=0 → JSON false; Value() → Integer0/False; Main → "false:0".

### JsonBoolean · 3

```vb
# JsonBoolean · 3
#
# Crée un booléen JSON explicite.
#
# Objet JsonBoolean sérialisé en true/false. Value() renvoie Integer1/True ou0/False pour If. Ne
# pas utiliser directement cet objet comme indicateur numérique.

Option Explicit On
Sub Main()
    # Exécuter Main. value=-2 → JSON true; Basic True → number1; Main → String [true,1].

    Dim values=List()
    values.Add(JsonBoolean(-2))
    values.Add(True)
    Return JsonStringify(values)
End Sub
```

**Explication des paramètres et du déroulement:**

- Exécuter Main. value=-2 → JSON true; Basic True → number1; Main → String [true,1].
