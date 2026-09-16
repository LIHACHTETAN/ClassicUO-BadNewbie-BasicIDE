# UO.TradeCount

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: fr -->

Compte les fenêtres d’échange ouvertes.

## Syntaxe exacte

```text
UO.TradeCount() -> Integer
```

## Paramètres

Aucun paramètre.

## Retour

Integer : nombre de fenêtres, à partir de 0. Ce n’est pas un booléen ; tester > 0.

## Comportement

- GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade commencent à 1 ; TradeContainer/TradeOpponent/TradeName et toutes les formes TradeCheck à 0. Ce client conserve ces conventions ; les références des différents moteurs ne concordent pas toujours.
- Lecture sur le thread du jeu, dans les fenêtres vivantes du World actuel. Les fenêtres fermées sont exclues. Aucun paquet ni attente en lecture. L’ordre UI change à l’ouverture, fermeture ou passage au premier plan ; l’indice n’est pas un identifiant stable.
- ConfirmTrade et l’écriture de votre TradeCheck envoient uniquement lors d’un changement d’accord. Le serveur contrôle l’autre case. CancelTrade annule une seule fois. 1/TRUE signifie état/traitement local, pas transfert terminé. Les noms et cases ne garantissent pas un contenu inchangé.

### Fonctions internes : de l’appel au résultat

Le chemin C# est expliqué ci-dessous, suivi d’exemples Basic exécutables. Les scripts ne réimplémentent pas le protocole réseau.

#### 1. TradeCount

La signature est choisie selon le nombre d’arguments ; NumberConversions convertit les nombres. TradeCheck à deux arguments valide 1/2 puis les transforme en 0/1 pour le bridge. ToHex formate les serials historiques.

Integer : nombre de fenêtres, à partir de 0. Ce n’est pas un booléen ; tester > 0.

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; fonction `TradeCount`.

#### 2. TradeCount

Invoke transfère lecture/écriture sur le thread du jeu avec annulation du script ; lecture de ID1/ID2, LocalSerial, OpponentName ou des cases du TradingGump choisi.

Compte les fenêtres d’échange ouvertes.

Source du projet: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; fonction `TradeCount`.

La fonction est entièrement définie et appelée par Main. Vérifier les limites/ID réduit les erreurs sans rendre les appels atomiques ; la fenêtre peut changer entre deux appels. expectedPartner est le serial mémorisé du personnage, pas une validation du prix/contenu.


## Exemples

### Lecture ou action directe

```vb
# Lecture ou action directe
#
# Compte les fenêtres d’échange ouvertes.
#
# Integer : nombre de fenêtres, à partir de 0. Ce n’est pas un booléen ; tester > 0.

SUB Main()
    # Un seul appel, conservé dans value/result. 0 désigne le premier indice, 1 le premier numéro
    # (voir syntaxe). HEX affiche les serials numériques ; CStr affiche nombres ou texte.

    VAR value = UO.TradeCount()
    UO.Print(CStr(value))
END SUB
```

**Explication des paramètres et du déroulement:**

- Un seul appel, conservé dans value/result. 0 désigne le premier indice, 1 le premier numéro (voir syntaxe). HEX affiche les serials numériques ; CStr affiche nombres ou texte.

### Autre scénario et paramètres

```vb
# Autre scénario et paramètres
#
# Compte les fenêtres d’échange ouvertes.
#
# Integer : nombre de fenêtres, à partir de 0. Ce n’est pas un booléen ; tester > 0.

SUB Main()
    # before/after sont deux instantanés espacés de 500 millisecondes. Ce délai n’attend aucun
    # échange précis et peut manquer des changements intermédiaires.

    VAR before = UO.TradeCount()
    WAIT(500)
    VAR after = UO.TradeCount()
    UO.Print(CStr(before) + " -> " + CStr(after))
END SUB
```

**Explication des paramètres et du déroulement:**

- before/after sont deux instantanés espacés de 500 millisecondes. Ce délai n’attend aucun échange précis et peut manquer des changements intermédiaires.

### Fonction auxiliaire complète

```vb
# Fonction auxiliaire complète
#
# Compte les fenêtres d’échange ouvertes.
#
# Integer : nombre de fenêtres, à partir de 0. Ce n’est pas un booléen ; tester > 0.

SUB Main()
    # La fonction est entièrement définie et appelée par Main. Vérifier les limites/ID réduit les
    # erreurs sans rendre les appels atomiques ; la fenêtre peut changer entre deux appels.
    # expectedPartner est le serial mémorisé du personnage, pas une validation du prix/contenu.

    VAR value = ReadTradeState()
    UO.Print(CStr(value))
END SUB

FUNCTION ReadTradeState()
    RETURN UO.TradeCount()
END FUNCTION
```

**Explication des paramètres et du déroulement:**

- La fonction est entièrement définie et appelée par Main. Vérifier les limites/ID réduit les erreurs sans rendre les appels atomiques ; la fenêtre peut changer entre deux appels. expectedPartner est le serial mémorisé du personnage, pas une validation du prix/contenu.
