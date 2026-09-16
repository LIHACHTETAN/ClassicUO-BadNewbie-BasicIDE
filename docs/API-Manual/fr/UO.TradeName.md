# UO.TradeName

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: fr -->

Lit le nom du partenaire avec un indice commençant à zéro.

## Syntaxe exacte

```text
UO.TradeName(windowIndex:Any) -> String
```

## Paramètres

- `windowIndex` — Indice entier actuel de 0 à TradeCount()-1. Un indice négatif/absent donne un résultat vide. Ce n’est pas un serial.

## Retour

String : nom mémorisé du partenaire ; chaîne vide sans fenêtre/nom. Le nom de l’objet conteneur n’est pas utilisé.

## Comportement

- GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade commencent à 1 ; TradeContainer/TradeOpponent/TradeName et toutes les formes TradeCheck à 0. Ce client conserve ces conventions ; les références des différents moteurs ne concordent pas toujours.
- Lecture sur le thread du jeu, dans les fenêtres vivantes du World actuel. Les fenêtres fermées sont exclues. Aucun paquet ni attente en lecture. L’ordre UI change à l’ouverture, fermeture ou passage au premier plan ; l’indice n’est pas un identifiant stable.
- ConfirmTrade et l’écriture de votre TradeCheck envoient uniquement lors d’un changement d’accord. Le serveur contrôle l’autre case. CancelTrade annule une seule fois. 1/TRUE signifie état/traitement local, pas transfert terminé. Les noms et cases ne garantissent pas un contenu inchangé.

### Fonctions internes : de l’appel au résultat

Le chemin C# est expliqué ci-dessous, suivi d’exemples Basic exécutables. Les scripts ne réimplémentent pas le protocole réseau.

#### 1. TradeName

La signature est choisie selon le nombre d’arguments ; NumberConversions convertit les nombres. TradeCheck à deux arguments valide 1/2 puis les transforme en 0/1 pour le bridge. ToHex formate les serials historiques.

String : nom mémorisé du partenaire ; chaîne vide sans fenêtre/nom. Le nom de l’objet conteneur n’est pas utilisé.

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; fonction `TradeName`.

#### 2. TradeName

Invoke transfère lecture/écriture sur le thread du jeu avec annulation du script ; lecture de ID1/ID2, LocalSerial, OpponentName ou des cases du TradingGump choisi.

Lit le nom du partenaire avec un indice commençant à zéro.

Source du projet: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; fonction `TradeName`.

#### 3. FindTrade

FindNumberedTrade vérifie number>0 avant de soustraire 1 ; FindTrade refuse les indices négatifs et parcourt les TradingGump non fermés de ce World.

GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade commencent à 1 ; TradeContainer/TradeOpponent/TradeName et toutes les formes TradeCheck à 0. Ce client conserve ces conventions ; les références des différents moteurs ne concordent pas toujours.

Source du projet: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; fonction `FindTrade`.

La fonction est entièrement définie et appelée par Main. Vérifier les limites/ID réduit les erreurs sans rendre les appels atomiques ; la fenêtre peut changer entre deux appels. expectedPartner est le serial mémorisé du personnage, pas une validation du prix/contenu.


## Exemples

### Lecture ou action directe

```vb
# Lecture ou action directe
#
# Lit le nom du partenaire avec un indice commençant à zéro.
#
# String : nom mémorisé du partenaire ; chaîne vide sans fenêtre/nom. Le nom de l’objet
# conteneur n’est pas utilisé.

SUB Main()
    # Un seul appel, conservé dans value/result. 0 désigne le premier indice, 1 le premier numéro
    # (voir syntaxe). HEX affiche les serials numériques ; CStr affiche nombres ou texte.

    VAR value = UO.TradeName(0)
    UO.Print(CStr(value))
END SUB
```

**Explication des paramètres et du déroulement:**

- Un seul appel, conservé dans value/result. 0 désigne le premier indice, 1 le premier numéro (voir syntaxe). HEX affiche les serials numériques ; CStr affiche nombres ou texte.

### Autre scénario et paramètres

```vb
# Autre scénario et paramètres
#
# Lit le nom du partenaire avec un indice commençant à zéro.
#
# String : nom mémorisé du partenaire ; chaîne vide sans fenêtre/nom. Le nom de l’objet
# conteneur n’est pas utilisé.

SUB Main()
    # total mémorise le nombre de fenêtres ; index est l’indice/numéro actuel. Le parcours ne
    # confirme rien. GetTradeContainer lit les conteneurs propre (1) et adverse (2) de la fenêtre 1.

    VAR total = UO.TradeCount()
    FOR VAR index = 0 TO total - 1
        VAR value = UO.TradeName(index)
        UO.Print(CStr(index) + ": " + CStr(value))
    NEXT
END SUB
```

**Explication des paramètres et du déroulement:**

- total mémorise le nombre de fenêtres ; index est l’indice/numéro actuel. Le parcours ne confirme rien. GetTradeContainer lit les conteneurs propre (1) et adverse (2) de la fenêtre 1.

### Fonction auxiliaire complète

```vb
# Fonction auxiliaire complète
#
# Lit le nom du partenaire avec un indice commençant à zéro.
#
# String : nom mémorisé du partenaire ; chaîne vide sans fenêtre/nom. Le nom de l’objet
# conteneur n’est pas utilisé.

SUB Main()
    # La fonction est entièrement définie et appelée par Main. Vérifier les limites/ID réduit les
    # erreurs sans rendre les appels atomiques ; la fenêtre peut changer entre deux appels.
    # expectedPartner est le serial mémorisé du personnage, pas une validation du prix/contenu.

    VAR value = ReadTradeValue(0)
    UO.Print(CStr(value))
END SUB

FUNCTION ReadTradeValue(index)
    VAR total = UO.TradeCount()
    IF index < 0 OR index >= total + 0 THEN
        RETURN ""
    END IF
    RETURN UO.TradeName(index)
END FUNCTION
```

**Explication des paramètres et du déroulement:**

- La fonction est entièrement définie et appelée par Main. Vérifier les limites/ID réduit les erreurs sans rendre les appels atomiques ; la fenêtre peut changer entre deux appels. expectedPartner est le serial mémorisé du personnage, pas une validation du prix/contenu.
