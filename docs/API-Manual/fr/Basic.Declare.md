# Declare / Lib / Alias

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: fr -->

Declare associe un nom de procédure Basic à un export d’une DLL native Windows x64. Ce sous-ensemble fonctionne dans le client compilé sans génération de code à l’exécution ; il ne représente pas toute l’interopérabilité VB.NET.

## Syntaxe exacte

```text
[Public | Private] Declare [Ansi | Unicode | Auto] Function name Lib "library.dll" [Alias "export"]([ByVal arg As Type, ...]) As ResultType
[Public | Private] Declare [Ansi | Unicode | Auto] Sub name Lib "library.dll" [Alias "export"]([ByVal arg As Type, ...])
name(arguments)
name(argumentName:=value)
ModuleName.name(arguments)
```

## Paramètres

- `name / Public / Private` — Nom local insensible à la casse, appelé sans UO. Déclaration au niveau du fichier ou du Module, sans corps ni End Function/End Sub. Public par défaut ; Private dans un Module. Ne peut masquer une commande Basic/UO intégrée : choisir un autre nom et Alias.
- `Lib / library.dll` — Nom ou chemin .dll obligatoire. Un nom système simple est cherché dans System32 en premier ; sinon le chemin relatif part du fichier déclarant, y compris Include. Chemins absolus acceptés. Le répertoire courant et PATH ne sont pas parcourus. Les dépendances peuvent être à côté de la DLL ou dans System32.
- `Alias / export` — Nom d’export exact et sensible à la casse, facultatif ; par défaut le nom local simple. Les ordinaux ne sont pas pris en charge. Il faut une fonction native Windows x64 correspondant exactement à la signature, pas une méthode .NET managée.
- `Ansi / Unicode / Auto` — Ansi, par défaut, copie le texte dans l’encodage ANSI Windows, avec perte possible des caractères non représentables. Unicode utilise UTF-16. Les deux cherchent le nom exact. Auto utilise UTF-16, essaie le nom exact puis ajoute W. L’encodage réel de l’export ne peut pas être deviné : préférer Unicode et un export W explicite.
- `ByVal arg As Type` — De zéro à quatre paramètres explicitement ByVal et As Integer, Double, Boolean ou String. Integer : 32 bits signés ; Double : 64 bits ; Boolean : BOOL Windows 32 bits, pas bool C/C++. String est une copie temporaire en lecture seule, terminée par NUL, limitée à 1048576 unités UTF-16 sans NUL interne. La DLL ne doit ni conserver le pointeur ni écrire dans le tampon. Arguments nommés selon les noms locaux. ByRef, Optional, ParamArray, tableaux, structures et pointeurs non pris en charge.
- `As ResultType / Sub` — Function exige As Integer, Double ou Boolean. Sub n’a pas de As et produit Unit. Les arguments Integer/Boolean doivent déjà être Integer ; Double accepte aussi Integer. Utiliser explicitement CInt/CDbl/CStr si nécessaire. Les retours de chaînes, pointeurs ou entiers 64 bits nécessitent un adaptateur natif avec une signature prise en charge.

## Retour

Integer renvoie un nombre signé 32 bits dont le sens dépend de la fonction native, pas automatiquement un succès. Double renvoie un flottant 64 bits. As Boolean transforme zéro en 0/False et tout autre BOOL en 1/True ; pour ces indicateurs normalisés, comparer à 1/0 ou True/False est équivalent. Sub ne renvoie rien (Unit). Exemples : 1, "3:8", "missing export:1".

## Comportement

- Une déclaration non prise en charge est rejetée avant exécution avec SC031. Limites : 256 déclarations et 64 bibliothèques chargées par script principal. Analyse et complétion ne chargent pas de DLL. La signature native réelle reste inconnue : une déclaration incorrecte peut faire planter le client.
- Le premier appel charge la DLL ; les suivants réutilisent la bibliothèque et l’adresse. Les expressions sont évaluées une fois dans l’ordre source puis réordonnées par nom. Try/Catch intercepte les erreurs de chargement, architecture, export et conversion. Une violation mémoire native n’est pas une erreur de script normalement récupérable.
- Les chaînes temporaires sont libérées après chaque appel, même après erreur de conversion. Les bibliothèques sont libérées à la fin, à l’échec ou à l’annulation du script principal. Fermer seulement l’IDE conserve le script et ses bibliothèques.
- Appel synchrone sur le worker du script. Pause et arrêt sont contrôlés avant et après ; une fonction native qui ne revient jamais ne peut pas être interrompue par le moteur. Employer des opérations courtes et Basic Wait pour attendre. Pas de DLL managée, rappel vers Basic, export variadique ou API arbitraire à pointeurs.

## Exemples

### 1. ID du processus client

```vb
# ClientProcessId appelle GetCurrentProcessId dans kernel32.dll sans paramètre. Main place l’ID Windows numérique dans processId. La comparaison processId > 0 produit 1/True ; l’ID lui-même n’est ni Boolean ni numéro de série UO.
Option Explicit On
Declare Function ClientProcessId Lib "kernel32.dll" Alias "GetCurrentProcessId"() As Integer

Sub Main()
    Dim processId = ClientProcessId()
    Return processId > 0
End Sub
```

**Explication des paramètres et du déroulement:**

ClientProcessId appelle GetCurrentProcessId dans kernel32.dll sans paramètre. Main place l’ID Windows numérique dans processId. La comparaison processId > 0 produit 1/True ; l’ID lui-même n’est ni Boolean ni numéro de série UO.

### 2. Texte, puissance et arguments nommés

```vb
# TextLength(text) transmet de l’UTF-16 à lstrlenW et renvoie la longueur. Power(value, exponent) appelle pow avec deux Double. Describe("ore", 2, 3) reçoit les trois arguments, écrit ceux de Power dans l’ordre inverse grâce aux noms et renvoie "3:8". Toutes les fonctions auxiliaires sont montrées.
Option Explicit On
Declare Unicode Function TextLength Lib "kernel32.dll" Alias "lstrlenW"(ByVal text As String) As Integer
Declare Function Power Lib "ucrtbase.dll" Alias "pow"(ByVal value As Double, ByVal exponent As Double) As Double

Function Describe(ByVal text As String, ByVal value As Double, ByVal exponent As Double) As String
    Dim length = TextLength(text:=text)
    Dim powered = Power(exponent:=exponent, value:=value)
    Return CStr(length) & ":" & CStr(powered)
End Function

Sub Main()
    Return Describe("ore", 2, 3)
End Sub
```

**Explication des paramètres et du déroulement:**

TextLength(text) transmet de l’UTF-16 à lstrlenW et renvoie la longueur. Power(value, exponent) appelle pow avec deux Double. Describe("ore", 2, 3) reçoit les trois arguments, écrit ceux de Power dans l’ordre inverse grâce aux noms et renvoie "3:8". Toutes les fonctions auxiliaires sont montrées.

### 3. Export absent

```vb
# NativeDemo.MissingExport désigne volontairement un export absent. TryRead intercepte l’erreur, fixe status="missing export" et Finally fixe finished=1. Main renvoie "missing export:1". Private garde la déclaration dans le module. Ce Finally illustre une erreur ordinaire, sans promettre le nettoyage du script après annulation d’urgence.
Option Explicit On
Module NativeDemo
    Private Declare Function MissingExport Lib "kernel32.dll" Alias "BasicManualMissingExport_71cf"() As Integer
    Public Function TryRead() As String
        Dim status = "unexpected export"
        Dim finished = 0
        Try
            MissingExport()
        Catch problem
            status = "missing export"
        Finally
            finished = 1
        End Try
        Return status & ":" & CStr(finished)
    End Function
End Module

Sub Main()
    Return NativeDemo.TryRead()
End Sub
```

**Explication des paramètres et du déroulement:**

NativeDemo.MissingExport désigne volontairement un export absent. TryRead intercepte l’erreur, fixe status="missing export" et Finally fixe finished=1. Main renvoie "missing export:1". Private garde la déclaration dans le module. Ce Finally illustre une erreur ordinaire, sans promettre le nettoyage du script après annulation d’urgence.


### Fonctions internes : de l’appel au résultat

Declare associe un nom de procédure Basic à un export d’une DLL native Windows x64. Ce sous-ensemble fonctionne dans le client compilé sans génération de code à l’exécution ; il ne représente pas toute l’interopérabilité VB.NET.

#### 1. ExternalDeclaration

Une déclaration non prise en charge est rejetée avant exécution avec SC031. Limites : 256 déclarations et 64 bibliothèques chargées par script principal. Analyse et complétion ne chargent pas de DLL. La signature native réelle reste inconnue : une déclaration incorrecte peut faire planter le client.

`source -> typed declaration -> SC031 on unsupported ABI`

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/ExternalDeclaration.cs`; fonction `ExternalDeclaration`.

#### 2. LibraryPath / GetCallable

Nom ou chemin .dll obligatoire. Un nom système simple est cherché dans System32 en premier ; sinon le chemin relatif part du fichier déclarant, y compris Include. Chemins absolus acceptés. Le répertoire courant et PATH ne sont pas parcourus. Les dépendances peuvent être à côté de la DLL ou dans System32.

`first call -> absolute DLL path -> cached library -> exact export`

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/ExternalLibraries.cs`; fonction `LibraryPath / GetCallable`.

#### 3. Invoke

De zéro à quatre paramètres explicitement ByVal et As Integer, Double, Boolean ou String. Integer : 32 bits signés ; Double : 64 bits ; Boolean : BOOL Windows 32 bits, pas bool C/C++. String est une copie temporaire en lecture seule, terminée par NUL, limitée à 1048576 unités UTF-16 sans NUL interne. La DLL ne doit ni conserver le pointeur ni écrire dans le tampon. Arguments nommés selon les noms locaux. ByRef, Optional, ParamArray, tableaux, structures et pointeurs non pris en charge.

`evaluate arguments once -> validate kinds -> copy input strings -> select compiled call shape`

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/ExternalLibraries.cs`; fonction `Invoke`.

#### 4. CallInteger / CallDouble / CallVoid

Function exige As Integer, Double ou Boolean. Sub n’a pas de As et produit Unit. Les arguments Integer/Boolean doivent déjà être Integer ; Double accepte aussi Integer. Utiliser explicitement CInt/CDbl/CStr si nécessaire. Les retours de chaînes, pointeurs ou entiers 64 bits nécessitent un adaptateur natif avec une signature prise en charge.

`Windows x64 argument slots -> native call -> declared result`

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/ExternalCallSites.cs`; fonction `CallInteger / CallDouble / CallVoid`.

#### 5. Dispose

Les chaînes temporaires sont libérées après chaque appel, même après erreur de conversion. Les bibliothèques sont libérées à la fin, à l’échec ou à l’annulation du script principal. Fermer seulement l’IDE conserve le script et ses bibliothèques.

`finally: free temporary strings; root exit: release DLL handles in reverse order`

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/ExternalLibraries.cs`; fonction `Dispose`.

Integer renvoie un nombre signé 32 bits dont le sens dépend de la fonction native, pas automatiquement un succès. Double renvoie un flottant 64 bits. As Boolean transforme zéro en 0/False et tout autre BOOL en 1/True ; pour ces indicateurs normalisés, comparer à 1/0 ou True/False est équivalent. Sub ne renvoie rien (Unit). Exemples : 1, "3:8", "missing export:1".

<!-- implementation references (not callable script procedures):
Runtime/ExternalDeclaration.cs: type and declaration validation
Analysis/ExternalDeclarationValidator.cs: SC031
Runtime/ExternalLibraries.cs: LibraryPath / GetCallable / Invoke / Dispose
Runtime/ExternalCallSites.cs: CallInteger / CallDouble / CallVoid
Runtime/Interpreter.cs: CallSubrutine / CallObserved
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/declare-statement
https://learn.microsoft.com/en-us/cpp/build/x64-calling-convention?view=msvc-170
https://learn.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-loadlibraryexw
-->
