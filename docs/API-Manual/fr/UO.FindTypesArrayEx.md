# UO.FindTypesArrayEx

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: fr -->

Cherche plusieurs graphiques, couleurs et conteneurs en un parcours et renvoie un ID. GetFoundItems fournit la liste complète.

## Syntaxe exacte

```text
UO.FindTypesArrayEx(ObjTypes:Any, Colors:Any, Containers:Any, InSub:Any) -> Integer
```

## Paramètres

- `ObjTypes` — Graphic/body, pas le serial d’un objet. 0..65534 désigne un graphique ; -1 ou 0xFFFF accepte tout. Les autres Integer négatifs font aussi office de joker.
- `Colors` — Hue, pas une quantité. 0 signifie sans teinture ; -1 ou 0xFFFF toute couleur. Les autres Integer négatifs désactivent aussi ce filtre.
- `Containers` — Sol : UO.Ground(), 0, -1, 0xFFFFFFFF ou chaîne ground. Sac à dos : backpack ou son serial. Serials décimaux/hex et noms AddObject acceptés. my choisit tout l’inventaire du joueur, équipement et sacs imbriqués compris. Un nom inconnu provoque une erreur de script. Vérifiez un serial résolu : 0 explicite sélectionne le sol. Préférez ground/backpack aux conventions numériques propres à chaque API.
- `InSub` — TRUE/FALSE (1/0), obligatoire. FALSE : contenu direct d’un conteneur précis ; TRUE : aussi ses sacs imbriqués chargés. Aucun effet au sol. my couvre déjà tout l’inventaire possédé.

## Retour

Integer : serial du premier résultat dans l’ordre local, ou 0 sans résultat. Ni graphique, ni quantité, ni tableau, ni Boolean. Testez result <> 0, pas result = TRUE ou result = 1. Une pile est un objet ; un Mobile est un objet et une unité. L’ordre ne garantit ni proximité ni stabilité.

## Comportement

- Passez un Array ; une valeur scalaire est aussi acceptée comme un seul élément. DIM values[1] crée les indices 0 et 1 : remplissez tout. Types et couleurs sont des alternatives indépendantes, pas des paires par indice. Un joker n’importe où, ou un tableau types/couleurs vide, supprime ce filtre. Un tableau de conteneurs vide sélectionne l’inventaire possédé. Les chevauchements et répétitions ne dupliquent pas les ID.
- Les quatre arguments positionnels sont obligatoires ; aucun ne peut être omis.
- Au sol, FindDistance/FindVertical de ce script s’appliquent ; self est exclu, les Item et Mobile correspondants sont inclus. Ces limites ne s’appliquent pas à un conteneur précis. Ignore et les objets détruits sont exclus dans les deux cas.
- FindItem, FindCount, FindFullQuantity et GetFoundItems sont vidés avant le parcours. Aucun résultat laisse des zéros et un tableau vide. FindFullQuantity additionne max(1, Amount) par Item et 1 par Mobile. FindQuantity lit la quantité actuelle de FindItem. Sauvegardez GetFoundItems avant qu’une autre recherche remplace cet état.
- Le bridge parcourt une fois les Item chargés, puis les Mobile si le sol est sélectionné. Type, couleur et au moins un conteneur doivent correspondre. Chaque objet est enregistré une fois, sans reparcourir tout le monde pour chaque combinaison.
- Uniquement les données reçues : aucun conteneur ouvert, case chargée ou transfert. Une recherche vide ne prouve pas un coffre vide sur le serveur. Vérifiez Connected si une connexion active est nécessaire ; la recherche lit l’état local.
- [Stealth FindTypesArrayEx](https://stealth.od.ua/api/FindTypesArrayEx/). La référence décrit le dernier ID et un repli sur le sac pour un conteneur invalide. Ici, le premier résultat local est conservé ; un nom inconnu ne choisit pas le sac. Ground accepte aussi 0 ; FindDistance local vaut initialement 18, maximum 255.

### Fonctions internes : de l’appel au résultat

Étapes réelles, pas des commandes publiques supplémentaires. FindGoldNearSelf et SearchTypesIn sont des fonctions de script fournies intégralement ci-dessous.

#### 1. ExecuteStealthCompatibility

Le runtime convertit les filtres numériques et résout séparément les noms ; le sol devient la portée monde interne du bridge.

Les quatre arguments positionnels sont obligatoires ; aucun ne peut être omis.

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; fonction `ExecuteStealthCompatibility`.

#### 2. ConvertStealthSearchContainer

Sol : UO.Ground(), 0, -1, 0xFFFFFFFF ou chaîne ground. Sac à dos : backpack ou son serial. Serials décimaux/hex et noms AddObject acceptés. my choisit tout l’inventaire du joueur, équipement et sacs imbriqués compris. Un nom inconnu provoque une erreur de script. Vérifiez un serial résolu : 0 explicite sélectionne le sol. Préférez ground/backpack aux conventions numériques propres à chaque API.

Le runtime convertit les filtres numériques et résout séparément les noms ; le sol devient la portée monde interne du bridge.

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; fonction `ConvertStealthSearchContainer`.

#### 3. ResetFindResults

FindItem, FindCount, FindFullQuantity et GetFoundItems sont vidés avant le parcours. Aucun résultat laisse des zéros et un tableau vide. FindFullQuantity additionne max(1, Amount) par Item et 1 par Mobile. FindQuantity lit la quantité actuelle de FindItem. Sauvegardez GetFoundItems avant qu’une autre recherche remplace cet état.

Integer : serial du premier résultat dans l’ordre local, ou 0 sans résultat. Ni graphique, ni quantité, ni tableau, ni Boolean. Testez result <> 0, pas result = TRUE ou result = 1. Une pile est un objet ; un Mobile est un objet et une unité. L’ordre ne garantit ni proximité ni stabilité.

Source du projet: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; fonction `ResetFindResults`.

#### 4. BuildFindIdentityMask

Passez un Array ; une valeur scalaire est aussi acceptée comme un seul élément. DIM values[1] crée les indices 0 et 1 : remplissez tout. Types et couleurs sont des alternatives indépendantes, pas des paires par indice. Un joker n’importe où, ou un tableau types/couleurs vide, supprime ce filtre. Un tableau de conteneurs vide sélectionne l’inventaire possédé. Les chevauchements et répétitions ne dupliquent pas les ID.

Le bridge parcourt une fois les Item chargés, puis les Mobile si le sol est sélectionné. Type, couleur et au moins un conteneur doivent correspondre. Chaque objet est enregistré une fois, sans reparcourir tout le monde pour chaque combinaison.

Source du projet: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; fonction `BuildFindIdentityMask`.

#### 5. FindTypes

Le bridge parcourt une fois les Item chargés, puis les Mobile si le sol est sélectionné. Type, couleur et au moins un conteneur doivent correspondre. Chaque objet est enregistré une fois, sans reparcourir tout le monde pour chaque combinaison.

Au sol, FindDistance/FindVertical de ce script s’appliquent ; self est exclu, les Item et Mobile correspondants sont inclus. Ces limites ne s’appliquent pas à un conteneur précis. Ignore et les objets détruits sont exclus dans les deux cas.

Source du projet: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; fonction `FindTypes`.

#### 6. MatchesFindIdentity

Graphic/body, pas le serial d’un objet. 0..65534 désigne un graphique ; -1 ou 0xFFFF accepte tout. Les autres Integer négatifs font aussi office de joker. Hue, pas une quantité. 0 signifie sans teinture ; -1 ou 0xFFFF toute couleur. Les autres Integer négatifs désactivent aussi ce filtre.

Le bridge parcourt une fois les Item chargés, puis les Mobile si le sol est sélectionné. Type, couleur et au moins un conteneur doivent correspondre. Chaque objet est enregistré une fois, sans reparcourir tout le monde pour chaque combinaison.

Source du projet: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; fonction `MatchesFindIdentity`.

#### 7. MatchesFindContainer

TRUE/FALSE (1/0), obligatoire. FALSE : contenu direct d’un conteneur précis ; TRUE : aussi ses sacs imbriqués chargés. Aucun effet au sol. my couvre déjà tout l’inventaire possédé.

Au sol, FindDistance/FindVertical de ce script s’appliquent ; self est exclu, les Item et Mobile correspondants sont inclus. Ces limites ne s’appliquent pas à un conteneur précis. Ignore et les objets détruits sont exclus dans les deux cas.

Source du projet: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; fonction `MatchesFindContainer`.

#### 8. RegisterFound

FindItem, FindCount, FindFullQuantity et GetFoundItems sont vidés avant le parcours. Aucun résultat laisse des zéros et un tableau vide. FindFullQuantity additionne max(1, Amount) par Item et 1 par Mobile. FindQuantity lit la quantité actuelle de FindItem. Sauvegardez GetFoundItems avant qu’une autre recherche remplace cet état.

Integer : serial du premier résultat dans l’ordre local, ou 0 sans résultat. Ni graphique, ni quantité, ni tableau, ni Boolean. Testez result <> 0, pas result = TRUE ou result = 1. Une pile est un objet ; un Mobile est un objet et une unité. L’ordre ne garantit ni proximité ni stabilité.

Source du projet: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; fonction `RegisterFound`.

Uniquement les données reçues : aucun conteneur ouvert, case chargée ou transfert. Une recherche vide ne prouve pas un coffre vide sur le serveur. Vérifiez Connected si une connexion active est nécessaire ; la recherche lit l’état local.


## Exemples

### Deux graphiques au sol

```vb
# Deux graphiques au sol
#
# Cherche plusieurs graphiques, couleurs et conteneurs en un parcours et renvoie un ID.
# GetFoundItems fournit la liste complète.
#
# Integer : serial du premier résultat dans l’ordre local, ou 0 sans résultat. Ni graphique, ni
# quantité, ni tableau, ni Boolean. Testez result <> 0, pas result = TRUE ou result = 1. Une
# pile est un objet ; un Mobile est un objet et une unité. L’ordre ne garantit ni proximité ni
# stabilité.

SUB Main()
    # types : or 0x0EED et perles noires 0x0F7A ; color=-1 : tout hue ; Ground : monde. FALSE n’y
    # change rien. Les limites actuelles s’appliquent. Affiche ID, objets et unités.

    DIM types[1]
    types[0] = 0x0EED
    types[1] = 0x0F7A
    DIM colors[0]
    colors[0] = -1
    DIM containers[0]
    containers[0] = UO.Ground()
    VAR first = UO.FindTypesArrayEx(types, colors, containers, FALSE)
    UO.Print(Hex(first))
    UO.Print(STR(UO.FindCount()))
    UO.Print(STR(UO.FindFullQuantity()))
END SUB
```

**Explication des paramètres et du déroulement:**

- types : or 0x0EED et perles noires 0x0F7A ; color=-1 : tout hue ; Ground : monde. FALSE n’y change rien. Les limites actuelles s’appliquent. Affiche ID, objets et unités.

### Or dans le sac et au sol

```vb
# Or dans le sac et au sol
#
# Cherche plusieurs graphiques, couleurs et conteneurs en un parcours et renvoie un ID.
# GetFoundItems fournit la liste complète.
#
# Integer : serial du premier résultat dans l’ordre local, ou 0 sans résultat. Ni graphique, ni
# quantité, ni tableau, ni Boolean. Testez result <> 0, pas result = TRUE ou result = 1. Une
# pile est un objet ; un Mobile est un objet et une unité. L’ordre ne garantit ni proximité ni
# stabilité.

SUB Main()
    # types : or seulement ; colors : tout hue. Containers : backpack et sol ; TRUE inclut les
    # sous-sacs. Affiche objets/piles et unités des deux portées sans compter deux fois un objet.

    DIM types[0]
    types[0] = 0x0EED
    DIM colors[0]
    colors[0] = -1
    DIM containers[1]
    containers[0] = 'backpack'
    containers[1] = UO.Ground()
    UO.FindTypesArrayEx(types, colors, containers, TRUE)
    UO.Print(STR(UO.FindCount()))
    UO.Print(STR(UO.FindFullQuantity()))
END SUB
```

**Explication des paramètres et du déroulement:**

- types : or seulement ; colors : tout hue. Containers : backpack et sol ; TRUE inclut les sous-sacs. Affiche objets/piles et unités des deux portées sans compter deux fois un objet.

### Fonction complète renvoyant une liste

```vb
# Fonction complète renvoyant une liste
#
# Cherche plusieurs graphiques, couleurs et conteneurs en un parcours et renvoie un ID.
# GetFoundItems fournit la liste complète.
#
# Integer : serial du premier résultat dans l’ordre local, ou 0 sans résultat. Ni graphique, ni
# quantité, ni tableau, ni Boolean. Testez result <> 0, pas result = TRUE ou result = 1. Une
# pile est un objet ; un Mobile est un objet et une unité. L’ordre ne garantit ni proximité ni
# stabilité.

SUB Main()
    # SearchTypesIn(container,firstType,secondType) renvoie Array<Integer>, contrairement à
    # l’Integer ID unique de la commande intégrée. Le code complet remplit les tableaux, cherche
    # récursivement et copie immédiatement GetFoundItems. Main vérifie puis affiche chaque ID.

    VAR items = SearchTypesIn('backpack', 0x0EED, 0x0F7A)
    FOR EACH item IN items
        IF UO.IsObjectExists(item) THEN
            UO.Print(Hex(item))
        END IF
    NEXT
END SUB

FUNCTION SearchTypesIn(container, firstType, secondType)
    DIM types[1]
    types[0] = firstType
    types[1] = secondType
    DIM colors[0]
    colors[0] = -1
    DIM containers[0]
    containers[0] = container
    UO.FindTypesArrayEx(types, colors, containers, TRUE)
    RETURN UO.GetFoundItems()
END FUNCTION
```

**Explication des paramètres et du déroulement:**

- SearchTypesIn(container,firstType,secondType) renvoie Array<Integer>, contrairement à l’Integer ID unique de la commande intégrée. Le code complet remplit les tableaux, cherche récursivement et copie immédiatement GetFoundItems. Main vérifie puis affiche chaque ID.
