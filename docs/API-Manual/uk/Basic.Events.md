# Event / AddHandler / RemoveHandler / RaiseEvent

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: uk -->

Event оголошує подію скрипту. AddHandler підключає Sub, RemoveHandler відключає її, а RaiseEvent синхронно викликає обробники в порядку підключення.

## Точний синтаксис

```text
Event Changed(ByVal value As Integer)
Public Event Adjust(ByRef value As Integer)
Private Event Completed()
AddHandler EventName, AddressOf Handler
AddHandler Module.EventName, callback
RemoveHandler EventName, AddressOf Handler
RaiseEvent EventName(arguments)
```

## Параметри

- `EventName / Public / Private` — Оголошуйте просте ім’я на рівні файлу (неявного модуля) або всередині Module, поза процедурами. Типовий доступ Public; Private потребує Module. Ззовні використовуйте Module.EventName. RaiseEvent дозволений лише модулю, що оголосив подію, навіть Public. Ім’я не повинно збігатися з процедурою чи змінною.
- `Handler / callback` — Handler — однозначно оголошена Sub: AddressOf або змінна/фабрика зворотного виклику цього завантаженого скрипту. Function, рядок з ім’ям, чужі посилання та перевантаження не підходять. Кількість, типи та режими ByVal/ByRef мають збігатися. У Sub явно пишіть ByVal: звичайні процедури зберігають старий типовий режим ByRef.
- `arguments / ByVal / ByRef` — RaiseEvent потребує всіх позиційних аргументів. Optional, ParamArray, типові значення, іменовані аргументи події та Safe Call не підтримуються. Параметр Event типовий ByVal: копіює скаляр або посилання, а не вміст об’єкта. Зміни ByRef бачать наступні обробники; вони записуються у змінну чи елемент колекції викликача. Аргументи й індекси обчислюються один раз у порядку запису.

## Повертає

Event, AddHandler, RemoveHandler і RaiseEvent не повертають значення (Unit), зокрема Boolean, ID чи кількість підписників. Результат передавайте через ByRef або спільний Module. Main у прикладах повертає String "ready", Integer 8 та String "ABAC:handler failed".

## Поведінка

- Підписки належать одному інтерпретатору. Інші скрипти та повторне завантаження починають без них. Наступні входи в той самий інтерпретатор зберігають підписки до видалення чи звільнення інтерпретатора. Закриття IDE залишає запущений скрипт із підписками, але не створює окремої фонової служби.
- AddHandler додає в кінець; повторні підписки повторюють виклик Sub. RemoveHandler видаляє останнє входження; відсутність збігу нічого не змінює. Перевіряються оголошення, доступ і сигнатура, обчислюються аргументи, потім фіксується незмінний список. Зміни підписок під час обробки діють із наступного RaiseEvent.
- Помилка обробника зупиняє поточний обхід і надходить у Catch/Finally викликача; попередні зміни ByRef записуються назад. Пауза й аварійна зупинка діють усередині обробника; Catch не поглинає аварійну зупинку. Новий потік не створюється. Блокувальні нативні виклики зберігають власні обмеження скасування.
- Межі: 4096 підписок на подію, 16 вкладених RaiseEvent, 32 вкладені кадри процедур. Цикли подій і глибока рекурсія дають перехоплювану помилку скрипту замість переповнення стека клієнта. Для глибокої обробки використовуйте цикл. Спільні скаляри зберігайте в Module; скаляри старого формату на рівні файлу успадковуються як копії.
- Це оголошені скриптом події, які ваш код викликає явно. Автоматичної підписки на ігрові пакети чи журнал немає. Handles, WithEvents, Custom Event, типи делегатів подій і події класів тут не реалізовані. Слова Basic пишуться без UO.; ігрові команди — з UO.

## Приклади

### 1. Підключити та відключити

```vb
# Feed.Message передає text As String ByVal. Повністю наведена Feed.Publish викликає подію, Record додає текст у спільне State.log. handler підписує Record; "ready" зберігається. RemoveHandler знаходить ту саму Sub навіть з AddressOf на іншому рядку. "ignored" після відключення нічого не додає; Main повертає "ready".
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

**Пояснення параметрів і виконання:**

Feed.Message передає text As String ByVal. Повністю наведена Feed.Publish викликає подію, Record додає текст у спільне State.log. handler підписує Record; "ready" зберігається. RemoveHandler знаходить ту саму Sub навіть з AddressOf на іншому рядку. "ignored" після відключення нічого не додає; Main повертає "ready".

### 2. Послідовно змінити значення

```vb
# Adjust і обидві Sub мають total As Integer ByRef. Increment змінює 3 на 4; DoubleValue отримує 4 та робить 8. RaiseEvent записує 8 у total процедури Main. Обидві підписки видаляються. Integer 8 — кількість, не True/False; RaiseEvent результату не має.
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

**Пояснення параметрів і виконання:**

Adjust і обидві Sub мають total As Integer ByRef. Increment змінює 3 на 4; DoubleValue отримує 4 та робить 8. RaiseEvent записує 8 у total процедури Main. Обидві підписки видаляються. Integer 8 — кількість, не True/False; RaiseEvent результату не має.

### 3. Перехопити помилку та продовжити

```vb
# Ready без параметрів. First додає A, Failing додає B і кидає помилку, тому Last пропускається. Catch зберігає повідомлення, Finally відключає Failing. Наступний виклик додає AC. Main повертає "ABAC:handler failed". Усі обробники та спільний State наведено повністю.
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

**Пояснення параметрів і виконання:**

Ready без параметрів. First додає A, Failing додає B і кидає помилку, тому Last пропускається. Catch зберігає повідомлення, Finally відключає Failing. Наступний виклик додає AC. Main повертає "ABAC:handler failed". Усі обробники та спільний State наведено повністю.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: eventDeclaration / eventHandler / raiseEvent
Runtime/EventCatalog.cs: Build / TryResolve / HandlerError
Analysis/EventValidator.cs: ValidateHandler / ValidateRaise / ValidateNativeNames
Runtime/Interpreter.Events.cs: VisitEventHandler / VisitRaiseEvent
Runtime/Interpreter.cs: CallSubrutine / ExecuteSubrutine / ByRef copy-back
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/event-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/addhandler-statement
-->
