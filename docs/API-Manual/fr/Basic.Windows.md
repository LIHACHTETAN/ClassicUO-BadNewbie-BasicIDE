# Windows.bas

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: fr -->

Windows.bas est un module Basic modifiable avec six fonctions publiques pour le processus, les courts intervalles et la taille du bureau. Tout le code et les Declare privés figurent ci-dessous ; Main seul ne suffit pas.

## Syntaxe exacte

```text
Include "Windows.bas"
Windows.ProcessId() As Integer
Windows.Milliseconds() As Double
Windows.ElapsedMilliseconds(ByVal startMilliseconds As Double) As Double
Windows.ScreenWidth() As Integer
Windows.ScreenHeight() As Integer
Windows.DesktopBounds() As Object
```

## Paramètres

- `Include / Windows.bas` — Include "Windows.bas" charge Scripts/Include/Windows.bas. Pour un dossier de scripts séparé, copier la bibliothèque dans son sous-dossier Include. Le paquet contient Main.bas et Include/Windows.bas. Appels avec Windows., sans UO.; il s’agit d’un module de script.
- `ProcessId()` — ProcessId(), sans argument, renvoie l’ID Windows du processus client en Integer, pas un numéro UO ni un ID de connexion.
- `Milliseconds()` — Milliseconds(), sans argument, renvoie Double dans 0..4294967295 : GetTickCount non signé 32 bits. Un résultat natif négatif reçoit 4294967296.0. Le compteur reboucle environ tous les 49,7 jours ; ni heure civile ni chronomètre haute résolution.
- `ElapsedMilliseconds(startMilliseconds)` — ElapsedMilliseconds(startMilliseconds) prend un ancien Milliseconds() en Double et renvoie les millisecondes écoulées en Double. Hors de 0..4294967295 : erreur. Une différence négative reçoit 4294967296.0 pour gérer un seul rebouclage. L’intervalle doit être inférieur à un cycle. Cette fonction n’attend pas.
- `ScreenWidth() / ScreenHeight()` — ScreenWidth()/ScreenHeight(), sans argument, renvoient les dimensions Integer du moniteur principal via les métriques 0/1 et le contexte DPI du processus. Ce ne sont ni des cases UO ni la taille de la fenêtre du jeu.
- `DesktopBounds()` — DesktopBounds() renvoie un nouveau Dictionary : clés texte X, Y, Width, Height et valeurs Integer, lues avec Item("X") etc. Les métriques 76–79 couvrent tous les moniteurs ; X/Y peuvent être négatifs. Modifier le dictionnaire ne modifie aucune fenêtre.

## Retour

ID et dimensions : Integer. Temps : quantités Double en millisecondes, pas Boolean. DesktopBounds : Object (Dictionary) aux valeurs Integer. Include et déclarations sans résultat. Main de chaque exemple renvoie 1/True après validation ; 0/False indique une validation échouée, pas la signification de toute valeur native.

## Comportement

- Windows x64 requis. NativeTicks, NativeProcessId et NativeMetric sont les Declare privés montrés ci-dessous ; comportement DLL décrit dans Basic.Declare. Aucun trafic de jeu, changement d’options ou déplacement du personnage.
- Les fonctions lisent les valeurs actuelles. Milliseconds est généralement actualisé toutes les 10–16 ms. Plusieurs cycles ou des valeurs d’une autre session Windows ne sont pas détectables. Utiliser pour de courts traitements ; Wait ne garantit pas une durée exacte.
- Copier Main.bas avec Include/Windows.bas ; le code est modifiable dans l’IDE. DesktopBounds crée chaque fois un instantané indépendant. La disposition des moniteurs ou le DPI peuvent changer les résultats suivants.

## Exemples

### 1. Processus et compteur

```vb
# Main charge Windows.bas, lit ProcessId() et stocke Milliseconds() dans startedAt. AndAlso vérifie un ID positif et la plage 0..4294967295 ; résultat 1/True. Les valeurs exactes dépendent de l’ordinateur.
Option Explicit On
Include "Windows.bas"

Sub Main()
    Dim processId = Windows.ProcessId()
    Dim startedAt = Windows.Milliseconds()
    Return processId > 0 AndAlso startedAt >= 0 AndAlso startedAt <= 4294967295.0
End Sub
```

**Explication des paramètres et du déroulement:**

Main charge Windows.bas, lit ProcessId() et stocke Milliseconds() dans startedAt. AndAlso vérifie un ID positif et la plage 0..4294967295 ; résultat 1/True. Les valeurs exactes dépendent de l’ordinateur.

**Include/Windows.bas**

```vbnet
Option Explicit On

' Windows x64 helpers. Include "Windows.bas" from the main script.
' These declarations use the Windows ABI, not VB6 Integer/Long widths.
Module Windows
    Private Declare Function NativeTicks Lib "kernel32.dll" Alias "GetTickCount"() As Integer
    Private Declare Function NativeProcessId Lib "kernel32.dll" Alias "GetCurrentProcessId"() As Integer
    Private Declare Function NativeMetric Lib "user32.dll" Alias "GetSystemMetrics"(ByVal index As Integer) As Integer

    ' Returns the current client process ID. This is not a character/item serial.
    Public Function ProcessId() As Integer
        Return NativeProcessId()
    End Function

    ' Unsigned 32-bit milliseconds since Windows started, represented as Double.
    ' Wraps every 4294967296 ms (about 49.7 days); this is not a calendar time.
    Public Function Milliseconds() As Double
        Dim value As Double = NativeTicks()
        If value < 0 Then
            value += 4294967296.0
        End If
        Return value
    End Function

    ' startMilliseconds must come from Milliseconds(). Handles one wrap only.
    ' Use for intervals shorter than 49.7 days; no waiting is performed here.
    Public Function ElapsedMilliseconds(ByVal startMilliseconds As Double) As Double
        If Not (startMilliseconds >= 0 AndAlso startMilliseconds <= 4294967295.0) Then
            Throw "Windows.ElapsedMilliseconds requires a tick value in 0..4294967295."
        End If
        Dim elapsed As Double = Milliseconds() - startMilliseconds
        If elapsed < 0 Then
            elapsed += 4294967296.0
        End If
        Return elapsed
    End Function

    ' Primary monitor dimensions in the process's Windows DPI coordinate space.
    ' These are desktop dimensions, not the UO game viewport size.
    Public Function ScreenWidth() As Integer
        Return NativeMetric(0)
    End Function

    Public Function ScreenHeight() As Integer
        Return NativeMetric(1)
    End Function

    ' Returns a new Dictionary: X, Y, Width, Height of the whole virtual desktop.
    ' X/Y may be negative when monitors are to the left/above the primary one.
    Public Function DesktopBounds() As Object
        Dim bounds = Dictionary()
        bounds.Set("X", NativeMetric(76))
        bounds.Set("Y", NativeMetric(77))
        bounds.Set("Width", NativeMetric(78))
        bounds.Set("Height", NativeMetric(79))
        Return bounds
    End Function
End Module
```

### 2. Mesurer une attente

```vb
# MeasureWait(delayMilliseconds) refuse les délais négatifs, mémorise le compteur, appelle Wait puis renvoie ElapsedMilliseconds(startMilliseconds:=startedAt). Main passe 15 et vérifie elapsed >= 0. Le délai réel peut dépasser 15 ms. Tous les auxiliaires et la correction de rebouclage sont montrés.
Option Explicit On
Include "Windows.bas"

Function MeasureWait(ByVal delayMilliseconds As Integer) As Double
    If delayMilliseconds < 0 Then
        Throw "delayMilliseconds must be non-negative"
    End If
    Dim startedAt = Windows.Milliseconds()
    Wait(delayMilliseconds)
    Return Windows.ElapsedMilliseconds(startMilliseconds:=startedAt)
End Function

Sub Main()
    Dim elapsed = MeasureWait(15)
    Return elapsed >= 0
End Sub
```

**Explication des paramètres et du déroulement:**

MeasureWait(delayMilliseconds) refuse les délais négatifs, mémorise le compteur, appelle Wait puis renvoie ElapsedMilliseconds(startMilliseconds:=startedAt). Main passe 15 et vérifie elapsed >= 0. Le délai réel peut dépasser 15 ms. Tous les auxiliaires et la correction de rebouclage sont montrés.

**Include/Windows.bas**

```vbnet
Option Explicit On

' Windows x64 helpers. Include "Windows.bas" from the main script.
' These declarations use the Windows ABI, not VB6 Integer/Long widths.
Module Windows
    Private Declare Function NativeTicks Lib "kernel32.dll" Alias "GetTickCount"() As Integer
    Private Declare Function NativeProcessId Lib "kernel32.dll" Alias "GetCurrentProcessId"() As Integer
    Private Declare Function NativeMetric Lib "user32.dll" Alias "GetSystemMetrics"(ByVal index As Integer) As Integer

    ' Returns the current client process ID. This is not a character/item serial.
    Public Function ProcessId() As Integer
        Return NativeProcessId()
    End Function

    ' Unsigned 32-bit milliseconds since Windows started, represented as Double.
    ' Wraps every 4294967296 ms (about 49.7 days); this is not a calendar time.
    Public Function Milliseconds() As Double
        Dim value As Double = NativeTicks()
        If value < 0 Then
            value += 4294967296.0
        End If
        Return value
    End Function

    ' startMilliseconds must come from Milliseconds(). Handles one wrap only.
    ' Use for intervals shorter than 49.7 days; no waiting is performed here.
    Public Function ElapsedMilliseconds(ByVal startMilliseconds As Double) As Double
        If Not (startMilliseconds >= 0 AndAlso startMilliseconds <= 4294967295.0) Then
            Throw "Windows.ElapsedMilliseconds requires a tick value in 0..4294967295."
        End If
        Dim elapsed As Double = Milliseconds() - startMilliseconds
        If elapsed < 0 Then
            elapsed += 4294967296.0
        End If
        Return elapsed
    End Function

    ' Primary monitor dimensions in the process's Windows DPI coordinate space.
    ' These are desktop dimensions, not the UO game viewport size.
    Public Function ScreenWidth() As Integer
        Return NativeMetric(0)
    End Function

    Public Function ScreenHeight() As Integer
        Return NativeMetric(1)
    End Function

    ' Returns a new Dictionary: X, Y, Width, Height of the whole virtual desktop.
    ' X/Y may be negative when monitors are to the left/above the primary one.
    Public Function DesktopBounds() As Object
        Dim bounds = Dictionary()
        bounds.Set("X", NativeMetric(76))
        bounds.Set("Y", NativeMetric(77))
        bounds.Set("Width", NativeMetric(78))
        bounds.Set("Height", NativeMetric(79))
        Return bounds
    End Function
End Module
```

### 3. Géométrie du bureau

```vb
# Main lit X/Y/Width/Height avec Item dans un Dictionary indépendant puis compare aux dimensions du moniteur principal. Celles-ci doivent être positives et le bureau au moins aussi grand. left/top peuvent être négatifs ; aucune coordonnée n’est envoyée aux commandes de mouvement UO.
Option Explicit On
Include "Windows.bas"

Sub Main()
    Dim desktop = Windows.DesktopBounds()
    Dim left = desktop.Item("X")
    Dim top = desktop.Item("Y")
    Dim width = desktop.Item("Width")
    Dim height = desktop.Item("Height")
    Dim primaryWidth = Windows.ScreenWidth()
    Dim primaryHeight = Windows.ScreenHeight()
    Return width >= primaryWidth AndAlso height >= primaryHeight AndAlso primaryWidth > 0 AndAlso primaryHeight > 0
End Sub
```

**Explication des paramètres et du déroulement:**

Main lit X/Y/Width/Height avec Item dans un Dictionary indépendant puis compare aux dimensions du moniteur principal. Celles-ci doivent être positives et le bureau au moins aussi grand. left/top peuvent être négatifs ; aucune coordonnée n’est envoyée aux commandes de mouvement UO.

**Include/Windows.bas**

```vbnet
Option Explicit On

' Windows x64 helpers. Include "Windows.bas" from the main script.
' These declarations use the Windows ABI, not VB6 Integer/Long widths.
Module Windows
    Private Declare Function NativeTicks Lib "kernel32.dll" Alias "GetTickCount"() As Integer
    Private Declare Function NativeProcessId Lib "kernel32.dll" Alias "GetCurrentProcessId"() As Integer
    Private Declare Function NativeMetric Lib "user32.dll" Alias "GetSystemMetrics"(ByVal index As Integer) As Integer

    ' Returns the current client process ID. This is not a character/item serial.
    Public Function ProcessId() As Integer
        Return NativeProcessId()
    End Function

    ' Unsigned 32-bit milliseconds since Windows started, represented as Double.
    ' Wraps every 4294967296 ms (about 49.7 days); this is not a calendar time.
    Public Function Milliseconds() As Double
        Dim value As Double = NativeTicks()
        If value < 0 Then
            value += 4294967296.0
        End If
        Return value
    End Function

    ' startMilliseconds must come from Milliseconds(). Handles one wrap only.
    ' Use for intervals shorter than 49.7 days; no waiting is performed here.
    Public Function ElapsedMilliseconds(ByVal startMilliseconds As Double) As Double
        If Not (startMilliseconds >= 0 AndAlso startMilliseconds <= 4294967295.0) Then
            Throw "Windows.ElapsedMilliseconds requires a tick value in 0..4294967295."
        End If
        Dim elapsed As Double = Milliseconds() - startMilliseconds
        If elapsed < 0 Then
            elapsed += 4294967296.0
        End If
        Return elapsed
    End Function

    ' Primary monitor dimensions in the process's Windows DPI coordinate space.
    ' These are desktop dimensions, not the UO game viewport size.
    Public Function ScreenWidth() As Integer
        Return NativeMetric(0)
    End Function

    Public Function ScreenHeight() As Integer
        Return NativeMetric(1)
    End Function

    ' Returns a new Dictionary: X, Y, Width, Height of the whole virtual desktop.
    ' X/Y may be negative when monitors are to the left/above the primary one.
    Public Function DesktopBounds() As Object
        Dim bounds = Dictionary()
        bounds.Set("X", NativeMetric(76))
        bounds.Set("Y", NativeMetric(77))
        bounds.Set("Width", NativeMetric(78))
        bounds.Set("Height", NativeMetric(79))
        Return bounds
    End Function
End Module
```


### Fonctions internes : de l’appel au résultat

Windows.bas est un module Basic modifiable avec six fonctions publiques pour le processus, les courts intervalles et la taille du bureau. Tout le code et les Declare privés figurent ci-dessous ; Main seul ne suffit pas.

#### 1. ProcessId / Milliseconds

Milliseconds(), sans argument, renvoie Double dans 0..4294967295 : GetTickCount non signé 32 bits. Un résultat natif négatif reçoit 4294967296.0. Le compteur reboucle environ tous les 49,7 jours ; ni heure civile ni chronomètre haute résolution.

`GetTickCount -> signed Integer -> if negative add 4294967296.0 -> Double`

Source du projet: `src/ClassicUO.Client/Scripts/Include/Windows.bas`; fonction `ProcessId / Milliseconds`.

#### 2. ElapsedMilliseconds

ElapsedMilliseconds(startMilliseconds) prend un ancien Milliseconds() en Double et renvoie les millisecondes écoulées en Double. Hors de 0..4294967295 : erreur. Une différence négative reçoit 4294967296.0 pour gérer un seul rebouclage. L’intervalle doit être inférieur à un cycle. Cette fonction n’attend pas.

`validate start -> now - start -> if negative add one wrap -> Double`

Source du projet: `src/ClassicUO.Client/Scripts/Include/Windows.bas`; fonction `ElapsedMilliseconds`.

#### 3. ScreenWidth / ScreenHeight / DesktopBounds

DesktopBounds() renvoie un nouveau Dictionary : clés texte X, Y, Width, Height et valeurs Integer, lues avec Item("X") etc. Les métriques 76–79 couvrent tous les moniteurs ; X/Y peuvent être négatifs. Modifier le dictionnaire ne modifie aucune fenêtre.

`metrics 0, 1: primary; 76, 77, 78, 79: desktop X, Y, Width, Height`

Source du projet: `src/ClassicUO.Client/Scripts/Include/Windows.bas`; fonction `ScreenWidth / ScreenHeight / DesktopBounds`.

ID et dimensions : Integer. Temps : quantités Double en millisecondes, pas Boolean. DesktopBounds : Object (Dictionary) aux valeurs Integer. Include et déclarations sans résultat. Main de chaque exemple renvoie 1/True après validation ; 0/False indique une validation échouée, pas la signification de toute valeur native.

<!-- implementation references (not callable script procedures):
src/ClassicUO.Client/Scripts/Include/Windows.bas: all declarations and helpers
Runtime/ExternalLibraries.cs: GetCallable / Invoke / Dispose
Parsing/ScriptSourceGraph.cs: Include resolution
https://learn.microsoft.com/en-us/windows/win32/api/sysinfoapi/nf-sysinfoapi-gettickcount
https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getsystemmetrics
-->
