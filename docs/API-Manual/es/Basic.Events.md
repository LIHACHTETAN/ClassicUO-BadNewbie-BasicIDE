# Event / AddHandler / RemoveHandler / RaiseEvent

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: es -->

Event declara un evento del script. AddHandler conecta una Sub, RemoveHandler la desconecta y RaiseEvent llama a los controladores de forma síncrona y en orden de suscripción.

## Sintaxis exacta

```text
Event Changed(ByVal value As Integer)
Public Event Adjust(ByRef value As Integer)
Private Event Completed()
AddHandler EventName, AddressOf Handler
AddHandler Module.EventName, callback
RemoveHandler EventName, AddressOf Handler
RaiseEvent EventName(arguments)
```

## Parámetros

- `EventName / Public / Private` — Declare un nombre simple a nivel de archivo (módulo implícito) o dentro de Module, fuera de procedimientos. Public es el acceso predeterminado; Private requiere Module. Desde fuera use Module.EventName para suscribirse. Solo el módulo que lo declara puede ejecutar RaiseEvent, aunque sea Public. Evite nombres de procedimientos o variables existentes.
- `Handler / callback` — Handler es una Sub declarada de forma única: AddressOf o una variable/fábrica de callback del script cargado. No admite Function, cadenas con nombres, referencias ajenas ni grupos de sobrecargas. Número, tipos y modos ByVal/ByRef deben coincidir exactamente. Escriba ByVal explícitamente en los controladores: los procedimientos ordinarios conservan su antiguo valor predeterminado ByRef.
- `arguments / ByVal / ByRef` — RaiseEvent requiere todos los argumentos posicionales. No admite Optional, ParamArray, valores predeterminados, argumentos de evento con nombre ni Safe Call. Los parámetros Event son ByVal por defecto: copian el escalar o la referencia, no el contenido del objeto. Los cambios ByRef llegan al siguiente controlador y a la variable o elemento indexado modificable del llamante. Argumentos e índices se evalúan una vez, en el orden escrito.

## Devuelve

Event, AddHandler, RemoveHandler y RaiseEvent no devuelven un valor (Unit): ni Boolean, ni ID, ni número de suscriptores. Use ByRef o el estado compartido de Module para obtener resultados. Main devuelve String "ready", Integer 8 y String "ABAC:handler failed".

## Comportamiento

- Las suscripciones pertenecen a un intérprete. Otros scripts y una recarga empiezan sin ellas. Nuevas entradas al mismo intérprete cargado las conservan hasta eliminarlas o liberar el intérprete. Cerrar la IDE mantiene el script activo con sus suscripciones; no crea un servicio de eventos independiente.
- AddHandler añade al final; las suscripciones duplicadas repiten la Sub. RemoveHandler elimina su última aparición; si no existe, no hace nada. El motor comprueba declaración, acceso y firma, evalúa argumentos y fija una lista ordenada. Cambios de suscripciones durante un controlador afectan al siguiente RaiseEvent.
- Un error detiene los controladores restantes y llega al Catch/Finally del llamante. Los cambios ByRef anteriores se copian de vuelta. Pausa y parada de emergencia funcionan dentro del controlador; Catch no absorbe la parada. No crea hilos nuevos. Las llamadas nativas bloqueantes conservan sus límites de cancelación.
- Límites: 4096 suscripciones por evento, 16 RaiseEvent anidados y 32 marcos de procedimientos. Los ciclos y la recursión profunda producen un error de script capturable en vez de agotar la pila del cliente. Use bucles para procesamiento profundo. Los escalares compartidos van en campos Module; los antiguos escalares de archivo siguen heredándose como copias.
- Son eventos declarados y activados explícitamente por su script, sin suscripción automática a paquetes del juego o cambios del diario. Handles, WithEvents, Custom Event, tipos de delegados de eventos y eventos de clases no están implementados aquí. Palabras Basic sin UO.; comandos del juego con UO.

## Ejemplos

### 1. Suscribirse y cancelar

```vb
# Feed.Message transmite text As String ByVal. Feed.Publish, mostrada completa, lo activa y Record añade a State.log. handler suscribe Record; "ready" se guarda. RemoveHandler reconoce la misma Sub desde otra línea AddressOf. "ignored" después de cancelar no añade nada. Main devuelve "ready".
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

**Explicación de los parámetros y la ejecución:**

Feed.Message transmite text As String ByVal. Feed.Publish, mostrada completa, lo activa y Record añade a State.log. handler suscribe Record; "ready" se guarda. RemoveHandler reconoce la misma Sub desde otra línea AddressOf. "ignored" después de cancelar no añade nada. Main devuelve "ready".

### 2. Modificar un valor en cadena

```vb
# Adjust y ambas Subs declaran total As Integer ByRef. Increment cambia 3 a 4; DoubleValue recibe 4 y lo convierte en 8. RaiseEvent escribe 8 en Main. Se eliminan ambas suscripciones. Integer 8 es una cantidad, no True/False; RaiseEvent no devuelve valor.
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

**Explicación de los parámetros y la ejecución:**

Adjust y ambas Subs declaran total As Integer ByRef. Increment cambia 3 a 4; DoubleValue recibe 4 y lo convierte en 8. RaiseEvent escribe 8 en Main. Se eliminan ambas suscripciones. Integer 8 es una cantidad, no True/False; RaiseEvent no devuelve valor.

### 3. Capturar un error y continuar

```vb
# Ready no tiene parámetros. First añade A, Failing añade B y lanza un error; Last se omite en esa llamada. Catch guarda el mensaje y Finally elimina Failing. La siguiente llamada añade AC. Main devuelve "ABAC:handler failed". Se incluyen todos los controladores y State.
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

**Explicación de los parámetros y la ejecución:**

Ready no tiene parámetros. First añade A, Failing añade B y lanza un error; Last se omite en esa llamada. Catch guarda el mensaje y Finally elimina Failing. La siguiente llamada añade AC. Main devuelve "ABAC:handler failed". Se incluyen todos los controladores y State.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: eventDeclaration / eventHandler / raiseEvent
Runtime/EventCatalog.cs: Build / TryResolve / HandlerError
Analysis/EventValidator.cs: ValidateHandler / ValidateRaise / ValidateNativeNames
Runtime/Interpreter.Events.cs: VisitEventHandler / VisitRaiseEvent
Runtime/Interpreter.cs: CallSubrutine / ExecuteSubrutine / ByRef copy-back
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/event-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/addhandler-statement
-->
