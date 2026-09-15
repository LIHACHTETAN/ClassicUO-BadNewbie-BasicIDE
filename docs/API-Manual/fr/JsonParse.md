# JsonParse

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: fr -->

Analyse du texte JSON en valeurs Basic.

## Syntaxe exacte

```text
JsonParse(text:String) -> Any
```

## Paramètres

- `text` — String JSON obligatoire contenant une seule valeur complète. Clés uniques sensibles à la casse; commentaires et virgules finales interdits.

## Retour

Any: objet→Dictionary, tableau→List, texte→String, nombre→Integer ou Decimal(Double), true/false→JsonBoolean, null→JsonNull. Pas un indicateur de réussite.

## Comportement

- Fonctions locales Basic sans UO., sans paquets de jeu. JsonParse/JsonStringify travaillent en mémoire. Basic True devient le nombre1; JsonBoolean(True) produit JSON true. JsonNull() distingue null de0.
- Nombres finis seulement. Valeurs entières hors ±9007199254740991 refusées; stocker les grands ID en Strings. Autres nombres: précision Double. UTF-8 strict: BOM accepté en entrée, absent en sortie. Unicode incorrect: erreur.
- Limites:1048576 unités UTF-16,4Mio de données,64 conteneurs imbriqués,100000 nœuds. Dépassement: erreur. Lecture/analyse crée de nouvelles collections; sauvegarder ne clone pas les objets mémoire.
- Save valide tout, crée les dossiers, écrit un fichier temporaire voisin, vide le tampon puis déplace/remplace. Échec/annulation avant remplacement préserve le fichier précédent. Nettoyage du temporaire si le système le permet. Un remplacement terminé ne peut pas être annulé.
- Pause/arrêt vérifiés tous les256 éléments, entre blocs de4096 octets/caractères et avant remplacement. Aucun thread supplémentaire; appels système non interruptibles de force. Écritures concurrentes: dernier remplacement réussi conservé; aucune transaction de base de données.

### Fonctions internes : de l’appel au résultat

Analyse du texte JSON en valeurs Basic.

#### 1. Parse

String JSON obligatoire contenant une seule valeur complète. Clés uniques sensibles à la casse; commentaires et virgules finales interdits.

Any: objet→Dictionary, tableau→List, texte→String, nombre→Integer ou Decimal(Double), true/false→JsonBoolean, null→JsonNull. Pas un indicateur de réussite.

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/BasicJson.cs`; fonction `Parse`.

Config.Load(fileName, defaults) renvoie un nouveau Dictionary: les clés sauvegardées de premier niveau remplacent une copie profonde des défauts. Les objets imbriqués sont remplacés entièrement. Config.Save(fileName, settings) enregistre explicitement sans résultat. Config.GetFlag(settings, key, fallback=False) renvoie1/True ou0/False; une valeur existante non booléenne provoque une erreur. Config.SetFlag(settings, key, value) modifie seulement la mémoire et ne renvoie rien. Load/Save nécessitent des Dictionaries à clés String. Private RequireObject vérifie la catégorie extérieure, JSON valide tout le contenu.


## Exemples

### JsonParse · 1

```vb
# JsonParse · 1
#
# Analyse du texte JSON en valeurs Basic.
#
# Any: objet→Dictionary, tableau→List, texte→String, nombre→Integer ou Decimal(Double),
# true/false→JsonBoolean, null→JsonNull. Pas un indicateur de réussite.

Option Explicit On
Sub Main()
    # Exécuter Main. text={"delay":350} → Dictionary; d["delay"] → Integer350.

    Dim d=JsonParse('{"delay":350}')
    Return d['delay']
End Sub
```

**Explication des paramètres et du déroulement:**

- Exécuter Main. text={"delay":350} → Dictionary; d["delay"] → Integer350.

### JsonParse · 2

```vb
# JsonParse · 2
#
# Analyse du texte JSON en valeurs Basic.
#
# Any: objet→Dictionary, tableau→List, texte→String, nombre→Integer ou Decimal(Double),
# true/false→JsonBoolean, null→JsonNull. Pas un indicateur de réussite.

Option Explicit On
Sub Main()
    # Exécuter Main. text=[true,null,12] → List; index0 → JsonBoolean.Value()=1; index1 → null;
    # index2 → Integer12.

    Dim a=JsonParse('[true,null,12]')
    Dim flag=a[0]
    Return CStr(flag.Value()) & ':' & JsonKind(a[1]) & ':' & CStr(a[2])
End Sub
```

**Explication des paramètres et du déroulement:**

- Exécuter Main. text=[true,null,12] → List; index0 → JsonBoolean.Value()=1; index1 → null; index2 → Integer12.

### JsonParse · 3

```vb
# JsonParse · 3
#
# Analyse du texte JSON en valeurs Basic.
#
# Any: objet→Dictionary, tableau→List, texte→String, nombre→Integer ou Decimal(Double),
# true/false→JsonBoolean, null→JsonNull. Pas un indicateur de réussite.

Option Explicit On
Sub Main()
    # Exécuter Main. text={"x":1,"x":2} → Catch → "duplicate key".

    Try
    Dim bad=JsonParse('{"x":1,"x":2}')
    Catch problem
    Return 'duplicate key'
    End Try
    Return 'unexpected'
End Sub
```

**Explication des paramètres et du déroulement:**

- Exécuter Main. text={"x":1,"x":2} → Catch → "duplicate key".
