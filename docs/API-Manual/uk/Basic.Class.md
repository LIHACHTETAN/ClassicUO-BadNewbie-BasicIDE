# Class / New / Me / Property

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: uk -->

Class об’єднує стан окремого об’єкта та методи скрипта. New створює об’єкт-посилання: присвоєння іншій змінній зберігає той самий об’єкт, на відміну від копіювання значення Structure. Приклади містять увесь код конструкторів, методів і властивостей.

## Точний синтаксис

```text
[Public | Private] Class TypeName
    [Public | Private | Dim] field As FieldType
    Public Sub New([parameters]) ... End Sub
    [Public | Private] Sub Method([parameters]) ... End Sub
    [Public | Private] Function Method([parameters]) As ResultType ... End Function
    [Public | Private] [ReadOnly | WriteOnly] Property Name[()] As ValueType
        Get ... Return value / Name = value / Exit Property ... End Get
        Set(ByVal value As ValueType) ... End Set
    End Property
    Public Property AutoName As ValueType
End Class
Dim instance [As TypeName] = New TypeName(arguments)
instance.Property = expression
value = instance.Property
instance.Method(arguments)
With instance ... End With
```

## Параметри

- `TypeName / Public / Private` — TypeName — унікальне просте ім’я на рівні файла або Module; зовні використовуйте ModuleName.TypeName. Class типово Public; Private Class доступний лише у своєму Module. Успадкування, інтерфейси, узагальнення, вкладені класи, Shared, перевантаження, деструктори та Event усередині екземпляра не реалізовані.
- `field As FieldType / Me` — Поле потребує As Integer, Double, Boolean, String, Object, оголошений Enum, Structure чи Class; діють також наявні псевдоніми типів Basic. Поля типово Private, для зовнішнього доступу вкажіть Public. Початкові числа/Boolean — 0, String — порожній, Structure — нульові поля, Object/Class — Nothing (Unit). Інші значення задавайте у Sub New. Me — поточний екземпляр; його не можна перевизначити чи переприсвоїти. Параметри й локальні змінні можуть приховувати інші імена членів.
- `New / Sub New` — New TypeName(arguments) створює окремі поля й один раз виконує Public Sub New. Без конструктора дозволено лише New TypeName(). Конструктор один; діють звичайні Optional, типові значення й іменовані аргументи. Аргументи обчислюються один раз у порядку запису; помилка не повертає створений об’єкт. Змінна лише As TypeName залишається Nothing.
- `Sub / Function / arguments` — Методи — Sub або Function. Зовні викликайте instance.Method(...), усередині — Method(...) чи Me.Method(...). Private доступний тільки зі свого Class, зокрема для іншого екземпляра того самого класу. Діють типи, ByVal/ByRef, Optional, ParamArray та іменовані аргументи; іменовані елементи ParamArray не підтримуються. Function повертає оголошений тип, Sub — Unit. TypeName.Method(...) та instance.New(...) заборонені. Для AddressOf методу потрібна процедура-обгортка файла/модуля.
- `Property / Get / Set` — Property Name[()] As ValueType не має індексних параметрів. Читання — instance.Name без дужок виклику. Get повертає значення через Return або присвоєння Name; Exit Property повертає його чи типове значення. instance.Name=expression виконує Set(ByVal value As ValueType), не читаючи кінцевий Get. Звичайна властивість має по одному Get та Set. Доступність задається на Property; Set потребує одного явного ByVal-параметра того самого типу.
- `ReadOnly / WriteOnly / auto Property` — ReadOnly з тілом містить лише Get; WriteOnly — лише Set. Неприпустиме читання/запис спричиняє перехоплювану помилку. Автовластивість зберігає значення без Get/Set та End Property. ReadOnly-автовластивість можна змінити тільки в Sub New цього екземпляра; WriteOnly без Set недійсний. Якщо ReadOnly повертає посилання Class, змінювані члени повернутого об’єкта змінювати можна.
- `ByVal / ByRef / With` — ByVal копіює посилання: зміна членів впливає на оригінал, заміна параметра — лише на локальну змінну. ByRef записує значення, зокрема нове посилання, назад за правилами copy-in/copy-out рушія. Рівність посилань перевіряє тотожність об’єктів. With instance запам’ятовує об’єкт один раз і підтримує поля, властивості й методи. Class не стає IDisposable автоматично; Using застосовуйте до підтримуваних ресурсів.

## Повертає

New повертає Object із посиланням Class, не ID чи графіку UO. Get і Function повертають оголошений тип; Set, Sub та оголошення — Unit. Без New змінна містить Nothing. Рівність посилань та As Boolean — 1/True або 0/False; числова кількість Integer не є автоматичним прапорцем успіху. Результати Main: "5:2:1", "1:0:6", "ore:1:replacement:0".

## Поведінка

- SC032 відхиляє хибні оголошення до запуску навіть без Option Explicit. Межі: 256 класів, 256 полів/властивостей і 256 методів на клас; 32 вкладені виклики разом із конструкторами/Get/Set. Шлях запису/ByRef — до 64 компонентів. Цикли посилань дозволені. Метадані й початкові значення готуються наперед, змінювані комірки належать кожному New окремо.
- Шлях до об’єкта фіксується до обчислення правої частини чи аргументів; кожен Get у шляху виконується один раз. Зворотний запис зберігає початкову ціль, навіть якщо процедура замінила змінну на шляху. Значення приводиться до типу. Помилки методів, властивостей і конструктора перехоплює Try/Catch; попередні зміни не відкочуються.
- Пауза, зупинка, рядки й захист глибини використовують звичайні кадри скрипта. Закриття IDE не зупиняє скрипт. Інспектор показує тип і кількість членів без Get та обходу циклів. Watch читає збережені поля/автовластивості, але не запускає користувацькі Get, методи чи New. Це описана підмножина Basic, не довільні класи .NET.

## Приклади

### 1. Окремі об’єкти та спільне посилання

```vb
# New Counter(label:="ore", start:=2) передає рядок label і Integer start, конструктор зберігає Label та stored. second має власні поля; alias=first копіює посилання. Add(amount:=3) записує через Value.Set із перевіркою від’ємного значення, потім повертає Integer із Value.Get. first=5, second=2, alias=first дає 1/True. Усі методи й блоки наведено.
Option Explicit On
Class Counter
    Private stored As Integer
    Public Property Label As String
    Public Sub New(ByVal label As String, ByVal start As Integer)
        Me.Label = label
        stored = start
    End Sub
    Public Property Value As Integer
        Get
            Return stored
        End Get
        Set(ByVal value As Integer)
            If value < 0 Then
                Throw "Value must be non-negative"
            End If
            stored = value
        End Set
    End Property
    Public Function Add(ByVal amount As Integer) As Integer
        Me.Value = stored + amount
        Return Me.Value
    End Function
End Class

Sub Main()
    Dim first = New Counter(label:="ore", start:=2)
    Dim second = New Counter("wood", 2)
    Dim alias = first
    alias.Add(amount:=3)
    Return CStr(first.Value) & ":" & CStr(second.Value) & ":" & CStr(alias = first)
End Sub
```

**Пояснення параметрів і виконання:**

New Counter(label:="ore", start:=2) передає рядок label і Integer start, конструктор зберігає Label та stored. second має власні поля; alias=first копіює посилання. Add(amount:=3) записує через Value.Set із перевіркою від’ємного значення, потім повертає Integer із Value.Get. first=5, second=2, alias=first дає 1/True. Усі методи й блоки наведено.

### 2. Читання, запис і Boolean

```vb
# Limit=10 передає value=10 у Set. Remaining.Get читає amount, присвоює результат і виходить через Exit Property. TrySpend(cost:=4) віднімає чотири та повертає 1/True; cost=9 перевищує залишок шість — 0/False. Limit=-3 породжує помилку перед зміною; Catch читає Remaining=6. Main повертає "1:0:6" без дій на сервері.
Option Explicit On
Class Budget
    Private amount As Integer
    Public ReadOnly Property Remaining() As Integer
        Get
            Remaining = amount
            Exit Property
        End Get
    End Property
    Public WriteOnly Property Limit As Integer
        Set(ByVal value As Integer)
            If value < 0 Then
                Throw "Limit must be non-negative"
            End If
            amount = value
        End Set
    End Property
    Public Function TrySpend(ByVal cost As Integer) As Boolean
        If cost < 0 Then
            Throw "cost must be non-negative"
        End If
        If cost > amount Then
            Return False
        End If
        amount -= cost
        Return True
    End Function
End Class

Sub Main()
    Dim budget = New Budget()
    budget.Limit = 10
    Dim paid = budget.TrySpend(4)
    Dim refused = budget.TrySpend(9)
    Try
        budget.Limit = -3
    Catch problem
        Return CStr(paid) & ":" & CStr(refused) & ":" & CStr(budget.Remaining)
    End Try
    Return "unexpected"
End Sub
```

**Пояснення параметрів і виконання:**

Limit=10 передає value=10 у Set. Remaining.Get читає amount, присвоює результат і виходить через Exit Property. TrySpend(cost:=4) віднімає чотири та повертає 1/True; cost=9 перевищує залишок шість — 0/False. Limit=-3 породжує помилку перед зміною; Catch читає Remaining=6. Main повертає "1:0:6" без дій на сервері.

### 3. Module, ByVal та ByRef

```vb
# Jobs.WorkItem(name) зберігає рядок Name, Done починається з нуля. Tick(ByVal job) збільшує спільний Done до 1, але наступна заміна job на "local" лишається локальною. Replace(ByRef job, ByVal name) створює "replacement" і записує посилання назад; іменовані аргументи навмисне записані у зворотному порядку. original лишається "ore" з Done=1, job — новий об’єкт із Done=0. Увесь Module Jobs наведено.
Option Explicit On
Module Jobs
    Public Class WorkItem
        Public Property Name As String
        Public Done As Integer
        Public Sub New(ByVal name As String)
            Me.Name = name
        End Sub
    End Class
    Public Sub Tick(ByVal job As WorkItem)
        job.Done += 1
        job = New WorkItem("local")
    End Sub
    Public Sub Replace(ByRef job As WorkItem, ByVal name As String)
        job = New WorkItem(name)
    End Sub
End Module

Sub Main()
    Dim job As Jobs.WorkItem = New Jobs.WorkItem("ore")
    Dim original = job
    Jobs.Tick(job)
    Jobs.Replace(name:="replacement", job:=job)
    Return original.Name & ":" & CStr(original.Done) & ":" & job.Name & ":" & CStr(job.Done)
End Sub
```

**Пояснення параметрів і виконання:**

Jobs.WorkItem(name) зберігає рядок Name, Done починається з нуля. Tick(ByVal job) збільшує спільний Done до 1, але наступна заміна job на "local" лишається локальною. Replace(ByRef job, ByVal name) створює "replacement" і записує посилання назад; іменовані аргументи навмисне записані у зворотному порядку. original лишається "ore" з Done=1, job — новий об’єкт із Done=0. Увесь Module Jobs наведено.


### Внутрішні функції: від виклику до результату

Class об’єднує стан окремого об’єкта та методи скрипта. New створює об’єкт-посилання: присвоєння іншій змінній зберігає той самий об’єкт, на відміну від копіювання значення Structure. Приклади містять увесь код конструкторів, методів і властивостей.

#### 1. ClassCatalog.Build / Complete

SC032 відхиляє хибні оголошення до запуску навіть без Option Explicit. Межі: 256 класів, 256 полів/властивостей і 256 методів на клас; 32 вкладені виклики разом із конструкторами/Get/Set. Шлях запису/ByRef — до 64 компонентів. Цикли посилань дозволені. Метадані й початкові значення готуються наперед, змінювані комірки належать кожному New окремо.

`declarations -> unique typed members -> accessor validation -> prepared metadata; SC032 on invalid Class`

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/ClassCatalog.cs`; функція `ClassCatalog.Build / Complete`.

#### 2. ConstructClass

New TypeName(arguments) створює окремі поля й один раз виконує Public Sub New. Без конструктора дозволено лише New TypeName(). Конструктор один; діють звичайні Optional, типові значення й іменовані аргументи. Аргументи обчислюються один раз у порядку запису; помилка не повертає створений об’єкт. Змінна лише As TypeName залишається Nothing.

`new instance -> independent field slots -> bind constructor arguments -> Sub New -> Object reference`

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Classes.cs`; функція `ConstructClass`.

#### 3. ClassObject.Member / Read

Property Name[()] As ValueType не має індексних параметрів. Читання — instance.Name без дужок виклику. Get повертає значення через Return або присвоєння Name; Exit Property повертає його чи типове значення. instance.Name=expression виконує Set(ByVal value As ValueType), не читаючи кінцевий Get. Звичайна властивість має по одному Get та Set. Доступність задається на Property; Set потребує одного явного ByVal-параметра того самого типу.

`check member visibility -> stored value OR Get frame -> declared value type`

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ClassObject.cs`; функція `ClassObject.Member / Read`.

#### 4. MemberAccess.Resolve / ClassObject.Write

Шлях до об’єкта фіксується до обчислення правої частини чи аргументів; кожен Get у шляху виконується один раз. Зворотний запис зберігає початкову ціль, навіть якщо процедура замінила змінну на шляху. Значення приводиться до типу. Помилки методів, властивостей і конструктора перехоплює Try/Catch; попередні зміни не відкочуються.

`capture receiver once -> evaluate RHS/arguments -> coerce value -> Set OR stored slot`

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/MemberAccess.cs`; функція `MemberAccess.Resolve / ClassObject.Write`.

#### 5. CallClassMethod / CallSubrutine

Методи — Sub або Function. Зовні викликайте instance.Method(...), усередині — Method(...) чи Me.Method(...). Private доступний тільки зі свого Class, зокрема для іншого екземпляра того самого класу. Діють типи, ByVal/ByRef, Optional, ParamArray та іменовані аргументи; іменовані елементи ParamArray не підтримуються. Function повертає оголошений тип, Sub — Unit. TypeName.Method(...) та instance.New(...) заборонені. Для AddressOf методу потрібна процедура-обгортка файла/модуля.

`check method visibility -> bind named/positional arguments -> Me frame -> return -> ByRef copy-out`

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Classes.cs`; функція `CallClassMethod / CallSubrutine`.

#### 6. ClassObject.DisplayValue

Пауза, зупинка, рядки й захист глибини використовують звичайні кадри скрипта. Закриття IDE не зупиняє скрипт. Інспектор показує тип і кількість членів без Get та обходу циклів. Watch читає збережені поля/автовластивості, але не запускає користувацькі Get, методи чи New. Це описана підмножина Basic, не довільні класи .NET.

`debugger: type + member count; no getter calls and no traversal of reference cycles`

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ClassObject.cs`; функція `ClassObject.DisplayValue`.

New повертає Object із посиланням Class, не ID чи графіку UO. Get і Function повертають оголошений тип; Set, Sub та оголошення — Unit. Без New змінна містить Nothing. Рівність посилань та As Boolean — 1/True або 0/False; числова кількість Integer не є автоматичним прапорцем успіху. Результати Main: "5:2:1", "1:0:6", "ore:1:replacement:0".

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: classDeclaration / classProperty / subrutine / newStructure
Runtime/ClassCatalog.cs: Build / Complete
Runtime/ObjectTypes/ClassObject.cs: Member / Read / Write
Runtime/Interpreter.Classes.cs: ConstructClass / CallClassMethod / InvokeAccessor
Runtime/MemberAccess.cs: Resolve / Read / Write
Runtime/SemanticScope.cs: TryMemberSlot / Coerce
Runtime/Interpreter.cs: CallSubrutine / CreateArgumentWriter
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/class-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/property-statement
-->
