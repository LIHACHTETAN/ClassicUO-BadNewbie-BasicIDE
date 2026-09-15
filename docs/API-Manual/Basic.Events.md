# Event / AddHandler / RemoveHandler / RaiseEvent

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ru -->

Event объявляет событие скрипта. AddHandler подключает Sub, RemoveHandler отключает её, а RaiseEvent синхронно вызывает обработчики в порядке подключения.

## Точный синтаксис

```text
Event Changed(ByVal value As Integer)
Public Event Adjust(ByRef value As Integer)
Private Event Completed()
AddHandler EventName, AddressOf Handler
AddHandler Module.EventName, callback
RemoveHandler EventName, AddressOf Handler
RaiseEvent EventName(arguments)
```

## Параметры

- `EventName / Public / Private` — Объявляйте простое имя события на уровне файла — неявного модуля скрипта — либо внутри Module, вне процедур. По умолчанию доступ Public. Private требует Module. Снаружи подписывайтесь через Module.EventName. Вызывать RaiseEvent может только объявивший событие модуль, даже для Public. Имя не должно совпадать с процедурой или переменной.
- `Handler / callback` — Handler — однозначно объявленная Sub: AddressOf либо переменная/фабрика обратного вызова этого загруженного скрипта. Function, строка с именем, чужая ссылка и перегрузки не подходят. Количество, типы и режимы ByVal/ByRef должны точно совпадать. В обработчиках явно пишите ByVal: у обычных процедур прежний режим по умолчанию — ByRef.
- `arguments / ByVal / ByRef` — RaiseEvent принимает все аргументы позиционно. Optional, ParamArray, значения по умолчанию, именованные аргументы события и Safe Call не поддерживаются. Параметр Event по умолчанию ByVal: копируется скаляр или ссылка, но не содержимое объекта. Изменения ByRef видны следующим обработчикам и записываются обратно в доступную для записи переменную или элемент коллекции. Аргументы и индексы вычисляются один раз в порядке записи.

## Возвращает

Event, AddHandler, RemoveHandler и RaiseEvent не возвращают значения (Unit): это не Boolean, не ID и не количество подписчиков. Для результата используйте ByRef или общее состояние Module. Main в примерах возвращает String "ready", Integer 8 и String "ABAC:handler failed".

## Поведение

- Подписки принадлежат одному интерпретатору. У другого скрипта и после повторной загрузки их нет. При следующих входах в тот же загруженный интерпретатор они сохраняются до удаления или освобождения интерпретатора. Закрытие IDE сохраняет работающий скрипт с подписками, но не создаёт отдельную фоновую службу событий.
- AddHandler добавляет подписку в конец; повторная подписка повторно вызывает ту же Sub. RemoveHandler удаляет последнее её вхождение; отсутствие совпадения ничего не меняет. Движок проверяет объявление, доступ и сигнатуру, вычисляет аргументы, затем берёт неизменяемый список обработчиков. Подписки, изменённые внутри обработчика, влияют на следующий RaiseEvent.
- Ошибка обработчика прекращает текущий обход и передаётся в Catch/Finally вызывающего кода; сделанные изменения ByRef записываются обратно. Пауза и аварийная остановка работают внутри обработчиков. Catch не поглощает аварийную остановку. Новый поток не создаётся; ограничения отмены блокирующего нативного вызова сохраняются.
- Ограничения: 4096 подписок на событие, 16 вложенных RaiseEvent и 32 вложенных кадра процедур. Цикл событий или глубокая рекурсия дают перехватываемую ошибку скрипта вместо переполнения стека клиента. Для глубокой обработки используйте цикл. Общие скаляры храните в полях Module; скаляры старого формата на уровне файла по-прежнему наследуются как копии.
- Это события, объявленные и явно вызванные вашим скриптом. Синтаксис сам не подписывается на пакеты игры или изменения журнала. Handles, WithEvents, Custom Event, типы делегатов событий и события классов здесь не реализованы. Ключевые слова Basic пишутся без UO.; игровые команды сохраняют UO.

## Примеры

### 1. Подключить и отключить обработчик

```vb
# Feed.Message передаёт text As String по значению. Полностью показанная Feed.Publish вызывает событие. Record добавляет текст в общее State.log. Переменная handler подключает Record; публикация "ready" сохраняет текст. RemoveHandler с AddressOf Record на другой строке находит ту же Sub. После отключения "ignored" ничего не добавляет. Main возвращает "ready".
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

**Разбор параметров и выполнения:**

Feed.Message передаёт text As String по значению. Полностью показанная Feed.Publish вызывает событие. Record добавляет текст в общее State.log. Переменная handler подключает Record; публикация "ready" сохраняет текст. RemoveHandler с AddressOf Record на другой строке находит ту же Sub. После отключения "ignored" ничего не добавляет. Main возвращает "ready".

### 2. Передать изменяемое значение по цепочке

```vb
# В Adjust и обеих Sub параметр total As Integer объявлен ByRef. Начальное 3 превращается в 4 внутри Increment; DoubleValue получает уже 4 и делает 8. RaiseEvent записывает 8 в total вызывающей Main. Затем обе подписки удаляются. Integer 8 — количество, а не True/False; у самого RaiseEvent результата нет.
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

**Разбор параметров и выполнения:**

В Adjust и обеих Sub параметр total As Integer объявлен ByRef. Начальное 3 превращается в 4 внутри Increment; DoubleValue получает уже 4 и делает 8. RaiseEvent записывает 8 в total вызывающей Main. Затем обе подписки удаляются. Integer 8 — количество, а не True/False; у самого RaiseEvent результата нет.

### 3. Обработать ошибку и продолжить

```vb
# Ready не имеет параметров. First добавляет A, Failing добавляет B и вызывает ошибку; Last в этом обходе пропускается. Catch сохраняет сообщение, Finally отключает Failing. Следующий RaiseEvent вызывает First и Last, добавляя AC. Результат Main — "ABAC:handler failed". Все обработчики и общий модуль State приведены полностью.
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

**Разбор параметров и выполнения:**

Ready не имеет параметров. First добавляет A, Failing добавляет B и вызывает ошибку; Last в этом обходе пропускается. Catch сохраняет сообщение, Finally отключает Failing. Следующий RaiseEvent вызывает First и Last, добавляя AC. Результат Main — "ABAC:handler failed". Все обработчики и общий модуль State приведены полностью.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: eventDeclaration / eventHandler / raiseEvent
Runtime/EventCatalog.cs: Build / TryResolve / HandlerError
Analysis/EventValidator.cs: ValidateHandler / ValidateRaise / ValidateNativeNames
Runtime/Interpreter.Events.cs: VisitEventHandler / VisitRaiseEvent
Runtime/Interpreter.cs: CallSubrutine / ExecuteSubrutine / ByRef copy-back
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/event-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/addhandler-statement
-->
