# Structure / New / fields

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: uk -->

Structure об’єднує типізовані поля, наприклад X, Y і Z, в одне значення. Рушій підтримує структури даних із копіюванням значень; нижче описано підтримувану частину, а не весь Structure із VB.NET.

## Точний синтаксис

```text
[Public | Private] Structure TypeName
    [Public | Dim | VAR] field As FieldType
End Structure
Dim value As TypeName
Dim value = New TypeName()
copy = value
value.field = expression
Sub Change(ByRef value As TypeName)
Function Copy(ByVal value As TypeName) As TypeName
```

## Параметри

- `TypeName / Public / Private` — Унікальне просте ім’я типу на рівні файлу або всередині Module. Типово Public. Private дозволено лише в Module; ззовні ім’я такого типу недоступне. Публічний тип модуля: ModuleName.TypeName. Ключові слова та назви полів не перекладаються.
- `field / FieldType` — Унікальне ім’я поля, As і підтримуваний скалярний тип, Enum або інша Structure. Поля публічні; приймаються Public, Dim і VAR. Типи: Integer/Long/Short/Byte, Single/Double/Decimal, String, Boolean/Bool, Object/Variant. Цілі псевдоніми мають 32 біти зі знаком. Вкладені структури не можуть утворювати цикли.
- `Dim / New` — Dim value As TypeName та New TypeName() створюють типове значення без виконання коду користувача. New потребує порожніх дужок. Аргументи X/Y/Z не передаються: задайте поля після створення. Dim copy = value отримує значення виразу. Префікс UO. не потрібний.
- `value.field / copy` — Поля читаються й записуються через крапку, включно з route.Start.X. Запис перевіряє тип поля й оновлює значення, що його містить. copy = value копіює скалярні та вкладені значення: зміна copy.X не змінює value.X. Типи структур мають бути сумісними.
- `ByVal / ByRef` — ByVal передає копію. ByRef копіює на вході та записує назад на виході; оновлення повертається змінній виклику, зокрема полю, яке можна записувати. Указуйте модифікатор явно; без нього діють наявні правила Basic. Return може повернути структуру, Function — оголосити As TypeName.

## Повертає

Оголошення й присвоєння не мають результату (Unit). New та функції зі структурним результатом повертають значення структури, представлене як Object у спостереженні рушія; відображення містить ім’я типу. Числові координати — кількості, а не Boolean. Порівняння = та <> повертають 1/True або 0/False. Результати прикладів: рядки "1445:1447:1690:0", "10:15:24", "2:4:2:2".

## Поведінка

- Перевірка оголошень передує ініціалізаторам. До 256 типів на скрипт, 1–256 полів у кожному, до 32 рівнів вкладеності. Дублікати, невідомі типи полів, цикли та перевищення меж дають SC030. Доступ Private перевіряється під час розв’язання імен.
- Типові поля: ціле/Enum — 0, дробове — 0, Boolean — 0/False, String — порожній рядок, Object/Variant — Unit до присвоєння. Вкладені структури мають власні типові значення. Ініціалізатори полів в оголошенні не підтримуються: присвойте значення після створення.
- Object і масиви зберігають посилання при копіюванні структури. Копії можуть спільно використовувати List, Dictionary або масив. Скалярні й вкладені поля змінюються незалежно, а зміни вмісту спільної колекції видимі обом копіям. List зберігає значення структури на момент додавання.
- = порівнює той самий оголошений тип і відповідні поля; <> дає протилежний результат. Поля-посилання порівнюються за тотожністю. Це розширення рушія, не загальне правило для всіх структур VB.NET. Кешовані хеші й набір уже перевірених пар запобігають повторному розгортанню спільних вкладених значень.
- Підтримуються публічні типізовані поля, доступність типу в Module, New(), присвоєння, параметри й результат функції. Методи всередині Structure, власні конструктори, ініціалізатори, властивості, успадкування та приватні поля не підтримуються. WITH .field та array[index].field не підтримуються: прочитайте елемент у змінну, змініть її й запишіть назад. Оголошення можна винести до Include.

## Приклади

### 1. Координати й незалежна копія

```vb
# original отримує X=1445 та Y=1690; Z лишається 0. copy отримує значення; copy.X += 2 змінює лише копію. New Position() створює empty із Z=0. Чотири поля дають 1445:1447:1690:0. Це збережені координати; скрипт не рухає персонажа.
Option Explicit On
Structure Position
    Public X As Integer
    Public Y As Integer
    Public Z As Integer
End Structure

Sub Main()
    Dim original As Position
    original.X = 1445
    original.Y = 1690
    Dim copy = original
    copy.X += 2
    Dim empty = New Position()
    Return CStr(original.X) & ":" & CStr(copy.X) & ":" & CStr(copy.Y) & ":" & CStr(empty.Z)
End Sub
```

**Пояснення параметрів і виконання:**

original отримує X=1445 та Y=1690; Z лишається 0. copy отримує значення; copy.X += 2 змінює лише копію. New Position() створює empty із Z=0. Чотири поля дають 1445:1447:1690:0. Це збережені координати; скрипт не рухає персонажа.

### 2. Вкладений маршрут, ByVal і ByRef

```vb
# Route містить Start і Finish типу Position. Shift(point ByVal, dx ByVal) додає dx до X копії й повертає Position. point:=route.Start, dx:=5 дають shifted.X=15, а route.Start.X лишається 10. Advance(route ByRef, dx ByVal) додає 4 до Finish.X та записує Route назад: 24. Main повертає 10:15:24; усі допоміжні процедури наведено.
Option Explicit On
Structure Position
    Public X As Integer
    Public Y As Integer
End Structure
Structure Route
    Public Start As Position
    Public Finish As Position
End Structure

Function Shift(ByVal point As Position, ByVal dx As Integer) As Position
    point.X += dx
    Return point
End Function

Sub Advance(ByRef route As Route, ByVal dx As Integer)
    route.Finish.X += dx
End Sub

Sub Main()
    Dim route As Route
    route.Start.X = 10
    route.Finish.X = 20
    Dim shifted = Shift(point:=route.Start, dx:=5)
    Advance(route:=route, dx:=4)
    Return CStr(route.Start.X) & ":" & CStr(shifted.X) & ":" & CStr(route.Finish.X)
End Sub
```

**Пояснення параметрів і виконання:**

Route містить Start і Finish типу Position. Shift(point ByVal, dx ByVal) додає dx до X копії й повертає Position. point:=route.Start, dx:=5 дають shifted.X=15, а route.Start.X лишається 10. Advance(route ByRef, dx ByVal) додає 4 до Finish.X та записує Route назад: 24. Main повертає 10:15:24; усі допоміжні процедури наведено.

### 3. Збережене значення і спільна колекція

```vb
# Entry містить значення Point та Object Items. first.Point.X=2, first.Items — List() з одним рядком. snapshots.Add(first) зберігає значення. Після second=first зміна second.Point.X=4 не змінює збережене 2. second.Items.Add("ingot") змінює спільний List, тому first.Items.Count()=2. saved=snapshots[0] дозволяє прочитати поля елемента. Результат: 2:4:2:2.
Option Explicit On
Structure Position
    Public X As Integer
End Structure
Structure Entry
    Public Point As Position
    Public Items As Object
End Structure

Sub Main()
    Dim first As Entry
    first.Point.X = 2
    first.Items = List()
    first.Items.Add("ore")
    Dim snapshots = List()
    snapshots.Add(first)

    Dim second = first
    second.Point.X = 4
    second.Items.Add("ingot")
    Dim saved = snapshots[0]
    Return CStr(first.Point.X) & ":" & CStr(second.Point.X) & ":" & CStr(saved.Point.X) & ":" & CStr(first.Items.Count())
End Sub
```

**Пояснення параметрів і виконання:**

Entry містить значення Point та Object Items. first.Point.X=2, first.Items — List() з одним рядком. snapshots.Add(first) зберігає значення. Після second=first зміна second.Point.X=4 не змінює збережене 2. second.Items.Add("ingot") змінює спільний List, тому first.Items.Count()=2. saved=snapshots[0] дозволяє прочитати поля елемента. Результат: 2:4:2:2.


### Внутрішні функції: від виклику до результату

Structure об’єднує типізовані поля, наприклад X, Y і Z, в одне значення. Рушій підтримує структури даних із копіюванням значень; нижче описано підтримувану частину, а не весь Structure із VB.NET.

#### 1. Build / PrepareDefault

Перевірка оголошень передує ініціалізаторам. До 256 типів на скрипт, 1–256 полів у кожному, до 32 рівнів вкладеності. Дублікати, невідомі типи полів, цикли та перевищення меж дають SC030. Доступ Private перевіряється під час розв’язання імен.

`declarations -> field types -> visibility -> cycle/depth checks -> immutable defaults`

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/StructureCatalog.cs`; функція `Build / PrepareDefault`.

#### 2. VisitNewStructure

Dim value As TypeName та New TypeName() створюють типове значення без виконання коду користувача. New потребує порожніх дужок. Аргументи X/Y/Z не передаються: задайте поля після створення. Dim copy = value отримує значення виразу. Префікс UO. не потрібний.

`resolve TypeName -> prepared default value; no procedure call`

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.cs`; функція `VisitNewStructure`.

#### 3. WithField / SetVar

Поля читаються й записуються через крапку, включно з route.Start.X. Запис перевіряє тип поля й оновлює значення, що його містить. copy = value копіює скалярні та вкладені значення: зміна copy.X не змінює value.X. Типи структур мають бути сумісними.

`resolve path -> coerce field -> replace path -> assign new root value`

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/StructureObject.cs`; функція `WithField / SetVar`.

#### 4. CreateArgumentWriter

ByVal передає копію. ByRef копіює на вході та записує назад на виході; оновлення повертається змінній виклику, зокрема полю, яке можна записувати. Указуйте модифікатор явно; без нього діють наявні правила Basic. Return може повернути структуру, Function — оголосити As TypeName.

`ByVal: value copy; ByRef: value copy -> callee -> caller slot write-back`

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.cs`; функція `CreateArgumentWriter`.

#### 5. ValueEquals

= порівнює той самий оголошений тип і відповідні поля; <> дає протилежний результат. Поля-посилання порівнюються за тотожністю. Це розширення рушія, не загальне правило для всіх структур VB.NET. Кешовані хеші й набір уже перевірених пар запобігають повторному розгортанню спільних вкладених значень.

`type identity -> cached hash -> distinct field pairs; reference members keep identity`

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/StructureObject.cs`; функція `ValueEquals`.

Оголошення й присвоєння не мають результату (Unit). New та функції зі структурним результатом повертають значення структури, представлене як Object у спостереженні рушія; відображення містить ім’я типу. Числові координати — кількості, а не Boolean. Порівняння = та <> повертають 1/True або 0/False. Результати прикладів: рядки "1445:1447:1690:0", "10:15:24", "2:4:2:2".

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: structureDeclaration / structureField / newStructure
Runtime/StructureCatalog.cs: Build / PrepareDefault
Runtime/ObjectTypes/StructureObject.cs: ReadField / WithField / ValueEquals
Runtime/BasicSyntaxPreprocessor.cs: NormalizeDim
Runtime/InjectionRuntime.cs: ScriptDeclarations / Load
Runtime/ScriptBindings.cs: Variable / CheckStructureType / CallName
Runtime/SemanticScope.cs: TryMemberRoot / SetVar / Coerce
Runtime/Interpreter.cs: VisitNewStructure / CreateArgumentWriter
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/statements/structure-statement
https://learn.microsoft.com/en-us/dotnet/visual-basic/programming-guide/language-features/data-types/structure-variables
-->
