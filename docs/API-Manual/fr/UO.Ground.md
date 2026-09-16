# UO.Ground

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: fr -->

Renvoie le sélecteur spécial du sol pour un conteneur de recherche ou une destination de transfert.

## Syntaxe exacte

```text
UO.Ground() -> Integer
```

## Paramètres

Aucun paramètre.

## Retour

Integer, toujours 0. Ce zéro désigne correctement le sol, pas FALSE, un échec, un ID, un graphique, une carte ou une coordonnée. Testez le résultat de la recherche ou du transfert, pas Ground() comme indicateur de réussite.

## Comportement

- Aucun paramètre. Ground() seul ne cherche ni ne déplace rien, n’ouvre aucune cible, n’envoie aucun paquet et ne modifie pas les résultats précédents. Renvoie aussi 0 avant connexion.
- À passer dans container/destination de FindType, FindList, Count, FindTypeEx, FindTypesArrayEx, CountEx ou MoveItem. La recherche lit les objets chargés sans charger les cases lointaines. X/Y/Z au sol sont des coordonnées du monde, pas des pixels du conteneur.
- FindType(type, color) cherche toujours dans l’inventaire : le deuxième argument est la couleur. Pour le sol : FindType(type, color, UO.Ground()). Les formes compactes FindType/MoveItem utilisent -1 pour l’inventaire ; les formes compatibles FindTypeEx/FindTypesArrayEx/CountEx acceptent aussi -1 pour le sol. Préférez UO.Ground() ou le nom ground aux constantes numériques propres à chaque commande.
- Source primaire : [Stealth Ground](https://stealth.od.ua/api/Ground/). Ces conventions et exemples décrivent ce client.

### Fonctions internes : de l’appel au résultat

Opérations internes réelles. FindGroundTypes est une fonction utilisateur complète, pas une commande intégrée supplémentaire.

#### 1. ExecuteStealthCompatibility

La branche runtime sans argument renvoie Integer 0 sans appeler le bridge du jeu.

Integer, toujours 0. Ce zéro désigne correctement le sol, pas FALSE, un échec, un ID, un graphique, une carte ou une coordonnée. Testez le résultat de la recherche ou du transfert, pas Ground() comme indicateur de réussite.

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; fonction `ExecuteStealthCompatibility`.

#### 2. ConvertContainer

L’adaptateur compact convertit 0 explicite en sol interne, et garde -1 pour l’inventaire. L’adaptateur compatible accepte 0 et l’ancien -1 pour le sol ; les noms de conteneurs sont résolus séparément.

FindType(type, color) cherche toujours dans l’inventaire : le deuxième argument est la couleur. Pour le sol : FindType(type, color, UO.Ground()). Les formes compactes FindType/MoveItem utilisent -1 pour l’inventaire ; les formes compatibles FindTypeEx/FindTypesArrayEx/CountEx acceptent aussi -1 pour le sol. Préférez UO.Ground() ou le nom ground aux constantes numériques propres à chaque commande.

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; fonction `ConvertContainer`.

#### 3. ConvertStealthSearchContainer

L’adaptateur compact convertit 0 explicite en sol interne, et garde -1 pour l’inventaire. L’adaptateur compatible accepte 0 et l’ancien -1 pour le sol ; les noms de conteneurs sont résolus séparément.

FindType(type, color) cherche toujours dans l’inventaire : le deuxième argument est la couleur. Pour le sol : FindType(type, color, UO.Ground()). Les formes compactes FindType/MoveItem utilisent -1 pour l’inventaire ; les formes compatibles FindTypeEx/FindTypesArrayEx/CountEx acceptent aussi -1 pour le sol. Préférez UO.Ground() ou le nom ground aux constantes numériques propres à chaque commande.

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; fonction `ConvertStealthSearchContainer`.

#### 4. ResolveTransferDestination

La résolution de destination conserve 0 pour le sol. Le bridge utilise les coordonnées du monde ; le paquet de dépôt contient 0xFFFFFFFF dans le champ conteneur. Sélecteur API et champ réseau ont des représentations différentes.

Remplacez 0x40001001 par le serial d’un objet accessible. IsObjectExists vérifie l’objet chargé. MoveItem(item, amount, destination, X, Y, Z) : amount=0 signifie pile entière ; Ground() désigne le sol ; GetX/GetY/GetZ lisent la case du joueur. result=1 signifie demande acceptée par le client, sinon 0 ; ce n’est ni Ground() ni une confirmation du serveur.

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; fonction `ResolveTransferDestination`.

#### 5. MoveItem

La résolution de destination conserve 0 pour le sol. Le bridge utilise les coordonnées du monde ; le paquet de dépôt contient 0xFFFFFFFF dans le champ conteneur. Sélecteur API et champ réseau ont des représentations différentes.

Remplacez 0x40001001 par le serial d’un objet accessible. IsObjectExists vérifie l’objet chargé. MoveItem(item, amount, destination, X, Y, Z) : amount=0 signifie pile entière ; Ground() désigne le sol ; GetX/GetY/GetZ lisent la case du joueur. result=1 signifie demande acceptée par le client, sinon 0 ; ce n’est ni Ground() ni une confirmation du serveur.

Source du projet: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; fonction `MoveItem`.

Aucun paramètre. Ground() seul ne cherche ni ne déplace rien, n’ouvre aucune cible, n’envoie aucun paquet et ne modifie pas les résultats précédents. Renvoie aussi 0 avant connexion.


## Exemples

### Lire le sélecteur

```vb
# Lire le sélecteur
#
# Renvoie le sélecteur spécial du sol pour un conteneur de recherche ou une destination de
# transfert.
#
# Integer, toujours 0. Ce zéro désigne correctement le sol, pas FALSE, un échec, un ID, un
# graphique, une carte ou une coordonnée. Testez le résultat de la recherche ou du transfert,
# pas Ground() comme indicateur de réussite.

SUB Main()
    # destination reçoit Integer 0 et Print l’affiche. Aucun objet n’est posé.

    VAR destination = UO.Ground()
    UO.Print(CStr(destination))
END SUB
```

**Explication des paramètres et du déroulement:**

- destination reçoit Integer 0 et Print l’affiche. Aucun objet n’est posé.

### Chercher une pile d’or au sol

```vb
# Chercher une pile d’or au sol
#
# Renvoie le sélecteur spécial du sol pour un conteneur de recherche ou une destination de
# transfert.
#
# Integer, toujours 0. Ce zéro désigne correctement le sol, pas FALSE, un échec, un ID, un
# graphique, une carte ou une coordonnée. Testez le résultat de la recherche ou du transfert,
# pas Ground() comme indicateur de réussite.

SUB Main()
    # 0x0EED : graphique de l’or ; deuxième -1 : toute couleur. Ground() choisit le monde ; FALSE
    # désactive la récursion. FindTypeEx renvoie un serial ou 0 ; <> 0 teste ce serial.
    # FindDistance/FindVertical et Ignore restent actifs.

    VAR id = UO.FindTypeEx(0x0EED, -1, UO.Ground(), FALSE)
    IF id <> 0 THEN
        UO.Print(HEX(id))
    ELSE
        UO.Print('0')
    END IF
END SUB
```

**Explication des paramètres et du déroulement:**

- 0x0EED : graphique de l’or ; deuxième -1 : toute couleur. Ground() choisit le monde ; FALSE désactive la récursion. FindTypeEx renvoie un serial ou 0 ; <> 0 teste ce serial. FindDistance/FindVertical et Ignore restent actifs.

### Fonction complète pour deux graphiques

```vb
# Fonction complète pour deux graphiques
#
# Renvoie le sélecteur spécial du sol pour un conteneur de recherche ou une destination de
# transfert.
#
# Integer, toujours 0. Ce zéro désigne correctement le sol, pas FALSE, un échec, un ID, un
# graphique, une carte ou une coordonnée. Testez le résultat de la recherche ou du transfert,
# pas Ground() comme indicateur de réussite.

SUB Main()
    # FindGroundTypes(firstType, secondType, radius, height) cherche l’or 0x0EED et les perles
    # noires 0x0F7A avec radius=5 et height=10. DIM types[1] crée deux cases, colors[0] et
    # containers[0] une chacun. Une pile compte pour un objet ; types/couleurs sont des alternatives
    # et les conteneurs qui se recoupent ne dupliquent pas les ID. Renvoie un tableau sauvegardé de
    # serials. Finally restaure les limites ; Main affiche chaque ID. Fonction complète ci-dessous.

    VAR ids = FindGroundTypes(0x0EED, 0x0F7A, 5, 10)
    FOR EACH id IN ids
        UO.Print(HEX(id))
    NEXT
END SUB

FUNCTION FindGroundTypes(firstType, secondType, radius, height)
    VAR oldDistance = UO.FindDistance()
    VAR oldVertical = UO.FindVertical()
    DIM types[1]
    types[0] = firstType
    types[1] = secondType
    DIM colors[0]
    colors[0] = -1
    DIM containers[0]
    containers[0] = UO.Ground()
    TRY
        UO.FindDistance(radius)
        UO.FindVertical(height)
        UO.FindTypesArrayEx(types, colors, containers, FALSE)
        RETURN UO.GetFoundItems()
    FINALLY
        UO.FindDistance(oldDistance)
        UO.FindVertical(oldVertical)
    END TRY
END FUNCTION
```

**Explication des paramètres et du déroulement:**

- FindGroundTypes(firstType, secondType, radius, height) cherche l’or 0x0EED et les perles noires 0x0F7A avec radius=5 et height=10. DIM types[1] crée deux cases, colors[0] et containers[0] une chacun. Une pile compte pour un objet ; types/couleurs sont des alternatives et les conteneurs qui se recoupent ne dupliquent pas les ID. Renvoie un tableau sauvegardé de serials. Finally restaure les limites ; Main affiche chaque ID. Fonction complète ci-dessous.

### Poser un objet connu sur la case du joueur

```vb
# Poser un objet connu sur la case du joueur
#
# Renvoie le sélecteur spécial du sol pour un conteneur de recherche ou une destination de
# transfert.
#
# Integer, toujours 0. Ce zéro désigne correctement le sol, pas FALSE, un échec, un ID, un
# graphique, une carte ou une coordonnée. Testez le résultat de la recherche ou du transfert,
# pas Ground() comme indicateur de réussite.

SUB Main()
    # Remplacez 0x40001001 par le serial d’un objet accessible. IsObjectExists vérifie l’objet
    # chargé. MoveItem(item, amount, destination, X, Y, Z) : amount=0 signifie pile entière ;
    # Ground() désigne le sol ; GetX/GetY/GetZ lisent la case du joueur. result=1 signifie demande
    # acceptée par le client, sinon 0 ; ce n’est ni Ground() ni une confirmation du serveur.

    VAR item = 0x40001001
    IF UO.IsObjectExists(item) THEN
        VAR result = UO.MoveItem(item, 0, UO.Ground(), UO.GetX('self'), UO.GetY('self'), UO.GetZ('self'))
    END IF
END SUB
```

**Explication des paramètres et du déroulement:**

- Remplacez 0x40001001 par le serial d’un objet accessible. IsObjectExists vérifie l’objet chargé. MoveItem(item, amount, destination, X, Y, Z) : amount=0 signifie pile entière ; Ground() désigne le sol ; GetX/GetY/GetZ lisent la case du joueur. result=1 signifie demande acceptée par le client, sinon 0 ; ce n’est ni Ground() ni une confirmation du serveur.
