# CreateTimer / script timers

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: fr -->

CreateTimer crée un minuteur de rappel arrêté. Start planifie une Sub sur le thread du script. Cette extension du projet est distincte de Basic Timer(), qui lit les secondes écoulées.

## Syntaxe exacte

```text
CreateTimer(milliseconds, handler) -> Object (ScriptTimer)
CreateTimer(milliseconds, handler, repeating) -> Object (ScriptTimer)
timer.Start() -> Unit
timer.Stop() -> Unit
timer.Dispose() -> Unit
timer.Enabled() -> Integer (0/1)
timer.Interval() -> Integer (ms)
timer.SetInterval(milliseconds) -> Unit
Using timer ... End Using
```

## Paramètres

- `milliseconds` — Integer en millisecondes, de 1 à 2147483647. Chaînes, fractions, zéro et valeurs négatives sont refusés. Même règle pour SetInterval. Interval() renvoie la durée configurée, pas le temps restant.
- `handler` — AddressOf une Sub déclarée sans ambiguïté et sans paramètre, ou une variable/fabrique de rappel du script chargé. Function, Optional/ParamArray, noms sous forme de chaîne et références étrangères sont refusés. État partagé dans Module ; aucune fermeture locale.
- `repeating` — Troisième argument facultatif : True/1 répète, False/0 appelle une fois. Par défaut True ; nom repeating:=. Autres nombres et chaînes refusés. Le minuteur unique est désactivé avant son rappel.
- `timer / Start / Stop / Dispose / SetInterval` — Méthodes : Start, Stop, Dispose, Enabled, Interval, SetInterval(milliseconds). Start ne modifie pas un minuteur actif. Stop permet un futur Start. SetInterval repart de maintenant si actif ; un minuteur arrêté reste arrêté. Dispose est répétable et définitif ; Start/SetInterval échouent ensuite. Using libère l’objet capturé à la sortie.

## Retour

CreateTimer → Object (ScriptTimer), ni ID d’objet ni indice de script. Start/Stop/Dispose/SetInterval → Unit. Enabled → Integer 1=True ou 0=False ; les deux comparaisons conviennent. Interval → millisecondes, pas Boolean. Exemples : String "3:0", "ready:0", "tick failed:0".

## Comportement

- Le temps monotone est vérifié entre instructions et dans Basic Wait/Sleep et Wait Until. Avec des minuteurs actifs, Wait est découpé en tranches de 25 ms maximum. Un appel de jeu ou natif bloquant doit revenir avant un rappel. Aucune garantie temps réel ; aucun nouveau thread.
- Ordre des échéances, puis de création en cas d’égalité ; au plus 64 rappels par point de contrôle, les autres au suivant. Aucun rappel réentrant pendant un gestionnaire, même avec Wait. Le prochain intervalle commence après sa fin ; les échéances manquées sont ignorées. Pause suspend les rappels ; la reprise exécute une seule fois un minuteur en retard.
- Une erreur désactive le minuteur et rejoint Catch/Finally. Stop/SetInterval depuis le rappel sont pris en compte. L’arrêt d’urgence n’est pas absorbé par Catch. Fin, erreur ou arrêt de l’appel racine libèrent tous ses minuteurs ; en recréer au prochain lancement/chargement. Fermer seulement l’IDE conserve ceux du script actif. Limite : 1024 minuteurs non libérés ; Dispose rend une place.
- RunThreePulses et GetHandler sont entièrement montrés. En interne, CreateTimer valide arguments/propriétaire ; Start fixe une échéance ; Pump appelle la Sub ; Fire programme la suite après achèvement ; Release libère à la fin du script. Aucun service indépendant ne subsiste.

## Exemples

### 1. Trois rappels avec nettoyage

```vb
# RunThreePulses crée un intervalle de 20 ms ; repeating=True par défaut. CountPulse augmente State.count et arrête à trois. Wait Until vérifie état et rappels avec 3000 ms de limite. Enabled()=0 donne "3:0". Using libère même lors du Return.
Option Explicit On
Module State
    Public Dim count As Integer = 0
    Public Dim pulse
End Module

Sub CountPulse()
    State.count += 1
    If State.count >= 3 Then
        State.pulse.Stop()
    End If
End Sub

Function RunThreePulses() As String
    State.pulse = CreateTimer(20, AddressOf CountPulse)
    Using State.pulse
        State.pulse.Start()
        Wait Until State.count >= 3 Timeout 3000
        Return CStr(State.count) & ":" & CStr(State.pulse.Enabled())
    End Using
End Function

Sub Main()
    Return RunThreePulses()
End Sub
```

**Explication des paramètres et du déroulement:**

RunThreePulses crée un intervalle de 20 ms ; repeating=True par défaut. CountPulse augmente State.count et arrête à trois. Wait Until vérifie état et rappels avec 3000 ms de limite. Enabled()=0 donne "3:0". Using libère même lors du Return.

### 2. Rappel unique et arguments nommés

```vb
# GetHandler renvoie AddressOf SetReady. Arguments nommés : 5 ms, callback, repeating=False. SetInterval remplace 5 par 10 avant Start. SetReady écrit "ready", le minuteur étant déjà désactivé. Main attend au plus 3000 ms et renvoie "ready:0". Tous les auxiliaires sont fournis.
Option Explicit On
Module State
    Public Dim message As String = ""
End Module

Sub SetReady()
    State.message = "ready"
End Sub

Function GetHandler()
    Return AddressOf SetReady
End Function

Sub Main()
    Dim callback = GetHandler()
    Dim notice = CreateTimer(repeating:=False, handler:=callback, milliseconds:=5)
    Using notice
        notice.SetInterval(10)
        notice.Start()
        Wait Until State.message = "ready" Timeout 3000
        Return State.message & ":" & CStr(notice.Enabled())
    End Using
End Sub
```

**Explication des paramètres et du déroulement:**

GetHandler renvoie AddressOf SetReady. Arguments nommés : 5 ms, callback, repeating=False. SetInterval remplace 5 par 10 avant Start. SetReady écrit "ready", le minuteur étant déjà désactivé. Main attend au plus 3000 ms et renvoie "ready:0". Tous les auxiliaires sont fournis.

### 3. Erreur pendant Wait

```vb
# FailingPulse lève "tick failed". Le minuteur de 5 ms intervient dans Wait(2000), se désactive et interrompt l’attente. Catch lit le texte et Enabled()=0 ; Finally libère. "tick failed:0" contient message et état. L’arrêt d’urgence reste géré par le moteur.
Option Explicit On
Sub FailingPulse()
    Throw "tick failed"
End Sub

Sub Main()
    Dim pulse = CreateTimer(5, AddressOf FailingPulse)
    Dim problemText As String = ""
    Dim enabledAfterError As Boolean = True
    Try
        pulse.Start()
        Wait(2000)
    Catch problem
        problemText = problem
        enabledAfterError = pulse.Enabled()
    Finally
        pulse.Dispose()
    End Try
    Return problemText & ":" & CStr(enabledAfterError)
End Sub
```

**Explication des paramètres et du déroulement:**

FailingPulse lève "tick failed". Le minuteur de 5 ms intervient dans Wait(2000), se désactive et interrompt l’attente. Catch lit le texte et Enabled()=0 ; Finally libère. "tick failed:0" contient message et état. L’arrêt d’urgence reste géré par le moteur.


### Fonctions internes : de l’appel au résultat

RunThreePulses et GetHandler sont entièrement montrés. En interne, CreateTimer valide arguments/propriétaire ; Start fixe une échéance ; Pump appelle la Sub ; Fire programme la suite après achèvement ; Release libère à la fin du script. Aucun service indépendant ne subsiste.

#### 1. CreateTimer

Integer en millisecondes, de 1 à 2147483647. Chaînes, fractions, zéro et valeurs négatives sont refusés. Même règle pour SetInterval. Interval() renvoie la durée configurée, pas le temps restant.

AddressOf une Sub déclarée sans ambiguïté et sans paramètre, ou une variable/fabrique de rappel du script chargé. Function, Optional/ParamArray, noms sous forme de chaîne et références étrangères sont refusés. État partagé dans Module ; aucune fermeture locale.

Troisième argument facultatif : True/1 répète, False/0 appelle une fois. Par défaut True ; nom repeating:=. Autres nombres et chaînes refusés. Le minuteur unique est désactivé avant son rappel.

CreateTimer → Object (ScriptTimer), ni ID d’objet ni indice de script. Start/Stop/Dispose/SetInterval → Unit. Enabled → Integer 1=True ou 0=False ; les deux comparaisons conviennent. Interval → millisecondes, pas Boolean. Exemples : String "3:0", "ready:0", "tick failed:0".

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Timers.cs`; fonction `CreateTimer`.

#### 2. Start

Méthodes : Start, Stop, Dispose, Enabled, Interval, SetInterval(milliseconds). Start ne modifie pas un minuteur actif. Stop permet un futur Start. SetInterval repart de maintenant si actif ; un minuteur arrêté reste arrêté. Dispose est répétable et définitif ; Start/SetInterval échouent ensuite. Using libère l’objet capturé à la sortie.

`Due = now + interval; enabled = true;`

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ScriptTimerObject.cs`; fonction `Start`.

#### 3. WaitWithTimers

Le temps monotone est vérifié entre instructions et dans Basic Wait/Sleep et Wait Until. Avec des minuteurs actifs, Wait est découpé en tranches de 25 ms maximum. Un appel de jeu ou natif bloquant doit revenir avant un rappel. Aucune garantie temps réel ; aucun nouveau thread.

`checkpoint -> Pump -> min(remaining, nextDue, 25 ms) -> Wait`

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Timers.cs`; fonction `WaitWithTimers`.

#### 4. Pump

Ordre des échéances, puis de création en cas d’égalité ; au plus 64 rappels par point de contrôle, les autres au suivant. Aucun rappel réentrant pendant un gestionnaire, même avec Wait. Le prochain intervalle commence après sa fin ; les échéances manquées sont ignorées. Pause suspend les rappels ; la reprise exécute une seule fois un minuteur en retard.

`snapshot -> deadline / sequence -> checkpoint -> Fire; limit = 64`

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/ScriptTimerScheduler.cs`; fonction `Pump`.

#### 5. Fire

Une erreur désactive le minuteur et rejoint Catch/Finally. Stop/SetInterval depuis le rappel sont pris en compte. L’arrêt d’urgence n’est pas absorbé par Catch. Fin, erreur ou arrêt de l’appel racine libèrent tous ses minuteurs ; en recréer au prochain lancement/chargement. Fermer seulement l’IDE conserve ceux du script actif. Limite : 1024 minuteurs non libérés ; Dispose rend une place.

`callback -> completion -> next Due; error -> disabled -> throw`

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ScriptTimerObject.cs`; fonction `Fire`.

#### 6. Dispose

Méthodes : Start, Stop, Dispose, Enabled, Interval, SetInterval(milliseconds). Start ne modifie pas un minuteur actif. Stop permet un futur Start. SetInterval repart de maintenant si actif ; un minuteur arrêté reste arrêté. Dispose est répétable et définitif ; Start/SetInterval échouent ensuite. Using libère l’objet capturé à la sortie.

`Release -> scheduler.Remove -> Changed`

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ScriptTimerObject.cs`; fonction `Dispose`.

#### 7. Release

Une erreur désactive le minuteur et rejoint Catch/Finally. Stop/SetInterval depuis le rappel sont pris en compte. L’arrêt d’urgence n’est pas absorbé par Catch. Fin, erreur ou arrêt de l’appel racine libèrent tous ses minuteurs ; en recréer au prochain lancement/chargement. Fermer seulement l’IDE conserve ceux du script actif. Limite : 1024 minuteurs non libérés ; Dispose rend une place.

`timer.Release for each handle -> timers.Clear -> no pending deadline`

Source du projet: `external/InjectionScript/src/InjectionScript/Runtime/ScriptTimerScheduler.cs`; fonction `Release`.

RunThreePulses crée un intervalle de 20 ms ; repeating=True par défaut. CountPulse augmente State.count et arrête à trois. Wait Until vérifie état et rappels avec 3000 ms de limite. Enabled()=0 donne "3:0". Using libère même lors du Return.

<!-- implementation references (not callable script procedures):
Runtime/InjectionApi.cs: CreateTimer / Wait
Runtime/Interpreter.Timers.cs: CreateTimer / WaitWithTimers / TimerCheckpoint
Runtime/ScriptTimerScheduler.cs: Pump / Delay / Release
Runtime/ObjectTypes/ScriptTimerObject.cs: Start / Fire / SetInterval / Dispose
Runtime/Interpreter.cs: statement checkpoints / VisitWaitUntilStatement / root-call cleanup
Runtime/RealTimeSource.cs: Stopwatch elapsed time
https://learn.microsoft.com/en-us/dotnet/api/system.diagnostics.stopwatch
https://learn.microsoft.com/en-us/dotnet/api/system.threading.timer (comparison only; this script timer does not use ThreadPool callbacks)
-->
