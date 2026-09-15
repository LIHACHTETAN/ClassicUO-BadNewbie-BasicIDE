# UO.FindVertical

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: fr -->

Lit ou modifie la différence de hauteur autorisée par défaut pour une recherche.

## Syntaxe exacte

```text
UO.FindVertical() -> Integer
UO.FindVertical(value:Any) -> Unit
```

## Paramètres

- `value` — Integer facultatif. Sans argument : lecture ; value : écriture. Borné à 0..120 ; un négatif devient 0, pas illimité. Nouveau runtime : 2 ; un état restauré peut différer. Les décimaux sont tronqués vers zéro ; les chaînes numériques decimal/0x sont acceptées. Utilisez Integer pour éviter une conversion implicite.

## Retour

Sans argument : Integer, limite actuelle (différence en unités Z du monde), pas un ID, un nombre d’objets ou un Boolean. 0 indique une limite nulle, pas un échec. Avec value : Unit, aucune valeur ; ni TRUE/FALSE ni ancienne valeur. Relisez FindVertical() après écriture.

## Comportement

- Hauteur : abs(object.Z - player.Z), dans les deux sens, borne incluse. 0 exige le même Z. Ce n’est ni un numéro d’étage ni une distance horizontale.
- Valeur du runtime du script courant, partagée par ses procédures ; les runtimes indépendants ont leurs propres valeurs. Lire/écrire ne cherche rien, ne vide pas FindItem/FindCount/GetFoundItems, n’envoie aucun paquet, ne déplace personne et ne charge aucun objet lointain.
- FindTypeEx et FindTypesArrayEx appliquent ces limites au sol, pas au contenu des conteneurs. Type, couleur, Ignore et objets chargés restent déterminants. FindAtCoord ignore les deux limites. Les distance/maxZ explicites des commandes étendues peuvent les remplacer ; -1 dans ces paramètres utilise le défaut, contrairement à -1 affecté à la configuration. FindList filtre aussi Z dans les conteneurs : cette exception ne le concerne pas.
- Sauvegardez avant une recherche temporaire et restaurez dans Finally : aucune annulation automatique. Finally couvre la fin normale et les erreurs interceptables ; l’arrêt d’urgence n’est pas un mécanisme de nettoyage.
- Référence : [Stealth FindVertical](https://stealth.od.ua/api/FindVertical/). Ce client conserve ses valeurs initiales/plages : FindDistance 18 / 0..255 ; FindVertical 2 / 0..120. La syntaxe Basic et les filtres étendus décrivent ce projet.

### Fonctions internes : de l’appel au résultat

Étapes internes réelles. CountGroundInRange est une fonction utilisateur entièrement définie, pas une commande intégrée cachée.

#### 1. ExecuteStealthCompatibility

Zéro argument sélectionne la lecture ; un argument convertit value puis écrit. Les métadonnées distinguent Integer et Unit.

Sans argument : Integer, limite actuelle (différence en unités Z du monde), pas un ID, un nombre d’objets ou un Boolean. 0 indique une limite nulle, pas un échec. Avec value : Unit, aucune valeur ; ni TRUE/FALSE ni ancienne valeur. Relisez FindVertical() après écriture.

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; fonction `ExecuteStealthCompatibility`.

#### 2. GetFindVertical

Le bridge lit le réglage du runtime ou borne et stocke l’entier, sans parcourir le monde.

Sans argument : Integer, limite actuelle (différence en unités Z du monde), pas un ID, un nombre d’objets ou un Boolean. 0 indique une limite nulle, pas un échec. Avec value : Unit, aucune valeur ; ni TRUE/FALSE ni ancienne valeur. Relisez FindVertical() après écriture.

Source du projet: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; fonction `GetFindVertical`.

#### 3. SetFindVertical

Le bridge lit le réglage du runtime ou borne et stocke l’entier, sans parcourir le monde.

Integer facultatif. Sans argument : lecture ; value : écriture. Borné à 0..120 ; un négatif devient 0, pas illimité. Nouveau runtime : 2 ; un état restauré peut différer. Les décimaux sont tronqués vers zéro ; les chaînes numériques decimal/0x sont acceptées. Utilisez Integer pour éviter une conversion implicite.

Source du projet: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; fonction `SetFindVertical`.

#### 4. FindType

Une recherche ultérieure lit le réglage en l’absence de remplacement explicite. Items au sol et Mobiles passent les filtres de distance et de hauteur correspondants.

FindTypeEx et FindTypesArrayEx appliquent ces limites au sol, pas au contenu des conteneurs. Type, couleur, Ignore et objets chargés restent déterminants. FindAtCoord ignore les deux limites. Les distance/maxZ explicites des commandes étendues peuvent les remplacer ; -1 dans ces paramètres utilise le défaut, contrairement à -1 affecté à la configuration. FindList filtre aussi Z dans les conteneurs : cette exception ne le concerne pas.

Source du projet: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; fonction `FindType`.

#### 5. FindList

Une recherche ultérieure lit le réglage en l’absence de remplacement explicite. Items au sol et Mobiles passent les filtres de distance et de hauteur correspondants.

FindTypeEx et FindTypesArrayEx appliquent ces limites au sol, pas au contenu des conteneurs. Type, couleur, Ignore et objets chargés restent déterminants. FindAtCoord ignore les deux limites. Les distance/maxZ explicites des commandes étendues peuvent les remplacer ; -1 dans ces paramètres utilise le défaut, contrairement à -1 affecté à la configuration. FindList filtre aussi Z dans les conteneurs : cette exception ne le concerne pas.

Source du projet: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; fonction `FindList`.

Valeur du runtime du script courant, partagée par ses procédures ; les runtimes indépendants ont leurs propres valeurs. Lire/écrire ne cherche rien, ne vide pas FindItem/FindCount/GetFoundItems, n’envoie aucun paquet, ne déplace personne et ne charge aucun objet lointain.


## Exemples

### Lire, régler et vérifier les bornes

```vb
# Lire, régler et vérifier les bornes
#
# Lit ou modifie la différence de hauteur autorisée par défaut pour une recherche.
#
# Sans argument : Integer, limite actuelle (différence en unités Z du monde), pas un ID, un
# nombre d’objets ou un Boolean. 0 indique une limite nulle, pas un échec. Avec value : Unit,
# aucune valeur ; ni TRUE/FALSE ni ancienne valeur. Relisez FindVertical() après écriture.

SUB Main()
    # previous sauvegarde le réglage réel. value:=10 définit une limite normale ; 1000 est ramené à
    # 120. Print utilise la lecture séparée. Finally restaure previous.

    VAR previous = UO.FindVertical()
    TRY
        UO.FindVertical(value:=10)
        UO.Print(CStr(UO.FindVertical()))
        UO.FindVertical(1000)
        UO.Print(CStr(UO.FindVertical()))
    FINALLY
        UO.FindVertical(previous)
    END TRY
END SUB
```

**Explication des paramètres et du déroulement:**

- previous sauvegarde le réglage réel. value:=10 définit une limite normale ; 1000 est ramené à 120. Print utilise la lecture séparée. Finally restaure previous.

### Recherche temporaire au sol

```vb
# Recherche temporaire au sol
#
# Lit ou modifie la différence de hauteur autorisée par défaut pour une recherche.
#
# Sans argument : Integer, limite actuelle (différence en unités Z du monde), pas un ID, un
# nombre d’objets ou un Boolean. 0 indique une limite nulle, pas un échec. Avec value : Unit,
# aucune valeur ; ni TRUE/FALSE ni ancienne valeur. Relisez FindVertical() après écriture.

SUB Main()
    # previous conserve le réglage appelant. 10 change seulement FindVertical, pas l’autre limite.
    # 0x0EED : graphique de l’or ; -1 : toute couleur ; Container=-1 : monde ; FALSE : sans
    # récursion des conteneurs. id est un serial ; <> 0 teste sa présence. FindCount compte les
    # objets/piles. Finally restaure le réglage, pas la liste.

    VAR previous = UO.FindVertical()
    TRY
        UO.FindVertical(10)
        VAR id = UO.FindTypeEx(0x0EED, -1, -1, FALSE)
        IF id <> 0 THEN
            UO.Print(HEX(id) + ':' + CStr(UO.FindCount()))
        ELSE
            UO.Print('0')
        END IF
    FINALLY
        UO.FindVertical(previous)
    END TRY
END SUB
```

**Explication des paramètres et du déroulement:**

- previous conserve le réglage appelant. 10 change seulement FindVertical, pas l’autre limite. 0x0EED : graphique de l’or ; -1 : toute couleur ; Container=-1 : monde ; FALSE : sans récursion des conteneurs. id est un serial ; <> 0 teste sa présence. FindCount compte les objets/piles. Finally restaure le réglage, pas la liste.

### Fonction complète CountGroundInRange

```vb
# Fonction complète CountGroundInRange
#
# Lit ou modifie la différence de hauteur autorisée par défaut pour une recherche.
#
# Sans argument : Integer, limite actuelle (différence en unités Z du monde), pas un ID, un
# nombre d’objets ou un Boolean. 0 indique une limite nulle, pas un échec. Avec value : Unit,
# aucune valeur ; ni TRUE/FALSE ni ancienne valeur. Relisez FindVertical() après écriture.

SUB Main()
    # CountGroundInRange(graphic, radius, height) sauvegarde les deux limites, applique radius=5 et
    # height=10, cherche graphic=0x0EED et renvoie FindCount(). Une pile vaut un objet. Fonction
    # complète après Main. Finally restaure les limites même lors de Return ; le résultat de
    # recherche reste accessible.

    VAR count = CountGroundInRange(0x0EED, 5, 10)
    UO.Print(CStr(count))
END SUB

FUNCTION CountGroundInRange(graphic, radius, height)
    VAR oldDistance = UO.FindDistance()
    VAR oldVertical = UO.FindVertical()
    TRY
        UO.FindDistance(radius)
        UO.FindVertical(height)
        UO.FindTypeEx(graphic, -1, -1, FALSE)
        RETURN UO.FindCount()
    FINALLY
        UO.FindDistance(oldDistance)
        UO.FindVertical(oldVertical)
    END TRY
END FUNCTION
```

**Explication des paramètres et du déroulement:**

- CountGroundInRange(graphic, radius, height) sauvegarde les deux limites, applique radius=5 et height=10, cherche graphic=0x0EED et renvoie FindCount(). Une pile vaut un objet. Fonction complète après Main. Finally restaure les limites même lors de Return ; le résultat de recherche reste accessible.
