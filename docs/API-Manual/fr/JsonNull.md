# JsonNull

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: fr -->

Crée une valeur JSON null explicite.

## Syntaxe exacte

```text
JsonNull() -> Object
```

## Paramètres

Aucun paramètre.

## Retour

Objet JsonNull sérialisé en null, ni0 ni String vide. Test:JsonKind(value)="null".

## Comportement

- Fonctions locales Basic sans UO., sans paquets de jeu. JsonParse/JsonStringify travaillent en mémoire. Basic True devient le nombre1; JsonBoolean(True) produit JSON true. JsonNull() distingue null de0.
- Nombres finis seulement. Valeurs entières hors ±9007199254740991 refusées; stocker les grands ID en Strings. Autres nombres: précision Double. UTF-8 strict: BOM accepté en entrée, absent en sortie. Unicode incorrect: erreur.
- Limites:1048576 unités UTF-16,4Mio de données,64 conteneurs imbriqués,100000 nœuds. Dépassement: erreur. Lecture/analyse crée de nouvelles collections; sauvegarder ne clone pas les objets mémoire.
- Save valide tout, crée les dossiers, écrit un fichier temporaire voisin, vide le tampon puis déplace/remplace. Échec/annulation avant remplacement préserve le fichier précédent. Nettoyage du temporaire si le système le permet. Un remplacement terminé ne peut pas être annulé.
- Pause/arrêt vérifiés tous les256 éléments, entre blocs de4096 octets/caractères et avant remplacement. Aucun thread supplémentaire; appels système non interruptibles de force. Écritures concurrentes: dernier remplacement réussi conservé; aucune transaction de base de données.

### Fonctions internes : de l’appel au résultat

Crée une valeur JSON null explicite.

#### 1. JsonNullObject



Objet JsonNull sérialisé en null, ni0 ni String vide. Test:JsonKind(value)="null".

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/JsonPrimitiveObjects.cs`; fonction `JsonNullObject`.

Config.Load(fileName, defaults) renvoie un nouveau Dictionary: les clés sauvegardées de premier niveau remplacent une copie profonde des défauts. Les objets imbriqués sont remplacés entièrement. Config.Save(fileName, settings) enregistre explicitement sans résultat. Config.GetFlag(settings, key, fallback=False) renvoie1/True ou0/False; une valeur existante non booléenne provoque une erreur. Config.SetFlag(settings, key, value) modifie seulement la mémoire et ne renvoie rien. Load/Save nécessitent des Dictionaries à clés String. Private RequireObject vérifie la catégorie extérieure, JSON valide tout le contenu.


## Exemples

### JsonNull · 1

```vb
# JsonNull · 1
#
# Crée une valeur JSON null explicite.
#
# Objet JsonNull sérialisé en null, ni0 ni String vide. Test:JsonKind(value)="null".

Option Explicit On
Sub Main()
    # Exécuter Main. JsonNull() → Object; JsonStringify → String "null".

    Return JsonStringify(JsonNull())
End Sub
```

**Explication des paramètres et du déroulement:**

- Exécuter Main. JsonNull() → Object; JsonStringify → String "null".

### JsonNull · 2

```vb
# JsonNull · 2
#
# Crée une valeur JSON null explicite.
#
# Objet JsonNull sérialisé en null, ni0 ni String vide. Test:JsonKind(value)="null".

Option Explicit On
Sub Main()
    # Exécuter Main. JsonNull() → d["selected"]; JsonKind comparison → Integer1/True.

    Dim d=Dictionary()
    d['selected']=JsonNull()
    Return JsonKind(d['selected'])='null'
End Sub
```

**Explication des paramètres et du déroulement:**

- Exécuter Main. JsonNull() → d["selected"]; JsonKind comparison → Integer1/True.

### JsonNull · 3

```vb
# JsonNull · 3
#
# Crée une valeur JSON null explicite.
#
# Objet JsonNull sérialisé en null, ni0 ni String vide. Test:JsonKind(value)="null".

Option Explicit On
Sub Main()
    # Exécuter Main. JsonNull(),0,"" → three distinct values → String [null,0,""] .

    Dim a=List()
    a.Add(JsonNull())
    a.Add(0)
    a.Add('')
    Return JsonStringify(a)
End Sub
```

**Explication des paramètres et du déroulement:**

- Exécuter Main. JsonNull(),0,"" → three distinct values → String [null,0,""] .
