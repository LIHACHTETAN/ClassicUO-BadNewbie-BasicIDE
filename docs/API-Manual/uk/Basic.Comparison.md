# =, ==, <>, <, >, <=, >=

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: uk -->

Оператори порівняння перевіряють два значення та дають логічний результат. Його можна використати в IF, зберегти у змінну або повернути з допоміжної функції.

## Точний синтаксис

```text
left = right
left == right
left <> right
left < right
left > right
left <= right
left >= right
```

## Параметри

- `left` — Ліве значення: літерал, оголошена змінна, вираз чи результат функції.
- `right` — Праве значення. Для порівняння порядку потрібні числові Integer або Decimal; рівність підтримує й інші види значень.
- `operator` — = та == у виразі перевіряють рівність; <> — нерівність; < та > — строгий порядок; <= та >= включають рівність. Окрема інструкція name = expression виконує присвоєння.

## Повертає

Integer 1 (TRUE), якщо порівняння істинне, інакше Integer 0 (FALSE). Для цього результату result=1 рівнозначне result=TRUE, а result=0 — result=FALSE. Кількість або ID мають інший зміст: 2 ненульове, але 2=TRUE хибне. Для ненульової кількості перевіряйте count<>0.

## Поведінка

- Integer і Decimal порівнюються чисельно між видами: 5=5.0 істинне. Текст не перетворюється автоматично: "5"=5 хибне. Рядки порівнюються посимвольно з урахуванням регістру: "Ore"<>"ore". Порівняння порядку тексту, масивів, об’єктів чи Unit через <, >, <=, >= спричиняє помилку.
- Рівність масивів і нативних об’єктів перевіряє те саме посилання, а не вміст. Два Unit рівні, але Unit не дорівнює числовому нулю. Різні види нерівні, крім числової пари Integer/Decimal. NaN не дорівнює навіть собі; усі числові порівняння порядку з NaN хибні.
- Арифметика виконується до порівняння. Ланцюжки йдуть зліва направо: 1<3<2 означає (1<3)<2 та дає істину. Для діапазону пишіть (low<=value) AND (value<=high). Дужки явно задають групування.
- Двійкова дробова арифметика округлює: для наближених вимірювань використовуйте Abs(actual-expected)<=tolerance з відповідним невід’ємним допуском. Допуск визначає скрипт, а не самі оператори.
- = порівнює той самий оголошений тип і відповідні поля; <> дає протилежний результат. Поля-посилання порівнюються за тотожністю. Це розширення рушія, не загальне правило для всіх структур VB.NET. Кешовані хеші й набір уже перевірених пар запобігають повторному розгортанню спільних вкладених значень.

## Приклади

### 1. Діапазон із межами та TRUE

```vb
# InRange отримує value=4, low=2, high=5. Обидва порівняння дають 1, AND поєднує їх в 1, Main перевіряє accepted=TRUE. Допоміжна функція і виклик наведені повністю; Main повертає 1.
Option Explicit On
FUNCTION InRange(value, low, high)
    RETURN (low <= value) AND (value <= high)
END FUNCTION
SUB Main()
    VAR accepted = InRange(4, 2, 5)
    IF accepted = TRUE THEN
        RETURN 1
    END IF
    RETURN 0
END SUB
```

**Пояснення параметрів і виконання:**

InRange отримує value=4, low=2, high=5. Обидва порівняння дають 1, AND поєднує їх в 1, Main перевіряє accepted=TRUE. Допоміжна функція і виклик наведені повністю; Main повертає 1.

### 2. Текст, числа й регістр

```vb
# sameCase порівнює "Ore" та "ore" й отримує 0. sameKind порівнює "5" з Integer 5 й отримує 0. converted явно викликає CDbl("5") й отримує 1. CStr формує повернений діагностичний рядок "0:0:1".
Option Explicit On
SUB Main()
    VAR sameCase = ("Ore" = "ore")
    VAR sameKind = ("5" == 5)
    VAR converted = (CDbl("5") = 5)
    RETURN CStr(sameCase) + ":" + CStr(sameKind) + ":" + CStr(converted)
END SUB
```

**Пояснення параметрів і виконання:**

sameCase порівнює "Ore" та "ore" й отримує 0. sameKind порівнює "5" з Integer 5 й отримує 0. converted явно викликає CDbl("5") й отримує 1. CStr формує повернений діагностичний рядок "0:0:1".

### 3. Наближена рівність дробів

```vb
# NearlyEqual отримує 0.1+0.2, expected=0.3, tolerance=0.000001. Від’ємний допуск відхиляється. Abs обчислює величину різниці; <= приймає відхилення в межах допуску. Main повертає 1. Усі параметри допоміжної функції задані явно.
Option Explicit On
FUNCTION NearlyEqual(actual, expected, tolerance)
    IF tolerance < 0 THEN
        RETURN FALSE
    END IF
    RETURN Abs(actual - expected) <= tolerance
END FUNCTION
SUB Main()
    RETURN NearlyEqual(0.1 + 0.2, 0.3, 0.000001)
END SUB
```

**Пояснення параметрів і виконання:**

NearlyEqual отримує 0.1+0.2, expected=0.3, tolerance=0.000001. Від’ємний допуск відхиляється. Abs обчислює величину різниці; <= приймає відхилення в межах допуску. Main повертає 1. Усі параметри допоміжної функції задані явно.

<!-- implementation references (not callable script procedures):
Parsing/injection.g4: logicalOperand / comparativeOperation
Runtime/Interpreter.cs: VisitLogicalOperand
Runtime/InjectionValue.cs: Equals / comparison operators
-->
