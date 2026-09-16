# Async / Await / Delay

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: uk -->

Async Function створює завдання скрипту. Await призупиняє цю функцію, дозволяючи іншій готовій роботі того самого скрипту виконуватися. Це спільне виконання Basic без нового потоку та повної бібліотеки Task із VB.NET.

## Точний синтаксис

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

## Параметри

- `milliseconds` — Delay приймає Integer від 0 до 2147483647 мілісекунд. Нуль завершується одразу; від’ємне, дробове значення та String спричиняють перехоплювану помилку. Монотонний час задає мінімальне очікування, а не гарантію точності запуску.
- `Async Function / ByVal / Task(Of T)` — As Task — без результату; As Task(Of T) — скалярний тип Basic або Object/Variant. Потрібні явні ByVal чи ParamArray; Optional та іменовані аргументи підтримуються. ByRef і Async Sub/Declare заборонені. Створюйте завдання в тілі процедури, після ініціалізації глобальних полів і типових значень параметрів.
- `task / Await` — Зберігайте завдання без оголошеного типу або As Object. Await приймає завдання цього запуску як окрему інструкцію, всю праву частину одного скалярного оголошення/присвоєння або Return Await. Заборонені арифметика, умови, присвоєння полю/індексу, Catch, Finally та використання поза Async Function. Кілька функцій можуть чекати одне завдання; циклічна залежність дає помилку.
- `IsCompleted / IsFaulted / IsCanceled / Result` — IsCompleted — 1 після успіху, помилки чи скасування; IsFaulted — 1 за помилки; IsCanceled — 1 за скасування. Ці Integer-перевірки порівнюються з True/False. Result() повертає збережене значення, дає помилку до завершення та повторно передає помилку невдалого завдання. Завдання попереднього запуску недійсні.

## Повертає

Виклик Async Function зі скрипту та Delay повертають Object (ScriptTask), не готове T. Await і Result() повертають T; As Task і Delay завершуються з Unit, без значення. Запускаючи Async Function як головну процедуру, клієнт чекає й отримує кінцевий результат. Числові дані не обов’язково Boolean.

## Поведінка

- Функція одразу працює до першого незавершеного Await. Локальні змінні, позиція циклу, об’єкт With та кадр налагоджувача зберігаються й відновлюються. Готове завдання не призупиняє виконання; операнд Await обчислюється один раз.
- Потік скрипту перевіряє строки в безпечних точках і виконує до 64 готових продовжень за прохід. Нових потоків немає. Звичайний Wait або тривалий ігровий/нативний виклик може затримати інші завдання; використовуйте Await Delay. Межа — 1024 незавершені завдання або непрочитані помилки.
- Пауза блокує продовження, але час іде; відновлення обробляє готові завдання. Стоп, помилка чи завершення головної процедури скасовує решту та звільняє Using-ресурси й ітератори. Аварійне скасування оминає скриптові Catch/Finally. Непрочитана помилка повідомляється під час виходу з головної процедури. Закриття IDE саме по собі не зупиняє скрипт.
- Немає Task.Run/WhenAll, зовнішніх завдань .NET, Async Sub, Await у Catch/Finally та локальних As Task. Не залишайте завдання після завершення Main. Async/Await — зарезервовані слова.

## Приклади

### 1. Два незалежні очікування

```vb
# ValueLater отримує value і milliseconds за значенням. Обидва виклики запускаються до читання результатів: 22 готове за 10 мс, 20 — за 30 мс. Main чекає обидва максимум 5000 мс; Result() повертає Integer, сума — 42. Таймаут Wait Until спричиняє помилку.
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

**Пояснення параметрів і виконання:**

ValueLater отримує value і milliseconds за значенням. Обидва виклики запускаються до читання результатів: 22 готове за 10 мс, 20 — за 30 мс. Main чекає обидва максимум 5000 мс; Result() повертає Integer, сума — 42. Таймаут Wait Until спричиняє помилку.

### 2. Перехоплення помилки

```vb
# FailLater не має результату й дає помилку за 5 мс. ReadFailure отримує її на Await, зберігає текст і встановлює спільний прапорець у Finally. Main чекає до 5000 мс і повертає String "failed:1"; 1 — True. У Catch/Finally немає Await.
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

**Пояснення параметрів і виконання:**

FailLater не має результату й дає помилку за 5 мс. ReadFailure отримує її на Await, зберігає текст і встановлює спільний прапорець у Finally. Main чекає до 5000 мс і повертає String "failed:1"; 1 — True. У Catch/Finally немає Await.

### 3. Цикл і передавання результату

```vb
# IncrementLater(value) чекає 5 мс і повертає value+1. SumLater послідовно чекає виклики для i=1..3, зберігаючи total та i. ForwardResult передає 9 через Return Await. Main повертає Integer 9 — суму, не логічне значення.
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

**Пояснення параметрів і виконання:**

IncrementLater(value) чекає 5 мс і повертає value+1. SumLater послідовно чекає виклики для i=1..3, зберігаючи total та i. ForwardResult передає 9 через Return Await. Main повертає Integer 9 — суму, не логічне значення.


### Внутрішні функції: від виклику до результату

Функція одразу працює до першого незавершеного Await. Локальні змінні, позиція циклу, об’єкт With та кадр налагоджувача зберігаються й відновлюються. Готове завдання не призупиняє виконання; операнд Await обчислюється один раз.

#### 1. Delay

Delay приймає Integer від 0 до 2147483647 мілісекунд. Нуль завершується одразу; від’ємне, дробове значення та String спричиняють перехоплювану помилку. Монотонний час задає мінімальне очікування, а не гарантію точності запуску.

due = monotonicNow + milliseconds
return task

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/ScriptAsyncScheduler.cs`; функція `Delay`.

#### 2. ResolveAwaitTask

Зберігайте завдання без оголошеного типу або As Object. Await приймає завдання цього запуску як окрему інструкцію, всю праву частину одного скалярного оголошення/присвоєння або Return Await. Заборонені арифметика, умови, присвоєння полю/індексу, Catch, Finally та використання поза Async Function. Кілька функцій можуть чекати одне завдання; циклічна залежність дає помилку.

validate owner and dependency chain
evaluate operand once

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Async.cs`; функція `ResolveAwaitTask`.

#### 3. ExecuteSubrutine

Функція одразу працює до першого незавершеного Await. Локальні змінні, позиція циклу, об’єкт With та кадр налагоджувача зберігаються й відновлюються. Готове завдання не призупиняє виконання; операнд Await обчислюється один раз.

save locals, With receiver, debugger frame
suspend until task completes
restore saved state

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.cs`; функція `ExecuteSubrutine`.

#### 4. Pump

Потік скрипту перевіряє строки в безпечних точках і виконує до 64 готових продовжень за прохід. Нових потоків немає. Звичайний Wait або тривалий ігровий/нативний виклик може затримати інші завдання; використовуйте Await Delay. Межа — 1024 незавершені завдання або непрочитані помилки.

if earliest deadline reached: complete delays
resume at most 64 queued continuations
refresh function results

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/ScriptAsyncScheduler.cs`; функція `Pump`.

#### 5. GetResult

IsCompleted — 1 після успіху, помилки чи скасування; IsFaulted — 1 за помилки; IsCanceled — 1 за скасування. Ці Integer-перевірки порівнюються з True/False. Result() повертає збережене значення, дає помилку до завершення та повторно передає помилку невдалого завдання. Завдання попереднього запуску недійсні.

if pending: error
if failed: rethrow
return saved value

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ScriptTaskObject.cs`; функція `GetResult`.

#### 6. Release

Пауза блокує продовження, але час іде; відновлення обробляє готові завдання. Стоп, помилка чи завершення головної процедури скасовує решту та звільняє Using-ресурси й ітератори. Аварійне скасування оминає скриптові Catch/Finally. Непрочитана помилка повідомляється під час виходу з головної процедури. Закриття IDE саме по собі не зупиняє скрипт.

cancel pending tasks
drain cleanup continuations
release resources
report unobserved failure

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/ScriptAsyncScheduler.cs`; функція `Release`.

Виклик Async Function зі скрипту та Delay повертають Object (ScriptTask), не готове T. Await і Result() повертають T; As Task і Delay завершуються з Unit, без значення. Запускаючи Async Function як головну процедуру, клієнт чекає й отримує кінцевий результат. Числові дані не обов’язково Boolean.

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
