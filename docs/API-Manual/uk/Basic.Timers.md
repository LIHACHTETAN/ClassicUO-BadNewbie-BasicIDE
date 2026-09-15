# CreateTimer / script timers

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: uk -->

CreateTimer створює зупинений таймер зворотного виклику. Start планує Sub у потоці цього скрипту. Це розширення проєкту; Basic Timer() окремо повертає минулі секунди.

## Точний синтаксис

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

## Параметри

- `milliseconds` — Integer у мілісекундах, 1..2147483647. Рядок, дріб, нуль та від’ємне значення — помилка. SetInterval має ті самі правила. Interval() повертає заданий інтервал, не залишок часу.
- `handler` — AddressOf однозначної Sub без жодних параметрів або змінна/фабрика зворотного виклику цього скрипту. Function, Optional/ParamArray, рядок з ім’ям і чуже посилання не підходять. Спільні дані зберігайте в Module; локальне замикання не створюється.
- `repeating` — Необов’язковий третій аргумент: True/1 повторює, False/0 викликає один раз. Типово True. Іменований аргумент repeating:=. Інші числа та рядки — помилка. Одноразовий таймер вимикається перед обробником.
- `timer / Start / Stop / Dispose / SetInterval` — Методи об’єкта: Start, Stop, Dispose, Enabled, Interval, SetInterval(milliseconds). Start увімкненого таймера нічого не змінює. Після Stop дозволено Start. SetInterval перезапускає інтервал увімкненого таймера від поточного часу; зупинений не вмикає. Dispose повторюваний і остаточний; подальші Start/SetInterval помилкові. Using звільняє захоплений об’єкт при виході.

## Повертає

CreateTimer → Object (ScriptTimer), не ID предмета чи індекс скрипту. Start/Stop/Dispose/SetInterval → Unit. Enabled → Integer 1=True або 0=False; обидва порівняння допустимі. Interval → мілісекунди, не Boolean. Приклади повертають String "3:0", "ready:0", "tick failed:0".

## Поведінка

- Перевірка монотонного часу відбувається між інструкціями та всередині Basic Wait/Sleep і Wait Until. З увімкненими таймерами Wait ділиться на частини до 25 мс. Ігровий або інший блокувальний нативний виклик спочатку мусить завершитися. Точність реального часу не гарантована; додаткових потоків немає.
- Порядок: строк, а за рівності — створення; до 64 обробників за перевірку, решта — за наступну. Під час обробника інші таймери цього скрипту повторно не входять, навіть при Wait. Новий інтервал починається після завершення; пропущені виклики не накопичуються. Пауза зупиняє виклики; після відновлення прострочений таймер викликається один раз.
- Помилка вимикає таймер і переходить у Catch/Finally виклику. Зміни Stop/SetInterval з обробника враховуються. Аварійна зупинка не поглинається Catch. Завершення, помилка або зупинка кореневого запуску звільняють усі його таймери; новий запуск/завантаження потребує нових. Закриття лише IDE зберігає таймери працюючого скрипту. До 1024 незвільнених об’єктів; Dispose звільняє місце.
- RunThreePulses та GetHandler — повністю наведені допоміжні функції прикладів. Усередині CreateTimer перевіряє параметри й власника; Start задає строк; Pump викликає Sub; Fire відраховує наступний інтервал від завершення; Release звільняє об’єкти при виході. Окремої служби після скрипту немає.

## Приклади

### 1. Три виклики й очищення

```vb
# RunThreePulses створює таймер на 20 мс; пропущений третій аргумент означає repeating=True. CountPulse збільшує State.count та викликає Stop на трьох. Wait Until перевіряє стан і таймери з межею 3000 мс. Enabled()=0 дає "3:0". Using звільняє об’єкт навіть при Return.
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

**Пояснення параметрів і виконання:**

RunThreePulses створює таймер на 20 мс; пропущений третій аргумент означає repeating=True. CountPulse збільшує State.count та викликає Stop на трьох. Wait Until перевіряє стан і таймери з межею 3000 мс. Enabled()=0 дає "3:0". Using звільняє об’єкт навіть при Return.

### 2. Одноразовий виклик

```vb
# GetHandler повертає AddressOf SetReady. Іменовані аргументи задають 5 мс, callback, repeating=False. SetInterval змінює 5 на 10 до Start. SetReady записує "ready"; таймер вже вимкнено. Main чекає до 3000 мс та повертає "ready:0". Усі допоміжні процедури наведено.
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

**Пояснення параметрів і виконання:**

GetHandler повертає AddressOf SetReady. Іменовані аргументи задають 5 мс, callback, repeating=False. SetInterval змінює 5 на 10 до Start. SetReady записує "ready"; таймер вже вимкнено. Main чекає до 3000 мс та повертає "ready:0". Усі допоміжні процедури наведено.

### 3. Помилка під час Wait

```vb
# FailingPulse кидає "tick failed". Таймер 5 мс спрацьовує у Wait(2000), вимикається і перериває очікування. Catch читає текст та Enabled()=0; Finally звільняє таймер. Результат "tick failed:0" містить текст і стан. Аварійну зупинку Catch не перехоплює.
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

**Пояснення параметрів і виконання:**

FailingPulse кидає "tick failed". Таймер 5 мс спрацьовує у Wait(2000), вимикається і перериває очікування. Catch читає текст та Enabled()=0; Finally звільняє таймер. Результат "tick failed:0" містить текст і стан. Аварійну зупинку Catch не перехоплює.


### Внутрішні функції: від виклику до результату

RunThreePulses та GetHandler — повністю наведені допоміжні функції прикладів. Усередині CreateTimer перевіряє параметри й власника; Start задає строк; Pump викликає Sub; Fire відраховує наступний інтервал від завершення; Release звільняє об’єкти при виході. Окремої служби після скрипту немає.

#### 1. CreateTimer

Integer у мілісекундах, 1..2147483647. Рядок, дріб, нуль та від’ємне значення — помилка. SetInterval має ті самі правила. Interval() повертає заданий інтервал, не залишок часу.

AddressOf однозначної Sub без жодних параметрів або змінна/фабрика зворотного виклику цього скрипту. Function, Optional/ParamArray, рядок з ім’ям і чуже посилання не підходять. Спільні дані зберігайте в Module; локальне замикання не створюється.

Необов’язковий третій аргумент: True/1 повторює, False/0 викликає один раз. Типово True. Іменований аргумент repeating:=. Інші числа та рядки — помилка. Одноразовий таймер вимикається перед обробником.

CreateTimer → Object (ScriptTimer), не ID предмета чи індекс скрипту. Start/Stop/Dispose/SetInterval → Unit. Enabled → Integer 1=True або 0=False; обидва порівняння допустимі. Interval → мілісекунди, не Boolean. Приклади повертають String "3:0", "ready:0", "tick failed:0".

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Timers.cs`; функція `CreateTimer`.

#### 2. Start

Методи об’єкта: Start, Stop, Dispose, Enabled, Interval, SetInterval(milliseconds). Start увімкненого таймера нічого не змінює. Після Stop дозволено Start. SetInterval перезапускає інтервал увімкненого таймера від поточного часу; зупинений не вмикає. Dispose повторюваний і остаточний; подальші Start/SetInterval помилкові. Using звільняє захоплений об’єкт при виході.

`Due = now + interval; enabled = true;`

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ScriptTimerObject.cs`; функція `Start`.

#### 3. WaitWithTimers

Перевірка монотонного часу відбувається між інструкціями та всередині Basic Wait/Sleep і Wait Until. З увімкненими таймерами Wait ділиться на частини до 25 мс. Ігровий або інший блокувальний нативний виклик спочатку мусить завершитися. Точність реального часу не гарантована; додаткових потоків немає.

`checkpoint -> Pump -> min(remaining, nextDue, 25 ms) -> Wait`

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Timers.cs`; функція `WaitWithTimers`.

#### 4. Pump

Порядок: строк, а за рівності — створення; до 64 обробників за перевірку, решта — за наступну. Під час обробника інші таймери цього скрипту повторно не входять, навіть при Wait. Новий інтервал починається після завершення; пропущені виклики не накопичуються. Пауза зупиняє виклики; після відновлення прострочений таймер викликається один раз.

`snapshot -> deadline / sequence -> checkpoint -> Fire; limit = 64`

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/ScriptTimerScheduler.cs`; функція `Pump`.

#### 5. Fire

Помилка вимикає таймер і переходить у Catch/Finally виклику. Зміни Stop/SetInterval з обробника враховуються. Аварійна зупинка не поглинається Catch. Завершення, помилка або зупинка кореневого запуску звільняють усі його таймери; новий запуск/завантаження потребує нових. Закриття лише IDE зберігає таймери працюючого скрипту. До 1024 незвільнених об’єктів; Dispose звільняє місце.

`callback -> completion -> next Due; error -> disabled -> throw`

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ScriptTimerObject.cs`; функція `Fire`.

#### 6. Dispose

Методи об’єкта: Start, Stop, Dispose, Enabled, Interval, SetInterval(milliseconds). Start увімкненого таймера нічого не змінює. Після Stop дозволено Start. SetInterval перезапускає інтервал увімкненого таймера від поточного часу; зупинений не вмикає. Dispose повторюваний і остаточний; подальші Start/SetInterval помилкові. Using звільняє захоплений об’єкт при виході.

`Release -> scheduler.Remove -> Changed`

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ScriptTimerObject.cs`; функція `Dispose`.

#### 7. Release

Помилка вимикає таймер і переходить у Catch/Finally виклику. Зміни Stop/SetInterval з обробника враховуються. Аварійна зупинка не поглинається Catch. Завершення, помилка або зупинка кореневого запуску звільняють усі його таймери; новий запуск/завантаження потребує нових. Закриття лише IDE зберігає таймери працюючого скрипту. До 1024 незвільнених об’єктів; Dispose звільняє місце.

`timer.Release for each handle -> timers.Clear -> no pending deadline`

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/ScriptTimerScheduler.cs`; функція `Release`.

RunThreePulses створює таймер на 20 мс; пропущений третій аргумент означає repeating=True. CountPulse збільшує State.count та викликає Stop на трьох. Wait Until перевіряє стан і таймери з межею 3000 мс. Enabled()=0 дає "3:0". Using звільняє об’єкт навіть при Return.

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
