# UO.Dist

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: fr -->

Calcule la distance en cases : la plus grande différence absolue entre X et Y.

## Syntaxe exacte

```text
UO.Dist(Xfrom:Any, Yfrom:Any, Xto:Any, Yto:Any) -> Integer
```

## Paramètres

- `Xfrom` — X du point de départ.
- `Yfrom` — Y du point de départ.
- `Xto` — X de destination.
- `Yto` — Y de destination.

## Retour

Distance Integer non négative pour des coordonnées valides. 0 signifie mêmes XY, 1 une case. Ce nombre n’est pas un indicateur de réussite. La comparaison séparée distance<=2 produit 1/True ou 0/False.

## Comportement

- Calcul pur sans paquets, attente, chargement de carte, contrôle des obstacles, de Z ou du monde. Ne cherche pas de chemin praticable et ne garantit pas l’arrivée. Utilisez le même repère ; un détour peut être plus long.
- Les quatre paramètres sont obligatoires : coordonnées mondiales Integer dans la plage documentée 0..65535. Any désigne l’adaptateur, pas un ID. Ni valeurs par défaut, coordonnées de conteneur, cinquième Z ni surcharge à objet unique.
- Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). Inverser les points ne change rien. Ni distance euclidienne, ni somme, ni nombre de pas autour d’un obstacle.

### Fonctions internes : de l’appel au résultat

Le troisième exemple reconstruit l’algorithme avec une fonction du script, sans prétendre être une fonction interne appelée par le moteur.

#### 1. ExecuteStealthCompatibility

L’adaptateur lit les positions 0..3 comme entiers Xfrom,Yfrom,Xto,Yto puis appelle le calcul.

Distance Integer non négative pour des coordonnées valides. 0 signifie mêmes XY, 1 une case. Ce nombre n’est pas un indicateur de réussite. La comparaison séparée distance<=2 produit 1/True ou 0/False.

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; fonction `ExecuteStealthCompatibility`.

#### 2. GetDistance

`GetDistance(int,int,int,int): dx=Math.Abs(x1-x2); dy=Math.Abs(y1-y2); return Math.Max(dx,dy).`

Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). Inverser les points ne change rien. Ni distance euclidienne, ni somme, ni nombre de pas autour d’un obstacle.

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; fonction `GetDistance`.

Calcul pur sans paquets, attente, chargement de carte, contrôle des obstacles, de Z ou du monde. Ne cherche pas de chemin praticable et ne garantit pas l’arrivée. Utilisez le même repère ; un détour peut être plus long.


## Exemples

### Calcul direct

```vb
# Calcul direct
#
# Calcule la distance en cases : la plus grande différence absolue entre X et Y.
#
# Distance Integer non négative pour des coordonnées valides. 0 signifie mêmes XY, 1 une case.
# Ce nombre n’est pas un indicateur de réussite. La comparaison séparée distance<=2 produit
# 1/True ou 0/False.

SUB Main()
    # Les différences de (100,100) à (103,104) valent 3 et 4. Maximum 4 : Main renvoie Integer 4.
    # Distance Integer non négative pour des coordonnées valides. 0 signifie mêmes XY, 1 une case.
    # Ce nombre n’est pas un indicateur de réussite. La comparaison séparée distance<=2 produit
    # 1/True ou 0/False.
    # Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). Inverser les points ne change rien. Ni distance
    # euclidienne, ni somme, ni nombre de pas autour d’un obstacle.

    Return UO.Dist(100,100,103,104)
END SUB
```

**Explication des paramètres et du déroulement:**

- Les différences de (100,100) à (103,104) valent 3 et 4. Maximum 4 : Main renvoie Integer 4.
- Distance Integer non négative pour des coordonnées valides. 0 signifie mêmes XY, 1 une case. Ce nombre n’est pas un indicateur de réussite. La comparaison séparée distance<=2 produit 1/True ou 0/False.
- Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). Inverser les points ne change rien. Ni distance euclidienne, ni somme, ni nombre de pas autour d’un obstacle.

### Interpréter le résultat

```vb
# Interpréter le résultat
#
# Calcule la distance en cases : la plus grande différence absolue entre X et Y.
#
# Distance Integer non négative pour des coordonnées valides. 0 signifie mêmes XY, 1 une case.
# Ce nombre n’est pas un indicateur de réussite. La comparaison séparée distance<=2 produit
# 1/True ou 0/False.

SUB Main()
    # Entre (100,100) et (101,99), distance=1 ; distance<=2 est True=1. Dans "1:1", le premier
    # nombre est une distance, le second un résultat logique.
    # Distance Integer non négative pour des coordonnées valides. 0 signifie mêmes XY, 1 une case.
    # Ce nombre n’est pas un indicateur de réussite. La comparaison séparée distance<=2 produit
    # 1/True ou 0/False.
    # Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). Inverser les points ne change rien. Ni distance
    # euclidienne, ni somme, ni nombre de pas autour d’un obstacle.

    Dim distance=UO.Dist(100,100,101,99)
    Dim close=distance<=2
    Return CStr(distance) & ":" & CStr(close)
END SUB
```

**Explication des paramètres et du déroulement:**

- Entre (100,100) et (101,99), distance=1 ; distance<=2 est True=1. Dans "1:1", le premier nombre est une distance, le second un résultat logique.
- Distance Integer non négative pour des coordonnées valides. 0 signifie mêmes XY, 1 une case. Ce nombre n’est pas un indicateur de réussite. La comparaison séparée distance<=2 produit 1/True ou 0/False.
- Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). Inverser les points ne change rien. Ni distance euclidienne, ni somme, ni nombre de pas autour d’un obstacle.

### Algorithme complet en script

```vb
# Algorithme complet en script
#
# Calcule la distance en cases : la plus grande différence absolue entre X et Y.
#
# Distance Integer non négative pour des coordonnées valides. 0 signifie mêmes XY, 1 une case.
# Ce nombre n’est pas un indicateur de réussite. La comparaison séparée distance<=2 produit
# 1/True ou 0/False.

SUB Main()
    # UO.Dist et RebuildTileDistance renvoient 4 ; Main renvoie "4:4". L’auxiliaire complet calcule
    # les différences Abs et retourne la plus grande. C’est du code d’exemple, pas une autre
    # commande API.
    # Distance Integer non négative pour des coordonnées valides. 0 signifie mêmes XY, 1 une case.
    # Ce nombre n’est pas un indicateur de réussite. La comparaison séparée distance<=2 produit
    # 1/True ou 0/False.
    # Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). Inverser les points ne change rien. Ni distance
    # euclidienne, ni somme, ni nombre de pas autour d’un obstacle.

    Dim actual=UO.Dist(100,100,103,104)
    Dim rebuilt=RebuildTileDistance(100,100,103,104)
    Return CStr(actual) & ":" & CStr(rebuilt)
END SUB

Function RebuildTileDistance(Xfrom, Yfrom, Xto, Yto) As Integer
    Dim dx = Abs(Xto-Xfrom)
    Dim dy = Abs(Yto-Yfrom)
    If dx>dy Then
        Return dx
    End If
    Return dy
End Function
```

**Explication des paramètres et du déroulement:**

- UO.Dist et RebuildTileDistance renvoient 4 ; Main renvoie "4:4". L’auxiliaire complet calcule les différences Abs et retourne la plus grande. C’est du code d’exemple, pas une autre commande API.
- Distance Integer non négative pour des coordonnées valides. 0 signifie mêmes XY, 1 une case. Ce nombre n’est pas un indicateur de réussite. La comparaison séparée distance<=2 produit 1/True ou 0/False.
- Max(Abs(Xto-Xfrom), Abs(Yto-Yfrom)). Inverser les points ne change rien. Ni distance euclidienne, ni somme, ni nombre de pas autour d’un obstacle.
