# Optional

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: ru -->

Параметры передают данные в SUB/FUNCTION. ByRef позволяет записать изменённое значение обратно вызывающему коду; ByVal сохраняет его переменную. Optional задаёт значение при пропуске аргумента, ParamArray принимает оставшиеся аргументы массивом. Это модификаторы объявления, а не отдельные вызываемые команды.

## Точный синтаксис

```text
Function Scale(ByVal value, Optional ByVal factor = 2)
Scale(3)
Scale(3, 4)
```

## Параметры

- `name / As type` — name / As type: Имя параметра и необязательное преобразование входного типа As. Аргументы передаются по позиции либо name:=value; модификаторы записываются в объявлении. См. Basic.NamedArguments.
- `ByRef` — ByRef: изменяемая переменная или существующий элемент массива/коллекции. Без ByVal параметр этого движка также использует обратную запись; это отличается от значения по умолчанию в VB.NET. Литерал, константа или вычисленное выражение передаются как временное значение.
- `ByVal` — ByVal: локальная копия значения. Присваивание параметру не меняет переменную вызывающего кода. Массивы и объекты при этом остаются общими ссылками, глубокой копии нет.
- `Optional / defaultValue` — Optional / defaultValue: аргумент можно не передавать в конце вызова. Выражение после = вычисляется только при пропуске. Всегда указывайте понятное значение по умолчанию; без него пропущенный параметр получает неинициализированное Unit.
- `ParamArray` — ParamArray values(): последний параметр собирает ноль или больше оставшихся значений. Один переданный массив используется напрямую; список скаляров упаковывается в новый массив. GetArrayLength возвращает его длину.

## Возвращает

Модификаторы сами ничего не возвращают. RETURN задаёт результат функции отдельно. Запись через ByRef — изменение аргумента, а не возвращаемое значение; SUB без RETURN возвращает Unit. Числа в примерах — результаты расчёта, не признаки TRUE/FALSE.

## Поведение

- При вызове аргументы вычисляются слева направо один раз. Для индексированного ByRef сохраняются контейнер и индекс/ключ; изменение переменной контейнера другим аргументом не перенаправляет эту запись.
- При входе создаются локальные параметры. При выходе, после внутренних FINALLY, значения ByRef записываются обратно по порядку параметров, включая выход из тела по ошибке. Передача одной переменной дважды не создаёт живой связи между двумя локальными параметрами: побеждает последняя обратная запись.
- ByVal запрещает замену переменной вызывающего кода, но не изменение содержимого общего массива или объекта. ReDim локального ByVal-массива создаёт новую локальную ссылку. Для независимых данных нужна явная копия.
- Для позиционных вызовов: Необязательные аргументы пропускаются с конца; пустые места между запятыми не поддерживаются. Значение по умолчанию может быть выражением нашего движка и исполняется при каждом пропуске. Оно не обязано быть константой VB.NET. Позиционные аргументы должны идти первыми; после первого именованного все остальные тоже именованные. Обязательные параметры пропускать нельзя. Пропущенные Optional в процедурах получают объявленные значения по умолчанию: они вычисляются по порядку объявления после переданных выражений. Нативные перегрузки принимают только зарегистрированные имена и количество аргументов, без придуманных значений по умолчанию.
- ParamArray не записывает упакованные скаляры обратно в исходные переменные. Если передан готовый массив, изменение его элементов видно вызывающему коду. Повторная передача массива в другую ParamArray-функцию не создаёт лишний уровень вложенности.
- Пишите ByRef и ByVal явно, чтобы читатель видел намерение. Эти правила относятся к вызовам пользовательских процедур из скрипта; параметры встроенных команд описываются в их собственных карточках.
- ParamArray по имени передавать нельзя. При именованном вызове его можно оставить пустым; для передачи его элементов нужен полностью позиционный вызов. Пустые места между запятыми не поддерживаются. Это подмножество с правилом «позиционные сначала», без свободного смешивания из новых VB.NET. Новые потоки не создаются, игровые задержки не меняются.

## Примеры

### 1. Пропущенный и заданный множитель

```vb
# Scale(3) использует factor=2 и возвращает 6. Scale(3,4) использует factor=4 и возвращает 12. Main возвращает 6*100+12, Integer 612.
Option Explicit On
Function Scale(ByVal value, Optional ByVal factor = 2)
    Return value * factor
End Function
Sub Main()
    Return Scale(3) * 100 + Scale(3, 4)
End Sub
```

**Разбор параметров и выполнения:**

Scale(3) использует factor=2 и возвращает 6. Scale(3,4) использует factor=4 и возвращает 12. Main возвращает 6*100+12, Integer 612.

### 2. Когда вычисляется значение по умолчанию

```vb
# Pick(5) возвращает 5 без вызова DefaultAmount. Pick() вызывает DefaultAmount один раз: calls=1, значение 7. Main возвращает 5*100+7*10+1, Integer 571.
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

**Разбор параметров и выполнения:**

Pick(5) возвращает 5 без вызова DefaultAmount. Pick() вызывает DefaultAmount один раз: calls=1, значение 7. Main возвращает 5*100+7*10+1, Integer 571.

### 3. Optional вместе с ByRef и As Integer

```vb
# value начинается с 1. Increase(value) добавляет amount=2 и сохраняет 3; Increase(value,4) добавляет 4 и сохраняет 7. Оба параметра числовые Integer. Main возвращает Integer 7.
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

**Разбор параметров и выполнения:**

value начинается с 1. Increase(value) добавляет amount=2 и сохраняет 3; Increase(value,4) добавляет 4 и сохраняет 7. Оба параметра числовые Integer. Main возвращает Integer 7.

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
