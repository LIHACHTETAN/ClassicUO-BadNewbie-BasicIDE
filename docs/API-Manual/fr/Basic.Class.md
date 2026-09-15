# Class / New / Me / Property

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: fr -->

Class regroupe l’état et les méthodes de chaque objet. New crée une référence ; l’affectation à une autre variable conserve le même objet, contrairement à la copie de valeur Structure. Les exemples contiennent tous leurs constructeurs, méthodes et accesseurs.

## Syntaxe exacte

```text
[Public | Private] Class TypeName
    [Public | Private | Dim] field As FieldType
    Public Sub New([parameters]) ... End Sub
    [Public | Private] Sub Method([parameters]) ... End Sub
    [Public | Private] Function Method([parameters]) As ResultType ... End Function
    [Public | Private] [ReadOnly | WriteOnly] Property Name[()] As ValueType
        Get ... Return value / Name = value / Exit Property ... End Get
        Set(ByVal value As ValueType) ... End Set
    End Property
    Public Property AutoName As ValueType
End Class
Dim instance [As TypeName] = New TypeName(arguments)
instance.Property = expression
value = instance.Property
instance.Method(arguments)
With instance ... End With
```

## Paramètres

- `TypeName / Public / Private` — TypeName est un nom simple unique au niveau fichier ou Module ; utilisez ModuleName.TypeName à l’extérieur. Class est Public par défaut ; Private Class reste dans son Module. Héritage, interfaces, génériques, classes imbriquées, Shared, surcharges, destructeurs et déclarations Event d’instance ne sont pas implémentés.
- `field As FieldType / Me` — Un champ exige As Integer, Double, Boolean, String, Object ou un Enum, Structure, Class déclaré ; les alias Basic existants restent valables. Les champs sont Private par défaut, Public doit être explicite. Valeurs initiales : nombres/Boolean 0, String vide, Structure à champs nuls, Object/Class Nothing (Unit). Initialisez autrement dans Sub New. Me désigne l’instance et ne peut être redéclaré/réaffecté ; paramètres et variables locales peuvent masquer les autres membres.
- `New / Sub New` — New TypeName(arguments) crée des champs propres et exécute une fois Public Sub New. Sans constructeur, seul New TypeName() convient. Un seul constructeur est admis ; Optional, valeurs par défaut et arguments nommés suivent les règles habituelles. Les arguments sont évalués une fois dans leur ordre d’écriture ; une erreur empêche de renvoyer l’objet construit. As TypeName sans New laisse Nothing.
- `Sub / Function / arguments` — Appelez Sub/Function par instance.Method(...), ou Method(...)/Me.Method(...) dans la classe. Private est réservé à cette Class, y compris sur une autre instance du même type. Types, ByVal/ByRef, Optional, ParamArray et arguments nommés fonctionnent ; pas d’éléments ParamArray nommés. Function renvoie son type, Sub Unit. TypeName.Method(...) et instance.New(...) sont interdits ; AddressOf nécessite une procédure enveloppe au niveau fichier/module.
- `Property / Get / Set` — Property Name[()] As ValueType n’a pas de paramètres d’index. Lisez instance.Name sans parenthèses d’appel. Get renvoie Return ou l’affectation à Name ; Exit Property restitue ce résultat/défaut. L’affectation appelle Set(ByVal value As ValueType), sans lire le dernier Get. Une propriété ordinaire exige un Get et un Set. La visibilité se place sur Property ; Set exige un paramètre ByVal explicite du même type.
- `ReadOnly / WriteOnly / auto Property` — ReadOnly avec corps a seulement Get, WriteOnly seulement Set ; un accès interdit produit une erreur interceptable. Une propriété automatique stocke directement sans Get/Set ni End Property. Son ReadOnly ne peut être affecté que dans le Sub New de cette instance ; WriteOnly sans Set est invalide. Un résultat ReadOnly de type Class peut garder des membres modifiables.
- `ByVal / ByRef / With` — ByVal copie la référence : modifier les membres touche l’original, remplacer le paramètre ne remplace pas la variable appelante. ByRef réécrit aussi une nouvelle référence selon les règles copy-in/copy-out du moteur. L’égalité teste l’identité des objets. With instance capture une fois l’objet et accepte champs, propriétés, méthodes. Class n’est pas automatiquement IDisposable ; Using concerne les ressources prises en charge.

## Retour

New renvoie Object contenant une référence Class, pas une ID/graphique UO. Get et Function renvoient leur type ; Set, Sub et déclarations Unit. Sans New : Nothing. Égalité de références et As Boolean utilisent 1/True ou 0/False ; une quantité Integer n’est pas automatiquement un succès. Main renvoie "5:2:1", "1:0:6", "ore:1:replacement:0".

## Comportement

- SC032 refuse les déclarations invalides avant exécution, même sans Option Explicit. Limites : 256 classes, 256 champs/propriétés et 256 méthodes par classe ; 32 appels imbriqués, New/Get/Set inclus. Chemins d’affectation/ByRef : 64 composants. Les cycles de références sont permis ; métadonnées/défauts sont préparés et chaque New possède son stockage mutable.
- Le chemin du destinataire est capturé avant la partie droite/les arguments ; chaque Get du chemin est évalué une fois. La réécriture conserve la cible initiale même si une procédure remplace une variable du chemin. Les valeurs sont converties au type déclaré. Try/Catch traite les erreurs des constructeurs, méthodes et accesseurs sans annuler les changements antérieurs.
- Pause, arrêt, lignes source et limite de profondeur utilisent les cadres ordinaires du script. Fermer IDE ne termine pas le script. L’inspecteur affiche type/nombre de membres sans Get ni parcours de cycles. Watch peut lire les champs/propriétés automatiques, mais pas exécuter Get personnalisé, méthodes ou New. Ce sous-ensemble ne permet pas les classes .NET arbitraires.

## Exemples

### 1. Objets séparés et référence partagée

```vb
# New Counter(label:="ore", start:=2) reçoit String label et Integer start, puis affecte Label/stored. second a ses propres champs ; alias=first copie la référence. Add(amount:=3) écrit par Value.Set, vérifie la valeur négative, puis renvoie Integer par Value.Get. first vaut 5, second 2, alias=first donne 1/True. Toutes les méthodes sont visibles.
Option Explicit On
Class Counter
    Private stored As Integer
    Public Property Label As String
    Public Sub New(ByVal label As String, ByVal start As Integer)
        Me.Label = label
        stored = start
    End Sub
    Public Property Value As Integer
        Get
            Return stored
        End Get
        Set(ByVal value As Integer)
            If value < 0 Then
                Throw "Value must be non-negative"
            End If
            stored = value
        End Set
    End Property
    Public Function Add(ByVal amount As Integer) As Integer
        Me.Value = stored + amount
        Return Me.Value
    End Function
End Class

Sub Main()
    Dim first = New Counter(label:="ore", start:=2)
    Dim second = New Counter("wood", 2)
    Dim alias = first
    alias.Add(amount:=3)
    Return CStr(first.Value) & ":" & CStr(second.Value) & ":" & CStr(alias = first)
End Sub
```

**Explication des paramètres et du déroulement:**

New Counter(label:="ore", start:=2) reçoit String label et Integer start, puis affecte Label/stored. second a ses propres champs ; alias=first copie la référence. Add(amount:=3) écrit par Value.Set, vérifie la valeur négative, puis renvoie Integer par Value.Get. first vaut 5, second 2, alias=first donne 1/True. Toutes les méthodes sont visibles.

### 2. Lecture, écriture et Boolean

```vb
# Limit=10 appelle Set avec value=10. Remaining.Get affecte le nom résultat puis Exit Property. TrySpend(cost:=4) soustrait quatre et renvoie 1/True ; cost=9 dépasse les six restants et renvoie 0/False. Limit=-3 lève avant modification ; Catch lit Remaining=6. Main donne "1:0:6", sans action serveur.
Option Explicit On
Class Budget
    Private amount As Integer
    Public ReadOnly Property Remaining() As Integer
        Get
            Remaining = amount
            Exit Property
        End Get
    End Property
    Public WriteOnly Property Limit As Integer
        Set(ByVal value As Integer)
            If value < 0 Then
                Throw "Limit must be non-negative"
            End If
            amount = value
        End Set
    End Property
    Public Function TrySpend(ByVal cost As Integer) As Boolean
        If cost < 0 Then
            Throw "cost must be non-negative"
        End If
        If cost > amount Then
            Return False
        End If
        amount -= cost
        Return True
    End Function
End Class

Sub Main()
    Dim budget = New Budget()
    budget.Limit = 10
    Dim paid = budget.TrySpend(4)
    Dim refused = budget.TrySpend(9)
    Try
        budget.Limit = -3
    Catch problem
        Return CStr(paid) & ":" & CStr(refused) & ":" & CStr(budget.Remaining)
    End Try
    Return "unexpected"
End Sub
```

**Explication des paramètres et du déroulement:**

Limit=10 appelle Set avec value=10. Remaining.Get affecte le nom résultat puis Exit Property. TrySpend(cost:=4) soustrait quatre et renvoie 1/True ; cost=9 dépasse les six restants et renvoie 0/False. Limit=-3 lève avant modification ; Catch lit Remaining=6. Main donne "1:0:6", sans action serveur.

### 3. Module, ByVal et remplacement ByRef

```vb
# Jobs.WorkItem(name) stocke String Name et initialise Done à zéro. Tick(ByVal job) porte le Done partagé à 1, puis ne remplace que son paramètre local par "local". Replace(ByRef job, ByVal name) crée "replacement" et réécrit la référence appelante ; les arguments nommés sont volontairement inversés. original reste "ore"/1 ; job devient "replacement"/0. Module Jobs est complet.
Option Explicit On
Module Jobs
    Public Class WorkItem
        Public Property Name As String
        Public Done As Integer
        Public Sub New(ByVal name As String)
            Me.Name = name
        End Sub
    End Class
    Public Sub Tick(ByVal job As WorkItem)
        job.Done += 1
        job = New WorkItem("local")
    End Sub
    Public Sub Replace(ByRef job As WorkItem, ByVal name As String)
        job = New WorkItem(name)
    End Sub
End Module

Sub Main()
    Dim job As Jobs.WorkItem = New Jobs.WorkItem("ore")
    Dim original = job
    Jobs.Tick(job)
    Jobs.Replace(name:="replacement", job:=job)
    Return original.Name & ":" & CStr(original.Done) & ":" & job.Name & ":" & CStr(job.Done)
End Sub
```

**Explication des paramètres et du déroulement:**

Jobs.WorkItem(name) stocke String Name et initialise Done à zéro. Tick(ByVal job) porte le Done partagé à 1, puis ne remplace que son paramètre local par "local". Replace(ByRef job, ByVal name) crée "replacement" et réécrit la référence appelante ; les arguments nommés sont volontairement inversés. original reste "ore"/1 ; job devient "replacement"/0. Module Jobs est complet.


### Fonctions internes : de l’appel au résultat

Class regroupe l’état et les méthodes de chaque objet. New crée une référence ; l’affectation à une autre variable conserve le même objet, contrairement à la copie de valeur Structure. Les exemples contiennent tous leurs constructeurs, méthodes et accesseurs.

#### 1. ClassCatalog.Build / Complete

SC032 refuse les déclarations invalides avant exécution, même sans Option Explicit. Limites : 256 classes, 256 champs/propriétés et 256 méthodes par classe ; 32 appels imbriqués, New/Get/Set inclus. Chemins d’affectation/ByRef : 64 composants. Les cycles de références sont permis ; métadonnées/défauts sont préparés et chaque New possède son stockage mutable.

`declarations -> unique typed members -> accessor validation -> prepared metadata; SC032 on invalid Class`

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/ClassCatalog.cs`; fonction `ClassCatalog.Build / Complete`.

#### 2. ConstructClass

New TypeName(arguments) crée des champs propres et exécute une fois Public Sub New. Sans constructeur, seul New TypeName() convient. Un seul constructeur est admis ; Optional, valeurs par défaut et arguments nommés suivent les règles habituelles. Les arguments sont évalués une fois dans leur ordre d’écriture ; une erreur empêche de renvoyer l’objet construit. As TypeName sans New laisse Nothing.

`new instance -> independent field slots -> bind constructor arguments -> Sub New -> Object reference`

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Classes.cs`; fonction `ConstructClass`.

#### 3. ClassObject.Member / Read

Property Name[()] As ValueType n’a pas de paramètres d’index. Lisez instance.Name sans parenthèses d’appel. Get renvoie Return ou l’affectation à Name ; Exit Property restitue ce résultat/défaut. L’affectation appelle Set(ByVal value As ValueType), sans lire le dernier Get. Une propriété ordinaire exige un Get et un Set. La visibilité se place sur Property ; Set exige un paramètre ByVal explicite du même type.

`check member visibility -> stored value OR Get frame -> declared value type`

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ClassObject.cs`; fonction `ClassObject.Member / Read`.

#### 4. MemberAccess.Resolve / ClassObject.Write

Le chemin du destinataire est capturé avant la partie droite/les arguments ; chaque Get du chemin est évalué une fois. La réécriture conserve la cible initiale même si une procédure remplace une variable du chemin. Les valeurs sont converties au type déclaré. Try/Catch traite les erreurs des constructeurs, méthodes et accesseurs sans annuler les changements antérieurs.

`capture receiver once -> evaluate RHS/arguments -> coerce value -> Set OR stored slot`

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/MemberAccess.cs`; fonction `MemberAccess.Resolve / ClassObject.Write`.

#### 5. CallClassMethod / CallSubrutine

Appelez Sub/Function par instance.Method(...), ou Method(...)/Me.Method(...) dans la classe. Private est réservé à cette Class, y compris sur une autre instance du même type. Types, ByVal/ByRef, Optional, ParamArray et arguments nommés fonctionnent ; pas d’éléments ParamArray nommés. Function renvoie son type, Sub Unit. TypeName.Method(...) et instance.New(...) sont interdits ; AddressOf nécessite une procédure enveloppe au niveau fichier/module.

`check method visibility -> bind named/positional arguments -> Me frame -> return -> ByRef copy-out`

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Classes.cs`; fonction `CallClassMethod / CallSubrutine`.

#### 6. ClassObject.DisplayValue

Pause, arrêt, lignes source et limite de profondeur utilisent les cadres ordinaires du script. Fermer IDE ne termine pas le script. L’inspecteur affiche type/nombre de membres sans Get ni parcours de cycles. Watch peut lire les champs/propriétés automatiques, mais pas exécuter Get personnalisé, méthodes ou New. Ce sous-ensemble ne permet pas les classes .NET arbitraires.

`debugger: type + member count; no getter calls and no traversal of reference cycles`

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ClassObject.cs`; fonction `ClassObject.DisplayValue`.

New renvoie Object contenant une référence Class, pas une ID/graphique UO. Get et Function renvoient leur type ; Set, Sub et déclarations Unit. Sans New : Nothing. Égalité de références et As Boolean utilisent 1/True ou 0/False ; une quantité Integer n’est pas automatiquement un succès. Main renvoie "5:2:1", "1:0:6", "ore:1:replacement:0".

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: classDeclaration / classProperty / subrutine / newStructure
Runtime/ClassCatalog.cs: Build / Complete
Runtime/ObjectTypes/ClassObject.cs: Member / Read / Write
Runtime/Interpreter.Classes.cs: ConstructClass / CallClassMethod / InvokeAccessor
Runtime/MemberAccess.cs: Resolve / Read / Write
Runtime/SemanticScope.cs: TryMemberSlot / Coerce
Runtime/Interpreter.cs: CallSubrutine / CreateArgumentWriter
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/class-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/property-statement
-->
