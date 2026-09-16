# Async / Await / Delay

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ru -->

Async Function создаёт задачу скрипта. Await приостанавливает эту функцию и позволяет выполнять другую готовую работу того же скрипта. Это совместное выполнение Basic, без нового потока и без полной библиотеки Task из VB.NET.

## Точный синтаксис

```text
Async Function Work(ByVal value As Integer) As Task(Of Integer)
    Await Delay(100)
    Return value
End Function
Async Function Work() As Task
    Await Delay(100)
End Function
Delay(milliseconds) -> Object (ScriptTask)
Await task
Dim value = Await task
value = Await task
Return Await task
task.IsCompleted() -> Integer (0/1)
task.IsFaulted() -> Integer (0/1)
task.IsCanceled() -> Integer (0/1)
task.Result() -> T / Unit
```

## Параметры

- `milliseconds` — Delay принимает Integer от 0 до 2147483647 миллисекунд. Ноль завершает задачу сразу. Отрицательное, дробное значение и String вызывают перехватываемую ошибку. Используется монотонное время; срок — минимальное ожидание, точность запуска не гарантируется.
- `Async Function / ByVal / Task(Of T)` — As Task означает отсутствие результата, As Task(Of T) — скалярный тип Basic либо Object/Variant. Параметры требуют явного ByVal или ParamArray; Optional и именованные аргументы поддерживаются. ByRef и Async Sub/Declare запрещены. Создавайте задачи внутри процедур, после инициализации глобальных полей и значений параметров по умолчанию.
- `task / Await` — Храните задачу в переменной без типа или As Object. Await принимает задачу текущего запуска: отдельной инструкцией, всей правой частью одного скалярного объявления/присваивания либо Return Await. Нельзя вставлять Await в арифметику, условия, присваивание полю/индексу, Catch или Finally. Вне Async Function он запрещён. Одну задачу могут ожидать несколько функций; циклическое ожидание вызывает ошибку.
- `IsCompleted / IsFaulted / IsCanceled / Result` — IsCompleted равен 1 после успеха, ошибки или отмены; IsFaulted — 1 при ошибке, IsCanceled — 1 при отмене. Эти Integer-проверки допускают сравнение с True/False. Result() возвращает сохранённое значение; незавершённая задача вызывает ошибку, завершившаяся с ошибкой повторно её передаёт. Задачи предыдущего запуска использовать нельзя.

## Возвращает

Вызов Async Function из скрипта и Delay возвращают Object (ScriptTask), а не готовое T. Await и Result() возвращают T; As Task и Delay завершаются с Unit, без значения. Если клиент запускает Async Function как главную процедуру, он ожидает её и получает конечный результат. Числовые данные не становятся автоматически Boolean.

## Поведение

- Функция сразу выполняется до первого незавершённого Await. Сохраняются локальные переменные, положение цикла, объект With и кадр отладчика; при продолжении они восстанавливаются. Готовая задача не приостанавливает выполнение. Операнд Await вычисляется один раз.
- Поток этого скрипта проверяет сроки в безопасных точках и выполняет до 64 готовых продолжений за проход. Новые потоки не создаются. Обычный Wait или длительный игровой/нативный вызов может задержать другие задачи; внутри асинхронных функций используйте Await Delay. Предел — 1024 незавершённые задачи или ошибки, которые ещё не прочитаны.
- Пауза блокирует продолжения, но время идёт; после возобновления обрабатываются готовые задачи. Стоп, ошибка или завершение главной процедуры отменяет оставшиеся задачи и освобождает Using-ресурсы и итераторы. Аварийная отмена не выполняет скриптовые Catch/Finally. Непрочитанная ошибка задачи сообщается при выходе из главной процедуры. Закрытие IDE само по себе не останавливает скрипт.
- Не поддерживаются Task.Run/WhenAll, внешние задачи .NET, Async Sub, Await в Catch/Finally и локальные объявления As Task. Не оставляйте задачи после возврата из Main. Async/Await — зарезервированные слова движка.

## Примеры

### 1. Два независимых ожидания

```vb
# ValueLater получает value и milliseconds по значению. Оба вызова стартуют до чтения результатов: 22 готово через 10 мс, 20 — через 30 мс. Main ожидает обе задачи максимум 5000 мс; Result() возвращает Integer, сумма равна 42. Истечение таймаута Wait Until вызывает ошибку.
Option Explicit On
Async Function ValueLater(ByVal value As Integer, ByVal milliseconds As Integer) As Task(Of Integer)
    Await Delay(milliseconds)
    Return value
End Function

Sub Main()
    Dim first = ValueLater(20, 30)
    Dim second = ValueLater(22, 10)
    Wait Until first.IsCompleted() AndAlso second.IsCompleted() Timeout 5000
    Return first.Result() + second.Result()
End Sub
```

**Разбор параметров и выполнения:**

ValueLater получает value и milliseconds по значению. Оба вызова стартуют до чтения результатов: 22 готово через 10 мс, 20 — через 30 мс. Main ожидает обе задачи максимум 5000 мс; Result() возвращает Integer, сумма равна 42. Истечение таймаута Wait Until вызывает ошибку.

### 2. Перехват ошибки ожидания

```vb
# FailLater не возвращает значение и выбрасывает ошибку после 5 мс. ReadFailure получает её на Await, сохраняет текст и устанавливает общий флаг очистки в Finally. Main ждёт максимум 5000 мс и возвращает String "failed:1"; 1 означает True. В Catch/Finally нет Await.
Option Explicit On
Module State
    Public Dim cleaned As Boolean = False
End Module

Async Function FailLater() As Task
    Await Delay(5)
    Throw "failed"
End Function

Async Function ReadFailure() As Task(Of String)
    Dim message As String = ""
    Try
        Await FailLater()
    Catch problem
        message = problem
    Finally
        State.cleaned = True
    End Try
    Return message & ":" & CStr(State.cleaned)
End Function

Sub Main()
    Dim task = ReadFailure()
    Wait Until task.IsCompleted() Timeout 5000
    Return task.Result()
End Sub
```

**Разбор параметров и выполнения:**

FailLater не возвращает значение и выбрасывает ошибку после 5 мс. ReadFailure получает её на Await, сохраняет текст и устанавливает общий флаг очистки в Finally. Main ждёт максимум 5000 мс и возвращает String "failed:1"; 1 означает True. В Catch/Finally нет Await.

### 3. Цикл и передача результата

```vb
# IncrementLater(value) ждёт 5 мс и возвращает value+1. SumLater последовательно ожидает вызовы для i=1..3, сохраняя total и i. ForwardResult передаёт 9 через Return Await. Main ждёт задачу и возвращает Integer 9 — сумму, а не логический результат.
Option Explicit On
Async Function IncrementLater(ByVal value As Integer) As Task(Of Integer)
    Await Delay(5)
    Return value + 1
End Function

Async Function SumLater() As Task(Of Integer)
    Dim total As Integer = 0
    For Var i = 1 To 3
        Dim nextValue = Await IncrementLater(i)
        total += nextValue
    Next
    Return total
End Function

Async Function ForwardResult() As Task(Of Integer)
    Return Await SumLater()
End Function

Sub Main()
    Dim task = ForwardResult()
    Wait Until task.IsCompleted() Timeout 5000
    Return task.Result()
End Sub
```

**Разбор параметров и выполнения:**

IncrementLater(value) ждёт 5 мс и возвращает value+1. SumLater последовательно ожидает вызовы для i=1..3, сохраняя total и i. ForwardResult передаёт 9 через Return Await. Main ждёт задачу и возвращает Integer 9 — сумму, а не логический результат.


### Внутренние функции: от вызова до результата

Функция сразу выполняется до первого незавершённого Await. Сохраняются локальные переменные, положение цикла, объект With и кадр отладчика; при продолжении они восстанавливаются. Готовая задача не приостанавливает выполнение. Операнд Await вычисляется один раз.

#### 1. Delay

Delay принимает Integer от 0 до 2147483647 миллисекунд. Ноль завершает задачу сразу. Отрицательное, дробное значение и String вызывают перехватываемую ошибку. Используется монотонное время; срок — минимальное ожидание, точность запуска не гарантируется.

due = monotonicNow + milliseconds
return task

Исходник проекта: `external/InjectionScript/src/InjectionScript/Runtime/ScriptAsyncScheduler.cs`; функция `Delay`.

#### 2. ResolveAwaitTask

Храните задачу в переменной без типа или As Object. Await принимает задачу текущего запуска: отдельной инструкцией, всей правой частью одного скалярного объявления/присваивания либо Return Await. Нельзя вставлять Await в арифметику, условия, присваивание полю/индексу, Catch или Finally. Вне Async Function он запрещён. Одну задачу могут ожидать несколько функций; циклическое ожидание вызывает ошибку.

validate owner and dependency chain
evaluate operand once

Исходник проекта: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Async.cs`; функция `ResolveAwaitTask`.

#### 3. ExecuteSubrutine

Функция сразу выполняется до первого незавершённого Await. Сохраняются локальные переменные, положение цикла, объект With и кадр отладчика; при продолжении они восстанавливаются. Готовая задача не приостанавливает выполнение. Операнд Await вычисляется один раз.

save locals, With receiver, debugger frame
suspend until task completes
restore saved state

Исходник проекта: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.cs`; функция `ExecuteSubrutine`.

#### 4. Pump

Поток этого скрипта проверяет сроки в безопасных точках и выполняет до 64 готовых продолжений за проход. Новые потоки не создаются. Обычный Wait или длительный игровой/нативный вызов может задержать другие задачи; внутри асинхронных функций используйте Await Delay. Предел — 1024 незавершённые задачи или ошибки, которые ещё не прочитаны.

if earliest deadline reached: complete delays
resume at most 64 queued continuations
refresh function results

Исходник проекта: `external/InjectionScript/src/InjectionScript/Runtime/ScriptAsyncScheduler.cs`; функция `Pump`.

#### 5. GetResult

IsCompleted равен 1 после успеха, ошибки или отмены; IsFaulted — 1 при ошибке, IsCanceled — 1 при отмене. Эти Integer-проверки допускают сравнение с True/False. Result() возвращает сохранённое значение; незавершённая задача вызывает ошибку, завершившаяся с ошибкой повторно её передаёт. Задачи предыдущего запуска использовать нельзя.

if pending: error
if failed: rethrow
return saved value

Исходник проекта: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ScriptTaskObject.cs`; функция `GetResult`.

#### 6. Release

Пауза блокирует продолжения, но время идёт; после возобновления обрабатываются готовые задачи. Стоп, ошибка или завершение главной процедуры отменяет оставшиеся задачи и освобождает Using-ресурсы и итераторы. Аварийная отмена не выполняет скриптовые Catch/Finally. Непрочитанная ошибка задачи сообщается при выходе из главной процедуры. Закрытие IDE само по себе не останавливает скрипт.

cancel pending tasks
drain cleanup continuations
release resources
report unobserved failure

Исходник проекта: `external/InjectionScript/src/InjectionScript/Runtime/ScriptAsyncScheduler.cs`; функция `Release`.

Вызов Async Function из скрипта и Delay возвращают Object (ScriptTask), а не готовое T. Await и Result() возвращают T; As Task и Delay завершаются с Unit, без значения. Если клиент запускает Async Function как главную процедуру, он ожидает её и получает конечный результат. Числовые данные не становятся автоматически Boolean.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: ASYNC / awaitExpression / taskType
Analysis/AsyncValidator.cs: supported statement forms and signatures
Runtime/Interpreter.cs: ExecuteSubrutine / statement suspension / cleanup
Runtime/Interpreter.Async.cs: ResolveAwaitTask / ResumeAsync / WaitForTask
Runtime/ScriptAsyncScheduler.cs: Delay / Track / Pump / Release
Runtime/ObjectTypes/ScriptTaskObject.cs: GetResult / Complete / Awaiter
Runtime/SemanticScope.cs: SuspendCurrent / Resume
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/modifiers/async
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/operators/await-operator
-->
