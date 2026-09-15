# Class / New / Me / Property

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ru -->

Class объединяет состояние отдельного объекта и методы скрипта. New создаёт объект-ссылку: присваивание другой переменной сохраняет тот же объект, в отличие от копирования значения Structure. В примерах полностью приведены все используемые конструкторы, методы и свойства.

## Точный синтаксис

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

## Параметры

- `TypeName / Public / Private` — TypeName — уникальное простое имя на уровне файла или Module; снаружи модуля используйте ModuleName.TypeName. Class по умолчанию Public; Private Class доступен только внутри своего Module. Наследование, интерфейсы, обобщения, вложенные классы, Shared, перегрузки, деструкторы и объявления Event внутри экземпляра не реализованы.
- `field As FieldType / Me` — Поле требует As Integer, Double, Boolean, String, Object, объявленный Enum, Structure или Class; действуют также существующие псевдонимы типов Basic. Поля по умолчанию Private; для внешнего доступа явно укажите Public. Начальные числа/Boolean — 0, String — пустая строка, Structure — нулевые поля, Object/Class — Nothing (Unit). Другие значения задавайте в Sub New. Me — текущий экземпляр, его нельзя переприсвоить или объявить заново; параметры и локальные переменные могут скрывать другие имена членов.
- `New / Sub New` — New TypeName(arguments) создаёт отдельные поля и один раз выполняет Public Sub New. Без конструктора разрешено только New TypeName(). Конструктор один; работают обычные правила Optional, значений по умолчанию и именованных аргументов. Выражения аргументов вычисляются один раз в порядке записи; при ошибке объект не возвращается. Объявление переменной только As TypeName оставляет Nothing.
- `Sub / Function / arguments` — Методы объявляются Sub или Function. Снаружи вызывайте instance.Method(...), внутри класса — Method(...) или Me.Method(...). Private-метод доступен только из своего Class, в том числе для другого экземпляра того же класса. Работают типы параметров, ByVal/ByRef, Optional, ParamArray и именованные аргументы; именованная передача элементов ParamArray не поддерживается. Function возвращает объявленный тип, Sub — Unit. TypeName.Method(...) и instance.New(...) недопустимы. Для AddressOf метода экземпляра нужна отдельная процедура-обёртка файла/модуля.
- `Property / Get / Set` — Property Name[()] As ValueType не принимает индексных параметров. Читать нужно instance.Name, без скобок вызова. Get возвращает значение через Return или присваивание имени Name; Exit Property возвращает это значение либо значение типа по умолчанию. instance.Name=expression вызывает Set(ByVal value As ValueType), не читая конечный Get. Обычное свойство требует по одному Get и Set. Доступность задавайте на Property, а не на отдельных блоках; Set требует один явный ByVal-параметр того же типа.
- `ReadOnly / WriteOnly / auto Property` — ReadOnly с телом содержит только Get, WriteOnly — только Set. Чтение WriteOnly или запись ReadOnly вызывает перехватываемую ошибку. Автосвойство не имеет блоков Get/Set и End Property: оно хранит значение напрямую. ReadOnly-автосвойство можно записать только в Sub New этого экземпляра; WriteOnly без Set недопустим. Если ReadOnly возвращает ссылку на Class, изменяемые члены самого возвращённого объекта менять разрешено.
- `ByVal / ByRef / With` — ByVal копирует ссылку: изменение членов затрагивает исходный объект, а замена параметра не заменяет переменную вызывающего кода. ByRef записывает значение обратно, включая новую ссылку, по существующим правилам copy-in/copy-out движка. Равенство ссылок проверяет один и тот же объект. With instance один раз запоминает объект и поддерживает поля, свойства и методы. Class не становится IDisposable автоматически; Using применяйте к поддерживаемым объектам ресурсов.

## Возвращает

New возвращает Object со ссылкой на экземпляр Class, а не ID или графику UO. Чтение свойства и Function возвращают объявленный тип; Set, Sub и объявления — Unit. Переменная класса без New содержит Nothing. Равенство ссылок и результат As Boolean используют 1/True и 0/False; числовое количество Integer не является автоматически флагом успеха. Main в примерах возвращает "5:2:1", "1:0:6" и "ore:1:replacement:0".

## Поведение

- SC032 отклоняет неверные объявления до выполнения, даже без Option Explicit. Пределы: 256 классов, 256 полей/свойств и 256 методов на класс; 32 вложенных вызова, включая конструкторы и Get/Set. Путь записи/ByRef ограничен 64 компонентами. Циклические ссылки Class разрешены. Метаданные и начальные значения подготовлены заранее, изменяемые ячейки создаются отдельно для каждого New.
- Путь к объекту запоминается до вычисления правой части либо аргументов; каждый Get в этом пути выполняется один раз. Обратная запись сохраняет исходную цель, даже если процедура заменила переменную на пути. Значение приводится к объявленному типу. Ошибки конструктора, метода и свойства обрабатываются обычным Try/Catch; уже сделанные изменения не откатываются.
- Пауза, остановка, номера строк и ограничение глубины работают через обычные кадры скрипта. Закрытие IDE само по себе не завершает скрипт. Инспектор показывает краткий тип и количество членов, не вызывая Get и не обходя циклы. В Watch можно читать хранимые поля/автосвойства, но нельзя выполнять пользовательские Get, методы или конструкторы. Поддерживается описанный набор скриптового языка, не произвольные классы .NET.

## Примеры

### 1. Независимые объекты и общая ссылка

```vb
# New Counter(label:="ore", start:=2) передаёт строку label и число start; конструктор записывает Label и stored. second получает отдельные поля. alias=first копирует ссылку. Add(amount:=3) записывает через Value.Set, который проверяет отрицательное значение, затем возвращает Integer из Value.Get. first становится 5, second остаётся 2, alias=first даёт 1/True. Все вспомогательные методы и оба блока свойства приведены полностью.
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

**Разбор параметров и выполнения:**

New Counter(label:="ore", start:=2) передаёт строку label и число start; конструктор записывает Label и stored. second получает отдельные поля. alias=first копирует ссылку. Add(amount:=3) записывает через Value.Set, который проверяет отрицательное значение, затем возвращает Integer из Value.Get. first становится 5, second остаётся 2, alias=first даёт 1/True. Все вспомогательные методы и оба блока свойства приведены полностью.

### 2. Чтение, запись и логический результат

```vb
# budget.Limit=10 вызывает Set с value=10. Remaining.Get читает amount без возможности внешней записи и показывает присваивание результату свойства вместе с Exit Property. TrySpend(cost:=4) вычитает четыре и возвращает 1/True; cost=9 больше остатка шесть, поэтому возвращается 0/False. Limit=-3 вызывает ошибку до изменения amount, а Catch читает Remaining=6. Main возвращает "1:0:6"; игровых действий здесь нет.
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

**Разбор параметров и выполнения:**

budget.Limit=10 вызывает Set с value=10. Remaining.Get читает amount без возможности внешней записи и показывает присваивание результату свойства вместе с Exit Property. TrySpend(cost:=4) вычитает четыре и возвращает 1/True; cost=9 больше остатка шесть, поэтому возвращается 0/False. Limit=-3 вызывает ошибку до изменения amount, а Catch читает Remaining=6. Main возвращает "1:0:6"; игровых действий здесь нет.

### 3. Модуль, изменение через ByVal и замена через ByRef

```vb
# Jobs.WorkItem(name) сохраняет строковый Name, а Done начинается с нуля. Tick(ByVal job) увеличивает Done общего объекта до 1, затем меняет только свой локальный параметр на объект "local". Replace(ByRef job, ByVal name) создаёт "replacement" и записывает новую ссылку в переменную вызывающего кода; имена аргументов специально указаны в обратном порядке. original остаётся объектом "ore" с Done=1, а job указывает на новый объект с Done=0. Все процедуры приведены внутри Module Jobs.
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

**Разбор параметров и выполнения:**

Jobs.WorkItem(name) сохраняет строковый Name, а Done начинается с нуля. Tick(ByVal job) увеличивает Done общего объекта до 1, затем меняет только свой локальный параметр на объект "local". Replace(ByRef job, ByVal name) создаёт "replacement" и записывает новую ссылку в переменную вызывающего кода; имена аргументов специально указаны в обратном порядке. original остаётся объектом "ore" с Done=1, а job указывает на новый объект с Done=0. Все процедуры приведены внутри Module Jobs.


### Внутренние функции: от вызова до результата

Class объединяет состояние отдельного объекта и методы скрипта. New создаёт объект-ссылку: присваивание другой переменной сохраняет тот же объект, в отличие от копирования значения Structure. В примерах полностью приведены все используемые конструкторы, методы и свойства.

#### 1. ClassCatalog.Build / Complete

SC032 отклоняет неверные объявления до выполнения, даже без Option Explicit. Пределы: 256 классов, 256 полей/свойств и 256 методов на класс; 32 вложенных вызова, включая конструкторы и Get/Set. Путь записи/ByRef ограничен 64 компонентами. Циклические ссылки Class разрешены. Метаданные и начальные значения подготовлены заранее, изменяемые ячейки создаются отдельно для каждого New.

`declarations -> unique typed members -> accessor validation -> prepared metadata; SC032 on invalid Class`

Исходник проекта: `external/InjectionScript/src/InjectionScript/Runtime/ClassCatalog.cs`; функция `ClassCatalog.Build / Complete`.

#### 2. ConstructClass

New TypeName(arguments) создаёт отдельные поля и один раз выполняет Public Sub New. Без конструктора разрешено только New TypeName(). Конструктор один; работают обычные правила Optional, значений по умолчанию и именованных аргументов. Выражения аргументов вычисляются один раз в порядке записи; при ошибке объект не возвращается. Объявление переменной только As TypeName оставляет Nothing.

`new instance -> independent field slots -> bind constructor arguments -> Sub New -> Object reference`

Исходник проекта: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Classes.cs`; функция `ConstructClass`.

#### 3. ClassObject.Member / Read

Property Name[()] As ValueType не принимает индексных параметров. Читать нужно instance.Name, без скобок вызова. Get возвращает значение через Return или присваивание имени Name; Exit Property возвращает это значение либо значение типа по умолчанию. instance.Name=expression вызывает Set(ByVal value As ValueType), не читая конечный Get. Обычное свойство требует по одному Get и Set. Доступность задавайте на Property, а не на отдельных блоках; Set требует один явный ByVal-параметр того же типа.

`check member visibility -> stored value OR Get frame -> declared value type`

Исходник проекта: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ClassObject.cs`; функция `ClassObject.Member / Read`.

#### 4. MemberAccess.Resolve / ClassObject.Write

Путь к объекту запоминается до вычисления правой части либо аргументов; каждый Get в этом пути выполняется один раз. Обратная запись сохраняет исходную цель, даже если процедура заменила переменную на пути. Значение приводится к объявленному типу. Ошибки конструктора, метода и свойства обрабатываются обычным Try/Catch; уже сделанные изменения не откатываются.

`capture receiver once -> evaluate RHS/arguments -> coerce value -> Set OR stored slot`

Исходник проекта: `external/InjectionScript/src/InjectionScript/Runtime/MemberAccess.cs`; функция `MemberAccess.Resolve / ClassObject.Write`.

#### 5. CallClassMethod / CallSubrutine

Методы объявляются Sub или Function. Снаружи вызывайте instance.Method(...), внутри класса — Method(...) или Me.Method(...). Private-метод доступен только из своего Class, в том числе для другого экземпляра того же класса. Работают типы параметров, ByVal/ByRef, Optional, ParamArray и именованные аргументы; именованная передача элементов ParamArray не поддерживается. Function возвращает объявленный тип, Sub — Unit. TypeName.Method(...) и instance.New(...) недопустимы. Для AddressOf метода экземпляра нужна отдельная процедура-обёртка файла/модуля.

`check method visibility -> bind named/positional arguments -> Me frame -> return -> ByRef copy-out`

Исходник проекта: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.Classes.cs`; функция `CallClassMethod / CallSubrutine`.

#### 6. ClassObject.DisplayValue

Пауза, остановка, номера строк и ограничение глубины работают через обычные кадры скрипта. Закрытие IDE само по себе не завершает скрипт. Инспектор показывает краткий тип и количество членов, не вызывая Get и не обходя циклы. В Watch можно читать хранимые поля/автосвойства, но нельзя выполнять пользовательские Get, методы или конструкторы. Поддерживается описанный набор скриптового языка, не произвольные классы .NET.

`debugger: type + member count; no getter calls and no traversal of reference cycles`

Исходник проекта: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/ClassObject.cs`; функция `ClassObject.DisplayValue`.

New возвращает Object со ссылкой на экземпляр Class, а не ID или графику UO. Чтение свойства и Function возвращают объявленный тип; Set, Sub и объявления — Unit. Переменная класса без New содержит Nothing. Равенство ссылок и результат As Boolean используют 1/True и 0/False; числовое количество Integer не является автоматически флагом успеха. Main в примерах возвращает "5:2:1", "1:0:6" и "ore:1:replacement:0".

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
