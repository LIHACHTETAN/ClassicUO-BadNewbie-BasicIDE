# Named arguments / :=

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: uk -->

Іменовані аргументи пов’язують значення з назвами параметрів незалежно від порядку оголошення. Працюють для процедур і функцій скрипту, модулів, зареєстрованих функцій Basic/UO та методів нативних об’єктів.

## Точний синтаксис

```text
FunctionName(parameterName:=expression, otherName:=expression)
FunctionName(positionalExpression, optionalName:=expression)
FunctionName([reservedName]:=expression)
```

## Параметри

- `parameterName / [reservedName]` — Використовуйте назву з оголошення або сигнатури, без урахування регістру: name:=value. Зарезервовану назву беріть у квадратні дужки: [to]:=100. Це дужки назви, а не індекс масиву. Невідомі й повторні назви спричиняють помилку.
- `expression` — Кожний переданий вираз обчислюється один раз зліва направо в порядку запису. Значення розподіляються за параметрами. Типи, межі та ByVal/ByRef визначає викликана функція. Іменована форма не перетворює звичайне значення на змінну ByRef.
- `positionalExpression / optionalName` — Позиційні аргументи йдуть першими; після першого іменованого решта також іменовані. Обов’язкові параметри не пропускаються. Пропущені Optional у скрипті отримують оголошені типові значення, обчислені за порядком оголошення після переданих виразів. Нативні перевантаження використовують лише зареєстровані назви й кількість, без доданих типових значень.

## Повертає

Запис := не повертає окремого значення. Функція/API повертає власний результат; Sub не має неявного результату. Приклади повертають Integer 129 і рядки "21:12", "20:10:2", а не Boolean.

## Поведінка

- Перевірка до запуску видає SC027 із місцем у джерелі для неправильних назв, повторів, пропущених обов’язкових параметрів або неоднозначності. Динамічний об’єкт перевіряється під час виконання до обчислення аргументів. Відсутнє нативне перевантаження не замінюється викликом без аргументів.
- Інтерпретатор кешує незмінну схему зіставлення статичного виклику. Вирази обчислюються в порядку запису, параметри та зворотний запис ByRef визначає схема. Типові значення й параметри відладчика відповідають вибраній сигнатурі. Динамічний об’єкт захоплюється для поточного виклику, без повторного використання попереднього.
- ParamArray не передається за назвою. За наявності іменованих аргументів він може залишитися порожнім; його елементи передаються лише повністю позиційним викликом. Порожні місця між комами не підтримуються. Правило цього підмножинного Basic — позиційні першими, без вільного змішування нових VB.NET. Потоки й ігрові затримки не змінюються.

## Приклади

### 1. Пропустити середній необов’язковий параметр

```vb
# Encode оголошує x, y=2, z=3. z:=9 передає z першим, x:=1 — x другим, пропущений y отримує 2. Результат 1*100+2*10+9=129. Еквіваленти: Encode(1,2,9) та Encode(1,z:=9).
Option Explicit On
Function Encode(ByVal x, Optional ByVal y=2, Optional ByVal z=3) As Integer
    Return x*100 + y*10 + z
End Function

Sub Main()
    Dim encoded = Encode(z:=9, x:=1)
    Return encoded
End Sub
```

**Пояснення параметрів і виконання:**

Encode оголошує x, y=2, z=3. z:=9 передає z першим, x:=1 — x другим, пропущений y отримує 2. Результат 1*100+2*10+9=129. Еквіваленти: Encode(1,2,9) та Encode(1,z:=9).

### 2. Змінити потрібні змінні через ByRef

```vb
# Change має ByRef left і right. right:=a пов’язує a=1 з right, left:=b — b=2 з left. Додавання 10 до left і 20 до right дає після зворотного запису b=12 та a=21. Main повертає "21:12". Назва ліворуч від := обирає параметр, вираз праворуч — змінну викликача.
Option Explicit On
Sub Change(ByRef left, ByRef right)
    left += 10
    right += 20
End Sub

Sub Main()
    Dim a = 1
    Dim b = 2
    Change(right:=a, left:=b)
    Return CStr(a) & ":" & CStr(b)
End Sub
```

**Пояснення параметрів і виконання:**

Change має ByRef left і right. right:=a пов’язує a=1 з right, left:=b — b=2 з left. Додавання 10 до left і 20 до right дає після зворотного запису b=12 та a=21. Main повертає "21:12". Назва ліворуч від := обирає параметр, вираз праворуч — змінну викликача.

### 3. Іменовані операнди колекції

```vb
# List() створює список. Add(value:=10) додає 10 без результату; Insert(value:=20,index:=0) вставляє 20 на індекс 0 і пересуває 10 на індекс 1. Item(index:=...) повертає елемент, Count() — 2, а Main — "20:10:2". Для UO.Name(...) діють ті самі правила з назвами й результатом конкретної команди.
Option Explicit On
Sub Main()
    Dim items = List()
    items.Add(value:=10)
    items.Insert(value:=20, index:=0)
    Dim first = items.Item(index:=0)
    Dim second = items.Item(index:=1)
    Return CStr(first) & ":" & CStr(second) & ":" & CStr(items.Count())
End Sub
```

**Пояснення параметрів і виконання:**

List() створює список. Add(value:=10) додає 10 без результату; Insert(value:=20,index:=0) вставляє 20 на індекс 0 і пересуває 10 на індекс 1. Item(index:=...) повертає елемент, Count() — 2, а Main — "20:10:2". Для UO.Name(...) діють ті самі правила з назвами й результатом конкретної команди.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: argument
Runtime/NamedArgumentBinding.cs: TryCreate / TryCustom
Runtime/Interpreter.NamedArguments.cs: CallNamed
Runtime/Interpreter.cs: CallSubrutine / CreateArgumentWriter
Analysis/NamedArgumentsValidator.cs
https://learn.microsoft.com/en-us/dotnet/visual-basic/programming-guide/language-features/procedures/passing-arguments-by-position-and-by-name
-->
