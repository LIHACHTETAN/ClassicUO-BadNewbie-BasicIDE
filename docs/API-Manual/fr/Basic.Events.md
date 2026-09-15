# Event / AddHandler / RemoveHandler / RaiseEvent

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: fr -->

Event déclare un événement du script. AddHandler relie une Sub, RemoveHandler la retire et RaiseEvent appelle les gestionnaires de façon synchrone, dans leur ordre d’inscription.

## Syntaxe exacte

```text
Event Changed(ByVal value As Integer)
Public Event Adjust(ByRef value As Integer)
Private Event Completed()
AddHandler EventName, AddressOf Handler
AddHandler Module.EventName, callback
RemoveHandler EventName, AddressOf Handler
RaiseEvent EventName(arguments)
```

## Paramètres

- `EventName / Public / Private` — Déclarez un nom simple au niveau du fichier (module implicite du script) ou dans Module, hors des procédures. Public est implicite ; Private exige Module. Depuis un autre module, utilisez Module.EventName pour vous inscrire. Seul le module déclarant peut faire RaiseEvent, même pour Public. Évitez les noms déjà utilisés par une procédure ou une variable.
- `Handler / callback` — Handler est une Sub unique, désignée par AddressOf ou une variable/fabrique de callback du script chargé. Function, chaîne contenant un nom, référence étrangère et groupe de surcharges sont refusés. Nombre, types et modes ByVal/ByRef doivent correspondre exactement. Écrivez ByVal explicitement dans la Sub : les procédures ordinaires gardent leur ancien mode implicite ByRef.
- `arguments / ByVal / ByRef` — RaiseEvent exige tous les arguments positionnels. Optional, ParamArray, valeurs par défaut, arguments nommés d’événement et Safe Call ne sont pas pris en charge. Le mode implicite d’Event est ByVal : copie du scalaire ou de la référence, pas du contenu de l’objet. Les changements ByRef passent aux gestionnaires suivants puis à la variable ou à l’élément indexé modifiable de l’appelant. Arguments et indices sont évalués une fois, dans l’ordre écrit.

## Retour

Event, AddHandler, RemoveHandler et RaiseEvent ne renvoient rien (Unit), ni Boolean, ni ID, ni nombre d’abonnés. Utilisez ByRef ou l’état partagé d’un Module pour transmettre un résultat. Main renvoie String "ready", Integer 8 et String "ABAC:handler failed".

## Comportement

- Chaque interpréteur possède ses inscriptions. Les autres scripts et un rechargement partent sans elles. Des appels d’entrée ultérieurs dans le même interpréteur les conservent jusqu’au retrait ou à la libération de l’interpréteur. Fermer l’IDE préserve le script actif et ses inscriptions, sans créer un service d’événements autonome.
- AddHandler ajoute à la fin ; les doublons répètent la Sub. RemoveHandler retire sa dernière occurrence ; sans correspondance, il ne fait rien. Le moteur vérifie déclaration, accès et signature, évalue les arguments, puis fige la liste ordonnée. Les modifications d’inscriptions faites par un gestionnaire prennent effet au RaiseEvent suivant.
- Une erreur interrompt les gestionnaires restants et arrive au Catch/Finally appelant. Les changements ByRef antérieurs sont recopiés. Pause et arrêt d’urgence restent actifs ; Catch n’intercepte pas cet arrêt. Aucun thread supplémentaire. Les appels natifs bloquants gardent leurs limites d’annulation.
- Limites : 4096 inscriptions par événement, 16 RaiseEvent imbriqués et 32 cadres de procédures. Les cycles/récursions profondes donnent une erreur de script interceptable au lieu de faire déborder la pile du client. Utilisez une boucle pour un traitement profond. Placez les scalaires partagés dans Module ; les anciens scalaires du fichier restent hérités par copie.
- Ces événements sont déclarés et déclenchés explicitement par votre script, sans abonnement automatique aux paquets du jeu ou au journal. Handles, WithEvents, Custom Event, types de délégués d’événement et événements de classe ne sont pas implémentés ici. Les mots Basic sont sans UO.; les commandes du jeu gardent UO.

## Exemples

### 1. Inscrire et retirer

```vb
# Feed.Message transporte text As String ByVal. Feed.Publish, entièrement montré, le déclenche. Record complète State.log. handler inscrit Record ; "ready" est enregistré. RemoveHandler retrouve la même Sub malgré une autre ligne AddressOf. "ignored" après retrait ne change rien. Main renvoie "ready".
Option Explicit On
Module Feed
    Public Event Message(ByVal text As String)
    Public Sub Publish(ByVal text As String)
        RaiseEvent Message(text)
    End Sub
End Module

Module State
    Public Dim log As String = ""
End Module

Sub Record(ByVal text As String)
    State.log = State.log & text
End Sub

Sub Main()
    Dim handler = AddressOf Record
    AddHandler Feed.Message, handler
    Feed.Publish("ready")
    RemoveHandler Feed.Message, AddressOf Record
    Feed.Publish("ignored")
    Return State.log
End Sub
```

**Explication des paramètres et du déroulement:**

Feed.Message transporte text As String ByVal. Feed.Publish, entièrement montré, le déclenche. Record complète State.log. handler inscrit Record ; "ready" est enregistré. RemoveHandler retrouve la même Sub malgré une autre ligne AddressOf. "ignored" après retrait ne change rien. Main renvoie "ready".

### 2. Modifier une valeur successivement

```vb
# Adjust et les deux Subs utilisent total As Integer ByRef. Increment passe de 3 à 4 ; DoubleValue reçoit 4 puis produit 8. RaiseEvent recopie 8 dans Main. Les deux inscriptions sont retirées. Integer 8 est une quantité, pas True/False ; RaiseEvent lui-même ne renvoie rien.
Option Explicit On
Event Adjust(ByRef total As Integer)

Sub Increment(ByRef total As Integer)
    total += 1
End Sub

Sub DoubleValue(ByRef total As Integer)
    total *= 2
End Sub

Sub Main()
    Dim total As Integer = 3
    AddHandler Adjust, AddressOf Increment
    AddHandler Adjust, AddressOf DoubleValue
    RaiseEvent Adjust(total)
    RemoveHandler Adjust, AddressOf Increment
    RemoveHandler Adjust, AddressOf DoubleValue
    Return total
End Sub
```

**Explication des paramètres et du déroulement:**

Adjust et les deux Subs utilisent total As Integer ByRef. Increment passe de 3 à 4 ; DoubleValue reçoit 4 puis produit 8. RaiseEvent recopie 8 dans Main. Les deux inscriptions sont retirées. Integer 8 est une quantité, pas True/False ; RaiseEvent lui-même ne renvoie rien.

### 3. Gérer une erreur et continuer

```vb
# Ready n’a aucun paramètre. First ajoute A, Failing ajoute B puis lève une erreur ; Last est ignoré pour cet appel. Catch stocke le message et Finally retire Failing. L’appel suivant ajoute AC. Main renvoie "ABAC:handler failed". Tous les gestionnaires et le module State sont inclus.
Option Explicit On
Event Ready()
Module State
    Public Dim log As String = ""
End Module

Sub First()
    State.log = State.log & "A"
End Sub

Sub Failing()
    State.log = State.log & "B"
    Throw "handler failed"
End Sub

Sub Last()
    State.log = State.log & "C"
End Sub

Sub Main()
    Dim message As String = ""
    AddHandler Ready, AddressOf First
    AddHandler Ready, AddressOf Failing
    AddHandler Ready, AddressOf Last
    Try
        RaiseEvent Ready()
    Catch problem
        message = problem
    Finally
        RemoveHandler Ready, AddressOf Failing
    End Try
    RaiseEvent Ready()
    Return State.log & ":" & message
End Sub
```

**Explication des paramètres et du déroulement:**

Ready n’a aucun paramètre. First ajoute A, Failing ajoute B puis lève une erreur ; Last est ignoré pour cet appel. Catch stocke le message et Finally retire Failing. L’appel suivant ajoute AC. Main renvoie "ABAC:handler failed". Tous les gestionnaires et le module State sont inclus.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: eventDeclaration / eventHandler / raiseEvent
Runtime/EventCatalog.cs: Build / TryResolve / HandlerError
Analysis/EventValidator.cs: ValidateHandler / ValidateRaise / ValidateNativeNames
Runtime/Interpreter.Events.cs: VisitEventHandler / VisitRaiseEvent
Runtime/Interpreter.cs: CallSubrutine / ExecuteSubrutine / ByRef copy-back
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/event-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/addhandler-statement
-->
