# UO.CalcDir

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: fr -->

Calcule la direction entre deux points du monde sans déplacer le personnage.

## Syntaxe exacte

```text
UO.CalcDir(Xfrom:Any, Yfrom:Any, Xto:Any, Yto:Any) -> Integer
```

## Paramètres

- `Xfrom` — X du point de départ.
- `Yfrom` — Y du point de départ.
- `Xto` — X de destination.
- `Yto` — Y de destination.

## Retour

Code Integer : 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SO, 6=O, 7=NO. Points identiques : 100. Ce n’est pas un Boolean : 0 signifie nord, pas échec ; 1 signifie nord-est, pas succès. Ne transmettez pas 100 comme direction de marche.

## Comportement

- Calcul pur sans paquets, attente, chargement de carte, contrôle des obstacles, de Z ou du monde. Ne cherche pas de chemin praticable et ne garantit pas l’arrivée. Utilisez le même repère ; un détour peut être plus long.
- Les quatre paramètres sont obligatoires : coordonnées mondiales Integer dans la plage documentée 0..65535. Any désigne l’adaptateur, pas un ID. Ni valeurs par défaut, coordonnées de conteneur, cinquième Z ni surcharge à objet unique.
- Soustrait départ de destination puis examine les signes. Y décroissant est le nord, X croissant l’est. Deux axes modifiés donnent une diagonale quelle que soit leur amplitude. Deux différences nulles donnent 100.

### Fonctions internes : de l’appel au résultat

Le troisième exemple reconstruit l’algorithme avec une fonction du script, sans prétendre être une fonction interne appelée par le moteur.

#### 1. ExecuteStealthCompatibility

L’adaptateur lit les positions 0..3 comme entiers Xfrom,Yfrom,Xto,Yto puis appelle le calcul.

Code Integer : 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SO, 6=O, 7=NO. Points identiques : 100. Ce n’est pas un Boolean : 0 signifie nord, pas échec ; 1 signifie nord-est, pas succès. Ne transmettez pas 100 comme direction de marche.

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; fonction `ExecuteStealthCompatibility`.

#### 2. CalculateDirection

`CalculateDirection: dx=Math.Sign(toX-fromX); dy=Math.Sign(toY-fromY); identical ->100; axis/sign branches ->0..7.`

Soustrait départ de destination puis examine les signes. Y décroissant est le nord, X croissant l’est. Deux axes modifiés donnent une diagonale quelle que soit leur amplitude. Deux différences nulles donnent 100.

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; fonction `CalculateDirection`.

Calcul pur sans paquets, attente, chargement de carte, contrôle des obstacles, de Z ou du monde. Ne cherche pas de chemin praticable et ne garantit pas l’arrivée. Utilisez le même repère ; un détour peut être plus long.


## Exemples

### Calcul direct

```vb
# Calcul direct
#
# Calcule la direction entre deux points du monde sans déplacer le personnage.
#
# Code Integer : 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SO, 6=O, 7=NO. Points identiques : 100. Ce n’est
# pas un Boolean : 0 signifie nord, pas échec ; 1 signifie nord-est, pas succès. Ne transmettez
# pas 100 comme direction de marche.

SUB Main()
    # (100,100) vers (101,100) : seul X augmente. Main renvoie Integer 2, est, sans déplacement.
    # Code Integer : 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SO, 6=O, 7=NO. Points identiques : 100. Ce n’est
    # pas un Boolean : 0 signifie nord, pas échec ; 1 signifie nord-est, pas succès. Ne transmettez
    # pas 100 comme direction de marche.
    # Soustrait départ de destination puis examine les signes. Y décroissant est le nord, X
    # croissant l’est. Deux axes modifiés donnent une diagonale quelle que soit leur amplitude. Deux
    # différences nulles donnent 100.

    Return UO.CalcDir(100,100,101,100)
END SUB
```

**Explication des paramètres et du déroulement:**

- (100,100) vers (101,100) : seul X augmente. Main renvoie Integer 2, est, sans déplacement.
- Code Integer : 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SO, 6=O, 7=NO. Points identiques : 100. Ce n’est pas un Boolean : 0 signifie nord, pas échec ; 1 signifie nord-est, pas succès. Ne transmettez pas 100 comme direction de marche.
- Soustrait départ de destination puis examine les signes. Y décroissant est le nord, X croissant l’est. Deux axes modifiés donnent une diagonale quelle que soit leur amplitude. Deux différences nulles donnent 100.

### Interpréter le résultat

```vb
# Interpréter le résultat
#
# Calcule la direction entre deux points du monde sans déplacer le personnage.
#
# Code Integer : 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SO, 6=O, 7=NO. Points identiques : 100. Ce n’est
# pas un Boolean : 0 signifie nord, pas échec ; 1 signifie nord-est, pas succès. Ne transmettez
# pas 100 comme direction de marche.

SUB Main()
    # Deux points (100,100) donnent direction=100 et Main renvoie "already there". Des points
    # différents prennent l’autre branche. Comparez à 100, pas à True.
    # Code Integer : 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SO, 6=O, 7=NO. Points identiques : 100. Ce n’est
    # pas un Boolean : 0 signifie nord, pas échec ; 1 signifie nord-est, pas succès. Ne transmettez
    # pas 100 comme direction de marche.
    # Soustrait départ de destination puis examine les signes. Y décroissant est le nord, X
    # croissant l’est. Deux axes modifiés donnent une diagonale quelle que soit leur amplitude. Deux
    # différences nulles donnent 100.

    Dim direction=UO.CalcDir(100,100,100,100)
    If direction=100 Then
        Return "already there"
    End If
    Return "different point"
END SUB
```

**Explication des paramètres et du déroulement:**

- Deux points (100,100) donnent direction=100 et Main renvoie "already there". Des points différents prennent l’autre branche. Comparez à 100, pas à True.
- Code Integer : 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SO, 6=O, 7=NO. Points identiques : 100. Ce n’est pas un Boolean : 0 signifie nord, pas échec ; 1 signifie nord-est, pas succès. Ne transmettez pas 100 comme direction de marche.
- Soustrait départ de destination puis examine les signes. Y décroissant est le nord, X croissant l’est. Deux axes modifiés donnent une diagonale quelle que soit leur amplitude. Deux différences nulles donnent 100.

### Algorithme complet en script

```vb
# Algorithme complet en script
#
# Calcule la direction entre deux points du monde sans déplacer le personnage.
#
# Code Integer : 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SO, 6=O, 7=NO. Points identiques : 100. Ce n’est
# pas un Boolean : 0 signifie nord, pas échec ; 1 signifie nord-est, pas succès. Ne transmettez
# pas 100 comme direction de marche.

SUB Main()
    # De (20,20) à (19,21), X baisse et Y monte. UO.CalcDir et RebuildDirection renvoient 5 ; Main
    # renvoie "5:5". L’auxiliaire complet montre chaque branche avec les mêmes quatre paramètres.
    # Code Integer : 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SO, 6=O, 7=NO. Points identiques : 100. Ce n’est
    # pas un Boolean : 0 signifie nord, pas échec ; 1 signifie nord-est, pas succès. Ne transmettez
    # pas 100 comme direction de marche.
    # Soustrait départ de destination puis examine les signes. Y décroissant est le nord, X
    # croissant l’est. Deux axes modifiés donnent une diagonale quelle que soit leur amplitude. Deux
    # différences nulles donnent 100.

    Dim actual=UO.CalcDir(20,20,19,21)
    Dim rebuilt=RebuildDirection(20,20,19,21)
    Return CStr(actual) & ":" & CStr(rebuilt)
END SUB

Function RebuildDirection(Xfrom, Yfrom, Xto, Yto) As Integer
    Dim dx = Xto-Xfrom
    Dim dy = Yto-Yfrom
    If dx=0 AndAlso dy=0 Then
        Return 100
    End If
    If dx=0 Then
        If dy<0 Then
            Return 0
        End If
        Return 4
    End If
    If dy=0 Then
        If dx>0 Then
            Return 2
        End If
        Return 6
    End If
    If dx>0 Then
        If dy<0 Then
            Return 1
        End If
        Return 3
    End If
    If dy>0 Then
        Return 5
    End If
    Return 7
End Function
```

**Explication des paramètres et du déroulement:**

- De (20,20) à (19,21), X baisse et Y monte. UO.CalcDir et RebuildDirection renvoient 5 ; Main renvoie "5:5". L’auxiliaire complet montre chaque branche avec les mêmes quatre paramètres.
- Code Integer : 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SO, 6=O, 7=NO. Points identiques : 100. Ce n’est pas un Boolean : 0 signifie nord, pas échec ; 1 signifie nord-est, pas succès. Ne transmettez pas 100 comme direction de marche.
- Soustrait départ de destination puis examine les signes. Y décroissant est le nord, X croissant l’est. Deux axes modifiés donnent une diagonale quelle que soit leur amplitude. Deux différences nulles donnent 100.
