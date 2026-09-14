# Optional

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: uk -->

Параметри передають дані в SUB/FUNCTION. ByRef записує змінене значення назад у код виклику; ByVal зберігає його змінну. Optional задає пропущений аргумент, ParamArray збирає решту аргументів. Це модифікатори оголошення, а не окремі команди.

## Точний синтаксис

```text
Function Scale(ByVal value, Optional ByVal factor = 2)
Scale(3)
Scale(3, 4)
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

### 1. Множник за замовчуванням та явний

```vb
# Scale(3) використовує factor=2 і повертає 6; Scale(3,4) використовує 4 і повертає 12. Main повертає 6*100+12, Integer 612.
Option Explicit On
Function Scale(ByVal value, Optional ByVal factor = 2)
    Return value * factor
End Function
Sub Main()
    Return Scale(3) * 100 + Scale(3, 4)
End Sub
```

**Пояснення параметрів і виконання:**

Scale(3) використовує factor=2 і повертає 6; Scale(3,4) використовує 4 і повертає 12. Main повертає 6*100+12, Integer 612.

### 2. Час обчислення значення за замовчуванням

```vb
# Pick(5) повертає 5 без DefaultAmount. Pick() викликає його один раз: calls=1, значення 7. Main повертає 5*100+7*10+1, Integer 571.
Option Explicit On
Module Counter
    Public Var calls = 0
End Module
Function DefaultAmount()
    Counter.calls += 1
    Return 7
End Function
Function Pick(Optional ByVal value = DefaultAmount())
    Return value
End Function
Sub Main()
    Var first = Pick(5)
    Var second = Pick()
    Return first * 100 + second * 10 + Counter.calls
End Sub
```

**Пояснення параметрів і виконання:**

Pick(5) повертає 5 без DefaultAmount. Pick() викликає його один раз: calls=1, значення 7. Main повертає 5*100+7*10+1, Integer 571.

### 3. Optional, ByRef та As Integer

```vb
# value починається з 1. Increase(value) додає amount=2 та зберігає 3; Increase(value,4) додає 4 та зберігає 7. Обидва параметри Integer. Main повертає Integer 7.
Option Explicit On
Sub Increase(ByRef value As Integer, Optional ByVal amount As Integer = 2)
    value += amount
End Sub
Sub Main()
    Var value As Integer = 1
    Increase(value)
    Increase(value, 4)
    Return value
End Sub
```

**Пояснення параметрів і виконання:**

value починається з 1. Increase(value) додає amount=2 та зберігає 3; Increase(value,4) додає 4 та зберігає 7. Обидва параметри Integer. Main повертає Integer 7.

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
