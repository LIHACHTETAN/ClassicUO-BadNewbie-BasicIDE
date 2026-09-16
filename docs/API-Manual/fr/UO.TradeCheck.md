# UO.TradeCheck

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: fr -->

Lit les cases d’accord ; la forme à trois arguments peut modifier la vôtre.

## Syntaxe exacte

```text
UO.TradeCheck(TradeNum:Any, Num:Any) -> Any
UO.TradeCheck(windowIndex:Any) -> Integer
UO.TradeCheck(windowIndex:Any, checkbox:Any, stateValue:Any) -> Integer
```

## Paramètres

- `windowIndex` — Indice entier actuel de 0 à TradeCount()-1. Un indice négatif/absent donne un résultat vide. Ce n’est pas un serial.
- `TradeNum` — Indice entier actuel de 0 à TradeCount()-1. Un indice négatif/absent donne un résultat vide. Ce n’est pas un serial.
- `Num` — Forme à deux arguments : 1 votre case, 2 celle du partenaire, sinon 0. TradeNum commence ici à 0.
- `checkbox` — Forme à trois arguments : 0 votre case, 1 celle du partenaire en lecture seule ; sinon résultat 0.
- `stateValue` — Pour checkbox=0 seulement : 0/FALSE décoche ; toute valeur non nulle/TRUE coche. Ignoré pour checkbox=1.

## Retour

Integer : 1 = TRUE si la case choisie est cochée ; 0 = FALSE sinon, ou si fenêtre/côté invalide. Une écriture renvoie l’état obtenu, pas le succès de l’échange : décocher renvoie 0.

Résultat logique : 1 = TRUE, 0 = FALSE. Après VAR result = commande(...), utilisez IF result = TRUE THEN ou IF result = 1 THEN ; sinon IF result = FALSE THEN ou IF result = 0 THEN. TRUE/FALSE sans guillemets. Appelez une seule fois et conservez le résultat : un nouvel appel peut répéter l’action ou lire un état modifié.

## Comportement

- GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade commencent à 1 ; TradeContainer/TradeOpponent/TradeName et toutes les formes TradeCheck à 0. Ce client conserve ces conventions ; les références des différents moteurs ne concordent pas toujours.
- Lecture sur le thread du jeu, dans les fenêtres vivantes du World actuel. Les fenêtres fermées sont exclues. Aucun paquet ni attente en lecture. L’ordre UI change à l’ouverture, fermeture ou passage au premier plan ; l’indice n’est pas un identifiant stable.
- ConfirmTrade et l’écriture de votre TradeCheck envoient uniquement lors d’un changement d’accord. Le serveur contrôle l’autre case. CancelTrade annule une seule fois. 1/TRUE signifie état/traitement local, pas transfert terminé. Les noms et cases ne garantissent pas un contenu inchangé.

### Fonctions internes : de l’appel au résultat

Le chemin C# est expliqué ci-dessous, suivi d’exemples Basic exécutables. Les scripts ne réimplémentent pas le protocole réseau.

#### 1. TradeCheck

La signature est choisie selon le nombre d’arguments ; NumberConversions convertit les nombres. TradeCheck à deux arguments valide 1/2 puis les transforme en 0/1 pour le bridge. ToHex formate les serials historiques.

Integer : 1 = TRUE si la case choisie est cochée ; 0 = FALSE sinon, ou si fenêtre/côté invalide. Une écriture renvoie l’état obtenu, pas le succès de l’échange : décocher renvoie 0.

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; fonction `TradeCheck`.

#### 2. TradeCheck

Invoke transfère lecture/écriture sur le thread du jeu avec annulation du script ; lecture de ID1/ID2, LocalSerial, OpponentName ou des cases du TradingGump choisi.

Lit les cases d’accord ; la forme à trois arguments peut modifier la vôtre.

Source du projet: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; fonction `TradeCheck`.

#### 3. FindTrade

FindNumberedTrade vérifie number>0 avant de soustraire 1 ; FindTrade refuse les indices négatifs et parcourt les TradingGump non fermés de ce World.

GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade commencent à 1 ; TradeContainer/TradeOpponent/TradeName et toutes les formes TradeCheck à 0. Ce client conserve ces conventions ; les références des différents moteurs ne concordent pas toujours.

Source du projet: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; fonction `FindTrade`.

#### 4. AcceptTrade

Un changement de votre case appelle GameActions.AcceptTrade puis Send_TradeResponse avec code 2, ID1 et état. Lecture et état inchangé n’envoient rien.

Integer : 1 = TRUE si la case choisie est cochée ; 0 = FALSE sinon, ou si fenêtre/côté invalide. Une écriture renvoie l’état obtenu, pas le succès de l’échange : décocher renvoie 0.

Source du projet: `src/ClassicUO.Client/Game/GameActions.cs`; fonction `AcceptTrade`.

La fonction est entièrement définie et appelée par Main. Vérifier les limites/ID réduit les erreurs sans rendre les appels atomiques ; la fenêtre peut changer entre deux appels. expectedPartner est le serial mémorisé du personnage, pas une validation du prix/contenu.


## Exemples

### Lecture ou action directe

```vb
# Lecture ou action directe
#
# Lit les cases d’accord ; la forme à trois arguments peut modifier la vôtre.
#
# Integer : 1 = TRUE si la case choisie est cochée ; 0 = FALSE sinon, ou si fenêtre/côté
# invalide. Une écriture renvoie l’état obtenu, pas le succès de l’échange : décocher renvoie 0.
#
# Résultat logique : 1 = TRUE, 0 = FALSE. Après VAR result = commande(...), utilisez IF result =
# TRUE THEN ou IF result = 1 THEN ; sinon IF result = FALSE THEN ou IF result = 0 THEN.
# TRUE/FALSE sans guillemets. Appelez une seule fois et conservez le résultat : un nouvel appel
# peut répéter l’action ou lire un état modifié.

SUB Main()
    # TradeCheck(0) et TradeCheck(0,1) lisent votre case de la première fenêtre ; TradeCheck(0,2)
    # lit celle du partenaire. Aucune écriture ni confirmation automatique.

    VAR own = UO.TradeCheck(0)
    VAR sameOwn = UO.TradeCheck(0, 1)
    VAR other = UO.TradeCheck(0, 2)
    UO.Print(CStr(own) + "/" + CStr(sameOwn) + "/" + CStr(other))
END SUB
```

**Explication des paramètres et du déroulement:**

- TradeCheck(0) et TradeCheck(0,1) lisent votre case de la première fenêtre ; TradeCheck(0,2) lit celle du partenaire. Aucune écriture ni confirmation automatique.

### Autre scénario et paramètres

```vb
# Autre scénario et paramètres
#
# Lit les cases d’accord ; la forme à trois arguments peut modifier la vôtre.
#
# Integer : 1 = TRUE si la case choisie est cochée ; 0 = FALSE sinon, ou si fenêtre/côté
# invalide. Une écriture renvoie l’état obtenu, pas le succès de l’échange : décocher renvoie 0.
#
# Résultat logique : 1 = TRUE, 0 = FALSE. Après VAR result = commande(...), utilisez IF result =
# TRUE THEN ou IF result = 1 THEN ; sinon IF result = FALSE THEN ou IF result = 0 THEN.
# TRUE/FALSE sans guillemets. Appelez une seule fois et conservez le résultat : un nouvel appel
# peut répéter l’action ou lire un état modifié.

SUB Main()
    # TradeCheck(0,0,FALSE) décoche votre accord. TradeCheck(0,1,FALSE) lit seulement celui du
    # partenaire : FALSE ne le modifie pas. Le résultat 0 après décochage est normal.

    VAR cleared = UO.TradeCheck(0, 0, FALSE)
    VAR other = UO.TradeCheck(0, 1, FALSE)
    UO.Print(CStr(cleared) + "/" + CStr(other))
END SUB
```

**Explication des paramètres et du déroulement:**

- TradeCheck(0,0,FALSE) décoche votre accord. TradeCheck(0,1,FALSE) lit seulement celui du partenaire : FALSE ne le modifie pas. Le résultat 0 après décochage est normal.

### Fonction auxiliaire complète

```vb
# Fonction auxiliaire complète
#
# Lit les cases d’accord ; la forme à trois arguments peut modifier la vôtre.
#
# Integer : 1 = TRUE si la case choisie est cochée ; 0 = FALSE sinon, ou si fenêtre/côté
# invalide. Une écriture renvoie l’état obtenu, pas le succès de l’échange : décocher renvoie 0.
#
# Résultat logique : 1 = TRUE, 0 = FALSE. Après VAR result = commande(...), utilisez IF result =
# TRUE THEN ou IF result = 1 THEN ; sinon IF result = FALSE THEN ou IF result = 0 THEN.
# TRUE/FALSE sans guillemets. Appelez une seule fois et conservez le résultat : un nouvel appel
# peut répéter l’action ou lire un état modifié.

SUB Main()
    # La fonction est entièrement définie et appelée par Main. Vérifier les limites/ID réduit les
    # erreurs sans rendre les appels atomiques ; la fenêtre peut changer entre deux appels.
    # expectedPartner est le serial mémorisé du personnage, pas une validation du prix/contenu.

    VAR accepted = BothAccepted(0)
    IF accepted = TRUE THEN
        UO.Print("Both boxes are checked; server completion is not known")
    END IF
END SUB

FUNCTION BothAccepted(index)
    IF index < 0 OR index >= UO.TradeCount() THEN
        RETURN FALSE
    END IF
    VAR own = UO.TradeCheck(index, 1)
    VAR other = UO.TradeCheck(index, 2)
    RETURN own = TRUE AND other = TRUE
END FUNCTION
```

**Explication des paramètres et du déroulement:**

- La fonction est entièrement définie et appelée par Main. Vérifier les limites/ID réduit les erreurs sans rendre les appels atomiques ; la fenêtre peut changer entre deux appels. expectedPartner est le serial mémorisé du personnage, pas une validation du prix/contenu.
