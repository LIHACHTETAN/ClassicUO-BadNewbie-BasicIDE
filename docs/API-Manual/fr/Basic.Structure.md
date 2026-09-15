# Structure / New / fields

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: fr -->

Structure regroupe des champs typés, par exemple X, Y et Z, en une valeur. Le moteur prend en charge les structures de données copiées par valeur, sans prétendre implémenter tout Structure de VB.NET.

## Syntaxe exacte

```text
[Public | Private] Structure TypeName
    [Public | Dim | VAR] field As FieldType
End Structure
Dim value As TypeName
Dim value = New TypeName()
copy = value
value.field = expression
Sub Change(ByRef value As TypeName)
Function Copy(ByVal value As TypeName) As TypeName
```

## Paramètres

- `TypeName / Public / Private` — Nom de type simple et unique, au niveau du fichier ou dans Module. Public par défaut. Private est permis uniquement dans Module ; le nom du type reste inaccessible à l’extérieur. Type public de module : ModuleName.TypeName. Les mots-clés et noms de champs ne sont pas traduits.
- `field / FieldType` — Nom de champ unique, As et un type scalaire pris en charge, Enum ou une autre Structure. Champs publics ; syntaxes Public, Dim et VAR acceptées. Types : Integer/Long/Short/Byte, Single/Double/Decimal, String, Boolean/Bool, Object/Variant. Les alias entiers utilisent 32 bits signés. Aucun cycle entre structures imbriquées.
- `Dim / New` — Dim value As TypeName et New TypeName() créent la valeur initiale sans appel de script. New exige des parenthèses vides : affectez X/Y/Z ensuite. Dim copy = value reprend la valeur de l’expression. Aucun préfixe UO.
- `value.field / copy` — Le point permet de lire ou écrire un champ, y compris route.Start.X. L’écriture vérifie le type et remplace la valeur qui contient le champ. copy = value copie les champs scalaires et les structures imbriquées ; changer copy.X ne change pas value.X. Les types doivent être compatibles.
- `ByVal / ByRef` — ByVal transmet une copie. ByRef copie à l’entrée puis réécrit la valeur chez l’appelant à la sortie, y compris pour un argument de champ modifiable. Précisez le modificateur ; sinon les règles Basic existantes s’appliquent. Return peut renvoyer une structure ; Function peut déclarer As TypeName.

## Retour

Les déclarations et affectations ne renvoient rien (Unit). New et les fonctions correspondantes renvoient une valeur de structure, représentée comme Object dans les observations avec son nom de type. Les coordonnées sont des nombres, pas des indicateurs Boolean. = et <> renvoient 1/True ou 0/False. Résultats String : "1445:1447:1690:0", "10:15:24", "2:4:2:2".

## Comportement

- Les déclarations sont vérifiées avant les initialiseurs : 256 types maximum, 1–256 champs chacun, 32 niveaux imbriqués. Doublons, types de champs inconnus, cycles et dépassements produisent SC030. La liaison des noms vérifie Private.
- Valeurs initiales : entier/Enum 0, flottant 0, Boolean 0/False, String vide, Object/Variant Unit avant affectation. Les structures imbriquées ont leurs propres valeurs initiales. Les initialiseurs de champs dans la déclaration ne sont pas acceptés : affectez les valeurs après création.
- Les champs Object et tableaux conservent leurs références lors de la copie. Les copies peuvent donc partager un List, Dictionary ou tableau. Les champs scalaires et structures imbriquées changent indépendamment ; modifier une collection partagée est visible dans les deux copies. List conserve la valeur au moment de l’ajout.
- = compare le même type déclaré et ses champs ; <> donne l’inverse. Les références sont comparées par identité. Il s’agit d’une extension du moteur, pas d’une règle universelle de VB.NET. Les hachages conservés et les paires déjà visitées évitent de développer plusieurs fois les mêmes valeurs imbriquées.
- Sont pris en charge : champs de données publics typés, visibilité dans Module, New(), affectation, paramètres et résultats. Pas de méthodes internes, constructeurs personnalisés, initialiseurs, propriétés, héritage ni champs privés. WITH .field et array[index].field ne sont pas acceptés : lire dans une variable, modifier, puis réécrire. Les déclarations peuvent figurer dans Include.

## Exemples

### 1. Coordonnées et copie indépendante

```vb
# original reçoit X=1445 et Y=1690 ; Z reste 0. copy reçoit la valeur, puis copy.X += 2 modifie uniquement la copie. New Position() crée empty avec Z=0. Résultat : 1445:1447:1690:0. Ces coordonnées sont stockées ; aucun déplacement du personnage n’est lancé.
Option Explicit On
Structure Position
    Public X As Integer
    Public Y As Integer
    Public Z As Integer
End Structure

Sub Main()
    Dim original As Position
    original.X = 1445
    original.Y = 1690
    Dim copy = original
    copy.X += 2
    Dim empty = New Position()
    Return CStr(original.X) & ":" & CStr(copy.X) & ":" & CStr(copy.Y) & ":" & CStr(empty.Z)
End Sub
```

**Explication des paramètres et du déroulement:**

original reçoit X=1445 et Y=1690 ; Z reste 0. copy reçoit la valeur, puis copy.X += 2 modifie uniquement la copie. New Position() crée empty avec Z=0. Résultat : 1445:1447:1690:0. Ces coordonnées sont stockées ; aucun déplacement du personnage n’est lancé.

### 2. Route imbriquée, ByVal et ByRef

```vb
# Route contient Start et Finish de type Position. Shift(point ByVal, dx ByVal) ajoute dx au X de la copie puis renvoie Position. point:=route.Start et dx:=5 donnent shifted.X=15 ; Start.X reste 10. Advance(route ByRef, dx ByVal) ajoute 4 à Finish.X puis réécrit Route : 24. Main renvoie 10:15:24. Toutes les procédures auxiliaires sont montrées.
Option Explicit On
Structure Position
    Public X As Integer
    Public Y As Integer
End Structure
Structure Route
    Public Start As Position
    Public Finish As Position
End Structure

Function Shift(ByVal point As Position, ByVal dx As Integer) As Position
    point.X += dx
    Return point
End Function

Sub Advance(ByRef route As Route, ByVal dx As Integer)
    route.Finish.X += dx
End Sub

Sub Main()
    Dim route As Route
    route.Start.X = 10
    route.Finish.X = 20
    Dim shifted = Shift(point:=route.Start, dx:=5)
    Advance(route:=route, dx:=4)
    Return CStr(route.Start.X) & ":" & CStr(shifted.X) & ":" & CStr(route.Finish.X)
End Sub
```

**Explication des paramètres et du déroulement:**

Route contient Start et Finish de type Position. Shift(point ByVal, dx ByVal) ajoute dx au X de la copie puis renvoie Position. point:=route.Start et dx:=5 donnent shifted.X=15 ; Start.X reste 10. Advance(route ByRef, dx ByVal) ajoute 4 à Finish.X puis réécrit Route : 24. Main renvoie 10:15:24. Toutes les procédures auxiliaires sont montrées.

### 3. Valeur conservée et collection partagée

```vb
# Entry contient Point comme valeur et Items comme Object. first.Point.X=2 ; Items reçoit List() avec un texte. snapshots.Add(first) conserve la valeur. second=first puis second.Point.X=4 ne changent pas le 2 conservé. second.Items.Add("ingot") modifie la liste partagée : first.Items.Count()=2. saved=snapshots[0] permet de lire les champs de l’élément. Résultat : 2:4:2:2.
Option Explicit On
Structure Position
    Public X As Integer
End Structure
Structure Entry
    Public Point As Position
    Public Items As Object
End Structure

Sub Main()
    Dim first As Entry
    first.Point.X = 2
    first.Items = List()
    first.Items.Add("ore")
    Dim snapshots = List()
    snapshots.Add(first)

    Dim second = first
    second.Point.X = 4
    second.Items.Add("ingot")
    Dim saved = snapshots[0]
    Return CStr(first.Point.X) & ":" & CStr(second.Point.X) & ":" & CStr(saved.Point.X) & ":" & CStr(first.Items.Count())
End Sub
```

**Explication des paramètres et du déroulement:**

Entry contient Point comme valeur et Items comme Object. first.Point.X=2 ; Items reçoit List() avec un texte. snapshots.Add(first) conserve la valeur. second=first puis second.Point.X=4 ne changent pas le 2 conservé. second.Items.Add("ingot") modifie la liste partagée : first.Items.Count()=2. saved=snapshots[0] permet de lire les champs de l’élément. Résultat : 2:4:2:2.


### Fonctions internes : de l’appel au résultat

Structure regroupe des champs typés, par exemple X, Y et Z, en une valeur. Le moteur prend en charge les structures de données copiées par valeur, sans prétendre implémenter tout Structure de VB.NET.

#### 1. Build / PrepareDefault

Les déclarations sont vérifiées avant les initialiseurs : 256 types maximum, 1–256 champs chacun, 32 niveaux imbriqués. Doublons, types de champs inconnus, cycles et dépassements produisent SC030. La liaison des noms vérifie Private.

`declarations -> field types -> visibility -> cycle/depth checks -> immutable defaults`

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/StructureCatalog.cs`; fonction `Build / PrepareDefault`.

#### 2. VisitNewStructure

Dim value As TypeName et New TypeName() créent la valeur initiale sans appel de script. New exige des parenthèses vides : affectez X/Y/Z ensuite. Dim copy = value reprend la valeur de l’expression. Aucun préfixe UO.

`resolve TypeName -> prepared default value; no procedure call`

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.cs`; fonction `VisitNewStructure`.

#### 3. WithField / SetVar

Le point permet de lire ou écrire un champ, y compris route.Start.X. L’écriture vérifie le type et remplace la valeur qui contient le champ. copy = value copie les champs scalaires et les structures imbriquées ; changer copy.X ne change pas value.X. Les types doivent être compatibles.

`resolve path -> coerce field -> replace path -> assign new root value`

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/StructureObject.cs`; fonction `WithField / SetVar`.

#### 4. CreateArgumentWriter

ByVal transmet une copie. ByRef copie à l’entrée puis réécrit la valeur chez l’appelant à la sortie, y compris pour un argument de champ modifiable. Précisez le modificateur ; sinon les règles Basic existantes s’appliquent. Return peut renvoyer une structure ; Function peut déclarer As TypeName.

`ByVal: value copy; ByRef: value copy -> callee -> caller slot write-back`

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.cs`; fonction `CreateArgumentWriter`.

#### 5. ValueEquals

= compare le même type déclaré et ses champs ; <> donne l’inverse. Les références sont comparées par identité. Il s’agit d’une extension du moteur, pas d’une règle universelle de VB.NET. Les hachages conservés et les paires déjà visitées évitent de développer plusieurs fois les mêmes valeurs imbriquées.

`type identity -> cached hash -> distinct field pairs; reference members keep identity`

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/StructureObject.cs`; fonction `ValueEquals`.

Les déclarations et affectations ne renvoient rien (Unit). New et les fonctions correspondantes renvoient une valeur de structure, représentée comme Object dans les observations avec son nom de type. Les coordonnées sont des nombres, pas des indicateurs Boolean. = et <> renvoient 1/True ou 0/False. Résultats String : "1445:1447:1690:0", "10:15:24", "2:4:2:2".

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: structureDeclaration / structureField / newStructure
Runtime/StructureCatalog.cs: Build / PrepareDefault
Runtime/ObjectTypes/StructureObject.cs: ReadField / WithField / ValueEquals
Runtime/BasicSyntaxPreprocessor.cs: NormalizeDim
Runtime/InjectionRuntime.cs: ScriptDeclarations / Load
Runtime/ScriptBindings.cs: Variable / CheckStructureType / CallName
Runtime/SemanticScope.cs: TryMemberRoot / SetVar / Coerce
Runtime/Interpreter.cs: VisitNewStructure / CreateArgumentWriter
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/structure-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/programming-guide/language-features/data-types/structure-variables
-->
