# UO.FindAtCoord

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: fr -->

Recherche les objets chargés sur une case X/Y exacte de la carte actuelle.

## Syntaxe exacte

```text
UO.FindAtCoord(X:Any, Y:Any) -> Integer
```

## Paramètres

- `X` — coordonnée horizontale du monde, Integer 0..65535. Obligatoire ; ce ne sont pas les pixels de la fenêtre du conteneur.
- `Y` — coordonnée verticale du monde, Integer 0..65535. Obligatoire. Aucun argument supplémentaire Z, carte, type ou rayon.

## Retour

Integer : serial du premier objet correspondant dans la liste de ce client. 0 signifie aucun résultat, personnage absent/supprimé ou coordonnées hors de 0..65535. C’est un ID, pas un type, une quantité ni un Boolean. Les 32 bits sont conservés : tester <> 0, pas = TRUE ni > 0. Le même ID devient FindItem().

## Comportement

- Examine les Items non supprimés au sol et les Mobiles, y compris le personnage présent sur la case. Le contenu des conteneurs et les objets équipés sont exclus : leurs X/Y ne sont pas des coordonnées du monde. Les serials ignorés sont exclus.
- Toutes les hauteurs Z à ces X/Y sont acceptées. FindDistance et FindVertical ne limitent pas cette recherche exacte. Seuls les objets chargés du monde actuel sont visibles ; aucun terrain, élément statique ou autre carte n’est chargé. Aucun paquet, curseur de ciblage ou déplacement d’objet.
- Chaque appel efface d’abord la recherche précédente. FindCount() compte les objets, FindFullQuantity() additionne les unités des piles (un Mobile ajoute un), GetFoundItems() fournit les serials. Les Items précèdent les Mobiles, selon l’ordre actuel de chaque collection. Conserver la liste avant une nouvelle recherche.
- Référence : [Stealth FindAtCoord](https://stealth.od.ua/api/FindAtCoord/). L’ordre et les filtres ci-dessus décrivent ce client.

### Fonctions internes : de l’appel au résultat

Voici les étapes internes réelles. CountGraphicAt est une fonction de script entièrement définie, pas une commande intégrée supplémentaire.

#### 1. ExecuteStealthCompatibility

Le chemin enregistré convertit les deux arguments X/Y positionnels ou nommés ; l’Integer de la passerelle devient le résultat.

Integer : serial du premier objet correspondant dans la liste de ce client. 0 signifie aucun résultat, personnage absent/supprimé ou coordonnées hors de 0..65535. C’est un ID, pas un type, une quantité ni un Boolean. Les 32 bits sont conservés : tester <> 0, pas = TRUE ni > 0. Le même ID devient FindItem().

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; fonction `ExecuteStealthCompatibility`.

#### 2. FindAtCoord

Sur le thread du jeu, la recherche précédente est effacée, le personnage et les coordonnées sont vérifiés, puis les Items au sol et Mobiles correspondants sont parcourus. Le contenu des conteneurs est exclu.

Examine les Items non supprimés au sol et les Mobiles, y compris le personnage présent sur la case. Le contenu des conteneurs et les objets équipés sont exclus : leurs X/Y ne sont pas des coordonnées du monde. Les serials ignorés sont exclus.

Source du projet: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; fonction `FindAtCoord`.

#### 3. RegisterFound

Chaque résultat augmente le compteur et ajoute son serial. Le premier serial reste FindItem ; Item.Amount ajoute au moins une unité, un Mobile en ajoute une.

Chaque appel efface d’abord la recherche précédente. FindCount() compte les objets, FindFullQuantity() additionne les unités des piles (un Mobile ajoute un), GetFoundItems() fournit les serials. Les Items précèdent les Mobiles, selon l’ordre actuel de chaque collection. Conserver la liste avant une nouvelle recherche.

Source du projet: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; fonction `RegisterFound`.

Toutes les hauteurs Z à ces X/Y sont acceptées. FindDistance et FindVertical ne limitent pas cette recherche exacte. Seuls les objets chargés du monde actuel sont visibles ; aucun terrain, élément statique ou autre carte n’est chargé. Aucun paquet, curseur de ciblage ou déplacement d’objet.


## Exemples

### Lire un ID

```vb
# Lire un ID
#
# Recherche les objets chargés sur une case X/Y exacte de la carte actuelle.
#
# Integer : serial du premier objet correspondant dans la liste de ce client. 0 signifie aucun
# résultat, personnage absent/supprimé ou coordonnées hors de 0..65535. C’est un ID, pas un
# type, une quantité ni un Boolean. Les 32 bits sont conservés : tester <> 0, pas = TRUE ni > 0.
# Le même ID devient FindItem().

SUB Main()
    # 1445 et 1690 sont des X/Y du monde donnés en exemple ; les remplacer par votre case. id
    # conserve un serial, HEX le formate. <> 0 vérifie un résultat, pas une quantité.

    VAR id = UO.FindAtCoord(1445, 1690)
    IF id <> 0 THEN
        UO.Print(HEX(id))
    ELSE
        UO.Print('No loaded object')
    END IF
END SUB
```

**Explication des paramètres et du déroulement:**

- 1445 et 1690 sont des X/Y du monde donnés en exemple ; les remplacer par votre case. id conserve un serial, HEX le formate. <> 0 vérifie un résultat, pas une quantité.

### Examiner les objets sur la case du personnage

```vb
# Examiner les objets sur la case du personnage
#
# Recherche les objets chargés sur une case X/Y exacte de la carte actuelle.
#
# Integer : serial du premier objet correspondant dans la liste de ce client. 0 signifie aucun
# résultat, personnage absent/supprimé ou coordonnées hors de 0..65535. C’est un ID, pas un
# type, une quantité ni un Boolean. Les 32 bits sont conservés : tester <> 0, pas = TRUE ni > 0.
# Le même ID devient FindItem().

SUB Main()
    # x/y sont lus sur le personnage ; ids conserve la liste. Chaque ID désigne un objet, y compris
    # une pile entière. GetType(id) lit son graphic/body. Aucun objet n’est choisi ou utilisé.

    VAR x = UO.GetX('self')
    VAR y = UO.GetY('self')
    UO.FindAtCoord(x, y)
    VAR ids = UO.GetFoundItems()
    FOR EACH id IN ids
        UO.Print(HEX(id) + ' type=' + HEX(UO.GetType(id)))
    NEXT
END SUB
```

**Explication des paramètres et du déroulement:**

- x/y sont lus sur le personnage ; ids conserve la liste. Chaque ID désigne un objet, y compris une pile entière. GetType(id) lit son graphic/body. Aucun objet n’est choisi ou utilisé.

### Fonction complète CountGraphicAt

```vb
# Fonction complète CountGraphicAt
#
# Recherche les objets chargés sur une case X/Y exacte de la carte actuelle.
#
# Integer : serial du premier objet correspondant dans la liste de ce client. 0 signifie aucun
# résultat, personnage absent/supprimé ou coordonnées hors de 0..65535. C’est un ID, pas un
# type, une quantité ni un Boolean. Les 32 bits sont conservés : tester <> 0, pas = TRUE ni > 0.
# Le même ID devient FindItem().

SUB Main()
    # CountGraphicAt(x, y, graphic) effectue une recherche, parcourt les ID sauvegardés et compte
    # les graphismes correspondants. graphic=0x0EED désigne l’or. Retour : nombre d’objets/piles,
    # pas la somme des unités ni true/false ; une pile compte pour un. Définition complète après
    # Main.

    VAR count = CountGraphicAt(1445, 1690, 0x0EED)
    UO.Print('Objects/stacks: ' + CStr(count))
END SUB

FUNCTION CountGraphicAt(x, y, graphic)
    UO.FindAtCoord(x, y)
    VAR ids = UO.GetFoundItems()
    VAR count = 0
    FOR EACH id IN ids
        IF UO.GetType(id) = graphic THEN
            count += 1
        END IF
    NEXT
    RETURN count
END FUNCTION
```

**Explication des paramètres et du déroulement:**

- CountGraphicAt(x, y, graphic) effectue une recherche, parcourt les ID sauvegardés et compte les graphismes correspondants. graphic=0x0EED désigne l’or. Retour : nombre d’objets/piles, pas la somme des unités ni true/false ; une pile compte pour un. Définition complète après Main.
