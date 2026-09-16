# AddHandler UO.JournalEntry / client events

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: es -->

AddHandler suscribe una Sub a nuevas entradas del diario, cambios de recursos y conexión. Estos nombres UO. son eventos, no funciones; no se pueden invocar mediante RaiseEvent.

## Sintaxis exacta

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

## Parámetros

- `Handler / AddressOf` — Use AddressOf una Sub del script cargado. Declare todos los parámetros explícitamente ByVal, con los tipos y el orden exactos de las firmas. No se admiten Function, Optional, ParamArray ni callbacks de otro script.
- `text / serial / name / hue` — JournalEntry entrega text String, serial Integer (ID de origen; 0 si no existe), name String y hue Integer (índice de tono UO, no RGB). Serial no es el gráfico de un objeto. Texto y nombre pueden estar vacíos. Los valores se copian antes de reutilizar la entrada. Solo llegan entradas nuevas tras suscribirse, incluidos mensajes locales.
- `current / previous` — HitPointsChanged/ManaChanged/StaminaChanged entregan current y previous Integer como puntos absolutos, no porcentajes ni Boolean. Se comparan estados por actualización; los cambios intermedios pueden agruparse. El estado inicial y otro personaje establecen una base sin notificar cambios de recursos.
- `online` — ConnectionChanged entrega online Boolean: True/1 si el mundo del cliente tiene personaje y mapa, False/0 si no. No garantiza que el socket esté sano. No se reproduce el estado inicial.
- `RemoveHandler` — RemoveHandler elimina la última coincidencia. Las suscripciones duplicadas se ejecutan varias veces en orden. El mensaje actual usa una lista fija; los cambios afectan a mensajes posteriores. Eliminar el último controlador libera la cola.

## Devuelve

AddHandler/RemoveHandler y las Sub no devuelven valor (Unit). Guarde resultados en campos Module compartidos. Solo online y los predicados usan 1/0 = True/False; serial, hue, puntos y State.changes son IDs o cantidades.

## Comportamiento

- El cliente encola copias. Los controladores se ejecutan en el hilo del script, entre instrucciones y dentro de Wait, Sleep, UO.Wait y Wait Until. Comprobación como máximo cada 25 ms, hasta 16 mensajes por evento y pasada. Una llamada nativa larga retrasa la entrega.
- Pausa acumula mensajes sin ejecutar controladores. Stop cancela y libera suscripciones; Catch no oculta la parada. Retorno o error de la entrada principal elimina las suscripciones del cliente. Una nueva ejecución empieza sin ellas. Cerrar IDE no detiene el script. La pausa automática por desconexión retrasa el evento hasta reanudar.
- Cada cola admite 256 mensajes. Desbordarse produce un error capturable y desactiva esa suscripción. Un error del controlador también la desactiva y omite los demás controladores del mensaje. Se puede volver a suscribir tras Catch/Finally. Evite reenviar cada mensaje al mismo diario.
- Solo estos cinco eventos están disponibles en Full con Basic IDE activa. No se añaden otros eventos, paquetes, Handles ni WithEvents. Los eventos declarados por el script están en Basic.Events.

## Ejemplos

### 1. Detectar una entrada nueva

```vb
# OnJournal recibe cuatro parámetros. IsReadyMessage, mostrada completa, comprueba InStr > 0. El mensaje local actualiza State.message. Wait Until espera hasta 5000 ms y después genera timeout. Finally elimina la suscripción. Main devuelve "ready: ore".
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

**Explicación de los parámetros y la ejecución:**

OnJournal recibe cuatro parámetros. IsReadyMessage, mostrada completa, comprueba InStr > 0. El mensaje local actualiza State.message. Wait Until espera hasta 5000 ms y después genera timeout. Finally elimina la suscripción. Main devuelve "ready: ore".

### 2. Observar recursos

```vb
# Tres controladores pasan current/previous a Remember, incluida completa. State.changes cuenta avisos y State.last guarda el último, por ejemplo SP:58:60. Tras Wait(250), Wait Until espera hasta 5000 ms; sin cambios hay timeout. Finally elimina las tres suscripciones. Devuelve String, no Boolean.
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

**Explicación de los parámetros y la ejecución:**

Tres controladores pasan current/previous a Remember, incluida completa. State.changes cuenta avisos y State.last guarda el último, por ejemplo SP:58:60. Tras Wait(250), Wait Until espera hasta 5000 ms; sin cambios hay timeout. Finally elimina las tres suscripciones. Devuelve String, no Boolean.

### 3. Observar la conexión

```vb
# OnConnection recibe Boolean online y cuenta transiciones durante Wait(1000). Finally elimina la suscripción. Main devuelve la cantidad: 0 sin cambios, 1 para una transición; aquí 1 no es True. State.online contiene el último estado recibido.
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

**Explicación de los parámetros y la ejecución:**

OnConnection recibe Boolean online y cuenta transiciones durante Wait(1000). Finally elimina la suscripción. Main devuelve la cantidad: 0 sin cambios, 1 para una transición; aquí 1 no es True. State.online contiene el último estado recibido.

<!-- implementation references (not callable script procedures):
Runtime/IScriptEventSource.cs: NativeScriptEvents / ScriptEventHub
Runtime/Interpreter.Events.cs: PumpClientEvents / ReleaseClientEvents
Runtime/Interpreter.Timers.cs: WaitWithTimers
Runtime/EventCatalog.cs: TryResolve / HandlerError
ClassicUO.Client/Game/Managers/YokoScriptEvents.cs: OnScriptJournalEntry / PublishScriptEvents
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/addhandler-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/removehandler-statement
-->
