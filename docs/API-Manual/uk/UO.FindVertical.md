# UO.FindVertical

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: uk -->

Читає або змінює типову допустиму різницю висоти під час пошуку.

## Точний синтаксис

```text
UO.FindVertical() -> Integer
UO.FindVertical(value:Any) -> Unit
```

## Параметри

- `value` — Необов’язковий Integer. Без аргументу — читання; value — встановлення. Межі 0..120; від’ємне значення стає 0, а не безлімітом. Новий runtime: 2; відновлений стан може мати інше значення. Дробова частина відкидається до нуля; числові рядки decimal/0x теж приймаються. Використовуйте Integer без неявних перетворень.

## Повертає

Без аргументів: Integer — поточна межа (різниця в одиницях світової Z), не ID, кількість об’єктів чи Boolean. 0 — нульова межа, не невдача. З value: Unit — значення немає, це не TRUE/FALSE і не попередня настройка. Прочитайте FindVertical() після запису.

## Поведінка

- Висота: abs(object.Z - player.Z) в обидва боки, включно з межею. 0 допускає лише однакову Z. Це не номер поверху й не горизонтальні клітинки.
- Зберігається в runtime поточного скрипту; його процедури поділяють настройку. Незалежні runtime мають окремі значення. Читання й запис не шукають, не очищають FindItem/FindCount/GetFoundItems, не надсилають пакетів, не рухають персонажа й не завантажують далекі об’єкти.
- FindTypeEx та FindTypesArrayEx застосовують ці межі на землі, а не всередині контейнерів. Діють також type, hue, Ignore та наявність завантажених об’єктів. FindAtCoord ігнорує обидві межі. Явні distance/maxZ розширених команд можуть замінити типові значення; -1 там означає взяти настройку, на відміну від встановлення самої настройки у -1. FindList фільтрує Z також у контейнерах; виняток для контейнерів на нього не поширюється.
- Збережіть значення перед тимчасовим пошуком та відновіть у Finally. Автоматичного скасування немає. Finally працює за звичайного завершення й перехоплюваних помилок; аварійну зупинку не слід використовувати для очищення.
- Джерело: [Stealth FindVertical](https://stealth.od.ua/api/FindVertical/). Цей клієнт має власні початкові значення та межі: FindDistance 18 / 0..255; FindVertical 2 / 0..120. Наведені синтаксис Basic і розширені фільтри стосуються цього проєкту.

### Внутрішні функції: від виклику до результату

Нижче справжні внутрішні етапи. CountGroundInRange — повна користувацька функція, а не прихована команда.

#### 1. ExecuteStealthCompatibility

Нуль аргументів обирає читання; один — перетворення value та запис. Метадані відрізняють Integer від Unit.

Без аргументів: Integer — поточна межа (різниця в одиницях світової Z), не ID, кількість об’єктів чи Boolean. 0 — нульова межа, не невдача. З value: Unit — значення немає, це не TRUE/FALSE і не попередня настройка. Прочитайте FindVertical() після запису.

Код проєкту: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; функція `ExecuteStealthCompatibility`.

#### 2. GetFindVertical

Bridge читає настройку runtime або обмежує й записує ціле число. Світ тут не сканується.

Без аргументів: Integer — поточна межа (різниця в одиницях світової Z), не ID, кількість об’єктів чи Boolean. 0 — нульова межа, не невдача. З value: Unit — значення немає, це не TRUE/FALSE і не попередня настройка. Прочитайте FindVertical() після запису.

Код проєкту: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; функція `GetFindVertical`.

#### 3. SetFindVertical

Bridge читає настройку runtime або обмежує й записує ціле число. Світ тут не сканується.

Необов’язковий Integer. Без аргументу — читання; value — встановлення. Межі 0..120; від’ємне значення стає 0, а не безлімітом. Новий runtime: 2; відновлений стан може мати інше значення. Дробова частина відкидається до нуля; числові рядки decimal/0x теж приймаються. Використовуйте Integer без неявних перетворень.

Код проєкту: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; функція `SetFindVertical`.

#### 4. FindType

Наступний пошук читає настройку, якщо немає явного перевизначення. Наземні Item та Mobile проходять відповідні фільтри відстані й висоти.

FindTypeEx та FindTypesArrayEx застосовують ці межі на землі, а не всередині контейнерів. Діють також type, hue, Ignore та наявність завантажених об’єктів. FindAtCoord ігнорує обидві межі. Явні distance/maxZ розширених команд можуть замінити типові значення; -1 там означає взяти настройку, на відміну від встановлення самої настройки у -1. FindList фільтрує Z також у контейнерах; виняток для контейнерів на нього не поширюється.

Код проєкту: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; функція `FindType`.

#### 5. FindList

Наступний пошук читає настройку, якщо немає явного перевизначення. Наземні Item та Mobile проходять відповідні фільтри відстані й висоти.

FindTypeEx та FindTypesArrayEx застосовують ці межі на землі, а не всередині контейнерів. Діють також type, hue, Ignore та наявність завантажених об’єктів. FindAtCoord ігнорує обидві межі. Явні distance/maxZ розширених команд можуть замінити типові значення; -1 там означає взяти настройку, на відміну від встановлення самої настройки у -1. FindList фільтрує Z також у контейнерах; виняток для контейнерів на нього не поширюється.

Код проєкту: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; функція `FindList`.

Зберігається в runtime поточного скрипту; його процедури поділяють настройку. Незалежні runtime мають окремі значення. Читання й запис не шукають, не очищають FindItem/FindCount/GetFoundItems, не надсилають пакетів, не рухають персонажа й не завантажують далекі об’єкти.


## Приклади

### Читання, запис та обмеження

```vb
# Читання, запис та обмеження
#
# Читає або змінює типову допустиму різницю висоти під час пошуку.
#
# Без аргументів: Integer — поточна межа (різниця в одиницях світової Z), не ID, кількість
# об’єктів чи Boolean. 0 — нульова межа, не невдача. З value: Unit — значення немає, це не
# TRUE/FALSE і не попередня настройка. Прочитайте FindVertical() після запису.

SUB Main()
    # previous зберігає фактичне значення. value:=10 задає звичайну межу; 1000 обмежується до 120.
    # Print читає результат окремим викликом. Finally відновлює previous.

    VAR previous = UO.FindVertical()
    TRY
        UO.FindVertical(value:=10)
        UO.Print(CStr(UO.FindVertical()))
        UO.FindVertical(1000)
        UO.Print(CStr(UO.FindVertical()))
    FINALLY
        UO.FindVertical(previous)
    END TRY
END SUB
```

**Пояснення параметрів і виконання:**

- previous зберігає фактичне значення. value:=10 задає звичайну межу; 1000 обмежується до 120. Print читає результат окремим викликом. Finally відновлює previous.

### Тимчасовий пошук на землі

```vb
# Тимчасовий пошук на землі
#
# Читає або змінює типову допустиму різницю висоти під час пошуку.
#
# Без аргументів: Integer — поточна межа (різниця в одиницях світової Z), не ID, кількість
# об’єктів чи Boolean. 0 — нульова межа, не невдача. З value: Unit — значення немає, це не
# TRUE/FALSE і не попередня настройка. Прочитайте FindVertical() після запису.

SUB Main()
    # previous зберігає настройку викликача. 10 змінює тільки FindVertical; друга межа незмінна.
    # 0x0EED — графіка золота, -1 — будь-який hue, Container=-1 — світ, FALSE — без рекурсії
    # контейнерів. id — serial; <> 0 перевіряє наявність. FindCount рахує об’єкти/стоси. Finally
    # відновлює настройку, не список.

    VAR previous = UO.FindVertical()
    TRY
        UO.FindVertical(10)
        VAR id = UO.FindTypeEx(0x0EED, -1, -1, FALSE)
        IF id <> 0 THEN
            UO.Print(HEX(id) + ':' + CStr(UO.FindCount()))
        ELSE
            UO.Print('0')
        END IF
    FINALLY
        UO.FindVertical(previous)
    END TRY
END SUB
```

**Пояснення параметрів і виконання:**

- previous зберігає настройку викликача. 10 змінює тільки FindVertical; друга межа незмінна. 0x0EED — графіка золота, -1 — будь-який hue, Container=-1 — світ, FALSE — без рекурсії контейнерів. id — serial; <> 0 перевіряє наявність. FindCount рахує об’єкти/стоси. Finally відновлює настройку, не список.

### Повна функція CountGroundInRange

```vb
# Повна функція CountGroundInRange
#
# Читає або змінює типову допустиму різницю висоти під час пошуку.
#
# Без аргументів: Integer — поточна межа (різниця в одиницях світової Z), не ID, кількість
# об’єктів чи Boolean. 0 — нульова межа, не невдача. З value: Unit — значення немає, це не
# TRUE/FALSE і не попередня настройка. Прочитайте FindVertical() після запису.

SUB Main()
    # CountGroundInRange(graphic, radius, height) зберігає обидві межі, задає radius=5 та height=10,
    # шукає graphic=0x0EED і повертає FindCount(). Стос — один об’єкт. Повна функція нижче Main.
    # Finally відновлює межі навіть при Return; результати пошуку залишаються.

    VAR count = CountGroundInRange(0x0EED, 5, 10)
    UO.Print(CStr(count))
END SUB

FUNCTION CountGroundInRange(graphic, radius, height)
    VAR oldDistance = UO.FindDistance()
    VAR oldVertical = UO.FindVertical()
    TRY
        UO.FindDistance(radius)
        UO.FindVertical(height)
        UO.FindTypeEx(graphic, -1, -1, FALSE)
        RETURN UO.FindCount()
    FINALLY
        UO.FindDistance(oldDistance)
        UO.FindVertical(oldVertical)
    END TRY
END FUNCTION
```

**Пояснення параметрів і виконання:**

- CountGroundInRange(graphic, radius, height) зберігає обидві межі, задає radius=5 та height=10, шукає graphic=0x0EED і повертає FindCount(). Стос — один об’єкт. Повна функція нижче Main. Finally відновлює межі навіть при Return; результати пошуку залишаються.
