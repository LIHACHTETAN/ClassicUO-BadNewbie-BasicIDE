# Structure / New / fields

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ru -->

Structure объединяет типизированные поля, например X, Y и Z, в одно значение. Движок поддерживает структуры данных с копированием значений; это описанный ниже набор возможностей, а не весь Structure из VB.NET.

## Точный синтаксис

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

## Параметры

- `TypeName / Public / Private` — Уникальное простое имя типа на уровне файла или внутри Module. По умолчанию Public. Private разрешён только внутри Module: снаружи нельзя обращаться к имени этого типа. Публичный тип модуля указывается как ModuleName.TypeName. Ключевые слова и имена полей не переводятся.
- `field / FieldType` — Уникальное имя поля, затем As и поддерживаемый скалярный тип, Enum либо другая Structure. Поля публичные; допустимы Public, Dim и VAR. Скалярные типы: Integer/Long/Short/Byte, Single/Double/Decimal, String, Boolean/Bool, Object/Variant. Целочисленные псевдонимы используют 32 бита со знаком, как в нашем движке. Вложенные структуры не должны образовывать цикл.
- `Dim / New` — Dim value As TypeName и New TypeName() создают значение по умолчанию без вызова пользовательского кода. У New нужны пустые скобки. Параметры X/Y/Z в них не передаются: поля присваиваются после создания. Dim copy = value получает значение из выражения. Префикс UO. не нужен.
- `value.field / copy` — Чтение и запись через точку, включая route.Start.X. При записи проверяется тип поля и обновляется содержащее его значение. copy = value копирует скалярные и вложенные значения; изменение copy.X не меняет value.X. Присваивать можно совместимый тип структуры.
- `ByVal / ByRef` — ByVal передаёт копию значения. ByRef работает через копирование при входе и обратную запись при выходе: обновлённое значение возвращается в переменную вызывающего кода, в том числе в переданное записываемое поле. Указывайте модификатор явно; без него действуют прежние правила Basic. Return может вернуть структуру, а Function — объявить As TypeName.

## Возвращает

Объявление и присваивание не возвращают результата (Unit). New и функции со структурным результатом возвращают значение структуры: в наблюдении движка это Object, а отображение содержит имя объявленного типа. Числовые координаты являются количеством, а не флагами Boolean. Сравнения структур = и <> возвращают 1/True или 0/False. Результаты примеров — строки "1445:1447:1690:0", "10:15:24" и "2:4:2:2".

## Поведение

- Объявления проверяются до выполнения инициализаторов. Допускаются 256 типов структур на скрипт, от 1 до 256 полей в каждом, вложенность до 32 уровней. Дубликат, неизвестный тип поля, цикл и превышение лимита дают SC030. Доступ к Private проверяется при разрешении имён.
- По умолчанию: целое/Enum — 0, дробное — 0, Boolean — 0/False, String — пустая строка, Object/Variant — Unit до присваивания. Вложенные поля содержат значения своих структур по умолчанию. Инициализация поля прямо в объявлении не поддерживается: задавайте значение после создания.
- Поля Object и массивы сохраняют ссылки при копировании структуры. Поэтому две копии могут использовать один List, Dictionary или массив. Замена скалярного либо вложенного поля независима; изменение содержимого общей коллекции видно в обеих копиях. List сохраняет значение структуры на момент добавления.
- В проекте дополнительно поддерживается сравнение значений: = проверяет один объявленный тип и соответствующие поля, <> даёт обратный результат. Ссылочные поля сравниваются по идентичности. Это расширение движка, а не утверждение, что любой Structure VB.NET поддерживает =. Сохранённые хеши и учёт уже проверенных пар не дают повторно разворачивать общие вложенные значения.
- Поддерживаются публичные типизированные поля данных, доступность типа в Module, New(), присваивание, параметры и результат функции. Методы внутри Structure, свои конструкторы, инициализаторы полей, свойства, наследование и приватные поля не поддерживаются. WITH .field и array[index].field не поддерживаются: сначала получите элемент в переменную, измените её, затем запишите обратно. Объявление можно вынести в отдельный файл Include.

## Примеры

### 1. Координаты и независимая копия

```vb
# Main создаёт original с X=1445 и Y=1690; Z остаётся 0. copy получает значение, затем copy.X += 2 меняет только копию. New Position() создаёт empty с Z=0. Возвращаются четыре поля: 1445:1447:1690:0. Это сохранённые координаты; данный скрипт не передвигает персонажа.
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

**Разбор параметров и выполнения:**

Main создаёт original с X=1445 и Y=1690; Z остаётся 0. copy получает значение, затем copy.X += 2 меняет только копию. New Position() создаёт empty с Z=0. Возвращаются четыре поля: 1445:1447:1690:0. Это сохранённые координаты; данный скрипт не передвигает персонажа.

### 2. Вложенный маршрут, ByVal и ByRef

```vb
# Route содержит Start и Finish типа Position. Shift(point ByVal, dx ByVal) добавляет dx к X копии точки и возвращает Position. При point:=route.Start и dx:=5 shifted.X становится 15, а route.Start.X остаётся 10. Advance(route ByRef, dx ByVal) прибавляет 4 к Finish.X и записывает Route обратно, получая 24. Main возвращает 10:15:24; все вспомогательные процедуры приведены полностью.
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

**Разбор параметров и выполнения:**

Route содержит Start и Finish типа Position. Shift(point ByVal, dx ByVal) добавляет dx к X копии точки и возвращает Position. При point:=route.Start и dx:=5 shifted.X становится 15, а route.Start.X остаётся 10. Advance(route ByRef, dx ByVal) прибавляет 4 к Finish.X и записывает Route обратно, получая 24. Main возвращает 10:15:24; все вспомогательные процедуры приведены полностью.

### 3. Сохранённое значение и общая коллекция

```vb
# Entry содержит вложенное значение Point и поле Items типа Object. first.Point.X=2; first.Items получает List() с одной строкой. snapshots.Add(first) сохраняет значение. После second=first изменение second.Point.X=4 оставляет сохранённый Point равным 2. second.Items.Add("ingot") меняет общий List, поэтому first.Items.Count() равен 2. saved=snapshots[0] — поддерживаемый способ получить элемент и прочитать его поля. Результат: 2:4:2:2.
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

**Разбор параметров и выполнения:**

Entry содержит вложенное значение Point и поле Items типа Object. first.Point.X=2; first.Items получает List() с одной строкой. snapshots.Add(first) сохраняет значение. После second=first изменение second.Point.X=4 оставляет сохранённый Point равным 2. second.Items.Add("ingot") меняет общий List, поэтому first.Items.Count() равен 2. saved=snapshots[0] — поддерживаемый способ получить элемент и прочитать его поля. Результат: 2:4:2:2.


### Внутренние функции: от вызова до результата

Structure объединяет типизированные поля, например X, Y и Z, в одно значение. Движок поддерживает структуры данных с копированием значений; это описанный ниже набор возможностей, а не весь Structure из VB.NET.

#### 1. Build / PrepareDefault

Объявления проверяются до выполнения инициализаторов. Допускаются 256 типов структур на скрипт, от 1 до 256 полей в каждом, вложенность до 32 уровней. Дубликат, неизвестный тип поля, цикл и превышение лимита дают SC030. Доступ к Private проверяется при разрешении имён.

`declarations -> field types -> visibility -> cycle/depth checks -> immutable defaults`

Исходник проекта: `external/InjectionScript/src/InjectionScript/Runtime/StructureCatalog.cs`; функция `Build / PrepareDefault`.

#### 2. VisitNewStructure

Dim value As TypeName и New TypeName() создают значение по умолчанию без вызова пользовательского кода. У New нужны пустые скобки. Параметры X/Y/Z в них не передаются: поля присваиваются после создания. Dim copy = value получает значение из выражения. Префикс UO. не нужен.

`resolve TypeName -> prepared default value; no procedure call`

Исходник проекта: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.cs`; функция `VisitNewStructure`.

#### 3. WithField / SetVar

Чтение и запись через точку, включая route.Start.X. При записи проверяется тип поля и обновляется содержащее его значение. copy = value копирует скалярные и вложенные значения; изменение copy.X не меняет value.X. Присваивать можно совместимый тип структуры.

`resolve path -> coerce field -> replace path -> assign new root value`

Исходник проекта: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/StructureObject.cs`; функция `WithField / SetVar`.

#### 4. CreateArgumentWriter

ByVal передаёт копию значения. ByRef работает через копирование при входе и обратную запись при выходе: обновлённое значение возвращается в переменную вызывающего кода, в том числе в переданное записываемое поле. Указывайте модификатор явно; без него действуют прежние правила Basic. Return может вернуть структуру, а Function — объявить As TypeName.

`ByVal: value copy; ByRef: value copy -> callee -> caller slot write-back`

Исходник проекта: `external/InjectionScript/src/InjectionScript/Runtime/Interpreter.cs`; функция `CreateArgumentWriter`.

#### 5. ValueEquals

В проекте дополнительно поддерживается сравнение значений: = проверяет один объявленный тип и соответствующие поля, <> даёт обратный результат. Ссылочные поля сравниваются по идентичности. Это расширение движка, а не утверждение, что любой Structure VB.NET поддерживает =. Сохранённые хеши и учёт уже проверенных пар не дают повторно разворачивать общие вложенные значения.

`type identity -> cached hash -> distinct field pairs; reference members keep identity`

Исходник проекта: `external/InjectionScript/src/InjectionScript/Runtime/ObjectTypes/StructureObject.cs`; функция `ValueEquals`.

Объявление и присваивание не возвращают результата (Unit). New и функции со структурным результатом возвращают значение структуры: в наблюдении движка это Object, а отображение содержит имя объявленного типа. Числовые координаты являются количеством, а не флагами Boolean. Сравнения структур = и <> возвращают 1/True или 0/False. Результаты примеров — строки "1445:1447:1690:0", "10:15:24" и "2:4:2:2".

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
