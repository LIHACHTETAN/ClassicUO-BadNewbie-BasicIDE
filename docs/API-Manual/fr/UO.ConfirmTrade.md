# UO.ConfirmTrade

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: fr -->

Coche votre accord pour l’échange sélectionné.

## Syntaxe exacte

```text
UO.ConfirmTrade(TradeNum:Any) -> Any
```

## Paramètres

- `TradeNum` — Numéro entier actuel de 1 à TradeCount(). Zéro/négatif invalide. Ce n’est pas un serial.

## Retour

Integer : 1 = TRUE si la fenêtre existe et votre accord est coché/déjà coché ; 0 = FALSE sinon. Ne prouve pas la fin côté serveur ; répéter ne décoche pas.

Résultat logique : 1 = TRUE, 0 = FALSE. Après VAR result = commande(...), utilisez IF result = TRUE THEN ou IF result = 1 THEN ; sinon IF result = FALSE THEN ou IF result = 0 THEN. TRUE/FALSE sans guillemets. Appelez une seule fois et conservez le résultat : un nouvel appel peut répéter l’action ou lire un état modifié.

## Comportement

- GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade commencent à 1 ; TradeContainer/TradeOpponent/TradeName et toutes les formes TradeCheck à 0. Ce client conserve ces conventions ; les références des différents moteurs ne concordent pas toujours.
- Lecture sur le thread du jeu, dans les fenêtres vivantes du World actuel. Les fenêtres fermées sont exclues. Aucun paquet ni attente en lecture. L’ordre UI change à l’ouverture, fermeture ou passage au premier plan ; l’indice n’est pas un identifiant stable.
- ConfirmTrade et l’écriture de votre TradeCheck envoient uniquement lors d’un changement d’accord. Le serveur contrôle l’autre case. CancelTrade annule une seule fois. 1/TRUE signifie état/traitement local, pas transfert terminé. Les noms et cases ne garantissent pas un contenu inchangé.

### Fonctions internes : de l’appel au résultat

Le chemin C# est expliqué ci-dessous, suivi d’exemples Basic exécutables. Les scripts ne réimplémentent pas le protocole réseau.

#### 1. ExecuteStealthCompatibility

La signature est choisie selon le nombre d’arguments ; NumberConversions convertit les nombres. TradeCheck à deux arguments valide 1/2 puis les transforme en 0/1 pour le bridge. ToHex formate les serials historiques.

Integer : 1 = TRUE si la fenêtre existe et votre accord est coché/déjà coché ; 0 = FALSE sinon. Ne prouve pas la fin côté serveur ; répéter ne décoche pas.

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; fonction `ExecuteStealthCompatibility`.

#### 2. ConfirmTrade

Invoke transfère lecture/écriture sur le thread du jeu avec annulation du script ; lecture de ID1/ID2, LocalSerial, OpponentName ou des cases du TradingGump choisi.

Coche votre accord pour l’échange sélectionné.

Source du projet: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; fonction `ConfirmTrade`.

#### 3. FindNumberedTrade

FindNumberedTrade vérifie number>0 avant de soustraire 1 ; FindTrade refuse les indices négatifs et parcourt les TradingGump non fermés de ce World.

GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade commencent à 1 ; TradeContainer/TradeOpponent/TradeName et toutes les formes TradeCheck à 0. Ce client conserve ces conventions ; les références des différents moteurs ne concordent pas toujours.

Source du projet: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; fonction `FindNumberedTrade`.

#### 4. AcceptTrade

Un changement de votre case appelle GameActions.AcceptTrade puis Send_TradeResponse avec code 2, ID1 et état. Lecture et état inchangé n’envoient rien.

Integer : 1 = TRUE si la fenêtre existe et votre accord est coché/déjà coché ; 0 = FALSE sinon. Ne prouve pas la fin côté serveur ; répéter ne décoche pas.

Source du projet: `src/ClassicUO.Client/Game/GameActions.cs`; fonction `AcceptTrade`.

La fonction est entièrement définie et appelée par Main. Vérifier les limites/ID réduit les erreurs sans rendre les appels atomiques ; la fenêtre peut changer entre deux appels. expectedPartner est le serial mémorisé du personnage, pas une validation du prix/contenu.


## Exemples

### Lecture ou action directe

```vb
# Lecture ou action directe
#
# Coche votre accord pour l’échange sélectionné.
#
# Integer : 1 = TRUE si la fenêtre existe et votre accord est coché/déjà coché ; 0 = FALSE
# sinon. Ne prouve pas la fin côté serveur ; répéter ne décoche pas.
#
# Résultat logique : 1 = TRUE, 0 = FALSE. Après VAR result = commande(...), utilisez IF result =
# TRUE THEN ou IF result = 1 THEN ; sinon IF result = FALSE THEN ou IF result = 0 THEN.
# TRUE/FALSE sans guillemets. Appelez une seule fois et conservez le résultat : un nouvel appel
# peut répéter l’action ou lire un état modifié.

SUB Main()
    # Un seul appel, conservé dans value/result. 0 désigne le premier indice, 1 le premier numéro
    # (voir syntaxe). HEX affiche les serials numériques ; CStr affiche nombres ou texte.

    VAR result = UO.ConfirmTrade(1)
    IF result = TRUE THEN
        UO.Print("Local request processed")
    END IF
END SUB
```

**Explication des paramètres et du déroulement:**

- Un seul appel, conservé dans value/result. 0 désigne le premier indice, 1 le premier numéro (voir syntaxe). HEX affiche les serials numériques ; CStr affiche nombres ou texte.

### Autre scénario et paramètres

```vb
# Autre scénario et paramètres
#
# Coche votre accord pour l’échange sélectionné.
#
# Integer : 1 = TRUE si la fenêtre existe et votre accord est coché/déjà coché ; 0 = FALSE
# sinon. Ne prouve pas la fin côté serveur ; répéter ne décoche pas.
#
# Résultat logique : 1 = TRUE, 0 = FALSE. Après VAR result = commande(...), utilisez IF result =
# TRUE THEN ou IF result = 1 THEN ; sinon IF result = FALSE THEN ou IF result = 0 THEN.
# TRUE/FALSE sans guillemets. Appelez une seule fois et conservez le résultat : un nouvel appel
# peut répéter l’action ou lire un état modifié.

SUB Main()
    # ConfirmTrade et l’écriture de votre TradeCheck envoient uniquement lors d’un changement
    # d’accord. Le serveur contrôle l’autre case. CancelTrade annule une seule fois. 1/TRUE signifie
    # état/traitement local, pas transfert terminé. Les noms et cases ne garantissent pas un contenu
    # inchangé.

    VAR tradeNumber = 2
    IF UO.TradeCount() >= tradeNumber THEN
        VAR result = UO.ConfirmTrade(tradeNumber)
        UO.Print(CStr(result))
    END IF
END SUB
```

**Explication des paramètres et du déroulement:**

- ConfirmTrade et l’écriture de votre TradeCheck envoient uniquement lors d’un changement d’accord. Le serveur contrôle l’autre case. CancelTrade annule une seule fois. 1/TRUE signifie état/traitement local, pas transfert terminé. Les noms et cases ne garantissent pas un contenu inchangé.

### Fonction auxiliaire complète

```vb
# Fonction auxiliaire complète
#
# Coche votre accord pour l’échange sélectionné.
#
# Integer : 1 = TRUE si la fenêtre existe et votre accord est coché/déjà coché ; 0 = FALSE
# sinon. Ne prouve pas la fin côté serveur ; répéter ne décoche pas.
#
# Résultat logique : 1 = TRUE, 0 = FALSE. Après VAR result = commande(...), utilisez IF result =
# TRUE THEN ou IF result = 1 THEN ; sinon IF result = FALSE THEN ou IF result = 0 THEN.
# TRUE/FALSE sans guillemets. Appelez une seule fois et conservez le résultat : un nouvel appel
# peut répéter l’action ou lire un état modifié.

SUB Main()
    # La fonction est entièrement définie et appelée par Main. Vérifier les limites/ID réduit les
    # erreurs sans rendre les appels atomiques ; la fenêtre peut changer entre deux appels.
    # expectedPartner est le serial mémorisé du personnage, pas une validation du prix/contenu.

    VAR expectedPartner = UO.GetTradeOpponent(1)
    VAR result = ApplyToPartner(1, expectedPartner)
    UO.Print(CStr(result))
END SUB

FUNCTION ApplyToPartner(tradeNumber, expectedPartner)
    IF expectedPartner = 0 THEN
        RETURN FALSE
    END IF
    IF UO.GetTradeOpponent(tradeNumber) <> expectedPartner THEN
        RETURN FALSE
    END IF
    RETURN UO.ConfirmTrade(tradeNumber)
END FUNCTION
```

**Explication des paramètres et du déroulement:**

- La fonction est entièrement définie et appelée par Main. Vérifier les limites/ID réduit les erreurs sans rendre les appels atomiques ; la fenêtre peut changer entre deux appels. expectedPartner est le serial mémorisé du personnage, pas une validation du prix/contenu.
