# ByVal

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: uk -->

Параметри передають дані в SUB/FUNCTION. ByRef записує змінене значення назад у код виклику; ByVal зберігає його змінну. Optional задає пропущений аргумент, ParamArray збирає решту аргументів. Це модифікатори оголошення, а не окремі команди.

## Точний синтаксис

```text
Sub Change(ByVal value)
Function Increment(ByVal value)
Increment(expression)
```

## Параметри

- `name / As type` — name / As type: Ім’я параметра та необов’язкове перетворення вхідного типу As. Аргументи передаються за позицією або name:=value; модифікатори належать оголошенню. Див. Basic.NamedArguments.
- `ByRef` — ByRef: змінна або наявний індексований елемент. Без ByVal цей рушій також використовує зворотний запис, на відміну від стандартного режиму VB.NET. Літерали, константи та обчислені вирази є тимчасовими значеннями.
- `ByVal` — ByVal: локальна копія значення. Присвоєння параметру не замінює змінну виклику. Масиви й об’єкти зберігають спільні посилання; глибокої копії немає.
- `Optional / defaultValue` — Optional / defaultValue: пропущений кінцевий аргумент обчислює вираз після =. Задавайте явне значення за замовчуванням; без нього пропущений параметр отримує неініціалізоване Unit.
- `ParamArray` — ParamArray values(): останній параметр приймає нуль чи більше решти значень. Один готовий масив використовується напряму, скаляри пакуються в новий масив. GetArrayLength повертає довжину.

## Повертає

Модифікатори не повертають значення. RETURN окремо задає результат функції. ByRef змінює аргумент, а не результат. SUB без RETURN повертає Unit. Числа в прикладах — результати обчислення, не прапорці TRUE/FALSE.

## Поведінка

- Аргументи обчислюються один раз зліва направо. Індексований ByRef зберігає контейнер та індекс/ключ; переприсвоєння змінної контейнера іншим аргументом не змінює місце запису.
- На вході створюються локальні параметри. На виході, після внутрішніх FINALLY, ByRef записується назад у порядку параметрів, зокрема при помилці виходу з тіла. Два параметри однієї змінної не мають живого зв’язку: останній зворотний запис перемагає.
- ByVal захищає змінну виклику від заміни, але дозволяє змінювати спільний масив чи об’єкт. ReDim створює нове локальне посилання. Незалежні дані потребують явної копії.
- Для позиційних викликів: Optional пропускається з кінця; порожні місця між комами не підтримуються. Вираз за замовчуванням виконується при кожному пропуску й не зобов’язаний бути константою VB.NET. Позиційні аргументи йдуть першими; після першого іменованого решта також іменовані. Обов’язкові параметри не пропускаються. Пропущені Optional у скрипті отримують оголошені типові значення, обчислені за порядком оголошення після переданих виразів. Нативні перевантаження використовують лише зареєстровані назви й кількість, без доданих типових значень.
- ParamArray не записує упаковані скаляри назад. Якщо передати готовий масив, зміни елементів видимі зовні. Передача такого масиву іншій ParamArray-функції не додає вкладеності.
- Пишіть ByRef і ByVal явно. Правила стосуються викликів користувацьких процедур зі скрипту; параметри вбудованих команд описані в їхніх картках.
- ParamArray не передається за назвою. За наявності іменованих аргументів він може залишитися порожнім; його елементи передаються лише повністю позиційним викликом. Порожні місця між комами не підтримуються. Правило цього підмножинного Basic — позиційні першими, без вільного змішування нових VB.NET. Потоки й ігрові затримки не змінюються.

## Приклади

### 1. Збереження скаляра

```vb
# Change отримує копію amount=5. Локальне присвоєння 99 не змінює зовнішню змінну. Main повертає Integer 5.
Option Explicit On
Sub Change(ByVal amount)
    amount = 99
End Sub
Sub Main()
    Var amount = 5
    Change(amount)
    Return amount
End Sub
```

**Пояснення параметрів і виконання:**

Change отримує копію amount=5. Локальне присвоєння 99 не змінює зовнішню змінну. Main повертає Integer 5.

### 2. Спільний масив та локальний ReDim

```vb
# ByVal зберігає спільний елемент, який стає 9. ReDim створює інший локальний масив, лише туди записується 20. Зовнішній масив має довжину 1 та значення 9. Main повертає Integer 91.
Option Explicit On
Sub Change(ByVal items)
    items[0] = 9
    ReDim items[1]
    items[0] = 20
End Sub
Sub Main()
    Dim items[0]
    items[0] = 4
    Change(items)
    Return items[0] * 10 + GetArrayLength(items)
End Sub
```

**Пояснення параметрів і виконання:**

ByVal зберігає спільний елемент, який стає 9. ReDim створює інший локальний масив, лише туди записується 20. Зовнішній масив має довжину 1 та значення 9. Main повертає Integer 91.

### 3. Вираз та окремий результат

```vb
# amount+3 дає 7. Increment змінює локальне value на 8 та повертає його. Зовнішнє amount залишається 4. Main повертає 4*10+8, Integer 48.
Option Explicit On
Function Increment(ByVal value)
    value += 1
    Return value
End Function
Sub Main()
    Var amount = 4
    Var result = Increment(amount + 3)
    Return amount * 10 + result
End Sub
```

**Пояснення параметрів і виконання:**

amount+3 дає 7. Increment змінює локальне value на 8 та повертає його. Зовнішнє amount залишається 4. Main повертає 4*10+8, Integer 48.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: parameterName / parameterModifier / defaultValue
Runtime/SubrutineDefinition.cs: WritableParameters / RequiredArgumentCount / HasParamArray
Runtime/Interpreter.cs: VisitCall / CreateArgumentWriter / CallSubrutine / EvaluateInitializer
Runtime/IndexedValueSlot.cs: Read / Write
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/modifiers/byref
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/modifiers/byval
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/modifiers/optional
https://learn.microsoft.com/en-us/dotnet/visual-basic/language-reference/modifiers/paramarray
-->
