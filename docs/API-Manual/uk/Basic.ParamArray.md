# ParamArray

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: uk -->

Параметри передають дані в SUB/FUNCTION. ByRef записує змінене значення назад у код виклику; ByVal зберігає його змінну. Optional задає пропущений аргумент, ParamArray збирає решту аргументів. Це модифікатори оголошення, а не окремі команди.

## Точний синтаксис

```text
Function Sum(ParamArray values())
Sum()
Sum(2, 3, 4)
Sum(existingArray)
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

### 1. Порожній та непорожній набір

```vb
# Sum() отримує порожній масив і повертає 0. Sum(2,3,4) отримує три значення та повертає 9. For Each перебирає кожне. Main повертає Integer 9.
Option Explicit On
Function Sum(ParamArray values())
    Var total = 0
    For Each value In values
        total += value
    Next
    Return total
End Function
Sub Main()
    Return Sum() + Sum(2, 3, 4)
End Sub
```

**Пояснення параметрів і виконання:**

Sum() отримує порожній масив і повертає 0. Sum(2,3,4) отримує три значення та повертає 9. For Each перебирає кожне. Main повертає Integer 9.

### 2. Передача готового масиву

```vb
# values містить 2 і 5. Forward передає масив у Sum без додаткової обгортки. Sum додає числа та повертає Integer 7.
Option Explicit On
Function Sum(ParamArray values())
    Var total = 0
    For Each value In values
        total += value
    Next
    Return total
End Function
Function Forward(ParamArray values())
    Return Sum(values)
End Function
Sub Main()
    Dim values[1]
    values[0] = 2
    values[1] = 5
    Return Forward(values)
End Sub
```

**Пояснення параметрів і виконання:**

values містить 2 і 5. Forward передає масив у Sum без додаткової обгортки. Sum додає числа та повертає Integer 7.

### 3. Скаляри та готовий масив

```vb
# SetFirst(first,second) змінює новий масив; first=2 та second=3 зберігаються. SetFirst(packed) змінює спільний packed[0] з 4 на 9. Main повертає 2*100+3*10+9, Integer 239.
Option Explicit On
Sub SetFirst(ParamArray values())
    If GetArrayLength(values) > 0 Then
        values[0] = 9
    End If
End Sub
Sub Main()
    Var first = 2
    Var second = 3
    SetFirst(first, second)
    Dim packed[0]
    packed[0] = 4
    SetFirst(packed)
    Return first * 100 + second * 10 + packed[0]
End Sub
```

**Пояснення параметрів і виконання:**

SetFirst(first,second) змінює новий масив; first=2 та second=3 зберігаються. SetFirst(packed) змінює спільний packed[0] з 4 на 9. Main повертає 2*100+3*10+9, Integer 239.

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
