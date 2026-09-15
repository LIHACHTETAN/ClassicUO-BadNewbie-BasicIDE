# CreateTimer / script timers

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ru -->

CreateTimer создаёт остановленный таймер обратного вызова. Start планирует выполнение Sub в потоке этого скрипта. Это расширение проекта; Basic Timer() отдельно возвращает прошедшие секунды.

## Точный синтаксис

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

## Параметры

- `milliseconds` — Integer, миллисекунды от 1 до 2147483647. Строка, дробь, ноль и отрицательное значение дают ошибку. У SetInterval те же правила. Interval() возвращает заданный интервал, а не оставшееся время.
- `handler` — AddressOf однозначно объявленной Sub строго без параметров либо переменная/фабрика обратного вызова этого скрипта. Function, Optional/ParamArray, строка с именем и чужая ссылка не подходят. Общие данные обработчиков храните в Module; локальное замыкание не создаётся.
- `repeating` — Третий параметр необязателен: True/1 — повторять, False/0 — один вызов. По умолчанию True. Именованная запись repeating:=. Другие числа и строки недопустимы. Однократный таймер отключается перед входом в обработчик.
- `timer / Start / Stop / Dispose / SetInterval` — Объект имеет Start(), Stop(), Dispose(), Enabled(), Interval(), SetInterval(milliseconds). Повторный Start включённого таймера ничего не меняет. После Stop разрешён Start. SetInterval отсчитывает новый интервал включённого таймера от текущего момента; остановленный остаётся остановленным. Dispose повторяем и окончателен: после него Start/SetInterval дают ошибку. Using освобождает захваченный объект при выходе.

## Возвращает

CreateTimer возвращает Object (ScriptTimer), не ID предмета и не индекс скрипта. Start/Stop/Dispose/SetInterval возвращают Unit. Enabled — Integer 1=True или 0=False: можно сравнивать обоими способами. Interval — миллисекунды, не Boolean. Результаты примеров: String "3:0", "ready:0", "tick failed:0".

## Поведение

- Движок проверяет монотонное прошедшее время между инструкциями и внутри Basic Wait/Sleep и Wait Until. При включённых таймерах Wait делится на части не длиннее 25 мс. Игровая команда или другой блокирующий нативный вызов сначала должны завершиться. Точность реального времени не гарантируется; новые потоки не создаются.
- Готовые таймеры вызываются по сроку, при равенстве — по порядку создания. До 64 обработчиков за одну проверку; оставшиеся — при следующей. Пока выполняется обработчик, другие таймеры этого скрипта не входят повторно, даже при Wait. Повторный интервал отсчитывается от завершения; пропущенные срабатывания не накапливаются. Пауза останавливает вызовы. После возобновления просроченный таймер срабатывает один раз.
- Ошибка отключает таймер и передаётся в Catch/Finally вызывающего кода. Stop и смена интервала из обработчика учитываются. Аварийная остановка не превращается в обычную ошибку Catch. При завершении, ошибке или остановке корневого запуска все его таймеры освобождаются; при новом запуске/загрузке создайте их заново. Закрытие только IDE сохраняет таймеры работающего скрипта. До 1024 неосвобождённых таймеров на интерпретатор; Dispose освобождает место.
- RunThreePulses и GetHandler ниже полностью показаны и являются функциями примеров. Внутри движка CreateTimer проверяет параметры и владельца, сохраняет остановленный объект; Start записывает срок; Pump вызывает Sub; Fire назначает следующий срок после завершения; Release освобождает объекты при выходе из корневой процедуры. После завершения скрипта отдельная служба таймеров не остаётся.

## Примеры

### 1. Три периодических вызова и освобождение

```vb
# Main вызывает полностью показанную RunThreePulses. 20 — интервал в миллисекундах; третий параметр пропущен, поэтому repeating=True. CountPulse увеличивает State.count и останавливает таймер на трёх. Wait Until выполняет проверки и обработчики с таймаутом 3000 мс. После Stop значение Enabled() равно 0; результат "3:0". Using освобождает таймер даже при Return из функции.
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

**Разбор параметров и выполнения:**

Main вызывает полностью показанную RunThreePulses. 20 — интервал в миллисекундах; третий параметр пропущен, поэтому repeating=True. CountPulse увеличивает State.count и останавливает таймер на трёх. Wait Until выполняет проверки и обработчики с таймаутом 3000 мс. После Stop значение Enabled() равно 0; результат "3:0". Using освобождает таймер даже при Return из функции.

### 2. Однократный вызов и именованные параметры

```vb
# GetHandler возвращает AddressOf SetReady. Именованные аргументы задают 5 мс, callback и repeating=False. SetInterval меняет интервал на 10 до Start. SetReady сохраняет "ready" в Module; однократный таймер уже отключён. Main ждёт не больше 3000 мс и возвращает "ready:0". Все функции и процедуры приведены целиком.
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

**Разбор параметров и выполнения:**

GetHandler возвращает AddressOf SetReady. Именованные аргументы задают 5 мс, callback и repeating=False. SetInterval меняет интервал на 10 до Start. SetReady сохраняет "ready" в Module; однократный таймер уже отключён. Main ждёт не больше 3000 мс и возвращает "ready:0". Все функции и процедуры приведены целиком.

### 3. Ошибка таймера во время ожидания

```vb
# FailingPulse создаёт ошибку "tick failed". Таймер на 5 мс срабатывает внутри Wait(2000), отключается при ошибке и прерывает ожидание. Catch сохраняет текст и Enabled()=0; Finally освобождает объект. Возвращается "tick failed:0" — сообщение и логическое состояние. Аварийную остановку обрабатывает движок, этот Catch её не поглощает.
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

**Разбор параметров и выполнения:**

FailingPulse создаёт ошибку "tick failed". Таймер на 5 мс срабатывает внутри Wait(2000), отключается при ошибке и прерывает ожидание. Catch сохраняет текст и Enabled()=0; Finally освобождает объект. Возвращается "tick failed:0" — сообщение и логическое состояние. Аварийную остановку обрабатывает движок, этот Catch её не поглощает.


### Внутренние функции: от вызова до результата

RunThreePulses и GetHandler ниже полностью показаны и являются функциями примеров. Внутри движка CreateTimer проверяет параметры и владельца, сохраняет остановленный объект; Start записывает срок; Pump вызывает Sub; Fire назначает следующий срок после завершения; Release освобождает объекты при выходе из корневой процедуры. После завершения скрипта отдельная служба таймеров не остаётся.

#### 1. CreateTimer

Integer, миллисекунды от 1 до 2147483647. Строка, дробь, ноль и отрицательное значение дают ошибку. У SetInterval те же правила. Interval() возвращает заданный интервал, а не оставшееся время.

AddressOf однозначно объявленной Sub строго без параметров либо переменная/фабрика обратного вызова этого скрипта. Function, Optional/ParamArray, строка с именем и чужая ссылка не подходят. Общие данные обработчиков храните в Module; локальное замыкание не создаётся.

Третий параметр необязателен: True/1 — повторять, False/0 — один вызов. По умолчанию True. Именованная запись repeating:=. Другие числа и строки недопустимы. Однократный таймер отключается перед входом в обработчик.

CreateTimer возвращает Object (ScriptTimer), не ID предмета и не индекс скрипта. Start/Stop/Dispose/SetInterval возвращают Unit. Enabled — Integer 1=True или 0=False: можно сравнивать обоими способами. Interval — миллисекунды, не Boolean. Результаты примеров: String "3:0", "ready:0", "tick failed:0".

Исходник проекта: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Timers.cs`; функция `CreateTimer`.

#### 2. Start

Объект имеет Start(), Stop(), Dispose(), Enabled(), Interval(), SetInterval(milliseconds). Повторный Start включённого таймера ничего не меняет. После Stop разрешён Start. SetInterval отсчитывает новый интервал включённого таймера от текущего момента; остановленный остаётся остановленным. Dispose повторяем и окончателен: после него Start/SetInterval дают ошибку. Using освобождает захваченный объект при выходе.

`Due = now + interval; enabled = true;`

Исходник проекта: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ScriptTimerObject.cs`; функция `Start`.

#### 3. WaitWithTimers

Движок проверяет монотонное прошедшее время между инструкциями и внутри Basic Wait/Sleep и Wait Until. При включённых таймерах Wait делится на части не длиннее 25 мс. Игровая команда или другой блокирующий нативный вызов сначала должны завершиться. Точность реального времени не гарантируется; новые потоки не создаются.

`checkpoint -> Pump -> min(remaining, nextDue, 25 ms) -> Wait`

Исходник проекта: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Timers.cs`; функция `WaitWithTimers`.

#### 4. Pump

Готовые таймеры вызываются по сроку, при равенстве — по порядку создания. До 64 обработчиков за одну проверку; оставшиеся — при следующей. Пока выполняется обработчик, другие таймеры этого скрипта не входят повторно, даже при Wait. Повторный интервал отсчитывается от завершения; пропущенные срабатывания не накапливаются. Пауза останавливает вызовы. После возобновления просроченный таймер срабатывает один раз.

`snapshot -> deadline / sequence -> checkpoint -> Fire; limit = 64`

Исходник проекта: `external/InjectionScript/src/InjectionScript/Runtime/ScriptTimerScheduler.cs`; функция `Pump`.

#### 5. Fire

Ошибка отключает таймер и передаётся в Catch/Finally вызывающего кода. Stop и смена интервала из обработчика учитываются. Аварийная остановка не превращается в обычную ошибку Catch. При завершении, ошибке или остановке корневого запуска все его таймеры освобождаются; при новом запуске/загрузке создайте их заново. Закрытие только IDE сохраняет таймеры работающего скрипта. До 1024 неосвобождённых таймеров на интерпретатор; Dispose освобождает место.

`callback -> completion -> next Due; error -> disabled -> throw`

Исходник проекта: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ScriptTimerObject.cs`; функция `Fire`.

#### 6. Dispose

Объект имеет Start(), Stop(), Dispose(), Enabled(), Interval(), SetInterval(milliseconds). Повторный Start включённого таймера ничего не меняет. После Stop разрешён Start. SetInterval отсчитывает новый интервал включённого таймера от текущего момента; остановленный остаётся остановленным. Dispose повторяем и окончателен: после него Start/SetInterval дают ошибку. Using освобождает захваченный объект при выходе.

`Release -> scheduler.Remove -> Changed`

Исходник проекта: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ScriptTimerObject.cs`; функция `Dispose`.

#### 7. Release

Ошибка отключает таймер и передаётся в Catch/Finally вызывающего кода. Stop и смена интервала из обработчика учитываются. Аварийная остановка не превращается в обычную ошибку Catch. При завершении, ошибке или остановке корневого запуска все его таймеры освобождаются; при новом запуске/загрузке создайте их заново. Закрытие только IDE сохраняет таймеры работающего скрипта. До 1024 неосвобождённых таймеров на интерпретатор; Dispose освобождает место.

`timer.Release for each handle -> timers.Clear -> no pending deadline`

Исходник проекта: `external/InjectionScript/src/InjectionScript/Runtime/ScriptTimerScheduler.cs`; функция `Release`.

Main вызывает полностью показанную RunThreePulses. 20 — интервал в миллисекундах; третий параметр пропущен, поэтому repeating=True. CountPulse увеличивает State.count и останавливает таймер на трёх. Wait Until выполняет проверки и обработчики с таймаутом 3000 мс. После Stop значение Enabled() равно 0; результат "3:0". Using освобождает таймер даже при Return из функции.

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
