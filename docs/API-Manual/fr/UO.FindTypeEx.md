# UO.FindTypeEx

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: fr -->

Cherche un graphique/couleur dans un conteneur ou au sol et renvoie un ID correspondant.

## Syntaxe exacte

```text
UO.FindTypeEx(ObjType:Any, Color:Any, Container:Any, InSub:Any) -> Integer
```

## Paramètres

- `ObjType` — Graphic/body, pas le serial d’un objet. 0..65534 désigne un graphique ; -1 ou 0xFFFF accepte tout. Les autres Integer négatifs font aussi office de joker.
- `Color` — Hue, pas une quantité. 0 signifie sans teinture ; -1 ou 0xFFFF toute couleur. Les autres Integer négatifs désactivent aussi ce filtre.
- `Container` — Sol : UO.Ground(), 0, -1, 0xFFFFFFFF ou chaîne ground. Sac à dos : backpack ou son serial. Serials décimaux/hex et noms AddObject acceptés. my choisit tout l’inventaire du joueur, équipement et sacs imbriqués compris. Un nom inconnu provoque une erreur de script. Vérifiez un serial résolu : 0 explicite sélectionne le sol. Préférez ground/backpack aux conventions numériques propres à chaque API.
- `InSub` — TRUE/FALSE (1/0), obligatoire. FALSE : contenu direct d’un conteneur précis ; TRUE : aussi ses sacs imbriqués chargés. Aucun effet au sol. my couvre déjà tout l’inventaire possédé.

## Retour

Integer : serial du premier résultat dans l’ordre local, ou 0 sans résultat. Ni graphique, ni quantité, ni tableau, ni Boolean. Testez result <> 0, pas result = TRUE ou result = 1. Une pile est un objet ; un Mobile est un objet et une unité. L’ordre ne garantit ni proximité ni stabilité.

## Comportement

- Les quatre arguments positionnels sont obligatoires ; aucun ne peut être omis.
- Au sol, FindDistance/FindVertical de ce script s’appliquent ; self est exclu, les Item et Mobile correspondants sont inclus. Ces limites ne s’appliquent pas à un conteneur précis. Ignore et les objets détruits sont exclus dans les deux cas.
- FindItem, FindCount, FindFullQuantity et GetFoundItems sont vidés avant le parcours. Aucun résultat laisse des zéros et un tableau vide. FindFullQuantity additionne max(1, Amount) par Item et 1 par Mobile. FindQuantity lit la quantité actuelle de FindItem. Sauvegardez GetFoundItems avant qu’une autre recherche remplace cet état.
- Le bridge parcourt une fois les Item chargés, puis les Mobile si le sol est sélectionné. Type, couleur et au moins un conteneur doivent correspondre. Chaque objet est enregistré une fois, sans reparcourir tout le monde pour chaque combinaison.
- Uniquement les données reçues : aucun conteneur ouvert, case chargée ou transfert. Une recherche vide ne prouve pas un coffre vide sur le serveur. Vérifiez Connected si une connexion active est nécessaire ; la recherche lit l’état local.
- [Stealth FindTypeEx](https://stealth.od.ua/api/FindTypeEx/). La référence décrit le dernier ID et un repli sur le sac pour un conteneur invalide. Ici, le premier résultat local est conservé ; un nom inconnu ne choisit pas le sac. Ground accepte aussi 0 ; FindDistance local vaut initialement 18, maximum 255.

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

#### 4. FindType

Le bridge parcourt une fois les Item chargés, puis les Mobile si le sol est sélectionné. Type, couleur et au moins un conteneur doivent correspondre. Chaque objet est enregistré une fois, sans reparcourir tout le monde pour chaque combinaison.

Au sol, FindDistance/FindVertical de ce script s’appliquent ; self est exclu, les Item et Mobile correspondants sont inclus. Ces limites ne s’appliquent pas à un conteneur précis. Ignore et les objets détruits sont exclus dans les deux cas.

Source du projet: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; fonction `FindType`.

#### 5. MatchesFindIdentity

Graphic/body, pas le serial d’un objet. 0..65534 désigne un graphique ; -1 ou 0xFFFF accepte tout. Les autres Integer négatifs font aussi office de joker. Hue, pas une quantité. 0 signifie sans teinture ; -1 ou 0xFFFF toute couleur. Les autres Integer négatifs désactivent aussi ce filtre.

Le bridge parcourt une fois les Item chargés, puis les Mobile si le sol est sélectionné. Type, couleur et au moins un conteneur doivent correspondre. Chaque objet est enregistré une fois, sans reparcourir tout le monde pour chaque combinaison.

Source du projet: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; fonction `MatchesFindIdentity`.

#### 6. MatchesFindContainer

TRUE/FALSE (1/0), obligatoire. FALSE : contenu direct d’un conteneur précis ; TRUE : aussi ses sacs imbriqués chargés. Aucun effet au sol. my couvre déjà tout l’inventaire possédé.

Au sol, FindDistance/FindVertical de ce script s’appliquent ; self est exclu, les Item et Mobile correspondants sont inclus. Ces limites ne s’appliquent pas à un conteneur précis. Ignore et les objets détruits sont exclus dans les deux cas.

Source du projet: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; fonction `MatchesFindContainer`.

#### 7. RegisterFound

FindItem, FindCount, FindFullQuantity et GetFoundItems sont vidés avant le parcours. Aucun résultat laisse des zéros et un tableau vide. FindFullQuantity additionne max(1, Amount) par Item et 1 par Mobile. FindQuantity lit la quantité actuelle de FindItem. Sauvegardez GetFoundItems avant qu’une autre recherche remplace cet état.

Integer : serial du premier résultat dans l’ordre local, ou 0 sans résultat. Ni graphique, ni quantité, ni tableau, ni Boolean. Testez result <> 0, pas result = TRUE ou result = 1. Une pile est un objet ; un Mobile est un objet et une unité. L’ordre ne garantit ni proximité ni stabilité.

Source du projet: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; fonction `RegisterFound`.

Uniquement les données reçues : aucun conteneur ouvert, case chargée ou transfert. Une recherche vide ne prouve pas un coffre vide sur le serveur. Vérifiez Connected si une connexion active est nécessaire ; la recherche lit l’état local.


## Exemples

### Contenu direct du sac

```vb
# Contenu direct du sac
#
# Cherche un graphique/couleur dans un conteneur ou au sol et renvoie un ID correspondant.
#
# Integer : serial du premier résultat dans l’ordre local, ou 0 sans résultat. Ni graphique, ni
# quantité, ni tableau, ni Boolean. Testez result <> 0, pas result = TRUE ou result = 1. Une
# pile est un objet ; un Mobile est un objet et une unité. L’ordre ne garantit ni proximité ni
# stabilité.

SUB Main()
    # 0x0EED : or ; -1 : tout hue ; backpack/FALSE exclut les sous-sacs. Affiche premier ID hex sans
    # 0x, nombre d’objets, unités. Deux piles de 20 et 50 donnent 2 objets et 70 unités.

    VAR item = UO.FindTypeEx(0x0EED, -1, 'backpack', FALSE)
    UO.Print(Hex(item))
    UO.Print(STR(UO.FindCount()))
    UO.Print(STR(UO.FindFullQuantity()))
END SUB
```

**Explication des paramètres et du déroulement:**

- 0x0EED : or ; -1 : tout hue ; backpack/FALSE exclut les sous-sacs. Affiche premier ID hex sans 0x, nombre d’objets, unités. Deux piles de 20 et 50 donnent 2 objets et 70 unités.

### Fonction complète de recherche temporaire au sol

```vb
# Fonction complète de recherche temporaire au sol
#
# Cherche un graphique/couleur dans un conteneur ou au sol et renvoie un ID correspondant.
#
# Integer : serial du premier résultat dans l’ordre local, ou 0 sans résultat. Ni graphique, ni
# quantité, ni tableau, ni Boolean. Testez result <> 0, pas result = TRUE ou result = 1. Une
# pile est un objet ; un Mobile est un objet et une unité. L’ordre ne garantit ni proximité ni
# stabilité.

SUB Main()
    # radius=5 et height=10 sont temporaires dans FindGoldNearSelf. Finally restaure les deux
    # limites même après Return ou erreur. Retour : serial d’or ou 0 ; Main teste <> 0.

    VAR item = FindGoldNearSelf(5, 10)
    IF item <> 0 THEN
        UO.Print(Hex(item))
    ELSE
        UO.Print('Empty')
    END IF
END SUB

FUNCTION FindGoldNearSelf(radius, height)
    VAR oldDistance = UO.FindDistance()
    VAR oldVertical = UO.FindVertical()
    TRY
        UO.FindDistance(radius)
        UO.FindVertical(height)
        RETURN UO.FindTypeEx(0x0EED, -1, UO.Ground(), FALSE)
    FINALLY
        UO.FindDistance(oldDistance)
        UO.FindVertical(oldVertical)
    END TRY
END FUNCTION
```

**Explication des paramètres et du déroulement:**

- radius=5 et height=10 sont temporaires dans FindGoldNearSelf. Finally restaure les deux limites même après Return ou erreur. Retour : serial d’or ou 0 ; Main teste <> 0.

### Conteneur nommé et sacs imbriqués

```vb
# Conteneur nommé et sacs imbriqués
#
# Cherche un graphique/couleur dans un conteneur ou au sol et renvoie un ID correspondant.
#
# Integer : serial du premier résultat dans l’ordre local, ou 0 sans résultat. Ni graphique, ni
# quantité, ni tableau, ni Boolean. Testez result <> 0, pas result = TRUE ou result = 1. Une
# pile est un objet ; un Mobile est un objet et une unité. L’ordre ne garantit ni proximité ni
# stabilité.

SUB Main()
    # GetSerial résout backpack ; vérifier zéro évite de sélectionner le sol. AddObject mémorise
    # search_bag. TRUE inclut les sous-sacs. GetFoundItems copie la liste et IsObjectExists
    # revérifie chaque ID.

    VAR bag = UO.GetSerial('backpack')
    IF bag <> 0 THEN
        UO.AddObject('search_bag', bag)
        UO.FindTypeEx(0x0EED, -1, 'search_bag', TRUE)
        VAR items = UO.GetFoundItems()
        FOR EACH item IN items
            IF UO.IsObjectExists(item) THEN
                UO.Print(Hex(item))
            END IF
        NEXT
    END IF
END SUB
```

**Explication des paramètres et du déroulement:**

- GetSerial résout backpack ; vérifier zéro évite de sélectionner le sol. AddObject mémorise search_bag. TRUE inclut les sous-sacs. GetFoundItems copie la liste et IsObjectExists revérifie chaque ID.
