# Using / End Using

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: fr -->

Using ferme une ressource native à la sortie du bloc. La forme prise en charge reçoit une variable existante ou une expression qui produit une ressource.

## Syntaxe exacte

```text
Dim resource = MemoryStream()
Using resource
    statements
End Using
Using resourceExpression
    statements
End Using
```

## Paramètres

- `resourceExpression` — Évaluée une fois. File(path), MemoryStream() et CreateTimer(...) conviennent. Libérer le minuteur l’arrête définitivement ; voir Basic.Timers. String, nombre, List et Dictionary provoquent une erreur située dans le source avant le corps. Déclarez la variable avant : déclaration dans l’en-tête, As New, liste séparée par virgules et Dispose utilisateur ne sont pas pris en charge.
- `statements / End Using` — End Using ferme l’objet capturé. La variable reste visible, mais la ressource est fermée. Imbriquez les blocs pour plusieurs ressources. Réaffecter la variable ne change pas l’objet initial qui sera fermé.

## Retour

L’instruction ne renvoie rien. Return libère la ressource avant de quitter la procédure. IsClosed est une fonction de l’exemple qui renvoie 1/True ou 0/False ; Main renvoie des chaînes, pas des indicateurs de succès.

## Comportement

- File(path) crée un conteneur : appelez Create() pour écrire ou Open() pour lire dans le bloc. Dispose appelle Close(), vide le tampon et libère le handle. Après fermeture de MemoryStream, Length() échoue. Ces exemples restent en mémoire.
- Le compilateur crée une zone protégée ; l’interpréteur conserve l’objet dans l’appel courant. End Using, Return, Exit, Continue et les sauts sortants ferment de l’intérieur vers l’extérieur. Un saut entrant est refusé avant exécution.
- Une erreur normale ferme les ressources avant le Catch externe. Un Dispose échoué n’est pas réessayé ; les ressources externes sont aussi libérées. L’arrêt d’urgence saute Catch/Finally du script mais ferme les ressources natives ; une erreur de fermeture ne remplace pas l’annulation. Pause garde les ressources jusqu’à reprise ou arrêt. Aucun nouveau thread ; une fermeture bloquée par le système ne peut pas être interrompue de force.
- Placez Try/Catch dans Using pour récupérer en gardant la ressource ouverte. Avec On Error Resume Next, une erreur non interceptée du corps ferme la ressource et reprend après tout le bloc. On Error GoTo ne peut viser une étiquette dans Using, ce qui réentrerait dans une zone déjà fermée.
- Après une erreur quittant Using, Resume dans le gestionnaire externe On Error GoTo reprend tout le bloc à son en-tête et réévalue la ressource. Resume Next poursuit juste après End Using. Une variable désignant un objet fermé ne le rouvre pas : utilisez une expression créant une nouvelle ressource pour réessayer. Les actions déjà exécutées peuvent donc se répéter.

## Exemples

### 1. Fermer un flux mémoire

```vb
# stream est la ressource ; size lit Length()=0 avant fermeture. IsClosed intercepte ensuite l’erreur et renvoie True=1 ; Main renvoie "0:1". ByVal copie la référence. Cette fonction pédagogique considère toute erreur Length comme une fermeture pour ces flux seulement.
Option Explicit On
Function IsClosed(ByVal stream) As Boolean
    Try
        Dim size = stream.Length()
        Return False
    Catch closed
        Return True
    End Try
End Function

Sub Main()
    Dim stream = MemoryStream()
    Dim size = -1
    Using stream
        size = stream.Length()
    End Using
    Return CStr(size) & ":" & CStr(IsClosed(stream))
End Sub
```

**Explication des paramètres et du déroulement:**

stream est la ressource ; size lit Length()=0 avant fermeture. IsClosed intercepte ensuite l’erreur et renvoie True=1 ; Main renvoie "0:1". ByVal copie la référence. Cette fonction pédagogique considère toute erreur Length comme une fermeture pour ces flux seulement.

### 2. Quitter une fonction auxiliaire

```vb
# ReadLength(stream) calcule Integer 0. Return ferme le flux avant que Main reçoive size. Le prochain Length échoue : closed=True, résultat "0:1". Ne passez pas une ressource que l’appelant doit garder ouverte.
Option Explicit On
Function ReadLength(ByVal stream) As Integer
    Using stream
        Return stream.Length()
    End Using
End Function

Sub Main()
    Dim stream = MemoryStream()
    Dim size = ReadLength(stream)
    Dim closed = False
    Try
        Dim after = stream.Length()
    Catch problem
        closed = True
    End Try
    Return CStr(size) & ":" & CStr(closed)
End Sub
```

**Explication des paramètres et du déroulement:**

ReadLength(stream) calcule Integer 0. Return ferme le flux avant que Main reçoive size. Le prochain Length échoue : closed=True, résultat "0:1". Ne passez pas une ressource que l’appelant doit garder ouverte.

### 3. Nettoyer des blocs imbriqués

```vb
# outer et inner sont distincts. Throw "demo" ferme inner puis outer. Catch conserve le message ; IsClosed vaut 1 pour chacun. Main renvoie "demo:2". Deux compte les objets fermés, ce n’est pas un Boolean.
Option Explicit On
Function IsClosed(ByVal stream) As Boolean
    Try
        Dim size = stream.Length()
        Return False
    Catch closed
        Return True
    End Try
End Function

Sub Main()
    Dim outer = MemoryStream()
    Dim inner = MemoryStream()
    Dim message = ""
    Try
        Using outer
            Using inner
                Throw "demo"
            End Using
        End Using
    Catch problem
        message = problem
    End Try
    Return message & ":" & CStr(IsClosed(outer) + IsClosed(inner))
End Sub
```

**Explication des paramètres et du déroulement:**

outer et inner sont distincts. Throw "demo" ferme inner puis outer. Catch conserve le message ; IsClosed vaut 1 pour chacun. Main renvoie "demo:2". Deux compte les objets fermés, ce n’est pas un Boolean.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: usingStatement / USING / END_USING
Runtime/Instructions/Generator.cs: Generate(UsingStatementContext)
Runtime/Interpreter.cs: TryExecutionScope.DisposeResource / Transfer / DeferReturn / CallSubrutine
Runtime/ObjectTypes/FileObject.cs: Dispose / Close
Runtime/ObjectTypes/MemoryStreamObject.cs: Dispose
Analysis/TryStructureValidator.cs: Regions
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/using-statement
-->
