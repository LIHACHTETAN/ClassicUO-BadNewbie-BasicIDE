# CreateTimer / script timers

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: es -->

CreateTimer crea un temporizador de callback detenido. Start programa una Sub en el hilo del script. Es una extensión del proyecto; Basic Timer() lee por separado los segundos transcurridos.

## Sintaxis exacta

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

## Parámetros

- `milliseconds` — Integer en milisegundos, 1..2147483647. Cadenas, fracciones, cero y negativos son errores. SetInterval sigue la misma regla. Interval() devuelve el intervalo configurado, no el tiempo restante.
- `handler` — AddressOf de una Sub inequívoca sin parámetros, o variable/fábrica de callback del script cargado. Function, Optional/ParamArray, cadenas con nombres y referencias ajenas se rechazan. Estado compartido en Module; no captura un cierre local.
- `repeating` — Tercer argumento opcional: True/1 repite, False/0 llama una vez. Predeterminado True; nombre repeating:=. Otros números y cadenas son errores. Un temporizador único se desactiva antes del manejador.
- `timer / Start / Stop / Dispose / SetInterval` — Métodos: Start, Stop, Dispose, Enabled, Interval, SetInterval(milliseconds). Start activo no cambia nada. Stop permite otro Start. SetInterval reinicia desde ahora si está activo; uno detenido sigue detenido. Dispose es repetible y definitivo; Start/SetInterval fallan después. Using libera el objeto capturado al salir.

## Devuelve

CreateTimer → Object (ScriptTimer), no ID de objeto ni índice de script. Start/Stop/Dispose/SetInterval → Unit. Enabled → Integer 1=True o 0=False; ambas comparaciones funcionan. Interval → milisegundos, no Boolean. Ejemplos: String "3:0", "ready:0", "tick failed:0".

## Comportamiento

- El reloj monotónico se comprueba entre instrucciones y dentro de Basic Wait/Sleep y Wait Until. Con temporizadores activos, Wait usa segmentos de hasta 25 ms. Una llamada de juego o nativa bloqueante debe terminar primero. No garantiza tiempo real ni crea hilos.
- Orden por vencimiento, luego creación en empates; máximo 64 manejadores por comprobación y el resto en la siguiente. No hay reentrada durante un manejador, incluso si espera. El siguiente intervalo comienza al terminar; se saltan intervalos perdidos. Pausa suspende llamadas; al reanudar, un temporizador vencido se ejecuta una vez.
- Un error desactiva el temporizador y llega a Catch/Finally. Stop/SetInterval dentro del manejador se respetan. Catch no absorbe la parada de emergencia. Final, error o parada de la llamada raíz liberan sus temporizadores; crearlos de nuevo al ejecutar/cargar. Cerrar solamente la IDE conserva los del script activo. Máximo 1024 sin liberar; Dispose devuelve una plaza.
- RunThreePulses y GetHandler están completos. Internamente CreateTimer valida argumentos/propietario; Start fija el plazo; Pump llama la Sub; Fire programa el siguiente plazo tras finalizar; Release libera al salir. No queda un servicio independiente tras el script.

## Ejemplos

### 1. Tres llamadas y limpieza

```vb
# RunThreePulses configura 20 ms, repeating=True por defecto. CountPulse aumenta State.count y para en tres. Wait Until comprueba estado y temporizadores con límite de 3000 ms. Enabled()=0 produce "3:0". Using libera incluso al retornar.
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

**Explicación de los parámetros y la ejecución:**

RunThreePulses configura 20 ms, repeating=True por defecto. CountPulse aumenta State.count y para en tres. Wait Until comprueba estado y temporizadores con límite de 3000 ms. Enabled()=0 produce "3:0". Using libera incluso al retornar.

### 2. Llamada única y argumentos nombrados

```vb
# GetHandler devuelve AddressOf SetReady. Los argumentos indican 5 ms, callback y repeating=False. SetInterval cambia a 10 antes de Start. SetReady escribe "ready"; el temporizador ya está desactivado. Main espera hasta 3000 ms y devuelve "ready:0". Todos los auxiliares están incluidos.
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

**Explicación de los parámetros y la ejecución:**

GetHandler devuelve AddressOf SetReady. Los argumentos indican 5 ms, callback y repeating=False. SetInterval cambia a 10 antes de Start. SetReady escribe "ready"; el temporizador ya está desactivado. Main espera hasta 3000 ms y devuelve "ready:0". Todos los auxiliares están incluidos.

### 3. Error durante Wait

```vb
# FailingPulse lanza "tick failed". El temporizador de 5 ms actúa dentro de Wait(2000), se desactiva e interrumpe la espera. Catch lee texto y Enabled()=0; Finally libera. "tick failed:0" contiene mensaje y estado. La parada de emergencia corresponde al motor.
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

**Explicación de los parámetros y la ejecución:**

FailingPulse lanza "tick failed". El temporizador de 5 ms actúa dentro de Wait(2000), se desactiva e interrumpe la espera. Catch lee texto y Enabled()=0; Finally libera. "tick failed:0" contiene mensaje y estado. La parada de emergencia corresponde al motor.


### Funciones internas: de la llamada al resultado

RunThreePulses y GetHandler están completos. Internamente CreateTimer valida argumentos/propietario; Start fija el plazo; Pump llama la Sub; Fire programa el siguiente plazo tras finalizar; Release libera al salir. No queda un servicio independiente tras el script.

#### 1. CreateTimer

Integer en milisegundos, 1..2147483647. Cadenas, fracciones, cero y negativos son errores. SetInterval sigue la misma regla. Interval() devuelve el intervalo configurado, no el tiempo restante.

AddressOf de una Sub inequívoca sin parámetros, o variable/fábrica de callback del script cargado. Function, Optional/ParamArray, cadenas con nombres y referencias ajenas se rechazan. Estado compartido en Module; no captura un cierre local.

Tercer argumento opcional: True/1 repite, False/0 llama una vez. Predeterminado True; nombre repeating:=. Otros números y cadenas son errores. Un temporizador único se desactiva antes del manejador.

CreateTimer → Object (ScriptTimer), no ID de objeto ni índice de script. Start/Stop/Dispose/SetInterval → Unit. Enabled → Integer 1=True o 0=False; ambas comparaciones funcionan. Interval → milisegundos, no Boolean. Ejemplos: String "3:0", "ready:0", "tick failed:0".

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Timers.cs`; función `CreateTimer`.

#### 2. Start

Métodos: Start, Stop, Dispose, Enabled, Interval, SetInterval(milliseconds). Start activo no cambia nada. Stop permite otro Start. SetInterval reinicia desde ahora si está activo; uno detenido sigue detenido. Dispose es repetible y definitivo; Start/SetInterval fallan después. Using libera el objeto capturado al salir.

`Due = now + interval; enabled = true;`

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ScriptTimerObject.cs`; función `Start`.

#### 3. WaitWithTimers

El reloj monotónico se comprueba entre instrucciones y dentro de Basic Wait/Sleep y Wait Until. Con temporizadores activos, Wait usa segmentos de hasta 25 ms. Una llamada de juego o nativa bloqueante debe terminar primero. No garantiza tiempo real ni crea hilos.

`checkpoint -> Pump -> min(remaining, nextDue, 25 ms) -> Wait`

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Timers.cs`; función `WaitWithTimers`.

#### 4. Pump

Orden por vencimiento, luego creación en empates; máximo 64 manejadores por comprobación y el resto en la siguiente. No hay reentrada durante un manejador, incluso si espera. El siguiente intervalo comienza al terminar; se saltan intervalos perdidos. Pausa suspende llamadas; al reanudar, un temporizador vencido se ejecuta una vez.

`snapshot -> deadline / sequence -> checkpoint -> Fire; limit = 64`

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/ScriptTimerScheduler.cs`; función `Pump`.

#### 5. Fire

Un error desactiva el temporizador y llega a Catch/Finally. Stop/SetInterval dentro del manejador se respetan. Catch no absorbe la parada de emergencia. Final, error o parada de la llamada raíz liberan sus temporizadores; crearlos de nuevo al ejecutar/cargar. Cerrar solamente la IDE conserva los del script activo. Máximo 1024 sin liberar; Dispose devuelve una plaza.

`callback -> completion -> next Due; error -> disabled -> throw`

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ScriptTimerObject.cs`; función `Fire`.

#### 6. Dispose

Métodos: Start, Stop, Dispose, Enabled, Interval, SetInterval(milliseconds). Start activo no cambia nada. Stop permite otro Start. SetInterval reinicia desde ahora si está activo; uno detenido sigue detenido. Dispose es repetible y definitivo; Start/SetInterval fallan después. Using libera el objeto capturado al salir.

`Release -> scheduler.Remove -> Changed`

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ScriptTimerObject.cs`; función `Dispose`.

#### 7. Release

Un error desactiva el temporizador y llega a Catch/Finally. Stop/SetInterval dentro del manejador se respetan. Catch no absorbe la parada de emergencia. Final, error o parada de la llamada raíz liberan sus temporizadores; crearlos de nuevo al ejecutar/cargar. Cerrar solamente la IDE conserva los del script activo. Máximo 1024 sin liberar; Dispose devuelve una plaza.

`timer.Release for each handle -> timers.Clear -> no pending deadline`

Código del proyecto: `external/InjectionScript/src/InjectionScript/Runtime/ScriptTimerScheduler.cs`; función `Release`.

RunThreePulses configura 20 ms, repeating=True por defecto. CountPulse aumenta State.count y para en tres. Wait Until comprueba estado y temporizadores con límite de 3000 ms. Enabled()=0 produce "3:0". Using libera incluso al retornar.

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
