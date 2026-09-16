# AddHandler UO.JournalEntry / client events

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: fr -->

AddHandler abonne un gestionnaire aux nouvelles entrées du journal, aux ressources du personnage et aux changements de connexion. Ces noms UO. désignent des événements, pas des fonctions. Ne les appelez pas avec RaiseEvent.

## Syntaxe exacte

```text
AddHandler UO.JournalEntry, AddressOf OnJournal
Sub OnJournal(ByVal text As String, ByVal serial As Integer, ByVal name As String, ByVal hue As Integer)
AddHandler UO.HitPointsChanged, AddressOf OnHits
AddHandler UO.ManaChanged, AddressOf OnMana
AddHandler UO.StaminaChanged, AddressOf OnStamina
Sub OnHits(ByVal current As Integer, ByVal previous As Integer)
Sub OnMana(ByVal current As Integer, ByVal previous As Integer)
Sub OnStamina(ByVal current As Integer, ByVal previous As Integer)
AddHandler UO.ConnectionChanged, AddressOf OnConnection
Sub OnConnection(ByVal online As Boolean)
RemoveHandler UO.JournalEntry, AddressOf OnJournal
```

## Paramètres

- `Handler / AddressOf` — Utilisez AddressOf une Sub du script chargé. Déclarez explicitement tous les paramètres ByVal, avec les types et l’ordre exacts des signatures. Function, Optional, ParamArray et les callbacks d’un autre script sont refusés.
- `text / serial / name / hue` — JournalEntry fournit text String, serial Integer (ID de la source, 0 si absente), name String et hue Integer (indice de teinte UO, pas RGB). Serial n’est pas le graphique d’un objet. Texte et nom peuvent être vides. Les valeurs sont copiées avant recyclage de l’entrée. Seules les nouvelles entrées après abonnement sont livrées, messages locaux compris.
- `current / previous` — HitPointsChanged/ManaChanged/StaminaChanged fournissent current et previous Integer en points absolus, pas en pourcentage ni en Boolean. Comparaison des états à chaque mise à jour : des changements intermédiaires peuvent être regroupés. L’état initial et un changement de personnage créent une nouvelle référence sans événement de ressource.
- `online` — ConnectionChanged fournit online Boolean : True/1 si le monde du client possède un personnage et une carte, False/0 sinon. Cela ne garantit pas la santé du socket. Aucun état initial n’est rejoué.
- `RemoveHandler` — RemoveHandler retire la dernière occurrence correspondante. Les doublons sont appelés plusieurs fois dans l’ordre d’inscription. Une liste figée sert au message courant ; les modifications concernent les suivants. Retirer le dernier gestionnaire libère la file.

## Retour

AddHandler/RemoveHandler et les Sub ne renvoient aucune valeur (Unit). Stockez les résultats dans des champs Module partagés. Seuls online et les prédicats utilisent 1/0 = True/False. Serial, hue, points et State.changes sont des identifiants ou quantités.

## Comportement

- Le client met des copies en file. Les gestionnaires s’exécutent dans le thread de leur script, entre instructions et pendant Wait, Sleep, UO.Wait et Wait Until. Consultation au plus toutes les 25 ms, jusqu’à 16 messages par événement et passage. Un appel natif long peut retarder la livraison.
- La pause conserve les messages sans exécuter les gestionnaires. Stop annule et libère les abonnements ; Catch ne masque pas cet arrêt. Retour ou erreur de la procédure principale supprime les abonnements client. Un nouveau lancement repart sans eux. Fermer IDE ne stoppe pas le script. La pause automatique à la déconnexion retarde la notification jusqu’à la reprise.
- Limite de 256 messages par événement. Un dépassement produit une erreur interceptable et désactive cet abonnement. Une erreur de gestionnaire le désactive aussi et ignore les gestionnaires suivants du message. Réabonnement possible après Catch/Finally. Évitez de réimprimer chaque message dans le même journal.
- Ces cinq événements nécessitent Full et Basic IDE activée. Autres événements, paquets, Handles et WithEvents ne sont pas inclus. Les événements déclarés par le script sont décrits dans Basic.Events.

## Exemples

### 1. Détecter une nouvelle entrée

```vb
# OnJournal reçoit quatre paramètres. IsReadyMessage, entièrement montré, vérifie InStr > 0. Le message local déclenche State.message. Wait Until attend au maximum 5000 ms puis signale un timeout. Finally retire le gestionnaire. Main renvoie "ready: ore".
Option Explicit On
Module State
    Public Dim matched As Boolean = False
    Public Dim message As String = ""
End Module

Function IsReadyMessage(ByVal text As String) As Boolean
    Return InStr(text, "ready: ore") > 0
End Function

Sub OnJournal(ByVal text As String, ByVal serial As Integer, ByVal name As String, ByVal hue As Integer)
    If IsReadyMessage(text) Then
        State.message = text
        State.matched = True
    End If
End Sub

Sub Main()
    AddHandler UO.JournalEntry, AddressOf OnJournal
    Try
        UO.AddToJournal("ready: ore")
        Wait Until State.matched Timeout 5000
    Finally
        RemoveHandler UO.JournalEntry, AddressOf OnJournal
    End Try
    Return State.message
End Sub
```

**Explication des paramètres et du déroulement:**

OnJournal reçoit quatre paramètres. IsReadyMessage, entièrement montré, vérifie InStr > 0. Le message local déclenche State.message. Wait Until attend au maximum 5000 ms puis signale un timeout. Finally retire le gestionnaire. Main renvoie "ready: ore".

### 2. Observer les ressources

```vb
# Trois gestionnaires transmettent current/previous à Remember, montré intégralement. State.changes compte les notifications ; State.last contient par exemple SP:58:60. Après Wait(250), Wait Until attend 5000 ms au maximum ; sans changement, timeout. Finally retire les trois abonnements. Résultat String, pas Boolean.
Option Explicit On
Module State
    Public Dim changes As Integer = 0
    Public Dim last As String = ""
End Module

Sub Remember(ByVal label As String, ByVal current As Integer, ByVal previous As Integer)
    State.changes += 1
    State.last = label & ":" & CStr(current) & ":" & CStr(previous)
End Sub

Sub OnHits(ByVal current As Integer, ByVal previous As Integer)
    Remember("HP", current, previous)
End Sub

Sub OnMana(ByVal current As Integer, ByVal previous As Integer)
    Remember("MP", current, previous)
End Sub

Sub OnStamina(ByVal current As Integer, ByVal previous As Integer)
    Remember("SP", current, previous)
End Sub

Sub Main()
    AddHandler UO.HitPointsChanged, AddressOf OnHits
    AddHandler UO.ManaChanged, AddressOf OnMana
    AddHandler UO.StaminaChanged, AddressOf OnStamina
    Try
        Wait(250)
        Wait Until State.changes > 0 Timeout 5000
    Finally
        RemoveHandler UO.HitPointsChanged, AddressOf OnHits
        RemoveHandler UO.ManaChanged, AddressOf OnMana
        RemoveHandler UO.StaminaChanged, AddressOf OnStamina
    End Try
    Return State.last
End Sub
```

**Explication des paramètres et du déroulement:**

Trois gestionnaires transmettent current/previous à Remember, montré intégralement. State.changes compte les notifications ; State.last contient par exemple SP:58:60. Après Wait(250), Wait Until attend 5000 ms au maximum ; sans changement, timeout. Finally retire les trois abonnements. Résultat String, pas Boolean.

### 3. Observer la connexion

```vb
# OnConnection reçoit online Boolean et compte les transitions pendant Wait(1000). Finally désabonne. Main renvoie le nombre : 0 sans changement, 1 pour une transition ; ce 1 ne signifie pas True. State.online conserve uniquement le dernier état reçu.
Option Explicit On
Module State
    Public Dim changes As Integer = 0
    Public Dim online As Boolean = False
End Module

Sub OnConnection(ByVal online As Boolean)
    State.online = online
    State.changes += 1
End Sub

Sub Main()
    AddHandler UO.ConnectionChanged, AddressOf OnConnection
    Try
        Wait(1000)
    Finally
        RemoveHandler UO.ConnectionChanged, AddressOf OnConnection
    End Try
    Return State.changes
End Sub
```

**Explication des paramètres et du déroulement:**

OnConnection reçoit online Boolean et compte les transitions pendant Wait(1000). Finally désabonne. Main renvoie le nombre : 0 sans changement, 1 pour une transition ; ce 1 ne signifie pas True. State.online conserve uniquement le dernier état reçu.

<!-- implementation references (not callable script procedures):
Runtime/IScriptEventSource.cs: NativeScriptEvents / ScriptEventHub
Runtime/Interpreter.Events.cs: PumpClientEvents / ReleaseClientEvents
Runtime/Interpreter.Timers.cs: WaitWithTimers
Runtime/EventCatalog.cs: TryResolve / HandlerError
ClassicUO.Client/Game/Managers/YokoScriptEvents.cs: OnScriptJournalEntry / PublishScriptEvents
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/addhandler-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/removehandler-statement
-->
