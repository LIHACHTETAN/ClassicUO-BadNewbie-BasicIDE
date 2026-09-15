# AS

ClassicUO • Basic

<!-- yoko-manual: 1 -->
<!-- yoko-language-guide: 1 -->
<!-- yoko-locale: uk -->

AS задає правило перетворення скалярної змінної. Рушій зберігає Integer, Decimal, String, Array, Object і Unit — відсутність значення. Boolean зберігається як Integer 1/0. Цей діалект Basic має власні правила: назва типу не означає відповідну розрядність VB.NET.

## Точний синтаксис

```text
VAR name AS type [= value]
DIM name AS type [= value]
```

## Параметри

- `name` — Ім’я оголошуваної змінної. Читання дає поточне значення; кожне наступне присвоєння знову застосовує AS.
- `type` — Integer, Long, Short, Byte: знакове 32-бітне ціле від -2147483648 до 2147483647; Short і Byte не звужують межі. Double, Single, Decimal: двійкове 64-бітне число з рухомою комою, внутрішня назва Decimal; це не точна десяткова арифметика. String: текст. Boolean, Bool: Integer 1/0. Variant, Object: зберігають вид переданого значення й не вимагають екземпляра об’єкта. Регістр назви не важливий.
- `value` — Необов’язкове початкове значення: число, текст, змінна або результат функції. AS належить оголошенню; явне перетворення у виразі виконують CInt(value), CDbl(value), CStr(value), CBool(value).

## Повертає

Сам AS нічого не повертає. Читання змінної повертає збережені вид і значення. Логічні числові результати: TRUE=1, FALSE=0. Кількість 2 ненульова, але 2=TRUE хибне; наявність предметів перевіряйте через count<>0 або CBool(count).

## Поведінка

- Без ініціалізатора типізований VAR дає 0 для цілих/Boolean, дробовий 0 для Double/Single/Decimal, порожній текст для String. VAR без типу та VAR AS Variant/Object дають Unit. Скалярний DIM підставляє порожній текст для String, інакше 0. Unit під час присвоєння через AS залишається Unit.
- AS Integer відкидає дробову частину допустимого за діапазоном числа до нуля. CInt/CLng округлюють, а половини — від нуля: 2.6 дає 3, тоді як AS Integer зберігає 2. Цілочисельний текст має повністю містити десяткове ціле або 0x-число; "2.6" не підходить. Перевіряйте діапазон до перетворення.
- AS Boolean порівнює початкове значення з числовим нулем: ненульове число дає 1, нуль — 0. Слова не розпізнаються: навіть текст "false" дає 1. CBool спочатку виконує числове перетворення. Використовуйте числа/логічні значення або явно порівнюйте текст із потрібним словом.
- AS String використовує текстове подання рушія. AS Double/Single/Decimal розбирає числовий текст із крапкою. Числове AS перетворює Array на 0, але для Object і неправильного числового тексту видає помилку, яку обробляє TRY/CATCH. CInt/CLng/CDbl/CSng/CBool читають поблажливо: незрозумілий рядок, Array, Object або Unit спочатку стають 0. Перевіряйте IsNumeric(value), перш ніж покладатися на перетворення тексту.
- Рушій обчислює ініціалізатор, вибирає перетворення AS і зберігає результат із назвою типу. Наступне присвоєння повторює перетворення. Дробові значення приблизні; не розраховуйте на точну грошову десяткову арифметику. Області видимості описано у VAR / DIM, захист прив’язки — у CONST.
- Після As також підтримується ім’я оголошеної Structure. VAR і DIM із цим типом без ініціалізатора створюють типові поля. Приймається саме цей оголошений тип; різні структурні типи не перетворюються один на одного. Копіювання вкладених значень і поля-посилання описано в Structure / New.

## Приклади

### 1. Присвоєння та округлення

```vb
# source=2.6 — дробове число. whole AS Integer зберігає 2; CInt(source) повертає 3 у rounded. Main повертає 2*10+3=23 для перевірки обох перетворень.
Option Explicit On
SUB Main()
    VAR source = 2.6
    VAR whole AS Integer = source
    VAR rounded = CInt(source)
    RETURN whole * 10 + rounded
END SUB
```

**Пояснення параметрів і виконання:**

source=2.6 — дробове число. whole AS Integer зберігає 2; CInt(source) повертає 3 у rounded. Main повертає 2*10+3=23 для перевірки обох перетворень.

### 2. Кількість і логічний результат

```vb
# count=2 — кількість предметів. hasItems AS Boolean стає 1. count=TRUE хибне, адже TRUE дорівнює саме 1; count<>0 істинне. Main повертає hasItems=1: предмети є, але їхня кількість не обов’язково один.
Option Explicit On
SUB Main()
    VAR count = 2
    VAR hasItems AS Boolean = count
    IF count = TRUE THEN
        RETURN -1
    END IF
    IF count <> 0 THEN
        RETURN hasItems
    END IF
    RETURN FALSE
END SUB
```

**Пояснення параметрів і виконання:**

count=2 — кількість предметів. hasItems AS Boolean стає 1. count=TRUE хибне, адже TRUE дорівнює саме 1; count<>0 істинне. Main повертає hasItems=1: предмети є, але їхня кількість не обов’язково один.

### 3. Variant зберігає вид значення

```vb
# value AS Variant спочатку зберігає Integer 7, потім String "ore". text AS String починається порожнім. CStr(12) дає текст "12"; з’єднання рядків дає "ore12", яке повертає Main. Variant дозволяє зміну виду значення.
Option Explicit On
SUB Main()
    VAR value AS Variant = 7
    value = "ore"
    VAR text AS String
    text = value + CStr(12)
    RETURN text
END SUB
```

**Пояснення параметрів і виконання:**

value AS Variant спочатку зберігає Integer 7, потім String "ore". text AS String починається порожнім. CStr(12) дає текст "12"; з’єднання рядків дає "ore12", яке повертає Main. Variant дозволяє зміну виду значення.

<!-- implementation references (not callable script procedures):
Runtime/InjectionValueKind.cs
Runtime/SemanticScope.cs: Coerce
Runtime/NumberConversions.cs
Runtime/Interpreter.cs: DefaultValueForType
Runtime/InjectionApi.cs: CInt / CLng / CDbl / CStr / CBool
-->
